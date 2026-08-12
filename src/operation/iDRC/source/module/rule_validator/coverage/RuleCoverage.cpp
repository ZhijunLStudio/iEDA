// ***************************************************************************************
// Copyright (c) 2023-2025 Peng Cheng Laboratory
// Copyright (c) 2023-2025 Institute of Computing Technology, Chinese Academy of Sciences
// Copyright (c) 2023-2025 Beijing Institute of Open Source Chip
//
// iEDA is licensed under Mulan PSL v2.
// ***************************************************************************************
#include "RuleCoverage.hpp"

#include <algorithm>
#include <cctype>
#include <fstream>
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

auto vectorToJson(const std::vector<std::string>& values) -> nlohmann::ordered_json
{
  nlohmann::ordered_json json = nlohmann::ordered_json::array();
  for (const auto& value : values) {
    json.push_back(value);
  }
  return json;
}

auto buildFastCheckRuleNames() -> std::set<std::string>
{
  return {"cut_short", "maximum_width", "metal_short", "minimum_area", "minimum_width", "nonsufficient_metal_overlap",
          "off_grid_or_wrong_way", "out_of_die"};
}

auto isSha256(const std::string& value) -> bool
{
  return value.size() == 64 && std::all_of(value.begin(), value.end(), [](unsigned char character) { return std::isxdigit(character); });
}

auto nonEmptyString(const nlohmann::json& json, const char* key) -> std::string
{
  if (!json.contains(key) || !json.at(key).is_string()) {
    return {};
  }
  return json.at(key).get<std::string>();
}

}  // namespace

auto buildRuleValidatorStatsJson(const RuleValidatorRunStats& stats) -> nlohmann::ordered_json
{
  nlohmann::ordered_json per_rule = nlohmann::ordered_json::object();
  for (const auto& [rule, rule_stats] : stats.per_rule) {
    per_rule[rule] = {{"runtime_seconds", rule_stats.runtime_seconds},
                      {"cluster_count", rule_stats.cluster_count},
                      {"violation_count", rule_stats.violation_count}};
  }

  return {{"runtime_seconds", stats.runtime_seconds},
          {"thread_count", stats.thread_count},
          {"cluster_count", stats.cluster_count},
          {"verified_cluster_count", stats.verified_cluster_count},
          {"stale_cluster_cache_count", stats.stale_cluster_cache_count},
          {"peak_rss_mb", stats.peak_rss_mb},
          {"per_rule", std::move(per_rule)}};
}

auto getFastCheckRuleNames() -> const std::set<std::string>&
{
  static const std::set<std::string> kFastCheckRuleNames = buildFastCheckRuleNames();
  return kFastCheckRuleNames;
}

auto FoundryCoverageManifest::load(const std::string& path, const std::set<std::string>& known_engine_rules)
    -> FoundryCoverageManifest
{
  FoundryCoverageManifest manifest;
  manifest._source_path = path;

  std::ifstream input(path);
  if (!input.is_open()) {
    manifest._errors.push_back("manifest_not_readable");
    return manifest;
  }

  nlohmann::json json;
  try {
    input >> json;
  } catch (const std::exception&) {
    manifest._errors.push_back("manifest_invalid_json");
    return manifest;
  }

  if (!json.is_object()) {
    manifest._errors.push_back("manifest_root_not_object");
    return manifest;
  }
  if (nonEmptyString(json, "schema_version") != "ieda.drc.rule_coverage.v1") {
    manifest._errors.push_back("unsupported_schema_version");
  }
  manifest._pdk = nonEmptyString(json, "pdk");
  if (manifest._pdk.empty()) {
    manifest._errors.push_back("pdk_missing");
  }

  if (!json.contains("deck") || !json.at("deck").is_object()) {
    manifest._errors.push_back("deck_identity_missing");
  } else {
    const auto& deck = json.at("deck");
    manifest._deck_id = nonEmptyString(deck, "id");
    manifest._deck_sha256 = nonEmptyString(deck, "sha256");
    if (manifest._deck_id.empty()) {
      manifest._errors.push_back("deck_id_missing");
    }
    if (!isSha256(manifest._deck_sha256)) {
      manifest._errors.push_back("deck_sha256_invalid");
    }
  }

  if (!json.contains("rules") || !json.at("rules").is_array() || json.at("rules").empty()) {
    manifest._errors.push_back("rules_missing_or_empty");
    return manifest;
  }

  std::set<std::string> foundry_ids;
  for (std::size_t index = 0; index < json.at("rules").size(); ++index) {
    const auto& rule_json = json.at("rules").at(index);
    if (!rule_json.is_object()) {
      manifest._errors.push_back("rule_" + std::to_string(index) + "_not_object");
      continue;
    }

    FoundryRuleMapping rule;
    rule.foundry_id = nonEmptyString(rule_json, "foundry_id");
    rule.state = nonEmptyString(rule_json, "state");
    rule.ieda_rule = nonEmptyString(rule_json, "ieda_rule");
    rule.note = nonEmptyString(rule_json, "note");
    if (rule.foundry_id.empty()) {
      manifest._errors.push_back("rule_" + std::to_string(index) + "_foundry_id_missing");
      continue;
    }
    if (!foundry_ids.insert(rule.foundry_id).second) {
      manifest._errors.push_back("duplicate_foundry_rule:" + rule.foundry_id);
      continue;
    }
    if (rule.state != "implemented" && rule.state != "partial" && rule.state != "missing") {
      manifest._errors.push_back("invalid_state:" + rule.foundry_id);
    }
    if (rule.state == "implemented" || rule.state == "partial") {
      if (rule.ieda_rule.empty()) {
        manifest._errors.push_back("mapped_rule_missing:" + rule.foundry_id);
      } else if (!known_engine_rules.contains(rule.ieda_rule)) {
        manifest._errors.push_back("unknown_engine_rule:" + rule.foundry_id + ":" + rule.ieda_rule);
      }
    } else if (rule.state == "missing" && !rule.ieda_rule.empty()) {
      manifest._errors.push_back("missing_rule_must_not_claim_mapping:" + rule.foundry_id);
    }
    manifest._rules.push_back(std::move(rule));
  }
  return manifest;
}

