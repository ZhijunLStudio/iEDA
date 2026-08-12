// ***************************************************************************************
// Copyright (c) 2023-2025 Peng Cheng Laboratory
// Copyright (c) 2023-2025 Institute of Computing Technology, Chinese Academy of Sciences
// Copyright (c) 2023-2025 Beijing Institute of Open Source Chip
//
// iEDA is licensed under Mulan PSL v2.
// ***************************************************************************************
#include "ieco_timing.h"

#include <fstream>

#include "json/json.hpp"

namespace ieco {
namespace {

auto capabilityToJson(const ECOTimingCapability& capability) -> nlohmann::ordered_json
{
  return {{"ito_primitive_ready", capability.ito_primitive_ready},
          {"route_eco_primitive_ready", capability.route_eco_primitive_ready},
          {"platform_transaction_ready", capability.platform_transaction_ready},
          {"local_oracle_ready", capability.local_oracle_ready},
          {"full_oracle_ready", capability.full_oracle_ready},
          {"prime_time_correlation_ready", capability.prime_time_correlation_ready}};
}

auto guardbandToJson(const ECOTimingGuardband& guardband) -> nlohmann::ordered_json
{
  return {{"setup_slack_ps", guardband.setup_slack_ps},
          {"hold_slack_ps", guardband.hold_slack_ps},
          {"drv_margin", guardband.drv_margin},
          {"area_delta_ratio", guardband.area_delta_ratio},
          {"power_delta_ratio", guardband.power_delta_ratio},
          {"congestion_delta_ratio", guardband.congestion_delta_ratio},
          {"legality_ok", guardband.legality_ok},
          {"ok", guardband.ok()}};
}

}  // namespace

bool ECOTimingGuardband::ok() const
{
  return setup_slack_ps >= 0.0 && hold_slack_ps >= 0.0 && drv_margin >= 0.0 && area_delta_ratio <= 0.0 && power_delta_ratio <= 0.0
         && congestion_delta_ratio <= 0.0 && legality_ok;
}

std::string toString(ECOTimingState state)
{
  switch (state) {
    case ECOTimingState::kAccepted:
      return "accepted";
    case ECOTimingState::kRejected:
      return "rejected";
    case ECOTimingState::kUnsupported:
      return "unsupported";
    case ECOTimingState::kExperimental:
      return "experimental";
  }
  return "experimental";
}

ECOTimingResult evaluateTimingFacade(const ECOTimingCapability& capability, const ECOTimingGuardband& guardband,
                                     bool commercial_correlation_required)
{
  ECOTimingResult result;
  result.capability = capability;
  result.guardband = guardband;

  if (!capability.ito_primitive_ready) {
    result.state = ECOTimingState::kUnsupported;
    result.reason = "iTO timing ECO primitive is not ready";
    return result;
  }
  if (!capability.route_eco_primitive_ready || !capability.platform_transaction_ready) {
    result.state = ECOTimingState::kUnsupported;
    result.reason = "routeECO/platform transaction primitive is not ready";
    return result;
  }
  if (!capability.local_oracle_ready || !capability.full_oracle_ready) {
    result.state = ECOTimingState::kUnsupported;
    result.reason = "local/full oracle primitive is not ready";
    return result;
  }
  if (!guardband.ok()) {
    result.state = ECOTimingState::kRejected;
    result.reason = "timing ECO guardband failed";
    return result;
  }
  if (commercial_correlation_required && !capability.prime_time_correlation_ready) {
    result.state = ECOTimingState::kExperimental;
    result.reason = "PrimeTime/commercial ECO correlation is not ready";
    return result;
  }

  result.state = ECOTimingState::kAccepted;
  result.experimental = false;
  result.reason = "timing ECO facade accepted";
  return result;
}

std::string ecoTimingReportJson(const ECOTimingResult& result)
{
  const nlohmann::ordered_json json = {{"schema_version", "ieda.eco.timing_report.v1"},
                                      {"state", toString(result.state)},
                                      {"ok", result.ok()},
                                      {"experimental", result.experimental},
                                      {"would_modify_db", result.would_modify_db},
                                      {"reason", result.reason},
                                      {"capability", capabilityToJson(result.capability)},
                                      {"guardband", guardbandToJson(result.guardband)}};
  return json.dump(2);
}

bool writeEcoTimingReportJson(const ECOTimingResult& result, const std::string& path)
{
  std::ofstream output(path, std::ios::trunc);
  if (!output.is_open()) {
    return false;
  }
  output << ecoTimingReportJson(result) << '\n';
  return static_cast<bool>(output);
}

}  // namespace ieco
