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

#include <cstdlib>
#include <iostream>
#include <string>

#include "MacroPlacer.hh"

#ifndef IPL_TEST_CONFIG_PATH
#define IPL_TEST_CONFIG_PATH "/home/lxq/AiEDA/iEDA.ai/benchmarks/designs/aes_nangate45_a/workspace/iEDA_config/pl_default_config.json"
#endif

namespace {

using namespace ipl;

enum class FixtureCase
{
  kRouteHalo,
  kInfeasibleRouteHalo,
  kFixedMacroConflict,
  kBlockageConflict,
  kRouteHaloOffAB,
  kRouteHaloOnAB,
  kRouteHaloWideAB,
  kUnknownRouteHalo,
  kDuplicateRouteHalo,
  kHintRight,
  kChannelConflict,
  kOrientConstraint
};

auto require(bool condition, const char* message) -> bool
{
  if (!condition) {
    std::cerr << "[FAIL] " << message << '\n';
  } else {
    std::cout << "[PASS] " << message << '\n';
  }
  return condition;
}

class FixtureWrapper final : public DBWrapper
{
 public:
  explicit FixtureWrapper(FixtureCase fixture_case = FixtureCase::kRouteHalo)
  {
    _layout.set_die_shape(Rectangle<int32_t>(0, 0, 1000, 1000));
    _layout.set_core_shape(Rectangle<int32_t>(0, 0, 1000, 1000));

    auto* row = new Row("ROW0");
    auto* site = new Site("SITE");
    site->set_width(10);
    site->set_height(10);
    row->set_site(site);
    row->set_shape(Rectangle<int32_t>(0, 0, 1000, 10));
    row->set_site_num(100);
    _layout.add_row(row);

    auto* macro_cell = new Cell("MACRO");
    macro_cell->set_type(CELL_TYPE::kMacro);
    const bool infeasible_macro = fixture_case == FixtureCase::kInfeasibleRouteHalo;
    const bool rectangular_macro = fixture_case == FixtureCase::kOrientConstraint;
    macro_cell->set_width(infeasible_macro ? 600 : (rectangular_macro ? 300 : 200));
    macro_cell->set_height(infeasible_macro ? 600 : (rectangular_macro ? 100 : 200));
    _layout.add_cell(macro_cell);

    auto* macro = new Instance("MACRO0");
    macro->set_cell_master(macro_cell);
    macro->set_shape(100, 100, infeasible_macro ? 700 : (rectangular_macro ? 400 : 300),
                     infeasible_macro ? 700 : (rectangular_macro ? 200 : 300));
    macro->set_orient(Orient::kN_R0);
    macro->set_instance_type(INSTANCE_TYPE::kNormal);
    macro->set_instance_state(INSTANCE_STATE::KUnPlaced);
    _design.add_instance(macro);

    if (fixture_case == FixtureCase::kRouteHaloOffAB || fixture_case == FixtureCase::kRouteHaloOnAB
        || fixture_case == FixtureCase::kRouteHaloWideAB || fixture_case == FixtureCase::kHintRight) {
      auto* macro1 = new Instance("MACRO1");
      macro1->set_cell_master(macro_cell);
      macro1->set_shape(100, 100, 300, 300);
      macro1->set_orient(Orient::kN_R0);
      macro1->set_instance_type(INSTANCE_TYPE::kNormal);
      macro1->set_instance_state(INSTANCE_STATE::KUnPlaced);
      _design.add_instance(macro1);

      auto* blockage = new Region("blockage_list0");
      blockage->set_type(REGION_TYPE::kFence);
      blockage->add_boundary(Rectangle<int32_t>(0, 0, 20, 100));
      _design.add_region(blockage);
    }

    if (fixture_case == FixtureCase::kFixedMacroConflict) {
      auto* fixed_macro = new Instance("FIXED_MACRO0");
      fixed_macro->set_cell_master(macro_cell);
      fixed_macro->set_shape(400, 400, 600, 600);
      fixed_macro->set_instance_type(INSTANCE_TYPE::kNormal);
      fixed_macro->set_instance_state(INSTANCE_STATE::kFixed);
      _design.add_instance(fixed_macro);
    }

    if (fixture_case == FixtureCase::kBlockageConflict) {
      auto* blockage = new Region("blockage_list0");
      blockage->set_type(REGION_TYPE::kFence);
      blockage->add_boundary(Rectangle<int32_t>(0, 0, 1000, 1000));
      _design.add_region(blockage);
    }

    if (fixture_case == FixtureCase::kRouteHaloOffAB) {
      // no route halo
    } else if (fixture_case == FixtureCase::kRouteHaloOnAB) {
      auto* route_halo = new Region("MACRO0_ROUTEHALO");
      route_halo->set_type(REGION_TYPE::kFence);
      route_halo->add_boundary(Rectangle<int32_t>(0, 0, 500, 500));
      _design.add_region(route_halo);
    } else if (fixture_case == FixtureCase::kRouteHaloWideAB) {
      auto* route_halo = new Region("MACRO0_ROUTEHALO");
      route_halo->set_type(REGION_TYPE::kFence);
      route_halo->add_boundary(Rectangle<int32_t>(0, 80, 420, 320));
      _design.add_region(route_halo);
    } else if (fixture_case == FixtureCase::kInfeasibleRouteHalo) {
      auto* route_halo = new Region("MACRO0_ROUTEHALO");
      route_halo->set_type(REGION_TYPE::kFence);
      route_halo->add_boundary(Rectangle<int32_t>(0, 0, 1000, 1000));
      _design.add_region(route_halo);
    } else {
      auto* route_halo = new Region("MACRO0_ROUTEHALO");
      route_halo->set_type(REGION_TYPE::kFence);
      route_halo->add_boundary(Rectangle<int32_t>(0, 0, 500, 500));
      _design.add_region(route_halo);
    }

    if (fixture_case == FixtureCase::kDuplicateRouteHalo) {
      auto* duplicate_route_halo = new Region("MACRO0_ROUTEHALO");
      duplicate_route_halo->set_type(REGION_TYPE::kFence);
      duplicate_route_halo->add_boundary(Rectangle<int32_t>(0, 0, 500, 500));
      _design.add_region(duplicate_route_halo);
    }

    if (fixture_case == FixtureCase::kHintRight) {
      auto* hint = new Region("MACRO0_HINT");
      hint->set_type(REGION_TYPE::kGuide);
      hint->add_boundary(Rectangle<int32_t>(740, 740, 760, 760));
      _design.add_region(hint);
    }

    if (fixture_case == FixtureCase::kChannelConflict) {
      auto* channel = new Region("MACRO0_CHANNEL");
      channel->set_type(REGION_TYPE::kFence);
      channel->add_boundary(Rectangle<int32_t>(0, 0, 1000, 1000));
      _design.add_region(channel);
    }

    if (fixture_case == FixtureCase::kOrientConstraint) {
      auto* orient = new Region("MACRO0_ORIENT_W");
      orient->set_type(REGION_TYPE::kGuide);
      _design.add_region(orient);
    }

    if (fixture_case == FixtureCase::kUnknownRouteHalo) {
      auto* unknown_route_halo = new Region("UNKNOWN_MACRO_ROUTEHALO");
      unknown_route_halo->set_type(REGION_TYPE::kFence);
      unknown_route_halo->add_boundary(Rectangle<int32_t>(0, 0, 100, 100));
      _design.add_region(unknown_route_halo);
    }
  }

