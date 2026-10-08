// ***************************************************************************************
// Copyright (c) 2023-2025 Peng Cheng Laboratory
// Copyright (c) 2023-2025 Institute of Computing Technology, Chinese Academy of Sciences
// Copyright (c) 2023-2025 Beijing Institute of Open Source Chip
//
// iEDA is licensed under Mulan PSL v2.
// ***************************************************************************************
#pragma once

#include <cstddef>
#include <set>
#include <string>
#include <vector>

#include "RuleValidatorStats.hpp"
#include "json/json.hpp"

namespace idrc {

auto getFastCheckRuleNames() -> const std::set<std::string>&;

struct RefusedRule
{
  std::string name;
  std::string reason;
};

struct FoundryRuleMapping
{
  std::string foundry_id;
  std::string state;
  std::string ieda_rule;
  std::string note;
};

class FoundryCoverageManifest
{
 public:
  static auto load(const std::string& path, const std::set<std::string>& known_engine_rules) -> FoundryCoverageManifest;

  auto valid() const -> bool { return _errors.empty(); }
  auto toJson() const -> nlohmann::ordered_json;

  auto getSourcePath() const -> const std::string& { return _source_path; }
  auto getPdk() const -> const std::string& { return _pdk; }
  auto getDeckId() const -> const std::string& { return _deck_id; }
  auto getDeckSha256() const -> const std::string& { return _deck_sha256; }
  auto getRules() const -> const std::vector<FoundryRuleMapping>& { return _rules; }
  auto getErrors() const -> const std::vector<std::string>& { return _errors; }

 private:
  std::string _source_path;
  std::string _pdk;
  std::string _deck_id;
  std::string _deck_sha256;
  std::vector<FoundryRuleMapping> _rules;
  std::vector<std::string> _errors;
};

class RuleCoverageReport
{
 public:
  static auto build(const std::set<std::string>& known_rules, const std::set<std::string>& loaded_rules,
                    const std::set<std::string>& requested_rules) -> RuleCoverageReport;

  void attachFoundryCoverage(const FoundryCoverageManifest& manifest, const std::set<std::string>& loaded_rules);
  void attachRunStats(const RuleValidatorRunStats& stats) { _run_stats = stats; _run_stats_attached = true; }

  auto canRun() const -> bool { return _refused.empty() && _manifest_errors.empty(); }
  auto status() const -> std::string;
  auto profile() const -> std::string;
  auto toJson() const -> nlohmann::ordered_json;
  auto refusalSummary() const -> std::string;

  void setViolationCount(std::size_t violation_count) { _violation_count = violation_count; }

  auto getRequested() const -> const std::set<std::string>& { return _requested; }
  auto getChecked() const -> const std::set<std::string>& { return _checked; }
  auto getSkipped() const -> const std::set<std::string>& { return _skipped; }
  auto getUnsupported() const -> const std::set<std::string>& { return _unsupported; }
  auto getRefused() const -> const std::vector<RefusedRule>& { return _refused; }
  auto getViolationCount() const -> std::size_t { return _violation_count; }

 private:
  std::set<std::string> _requested;
  std::set<std::string> _checked;
  std::set<std::string> _skipped;
  std::set<std::string> _unsupported;
  std::vector<RefusedRule> _refused;
  bool _foundry_coverage_attached = false;
  FoundryCoverageManifest _foundry_manifest;
  std::set<std::string> _foundry_checked;
  std::set<std::string> _foundry_skipped;
  std::set<std::string> _foundry_partial;
  std::set<std::string> _foundry_unsupported;
  std::vector<std::string> _manifest_errors;
  std::size_t _violation_count = 0;
  RuleValidatorRunStats _run_stats;
  bool _run_stats_attached = false;
};

}  // namespace idrc
