#include "ieco_timing.h"

#include <iostream>
#include <stdexcept>

namespace {

void require(bool condition, const char* message)
{
  if (!condition) {
    throw std::runtime_error(message);
  }
}

ieco::ECOTimingGuardband passingGuardband()
{
  return {1.0, 1.0, 0.0, 0.0, 0.0, 0.0, true};
}

ieco::ECOTimingCapability readyCapability()
{
  return {true, true, true, true, true, true};
}

}  // namespace

int main()
{
  try {
    const auto unsupported = ieco::evaluateTimingFacade({}, passingGuardband());
    require(unsupported.state == ieco::ECOTimingState::kUnsupported, "missing iTO primitive must be unsupported");
    require(!unsupported.ok(), "unsupported timing ECO must not pass");
    require(unsupported.experimental, "unsupported timing ECO must remain experimental");

    auto missing_route = readyCapability();
    missing_route.route_eco_primitive_ready = false;
    const auto route_blocked = ieco::evaluateTimingFacade(missing_route, passingGuardband());
    require(route_blocked.state == ieco::ECOTimingState::kUnsupported, "missing routeECO primitive must block facade");

    auto guardband = passingGuardband();
    guardband.hold_slack_ps = -1.0;
    const auto rejected = ieco::evaluateTimingFacade(readyCapability(), guardband);
    require(rejected.state == ieco::ECOTimingState::kRejected, "bad guardband must reject timing ECO");

    auto no_correlation = readyCapability();
    no_correlation.prime_time_correlation_ready = false;
    const auto experimental = ieco::evaluateTimingFacade(no_correlation, passingGuardband());
    require(experimental.state == ieco::ECOTimingState::kExperimental, "missing commercial correlation must stay experimental");
    require(!experimental.ok(), "experimental timing ECO must not pass signoff");

    const auto accepted = ieco::evaluateTimingFacade(readyCapability(), passingGuardband());
    require(accepted.ok(), "ready timing facade should accept");
    require(!accepted.experimental, "accepted timing facade should not be experimental");
    require(!accepted.would_modify_db, "timing facade contract must not directly modify DB");

    std::cout << "iECO timing contract tests passed\n";
    return 0;
  } catch (const std::exception& error) {
    std::cerr << error.what() << '\n';
    return 1;
  }
}
