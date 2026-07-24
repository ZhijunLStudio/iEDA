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

namespace ipl {

enum class PlacementStatusCode
{
  kNotRun,
  kOk,
  kGPDiverged,
  kGPInvalidMetric,
  kGPOverflowTargetMiss,
  kLGSolverFailed,
  kLGIllegal
};

inline auto placementStatusCodeName(PlacementStatusCode code) -> const char*
{
  switch (code) {
    case PlacementStatusCode::kNotRun:
      return "NOT_RUN";
    case PlacementStatusCode::kOk:
      return "OK";
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
  }
  return "UNKNOWN";
}

struct PlacementStageStatus
{
  PlacementStatusCode code = PlacementStatusCode::kNotRun;
  std::string stage = "not_run";
  std::string message = "stage has not run";
  bool execution_success = false;
  bool quality_success = false;
  bool metrics_valid = false;
  bool legal = false;
  double overflow = 0.0;
  double target_overflow = 0.0;
  int64_t hpwl = 0;
};

struct PlacementFlowStatus
{
  PlacementStageStatus global_placement;
  PlacementStageStatus legalization;
  bool gp_ran = false;
  bool lg_ran = false;
  bool flow_complete = false;

  auto executionSuccess() const -> bool
  {
    return (gp_ran || lg_ran) && (!gp_ran || global_placement.execution_success) && (!lg_ran || legalization.execution_success);
  }

  auto qualitySuccess() const -> bool
  {
    return (gp_ran || lg_ran) && (!gp_ran || global_placement.quality_success) && (!lg_ran || legalization.quality_success);
  }
};

class PlacementStatusEvaluator
{
 public:
  static auto globalPlacement(bool diverged, double overflow, double target_overflow, int64_t hpwl, bool expect_positive_hpwl)
      -> PlacementStageStatus
  {
    PlacementStageStatus status{.stage = "global_placement",
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
    status.metrics_valid = true;
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
    PlacementStageStatus status{.stage = "legalization", .legal = legal, .hpwl = hpwl};
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
    status.quality_success = true;
    status.metrics_valid = hpwl >= 0;
    return status;
  }
};

}  // namespace ipl
