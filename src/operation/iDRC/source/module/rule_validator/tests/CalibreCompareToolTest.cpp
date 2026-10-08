#include <filesystem>
#include <fstream>
#include <iostream>
#include <map>
#include <set>
#include <stdexcept>
#include <string>
#include <tuple>
#include <vector>

#include "CalibreCompareTool.hpp"

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
  context.design_name = "calibre_tiny";
  context.def_file_path = "/tmp/calibre_tiny.def";
  context.temp_directory_path = "/tmp/idrc_calibre_compare";
  context.rule_deck_hash = std::string(64, 'a');
  context.dbu_per_micron = 2000;
  context.routing_layer_names = {"M1", "M2"};
  context.regular_net_names[0] = "n1";
  context.regular_net_names[1] = "n2";
  return context;
}

auto makeViolation(std::string type, int32_t ll_x, int32_t ll_y, int32_t ur_x, int32_t ur_y, int32_t layer_idx,
                   std::set<int32_t> nets, int32_t required_size = 0) -> ids::Violation
{
  ids::Violation violation;
  violation.violation_type = std::move(type);
  violation.ll_x = ll_x;
  violation.ll_y = ll_y;
  violation.ur_x = ur_x;
  violation.ur_y = ur_y;
  violation.layer_idx = layer_idx;
  violation.is_routing = true;
  violation.violation_net_set = std::move(nets);
  violation.required_size = required_size;
  return violation;
}

auto makeCoverage(std::size_t violation_count) -> idrc::RuleCoverageReport
{
  idrc::RuleCoverageReport coverage
      = idrc::RuleCoverageReport::build({"density", "metal_short", "minimum_width"}, {"density", "metal_short", "minimum_width"}, {});
  coverage.setViolationCount(violation_count);
  return coverage;
}

auto makeArtifact(std::vector<ids::Violation> violations) -> nlohmann::ordered_json
{
  std::map<std::string, std::vector<ids::Violation>> by_type;
  for (auto& violation : violations) {
    by_type[violation.violation_type].push_back(std::move(violation));
  }
  auto artifact = idrc::buildViolationsArtifact(by_type, makeContext(), makeCoverage(violations.size()));
  artifact["hashes"] = {{"gds_sha256", std::string(64, '1')},
                        {"def_sha256", std::string(64, '2')},
                        {"tech_sha256", std::string(64, '3')},
                        {"deck_sha256", std::string(64, '4')}};
  return artifact;
}

void writeJson(const std::filesystem::path& path, const nlohmann::ordered_json& json)
{
  std::ofstream output(path, std::ios::trunc);
  output << json.dump(2) << '\n';
  if (!output) {
    throw std::runtime_error("cannot write fixture: " + path.string());
  }
}

auto readJson(const std::filesystem::path& path) -> nlohmann::json
{
  std::ifstream input(path);
  nlohmann::json json;
  input >> json;
  return json;
}

auto writeFixturePair(const std::filesystem::path& fixture_dir, const nlohmann::ordered_json& idrc_artifact,
                      const nlohmann::ordered_json& calibre_artifact) -> std::pair<std::filesystem::path, std::filesystem::path>
{
  const auto idrc_path = fixture_dir / "idrc_violations.json";
  const auto calibre_path = fixture_dir / "calibre_violations.json";
  writeJson(idrc_path, idrc_artifact);
  writeJson(calibre_path, calibre_artifact);
  return {idrc_path, calibre_path};
}

auto makeConfig(const std::filesystem::path& idrc_path, const std::filesystem::path& calibre_path, const std::filesystem::path& report_path)
    -> idrc::CalibreCompareConfig
{
  idrc::CalibreCompareConfig config;
  config.idrc_artifact_path = idrc_path.string();
  config.calibre_artifact_path = calibre_path.string();
  config.output_report_path = report_path.string();
  config.supported_rule_types = {"metal_short", "minimum_width"};
  return config;
}

void testBucketReportAndOutputFile(const std::filesystem::path& fixture_dir)
{
  const auto idrc_artifact = makeArtifact({makeViolation("metal_short", 10, 20, 30, 40, 0, {0, 1}),
                                           makeViolation("minimum_width", 100, 100, 120, 150, 0, {0}, 40)});
  const auto calibre_artifact = makeArtifact({makeViolation("metal_short", 10, 20, 30, 40, 0, {0, 1}),
                                              makeViolation("minimum_width", 300, 300, 320, 350, 0, {0}, 40),
                                              makeViolation("density", 900, 900, 950, 950, 1, {1})});

  const auto [idrc_path, calibre_path] = writeFixturePair(fixture_dir, idrc_artifact, calibre_artifact);
  const auto report_path = fixture_dir / "calibre_compare_report.json";
  auto config = makeConfig(idrc_path, calibre_path, report_path);
  config.options.fail_on_false_positive = true;

  nlohmann::ordered_json report;
  std::string error;
  const bool pass = idrc::CalibreCompareTool::runToReport(config, &report, &error);
  require(!pass, "FN/FP mismatch unexpectedly passed");
  require(error.empty(), "bucket mismatch should not be reported as an I/O error");
  require(std::filesystem::exists(report_path), "compare report was not written");
  const auto persisted = readJson(report_path);
  require(persisted.at("schema_version") == "ieda.drc.calibre_compare.v1", "report schema changed");
  require(report.at("context_hashes_present") == true && report.at("context_match") == true, "matching context was not accepted");
  require(report.at("counts").at("true_positive") == 1, "TP bucket wrong");
  require(report.at("counts").at("false_positive") == 1, "FP bucket wrong");
  require(report.at("counts").at("false_negative") == 1, "FN bucket wrong");
  require(report.at("counts").at("unsupported") == 1, "unsupported bucket wrong");
  require(report.at("policy").at("supported_rule_types").size() == 2, "supported subset was not recorded");
  require(report.at("signoff_clean") == false, "Calibre subset report claimed signoff clean");
  require(report.at("scope") == "calibre_supported_subset_only", "report scope is ambiguous");
}

