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

#include "json/json.hpp"

namespace idrc {

struct RefusedRule
{
  std::string name;
  std::string reason;
};

class RuleCoverageReport
{
 public:
  static auto build(const std::set<std::string>& known_rules, const std::set<std::string>& loaded_rules,
                    const std::set<std::string>& requested_rules) -> RuleCoverageReport;

  auto canRun() const -> bool { return _refused.empty(); }
  auto status() const -> std::string;
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
  std::size_t _violation_count = 0;
};

}  // namespace idrc
