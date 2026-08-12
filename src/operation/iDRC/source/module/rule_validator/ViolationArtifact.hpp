// ***************************************************************************************
// Copyright (c) 2023-2025 Peng Cheng Laboratory
// Copyright (c) 2023-2025 Institute of Computing Technology, Chinese Academy of Sciences
// Copyright (c) 2023-2025 Beijing Institute of Open Source Chip
//
// iEDA is licensed under Mulan PSL v2.
// ***************************************************************************************
#pragma once

#include <cstdint>
#include <map>
#include <set>
#include <string>
#include <vector>

#include "RuleCoverage.hpp"
#include "ids.hpp"
#include "json/json.hpp"

namespace idrc {

struct CanonicalViolationContext
{
  std::string tool = "iDRC";
  std::string artifact = "violations";
  std::string source = "idrc_in_design";
  std::string stage = "DRC";
  std::string design_name;
  std::string def_file_path;
  std::string temp_directory_path;
  std::string rule_deck_hash = "unknown";
  int32_t dbu_per_micron = -1;
  std::vector<std::string> routing_layer_names;
  std::vector<std::string> cut_layer_names;
  std::map<int32_t, std::vector<int32_t>> cut_to_adjacent_routing_map;
  std::map<int32_t, std::string> regular_net_names;
  std::map<int32_t, std::string> special_net_names;
};

struct CalibreCompareOptions
{
  bool require_context_match = true;
  bool fail_on_false_negative = true;
  bool fail_on_false_positive = false;
  bool fail_on_unsupported = false;
};

struct CalibreCompareResult
{
  nlohmann::ordered_json report;
  bool pass = false;
};

auto canonicalizeViolations(const std::map<std::string, std::vector<ids::Violation>>& type_violation_map,
                            const CanonicalViolationContext& context) -> std::vector<nlohmann::ordered_json>;
auto buildViolationsArtifact(const std::map<std::string, std::vector<ids::Violation>>& type_violation_map,
                             const CanonicalViolationContext& context, const RuleCoverageReport& coverage) -> nlohmann::ordered_json;
auto buildCVioArtifact(const nlohmann::ordered_json& violations_artifact, const RuleCoverageReport& coverage) -> nlohmann::ordered_json;
auto validateViolationsArtifact(const nlohmann::json& artifact, std::string* reason = nullptr) -> bool;
auto compareCalibreArtifacts(const nlohmann::json& idrc_artifact, const nlohmann::json& calibre_artifact,
                             const CalibreCompareOptions& options = {}) -> CalibreCompareResult;

}  // namespace idrc
