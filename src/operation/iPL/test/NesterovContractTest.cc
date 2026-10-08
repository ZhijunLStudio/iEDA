#include "module/global_placer/electrostatic_placer/NesterovPlaceContract.hh"

#include <cstdlib>
#include <iostream>
#include <limits>
#include <string>
#include <vector>

namespace {

auto require(bool condition, const char* message) -> bool
{
  if (!condition) {
    std::cerr << "[FAIL] " << message << '\n';
  } else {
    std::cout << "[PASS] " << message << '\n';
  }
  return condition;
}

auto validRecord(int32_t iter) -> ipl::NesterovIterationRecord
{
  return {.iter = iter,
          .hpwl = 1000 - iter,
          .overflow = 0.5F / iter,
          .step_length = 0.01F,
          .gradient_norm = 10.0F,
          .density_penalty = 0.001F,
          .route_util = 0.0F};
}

}  // namespace

int main()
{
  bool ok = true;
  std::string reason;

  std::vector<ipl::NesterovIterationRecord> records{validRecord(1), validRecord(2), validRecord(10)};
  ok &= require(ipl::validateNesterovIterationRecords(records, &reason),
                "finite records with strictly increasing iteration numbers must validate");

  records[1].iter = 1;
  ok &= require(!ipl::validateNesterovIterationRecords(records, &reason)
                    && reason == "iteration numbers must be strictly increasing",
                "duplicate iteration numbers must fail the replay contract");

  auto invalid = validRecord(1);
  invalid.overflow = std::numeric_limits<float>::quiet_NaN();
  ok &= require(!ipl::validateNesterovIterationRecord(invalid, 0, &reason)
                    && reason == "iteration overflow must be finite and non-negative",
                "NaN overflow must fail as an invalid metric");

  invalid = validRecord(1);
  invalid.step_length = std::numeric_limits<float>::infinity();
  ok &= require(!ipl::validateNesterovIterationRecord(invalid, 0, &reason)
                    && reason == "iteration step length must be finite and non-negative",
                "infinite step length must fail as an invalid metric");

  invalid = validRecord(1);
  invalid.gradient_norm = -1.0F;
  ok &= require(!ipl::validateNesterovIterationRecord(invalid, 0, &reason)
                    && reason == "iteration gradient norm must be finite and non-negative",
                "negative gradient norm must fail the iteration contract");

  ok &= require(ipl::isNesterovHardFailure(ipl::NesterovPlaceOutcome::kDiverged),
                "divergence must be a hard failure");
  ok &= require(ipl::isNesterovHardFailure(ipl::NesterovPlaceOutcome::kInvalidMetric),
                "invalid metrics must be a hard failure");
  ok &= require(!ipl::isNesterovHardFailure(ipl::NesterovPlaceOutcome::kMaxIter),
                "max-iteration completion must remain a quality failure rather than an execution crash");
  ok &= require(!ipl::isNesterovQualitySuccess(ipl::NesterovPlaceOutcome::kOverflowTargetMiss),
                "overflow target miss must not satisfy the GP quality contract");
  ok &= require(ipl::isNesterovQualitySuccess(ipl::NesterovPlaceOutcome::kConverged),
                "only convergence may satisfy the GP quality contract");

  ok &= require(ipl::detectNesterovDivergence({0.10F, 0.10F, 0.10F}, {100, 150, 150}, 3, 0.03F, 0.10F, 0.10F, 100),
                "synthetic overflow plateau with HPWL regression must be classified as divergence");
  ok &= require(!ipl::detectNesterovDivergence({0.30F, 0.20F, 0.10F}, {90, 95, 100}, 3, 0.03F, 0.10F, 0.10F, 100),
                "synthetic improving metric window must not be classified as divergence");

  return ok ? EXIT_SUCCESS : EXIT_FAILURE;
}
