// ***************************************************************************************
// Copyright (c) 2023-2025 Peng Cheng Laboratory
// Copyright (c) 2023-2025 Institute of Computing Technology, Chinese Academy of Sciences
// Copyright (c) 2023-2025 Beijing Institute of Open Source Chip
//
// iEDA is licensed under Mulan PSL v2.
// ***************************************************************************************
#pragma once

#include <cmath>
#include <cstdint>
#include <string>
#include <utility>
#include <vector>

namespace ipl {

enum class PlacementStatusCode
{
  kNotRun,
  kOk,
  kMPInfeasible,
  kGPDiverged,
  kGPInvalidMetric,
  kGPOverflowTargetMiss,
  kLGSolverFailed,
  kLGIllegal,
  kDPFailed,
  kDPIllegal,
  kPostGPFailed,
  kBufferFailed,
  kNFSFailed,
  kArtifactError
};

inline auto placementStatusCodeName(PlacementStatusCode code) -> const char*
{
  switch (code) {
    case PlacementStatusCode::kNotRun:
      return "NOT_RUN";
    case PlacementStatusCode::kOk:
      return "OK";
    case PlacementStatusCode::kMPInfeasible:
      return "MP_INFEASIBLE";
    case PlacementStatusCode::kGPDiverged:
      return "GP_DIVERGED";
    case PlacementStatusCode::kGPInvalidMetric:
      return "GP_INVALID_METRIC";
    case PlacementStatusCode::kGPOverflowTargetMiss:
      return "GP_OVERFLOW_TARGET_MISS";
    case PlacementStatusCode::kLGSolverFailed:
      return "LG_SOLVER_FAILED";
    case PlacementStatusCode::kLGIllegal:
      return "LG_ILLEGAL";
    case PlacementStatusCode::kDPFailed:
      return "DP_FAILED";
    case PlacementStatusCode::kDPIllegal:
      return "DP_ILLEGAL";
    case PlacementStatusCode::kPostGPFailed:
      return "POSTGP_FAILED";
    case PlacementStatusCode::kBufferFailed:
      return "BUFFER_FAILED";
    case PlacementStatusCode::kNFSFailed:
      return "NFS_FAILED";
    case PlacementStatusCode::kArtifactError:
      return "ARTIFACT_ERROR";
  }
  return "UNKNOWN";
}

struct PlacementStageStatus
{
  PlacementStatusCode code = PlacementStatusCode::kNotRun;
  std::string stage = "not_run";
  std::string message = "stage has not run";
  bool entered = false;
  bool completed = false;
  bool skipped = false;
  bool execution_success = false;
  bool quality_success = false;
  bool metrics_valid = false;
  bool legal = false;
  double overflow = 0.0;
  double target_overflow = 0.0;
  int64_t hpwl = 0;
  int64_t metric_before = 0;
  int64_t metric_after = 0;
  int64_t changed_count = -1;
  std::vector<std::string> exhibit;
};

struct PlacementFlowStatus
{
  PlacementStageStatus macro_placement;
  PlacementStageStatus global_placement;
  PlacementStageStatus legalization;
  PlacementStageStatus detail_placement;
  PlacementStageStatus post_global_placement;
  PlacementStageStatus buffer_insertion;
  PlacementStageStatus network_flow;
  PlacementStageStatus artifact;
  bool gp_ran = false;
  bool lg_ran = false;
  bool flow_complete = false;
  std::string failed_stage;
  std::string overall_reason;

  auto executionSuccess() const -> bool
  {
    return (gp_ran || lg_ran) && (!gp_ran || global_placement.execution_success) && (!lg_ran || legalization.execution_success)
           && (!macro_placement.entered || macro_placement.execution_success)
           && (!detail_placement.entered || detail_placement.execution_success)
           && (!post_global_placement.entered || post_global_placement.execution_success)
           && (!buffer_insertion.entered || buffer_insertion.execution_success)
           && (!network_flow.entered || network_flow.execution_success)
           && (!artifact.entered || artifact.execution_success);
  }

