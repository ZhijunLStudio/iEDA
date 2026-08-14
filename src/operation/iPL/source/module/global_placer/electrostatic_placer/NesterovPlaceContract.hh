#ifndef IPL_OPERATOR_GP_NESTEROV_PLACE_CONTRACT_H
#define IPL_OPERATOR_GP_NESTEROV_PLACE_CONTRACT_H

#include <cmath>
#include <cstdint>
#include <algorithm>
#include <limits>
#include <string>
#include <vector>

#include "solver/nesterov/Nesterov.hh"

namespace ipl {

enum class NesterovPlaceOutcome
{
  kNotRun,
  kConverged,
  kDiverged,
  kMaxIter,
  kInvalidMetric,
  kOverflowTargetMiss,
};

// Per-batch advance result of a persistent GP session.
// The underlying solve outcome (when the session reaches a terminal condition)
// is reported through NesterovPlaceOutcome via NesterovPlace::lastResult().
enum class GPAdvanceOutcome
{
  kBudgetReached,   // requested iterations consumed, session remains Ready
  kFinished,        // a terminal condition fired during this batch (see lastResult().outcome)
  kAlreadyFinished, // the session had already reached a terminal condition; no iterations ran
  kNotInitialized,  // advance called before session initialization
};

inline bool isNesterovHardFailure(NesterovPlaceOutcome outcome)
{
  return outcome == NesterovPlaceOutcome::kDiverged || outcome == NesterovPlaceOutcome::kInvalidMetric;
}

inline bool isNesterovQualitySuccess(NesterovPlaceOutcome outcome)
{
  return outcome == NesterovPlaceOutcome::kConverged;
}

struct NesterovIterationRecord
{
  int32_t iter = 0;
  int64_t hpwl = 0;
  float overflow = 0.0f;
  float step_length = 0.0f;
  float gradient_norm = 0.0f;
  float density_penalty = 0.0f;
  float route_util = 0.0f;
  bool quad_penalty_enabled = false;
  bool entropy_injected = false;
};

// Persistent GP session state (72c M2). Captured at accepted-iteration
// boundaries; restoring it into a fresh NesterovPlace + Nesterov must reproduce
// the exact numerical path of the next advance batch.
struct GPStateCheckpoint
{
  // NesterovPlace session scalars.
  int32_t current_iter = 0;
  float sum_overflow = 0.0F;
  int64_t prev_hpwl = 0;
  int64_t cur_hpwl = 0;
  float sum_overflow_threshold = 1e25F;
  float hpwl_attach_sum_overflow = 1e25F;
  bool max_phi_coef_record = false;
  int32_t cur_opt_overflow_step = 0;
  int32_t last_perturb_iter = -50;
  bool is_add_quad_penalty = false;
  bool is_cal_phi = false;
  bool stop_placement = false;
  int64_t best_hpwl = INT64_MAX;
  float best_overflow = FLT_MAX;
  float quad_penalty_coeff = 0.005F;
  int64_t total_inst_area = 0;
  int32_t finished_iter = 0;
  float final_step_length = 0.0F;
  float final_gradient_norm = 0.0F;
  float final_route_util = 0.0F;
  std::vector<float> overflow_record_list;
  std::vector<float> hpwl_record_list;
  std::vector<NesterovIterationRecord> iteration_records;

  // NesterovDatabase scalars (gradient sums are recomputed at the start of each
  // updatePenaltyGradient and _base_wirelength_coef is rebuilt deterministically).
  float wirelength_coef = 0.0F;
  float density_penalty = 0.0F;
  bool is_diverged = false;

  // Per-net weights (in _nNet_list order). Only mutated by max-wirelength /
  // timing net-weight updates (opt_overflow_list), which is empty in the default
  // config surface; persisted regardless so any weight state resumes exactly.
  std::vector<float> net_weights;
  std::vector<float> net_delta_weights;

  // Effective GP config fingerprint: canonical serialization of every
  // NesterovPlaceConfig value that affects the numerical path. Mismatch on
  // restore is rejected before any solver state is touched.
  std::string config_fingerprint;

  // Runtime config mutation (the only NesterovPlaceConfig field mutated mid-run).
  float max_phi_coef = 1.05F;

