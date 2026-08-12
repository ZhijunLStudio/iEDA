// ***************************************************************************************
// Copyright (c) 2023-2025 Peng Cheng Laboratory
// Copyright (c) 2023-2025 Institute of Computing Technology, Chinese Academy of Sciences
// Copyright (c) 2023-2025 Beijing Institute of Open Source Chip
//
// iEDA is licensed under Mulan PSL v2.
// ***************************************************************************************
#pragma once

#include <string>

namespace ieco {

enum class ECOTimingState
{
  kAccepted,
  kRejected,
  kUnsupported,
  kExperimental
};

struct ECOTimingCapability
{
  bool ito_primitive_ready = false;
  bool route_eco_primitive_ready = false;
  bool platform_transaction_ready = false;
  bool local_oracle_ready = false;
  bool full_oracle_ready = false;
  bool prime_time_correlation_ready = false;
};

struct ECOTimingGuardband
{
  double setup_slack_ps = 0.0;
  double hold_slack_ps = 0.0;
  double drv_margin = 0.0;
  double area_delta_ratio = 0.0;
  double power_delta_ratio = 0.0;
  double congestion_delta_ratio = 0.0;
  bool legality_ok = false;

  [[nodiscard]] bool ok() const;
};

struct ECOTimingResult
{
  ECOTimingState state = ECOTimingState::kExperimental;
  ECOTimingCapability capability;
  ECOTimingGuardband guardband;
  bool experimental = true;
  bool would_modify_db = false;
  std::string reason;

  [[nodiscard]] bool ok() const { return state == ECOTimingState::kAccepted && !experimental && !would_modify_db; }
};

[[nodiscard]] std::string toString(ECOTimingState state);
[[nodiscard]] ECOTimingResult evaluateTimingFacade(const ECOTimingCapability& capability, const ECOTimingGuardband& guardband,
                                                   bool commercial_correlation_required = true);
[[nodiscard]] std::string ecoTimingReportJson(const ECOTimingResult& result);
[[nodiscard]] bool writeEcoTimingReportJson(const ECOTimingResult& result, const std::string& path);

}  // namespace ieco