  auto qualitySuccess() const -> bool
  {
    return (gp_ran || lg_ran) && (!gp_ran || global_placement.quality_success) && (!lg_ran || legalization.quality_success)
           && (!macro_placement.entered || macro_placement.quality_success)
           && (!detail_placement.entered || detail_placement.quality_success)
           && (!post_global_placement.entered || post_global_placement.quality_success)
           && (!buffer_insertion.entered || buffer_insertion.quality_success)
           && (!network_flow.entered || network_flow.quality_success)
           && (!artifact.entered || artifact.quality_success);
  }

  // Strict flow policy: every entered stage must execute and meet its quality
  // contract. The legacy reducers above intentionally remain compatible with
  // callers that only gate on execution.
  auto strictSuccess() const -> bool
  {
    bool entered_stage = false;
    for (const auto* stage : {&macro_placement, &global_placement, &legalization, &detail_placement, &post_global_placement,
                              &buffer_insertion, &network_flow, &artifact}) {
      if (!stage->entered) {
        continue;
      }
      entered_stage = true;
      if (!stage->completed || !stage->execution_success || !stage->quality_success) {
        return false;
      }
    }
    return entered_stage && flow_complete;
  }

  auto setFailure(const PlacementStageStatus& stage_status) -> void
  {
    if (!stage_status.entered || stage_status.skipped) {
      return;
    }
    if (stage_status.execution_success && stage_status.quality_success) {
      return;
    }
    failed_stage = stage_status.stage;
    overall_reason = stage_status.message;
  }

  auto failedStatusCode() const -> PlacementStatusCode
  {
    for (const auto* stage : {&macro_placement, &global_placement, &buffer_insertion, &network_flow, &legalization,
                              &post_global_placement, &detail_placement, &artifact}) {
      if (stage->entered && (!stage->execution_success || !stage->quality_success)) {
        return stage->code;
      }
    }
    return PlacementStatusCode::kOk;
  }
};

class PlacementStatusEvaluator
{
 public:
  static auto stage(std::string stage_name, PlacementStatusCode code, bool execution_success, bool quality_success, bool legal,
                    std::string message, int64_t metric_before = 0, int64_t metric_after = 0, int64_t changed_count = -1,
                    std::vector<std::string> exhibit = {})
      -> PlacementStageStatus
  {
    PlacementStageStatus status;
    status.code = code;
    status.stage = std::move(stage_name);
    status.message = std::move(message);
    status.entered = true;
    status.completed = execution_success;
    status.execution_success = execution_success;
    status.quality_success = quality_success;
    status.metrics_valid = true;
    status.legal = legal;
    status.hpwl = metric_after;
    status.metric_before = metric_before;
    status.metric_after = metric_after;
    status.changed_count = changed_count;
    status.exhibit = std::move(exhibit);
    return status;
  }

  static auto skippedStage(std::string stage_name, std::string reason) -> PlacementStageStatus
  {
    return PlacementStageStatus{.stage = std::move(stage_name), .message = std::move(reason), .skipped = true};
  }

  static auto macroPlacement(bool success, bool legal, int64_t hpwl, std::string reason = {}) -> PlacementStageStatus
  {
    if (!success) {
      return stage("macro_placement", PlacementStatusCode::kMPInfeasible, false, false, legal,
                   reason.empty() ? "macro placement did not produce a feasible legal placement" : std::move(reason), 0, hpwl);
    }
    if (!legal) {
      return stage("macro_placement", PlacementStatusCode::kMPInfeasible, false, false, false,
                   reason.empty() ? "macro placement produced an illegal placement" : std::move(reason), 0, hpwl);
    }
    return stage("macro_placement", PlacementStatusCode::kOk, true, true, true, "macro placement completed", 0, hpwl);
  }