  // Per-placable-instance state, in placable-list order. instance_names doubles
  // as the topology fingerprint validated on restore.
  std::vector<std::string> instance_names;
  std::vector<Point<int32_t>> instance_density_coords;
  std::vector<float> instance_density_scales;
  std::vector<Point<int32_t>> best_position_list;
  std::vector<Point<int32_t>> cur_position_list;
  std::vector<float> best_density_scale_list;
  std::vector<float> cur_density_scale_list;

  // Nesterov solver state.
  Nesterov::State solver;
};

inline bool validateNesterovIterationRecord(const NesterovIterationRecord& record, int32_t previous_iter = 0,
                                            std::string* reason = nullptr)
{
  const auto fail = [reason](const std::string& message) {
    if (reason != nullptr) {
      *reason = message;
    }
    return false;
  };
  if (record.iter <= previous_iter) {
    return fail("iteration numbers must be strictly increasing");
  }
  if (record.hpwl < 0) {
    return fail("iteration HPWL must be non-negative");
  }
  if (!std::isfinite(record.overflow) || record.overflow < 0.0F) {
    return fail("iteration overflow must be finite and non-negative");
  }
  if (!std::isfinite(record.step_length) || record.step_length < 0.0F) {
    return fail("iteration step length must be finite and non-negative");
  }
  if (!std::isfinite(record.gradient_norm) || record.gradient_norm < 0.0F) {
    return fail("iteration gradient norm must be finite and non-negative");
  }
  if (!std::isfinite(record.density_penalty) || record.density_penalty < 0.0F) {
    return fail("iteration density penalty must be finite and non-negative");
  }
  if (!std::isfinite(record.route_util) || record.route_util < 0.0F) {
    return fail("iteration route utilization must be finite and non-negative");
  }
  return true;
}

inline bool validateNesterovIterationRecords(const std::vector<NesterovIterationRecord>& records, std::string* reason = nullptr)
{
  int32_t previous_iter = 0;
  for (const auto& record : records) {
    if (!validateNesterovIterationRecord(record, previous_iter, reason)) {
      return false;
    }
    previous_iter = record.iter;
  }
  return true;
}

inline bool detectNesterovDivergence(const std::vector<float>& overflow_records, const std::vector<float>& hpwl_records,
                                     int32_t window, float threshold, float target_overflow, float best_overflow,
                                     float best_hpwl, bool is_routability = false)
{
  if (window <= 0 || static_cast<int32_t>(overflow_records.size()) < window
      || hpwl_records.size() < overflow_records.size()) {
    return false;
  }

  const int32_t begin_idx = static_cast<int32_t>(overflow_records.size()) - window;
  const int32_t end_idx = static_cast<int32_t>(overflow_records.size());
  float overflow_mean = 0.0F;
  float overflow_diff = 0.0F;
  float overflow_max = -std::numeric_limits<float>::max();
  float overflow_min = std::numeric_limits<float>::max();
  float hpwl_mean = 0.0F;
  for (int32_t index = begin_idx; index < end_idx; ++index) {
    const float overflow = overflow_records[index];
    if (!std::isfinite(overflow) || overflow < 0.0F || !std::isfinite(hpwl_records[index]) || hpwl_records[index] < 0.0F) {
      return false;
    }
    overflow_mean += overflow;
    if (index + 1 < end_idx) {
      overflow_diff += std::fabs(overflow_records[index + 1] - overflow);
    }
    overflow_max = std::max(overflow_max, overflow);
    overflow_min = std::min(overflow_min, overflow);
    hpwl_mean += hpwl_records[index];
  }

  overflow_mean /= window;
  overflow_diff /= window;
  hpwl_mean /= static_cast<float>(window);
  const float overflow_base = std::max(target_overflow, best_overflow);
  const float overflow_ratio = (overflow_mean - overflow_base) / std::max(overflow_base, 1.0e-6F);
  const float hpwl_ratio = static_cast<float>(hpwl_mean - best_hpwl) / std::max(1.0F, best_hpwl);
  if (hpwl_ratio <= threshold * 1.2F) {
    return false;
  }
  if (overflow_ratio > threshold && !is_routability) {
    return true;
  }
  if (overflow_mean > 0.0F && (overflow_max - overflow_min) / overflow_mean < threshold && !is_routability) {
    return true;
  }
  return overflow_diff > 0.6F;
}

}  // namespace ipl

#endif
