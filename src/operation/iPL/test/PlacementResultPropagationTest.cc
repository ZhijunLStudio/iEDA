#include "PlacementResult.hh"

#include <cstdlib>
#include <iostream>

namespace {

auto require(bool condition, const char* message) -> bool
{
  if (!condition) {
    std::cerr << message << '\n';
  }
  return condition;
}

}  // namespace

int main()
{
  bool ok = true;

  int failed_flow_calls = 0;
  const bool io_failure = ipl::propagatePlacementFlowResult([&failed_flow_calls] {
    ++failed_flow_calls;
    return false;
  });
  ok &= require(failed_flow_calls == 1 && !io_failure, "IO must call the placement flow once and preserve failure");
  ok &= require(ipl::placementTclResult(io_failure) == 0U, "TCL must map placement failure to command failure");

  int successful_flow_calls = 0;
  const bool io_success = ipl::propagatePlacementFlowResult([&successful_flow_calls] {
    ++successful_flow_calls;
    return true;
  });
  ok &= require(successful_flow_calls == 1 && io_success, "IO must call the placement flow once and preserve success");
  ok &= require(ipl::placementTclResult(io_success) == 1U, "TCL must map placement success to command success");

  ipl::PlacementFlowStatus flow;
  flow.global_placement = ipl::PlacementStatusEvaluator::globalPlacement(false, 0.05, 0.1, 100, true);
  flow.detail_placement = ipl::PlacementStatusEvaluator::detailPlacement(false, true, 100, 100, "DP failed");
  flow.gp_ran = true;
  flow.flow_complete = true;
  flow.setFailure(flow.detail_placement);
  const auto typed_result = ipl::PlacementFlowResult::fromStatus(flow);
  ok &= require(!typed_result.success && typed_result.status == ipl::PlacementStatusCode::kDPFailed
                    && typed_result.failed_stage == "detail_placement" && typed_result.reason == "DP failed",
                "typed result must preserve the failed stage and reason");
  ok &= require(ipl::placementTclResult(typed_result) == 0U, "typed result failure must map to Tcl failure");

  const auto require_typed_failure = [&ok](const ipl::PlacementStageStatus& stage, ipl::PlacementStatusCode expected_code,
                                           const char* message) {
    ipl::PlacementFlowStatus failed_flow;
    failed_flow.global_placement = ipl::PlacementStatusEvaluator::globalPlacement(false, 0.05, 0.1, 100, true);
    failed_flow.gp_ran = true;
    failed_flow.flow_complete = true;
    failed_flow.setFailure(stage);
    if (stage.stage == "macro_placement") {
      failed_flow.macro_placement = stage;
    } else if (stage.stage == "global_placement") {
      failed_flow.global_placement = stage;
    } else if (stage.stage == "legalization") {
      failed_flow.legalization = stage;
      failed_flow.lg_ran = true;
    } else if (stage.stage == "detail_placement") {
      failed_flow.detail_placement = stage;
    } else if (stage.stage == "post_global_placement") {
      failed_flow.post_global_placement = stage;
    } else if (stage.stage == "artifact") {
      failed_flow.artifact = stage;
    }
    const auto result = ipl::PlacementFlowResult::fromStatus(failed_flow);
    ok &= require(!result.success && result.status == expected_code && ipl::placementTclResult(result) == 0U, message);
  };
  require_typed_failure(ipl::PlacementStatusEvaluator::macroPlacement(false, false, 0, "MP failed"),
                        ipl::PlacementStatusCode::kMPInfeasible, "MP failure must reach the typed/Tcl boundary");
  require_typed_failure(ipl::PlacementStatusEvaluator::globalPlacement(true, 0.0, 0.1, 100, true),
                        ipl::PlacementStatusCode::kGPDiverged, "GP divergence must reach the typed/Tcl boundary");
  require_typed_failure(ipl::PlacementStatusEvaluator::legalization(true, false, 100), ipl::PlacementStatusCode::kLGIllegal,
                        "LG illegality must reach the typed/Tcl boundary");
  require_typed_failure(ipl::PlacementStatusEvaluator::postGlobalPlacement(false, false, 100, 100, "PostGP failed"),
                        ipl::PlacementStatusCode::kPostGPFailed, "PostGP failure must reach the typed/Tcl boundary");
  require_typed_failure(ipl::PlacementStatusEvaluator::artifact(false, "artifact failed"), ipl::PlacementStatusCode::kArtifactError,
                        "artifact failure must reach the typed/Tcl boundary");

  return ok ? EXIT_SUCCESS : EXIT_FAILURE;
}
