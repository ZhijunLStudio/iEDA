#include <iostream>
#include <set>
#include <stdexcept>
#include <string>

#include "RuleCoverage.hpp"

namespace {

void require(bool condition, const std::string& message)
{
  if (!condition) {
    throw std::runtime_error(message);
  }
}

}  // namespace

int main()
{
  try {
    const std::set<std::string> known = {"metal_short", "minimum_area", "minimum_width"};
    const std::set<std::string> loaded = {"metal_short", "minimum_area"};

    auto all_loaded = idrc::RuleCoverageReport::build(known, loaded, {});
    require(all_loaded.canRun(), "all-loaded selection was refused");
    require(all_loaded.getChecked() == loaded, "loaded rules were not marked checked");
    require(all_loaded.getUnsupported() == std::set<std::string>{"minimum_width"}, "unloaded engine rule was not explicit");
    require(all_loaded.status() == "partial_clean", "zero violations became signoff clean");
    auto all_loaded_json = all_loaded.toJson();
    require(all_loaded_json.at("signoff_clean") == false, "report claimed signoff clean without foundry coverage");
    require(all_loaded_json.at("gates").at("G11").at("verdict") == "incomplete", "G11 became green without Calibre evidence");
    require(all_loaded_json.at("gates").at("G11").at("blocking_reasons").is_array()
                && all_loaded_json.at("gates").at("G11").at("blocking_reasons").size() == 2,
            "G11 blockers are not machine readable");

    all_loaded.setViolationCount(2);
    require(all_loaded.status() == "dirty", "violations did not make the report dirty");

    auto subset = idrc::RuleCoverageReport::build(known, loaded, {"metal_short"});
    require(subset.canRun(), "valid explicit subset was refused");
    require(subset.getChecked() == std::set<std::string>{"metal_short"}, "explicit rule was not checked");
    require(subset.getSkipped() == std::set<std::string>{"minimum_area"}, "unselected loaded rule was not marked skipped");

    auto refused = idrc::RuleCoverageReport::build(known, loaded, {"minimum_width", "not_a_rule"});
    require(!refused.canRun() && refused.status() == "refused", "invalid selection was allowed to run");
    require(refused.getRefused().size() == 2, "refusal reasons are incomplete");
    const auto refused_json = refused.toJson();
    require(refused_json.at("execution_started") == false, "refused run was reported as executed");
    require(refused_json.at("gates").at("G14").at("verdict") == "fail", "refused run passed G14");
    require(!refused.refusalSummary().empty(), "refusal has no diagnostic summary");

    std::cout << "iDRC rule coverage tests passed\n";
    return 0;
  } catch (const std::exception& error) {
    std::cerr << "iDRC rule coverage test failure: " << error.what() << '\n';
    return 1;
  }
}
