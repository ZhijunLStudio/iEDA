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

#ifndef IPL_API_GP_CONTRACT_H
#define IPL_API_GP_CONTRACT_H

#include <cstdint>
#include <string>
#include <vector>

namespace ipl {

enum class GPRunMode
{
  kStart,    // build a new session from the current design (random_init controls the initial layout)
  kAdvance,  // advance the active session by accepted_iterations
  kResume,   // rebuild a session from a persisted checkpoint, then advance
};

enum class GPStopReason
{
  kNotRun,
  kBudgetReached,      // requested iterations consumed, session still ready
  kTargetReached,      // natural convergence
  kMaxIter,            // solver reached its configured iteration limit
  kOverflowTargetMiss, // stopped before reaching target overflow
  kDiverged,
  kInvalidMetric,
  kRejected,  // request rejected (invalid mode/ref combination); solver state untouched
};

inline const char* gpStopReasonName(GPStopReason reason)
{
  switch (reason) {
    case GPStopReason::kBudgetReached:
      return "budget_reached";
    case GPStopReason::kTargetReached:
      return "target_reached";
    case GPStopReason::kMaxIter:
      return "max_iter";
    case GPStopReason::kOverflowTargetMiss:
      return "overflow_target_miss";
    case GPStopReason::kDiverged:
      return "diverged";
    case GPStopReason::kInvalidMetric:
      return "invalid_metric";
    case GPStopReason::kRejected:
      return "rejected";
    case GPStopReason::kNotRun:
      break;
  }
  return "not_run";
}

// How the Active/Halo/Context movement mask is constructed for this batch.
// A local scope is a per-run action, not persistent session state: the next
// batch defaults back to kGlobal unless the caller asks for local again.
enum class GPRunScopeMode
{
  kGlobal,     // all movable instances active (default; bit-identical legacy path)
  kHotspot,    // hottest overflowing bins seed Active, net-hop neighbors become Halo
  kRandom,     // random Active set of scope_active_count instances (ablation/candidate control)
  kInstances,  // caller-specified seed instances, net-hop neighbors become Halo
};

inline const char* gpScopeModeName(GPRunScopeMode mode)
{
  switch (mode) {
    case GPRunScopeMode::kGlobal:
      return "global";
    case GPRunScopeMode::kHotspot:
      return "hotspot";
    case GPRunScopeMode::kRandom:
      return "random";
    case GPRunScopeMode::kInstances:
      return "instances";
  }
  return "unknown";
}

// API-level mirror of the solver's per-iteration record, so the api layer does
// not depend on module-internal headers. Populated from NesterovIterationRecord.
struct GPIterationRecord
{
  int32_t iter = 0;
  int64_t hpwl = 0;
  float overflow = 0.0F;
  float step_length = 0.0F;
  float gradient_norm = 0.0F;
  float density_penalty = 0.0F;
  float route_util = 0.0F;
  bool quad_penalty_enabled = false;
  bool entropy_injected = false;
};

// Per-batch movement-mask accounting. The solver verifies that every context
// instance (coefficient 0) stayed bitwise at its batch-start coordinate, so
// context_moved == 0 is a hard safety invariant.
struct GPRunScopeEffect
{
  bool scope_applied = false;
  bool in_scope = true;
  int64_t active_written = 0;
  int64_t halo_written = 0;
  int64_t context_written = 0;
  int64_t context_moved = 0;
  float max_displacement = 0.0F;  // max L1 displacement of any movable instance in this batch
};

struct GPBinReport
{
  int32_t row = 0;
  int32_t col = 0;
  int32_t ll_x = 0;
  int32_t ll_y = 0;
  int32_t ur_x = 0;
  int32_t ur_y = 0;
  int64_t grid_area = 0;
  int64_t occupied_area = 0;
  int64_t fixed_area = 0;
  int64_t available_area = 0;
  int64_t overflow_area = 0;
  float density = 0.0F;
  float density_target = 1.0F;
};

// Bin-level overflow observation exported after every session batch. The report
// is produced by reading the solver's already-computed grid state; it does not
// refresh the grid and therefore cannot perturb the numerical path.
struct GPOverflowReport
{
  int32_t bin_cnt_x = 0;
  int32_t bin_cnt_y = 0;
  int32_t bin_size_x = 0;
  int32_t bin_size_y = 0;
  int32_t core_ll_x = 0;
  int32_t core_ll_y = 0;
  int32_t core_ur_x = 0;
  int32_t core_ur_y = 0;
  int32_t overflowing_bin_count = 0;
  int64_t total_overflow_area = 0;
  float total_overflow_ratio = 0.0F;  // overflow area / total movable instance area
  float peak_density = 0.0F;
  std::vector<GPBinReport> bins;  // top-N overflowing bins, sorted by overflow desc
};

struct GPRunRequest
{
  GPRunMode mode = GPRunMode::kStart;
  int32_t accepted_iterations = 20;
  bool random_init = true;          // kStart only: run RandomPlace before building the session
  int32_t seed = 1000;              // kStart only: RandomPlace seed (default preserves legacy determinism)
  // kStart only: density target override, the agent-facing knob trading
  // wirelength/timing (loose) against density/congestion (tight). Negative =
  // keep the placer config value. Valid range (0,1). Changing it mid-session
  // is not allowed: restart with random_init=false (relinearize) instead.
  float target_density = -1.0F;
  std::string checkpoint_path;      // kResume only: checkpoint JSON to restore from

