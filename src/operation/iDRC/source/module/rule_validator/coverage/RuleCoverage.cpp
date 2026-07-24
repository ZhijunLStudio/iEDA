// ***************************************************************************************
// Copyright (c) 2023-2025 Peng Cheng Laboratory
// Copyright (c) 2023-2025 Institute of Computing Technology, Chinese Academy of Sciences
// Copyright (c) 2023-2025 Beijing Institute of Open Source Chip
//
// iEDA is licensed under Mulan PSL v2.
// ***************************************************************************************
#include "RuleCoverage.hpp"

#include <sstream>

namespace idrc {
namespace {

auto setToJson(const std::set<std::string>& values) -> nlohmann::ordered_json
{
  nlohmann::ordered_json json = nlohmann::ordered_json::array();
  for (const auto& value : values) {
    json.push_back(value);
  }
  return json;
}

}  // namespace

auto RuleCoverageReport::build(const std::set<std::string>& known_rules, const std::set<std::string>& loaded_rules,
                               const std::set<std::string>& requested_rules) -> RuleCoverageReport
{
  RuleCoverageReport report;
  report._requested = requested_rules;

  for (const auto& known_rule : known_rules) {
    if (!loaded_rules.contains(known_rule)) {
      report._unsupported.insert(known_rule);
    }
  }

  if (requested_rules.empty()) {
    report._checked = loaded_rules;
    return report;
  }

  for (const auto& requested_rule : requested_rules) {
    if (!known_rules.contains(requested_rule)) {
      report._refused.push_back({requested_rule, "unknown_rule"});
    } else if (!loaded_rules.contains(requested_rule)) {
      report._refused.push_back({requested_rule, "rule_not_loaded_from_technology"});
    } else {
      report._checked.insert(requested_rule);
    }
  }
  for (const auto& loaded_rule : loaded_rules) {
    if (!report._checked.contains(loaded_rule)) {
      report._skipped.insert(loaded_rule);
    }
  }
  return report;
}

auto RuleCoverageReport::status() const -> std::string
{
  if (!canRun()) {
    return "refused";
  }
  if (_violation_count != 0) {
    return "dirty";
  }
  return "partial_clean";
}

auto RuleCoverageReport::toJson() const -> nlohmann::ordered_json
{
  nlohmann::ordered_json refused = nlohmann::ordered_json::array();
  for (const auto& item : _refused) {
    refused.push_back({{"rule", item.name}, {"reason", item.reason}});
  }

  nlohmann::ordered_json json;
  json["schema_version"] = "ieda.drc.coverage.v1";
  json["status"] = status();
  json["signoff_clean"] = false;
  json["execution_started"] = canRun();
  json["violation_count"] = _violation_count;
  json["selection_mode"] = _requested.empty() ? "all_loaded_rules" : "explicit_subset";
  json["coverage_basis"] = "ieda_engine_families_and_technology_loaded_rules_only";
  json["foundry_coverage_table_loaded"] = false;
  json["requested"] = setToJson(_requested);
  json["checked"] = setToJson(_checked);
  json["skipped"] = setToJson(_skipped);
  json["unsupported"] = setToJson(_unsupported);
  json["refused"] = std::move(refused);
  json["gates"]["G11"] = {
      {"verdict", "incomplete"}, {"blocking_reasons", {"foundry_coverage_table_not_loaded", "calibre_alignment_not_attached"}}};
  json["gates"]["G14"] = {{"verdict", canRun() ? "pass" : "fail"}};
  return json;
}

auto RuleCoverageReport::refusalSummary() const -> std::string
{
  std::ostringstream summary;
  for (std::size_t index = 0; index < _refused.size(); ++index) {
    if (index != 0) {
      summary << ", ";
    }
    summary << _refused[index].name << " (" << _refused[index].reason << ')';
  }
  return summary.str();
}

}  // namespace idrc