void testSubsetPassIsNotSignoffClean(const std::filesystem::path& fixture_dir)
{
  const auto idrc_artifact = makeArtifact({makeViolation("metal_short", 10, 20, 30, 40, 0, {0, 1})});
  const auto calibre_artifact
      = makeArtifact({makeViolation("metal_short", 10, 20, 30, 40, 0, {0, 1}), makeViolation("density", 900, 900, 950, 950, 1, {1})});
  const auto [idrc_path, calibre_path] = writeFixturePair(fixture_dir, idrc_artifact, calibre_artifact);
  auto config = makeConfig(idrc_path, calibre_path, fixture_dir / "subset_pass.json");

  nlohmann::ordered_json report;
  std::string error;
  const bool pass = idrc::CalibreCompareTool::runToReport(config, &report, &error);
  require(pass, "supported subset match did not pass");
  require(report.at("counts").at("unsupported") == 1, "unsupported Calibre rule was hidden");
  require(report.at("signoff_clean") == false, "supported subset pass became signoff clean");
}

void testContextGuards(const std::filesystem::path& fixture_dir)
{
  const auto idrc_artifact = makeArtifact({makeViolation("metal_short", 10, 20, 30, 40, 0, {0, 1})});
  auto calibre_artifact = idrc_artifact;
  calibre_artifact.at("hashes").at("deck_sha256") = std::string(64, '5');

  auto [idrc_path, calibre_path] = writeFixturePair(fixture_dir, idrc_artifact, calibre_artifact);
  auto config = makeConfig(idrc_path, calibre_path, fixture_dir / "hash_mismatch.json");
  nlohmann::ordered_json report;
  std::string error;
  require(!idrc::CalibreCompareTool::runToReport(config, &report, &error), "deck hash mismatch was accepted");
  require(report.at("context_match") == false, "deck hash mismatch was not reported");

  auto missing_hash_idrc = idrc_artifact;
  missing_hash_idrc.at("hashes").erase("tech_sha256");
  std::tie(idrc_path, calibre_path) = writeFixturePair(fixture_dir, missing_hash_idrc, idrc_artifact);
  config = makeConfig(idrc_path, calibre_path, fixture_dir / "missing_hash.json");
  report.clear();
  error.clear();
  require(!idrc::CalibreCompareTool::runToReport(config, &report, &error), "missing input hash was accepted");
  require(report.at("context_hashes_present") == false, "missing context hash was not reported");
  require(report.at("missing_context_hashes").at("idrc").size() == 1
              && report.at("missing_context_hashes").at("idrc").at(0) == "tech_sha256",
          "missing hash diagnostic is not stable");
}

void testSupportedSubsetIsMandatory(const std::filesystem::path& fixture_dir)
{
  const auto idrc_artifact = makeArtifact({makeViolation("metal_short", 10, 20, 30, 40, 0, {0, 1})});
  const auto [idrc_path, calibre_path] = writeFixturePair(fixture_dir, idrc_artifact, idrc_artifact);
  auto config = makeConfig(idrc_path, calibre_path, fixture_dir / "missing_subset.json");
  config.supported_rule_types.clear();

  nlohmann::ordered_json report;
  std::string error;
  require(!idrc::CalibreCompareTool::runToReport(config, &report, &error), "empty supported subset was accepted");
  require(error == "Calibre compare requires an explicit supported rule subset", "empty subset diagnostic changed");
}

}  // namespace

int main()
{
  try {
    const auto fixture_dir = std::filesystem::temp_directory_path() / "ieda_idrc_calibre_compare_test";
    std::filesystem::create_directories(fixture_dir);
    testBucketReportAndOutputFile(fixture_dir);
    testSubsetPassIsNotSignoffClean(fixture_dir);
    testContextGuards(fixture_dir);
    testSupportedSubsetIsMandatory(fixture_dir);
    std::cout << "iDRC Calibre compare tests passed\n";
    return 0;
  } catch (const std::exception& error) {
    std::cerr << "iDRC Calibre compare test failure: " << error.what() << '\n';
    return 1;
  }
}
