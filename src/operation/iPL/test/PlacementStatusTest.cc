#include "PlacementStatus.hh"

#include <cstdlib>
#include <iostream>
#include <limits>

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
  using ipl::PlacementStatusCode;
  using ipl::PlacementStatusEvaluator;

  bool ok = true;
  {
    const PlacementStatusCode codes[] = {
        PlacementStatusCode::kNotRun,       PlacementStatusCode::kOk,          PlacementStatusCode::kMPInfeasible,
        PlacementStatusCode::kGPDiverged,   PlacementStatusCode::kGPInvalidMetric,
        PlacementStatusCode::kGPOverflowTargetMiss, PlacementStatusCode::kLGSolverFailed,
        PlacementStatusCode::kLGIllegal,    PlacementStatusCode::kDPFailed,    PlacementStatusCode::kDPIllegal,
        PlacementStatusCode::kPostGPFailed, PlacementStatusCode::kBufferFailed, PlacementStatusCode::kNFSFailed,
        PlacementStatusCode::kArtifactError};
    for (const auto code : codes) {
      ok &= require(std::string(ipl::placementStatusCodeName(code)) != "UNKNOWN", "all status codes must serialize");
    }
    ok &= require(std::string(ipl::placementStatusCodeName(static_cast<PlacementStatusCode>(999))) == "UNKNOWN",
                  "unknown status codes must serialize as UNKNOWN");
  }
  {
    const auto failed = PlacementStatusEvaluator::macroPlacement(false, false, 0, "no feasible macro placement");
    ok &= require(failed.code == PlacementStatusCode::kMPInfeasible && !failed.execution_success,
                  "macro infeasibility must be a hard failure");
  }
  {
    const auto status = PlacementStatusEvaluator::globalPlacement(true, 0.0, 0.1, 100, true);
    ok &= require(status.code == PlacementStatusCode::kGPDiverged && !status.execution_success, "GP divergence must be a hard failure");
  }
  {
    const auto status
        = PlacementStatusEvaluator::globalPlacement(false, std::numeric_limits<double>::quiet_NaN(), 0.1, 100, true);
    ok &= require(status.code == PlacementStatusCode::kGPInvalidMetric && !status.execution_success, "non-finite overflow must fail");
  }
  {
    const auto status = PlacementStatusEvaluator::globalPlacement(false, 0.05, 0.1, 0, true);
    ok &= require(status.code == PlacementStatusCode::kGPInvalidMetric && !status.execution_success, "zero HPWL on a routable design must fail");
  }
  {
    const auto status = PlacementStatusEvaluator::globalPlacement(false, 0.15, 0.1, 100, true);
    ok &= require(status.code == PlacementStatusCode::kGPOverflowTargetMiss && status.execution_success && status.metrics_valid
                      && !status.quality_success,
                  "overflow target miss must be a QoR failure without changing compatible execution");
  }
  {
    const auto status = PlacementStatusEvaluator::globalPlacement(false, 0.05, 0.1, 100, true);
    ok &= require(status.code == PlacementStatusCode::kOk && status.execution_success && status.quality_success,
                  "valid GP metrics must pass execution and quality");
  }
  {
    const auto solver_failure = PlacementStatusEvaluator::legalization(false, false, 100);
    const auto illegal = PlacementStatusEvaluator::legalization(true, false, 100);
    const auto legal = PlacementStatusEvaluator::legalization(true, true, 100);
    ok &= require(solver_failure.code == PlacementStatusCode::kLGSolverFailed && !solver_failure.execution_success,
                  "LG solver failure must propagate");
    ok &= require(illegal.code == PlacementStatusCode::kLGIllegal && !illegal.execution_success, "illegal LG result must not be successful");
    ok &= require(legal.code == PlacementStatusCode::kOk && legal.execution_success && legal.quality_success, "legal LG result must pass");
  }
  {
    ipl::PlacementFlowStatus flow;
    flow.global_placement = PlacementStatusEvaluator::globalPlacement(false, 0.15, 0.1, 100, true);
    flow.legalization = PlacementStatusEvaluator::legalization(true, true, 100);
    flow.gp_ran = true;
    flow.lg_ran = true;
    ok &= require(flow.executionSuccess() && !flow.qualitySuccess(), "flow aggregation must preserve a GP QoR miss after legal LG");
    flow.flow_complete = true;
    ok &= require(!flow.strictSuccess() && flow.failedStatusCode() == PlacementStatusCode::kGPOverflowTargetMiss,
                  "strict flow policy must reject a quality miss");
  }
  {
    ipl::PlacementFlowStatus flow;
    flow.global_placement = PlacementStatusEvaluator::globalPlacement(false, 0.05, 0.1, 100, true);
    flow.detail_placement = PlacementStatusEvaluator::detailPlacement(false, true, 100, 100, "DP solver failed");
    flow.gp_ran = true;
    flow.flow_complete = true;
    flow.setFailure(flow.detail_placement);
    ok &= require(!flow.strictSuccess() && flow.failed_stage == "detail_placement"
                      && flow.failedStatusCode() == PlacementStatusCode::kDPFailed,
                  "DP failure must be retained as the failed stage");
  }
  {
    const auto artifact = PlacementStatusEvaluator::artifact(false, "read-only report directory");
    ipl::PlacementFlowStatus flow;
    flow.global_placement = PlacementStatusEvaluator::globalPlacement(false, 0.05, 0.1, 100, true);
    flow.gp_ran = true;
    flow.flow_complete = true;
    flow.artifact = artifact;
    flow.setFailure(flow.artifact);
    ok &= require(!flow.strictSuccess() && flow.failedStatusCode() == PlacementStatusCode::kArtifactError
                      && flow.failed_stage == "artifact",
                  "artifact publication failure must fail the strict flow");
  }
  {
    const auto skipped = PlacementStatusEvaluator::skippedStage("post_global_placement", "STA disabled");
    ipl::PlacementFlowStatus flow;
    flow.global_placement = PlacementStatusEvaluator::globalPlacement(false, 0.05, 0.1, 100, true);
    flow.gp_ran = true;
    flow.flow_complete = true;
    flow.post_global_placement = skipped;
    ok &= require(flow.strictSuccess(), "skipped optional stages must not fail a completed flow");
  }
  return ok ? EXIT_SUCCESS : EXIT_FAILURE;
}
