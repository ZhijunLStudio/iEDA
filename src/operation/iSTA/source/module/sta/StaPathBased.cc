// ***************************************************************************************
// Copyright (c) 2023-2025 Peng Cheng Laboratory
// Copyright (c) 2023-2025 Institute of Computing Technology, Chinese Academy of Sciences
// Copyright (c) 2023-2025 Beijing Institute of Open Source Chip
//
// iEDA is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
// http://license.coscl.org.cn/MulanPSL2
//
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
//
// See the Mulan PSL v2 for more details.
// ***************************************************************************************
/**
 * @file StaPathBased.cc
 * @author Agent A1 (iSTA-PrimeTime alignment)
 * @brief Implementation of Path-Based Analysis (PBA) module.
 * @version 0.1
 * @date 2026-07-29
 */

#include "StaPathBased.hh"

#include <stack>

#include "StaCppr.hh"
#include "StaData.hh"
#include "StaPathData.hh"
#include "Sta.hh"
#include "log/Log.hh"

namespace ista {

/**
 * @brief Run PBA on top-N paths.
 *
 * Phase 1 (skeleton): Stub implementation for zero-regression testing.
 * Real implementation in Phase 2 after SPEF validation.
 */
void StaPathBased::runTopNPba(int n, AnalysisMode mode) {
  if (n == 0) {
    // PBA disabled, zero overhead
    return;
  }

  LOG_INFO << "StaPathBased::runTopNPba N=" << n
           << " mode=" << (mode == AnalysisMode::kMax ? "setup" : "hold");

  // Phase 2 TODO:
  // 1. Get top-N paths from _ista->getTopNWorstSeqPaths(n, mode)
  // 2. For each path: recomputePathArriveTime()
  // 3. Apply path CPPR
  // 4. Update path->setPbaSlack()
  // 5. Check monotonicity

  LOG_WARNING << "PBA implementation pending Phase 2 (waiting for SPEF)";
}

/**
 * @brief Recompute arrive time for a single path (stub).
 */
int64_t StaPathBased::recomputePathArriveTime(StaSeqPathData* seq_path) {
  if (!seq_path) {
    LOG_ERROR << "StaPathBased::recomputePathArriveTime: null seq_path";
    return 0;
  }

  // Phase 2 TODO:
  // 1. Extract path stack: seq_path->getPathDelayData()
  // 2. Call accumulatePathDelay()
  // 3. Return path-consistent arrive time

  // Stub: return GBA arrive time as fallback
  return seq_path->getArriveTime();
}

/**
 * @brief Generate comparison report (stub).
 */
void StaPathBased::reportGbaVsPba(const std::vector<StaSeqPathData*>& paths) {
  LOG_INFO << "StaPathBased GBA vs PBA Report";
  LOG_INFO << "Paths analyzed: " << paths.size();
  LOG_INFO << "Monotonicity violations: " << _monotonicity_violations;

  // Phase 2 TODO:
  // 1. Iterate paths, print: endpoint | gba_slack | pba_slack | delta | mono_ok
  // 2. Compute statistics: mean(|delta|), P95, R²
  // 3. Save to JSON for G7 gate processing

  LOG_WARNING << "Full report implementation pending Phase 2";
}

/**
 * @brief Accumulate path delay (stub).
 */
int64_t StaPathBased::accumulatePathDelay(
    const std::stack<StaPathDelayData*>& path_stack, AnalysisMode mode,
    TransType start_trans) {
  // Phase 2 TODO:
  // 1. Pop path stack, accumulate arc delays
  // 2. Track slew along path (path-consistent)
  // 3. Handle transition flips properly

  return 0;  // Stub
}

/**
 * @brief Compute path-specific CPPR (stub).
 */
std::optional<int> StaPathBased::computePathCppr(
    StaClockData* launch_clock_data, StaClockData* capture_clock_data) {
  if (!launch_clock_data || !capture_clock_data) {
    return std::nullopt;
  }

  // Phase 2 TODO: Reuse StaCppr logic
  // StaCppr find_cppr(launch_clock_data, capture_clock_data);
  // if (capture_clock_data->get_clock()->exec(find_cppr)) {
  //   return find_cppr.get_cppr();
  // }

  return std::nullopt;  // Stub
}

/**
 * @brief Check monotonicity: PBA should be better than GBA.
 */
bool StaPathBased::checkMonotonicity(int64_t gba_slack, int64_t pba_slack,
                                      AnalysisMode mode) {
  bool is_monotonic = false;

  if (mode == AnalysisMode::kMax) {
    // Setup: PBA slack should be >= GBA slack (less pessimistic)
    is_monotonic = (pba_slack >= gba_slack);
  } else {
    // Hold: PBA slack should be <= GBA slack (symmetric)
    is_monotonic = (pba_slack <= gba_slack);
  }

  if (!is_monotonic) {
    _monotonicity_violations++;
    LOG_WARNING << "Monotonicity violation: GBA=" << FS_TO_NS(gba_slack)
                << "ns PBA=" << FS_TO_NS(pba_slack) << "ns"
                << " mode=" << (mode == AnalysisMode::kMax ? "setup" : "hold");
  }

  return is_monotonic;
}

}  // namespace ista
