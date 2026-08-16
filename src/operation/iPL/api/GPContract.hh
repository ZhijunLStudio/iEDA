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
  kRestore,  // rebuild a session from a checkpoint exactly (0 iterations) and publish it
  kCandidate, // fork the active parent: local scope batch + same-budget global control, restore winner
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
  kRestored,  // checkpoint restored exactly; no iterations were run
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
    case GPStopReason::kRestored:
      return "restored";
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
  kRegion,     // all movable instances overlapping a physical rectangle become Active
  kLongNet,    // instances on the highest-HPWL nets become Active (wirelength-driven local seed)
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
    case GPRunScopeMode::kRegion:
      return "region";
    case GPRunScopeMode::kLongNet:
      return "longnet";
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
  int64_t local_fixed_area = 0;
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

enum class GPCandidateVerdict
{
  kIncomparable,
  kLeftBetter,
  kRightBetter,
  kEqual,
};

inline const char* gpCandidateVerdictName(GPCandidateVerdict verdict)
{
  switch (verdict) {
    case GPCandidateVerdict::kIncomparable:
      return "incomparable";
    case GPCandidateVerdict::kLeftBetter:
      return "left_better";
    case GPCandidateVerdict::kRightBetter:
      return "right_better";
    case GPCandidateVerdict::kEqual:
      return "equal";
  }
  return "unknown";
}

struct GPCandidateMetrics
{
  int32_t current_iter = 0;
  int64_t hpwl = 0;
  float overflow = 0.0F;
  float step_length = 0.0F;
  float density_penalty = 0.0F;
};

// Production candidate comparison on persisted checkpoints. It never touches
// solver state: both checkpoints are loaded, their origin (config fingerprint +
// placable topology + iteration count) is compared, then the same-stage metrics
// are compared under the hard rules of the agent loop.
struct GPCandidateComparison
{
  bool ok = false;
  bool same_origin = false;
  bool same_budget = false;
  GPCandidateVerdict verdict = GPCandidateVerdict::kIncomparable;
  std::string reason;
  GPCandidateMetrics left;
  GPCandidateMetrics right;
};

struct GPRunRequest
{
  GPRunMode mode = GPRunMode::kStart;
  int32_t accepted_iterations = 20;
  bool random_init = true;          // kStart only: run RandomPlace before building the session
  // kStart only with random_init=false: blend each solver step toward the
  // session-start coordinates. 0 = unconstrained re-linearize, 1 = freeze.
  float seed_anchor_strength = 0.0F;
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
  int32_t scope_halo_hops = 1;       // net-hop radius of the halo; level h moves at halo_coeff^h
  uint32_t scope_seed = 1000;        // kRandom: reproducible Active-set shuffle seed
  std::vector<std::string> scope_instance_names;  // kInstances: seed instance names
  bool scope_region_set = false;       // kRegion: physical rectangle seed
  int32_t scope_region_ll_x = 0;
  int32_t scope_region_ll_y = 0;
  int32_t scope_region_ur_x = 0;
  int32_t scope_region_ur_y = 0;
  // Local density screen (L1): effective grid capacity factor inside the
  // selected scope. 1.0 keeps the global density model; values in (0,1) make
  // the scoped grids harder/easier? A value below 1.0 reduces the effective
  // capacity, pushing cells out of the scoped region. Applied per batch and
  // cleared before the checkpoint boundary, so it never leaks.
  float scope_density_target = 1.0F;
  // kHotspot only: apply scope_density_target to the top ratio of overflowing
  // bins. 0 keeps the movement-scope-only behavior.
  float scope_density_ratio = 0.0F;

  // Observation: max overflowing bins returned in GPRunResult.grid_report.
  // The full top-N report is also written to <output>/pl/gp_grid_report.json.
  int32_t grid_report_top_n = 64;
  // Observation: recompute RUDY route demand/utilization at this batch
  // boundary and return it in GPRunResult.route_util. Off by default because
  // it is an O(nets) pass and is not needed by the numerical path.
  bool evaluate_route_util = false;
  // Candidate acceptance: when both candidates are infeasible and neither
  // Pareto-dominates, allow a controlled HPWL-vs-overflow tradeoff.
  // score = delta_hpwl_ratio + overflow_penalty * delta_overflow_ratio.
  // 0 keeps the strict Pareto policy (global baseline wins tradeoffs).
  float candidate_overflow_penalty = 0.0F;

  // kStart-only cautious solver overrides (-1 = keep the configured value).
  // These are effective configuration, not mid-session mutation; they are
  // captured in the checkpoint and restored by kResume automatically.
  float init_density_penalty = -1.0F;
  float min_phi_coef = -1.0F;
  float max_phi_coef = -1.0F;
  // kStart-only congestion-effort override (-1 = keep configured value).
  int32_t congestion_effort = -1;
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
  float route_util = 0.0F;  // congestion mode: max(H util, V util) at batch end
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

  // kCandidate provenance: comparison and child checkpoints of the automatic
  // local-vs-global fork. The returned session is already restored to the
  // winner (global on tie / incomparable).
  GPCandidateComparison candidate_comparison;
  std::string candidate_local_checkpoint_path;
  std::string candidate_global_checkpoint_path;
};

}  // namespace ipl

#endif  // IPL_API_GP_CONTRACT_H
