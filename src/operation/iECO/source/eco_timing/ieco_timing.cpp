// ***************************************************************************************
// Copyright (c) 2023-2025 Peng Cheng Laboratory
// Copyright (c) 2023-2025 Institute of Computing Technology, Chinese Academy of Sciences
// Copyright (c) 2023-2025 Beijing Institute of Open Source Chip
//
// iEDA is licensed under Mulan PSL v2.
// ***************************************************************************************
#include "ieco_timing.h"

namespace ieco {

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

}  // namespace ieco