  const Layout* get_layout() const override { return &_layout; }
  Design* get_design() const override { return const_cast<Design*>(&_design); }
  void writeDef(std::string) override {}
  void updateFromSourceDataBase() override {}
  void updateFromSourceDataBase(std::vector<std::string>) override {}
  bool writeBackSourceDatabase() override { return true; }
  void initInstancesForFragmentedRow() override {}
  void saveVerilogForDebug(std::string) override {}

 private:
  Layout _layout;
  Design _design;
};

}  // namespace

int main()
{
  bool ok = true;
  auto& placer_db = PlacerDB::getInst();
  placer_db.initPlacerDB(IPL_TEST_CONFIG_PATH, new FixtureWrapper());

  MacroPlacer macro_placer(&placer_db);
  ok &= require(macro_placer.runMacroPlacement(), "a macro with a route halo must be placed legally");
  ok &= require(placer_db.get_revision() == 1, "successful macro placement must commit the PlacerDB transaction");
  ok &= require(macro_placer.get_last_constraint_cost() > 0.0, "route halo must contribute a non-zero placement cost");
  ok &= require(!macro_placer.get_last_exhibit().empty(), "macro placement exhibit must not be empty");
  ok &= require(macro_placer.get_last_candidate_count() > 0, "macro placement exhibit must count candidates");
  ok &= require(macro_placer.get_last_exhibit().size() >= 6, "macro placement exhibit must include per-macro summaries");
  bool exhibit_has_macro_summary = false;
  for (const auto& exhibit_line : macro_placer.get_last_exhibit()) {
    if (exhibit_line.find("candidate=(") != std::string::npos && exhibit_line.find("cost=") != std::string::npos
        && exhibit_line.find("route_halo=") != std::string::npos) {
      exhibit_has_macro_summary = true;
      break;
    }
  }
  ok &= require(exhibit_has_macro_summary, "macro placement exhibit must record candidate, cost and constraint coverage");

  auto* macro = placer_db.get_design()->find_instance("MACRO0");
  ok &= require(macro != nullptr && macro->get_center_coordi().get_x() == 500 && macro->get_center_coordi().get_y() == 500,
                "the constrained macro must be materialized at the selected iPL location");

  PlacerDB::destoryInst();
  auto* infeasible_wrapper = new FixtureWrapper(FixtureCase::kInfeasibleRouteHalo);
  auto& infeasible_db = PlacerDB::getInst();
  infeasible_db.initPlacerDB(IPL_TEST_CONFIG_PATH, infeasible_wrapper);
  auto* infeasible_macro = infeasible_db.get_design()->find_instance("MACRO0");
  const auto original_shape = infeasible_macro->get_shape();
  const auto original_state = infeasible_macro->get_instance_state();
  MacroPlacer infeasible_placer(&infeasible_db);
  ok &= require(!infeasible_placer.runMacroPlacement(), "an oversized macro must fail macro placement");
  ok &= require(infeasible_db.get_revision() == 0, "failed macro placement must rollback without committing a DB revision");
  const auto restored_shape = infeasible_macro->get_shape();
  ok &= require(restored_shape.get_ll_x() == original_shape.get_ll_x() && restored_shape.get_ll_y() == original_shape.get_ll_y()
                    && restored_shape.get_ur_x() == original_shape.get_ur_x() && restored_shape.get_ur_y() == original_shape.get_ur_y()
                    && infeasible_macro->get_instance_state() == original_state,
                "failed macro placement must restore the original DB state");
  PlacerDB::destoryInst();

  auto* fixed_conflict_wrapper = new FixtureWrapper(FixtureCase::kFixedMacroConflict);
  auto& fixed_conflict_db = PlacerDB::getInst();
  fixed_conflict_db.initPlacerDB(IPL_TEST_CONFIG_PATH, fixed_conflict_wrapper);
  auto* conflict_macro = fixed_conflict_db.get_design()->find_instance("MACRO0");
  const auto conflict_original_shape = conflict_macro->get_shape();
  const auto conflict_original_state = conflict_macro->get_instance_state();
  MacroPlacer fixed_conflict_placer(&fixed_conflict_db);
  ok &= require(!fixed_conflict_placer.runMacroPlacement(), "a movable macro overlapping a fixed macro must fail placement");
  ok &= require(fixed_conflict_db.get_revision() == 0, "fixed-macro conflict must rollback without committing a DB revision");
  const auto conflict_restored_shape = conflict_macro->get_shape();
  ok &= require(conflict_restored_shape.get_ll_x() == conflict_original_shape.get_ll_x()
                    && conflict_restored_shape.get_ll_y() == conflict_original_shape.get_ll_y()
                    && conflict_restored_shape.get_ur_x() == conflict_original_shape.get_ur_x()
                    && conflict_restored_shape.get_ur_y() == conflict_original_shape.get_ur_y()
                    && conflict_macro->get_instance_state() == conflict_original_state,
                "fixed-macro conflict failure must restore the movable macro state");
  PlacerDB::destoryInst();

  auto* blockage_wrapper = new FixtureWrapper(FixtureCase::kBlockageConflict);
  auto& blockage_db = PlacerDB::getInst();
  blockage_db.initPlacerDB(IPL_TEST_CONFIG_PATH, blockage_wrapper);
  auto* blockage_macro = blockage_db.get_design()->find_instance("MACRO0");
  const auto blockage_original_shape = blockage_macro->get_shape();
  const auto blockage_original_state = blockage_macro->get_instance_state();
  MacroPlacer blockage_placer(&blockage_db);
  ok &= require(!blockage_placer.runMacroPlacement(), "a full-core blockage must fail macro placement");
  ok &= require(blockage_db.get_revision() == 0, "blockage failure must not commit a DB revision");
  const auto blockage_restored_shape = blockage_macro->get_shape();
  ok &= require(blockage_restored_shape.get_ll_x() == blockage_original_shape.get_ll_x()
                    && blockage_restored_shape.get_ll_y() == blockage_original_shape.get_ll_y()
                    && blockage_restored_shape.get_ur_x() == blockage_original_shape.get_ur_x()
                    && blockage_restored_shape.get_ur_y() == blockage_original_shape.get_ur_y()
                    && blockage_macro->get_instance_state() == blockage_original_state,
                "blockage failure must restore the movable macro state");
  PlacerDB::destoryInst();

  auto* unknown_wrapper = new FixtureWrapper(FixtureCase::kUnknownRouteHalo);
  auto& unknown_db = PlacerDB::getInst();
  unknown_db.initPlacerDB(IPL_TEST_CONFIG_PATH, unknown_wrapper);
  auto* unknown_macro = unknown_db.get_design()->find_instance("MACRO0");
  const auto unknown_original_shape = unknown_macro->get_shape();
  const auto unknown_original_state = unknown_macro->get_instance_state();
  MacroPlacer unknown_placer(&unknown_db);
  ok &= require(!unknown_placer.runMacroPlacement(), "an unknown macro constraint must fail placement");
  ok &= require(unknown_db.get_revision() == 0, "unknown macro constraint must fail before any DB commit");
  const auto unknown_restored_shape = unknown_macro->get_shape();
  ok &= require(unknown_restored_shape.get_ll_x() == unknown_original_shape.get_ll_x()
                    && unknown_restored_shape.get_ll_y() == unknown_original_shape.get_ll_y()
                    && unknown_restored_shape.get_ur_x() == unknown_original_shape.get_ur_x()
                    && unknown_restored_shape.get_ur_y() == unknown_original_shape.get_ur_y()
                    && unknown_macro->get_instance_state() == unknown_original_state,
                "unknown macro constraint failure must not mutate the movable macro state");
  PlacerDB::destoryInst();

  auto* duplicate_wrapper = new FixtureWrapper(FixtureCase::kDuplicateRouteHalo);
  auto& duplicate_db = PlacerDB::getInst();
  duplicate_db.initPlacerDB(IPL_TEST_CONFIG_PATH, duplicate_wrapper);
  auto* duplicate_macro = duplicate_db.get_design()->find_instance("MACRO0");
  const auto duplicate_original_shape = duplicate_macro->get_shape();
  const auto duplicate_original_state = duplicate_macro->get_instance_state();
  MacroPlacer duplicate_placer(&duplicate_db);
  ok &= require(!duplicate_placer.runMacroPlacement(), "a duplicate macro constraint must fail placement");
  ok &= require(duplicate_db.get_revision() == 0, "duplicate macro constraint must fail before any DB commit");
  const auto duplicate_restored_shape = duplicate_macro->get_shape();
  ok &= require(duplicate_restored_shape.get_ll_x() == duplicate_original_shape.get_ll_x()
                    && duplicate_restored_shape.get_ll_y() == duplicate_original_shape.get_ll_y()
                    && duplicate_restored_shape.get_ur_x() == duplicate_original_shape.get_ur_x()
                    && duplicate_restored_shape.get_ur_y() == duplicate_original_shape.get_ur_y()
                    && duplicate_macro->get_instance_state() == duplicate_original_state,
                "duplicate constraint failure must not mutate the movable macro state");

  PlacerDB::destoryInst();

  auto* ab_off_wrapper = new FixtureWrapper(FixtureCase::kRouteHaloOffAB);
  auto& ab_off_db = PlacerDB::getInst();
  ab_off_db.initPlacerDB(IPL_TEST_CONFIG_PATH, ab_off_wrapper);
  MacroPlacer ab_off_placer(&ab_off_db);
  ok &= require(ab_off_placer.runMacroPlacement(), "route-halo off A/B fixture must place legally");
  auto* ab_off_macro = ab_off_db.get_design()->find_instance("MACRO0");
  ok &= require(ab_off_macro != nullptr, "route-halo off A/B macro must exist");
  const auto off_x = ab_off_macro != nullptr ? ab_off_macro->get_center_coordi().get_x() : -1;
  const auto off_y = ab_off_macro != nullptr ? ab_off_macro->get_center_coordi().get_y() : -1;
  ok &= require(off_x > 0 && off_y > 0, "route-halo off must materialize a legal macro position");
  PlacerDB::destoryInst();

  auto* ab_on_wrapper = new FixtureWrapper(FixtureCase::kRouteHaloOnAB);
  auto& ab_on_db = PlacerDB::getInst();
  ab_on_db.initPlacerDB(IPL_TEST_CONFIG_PATH, ab_on_wrapper);
  MacroPlacer ab_on_placer(&ab_on_db);
  ok &= require(ab_on_placer.runMacroPlacement(), "route-halo on A/B fixture must place legally");
  auto* ab_on_macro = ab_on_db.get_design()->find_instance("MACRO0");
  ok &= require(ab_on_macro != nullptr, "route-halo on A/B macro must exist");
  const auto on_x = ab_on_macro != nullptr ? ab_on_macro->get_center_coordi().get_x() : -1;
  const auto on_y = ab_on_macro != nullptr ? ab_on_macro->get_center_coordi().get_y() : -1;
  ok &= require(on_x > 0 && on_y > 0, "route-halo on must materialize a legal macro position");
  ok &= require(off_x != on_x || off_y != on_y, "route-halo A/B must produce different macro positions");

  PlacerDB::destoryInst();

  auto* ab_wide_wrapper = new FixtureWrapper(FixtureCase::kRouteHaloWideAB);
  auto& ab_wide_db = PlacerDB::getInst();
  ab_wide_db.initPlacerDB(IPL_TEST_CONFIG_PATH, ab_wide_wrapper);
  MacroPlacer ab_wide_placer(&ab_wide_db);
  ok &= require(ab_wide_placer.runMacroPlacement(), "route-halo wide A/B fixture must place legally");
  auto* ab_wide_macro = ab_wide_db.get_design()->find_instance("MACRO0");
  ok &= require(ab_wide_macro != nullptr, "route-halo wide A/B macro must exist");
  const auto wide_x = ab_wide_macro != nullptr ? ab_wide_macro->get_center_coordi().get_x() : -1;
  const auto wide_y = ab_wide_macro != nullptr ? ab_wide_macro->get_center_coordi().get_y() : -1;
  ok &= require(wide_x > 0 && wide_y > 0, "route-halo wide must materialize a legal macro position");
  ok &= require(on_x != wide_x || on_y != wide_y, "route-halo on/off A/B must differ from widened route-halo position");

  std::cout << "\nMacro Placer route-halo test: " << (ok ? "PASSED" : "FAILED") << "\n";
  PlacerDB::destoryInst();

  auto* hint_wrapper = new FixtureWrapper(FixtureCase::kHintRight);
  auto& hint_db = PlacerDB::getInst();
  hint_db.initPlacerDB(IPL_TEST_CONFIG_PATH, hint_wrapper);
  MacroPlacer hint_placer(&hint_db);
  ok &= require(hint_placer.runMacroPlacement(), "macro hint fixture must place legally");
  auto* hint_macro0 = hint_db.get_design()->find_instance("MACRO0");
  auto* hint_macro1 = hint_db.get_design()->find_instance("MACRO1");
  ok &= require(hint_macro0 != nullptr && hint_macro1 != nullptr, "hint fixture must contain both macros");
  ok &= require(hint_placer.get_last_candidate_count() > 0, "hint fixture must evaluate macro candidates");
  ok &= require(hint_macro0->get_center_coordi().get_x() >= hint_macro1->get_center_coordi().get_x(),
                "macro hint must bias the first macro toward the hinted region");
  ok &= require(hint_macro0->get_center_coordi().get_y() >= hint_macro1->get_center_coordi().get_y(),
                "macro hint must bias the first macro toward the hinted region");
  PlacerDB::destoryInst();

  auto* orient_wrapper = new FixtureWrapper(FixtureCase::kOrientConstraint);
  auto& orient_db = PlacerDB::getInst();
  orient_db.initPlacerDB(IPL_TEST_CONFIG_PATH, orient_wrapper);
  MacroPlacer orient_placer(&orient_db);
  ok &= require(orient_placer.runMacroPlacement(), "macro orientation fixture must place legally");
  auto* orient_macro = orient_db.get_design()->find_instance("MACRO0");
  ok &= require(orient_macro != nullptr, "orientation fixture macro must exist");
  ok &= require(orient_macro->get_orient() == Orient::kW_R90, "macro orientation constraint must be consumed");
  ok &= require(orient_macro->get_shape_width() == 100 && orient_macro->get_shape_height() == 300,
                "macro orientation constraint must rotate the macro geometry");
  PlacerDB::destoryInst();

  auto* channel_wrapper = new FixtureWrapper(FixtureCase::kChannelConflict);
  auto& channel_db = PlacerDB::getInst();
  channel_db.initPlacerDB(IPL_TEST_CONFIG_PATH, channel_wrapper);
  MacroPlacer channel_placer(&channel_db);
  ok &= require(!channel_placer.runMacroPlacement(), "macro channel keepout fixture must fail placement");
  ok &= require(channel_db.get_revision() == 0, "macro channel keepout failure must rollback without committing a DB revision");
  PlacerDB::destoryInst();

  return ok ? EXIT_SUCCESS : EXIT_FAILURE;
}
