// ***************************************************************************************
// Copyright (c) 2023-2025 Peng Cheng Laboratory
// Copyright (c) 2023-2025 Institute of Computing Technology, Chinese Academy of Sciences
// Copyright (c) 2023-2025 Beijing Institute of Open Source Chip
//
// iEDA is licensed under Mulan PSL v2.
// ***************************************************************************************
#pragma once

#include <algorithm>
#include <cmath>
#include <cstdint>
#include <iterator>
#include <map>
#include <set>
#include <string>
#include <utility>
#include <vector>

namespace irt {

struct DRIterationState
{
  int32_t iter = 0;
  int32_t routed_net_num = 0;
  int32_t total_net_num = 0;
  int32_t violation_num = 0;
  int64_t violation_score = 0;
  double total_wire_length = 0.0;
  int32_t total_via_num = 0;
  std::map<std::string, int32_t> violation_type_count_map;
  std::set<std::string> hotspot_set;
};

struct DRConvergenceDecision
{
  bool clean = false;
  bool plateau = false;
  double completeness = 0.0;
  double violation_improvement = 0.0;
  double severity_improvement = 0.0;
  double hotspot_change = 0.0;
  double wire_length_change = 0.0;
  double via_change = 0.0;
  std::string reason = "insufficient_history";
};

struct DRConvergenceConfig
{
  int32_t window = 3;
  double min_relative_improvement = 0.02;
  double max_hotspot_change = 0.25;
};

class DRConvergenceTracker
{
 public:
  explicit DRConvergenceTracker(DRConvergenceConfig config = {}) : _config(config)
  {
    _config.window = std::max(_config.window, 2);
    _config.min_relative_improvement = std::clamp(_config.min_relative_improvement, 0.0, 1.0);
    _config.max_hotspot_change = std::clamp(_config.max_hotspot_change, 0.0, 1.0);
  }

  auto observe(DRIterationState state) -> const DRConvergenceDecision&
  {
    DRConvergenceDecision decision;
    const bool routing_complete = state.total_net_num == 0 || state.routed_net_num >= state.total_net_num;
    decision.clean = state.violation_num == 0 && routing_complete;
    decision.completeness = state.total_net_num == 0 ? 1.0 : static_cast<double>(state.routed_net_num) / state.total_net_num;
    if (decision.clean) {
      decision.reason = "drc_clean";
    } else if (state.violation_num == 0) {
      decision.reason = "routing_incomplete";
    }

    _history.push_back(std::move(state));
    if (!decision.clean && _history.size() >= static_cast<std::size_t>(_config.window)) {
      const auto& first = _history[_history.size() - _config.window];
      const auto& last = _history.back();
      decision.violation_improvement = relativeImprovement(first.violation_num, last.violation_num);
      decision.severity_improvement = relativeImprovement(first.violation_score, last.violation_score);
      decision.hotspot_change = setChange(first.hotspot_set, last.hotspot_set);
      decision.wire_length_change = relativeChange(first.total_wire_length, last.total_wire_length);
      decision.via_change = relativeChange(first.total_via_num, last.total_via_num);

      const bool completeness_improved = last.routed_net_num > first.routed_net_num;
      const bool violations_improved = decision.violation_improvement >= _config.min_relative_improvement;
      const bool severity_improved = decision.severity_improvement >= _config.min_relative_improvement;
      const bool hotspots_moved = decision.hotspot_change > _config.max_hotspot_change;
      decision.plateau = !completeness_improved && !violations_improved && !severity_improved && !hotspots_moved;
      decision.reason = decision.plateau ? (last.violation_num == 0 ? "unrouted_nets_plateau" : "stable_residual_hotspots") : "progressing";
    }
    _decisions.push_back(std::move(decision));
    return _decisions.back();
  }

  auto config() const -> const DRConvergenceConfig& { return _config; }
  auto history() const -> const std::vector<DRIterationState>& { return _history; }
  auto decisions() const -> const std::vector<DRConvergenceDecision>& { return _decisions; }

 private:
  template <typename T>
  static auto relativeImprovement(T first, T last) -> double
  {
    const double baseline = std::max(static_cast<double>(first), 1.0);
    return (static_cast<double>(first) - static_cast<double>(last)) / baseline;
  }

  template <typename T>
  static auto relativeChange(T first, T last) -> double
  {
    const double baseline = std::max(static_cast<double>(first), 1.0);
    return std::abs(static_cast<double>(last) - static_cast<double>(first)) / baseline;
  }

  static auto setChange(const std::set<std::string>& first, const std::set<std::string>& last) -> double
  {
    if (first.empty() && last.empty()) {
      return 0.0;
    }
    std::vector<std::string> symmetric_difference;
    std::set_symmetric_difference(first.begin(), first.end(), last.begin(), last.end(), std::back_inserter(symmetric_difference));
    std::vector<std::string> union_set;
    std::set_union(first.begin(), first.end(), last.begin(), last.end(), std::back_inserter(union_set));
    return union_set.empty() ? 0.0 : static_cast<double>(symmetric_difference.size()) / union_set.size();
  }

  DRConvergenceConfig _config;
  std::vector<DRIterationState> _history;
  std::vector<DRConvergenceDecision> _decisions;
};

}  // namespace irt
