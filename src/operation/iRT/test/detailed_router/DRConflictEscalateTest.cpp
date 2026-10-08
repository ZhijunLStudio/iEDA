#include "DRConflictEscalate.hpp"

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

  ok &= require(irt::prlShortRepairPriority(irt::ViolationType::kMetalShort) >
                    irt::prlShortRepairPriority(irt::ViolationType::kParallelRunLengthSpacing),
                "short must outrank PRL");
  ok &= require(irt::prlShortRepairPriority(irt::ViolationType::kParallelRunLengthSpacing) >
                    irt::prlShortRepairPriority(irt::ViolationType::kMinimumArea),
                "PRL must outrank min-area");
  ok &= require(irt::componentWeightBoost(2, 0) == 2, "level 0 keeps weight");
  ok &= require(irt::componentWeightBoost(2, 1) == 4, "level 1 doubles");
  ok &= require(irt::componentWeightBoost(2, 4) == 10, "level 4 is capped boost");

  // Two shorts sharing a net → one component; isolated PRL → second component; pick highest severity.
  std::vector<irt::DRConflictViolationRef> refs(3);
  refs[0] = {.index = 0,
             .type = irt::ViolationType::kMetalShort,
             .layer_idx = 1,
             .ll_x = 0,
             .ll_y = 0,
             .ur_x = 10,
             .ur_y = 10,
             .severity = 4,
             .net_ids = {1, 2}};
  refs[1] = {.index = 1,
             .type = irt::ViolationType::kMetalShort,
             .layer_idx = 1,
             .ll_x = 100,
             .ll_y = 100,
             .ur_x = 110,
             .ur_y = 110,
             .severity = 4,
             .net_ids = {2, 3}};  // share net 2 with refs[0]
  refs[2] = {.index = 2,
             .type = irt::ViolationType::kParallelRunLengthSpacing,
             .layer_idx = 1,
             .ll_x = 1000,
             .ll_y = 1000,
             .ur_x = 1010,
             .ur_y = 1010,
             .severity = 3,
             .net_ids = {9}};

  const auto components = irt::buildConflictComponents(refs, /*halo=*/5);
  ok &= require(components.size() == 2, "expect 2 components (shared-net merge + isolated)");
  const int32_t best = irt::selectHighestSeverityComponent(components);
  ok &= require(best >= 0, "must select a component");
  ok &= require(components[best].severity_sum == 8, "shared-net component severity 4+4");
  ok &= require(components[best].net_ids.count(1) == 1 && components[best].net_ids.count(2) == 1
                    && components[best].net_ids.count(3) == 1,
                "escalated nets must be {1,2,3}");

  // Same-layer bbox+halo overlap without shared net also merges.
  std::vector<irt::DRConflictViolationRef> overlap_refs(2);
  overlap_refs[0] = {.index = 0,
                     .type = irt::ViolationType::kMetalShort,
                     .layer_idx = 2,
                     .ll_x = 0,
                     .ll_y = 0,
                     .ur_x = 10,
                     .ur_y = 10,
                     .severity = 1,
                     .net_ids = {10}};
  overlap_refs[1] = {.index = 1,
                     .type = irt::ViolationType::kMetalShort,
                     .layer_idx = 2,
                     .ll_x = 12,
                     .ll_y = 0,
                     .ur_x = 22,
                     .ur_y = 10,
                     .severity = 1,
                     .net_ids = {11}};
  const auto overlap_comps = irt::buildConflictComponents(overlap_refs, /*halo=*/5);
  ok &= require(overlap_comps.size() == 1, "halo overlap must merge into one component");

  return ok ? EXIT_SUCCESS : EXIT_FAILURE;
}
