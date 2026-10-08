#pragma once

#include <functional>
#include <string>
#include <utility>

#include "PlacementStatus.hh"

namespace ipl {

struct PlacementFlowResult
{
  bool success = false;
  PlacementStatusCode status = PlacementStatusCode::kNotRun;
  std::string failed_stage;
  std::string reason;

  static auto fromStage(const PlacementStageStatus& stage_status) -> PlacementFlowResult
  {
    return {.success = stage_status.execution_success && stage_status.quality_success,
            .status = stage_status.code,
            .failed_stage = stage_status.stage,
            .reason = stage_status.message};
  }

  static auto fromStatus(const PlacementFlowStatus& flow_status) -> PlacementFlowResult
  {
    return {.success = flow_status.strictSuccess(),
            .status = flow_status.failedStatusCode(),
            .failed_stage = flow_status.failed_stage,
            .reason = flow_status.overall_reason};
  }
};

// Legacy adapter used by the Tcl/flow boundary. The typed status remains
// available through PLAPI::lastRunStatus() for callers that need diagnostics.
template <typename FlowRunner>
auto propagatePlacementFlowResult(FlowRunner&& run_flow) -> bool
{
  return std::invoke(std::forward<FlowRunner>(run_flow));
}

inline auto placementTclResult(bool placement_succeeded) -> unsigned
{
  return placement_succeeded ? 1U : 0U;
}

inline auto placementTclResult(const PlacementFlowResult& result) -> unsigned
{
  return placementTclResult(result.success);
}

inline auto placementPythonResult(bool placement_succeeded) -> bool
{
  return placement_succeeded;
}

inline auto placementPythonResult(const PlacementFlowResult& result) -> bool
{
  return placementPythonResult(result.success);
}

}  // namespace ipl
