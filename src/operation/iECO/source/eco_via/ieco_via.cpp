// ***************************************************************************************
// Copyright (c) 2023-2025 Peng Cheng Laboratory
// Copyright (c) 2023-2025 Institute of Computing Technology, Chinese Academy of Sciences
// Copyright (c) 2023-2025 Beijing Institute of Open Source Chip
//
// iEDA is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
// http://license.coscl.org.cn/MulanPSL2
//
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
//
// See the Mulan PSL v2 for more details.
// ***************************************************************************************
#include "ieco_via.h"

#include <iostream>

#include "ieco_dm.h"
#include "ieco_via_init.h"
#include "ieco_via_repair.h"

namespace ieco {

ECOVia::ECOVia(EcoDataManager* data_manager)
{
  _data_manager = data_manager;
}

ECOVia::~ECOVia()
{
}

void ECOVia::init()
{
  ECOViaInit via_init(_data_manager);
  via_init.initData();
}

ECOViaResult ECOVia::repair(std::string_view type)
{
  const ECOViaRequest request = parseECOViaRequest(type);
  if (request.status == ECOViaStatus::kUnsupported) {
    std::cerr << "iECO ERROR: via repair type '" << type << "' is not implemented" << std::endl;
    ECOViaResult result(request.status, 0);
    result.reason = request.reason;
    return result;
  }
  if (request.status == ECOViaStatus::kInvalidType) {
    std::cerr << "iECO ERROR: unknown via repair type '" << type << "' (expected 'shape')" << std::endl;
    ECOViaResult result(request.status, 0);
    result.reason = request.reason;
    return result;
  }

  std::cerr << "iECO ERROR: legacy via repair entry requires structured shape request and ECO oracle" << std::endl;
  return evaluateLegacyViaRequest(type);
}

ECOViaResult ECOVia::repair(ECOViaType type)
{
  ECOViaRepair via_repair(_data_manager);
  switch (type) {
    case ECOViaType::kECOViaByShape:
      return {ECOViaStatus::kSuccess, via_repair.repairByShape()};
    case ECOViaType::kECOViaByPattern:
      return {ECOViaStatus::kUnsupported, 0};
    default:
      return {ECOViaStatus::kInvalidType, 0};
  }
}

ECOViaResult ECOVia::repairShapeRequest(const std::optional<ECOViaShapeRequest>& request, const ECOViaConfig& config,
                                        const ECOOracleResult& oracle, std::string baseline_hash)
{
  return evaluateShapeRequest(request, config, oracle, std::move(baseline_hash));
}

}  // namespace ieco
