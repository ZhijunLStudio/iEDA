#include <filesystem>
#include <fstream>
#include <iostream>
#include <set>
#include <stdexcept>
#include <string>
#include <string_view>

#include "RuleCoverage.hpp"

namespace {

void require(bool condition, const std::string& message)
{
  if (!condition) {
    throw std::runtime_error(message);
  }
}

auto hasBlockingReason(const nlohmann::json& gate, std::string_view expected) -> bool
{
  for (const auto& reason : gate.at("blocking_reasons")) {
    if (reason.get<std::string>() == expected) {
      return true;
    }
  }
  return false;
}

void writeJson(const std::filesystem::path& path, const nlohmann::ordered_json& json)
{
  std::ofstream output(path, std::ios::trunc);
  output << json.dump(2) << '\n';
  if (!output) {
    throw std::runtime_error("cannot write manifest fixture");
  }
}

}  // namespace

int main()
{
  try {
    const std::set<std::string> known = {"metal_short", "minimum_area", "minimum_width"};
    const std::set<std::string> loaded = {"metal_short", "minimum_area"};
    const auto fast_check = idrc::getFastCheckRuleNames();
    const std::set<std::string> expected_fast_check = {"cut_short", "maximum_width", "metal_short", "minimum_area", "minimum_width",
                                                       "nonsufficient_metal_overlap", "off_grid_or_wrong_way", "out_of_die"};
    require(fast_check == expected_fast_check, "fast-check profile changed unexpectedly");

    auto all_loaded = idrc::RuleCoverageReport::build(known, loaded, {});
    require(all_loaded.canRun(), "all-loaded selection was refused");
    require(all_loaded.getChecked() == loaded, "loaded rules were not marked checked");
    require(all_loaded.getUnsupported() == std::set<std::string>{"minimum_width"}, "unloaded engine rule was not explicit");
    require(all_loaded.status() == "partial_clean", "zero violations became signoff clean");
    require(all_loaded.profile() == "all_loaded_rules", "default profile changed unexpectedly");
    auto all_loaded_json = all_loaded.toJson();
    require(all_loaded_json.at("signoff_clean") == false, "report claimed signoff clean without foundry coverage");
    require(all_loaded_json.at("gates").at("G11").at("verdict") == "incomplete", "G11 became green without Calibre evidence");
    require(all_loaded_json.at("check_profile") == "all_loaded_rules", "coverage JSON lost profile");
    require(all_loaded_json.at("gates").at("G11").at("blocking_reasons").is_array()
                && all_loaded_json.at("gates").at("G11").at("blocking_reasons").size() == 2,
            "G11 blockers are not machine readable");

    all_loaded.setViolationCount(2);
    require(all_loaded.status() == "dirty", "violations did not make the report dirty");
    auto subset = idrc::RuleCoverageReport::build(known, loaded, {"metal_short"});
    require(subset.canRun(), "valid explicit subset was refused");
    require(subset.getChecked() == std::set<std::string>{"metal_short"}, "explicit rule was not checked");
    require(subset.getSkipped() == std::set<std::string>{"minimum_area"}, "unselected loaded rule was not marked skipped");
    require(subset.profile() == "custom_subset", "custom subset profile collapsed into a preset");

    std::set<std::string> fast_loaded = fast_check;
    fast_loaded.insert("floating_patch");
    auto fast_report = idrc::RuleCoverageReport::build(fast_loaded, fast_loaded, fast_check);
    require(fast_report.canRun(), "fast-check profile was refused");
    require(fast_report.getChecked() == fast_check, "fast-check profile did not select the expected rules");
    require(fast_report.getSkipped() == std::set<std::string>{"floating_patch"}, "fast-check profile skipped set is wrong");
    require(fast_report.status() == "partial_clean", "fast-check profile became signoff clean");
    require(fast_report.profile() == "idrc_fast_check_v1", "fast-check profile was not recognized");
    require(fast_report.toJson().at("check_profile") == "idrc_fast_check_v1", "fast-check JSON profile is missing");
    require(fast_report.toJson().at("signoff_clean") == false, "fast-check JSON claimed signoff clean");

    auto refused = idrc::RuleCoverageReport::build(known, loaded, {"minimum_width", "not_a_rule"});
    require(!refused.canRun() && refused.status() == "refused", "invalid selection was allowed to run");
    require(refused.getRefused().size() == 2, "refusal reasons are incomplete");
    const auto refused_json = refused.toJson();
    require(refused_json.at("execution_started") == false, "refused run was reported as executed");
    require(refused_json.at("gates").at("G14").at("verdict") == "fail", "refused run passed G14");
    require(!refused.refusalSummary().empty(), "refusal has no diagnostic summary");

    const auto fixture_dir = std::filesystem::temp_directory_path() / "ieda_rule_coverage_manifest_test";
    std::filesystem::create_directories(fixture_dir);
    const std::string deck_hash(64, 'a');
    const auto valid_manifest_path = fixture_dir / "valid.json";
    writeJson(valid_manifest_path,
              {{"schema_version", "ieda.drc.rule_coverage.v1"},
               {"pdk", "synthetic"},
               {"deck", {{"id", "synthetic-deck-v1"}, {"sha256", deck_hash}}},
               {"rules",
                {{{"foundry_id", "M1.SHORT"}, {"state", "implemented"}, {"ieda_rule", "metal_short"}},
                 {{"foundry_id", "M1.AREA"}, {"state", "partial"}, {"ieda_rule", "minimum_area"}, {"note", "microcase only"}},
                 {{"foundry_id", "M1.DENSITY"}, {"state", "missing"}}}}});

    const auto manifest = idrc::FoundryCoverageManifest::load(valid_manifest_path.string(), known);
    require(manifest.valid(), "valid foundry manifest was rejected");
    auto covered = idrc::RuleCoverageReport::build(known, loaded, {});
    covered.attachFoundryCoverage(manifest, loaded);
    require(covered.canRun(), "transparent partial/missing coverage prevented an in-design run");
    const auto covered_json = covered.toJson();
    require(covered_json.at("foundry_coverage_table_loaded") == true, "valid foundry coverage was not attached");
    require(covered_json.at("foundry_coverage").at("deck").at("sha256_verification") == "declared_format_only",
            "declared deck hash was incorrectly presented as content-verified provenance");
    require(covered_json.at("foundry_coverage").at("checked").size() == 1
                && covered_json.at("foundry_coverage").at("checked").at(0) == "M1.SHORT",
            "implemented foundry rule was not marked checked");
    require(covered_json.at("foundry_coverage").at("partial").size() == 1
                && covered_json.at("foundry_coverage").at("partial").at(0) == "M1.AREA",
            "partial foundry rule was hidden");
    require(covered_json.at("foundry_coverage").at("unsupported").size() == 1
                && covered_json.at("foundry_coverage").at("unsupported").at(0) == "M1.DENSITY",
            "missing foundry rule was hidden");
    require(hasBlockingReason(covered_json.at("gates").at("G11"), "partial_foundry_rules_present")
                && hasBlockingReason(covered_json.at("gates").at("G11"), "missing_foundry_rules_present")
                && hasBlockingReason(covered_json.at("gates").at("G11"), "calibre_alignment_not_attached")
                && !hasBlockingReason(covered_json.at("gates").at("G11"), "foundry_coverage_table_not_loaded"),
            "G11 blockers do not reflect attached manifest evidence");

    const auto stale_manifest_path = fixture_dir / "stale.json";
    writeJson(stale_manifest_path,
              {{"schema_version", "ieda.drc.rule_coverage.v1"},
               {"pdk", "synthetic"},
               {"deck", {{"id", "synthetic-deck-v1"}, {"sha256", deck_hash}}},
               {"rules", {{{"foundry_id", "M1.WIDTH"}, {"state", "implemented"}, {"ieda_rule", "minimum_width"}}}}});
    auto stale = idrc::RuleCoverageReport::build(known, loaded, {});
    stale.attachFoundryCoverage(idrc::FoundryCoverageManifest::load(stale_manifest_path.string(), known), loaded);
    require(!stale.canRun(), "manifest claiming an unloaded technology rule was allowed");
    const auto stale_json = stale.toJson();
    require(stale_json.at("gates").at("G14").at("verdict") == "fail"
                && hasBlockingReason(stale_json.at("gates").at("G11"), "foundry_coverage_table_invalid"),
            "stale manifest did not fail loud");

    const auto invalid_manifest_path = fixture_dir / "invalid.json";
    writeJson(invalid_manifest_path,
              {{"schema_version", "ieda.drc.rule_coverage.v1"},
               {"pdk", "synthetic"},
               {"deck", {{"id", "synthetic-deck-v1"}, {"sha256", "not-a-sha256"}}},
               {"rules",
                {{{"foundry_id", "M1.SHORT"}, {"state", "implemented"}, {"ieda_rule", "metal_short"}},
                 {{"foundry_id", "M1.SHORT"}, {"state", "implemented"}, {"ieda_rule", "metal_short"}}}}});
    const auto invalid_manifest = idrc::FoundryCoverageManifest::load(invalid_manifest_path.string(), known);
    require(!invalid_manifest.valid() && invalid_manifest.getErrors().size() == 2,
            "bad deck provenance or duplicate foundry IDs were accepted");
    auto invalid = idrc::RuleCoverageReport::build(known, loaded, {});
    invalid.attachFoundryCoverage(invalid_manifest, loaded);
    require(!invalid.canRun() && invalid.toJson().at("gates").at("G14").at("verdict") == "fail",
            "invalid manifest did not refuse execution");

    std::cout << "iDRC rule coverage tests passed\n";
    return 0;
  } catch (const std::exception& error) {
    std::cerr << "iDRC rule coverage test failure: " << error.what() << '\n';
    return 1;
  }
}
