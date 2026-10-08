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

#include <cmath>
#include <cstdint>
#include <limits>
#include <optional>

namespace ifp {

struct FloorplanBox
{
  int32_t low_x = 0;
  int32_t low_y = 0;
  int32_t high_x = 0;
  int32_t high_y = 0;
};

struct PinPitch
{
  int32_t horizontal = 0;
  int32_t vertical = 0;
};

inline bool isValidCoordinateBox(double low_x, double low_y, double high_x, double high_y)
{
  return std::isfinite(low_x) && std::isfinite(low_y) && std::isfinite(high_x) && std::isfinite(high_y) && low_x < high_x
         && low_y < high_y;
}

inline bool isValidFloorplanBox(const FloorplanBox& box)
{
  return box.low_x < box.high_x && box.low_y < box.high_y;
}

inline bool containsBox(const FloorplanBox& outer, const FloorplanBox& inner)
{
  return isValidFloorplanBox(outer) && isValidFloorplanBox(inner) && outer.low_x <= inner.low_x && outer.low_y <= inner.low_y
         && outer.high_x >= inner.high_x && outer.high_y >= inner.high_y;
}

inline bool intersectsClosed(const FloorplanBox& lhs, const FloorplanBox& rhs)
{
  return !(lhs.high_y < rhs.low_y || lhs.low_y > rhs.high_y || lhs.low_x > rhs.high_x || lhs.high_x < rhs.low_x);
}

inline std::optional<PinPitch> makePinPitch(int32_t core_width, int32_t core_height, int32_t edge_count,
                                            int32_t manufacturing_grid)
{
  if (core_width <= 0 || core_height <= 0 || edge_count < 0 || manufacturing_grid <= 0
      || edge_count == std::numeric_limits<int32_t>::max()) {
    return std::nullopt;
  }

  const int32_t denominator = edge_count + 1;
  const int32_t horizontal = (core_width / denominator / manufacturing_grid) * manufacturing_grid;
  const int32_t vertical = (core_height / denominator / manufacturing_grid) * manufacturing_grid;
  if (horizontal <= 0 || vertical <= 0) {
    return std::nullopt;
  }

  return PinPitch{.horizontal = horizontal, .vertical = vertical};
}

}  // namespace ifp