  // Per-batch movement scope (all modes). kGlobal is the default and is
  // bit-identical to the pre-scope path.
  GPRunScopeMode scope_mode = GPRunScopeMode::kGlobal;
  float scope_active_ratio = 0.2F;   // kHotspot: fraction of overflowing bins that seed Active
  int32_t scope_active_count = 0;    // kRandom: number of random Active instances
  float scope_halo_coeff = 0.5F;     // (0,1) movement scale for one-net-hop neighbors
  uint32_t scope_seed = 1000;        // kRandom: reproducible Active-set shuffle seed
  std::vector<std::string> scope_instance_names;  // kInstances: seed instance names

  // Observation: max overflowing bins returned in GPRunResult.grid_report.
  // The full top-N report is also written to <output>/pl/gp_grid_report.json.
  int32_t grid_report_top_n = 64;

  // kStart-only cautious solver overrides (-1 = keep the configured value).
  // These are effective configuration, not mid-session mutation; they are
  // captured in the checkpoint and restored by kResume automatically.
  float init_density_penalty = -1.0F;
  float min_phi_coef = -1.0F;
  float max_phi_coef = -1.0F;
};

struct GPRunResult
{
  bool ok = false;
  bool session_active = false;
  GPStopReason stop_reason = GPStopReason::kNotRun;
  int32_t start_iteration = 0;  // first iteration executed in this batch (1-based)
  int32_t end_iteration = 0;    // last iteration executed in this batch
  int32_t requested_iterations = 0;
  int32_t executed_iterations = 0;
  int64_t hpwl = 0;
  float overflow = 0.0F;
  float step_length = 0.0F;
  float density_penalty = 0.0F;
  int64_t best_hpwl = 0;
  float best_overflow = 0.0F;
  std::string reason;
  std::string checkpoint_path;        // auto-saved checkpoint after a budget-limited batch
  std::string parent_checkpoint_path; // preserved pre-batch checkpoint (candidate rollback)
  std::string grid_report_path;       // bin-level overflow report JSON
  std::string experiment_record_path; // append-only JSONL action/provenance record
  std::vector<GPIterationRecord> iteration_records;  // records produced by this batch only
  GPRunScopeEffect scope_effect;
  GPOverflowReport grid_report;
};

}  // namespace ipl

#endif  // IPL_API_GP_CONTRACT_H
