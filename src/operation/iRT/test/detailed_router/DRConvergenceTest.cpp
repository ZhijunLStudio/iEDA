#include "DRConvergence.hpp"

#include <cstdlib>
#include <iostream>
#include <set>
#include <string>
#include <utility>

namespace {

auto state(int iter, int violations, int severity, std::set<std::string> hotspots, int routed = 10) -> irt::DRIterationState
{
  return irt::DRIterationState{.iter = iter,
                               .routed_net_num = routed,
                               .total_net_num = 10,
                               .violation_num = violations,
                               .violation_score = severity,
                               .total_wire_length = 100.0,
                               .total_via_num = 20,
                               .hotspot_set = std::move(hotspots)};
}

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
  {
    irt::DRConvergenceTracker tracker;
    tracker.observe(state(1, 10, 20, {"a", "b"}));
    tracker.observe(state(2, 10, 20, {"a", "b"}));
    const auto& decision = tracker.observe(state(3, 10, 20, {"a", "b"}));
    ok &= require(decision.plateau, "stable residual hotspots must be classified as a plateau");
    ok &= require(decision.reason == "stable_residual_hotspots", "plateau reason must be machine-readable");
  }
  {
    irt::DRConvergenceTracker tracker;
    tracker.observe(state(1, 10, 20, {"a", "b"}));
    tracker.observe(state(2, 8, 16, {"a", "b"}));
    const auto& decision = tracker.observe(state(3, 6, 12, {"a", "b"}));
    ok &= require(!decision.plateau && decision.reason == "progressing", "improving severity must not be a plateau");
  }
  {
    irt::DRConvergenceTracker tracker;
    tracker.observe(state(1, 10, 20, {"a", "b"}));
    tracker.observe(state(2, 10, 20, {"c", "d"}));
    const auto& decision = tracker.observe(state(3, 10, 20, {"e", "f"}));
    ok &= require(!decision.plateau, "moving hotspots must not be classified as a stable plateau");
  }
  {
    irt::DRConvergenceTracker tracker;
    const auto& decision = tracker.observe(state(1, 0, 0, {}));
    ok &= require(decision.clean && !decision.plateau && decision.reason == "drc_clean", "DRC-clean state must terminate as clean");
  }
  {
    irt::DRConvergenceTracker tracker;
    const auto& decision = tracker.observe(state(1, 0, 0, {}, 9));
    ok &= require(!decision.clean && decision.reason == "routing_incomplete", "unrouted nets must prevent a false clean result");
  }
  return ok ? EXIT_SUCCESS : EXIT_FAILURE;
}
