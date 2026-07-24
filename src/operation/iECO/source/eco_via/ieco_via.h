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
#include <string>
#include <string_view>

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
  kInvalidType
};

struct ECOViaRequest
{
  ECOViaStatus status = ECOViaStatus::kInvalidType;
  ECOViaType type = ECOViaType::kECONone;
};

struct ECOViaResult
{
  ECOViaStatus status = ECOViaStatus::kInvalidType;
  int repaired_count = 0;

  [[nodiscard]] bool ok() const { return status == ECOViaStatus::kSuccess; }
};

[[nodiscard]] inline ECOViaRequest parseECOViaRequest(std::string_view type)
{
  if (type == kEcoRepairViaByShape) {
    return {ECOViaStatus::kSuccess, ECOViaType::kECOViaByShape};
  }
  if (type == kEcoRepairViaByPattern) {
    return {ECOViaStatus::kUnsupported, ECOViaType::kECOViaByPattern};
  }
  return {ECOViaStatus::kInvalidType, ECOViaType::kECONone};
}

class EcoDataManager;

class ECOVia
{
 public:
  ECOVia(EcoDataManager* data_manager);
  ~ECOVia();

  void init();
  [[nodiscard]] ECOViaResult repair(std::string_view type);

 private:
  EcoDataManager* _data_manager;
  ECOViaResult repair(ECOViaType type);
};

}  // namespace ieco
