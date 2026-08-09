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
#include <cctype>
#include <cmath>
#include <limits>
#include <sstream>

#include "Log.hh"

namespace ipl {

namespace {

auto orientToName(Orient orient) -> const char*
{
  switch (orient) {
    case Orient::kN_R0:
      return "N_R0";
    case Orient::kS_R180:
      return "S_R180";
    case Orient::kW_R90:
      return "W_R90";
    case Orient::kE_R270:
      return "E_R270";
    case Orient::kFN_MY:
      return "FN_MY";
    case Orient::kFS_MX:
      return "FS_MX";
    case Orient::kFW_MX90:
      return "FW_MX90";
    case Orient::kFE_MY90:
      return "FE_MY90";
    default:
      return "NONE";
  }
}

}  // namespace

MacroPlacer::MacroPlacer(PlacerDB* placer_db)
    : _placer_db(placer_db),
      _macro_list(),
      _fixed_macro_list(),
      _placement_blockages(),
      _macro_halos(),
      _macro_route_halos(),
      _macro_location_hints(),
      _macro_orient_constraints(),
      _macro_channel_keepouts(),
      _last_exhibit()
{
}

bool MacroPlacer::runMacroPlacement()
{
  LOG_INFO << "-----------------Start Macro Placement-----------------";

  // Step 1: Collect all macro instances
  if (!collectMacros()) {
    buildMacroExhibit(false, _constraint_error.empty() ? "invalid constraint set" : _constraint_error);
    if (!_constraint_error.empty()) {
      LOG_ERROR << _constraint_error;
    } else {
      LOG_ERROR << "Macro placement encountered an invalid constraint set.";
    }
    LOG_INFO << "-----------------Finish Macro Placement-----------------";
    return false;
  }

  if (_macro_list.empty()) {
    LOG_INFO << "No macros found in design, skipping macro placement.";
    LOG_INFO << "-----------------Finish Macro Placement-----------------";
    return true;
  }

  LOG_INFO << "Found " << _macro_list.size() << " macro instances.";

  auto transaction = _placer_db->beginStageTransaction("MacroPlacer");
  if (!transaction.active) {
    LOG_ERROR << "Macro placement cannot create a PlacerDB transaction.";
    LOG_INFO << "-----------------Finish Macro Placement-----------------";
    return false;
  }

  // Step 2: Initialize macro positions (simple center placement for now)
  initializeMacroPositions();

  _last_constraint_cost = calculateConstraintCost();
  LOG_INFO << "Macro constraint cost: " << _last_constraint_cost;

  // Step 3: Check legality
  bool is_legal = checkMacroLegal();
  buildMacroExhibit(is_legal, is_legal ? std::string{} : (_constraint_error.empty() ? std::string("illegal placement") : _constraint_error));

  if (!is_legal) {
    LOG_ERROR << "Macro placement resulted in illegal placement (overlaps detected).";
    double packed_frac = calculateMacroPackedFraction();
    LOG_ERROR << "Macro packed fraction: " << packed_frac;
    if (!_placer_db->rollbackStageTransaction(transaction)) {
      LOG_ERROR << "Macro placement failed and PlacerDB rollback also failed.";
    }
    LOG_INFO << "-----------------Finish Macro Placement-----------------";
    return false;
  }

  double packed_frac = calculateMacroPackedFraction();
  LOG_INFO << "Macro placement completed. Packed fraction: " << packed_frac;

  if (packed_frac > 0.10) {
    LOG_WARNING << "Macro packed fraction exceeds 10% threshold (" << packed_frac << ")";
  }

  if (!_placer_db->commitStageTransaction(transaction)) {
    LOG_ERROR << "Macro placement completed but PlacerDB commit failed.";
    LOG_INFO << "-----------------Finish Macro Placement-----------------";
    return false;
  }

  LOG_INFO << "-----------------Finish Macro Placement-----------------";
  return true;
}

bool MacroPlacer::collectMacros()
{
  _macro_list.clear();
  _fixed_macro_list.clear();
  _placement_blockages.clear();
  _macro_halos.clear();
  _macro_route_halos.clear();
  _macro_location_hints.clear();
  _macro_orient_constraints.clear();
  _macro_channel_keepouts.clear();
  _constraint_error.clear();
  _last_constraint_cost = 0.0;
  _last_candidate_count = 0;
  _last_exhibit.clear();

  Design* design = _placer_db->get_design();
  if (!design) {
    _constraint_error = "Design is null in MacroPlacer::collectMacros";
    return false;
  }

  for (auto* inst : design->get_instance_list()) {
    if (!inst) {
      continue;
    }

    // Check if instance is a macro
    Cell* cell = inst->get_cell_master();
    if (cell && cell->isMacro()) {
      (inst->isFixed() ? _fixed_macro_list : _macro_list).push_back(inst);
    }
  }

  std::vector<Rectangle<int32_t>> fenced_boundaries;
  std::unordered_map<std::string, int32_t> halo_counts;
  std::unordered_map<std::string, int32_t> route_halo_counts;
  std::unordered_map<std::string, int32_t> hint_counts;
  std::unordered_map<std::string, int32_t> orient_counts;
  for (auto* region : design->get_region_list()) {
    if (region == nullptr) continue;
    const auto name = region->get_name();
    const auto boundaries = region->get_boundaries();
    if (collectMacroRegionConstraint(name, boundaries, design, fenced_boundaries, halo_counts, route_halo_counts, hint_counts,
                                     orient_counts)) {
      if (!_constraint_error.empty()) {
        return false;
      }
      continue;
    }
    if (name.rfind("blockage_list", 0) == 0) {
      for (const auto& boundary : boundaries) {
        const bool duplicates_halo = std::any_of(fenced_boundaries.begin(), fenced_boundaries.end(), [&](const auto& halo) {
          return halo.get_ll_x() == boundary.get_ll_x() && halo.get_ll_y() == boundary.get_ll_y()
                 && halo.get_ur_x() == boundary.get_ur_x() && halo.get_ur_y() == boundary.get_ur_y();
        });
        if (!duplicates_halo) _placement_blockages.push_back(boundary);
      }
    }
  }
  return true;
}

bool MacroPlacer::collectMacroRegionConstraint(const std::string& name, const std::vector<Rectangle<int32_t>>& boundaries,
                                                Design* design, std::vector<Rectangle<int32_t>>& fenced_boundaries,
                                                std::unordered_map<std::string, int32_t>& halo_counts,
                                                std::unordered_map<std::string, int32_t>& route_halo_counts,
                                                std::unordered_map<std::string, int32_t>& hint_counts,
                                                std::unordered_map<std::string, int32_t>& orient_counts)
{
  constexpr const char* kHaloSuffix = "_HALO";
  constexpr const char* kRouteHaloSuffix = "_ROUTEHALO";
  constexpr const char* kHintSuffix = "_HINT";
  constexpr const char* kChannelSuffix = "_CHANNEL";
  constexpr const char* kOrientMarker = "_ORIENT_";

  const auto has_suffix = [&](const char* suffix) {
    const auto suffix_length = std::char_traits<char>::length(suffix);
    return name.size() > suffix_length && name.compare(name.size() - suffix_length, suffix_length, suffix) == 0;
  };

  const auto macro_name_from_suffix = [&](const char* suffix) {
    const auto suffix_length = std::char_traits<char>::length(suffix);
    return name.substr(0, name.size() - suffix_length);
  };

  const auto macro_from_name = [&](const std::string& macro_name) -> Instance* {
    auto* macro = design->find_instance(macro_name);
    if (macro == nullptr || macro->get_cell_master() == nullptr || !macro->get_cell_master()->isMacro()) {
      _constraint_error = "Macro constraint " + name + " references unknown macro " + macro_name;
      return nullptr;
    }
    return macro;
  };

  const auto collect_halo = [&](const char* suffix, auto& halo_map, auto& seen_counts) {
    if (!has_suffix(suffix)) {
      return false;
    }
    auto* macro = macro_from_name(macro_name_from_suffix(suffix));
    if (macro == nullptr) return true;
    if (boundaries.empty()) {
      _constraint_error = "Macro constraint " + name + " has no boundary.";
      return true;
    }
    if (++seen_counts[macro->get_name()] > 1) {
      _constraint_error = "Duplicate macro constraint " + std::string(suffix) + " for macro " + macro->get_name();
      return true;
    }

    const auto shape = macro->get_shape();
    const auto boundary = boundaries.front();
    halo_map[macro] = {.left = std::max(0, shape.get_ll_x() - boundary.get_ll_x()),
                       .bottom = std::max(0, shape.get_ll_y() - boundary.get_ll_y()),
                       .right = std::max(0, boundary.get_ur_x() - shape.get_ur_x()),
                       .top = std::max(0, boundary.get_ur_y() - shape.get_ur_y())};
    fenced_boundaries.push_back(boundary);
    return true;
  };

  if (collect_halo(kRouteHaloSuffix, _macro_route_halos, route_halo_counts)
      || collect_halo(kHaloSuffix, _macro_halos, halo_counts)) {
    return true;
  }

  if (has_suffix(kHintSuffix)) {
    auto* macro = macro_from_name(macro_name_from_suffix(kHintSuffix));
    if (macro == nullptr) return true;
    if (boundaries.empty()) {
      _constraint_error = "Macro hint constraint " + name + " has no boundary.";
      return true;
    }
    if (++hint_counts[macro->get_name()] > 1) {
      _constraint_error = "Duplicate macro hint constraint for macro " + macro->get_name();
      return true;
    }
    _macro_location_hints[macro] = boundaries.front().get_center();
    return true;
  }

  if (name.size() > std::char_traits<char>::length(kChannelSuffix)
      && name.compare(name.size() - std::char_traits<char>::length(kChannelSuffix), std::string::npos, kChannelSuffix) == 0) {
    const auto macro_name = name.substr(0, name.size() - std::char_traits<char>::length(kChannelSuffix));
    auto* macro = macro_from_name(macro_name);
    if (macro == nullptr) return true;
    if (boundaries.empty()) {
      _constraint_error = "Macro channel constraint " + name + " has no boundary.";
      return true;
    }
    for (const auto& boundary : boundaries) {
      _macro_channel_keepouts[macro].push_back(boundary);
    }
    return true;
  }

  const auto orient_pos = name.rfind(kOrientMarker);
  if (orient_pos != std::string::npos && orient_pos > 0) {
    const std::string macro_name = name.substr(0, orient_pos);
    auto* macro = design->find_instance(macro_name);
    if (macro == nullptr || macro->get_cell_master() == nullptr || !macro->get_cell_master()->isMacro()) {
      _constraint_error = "Macro orient constraint " + name + " references unknown macro " + macro_name;
      return true;
    }
    if (++orient_counts[macro_name] > 1) {
      _constraint_error = "Duplicate macro orientation constraint for macro " + macro_name;
      return true;
    }
    const std::string orient_name = name.substr(orient_pos + std::char_traits<char>::length(kOrientMarker));
    const auto orient = parseOrientConstraint(orient_name);
    if (!orient) {
      _constraint_error = "Macro orientation constraint " + name + " has unsupported orientation " + orient_name;
      return true;
    }
    _macro_orient_constraints[macro] = *orient;
    return true;
  }

  return false;
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
  if (num_macros > 1) {
    grid_cols = std::max(grid_cols, 4);
    grid_rows = std::max(grid_rows, 4);
  }

  int32_t core_width = core.get_width();
  int32_t core_height = core.get_height();
  int32_t cell_width = core_width / grid_cols;
  int32_t cell_height = core_height / grid_rows;

  std::vector<Instance*> placed_macros = _fixed_macro_list;
  for (size_t i = 0; i < _macro_list.size(); ++i) {
    Instance* macro = _macro_list[i];
    double best_penalty = std::numeric_limits<double>::infinity();
    int32_t best_center_x = core.get_ll_x() + cell_width / 2;
    int32_t best_center_y = core.get_ll_y() + cell_height / 2;
    Orient best_orient = macro->get_orient();
    const auto orient_constraint = _macro_orient_constraints.find(macro);
    const Orient candidate_orient = orient_constraint != _macro_orient_constraints.end() ? orient_constraint->second : macro->get_orient();

    for (int32_t row = 0; row < grid_rows; ++row) {
      for (int32_t col = 0; col < grid_cols; ++col) {
        const int32_t center_x = core.get_ll_x() + col * cell_width + cell_width / 2;
        const int32_t center_y = core.get_ll_y() + row * cell_height + cell_height / 2;
        const double penalty = calculatePlacementPenalty(macro, center_x, center_y, candidate_orient, placed_macros);
        ++_last_candidate_count;
        if (penalty < best_penalty) {
          best_penalty = penalty;
          best_center_x = center_x;
          best_center_y = center_y;
          best_orient = candidate_orient;
        }
      }
    }

    macro->set_orient(best_orient);
    macro->update_center_coordi(best_center_x, best_center_y);
    macro->set_instance_state(INSTANCE_STATE::kPlaced);
    placed_macros.push_back(macro);

    LOG_INFO << "Placed macro " << macro->get_name()
             << " at (" << best_center_x << ", " << best_center_y << ")"
             << " with constraint penalty " << best_penalty;
  }
}

bool MacroPlacer::checkMacroLegal() const
{
  const Layout* layout = _placer_db->get_layout();
  Rectangle<int32_t> core = layout->get_core_shape();

  // Check 1: All macros within core boundary
  for (auto* macro : _macro_list) {
    const auto orient_constraint = _macro_orient_constraints.find(macro);
    if (orient_constraint != _macro_orient_constraints.end() && macro->get_orient() != orient_constraint->second) {
      LOG_ERROR << "Macro " << macro->get_name() << " violates required orientation.";
      return false;
    }

    Rectangle<int32_t> shape = expandedShape(macro);

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

  for (auto* macro : _macro_list) {
    for (auto* fixed_macro : _fixed_macro_list) {
      if (hasOverlap(macro, fixed_macro)) {
        LOG_ERROR << "Overlap detected between movable macro " << macro->get_name() << " and fixed macro " << fixed_macro->get_name();
        return false;
      }
    }
    const auto shape = expandedShape(macro);
    for (const auto& blockage : _placement_blockages) {
      const bool x_overlap = !(shape.get_ur_x() <= blockage.get_ll_x() || blockage.get_ur_x() <= shape.get_ll_x());
      const bool y_overlap = !(shape.get_ur_y() <= blockage.get_ll_y() || blockage.get_ur_y() <= shape.get_ll_y());
      if (x_overlap && y_overlap) {
        LOG_ERROR << "Macro " << macro->get_name() << " overlaps a placement blockage.";
        return false;
      }
    }
    const auto channel_keepouts = _macro_channel_keepouts.find(macro);
    if (channel_keepouts != _macro_channel_keepouts.end()) {
      for (const auto& channel : channel_keepouts->second) {
        const bool x_overlap = !(shape.get_ur_x() <= channel.get_ll_x() || channel.get_ur_x() <= shape.get_ll_x());
        const bool y_overlap = !(shape.get_ur_y() <= channel.get_ll_y() || channel.get_ur_y() <= shape.get_ll_y());
        if (x_overlap && y_overlap) {
          LOG_ERROR << "Macro " << macro->get_name() << " overlaps a macro channel keepout.";
          return false;
        }
      }
    }
  }

  return true;
}

Rectangle<int32_t> MacroPlacer::expandedShape(Instance* macro) const
{
  const auto shape = macro->get_shape();
  const auto halo = combinedHaloExtents(macro);
  return Rectangle<int32_t>(shape.get_ll_x() - halo.left, shape.get_ll_y() - halo.bottom, shape.get_ur_x() + halo.right,
                            shape.get_ur_y() + halo.top);
}

Rectangle<int32_t> MacroPlacer::expandedShapeAt(Instance* macro, int32_t center_x, int32_t center_y) const
{
  return expandedShapeAt(macro, center_x, center_y, macro->get_orient());
}

Rectangle<int32_t> MacroPlacer::expandedShapeAt(Instance* macro, int32_t center_x, int32_t center_y, Orient orient) const
{
  const auto shape = macro->get_shape();
  const auto halo = combinedHaloExtents(macro);
  int32_t width = shape.get_width();
  int32_t height = shape.get_height();
  if (orient == Orient::kW_R90 || orient == Orient::kE_R270 || orient == Orient::kFW_MX90 || orient == Orient::kFE_MY90) {
    std::swap(width, height);
  }
  const int32_t half_width = width / 2;
  const int32_t half_height = height / 2;
  return Rectangle<int32_t>(center_x - half_width - halo.left, center_y - half_height - halo.bottom,
                            center_x + (width - half_width) + halo.right,
                            center_y + (height - half_height) + halo.top);
}

MacroPlacer::HaloExtents MacroPlacer::combinedHaloExtents(Instance* macro) const
{
  HaloExtents result;
  const auto merge = [&](const auto& halo_map) {
    const auto found = halo_map.find(macro);
    if (found == halo_map.end()) return;
    result.left = std::max(result.left, found->second.left);
    result.bottom = std::max(result.bottom, found->second.bottom);
    result.right = std::max(result.right, found->second.right);
    result.top = std::max(result.top, found->second.top);
  };
  merge(_macro_halos);
  merge(_macro_route_halos);
  return result;
}

std::optional<Orient> MacroPlacer::parseOrientConstraint(const std::string& orient_name) const
{
  std::string upper;
  upper.reserve(orient_name.size());
  for (const auto ch : orient_name) {
    upper.push_back(static_cast<char>(std::toupper(static_cast<unsigned char>(ch))));
  }

  if (upper == "N" || upper == "R0" || upper == "N_R0") return Orient::kN_R0;
  if (upper == "W" || upper == "R90" || upper == "W_R90") return Orient::kW_R90;
  if (upper == "S" || upper == "R180" || upper == "S_R180") return Orient::kS_R180;
  if (upper == "E" || upper == "R270" || upper == "E_R270") return Orient::kE_R270;
  if (upper == "FN" || upper == "MY" || upper == "FN_MY") return Orient::kFN_MY;
  if (upper == "FS" || upper == "MX" || upper == "FS_MX") return Orient::kFS_MX;
  if (upper == "FW" || upper == "MX90" || upper == "FW_MX90") return Orient::kFW_MX90;
  if (upper == "FE" || upper == "MY90" || upper == "FE_MY90") return Orient::kFE_MY90;
  return std::nullopt;
}

bool MacroPlacer::isOrientLegal(Instance* macro, Orient orient) const
{
  const auto found = _macro_orient_constraints.find(macro);
  return found == _macro_orient_constraints.end() || found->second == orient;
}

double MacroPlacer::calculateHintPenalty(Instance* macro, int32_t center_x, int32_t center_y) const
{
  const auto found = _macro_location_hints.find(macro);
  if (found == _macro_location_hints.end()) {
    return 0.0;
  }

  const Layout* layout = _placer_db->get_layout();
  const auto core = layout->get_core_shape();
  const double core_span = static_cast<double>(std::max(core.get_width(), core.get_height()));
  const double dx = static_cast<double>(center_x - found->second.get_x());
  const double dy = static_cast<double>(center_y - found->second.get_y());
  const double distance = std::sqrt(dx * dx + dy * dy);
  return core_span > 0.0 ? distance / core_span : distance;
}

double MacroPlacer::calculatePlacementPenalty(Instance* macro, int32_t center_x, int32_t center_y,
                                               const std::vector<Instance*>& placed_macros) const
{
  return calculatePlacementPenalty(macro, center_x, center_y, macro->get_orient(), placed_macros);
}

double MacroPlacer::calculatePlacementPenalty(Instance* macro, int32_t center_x, int32_t center_y, Orient orient,
                                               const std::vector<Instance*>& placed_macros) const
{
  const Layout* layout = _placer_db->get_layout();
  const auto candidate = expandedShapeAt(macro, center_x, center_y, orient);
  const auto core = layout->get_core_shape();
  double penalty = 0.0;

  if (!isOrientLegal(macro, orient)) {
    penalty += 1.0e18;
  }
  for (auto* placed : placed_macros) {
    if (placed != macro) penalty += calculateOverlapArea(candidate, expandedShape(placed));
  }
  for (const auto& blockage : _placement_blockages) {
    penalty += 2.0 * calculateOverlapArea(candidate, blockage);
  }
  const auto channel_keepouts = _macro_channel_keepouts.find(macro);
  if (channel_keepouts != _macro_channel_keepouts.end()) {
    for (const auto& channel : channel_keepouts->second) {
      penalty += 3.0 * calculateOverlapArea(candidate, channel);
    }
  }

  const int32_t core_ll_x = core.get_ll_x();
  const int32_t core_ll_y = core.get_ll_y();
  const int32_t core_ur_x = core.get_ur_x();
  const int32_t core_ur_y = core.get_ur_y();
  const int64_t candidate_area = static_cast<int64_t>(candidate.get_width()) * candidate.get_height();
  const int32_t ix = std::max(core_ll_x, candidate.get_ll_x());
  const int32_t iy = std::max(core_ll_y, candidate.get_ll_y());
  const int32_t ux = std::min(core_ur_x, candidate.get_ur_x());
  const int32_t uy = std::min(core_ur_y, candidate.get_ur_y());
  const int64_t inside_area = ux > ix && uy > iy ? static_cast<int64_t>(ux - ix) * (uy - iy) : 0;
  penalty += 4.0 * static_cast<double>(std::max<int64_t>(0, candidate_area - inside_area));
  penalty += calculateHintPenalty(macro, center_x, center_y);
  return penalty;
}

double MacroPlacer::calculateOverlapArea(const Rectangle<int32_t>& lhs, const Rectangle<int32_t>& rhs) const
{
  const int32_t x_overlap = std::max(0, std::min(lhs.get_ur_x(), rhs.get_ur_x()) - std::max(lhs.get_ll_x(), rhs.get_ll_x()));
  const int32_t y_overlap = std::max(0, std::min(lhs.get_ur_y(), rhs.get_ur_y()) - std::max(lhs.get_ll_y(), rhs.get_ll_y()));
  return static_cast<double>(x_overlap) * y_overlap;
}

double MacroPlacer::calculateConstraintCost() const
{
  const Layout* layout = _placer_db->get_layout();
  const auto core = layout->get_core_shape();
  const double core_area = static_cast<double>(core.get_width()) * core.get_height();
  double cost = 0.0;

  for (auto* macro : _macro_list) {
    const auto shape = macro->get_shape();
    const auto expanded = expandedShape(macro);
    const double constraint_area = calculateOverlapArea(expanded, expanded) - calculateOverlapArea(shape, shape);
    cost += core_area > 0.0 ? constraint_area / core_area : constraint_area;
    cost += calculatePlacementPenalty(macro, shape.get_center().get_x(), shape.get_center().get_y(), {});
  }
  return cost;
}

bool MacroPlacer::hasOverlap(Instance* macro1, Instance* macro2) const
{
  Rectangle<int32_t> r1 = expandedShape(macro1);
  Rectangle<int32_t> r2 = expandedShape(macro2);

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

void MacroPlacer::buildMacroExhibit(bool legal, const std::string& rejection_reason)
{
  _last_exhibit.clear();
  _last_exhibit.push_back("macro_count=" + std::to_string(_macro_list.size()));
  _last_exhibit.push_back("fixed_macro_count=" + std::to_string(_fixed_macro_list.size()));
  _last_exhibit.push_back("candidate_count=" + std::to_string(_last_candidate_count));
  _last_exhibit.push_back("constraint_cost=" + std::to_string(_last_constraint_cost));
  _last_exhibit.push_back(std::string("legal=") + (legal ? "true" : "false"));
  if (!rejection_reason.empty()) {
    _last_exhibit.push_back("rejection_reason=" + rejection_reason);
  }
  std::vector<Instance*> placed_macros = _fixed_macro_list;
  placed_macros.insert(placed_macros.end(), _macro_list.begin(), _macro_list.end());
  for (auto* macro : _macro_list) {
    if (macro == nullptr) {
      continue;
    }
    const auto center = macro->get_center_coordi();
    const auto orient = macro->get_orient();
    const auto halo = combinedHaloExtents(macro);
    const auto route_halo = _macro_route_halos.find(macro);
    const auto hint = _macro_location_hints.find(macro);
    const auto channel = _macro_channel_keepouts.find(macro);
    const double penalty = calculatePlacementPenalty(macro, center.get_x(), center.get_y(), orient, placed_macros);

    std::ostringstream stream;
    stream << macro->get_name() << " candidate=(" << center.get_x() << ',' << center.get_y() << ')'
           << " orient=" << orientToName(orient)
           << " cost=" << penalty
           << " halo=" << halo.left << '/' << halo.bottom << '/' << halo.right << '/' << halo.top
           << " route_halo=" << (route_halo != _macro_route_halos.end() ? 1 : 0)
           << " hint=" << (hint != _macro_location_hints.end() ? 1 : 0)
           << " channel_keepouts=" << (channel != _macro_channel_keepouts.end() ? channel->second.size() : 0);
    _last_exhibit.push_back(stream.str());
  }
}

}  // namespace ipl