auto FoundryCoverageManifest::toJson() const -> nlohmann::ordered_json
{
  nlohmann::ordered_json rules = nlohmann::ordered_json::array();
  for (const auto& rule : _rules) {
    rules.push_back({{"foundry_id", rule.foundry_id}, {"state", rule.state}, {"ieda_rule", rule.ieda_rule}, {"note", rule.note}});
  }
  return {{"source_path", _source_path},
          {"valid", valid()},
          {"pdk", _pdk},
          {"deck", {{"id", _deck_id}, {"sha256", _deck_sha256}, {"sha256_verification", "declared_format_only"}}},
          {"rules", std::move(rules)},
          {"errors", vectorToJson(_errors)}};
}

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

void RuleCoverageReport::attachFoundryCoverage(const FoundryCoverageManifest& manifest, const std::set<std::string>& loaded_rules)
{
  _foundry_coverage_attached = true;
  _foundry_manifest = manifest;
  _manifest_errors = manifest.getErrors();
  if (!manifest.valid()) {
    return;
  }

  for (const auto& rule : manifest.getRules()) {
    if (rule.state == "missing") {
      _foundry_unsupported.insert(rule.foundry_id);
      continue;
    }
    if (!loaded_rules.contains(rule.ieda_rule)) {
      _manifest_errors.push_back("mapped_engine_rule_not_loaded:" + rule.foundry_id + ":" + rule.ieda_rule);
      continue;
    }
    if (rule.state == "partial") {
      _foundry_partial.insert(rule.foundry_id);
      continue;
    }
    if (_checked.contains(rule.ieda_rule)) {
      _foundry_checked.insert(rule.foundry_id);
    } else {
      _foundry_skipped.insert(rule.foundry_id);
    }
  }
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

auto RuleCoverageReport::profile() const -> std::string
{
  if (_requested.empty()) {
    return "all_loaded_rules";
  }
  if (_requested == getFastCheckRuleNames()) {
    return "idrc_fast_check_v1";
  }
  return "custom_subset";
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
  json["check_profile"] = profile();
  json["signoff_clean"] = false;
  json["execution_started"] = canRun();
  json["violation_count"] = _violation_count;
  json["selection_mode"] = _requested.empty() ? "all_loaded_rules" : "explicit_subset";
  json["coverage_basis"] = "ieda_engine_families_and_technology_loaded_rules_only";
  json["foundry_coverage_table_loaded"] = _foundry_coverage_attached && _foundry_manifest.valid();
  json["requested"] = setToJson(_requested);
  json["checked"] = setToJson(_checked);
  json["skipped"] = setToJson(_skipped);
  json["unsupported"] = setToJson(_unsupported);
  json["refused"] = std::move(refused);
  json["runtime"] = buildRuleValidatorStatsJson(_run_stats);
  json["runtime"]["attached"] = _run_stats_attached;
  nlohmann::ordered_json foundry_coverage = _foundry_manifest.toJson();
  foundry_coverage["checked"] = setToJson(_foundry_checked);
  foundry_coverage["skipped"] = setToJson(_foundry_skipped);
  foundry_coverage["partial"] = setToJson(_foundry_partial);
  foundry_coverage["unsupported"] = setToJson(_foundry_unsupported);
  foundry_coverage["runtime_errors"] = vectorToJson(_manifest_errors);
  foundry_coverage["total_rule_count"] = _foundry_manifest.getRules().size();
  foundry_coverage["fully_implemented_rule_count"] = _foundry_checked.size() + _foundry_skipped.size();
  foundry_coverage["partial_rule_count"] = _foundry_partial.size();
  foundry_coverage["missing_rule_count"] = _foundry_unsupported.size();
  json["foundry_coverage"] = std::move(foundry_coverage);

  nlohmann::ordered_json g11_blockers = nlohmann::ordered_json::array();
  if (!_foundry_coverage_attached) {
    g11_blockers.push_back("foundry_coverage_table_not_loaded");
  } else if (!_foundry_manifest.valid() || !_manifest_errors.empty()) {
    g11_blockers.push_back("foundry_coverage_table_invalid");
  } else {
    if (!_foundry_skipped.empty()) {
      g11_blockers.push_back("mapped_foundry_rules_skipped_by_selection");
    }
    if (!_foundry_partial.empty()) {
      g11_blockers.push_back("partial_foundry_rules_present");
    }
    if (!_foundry_unsupported.empty()) {
      g11_blockers.push_back("missing_foundry_rules_present");
    }
  }
  g11_blockers.push_back("calibre_alignment_not_attached");
  json["gates"]["G11"] = {{"verdict", "incomplete"}, {"blocking_reasons", std::move(g11_blockers)}};
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
  for (const auto& error : _manifest_errors) {
    if (summary.tellp() != std::streampos(0)) {
      summary << ", ";
    }
    summary << "coverage_manifest (" << error << ')';
  }
  return summary.str();
}

}  // namespace idrc
