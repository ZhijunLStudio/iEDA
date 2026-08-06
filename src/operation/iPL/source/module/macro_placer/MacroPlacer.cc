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
#include "MacroPlacer.hh"

#include <algorithm>
#include <cmath>

#include "Log.hh"

namespace ipl {

MacroPlacer::MacroPlacer(PlacerDB* placer_db) : _placer_db(placer_db), _macro_list()
{
}

bool MacroPlacer::runMacroPlacement()
{
  LOG_INFO << "-----------------Start Macro Placement-----------------";

  // Step 1: Collect all macro instances
  collectMacros();

  if (_macro_list.empty()) {
    LOG_INFO << "No macros found in design, skipping macro placement.";
    LOG_INFO << "-----------------Finish Macro Placement-----------------";
    return true;
  }

  LOG_INFO << "Found " << _macro_list.size() << " macro instances.";

  // Step 2: Initialize macro positions (simple center placement for now)
  initializeMacroPositions();

  // Step 3: Check legality
  bool is_legal = checkMacroLegal();

  if (!is_legal) {
    LOG_ERROR << "Macro placement resulted in illegal placement (overlaps detected).";
    double packed_frac = calculateMacroPackedFraction();
    LOG_ERROR << "Macro packed fraction: " << packed_frac;
    LOG_INFO << "-----------------Finish Macro Placement-----------------";
    return false;
  }

  double packed_frac = calculateMacroPackedFraction();
  LOG_INFO << "Macro placement completed. Packed fraction: " << packed_frac;

  if (packed_frac > 0.10) {
    LOG_WARNING << "Macro packed fraction exceeds 10% threshold (" << packed_frac << ")";
  }

  LOG_INFO << "-----------------Finish Macro Placement-----------------";
  return true;
}

void MacroPlacer::collectMacros()
{
  _macro_list.clear();

  Design* design = _placer_db->get_design();
  if (!design) {
    LOG_ERROR << "Design is null in MacroPlacer::collectMacros";
    return;
  }

  for (auto* inst : design->get_instance_list()) {
    if (!inst) {
      continue;
    }

    // Check if instance is a macro
    Cell* cell = inst->get_cell_master();
    if (cell && cell->isMacro()) {
      // Only place unfixed macros
      if (!inst->isFixed()) {
        _macro_list.push_back(inst);
      }
    }
  }
}

void MacroPlacer::initializeMacroPositions()
{
  if (_macro_list.empty()) {
    return;
  }

  const Layout* layout = _placer_db->get_layout();
  Rectangle<int32_t> core = layout->get_core_shape();

  // Simple grid-based initial placement
  int32_t num_macros = static_cast<int32_t>(_macro_list.size());
  int32_t grid_cols = static_cast<int32_t>(std::ceil(std::sqrt(num_macros)));
  int32_t grid_rows = static_cast<int32_t>(std::ceil(static_cast<double>(num_macros) / grid_cols));

  int32_t core_width = core.get_width();
  int32_t core_height = core.get_height();
  int32_t cell_width = core_width / grid_cols;
  int32_t cell_height = core_height / grid_rows;

  for (size_t i = 0; i < _macro_list.size(); ++i) {
    Instance* macro = _macro_list[i];

    int32_t row = static_cast<int32_t>(i) / grid_cols;
    int32_t col = static_cast<int32_t>(i) % grid_cols;

    // Place at grid cell center
    int32_t center_x = core.get_ll_x() + col * cell_width + cell_width / 2;
    int32_t center_y = core.get_ll_y() + row * cell_height + cell_height / 2;

    macro->update_center_coordi(center_x, center_y);
    macro->set_instance_state(INSTANCE_STATE::kPlaced);

    LOG_INFO << "Placed macro " << macro->get_name()
             << " at (" << center_x << ", " << center_y << ")";
  }
}

bool MacroPlacer::checkMacroLegal() const
{
  const Layout* layout = _placer_db->get_layout();
  Rectangle<int32_t> core = layout->get_core_shape();

  // Check 1: All macros within core boundary
  for (auto* macro : _macro_list) {
    Rectangle<int32_t> shape = macro->get_shape();

    if (shape.get_ll_x() < core.get_ll_x() || shape.get_ll_y() < core.get_ll_y() ||
        shape.get_ur_x() > core.get_ur_x() || shape.get_ur_y() > core.get_ur_y()) {
      LOG_ERROR << "Macro " << macro->get_name() << " is outside core boundary.";
      return false;
    }
  }

  // Check 2: No overlaps between macros
  for (size_t i = 0; i < _macro_list.size(); ++i) {
    for (size_t j = i + 1; j < _macro_list.size(); ++j) {
      if (hasOverlap(_macro_list[i], _macro_list[j])) {
        LOG_ERROR << "Overlap detected between macros: "
                  << _macro_list[i]->get_name() << " and "
                  << _macro_list[j]->get_name();
        return false;
      }
    }
  }

  return true;
}

bool MacroPlacer::hasOverlap(Instance* macro1, Instance* macro2) const
{
  Rectangle<int32_t> r1 = macro1->get_shape();
  Rectangle<int32_t> r2 = macro2->get_shape();

  // Check if rectangles overlap
  bool x_overlap = !(r1.get_ur_x() <= r2.get_ll_x() || r2.get_ur_x() <= r1.get_ll_x());
  bool y_overlap = !(r1.get_ur_y() <= r2.get_ll_y() || r2.get_ur_y() <= r1.get_ll_y());

  return x_overlap && y_overlap;
}

double MacroPlacer::calculateOverlapArea(Instance* macro1, Instance* macro2) const
{
  Rectangle<int32_t> r1 = macro1->get_shape();
  Rectangle<int32_t> r2 = macro2->get_shape();

  int32_t x_overlap = std::max(0, std::min(r1.get_ur_x(), r2.get_ur_x()) - std::max(r1.get_ll_x(), r2.get_ll_x()));
  int32_t y_overlap = std::max(0, std::min(r1.get_ur_y(), r2.get_ur_y()) - std::max(r1.get_ll_y(), r2.get_ll_y()));

  return static_cast<double>(x_overlap) * static_cast<double>(y_overlap);
}

double MacroPlacer::calculateMacroPackedFraction() const
{
  if (_macro_list.empty()) {
    return 0.0;
  }

  // Calculate total overlap area
  double total_overlap = 0.0;
  for (size_t i = 0; i < _macro_list.size(); ++i) {
    for (size_t j = i + 1; j < _macro_list.size(); ++j) {
      total_overlap += calculateOverlapArea(_macro_list[i], _macro_list[j]);
    }
  }

  // Calculate total macro area
  double total_macro_area = 0.0;
  for (auto* macro : _macro_list) {
    Rectangle<int32_t> shape = macro->get_shape();
    total_macro_area += static_cast<double>(shape.get_width()) * static_cast<double>(shape.get_height());
  }

  if (total_macro_area == 0.0) {
    return 0.0;
  }

  // Packed fraction = overlap_area / total_macro_area
  return total_overlap / total_macro_area;
}

int64_t MacroPlacer::calculateTotalWirelength() const
{
  // Placeholder for wirelength calculation
  // Will be implemented when integrating force-directed placement
  return 0;
}

}  // namespace ipl
