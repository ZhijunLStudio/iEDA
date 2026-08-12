#include <iostream>
#include <map>
#include <set>
#include <stdexcept>
#include <string>
#include <vector>

#include "ViolationArtifact.hpp"

namespace {

void require(bool condition, const std::string& message)
{
  if (!condition) {
    throw std::runtime_error(message);
  }
}

auto makeContext() -> idrc::CanonicalViolationContext
{
  idrc::CanonicalViolationContext context;
  context.design_name = "tiny";
  context.def_file_path = "/tmp/tiny.def";
  context.temp_directory_path = "/tmp/idrc";
  context.rule_deck_hash = std::string(64, 'a');
  context.dbu_per_micron = 2000;
  context.routing_layer_names = {"M1", "M2"};
  context.cut_layer_names = {"VIA1"};
  context.cut_to_adjacent_routing_map[0] = {0, 1};
  context.regular_net_names[0] = "n1";
  context.regular_net_names[1] = "n2";
  context.special_net_names[2] = "VDD";
  return context;
}

auto makeViolation(std::string type, int32_t ll_x, int32_t ll_y, int32_t ur_x, int32_t ur_y, int32_t layer_idx,
                   bool is_routing, std::set<int32_t> nets, int32_t required_size = 0) -> ids::Violation
{
  ids::Violation violation;
  violation.violation_type = std::move(type);
  violation.ll_x = ll_x;
  violation.ll_y = ll_y;
  violation.ur_x = ur_x;
  violation.ur_y = ur_y;
  violation.layer_idx = layer_idx;
  violation.is_routing = is_routing;
  violation.violation_net_set = std::move(nets);
  violation.required_size = required_size;
  return violation;
}

auto makeCoverage(std::size_t violation_count) -> idrc::RuleCoverageReport
{
  idrc::RuleCoverageReport coverage
      = idrc::RuleCoverageReport::build({"metal_short", "parallel_run_length_spacing", "cut_short"},
                                        {"metal_short", "parallel_run_length_spacing", "cut_short"}, {});
  coverage.setViolationCount(violation_count);
  return coverage;
}

auto buildArtifact() -> nlohmann::ordered_json
{
  std::map<std::string, std::vector<ids::Violation>> by_type;
  by_type["parallel_run_length_spacing"].push_back(
      makeViolation("parallel_run_length_spacing", 100, 100, 150, 180, 1, true, {1}, 40));
  by_type["metal_short"].push_back(makeViolation("metal_short", 10, 20, 30, 40, 0, true, {0, 1}, 0));
  by_type["metal_short"].push_back(makeViolation("metal_short", 10, 20, 30, 40, 0, true, {1, 0}, 0));
  by_type["cut_short"].push_back(makeViolation("cut_short", 50, 60, 70, 80, 0, false, {2}, 5));

  return idrc::buildViolationsArtifact(by_type, makeContext(), makeCoverage(3));
}

void testCanonicalSchemaDedupAndStableOrder()
{
  const auto artifact = buildArtifact();
  std::string reason;
  require(idrc::validateViolationsArtifact(artifact, &reason), "canonical artifact failed validation: " + reason);
  require(artifact.at("schema_version") == "ieda.drc.violations.v1", "schema version changed");
  require(artifact.at("coordinate_units") == "DBU", "coordinate units are not explicit");
  require(artifact.at("dbu_per_micron") == 2000, "DBU provenance missing");
  require(artifact.at("count") == 3, "duplicate violation was not removed");
  require(artifact.at("summary").at("by_type").at("metal_short") == 1, "deduped summary is wrong");

  std::string previous_key;
  for (std::size_t index = 0; index < artifact.at("violations").size(); ++index) {
    const auto& violation = artifact.at("violations").at(index);
    require(violation.at("id") == violation.at("canonical_key"), "id is not the canonical content key");
    require(violation.at("bbox").is_array() && violation.at("bbox").size() == 4, "bbox is not consumer readable");
    require(violation.at("shape_id").is_string() && !violation.at("shape_id").get<std::string>().empty(), "shape_id missing");
    require(violation.at("shape_ids").is_array() && !violation.at("shape_ids").empty(), "shape id missing");
    require(violation.at("shape_ids").at(0) == violation.at("shape_id"), "shape_id adapter fields disagree");
    require(violation.at("net").is_array(), "net mapping missing");
    require(violation.at("source") == "idrc_in_design", "source field changed");
    require(violation.at("stage") == "DRC", "stage field changed");
    require(violation.at("severity").is_number_integer(), "severity is not numeric");
    require(violation.at("repair_hint").at("mutates_db") == false, "repair hint mutates DB");
    const std::string key = violation.at("canonical_key").get<std::string>();
    require(previous_key.empty() || previous_key <= key, "canonical order is unstable");
    previous_key = key;
  }

  bool saw_special_net = false;
  bool saw_cut_layer_mapped_to_routing_layer = false;
  for (const auto& violation : artifact.at("violations")) {
    for (const auto& net : violation.at("net")) {
      saw_special_net = saw_special_net || net.get<std::string>() == "VDD";
    }
    if (violation.at("type") == "cut_short") {
      saw_cut_layer_mapped_to_routing_layer = violation.at("layer") == "M1" && violation.at("source_layer") == "VIA1";
    }
  }
  require(saw_special_net, "special net mapping was lost");
  require(saw_cut_layer_mapped_to_routing_layer, "cut violation did not expose consumer routing layer and source layer");
}

void testInvalidArtifactsFailLoud()
{
  auto artifact = buildArtifact();
  artifact.at("violations").at(0).erase("shape_ids");
  std::string reason;
  require(!idrc::validateViolationsArtifact(artifact, &reason), "missing shape ids were accepted");
  require(reason == "violation shape_ids are missing", "invalid artifact reason changed");

  auto duplicate = buildArtifact();
  duplicate.at("violations").push_back(duplicate.at("violations").at(0));
  require(!idrc::validateViolationsArtifact(duplicate, &reason), "duplicate canonical key was accepted");
}

void testIrtSchemaVersionCompatibility()
{
  nlohmann::json artifact = buildArtifact();
  artifact["schema_version"] = 1;
  std::string reason;
  require(idrc::validateViolationsArtifact(artifact, &reason), "iRT integer schema version was not accepted");
}

void testCVioAdapter()
{
  const auto artifact = buildArtifact();
  const auto c_vio = idrc::buildCVioArtifact(artifact, makeCoverage(3));
  require(c_vio.at("schema") == "c-vio/v1", "C-VIO schema changed");
  require(c_vio.at("summary").at("total") == 3, "C-VIO summary lost canonical count");
  require(c_vio.at("violations").size() == artifact.at("violations").size(), "C-VIO violations diverged");
  require(c_vio.at("coverage").at("signoff_clean") == false, "C-VIO claimed signoff clean");
}

void testCalibreCompareBuckets()
{
  auto idrc_artifact = buildArtifact();
  idrc_artifact["hashes"] = {{"gds_sha256", std::string(64, '1')},
                             {"def_sha256", std::string(64, '2')},
                             {"tech_sha256", std::string(64, '3')},
                             {"deck_sha256", std::string(64, '4')}};
  auto calibre_artifact = idrc_artifact;
  calibre_artifact.at("violations").erase(1);
  auto false_negative = idrc_artifact.at("violations").at(1);
  false_negative["bbox"] = {999, 1000, 1100, 1200};
  false_negative["canonical_key"] = "parallel_run_length_spacing|routing|1|M2|999,1000,1100,1200|40|n2,";
  calibre_artifact.at("violations").push_back(false_negative);
  auto unsupported = idrc_artifact.at("violations").at(2);
  unsupported["bbox"] = {2000, 2000, 2100, 2100};
  unsupported["canonical_key"] = "unsupported_density|routing|1|M2|2000,2000,2100,2100|0|n2,";
  unsupported["unsupported"] = true;
  calibre_artifact.at("violations").push_back(unsupported);

  idrc::CalibreCompareOptions options;
  options.fail_on_false_positive = true;
  const auto result = idrc::compareCalibreArtifacts(idrc_artifact, calibre_artifact, options);
  require(!result.pass, "Calibre mismatch unexpectedly passed");
  require(result.report.at("context_match") == true, "matching hash context was not recognized");
  require(result.report.at("counts").at("true_positive") == 2, "TP bucket wrong");
  require(result.report.at("counts").at("false_positive") == 1, "FP bucket wrong");
  require(result.report.at("counts").at("false_negative") == 1, "FN bucket wrong");
  require(result.report.at("counts").at("unsupported") == 1, "unsupported bucket wrong");

  auto mismatched_calibre = calibre_artifact;
  mismatched_calibre.at("hashes").at("deck_sha256") = std::string(64, '5');
  idrc::CalibreCompareOptions context_options;
  context_options.fail_on_false_negative = false;
  context_options.fail_on_false_positive = false;
  const auto context_result = idrc::compareCalibreArtifacts(idrc_artifact, mismatched_calibre, context_options);
  require(!context_result.pass && context_result.report.at("context_match") == false, "context hash mismatch was accepted");
}

}  // namespace

int main()
{
  try {
    testCanonicalSchemaDedupAndStableOrder();
    testInvalidArtifactsFailLoud();
    testIrtSchemaVersionCompatibility();
    testCVioAdapter();
    testCalibreCompareBuckets();
    std::cout << "iDRC violation artifact tests passed\n";
    return 0;
  } catch (const std::exception& error) {
    std::cerr << "iDRC violation artifact test failure: " << error.what() << '\n';
    return 1;
  }
}
