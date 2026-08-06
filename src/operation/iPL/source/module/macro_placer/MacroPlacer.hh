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

#include <vector>
#include <string>

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

 private:
  PlacerDB* _placer_db;
  std::vector<Instance*> _macro_list;

  // Internal methods
  void collectMacros();
  void initializeMacroPositions();
  bool hasOverlap(Instance* macro1, Instance* macro2) const;
  double calculateOverlapArea(Instance* macro1, Instance* macro2) const;
  int64_t calculateTotalWirelength() const;
};

}  // namespace ipl
