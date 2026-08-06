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
 * @file StaPathBased.hh
 * @author Agent A1 (iSTA-PrimeTime alignment)
 * @brief Path-Based Analysis (PBA) module for iSTA vs PrimeTime alignment.
 *
 * Design principle: Composition over GBA, not replacement.
 * - GBA (Graph-Based Analysis) remains as first-pass screening
 * - PBA recomputes only top-N violating paths with path-consistent slew
 * - Removes pessimism from GBA bucket merging at reconvergent fanout
 *
 * Key composability:
 * - Reuses existing propagation kernel (StaDataPropagation)
 * - Reuses CPPR logic (StaCppr)
 * - Reuses path data structures (StaSeqPathData, StaPathDelayData)
 *
 * Configuration:
 * - path_based_top_n = 0 (default): PBA disabled, zero overhead
 * - path_based_top_n > 0: PBA on top-N paths
 * - path_based_top_n < 0: Exhaustive PBA (signoff only, reserved)
 *
 * @version 0.1
 * @date 2026-07-29
 */

#pragma once

#include <optional>
#include <stack>
#include <vector>

#include "Type.hh"

namespace ista {

// Forward declarations
class Sta;
class StaSeqPathData;
class StaPathDelayData;
class StaClockData;
class StaArc;
class StaVertex;

/**
 * @brief Path-Based Analysis controller for top-N critical paths.
 *
 * Algorithm (from docs/ai/27-iSTA.md §4.3):
 * 1. Select top-N paths from GBA results (by slack)
 * 2. For each path: recompute delays with path-consistent slew propagation
 * 3. Apply path-specific CPPR
 * 4. Report dual-value slack (GBA vs PBA)
 *
 * Monotonicity contract (NFR-STA-03):
 * - Setup: slack_pba >= slack_gba
 * - Hold:  slack_pba <= slack_gba (symmetric)
 * - Violations are reported and counted
 */
class StaPathBased {
 public:
  explicit StaPathBased(Sta* ista) : _ista(ista), _top_n(0) {}
  ~StaPathBased() = default;

  // Disable copy/move (owns no resources, but avoid accidental duplication)
  StaPathBased(const StaPathBased&) = delete;
  StaPathBased& operator=(const StaPathBased&) = delete;

  /**
   * @brief Run PBA on top-N paths for the given analysis mode.
   *
   * @param n Number of paths to analyze (0=disabled, <0=exhaustive)
   * @param mode AnalysisMode::kMax (setup) or kMin (hold)
   *
   * Side effects:
   * - Stores PBA slack in each StaSeqPathData (via new field)
   * - Updates PBA statistics counters
   */
  void runTopNPba(int n, AnalysisMode mode);

  /**
   * @brief Recompute arrive time for a single sequential path.
   *
   * @param seq_path The path to analyze
   * @return Path-based arrive time in femtoseconds
   *
   * Method:
   * 1. Traverse path stack from launch to capture
   * 2. Accumulate arc delays with path-consistent slew
   * 3. Preserve transition consistency (no flip unless arc specifies)
   */
  int64_t recomputePathArriveTime(StaSeqPathData* seq_path);

  /**
   * @brief Generate GBA vs PBA comparison report.
   *
   * @param paths Paths to report
   *
   * Output columns: endpoint, gba_slack, pba_slack, delta, mono_ok
   *
   * Statistics:
   * - Mean/P95 of |delta|
   * - Monotonicity violation count
   * - R² correlation (for G7 gate)
   */
  void reportGbaVsPba(const std::vector<StaSeqPathData*>& paths);

  // Configuration
  void setTopN(int n) { _top_n = n; }
  int getTopN() const { return _top_n; }

  // Statistics (for test validation)
  unsigned getMonotonicityViolationCount() const {
    return _monotonicity_violations;
  }
  void resetStatistics() { _monotonicity_violations = 0; }

 private:
  Sta* _ista;
  int _top_n;  // 0=disabled, >0=top-N, <0=exhaustive

  // Statistics
  unsigned _monotonicity_violations = 0;

  /**
   * @brief Accumulate path delay by traversing the path stack.
   *
   * @param path_stack Stack of StaPathDelayData from getPathDelayData()
   * @param mode Analysis mode (max/min)
   * @param start_trans Starting transition type
   * @return Total path delay in femtoseconds
   *
   * Key difference from GBA:
   * - GBA: bucket merges at each vertex, loses path identity
   * - PBA: single-path traversal, preserves slew consistency
   */
  int64_t accumulatePathDelay(const std::stack<StaPathDelayData*>& path_stack,
                               AnalysisMode mode, TransType start_trans);

  /**
   * @brief Compute path-specific CPPR by reusing StaCppr.
   *
   * @param launch_clock_data Launch clock path data
   * @param capture_clock_data Capture clock path data
   * @return CPPR value in femtoseconds, or nullopt if N/A
   *
   * Composition pattern: delegates to existing StaCppr logic.
   */
  std::optional<int> computePathCppr(StaClockData* launch_clock_data,
                                      StaClockData* capture_clock_data);

  /**
   * @brief Check monotonicity and update violation counter.
   *
   * @param gba_slack GBA slack (pessimistic)
   * @param pba_slack PBA slack (should be better)
   * @param mode Analysis mode
   * @return true if monotonicity holds
   */
  bool checkMonotonicity(int64_t gba_slack, int64_t pba_slack,
                         AnalysisMode mode);
};

}  // namespace ista
