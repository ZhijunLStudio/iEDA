// ***************************************************************************************
// Copyright (c) 2023-2025 Peng Cheng Laboratory
// Copyright (c) 2023-2025 Institute of Computing Technology, Chinese Academy of Sciences
// Copyright (c) 2023-2025 Beijing Institute of Open Source Chip
//
// iEDA is licensed under Mulan PSL v2.
// ***************************************************************************************
#include "ViolationArtifact.hpp"

#include <algorithm>
#include <cstdint>
#include <map>
#include <optional>
#include <set>
#include <sstream>
#include <utility>

namespace idrc {
namespace {

auto netNames(const ids::Violation& violation, const CanonicalViolationContext& context) -> std::vector<std::string>
{
  std::vector<std::string> names;
  names.reserve(violation.violation_net_set.size());
  for (int32_t net_idx : violation.violation_net_set) {
    if (auto regular = context.regular_net_names.find(net_idx); regular != context.regular_net_names.end()) {
      names.push_back(regular->second);
      continue;
    }
    if (auto special = context.special_net_names.find(net_idx); special != context.special_net_names.end()) {
      names.push_back(special->second);
      continue;
    }
    names.push_back(net_idx < 0 ? "obs" : ("net#" + std::to_string(net_idx)));
  }
  std::sort(names.begin(), names.end());
  names.erase(std::unique(names.begin(), names.end()), names.end());
  return names;
}

auto canonicalLayerIdx(const ids::Violation& violation, const CanonicalViolationContext& context) -> int32_t
{
  if (violation.is_routing) {
    return violation.layer_idx;
  }
  auto adjacent_iter = context.cut_to_adjacent_routing_map.find(violation.layer_idx);
  if (adjacent_iter == context.cut_to_adjacent_routing_map.end() || adjacent_iter->second.empty()) {
    return violation.layer_idx;
  }
  return *std::min_element(adjacent_iter->second.begin(), adjacent_iter->second.end());
}

auto layerName(const ids::Violation& violation, const CanonicalViolationContext& context) -> std::string
{
  if (violation.is_routing) {
    if (violation.layer_idx >= 0 && violation.layer_idx < static_cast<int32_t>(context.routing_layer_names.size())) {
      return context.routing_layer_names[violation.layer_idx];
    }
    return "unknown";
  }
  if (violation.layer_idx >= 0 && violation.layer_idx < static_cast<int32_t>(context.cut_layer_names.size())) {
    return context.cut_layer_names[violation.layer_idx];
  }
  return "unknown";
}

auto routingLayerName(const ids::Violation& violation, const CanonicalViolationContext& context) -> std::string
{
  const int32_t layer_idx = canonicalLayerIdx(violation, context);
  if (layer_idx >= 0 && layer_idx < static_cast<int32_t>(context.routing_layer_names.size())) {
    return context.routing_layer_names[layer_idx];
  }
  return layerName(violation, context);
}

auto severity(const std::string& type) -> int32_t
{
  if (type == "metal_short" || type == "cut_short") {
    return 4;
  }
  if (type == "parallel_run_length_spacing" || type == "minimum_width" || type == "minimum_area" || type == "end_of_line_spacing"
      || type == "same_layer_cut_spacing" || type == "different_layer_cut_spacing") {
    return 3;
  }
  if (type == "nonsufficient_metal_overlap" || type == "enclosure" || type == "enclosure_edge" || type == "enclosure_parallel") {
    return 2;
  }
  return 1;
}

auto repairable(const std::string& type) -> bool
{
  static const std::set<std::string> kRepairable = {"metal_short",
                                                    "cut_short",
                                                    "parallel_run_length_spacing",
                                                    "minimum_width",
                                                    "minimum_area",
                                                    "same_layer_cut_spacing",
                                                    "different_layer_cut_spacing",
                                                    "nonsufficient_metal_overlap",
                                                    "enclosure",
                                                    "enclosure_edge",
                                                    "enclosure_parallel"};
  return kRepairable.contains(type);
}

auto repairAction(const std::string& type) -> std::string
{
  if (type.find("short") != std::string::npos) {
    return "reroute_or_isolate";
  }
  if (type.find("spacing") != std::string::npos) {
    return "increase_spacing_or_reroute";
  }
  if (type.find("width") != std::string::npos) {
    return "adjust_width";
  }
  if (type.find("area") != std::string::npos) {
    return "add_patch_or_resize";
  }
  if (type.find("enclosure") != std::string::npos || type.find("overlap") != std::string::npos) {
    return "adjust_via_or_metal_anchor";
  }
  return "manual_review";
}

auto shapeId(const ids::Violation& violation, const std::string& layer_name, const std::string& type) -> std::string
{
  std::ostringstream oss;
  oss << "shape|" << type << '|' << layer_name << '|' << violation.ll_x << ',' << violation.ll_y << ',' << violation.ur_x << ','
      << violation.ur_y << '|' << (violation.is_routing ? "routing" : "cut");
  return oss.str();
}

auto canonicalKey(const ids::Violation& violation, const CanonicalViolationContext& context) -> std::string
{
  const auto nets = netNames(violation, context);
  std::ostringstream oss;
  oss << violation.violation_type << '|' << (violation.is_routing ? "routing" : "cut") << '|' << canonicalLayerIdx(violation, context) << '|'
      << routingLayerName(violation, context) << '|' << violation.ll_x << ',' << violation.ll_y << ',' << violation.ur_x << ',' << violation.ur_y
      << '|' << violation.required_size << '|';
  for (const auto& net : nets) {
    oss << net << ',';
  }
  return oss.str();
}

auto toStringArray(const std::vector<std::string>& values) -> nlohmann::ordered_json
{
  nlohmann::ordered_json json = nlohmann::ordered_json::array();
  for (const auto& value : values) {
    json.push_back(value);
  }
  return json;
}

auto toStringArray(const std::set<std::string>& values) -> nlohmann::ordered_json
{
  nlohmann::ordered_json json = nlohmann::ordered_json::array();
  for (const auto& value : values) {
    json.push_back(value);
  }
  return json;
}

auto intArray(std::initializer_list<int32_t> values) -> nlohmann::ordered_json
{
  nlohmann::ordered_json json = nlohmann::ordered_json::array();
  for (int32_t value : values) {
    json.push_back(value);
  }
  return json;
}

auto stringValue(const nlohmann::json& json, const char* key) -> std::string
{
  if (!json.contains(key) || !json.at(key).is_string()) {
    return {};
  }
  return json.at(key).get<std::string>();
}

auto integerValue(const nlohmann::json& json, const char* key) -> std::optional<int64_t>
{
  if (!json.contains(key) || !json.at(key).is_number_integer()) {
    return std::nullopt;
  }
  return json.at(key).get<int64_t>();
}

auto boolValue(const nlohmann::json& json, const char* key, bool default_value = false) -> bool
{
  return json.contains(key) && json.at(key).is_boolean() ? json.at(key).get<bool>() : default_value;
}

auto violationList(const nlohmann::json& artifact) -> const nlohmann::json*
{
  if (artifact.is_array()) {
    return &artifact;
  }
  if (artifact.is_object() && artifact.contains("violations") && artifact.at("violations").is_array()) {
    return &artifact.at("violations");
  }
  return nullptr;
}

auto canonicalKeyFromJson(const nlohmann::json& item) -> std::string
{
  std::ostringstream oss;
  oss << stringValue(item, "type") << '|';
  if (item.contains("is_routing") && item.at("is_routing").is_boolean()) {
    oss << (item.at("is_routing").get<bool>() ? "routing" : "cut");
  } else {
    oss << "unknown";
  }
  oss << '|';
  if (item.contains("layer_idx") && item.at("layer_idx").is_number_integer()) {
    oss << item.at("layer_idx").get<int64_t>();
  }
  oss << '|' << stringValue(item, "layer") << '|';
  if (item.contains("bbox") && item.at("bbox").is_array()) {
    for (const auto& value : item.at("bbox")) {
      if (value.is_number_integer()) {
        oss << value.get<int64_t>();
      }
      oss << ',';
    }
  }
  oss << '|';
  if (item.contains("required_size") && item.at("required_size").is_number_integer()) {
    oss << item.at("required_size").get<int64_t>();
  }
  oss << '|';
  std::vector<std::string> nets;
  if (item.contains("net") && item.at("net").is_array()) {
    for (const auto& net : item.at("net")) {
      if (net.is_string()) {
        nets.push_back(net.get<std::string>());
      }
    }
  }
  std::sort(nets.begin(), nets.end());
  for (const auto& net : nets) {
    oss << net << ',';
  }
  return oss.str();
}

auto indexByCanonicalKey(const nlohmann::json& artifact) -> std::map<std::string, nlohmann::json>
{
  std::map<std::string, nlohmann::json> indexed;
  if (const nlohmann::json* list = violationList(artifact); list != nullptr) {
    for (const auto& item : *list) {
      if (item.is_object()) {
        indexed[canonicalKeyFromJson(item)] = item;
      }
    }
  }
  return indexed;
}

auto unsupportedKeySet(const nlohmann::json& artifact) -> std::set<std::string>
{
  std::set<std::string> unsupported;
  if (const nlohmann::json* list = violationList(artifact); list != nullptr) {
    for (const auto& item : *list) {
      if (item.is_object() && boolValue(item, "unsupported")) {
        unsupported.insert(canonicalKeyFromJson(item));
      }
    }
  }
  return unsupported;
}

auto makeContext(const nlohmann::json& artifact) -> nlohmann::ordered_json
{
  nlohmann::ordered_json context;
  if (!artifact.is_object()) {
    return context;
  }
  if (artifact.contains("context") && artifact.at("context").is_object()) {
    const auto& artifact_context = artifact.at("context");
    context["gds_sha256"] = stringValue(artifact_context, "gds_sha256");
    context["def_sha256"] = stringValue(artifact_context, "def_sha256");
    context["tech_sha256"] = stringValue(artifact_context, "tech_sha256");
    context["deck_sha256"] = stringValue(artifact_context, "deck_sha256");
  } else if (artifact.contains("hashes") && artifact.at("hashes").is_object()) {
    const auto& hashes = artifact.at("hashes");
    context["gds_sha256"] = stringValue(hashes, "gds_sha256");
    context["def_sha256"] = stringValue(hashes, "def_sha256");
    context["tech_sha256"] = stringValue(hashes, "tech_sha256");
    context["deck_sha256"] = stringValue(hashes, "deck_sha256");
  }
  return context;
}

auto contextMatches(const nlohmann::ordered_json& left, const nlohmann::ordered_json& right) -> bool
{
  for (const char* key : {"gds_sha256", "def_sha256", "tech_sha256", "deck_sha256"}) {
    const std::string left_value = left.value(key, "");
    const std::string right_value = right.value(key, "");
    if (!left_value.empty() && !right_value.empty() && left_value != right_value) {
      return false;
    }
  }
  return true;
}

auto keyArray(const std::set<std::string>& keys) -> nlohmann::ordered_json
{
  nlohmann::ordered_json json = nlohmann::ordered_json::array();
  for (const auto& key : keys) {
    json.push_back(key);
  }
  return json;
}

}  // namespace

auto canonicalizeViolations(const std::map<std::string, std::vector<ids::Violation>>& type_violation_map,
                            const CanonicalViolationContext& context) -> std::vector<nlohmann::ordered_json>
{
  std::map<std::string, nlohmann::ordered_json> deduped;
  for (const auto& [type, violation_list] : type_violation_map) {
    for (const ids::Violation& violation : violation_list) {
      ids::Violation normalized = violation;
      if (normalized.violation_type.empty()) {
        normalized.violation_type = type;
      }
      const std::string presentation_layer = layerName(normalized, context);
      const std::string routing_layer = routingLayerName(normalized, context);
      const auto nets = netNames(normalized, context);
      const std::string key = canonicalKey(normalized, context);
      const std::string item_type = normalized.violation_type.empty() ? "unknown" : normalized.violation_type;
      const std::string shape_id = shapeId(normalized, routing_layer, item_type);

      nlohmann::ordered_json item;
      item["id"] = key;
      item["type"] = item_type;
      item["layer_idx"] = canonicalLayerIdx(normalized, context);
      item["layer"] = routing_layer;
      item["source_layer"] = presentation_layer;
      item["bbox"] = intArray({normalized.ll_x, normalized.ll_y, normalized.ur_x, normalized.ur_y});
      item["shape"] = nlohmann::ordered_json::array({normalized.ll_x, normalized.ll_y, normalized.ur_x, normalized.ur_y, routing_layer});
      item["shape_id"] = shape_id;
      item["shape_ids"] = nlohmann::ordered_json::array({shape_id});
      item["net"] = toStringArray(nets);
      item["net_ids"] = item["net"];
      item["stage"] = context.stage;
      item["source"] = context.source;
      item["severity"] = severity(item_type);
      item["repairable"] = repairable(item_type);
      item["repair_hint"] = {{"owner", "platform_route_eco"},
                             {"action", repairAction(item_type)},
                             {"mutates_db", false},
                             {"reason", item["repairable"].get<bool>() ? "route_eco_candidate" : "diagnostic_only"}};
      item["required_size"] = normalized.required_size;
      item["is_routing"] = normalized.is_routing;
      item["units"] = {{"coordinates", "DBU"}, {"dbu_per_micron", context.dbu_per_micron}};
      item["canonical_key"] = key;
      deduped[key] = std::move(item);
    }
  }

  std::vector<nlohmann::ordered_json> result;
  result.reserve(deduped.size());
  for (auto& [key, item] : deduped) {
    result.push_back(std::move(item));
  }
  return result;
}

auto buildViolationsArtifact(const std::map<std::string, std::vector<ids::Violation>>& type_violation_map,
                             const CanonicalViolationContext& context, const RuleCoverageReport& coverage) -> nlohmann::ordered_json
{
  const auto canonical_violations = canonicalizeViolations(type_violation_map, context);
  nlohmann::ordered_json violations = nlohmann::ordered_json::array();
  nlohmann::ordered_json by_type = nlohmann::ordered_json::object();
  nlohmann::ordered_json by_layer = nlohmann::ordered_json::object();
  for (const auto& item : canonical_violations) {
    const std::string type = item.at("type").get<std::string>();
    const std::string layer = item.at("layer").get<std::string>();
    by_type[type] = by_type.value(type, 0) + 1;
    by_layer[layer] = by_layer.value(layer, 0) + 1;
    violations.push_back(item);
  }

  nlohmann::ordered_json artifact;
  artifact["schema_version"] = "ieda.drc.violations.v1";
  artifact["artifact"] = context.artifact;
  artifact["tool"] = context.tool;
  artifact["status"] = coverage.status();
  artifact["source"] = context.source;
  artifact["stage"] = context.stage;
  artifact["count"] = violations.size();
  artifact["coordinate_units"] = "DBU";
  artifact["dbu_per_micron"] = context.dbu_per_micron;
  artifact["coverage"] = {{"schema_version", "ieda.drc.coverage.v1"},
                          {"status", coverage.status()},
                          {"check_profile", coverage.profile()},
                          {"checked", toStringArray(coverage.getChecked())},
                          {"skipped", toStringArray(coverage.getSkipped())},
                          {"unsupported", toStringArray(coverage.getUnsupported())},
                          {"signoff_clean", false}};
  artifact["provenance"] = {{"design_name", context.design_name},
                            {"def_file_path", context.def_file_path},
                            {"temp_directory_path", context.temp_directory_path},
                            {"rule_deck_hash", context.rule_deck_hash}};
  artifact["hashes"] = {{"deck_sha256", context.rule_deck_hash}, {"rule_deck_hash", context.rule_deck_hash}};
  artifact["summary"] = {{"total", violations.size()}, {"by_type", std::move(by_type)}, {"by_layer", std::move(by_layer)}};
  artifact["violations"] = std::move(violations);
  return artifact;
}

auto buildCVioArtifact(const nlohmann::ordered_json& violations_artifact, const RuleCoverageReport& coverage) -> nlohmann::ordered_json
{
  nlohmann::ordered_json root;
  root["schema"] = "c-vio/v1";
  root["schema_version"] = "ieda.c-vio.v1";
  root["design"] = violations_artifact.at("provenance").value("design_name", "");
  root["rule_deck_hash"] = violations_artifact.at("provenance").value("rule_deck_hash", "unknown");
  root["source"] = violations_artifact.value("source", "idrc_in_design");
  root["status"] = coverage.status();
  root["check_profile"] = coverage.profile();
  root["coordinate_units"] = violations_artifact.value("coordinate_units", "DBU");
  root["dbu_per_micron"] = violations_artifact.value("dbu_per_micron", -1);
  root["summary"] = violations_artifact.at("summary");
  root["coverage"] = violations_artifact.at("coverage");
  root["violations"] = violations_artifact.at("violations");
  return root;
}

auto validateViolationsArtifact(const nlohmann::json& artifact, std::string* reason) -> bool
{
  auto fail = [reason](const std::string& message) {
    if (reason != nullptr) {
      *reason = message;
    }
    return false;
  };
  if (!artifact.is_object()) {
    return fail("artifact root is not an object");
  }
  const std::string schema_string = stringValue(artifact, "schema_version");
  const std::optional<int64_t> schema_integer = integerValue(artifact, "schema_version");
  if (schema_string != "ieda.drc.violations.v1" && schema_integer.value_or(-1) != 1) {
    return fail("unsupported violation artifact schema");
  }
  if (!artifact.contains("violations") || !artifact.at("violations").is_array()) {
    return fail("violations array is missing");
  }
  std::set<std::string> seen_keys;
  std::string previous_key;
  for (std::size_t index = 0; index < artifact.at("violations").size(); ++index) {
    const auto& item = artifact.at("violations").at(index);
    if (!item.is_object()) {
      return fail("violation item is not an object");
    }
    for (const char* key : {"id", "type", "layer", "source", "stage"}) {
      if (!item.contains(key) || !item.at(key).is_string() || item.at(key).get<std::string>().empty()) {
        return fail(std::string("violation item missing string field: ") + key);
      }
    }
    if (!item.contains("bbox") || !item.at("bbox").is_array() || item.at("bbox").size() != 4) {
      return fail("violation bbox must be a four-element array");
    }
    for (const auto& value : item.at("bbox")) {
      if (!value.is_number_integer()) {
        return fail("violation bbox coordinate is not an integer DBU");
      }
    }
    if (!item.contains("net") || !item.at("net").is_array()) {
      return fail("violation net array is missing");
    }
    if (!item.contains("shape_ids") || !item.at("shape_ids").is_array() || item.at("shape_ids").empty()) {
      return fail("violation shape_ids are missing");
    }
    if (!item.contains("shape_id") || !item.at("shape_id").is_string() || item.at("shape_id").get<std::string>().empty()) {
      return fail("violation shape_id is missing");
    }
    if (!item.contains("severity") || !item.at("severity").is_number()) {
      return fail("violation severity is missing");
    }
    if (!item.contains("repair_hint") || !item.at("repair_hint").is_object() || item.at("repair_hint").value("mutates_db", true)) {
      return fail("violation repair_hint must be non-mutating");
    }
    const std::string canonical_key = item.value("canonical_key", canonicalKeyFromJson(item));
    if (!seen_keys.insert(canonical_key).second) {
      return fail("duplicate canonical violation key");
    }
    if (!previous_key.empty() && canonical_key < previous_key) {
      return fail("violations are not in stable canonical order");
    }
    previous_key = canonical_key;
  }
  if (artifact.contains("count") && artifact.at("count").is_number_integer()
      && artifact.at("count").get<int64_t>() != static_cast<int64_t>(artifact.at("violations").size())) {
    return fail("count does not match violations array size");
  }
  if (reason != nullptr) {
    reason->clear();
  }
  return true;
}

auto compareCalibreArtifacts(const nlohmann::json& idrc_artifact, const nlohmann::json& calibre_artifact, const CalibreCompareOptions& options)
    -> CalibreCompareResult
{
  const auto idrc_context = makeContext(idrc_artifact);
  const auto calibre_context = makeContext(calibre_artifact);
  const bool context_match = contextMatches(idrc_context, calibre_context);
  const auto idrc = indexByCanonicalKey(idrc_artifact);
  const auto calibre = indexByCanonicalKey(calibre_artifact);
  const auto unsupported = unsupportedKeySet(calibre_artifact);

  std::set<std::string> true_positive;
  std::set<std::string> false_positive;
  std::set<std::string> false_negative;
  std::set<std::string> unsupported_matched;
  for (const auto& [key, item] : idrc) {
    if (unsupported.contains(key)) {
      unsupported_matched.insert(key);
      continue;
    }
    if (calibre.contains(key)) {
      true_positive.insert(key);
    } else {
      false_positive.insert(key);
    }
  }
  for (const auto& [key, item] : calibre) {
    if (unsupported.contains(key)) {
      continue;
    }
    if (!idrc.contains(key)) {
      false_negative.insert(key);
    }
  }

  const double precision = true_positive.empty() && false_positive.empty()
                               ? 1.0
                               : static_cast<double>(true_positive.size()) / static_cast<double>(true_positive.size() + false_positive.size());
  const double recall = true_positive.empty() && false_negative.empty()
                            ? 1.0
                            : static_cast<double>(true_positive.size()) / static_cast<double>(true_positive.size() + false_negative.size());
  const double f1 = (precision + recall) == 0.0 ? 0.0 : (2.0 * precision * recall) / (precision + recall);

  nlohmann::ordered_json report;
  report["schema_version"] = "ieda.drc.calibre_compare.v1";
  report["context_match"] = context_match;
  report["context"] = {{"idrc", idrc_context}, {"calibre", calibre_context}};
  report["buckets"] = {{"true_positive", keyArray(true_positive)},
                       {"false_positive", keyArray(false_positive)},
                       {"false_negative", keyArray(false_negative)},
                       {"unsupported", keyArray(unsupported)},
                       {"unsupported_matched_by_idrc", keyArray(unsupported_matched)}};
  report["counts"] = {{"true_positive", true_positive.size()},
                      {"false_positive", false_positive.size()},
                      {"false_negative", false_negative.size()},
                      {"unsupported", unsupported.size()}};
  report["metrics"] = {{"precision", precision}, {"recall", recall}, {"f1", f1}};
  report["policy"] = {{"require_context_match", options.require_context_match},
                      {"fail_on_false_negative", options.fail_on_false_negative},
                      {"fail_on_false_positive", options.fail_on_false_positive},
                      {"fail_on_unsupported", options.fail_on_unsupported}};

  bool pass = true;
  if (options.require_context_match && !context_match) {
    pass = false;
  }
  if (options.fail_on_false_negative && !false_negative.empty()) {
    pass = false;
  }
  if (options.fail_on_false_positive && !false_positive.empty()) {
    pass = false;
  }
  if (options.fail_on_unsupported && !unsupported.empty()) {
    pass = false;
  }
  report["pass"] = pass;
  return {std::move(report), pass};
}

}  // namespace idrc
