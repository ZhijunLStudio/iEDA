#include "ieco_timing.h"

#include <fstream>
#include <iostream>
#include <iterator>
#include <stdexcept>
#include <string>

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

std::string readFile(const std::string& path)
{
  std::ifstream input(path);
  return {std::istreambuf_iterator<char>(input), std::istreambuf_iterator<char>()};
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
    const std::string experimental_json = ieco::ecoTimingReportJson(experimental);
    require(experimental_json.find("\"schema_version\": \"ieda.eco.timing_report.v1\"") != std::string::npos,
            "timing report schema missing");
    require(experimental_json.find("\"state\": \"experimental\"") != std::string::npos, "experimental state missing from report");
    require(experimental_json.find("\"prime_time_correlation_ready\": false") != std::string::npos,
            "commercial correlation capability missing");

    const auto accepted = ieco::evaluateTimingFacade(readyCapability(), passingGuardband());
    require(accepted.ok(), "ready timing facade should accept");
    require(!accepted.experimental, "accepted timing facade should not be experimental");
    require(!accepted.would_modify_db, "timing facade contract must not directly modify DB");
    const std::string accepted_json = ieco::ecoTimingReportJson(accepted);
    require(accepted_json.find("\"setup_slack_ps\": 1.0") != std::string::npos, "setup guardband missing from report");
    require(accepted_json.find("\"would_modify_db\": false") != std::string::npos, "DB mutation proof missing from report");
    require(ieco::writeEcoTimingReportJson(accepted, "/tmp/eco_timing_report.json"), "eco_timing_report.json write failed");
    require(readFile("/tmp/eco_timing_report.json").find("\"schema_version\": \"ieda.eco.timing_report.v1\"") != std::string::npos,
            "eco_timing_report.json schema missing");

    std::cout << "iECO timing contract tests passed\n";
    return 0;
  } catch (const std::exception& error) {
    std::cerr << error.what() << '\n';
    return 1;
  }
}
