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
#include <cstdint>
#include <iostream>
#include <string>

#include "PlacerDB.hh"

#ifndef IPL_TEST_CONFIG_PATH
#define IPL_TEST_CONFIG_PATH "/home/lxq/AiEDA/iEDA.ai/benchmarks/designs/aes_nangate45_a/workspace/iEDA_config/pl_default_config.json"
#endif

namespace {

using namespace ipl;

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
  FixtureWrapper()
  {
    _layout.set_die_shape(Rectangle<int32_t>(0, 0, 100, 20));
    _layout.set_core_shape(Rectangle<int32_t>(0, 0, 100, 20));

    auto* row0 = new Row("ROW0");
    auto* row1 = new Row("ROW1");
    auto* site0 = new Site("SITE0");
    auto* site1 = new Site("SITE1");
    site0->set_width(10);
    site0->set_height(10);
    site1->set_width(10);
    site1->set_height(10);
    row0->set_site(site0);
    row1->set_site(site1);
    row0->set_shape(Rectangle<int32_t>(0, 0, 100, 10));
    row1->set_shape(Rectangle<int32_t>(0, 10, 100, 20));
    row0->set_site_num(10);
    row1->set_site_num(10);
    _layout.add_row(row0);
    _layout.add_row(row1);
    for (int32_t index = 0; index < 20; ++index) {
      _layout.add_row_orient(Orient::kN_R0);
    }

    auto* std_cell = new Cell("STD");
    std_cell->set_type(CELL_TYPE::kLogic);
    std_cell->set_width(10);
    std_cell->set_height(10);
    _layout.add_cell(std_cell);

    _inst = new Instance("U0");
    _inst->set_cell_master(std_cell);
    _inst->set_shape(0, 0, 10, 10);
    _inst->set_instance_type(INSTANCE_TYPE::kNormal);
    _inst->set_instance_state(INSTANCE_STATE::kPlaced);
    _inst->set_orient(Orient::kN_R0);
    _design.add_instance(_inst);
  }

  const Layout* get_layout() const override { return &_layout; }
  Design* get_design() const override { return const_cast<Design*>(&_design); }
  Instance* get_instance() const { return _inst; }

  void writeDef(std::string) override {}
  void updateFromSourceDataBase() override {}
  void updateFromSourceDataBase(std::vector<std::string>) override {}
  bool writeBackSourceDatabase() override { return true; }
  void initInstancesForFragmentedRow() override {}
  void saveVerilogForDebug(std::string) override {}

 private:
  Layout _layout;
  Design _design;
  Instance* _inst = nullptr;
};

auto gridOccupiedArea(PlacerDB& placer_db, int32_t row, int32_t col) -> int64_t
{
  return placer_db.get_grid_manager()->get_grid_2d_list().at(row).at(col).occupied_area;
}

auto gridFixedArea(PlacerDB& placer_db, int32_t row, int32_t col) -> int64_t
{
  return placer_db.get_grid_manager()->get_grid_2d_list().at(row).at(col).fixed_area;
}

}  // namespace

int main()
{
  bool ok = true;
  auto& placer_db = PlacerDB::getInst();
  auto* wrapper = new FixtureWrapper();
  placer_db.initPlacerDB(IPL_TEST_CONFIG_PATH, wrapper);
  auto* inst = wrapper->get_instance();

  ok &= require(placer_db.get_revision() == 0, "fresh PlacerDB revision starts at zero");
  ok &= require(gridOccupiedArea(placer_db, 0, 0) == 100, "initial grid occupancy follows initial placement");
  ok &= require(gridOccupiedArea(placer_db, 1, 1) == 0, "target grid is initially empty");

  auto rollback_txn = placer_db.beginStageTransaction("unit_rollback");
  ok &= require(rollback_txn.changedInstanceCount() == 0, "fresh transaction reports no changed instances");
  inst->update_coordi(10, 10);
  inst->set_instance_state(INSTANCE_STATE::kFixed);
  placer_db.updateGridManager();

  ok &= require(inst->get_coordi().get_x() == 10 && inst->get_coordi().get_y() == 10, "transaction body can move instance");
  ok &= require(rollback_txn.changedInstanceCount() == 1, "transaction counts moved/state-changed instance");
  ok &= require(gridOccupiedArea(placer_db, 0, 0) == 0, "manual grid refresh observes in-transaction move");
  ok &= require(gridOccupiedArea(placer_db, 1, 1) == 0, "fixed in-transaction instance is excluded from movable occupancy");

  ok &= require(placer_db.rollbackStageTransaction(rollback_txn), "rollback reports success for active transaction");
  ok &= require(rollback_txn.changedInstanceCount() == 0, "closed rollback transaction clears changed-instance snapshots");
  ok &= require(placer_db.get_revision() == 0, "rollback does not advance committed revision");
  ok &= require(!rollback_txn.active, "rollback closes transaction handle");
  ok &= require(inst->get_coordi().get_x() == 0 && inst->get_coordi().get_y() == 0, "rollback restores instance coordinate");
  ok &= require(inst->get_instance_state() == INSTANCE_STATE::kPlaced, "rollback restores instance state");
  ok &= require(gridOccupiedArea(placer_db, 0, 0) == 100, "rollback refreshes old grid occupancy");
  ok &= require(gridOccupiedArea(placer_db, 1, 1) == 0, "rollback clears moved grid occupancy");

  auto commit_txn = placer_db.beginStageTransaction("unit_commit");
  inst->update_coordi(10, 10);
  inst->set_instance_state(INSTANCE_STATE::kFixed);
  placer_db.updateGridManager();
  ok &= require(commit_txn.changedInstanceCount() == 1, "commit transaction counts changed instance before commit");
  ok &= require(placer_db.commitStageTransaction(commit_txn), "commit reports success for active transaction");
  ok &= require(commit_txn.changedInstanceCount() == 0, "closed commit transaction clears changed-instance snapshots");
  ok &= require(placer_db.get_revision() == 1, "commit advances DB revision");
  ok &= require(!commit_txn.active, "commit closes transaction handle");
  ok &= require(inst->get_coordi().get_x() == 10 && inst->get_coordi().get_y() == 10, "commit preserves changed coordinate");
  ok &= require(inst->get_instance_state() == INSTANCE_STATE::kFixed, "commit preserves changed instance state");
  ok &= require(gridOccupiedArea(placer_db, 0, 0) == 0, "commit clears old grid occupancy");
  ok &= require(gridOccupiedArea(placer_db, 1, 1) == 0, "commit excludes fixed instance from movable occupancy");
  ok &= require(gridFixedArea(placer_db, 1, 1) == 100, "commit rebuilds fixed grid occupancy");
  ok &= require(!placer_db.rollbackStageTransaction(commit_txn), "closed transaction cannot rollback after commit");

  PlacerDB::destoryInst();
  return ok ? EXIT_SUCCESS : EXIT_FAILURE;
}
