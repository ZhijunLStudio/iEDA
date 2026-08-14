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

struct GPRunRequest
{
  GPRunMode mode = GPRunMode::kStart;
  int32_t accepted_iterations = 20;
  bool random_init = true;          // kStart only: run RandomPlace before building the session
  std::string checkpoint_path;      // kResume only: checkpoint JSON to restore from
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
  std::string reason;
  std::string checkpoint_path;                         // auto-saved checkpoint after a budget-limited batch
  std::vector<GPIterationRecord> iteration_records;    // records produced by this batch only
};

}  // namespace ipl

#endif  // IPL_API_GP_CONTRACT_H
