// ***************************************************************************************
// Copyright (c) 2023-2025 Peng Cheng Laboratory
// Copyright (c) 2023-2025 Institute of Computing Technology, Chinese Academy of Sciences
// Copyright (c) 2023-2025 Beijing Institute of Open Source Chip
//
// iEDA is licensed under Mulan PSL v2.
// ***************************************************************************************
#pragma once

#include <algorithm>
#include <cstdint>

#include "ViolationType.hpp"

namespace irt {

/**
 * WP-RT-01 rule-aware DRC cost helpers.
 *
 * Performance contract:
 * - All helpers are O(1), no heap allocation, safe on A* hot path.
 * - When disabled, weights collapse to 1 and callers keep binary violation cost.
 *
 * Quality contract:
 * - New lever defaults OFF → zero regression vs prior PathFinder cost.
 */
struct DRRuleAwareCostConfig
{
  bool enabled = false;
  // Cap history scale on a node edge to bound A* cost explosion / wall-clock.
  int32_t max_history_scale = 8;
  // Extra min-area patch candidates when enhanced repair is on.
  int32_t minarea_candidate_boost = 10;
};

inline auto ruleAwareWeight(ViolationType violation_type, bool enabled) -> int32_t
{
  if (!enabled) {
    return 1;
  }
  switch (violation_type) {
    case ViolationType::kMetalShort:
      return 4;  // nangate45 top residual
    case ViolationType::kParallelRunLengthSpacing:
      return 3;  // sky130 top residual
    case ViolationType::kMinimumArea:
      return 3;  // asap7 / ics55 top residual
    case ViolationType::kNotchSpacing:
    case ViolationType::kEndOfLineSpacing:
    case ViolationType::kCornerSpacing:
    case ViolationType::kJogToJogSpacing:
      return 2;
    default:
      return 1;
  }
}

inline auto cappedHistoryScale(int32_t violation_number, int32_t max_history_scale) -> int32_t
{
  if (violation_number <= 0) {
    return 0;
  }
  return std::min(violation_number, std::max(1, max_history_scale));
}

inline auto ruleAwareViolationCost(int32_t violation_number, double violation_unit, const DRRuleAwareCostConfig& config) -> double
{
  if (violation_number <= 0) {
    return 0.0;
  }
  if (!config.enabled) {
    // Legacy PathFinder path: presence only (binary), not count.
    return violation_unit;
  }
  return violation_unit * static_cast<double>(cappedHistoryScale(violation_number, config.max_history_scale));
}

inline auto enhancedMinAreaCandidateBudget(int32_t base_budget, bool enhanced, int32_t boost) -> int32_t
{
  if (!enhanced || base_budget <= 0) {
    return base_budget;
  }
  return std::max(base_budget * 2, base_budget + std::max(0, boost));
}

}  // namespace irt
