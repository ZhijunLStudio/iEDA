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

#include <optional>
#include <string>
#include <array>
#include <unordered_map>
#include <vector>

#include "PlacerDB.hh"
#include "data/Instance.hh"
#include "data/Layout.hh"
#include "data/Design.hh"

namespace ipl {

class MacroPlacer
{
 public:
  MacroPlacer() = delete;
  explicit MacroPlacer(PlacerDB* placer_db);
  MacroPlacer(const MacroPlacer&) = delete;
  MacroPlacer(MacroPlacer&&) = delete;
  ~MacroPlacer() = default;

  MacroPlacer& operator=(const MacroPlacer&) = delete;
  MacroPlacer& operator=(MacroPlacer&&) = delete;

  // Main interface
  bool runMacroPlacement();

  // Validation
  bool checkMacroLegal() const;
  double calculateMacroPackedFraction() const;
  size_t get_macro_count() const { return _macro_list.size(); }
  double get_last_constraint_cost() const { return _last_constraint_cost; }
  size_t get_last_candidate_count() const { return _last_candidate_count; }
  const std::vector<std::string>& get_last_exhibit() const { return _last_exhibit; }

 private:
  PlacerDB* _placer_db;
  std::vector<Instance*> _macro_list;
  std::vector<Instance*> _fixed_macro_list;
  std::vector<Rectangle<int32_t>> _placement_blockages;
  std::string _constraint_error;

  struct HaloExtents
  {
    int32_t left = 0;
    int32_t bottom = 0;
    int32_t right = 0;
    int32_t top = 0;
  };
  std::unordered_map<Instance*, HaloExtents> _macro_halos;
  std::unordered_map<Instance*, HaloExtents> _macro_route_halos;
  std::unordered_map<Instance*, Point<int32_t>> _macro_location_hints;
  std::unordered_map<Instance*, Orient> _macro_orient_constraints;
  std::unordered_map<Instance*, std::vector<Rectangle<int32_t>>> _macro_channel_keepouts;
  double _last_constraint_cost = 0.0;
  size_t _last_candidate_count = 0;
  std::vector<std::string> _last_exhibit;

  // Internal methods
  bool collectMacros();
  bool collectMacroRegionConstraint(const std::string& name, const std::vector<Rectangle<int32_t>>& boundaries, Design* design,
                                    std::vector<Rectangle<int32_t>>& fenced_boundaries,
                                    std::unordered_map<std::string, int32_t>& halo_counts,
                                    std::unordered_map<std::string, int32_t>& route_halo_counts,
                                    std::unordered_map<std::string, int32_t>& hint_counts,
                                    std::unordered_map<std::string, int32_t>& orient_counts);
  void initializeMacroPositions();
  bool hasOverlap(Instance* macro1, Instance* macro2) const;
  Rectangle<int32_t> expandedShape(Instance* macro) const;
  Rectangle<int32_t> expandedShapeAt(Instance* macro, int32_t center_x, int32_t center_y, Orient orient) const;
  Rectangle<int32_t> expandedShapeAt(Instance* macro, int32_t center_x, int32_t center_y) const;
  HaloExtents combinedHaloExtents(Instance* macro) const;
  std::optional<Orient> parseOrientConstraint(const std::string& orient_name) const;
  bool isOrientLegal(Instance* macro, Orient orient) const;
  double calculateHintPenalty(Instance* macro, int32_t center_x, int32_t center_y) const;
  double calculatePlacementPenalty(Instance* macro, int32_t center_x, int32_t center_y,
                                   const std::vector<Instance*>& placed_macros) const;
  double calculatePlacementPenalty(Instance* macro, int32_t center_x, int32_t center_y, Orient orient,
                                   const std::vector<Instance*>& placed_macros) const;
  double calculateOverlapArea(Instance* macro1, Instance* macro2) const;
  double calculateOverlapArea(const Rectangle<int32_t>& lhs, const Rectangle<int32_t>& rhs) const;
  double calculateConstraintCost() const;
  void buildMacroExhibit(bool legal, const std::string& rejection_reason = {});
  int64_t calculateTotalWirelength() const;
};

}  // namespace ipl
