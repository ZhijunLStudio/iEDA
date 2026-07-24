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

  return ok ? EXIT_SUCCESS : EXIT_FAILURE;
}
