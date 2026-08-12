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
#pragma once
#include <cstdint>
#include <optional>
#include <set>
#include <string>
#include <string_view>
#include <vector>

namespace ieco {
enum ECOViaType
{
  kECONone = 0,
  kECOViaByShape = 1,
  kECOViaByPattern = 2,
  kECOViaMax
};

inline constexpr std::string_view kEcoRepairViaByShape = "shape";
inline constexpr std::string_view kEcoRepairViaByPattern = "pattern";

enum class ECOViaStatus
{
  kSuccess,
  kUnsupported,
  kInvalidType,
  kRejected,
  kFailed,
  kRolledBack
};

enum class ECORequestState
{
  kAccepted,
  kRejected,
  kUnsupported,
  kFailed,
  kRolledBack
};

struct ECORect
{
  int32_t lx = 0;
  int32_t ly = 0;
  int32_t ux = 0;
  int32_t uy = 0;
};

struct ECOViaShapeRequest
{
  std::string layer;
  ECORect bbox;
  std::string net;
  std::string shape_id;
};

struct ECOOracleResult
{
  int local_drc_before = 0;
  int local_drc_after = 0;
  bool connectivity_ok = true;
  bool route_legal = true;
  [[nodiscard]] bool improved() const { return local_drc_after < local_drc_before; }
  [[nodiscard]] bool ok() const { return improved() && connectivity_ok && route_legal; }
};

struct ECOViaRequest
{
  ECOViaStatus status = ECOViaStatus::kInvalidType;
  ECOViaType type = ECOViaType::kECONone;
  ECORequestState state = ECORequestState::kRejected;
  std::string reason;
};

struct ECOViaResult
{
  ECOViaStatus status = ECOViaStatus::kInvalidType;
  ECORequestState state = ECORequestState::kRejected;
  int repaired_count = 0;
  int changed_shape_count = 0;
  int via_count = 0;
  ECOOracleResult oracle;
  std::vector<ECOViaShapeRequest> changed_shapes;
  std::set<std::string> affected_nets;
  std::string baseline_hash;
  std::string committed_hash;
  std::string rollback_hash;
  std::string reason;

  ECOViaResult() = default;
  ECOViaResult(ECOViaStatus input_status, int input_repaired_count)
      : status(input_status), state(input_status == ECOViaStatus::kSuccess ? ECORequestState::kAccepted : ECORequestState::kFailed),
        repaired_count(input_repaired_count)
  {
    if (input_status == ECOViaStatus::kUnsupported) {
      state = ECORequestState::kUnsupported;
    } else if (input_status == ECOViaStatus::kInvalidType || input_status == ECOViaStatus::kRejected) {
      state = ECORequestState::kRejected;
    } else if (input_status == ECOViaStatus::kRolledBack) {
      state = ECORequestState::kRolledBack;
    }
  }

  [[nodiscard]] bool ok() const { return status == ECOViaStatus::kSuccess; }
  [[nodiscard]] bool rolledBack() const { return state == ECORequestState::kRolledBack; }
};

[[nodiscard]] inline ECOViaRequest parseECOViaRequest(std::string_view type)
{
  if (type == kEcoRepairViaByShape) {
    return {ECOViaStatus::kSuccess, ECOViaType::kECOViaByShape, ECORequestState::kAccepted, ""};
  }
  if (type == kEcoRepairViaByPattern) {
    return {ECOViaStatus::kUnsupported, ECOViaType::kECOViaByPattern, ECORequestState::kUnsupported, "pattern via ECO is not implemented"};
  }
  return {ECOViaStatus::kInvalidType, ECOViaType::kECONone, ECORequestState::kRejected, "unknown via ECO request type"};
}

struct ECOViaConfig
{
  std::set<std::string> freeze_layers;
  std::set<std::string> eco_layers;
};

[[nodiscard]] std::string toString(ECOViaStatus status);
[[nodiscard]] std::string toString(ECORequestState state);
[[nodiscard]] ECOViaResult evaluateShapeRequest(const std::optional<ECOViaShapeRequest>& request, const ECOViaConfig& config,
                                                const ECOOracleResult& oracle, std::string baseline_hash);
[[nodiscard]] std::string ecoViaReportJson(const ECOViaResult& result);
[[nodiscard]] bool writeEcoViaReportJson(const ECOViaResult& result, const std::string& path);

class EcoDataManager;

class ECOVia
{
 public:
  ECOVia(EcoDataManager* data_manager);
  ~ECOVia();

  void init();
  [[nodiscard]] ECOViaResult repair(std::string_view type);
  [[nodiscard]] ECOViaResult repairShapeRequest(const std::optional<ECOViaShapeRequest>& request, const ECOViaConfig& config,
                                                const ECOOracleResult& oracle, std::string baseline_hash);

 private:
  EcoDataManager* _data_manager;
  ECOViaResult repair(ECOViaType type);
};

}  // namespace ieco
