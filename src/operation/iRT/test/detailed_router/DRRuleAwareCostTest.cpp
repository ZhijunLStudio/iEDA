#include "DRRuleAwareCost.hpp"

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

  ok &= require(irt::ruleAwareWeight(irt::ViolationType::kMetalShort, false) == 1, "disabled weights must stay 1");
  ok &= require(irt::ruleAwareWeight(irt::ViolationType::kMetalShort, true) == 4, "metal short must be highest weight");
  ok &= require(irt::ruleAwareWeight(irt::ViolationType::kParallelRunLengthSpacing, true) == 3, "PRL spacing weight");
  ok &= require(irt::ruleAwareWeight(irt::ViolationType::kMinimumArea, true) == 3, "min-area weight");

  ok &= require(irt::ruleAwareViolationCost(0, 10.0, {.enabled = false}) == 0.0, "no violation → zero cost");
  ok &= require(irt::ruleAwareViolationCost(5, 10.0, {.enabled = false}) == 10.0, "legacy path stays binary");
  ok &= require(irt::ruleAwareViolationCost(5, 10.0, {.enabled = true, .max_history_scale = 8}) == 50.0,
                "enabled path scales by capped history");
  ok &= require(irt::ruleAwareViolationCost(20, 10.0, {.enabled = true, .max_history_scale = 8}) == 80.0,
                "history scale must be capped for A* stability");

  ok &= require(irt::enhancedMinAreaCandidateBudget(10, false, 10) == 10, "disabled repair keeps budget");
  ok &= require(irt::enhancedMinAreaCandidateBudget(10, true, 10) == 20, "enhanced repair doubles or boosts");
  ok &= require(irt::enhancedMinAreaCandidateBudget(3, true, 10) == 13, "boost wins when larger than 2x");

  return ok ? EXIT_SUCCESS : EXIT_FAILURE;
}