  static auto globalPlacement(bool diverged, double overflow, double target_overflow, int64_t hpwl, bool expect_positive_hpwl)
      -> PlacementStageStatus
  {
    PlacementStageStatus status{.stage = "global_placement",
                                .entered = true,
                                .overflow = overflow,
                                .target_overflow = target_overflow,
                                .hpwl = hpwl};
    if (diverged) {
      status.code = PlacementStatusCode::kGPDiverged;
      status.message = "Nesterov global placement diverged";
      return status;
    }
    if (!std::isfinite(overflow) || !std::isfinite(target_overflow) || overflow < 0.0 || target_overflow < 0.0 || hpwl < 0
        || (expect_positive_hpwl && hpwl == 0)) {
      status.code = PlacementStatusCode::kGPInvalidMetric;
      status.message = "global placement produced an invalid overflow or HPWL metric";
      return status;
    }

    status.execution_success = true;
    status.completed = true;
    status.metrics_valid = true;
    status.metric_after = hpwl;
    if (overflow > target_overflow) {
      status.code = PlacementStatusCode::kGPOverflowTargetMiss;
      status.message = "global placement completed but missed the configured overflow target";
      return status;
    }
    status.code = PlacementStatusCode::kOk;
    status.message = "global placement completed and met its metric contract";
    status.quality_success = true;
    return status;
  }

  static auto legalization(bool solver_success, bool legal, int64_t hpwl) -> PlacementStageStatus
  {
    PlacementStageStatus status{.stage = "legalization", .entered = true, .legal = legal, .hpwl = hpwl, .metric_after = hpwl};
    if (!solver_success) {
      status.code = PlacementStatusCode::kLGSolverFailed;
      status.message = "legalization solver did not complete";
      return status;
    }
    if (!legal) {
      status.code = PlacementStatusCode::kLGIllegal;
      status.message = "legalization completed with an illegal placement";
      return status;
    }
    status.code = PlacementStatusCode::kOk;
    status.message = "legalization completed with a legal placement";
    status.execution_success = true;
    status.completed = true;
    status.quality_success = true;
    status.metrics_valid = hpwl >= 0;
    return status;
  }

  static auto detailPlacement(bool success, bool legal, int64_t metric_before, int64_t metric_after, std::string reason = {})
      -> PlacementStageStatus
  {
    if (!success) {
      return stage("detail_placement", PlacementStatusCode::kDPFailed, false, false, legal,
                   reason.empty() ? "detail placement did not complete" : std::move(reason), metric_before, metric_after);
    }
    if (!legal) {
      return stage("detail_placement", PlacementStatusCode::kDPIllegal, true, false, false,
                   reason.empty() ? "detail placement produced an illegal placement" : std::move(reason), metric_before, metric_after);
    }
    return stage("detail_placement", PlacementStatusCode::kOk, true, true, true, "detail placement completed", metric_before, metric_after);
  }

  static auto postGlobalPlacement(bool success, bool legal, int64_t metric_before, int64_t metric_after, std::string reason = {})
      -> PlacementStageStatus
  {
    if (!success) {
      return stage("post_global_placement", PlacementStatusCode::kPostGPFailed, false, false, legal,
                   reason.empty() ? "post global placement did not complete" : std::move(reason), metric_before, metric_after);
    }
    if (!legal) {
      return stage("post_global_placement", PlacementStatusCode::kPostGPFailed, true, false, false,
                   reason.empty() ? "post global placement produced an illegal placement" : std::move(reason), metric_before, metric_after);
    }
    return stage("post_global_placement", PlacementStatusCode::kOk, true, true, true, "post global placement completed", metric_before,
                 metric_after);
  }

  static auto optionalStage(const std::string& stage_name, bool success, PlacementStatusCode failure_code, int64_t metric_before,
                            int64_t metric_after, std::string success_message, std::string failure_message,
                            int64_t changed_count = -1) -> PlacementStageStatus
  {
    if (!success) {
      return stage(stage_name, failure_code, false, false, true, std::move(failure_message), metric_before, metric_after, changed_count);
    }
    return stage(stage_name, PlacementStatusCode::kOk, true, true, true, std::move(success_message), metric_before, metric_after,
                 changed_count);
  }

  static auto artifact(bool success, std::string reason = {}) -> PlacementStageStatus
  {
    return stage("artifact", success ? PlacementStatusCode::kOk : PlacementStatusCode::kArtifactError, success, success, true,
                 success ? "placement status artifact published"
                         : (reason.empty() ? "placement status artifact could not be published" : std::move(reason)));
  }
};

}  // namespace ipl
