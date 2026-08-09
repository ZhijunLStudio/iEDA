#include <cstdlib>
#include <iostream>

#include "PlacementResult.hh"

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

}  // namespace

int main()
{
  bool ok = true;
  const auto success = ipl::PlacementFlowResult{true, ipl::PlacementStatusCode::kOk, {}, {}};
  const auto failure = ipl::PlacementFlowResult{false, ipl::PlacementStatusCode::kDPFailed, "detail_placement", "DP failed"};

  ok &= require(ipl::placementTclResult(success) == 1U, "Tcl must map typed success to command success");
  ok &= require(ipl::placementTclResult(failure) == 0U, "Tcl must map typed failure to command failure");
  ok &= require(ipl::placementPythonResult(success), "Python must preserve typed success as True");
  ok &= require(!ipl::placementPythonResult(failure), "Python must preserve typed failure as False");
  ok &= require(ipl::placementPythonResult(true) && !ipl::placementPythonResult(false),
                "Python bool adapter must preserve legacy bool semantics");
  return ok ? EXIT_SUCCESS : EXIT_FAILURE;
}
