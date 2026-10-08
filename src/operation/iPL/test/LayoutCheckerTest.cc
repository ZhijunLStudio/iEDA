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

#include "LayoutChecker.hh"

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
    _layout.set_die_shape(Rectangle<int32_t>(0, 0, 100, 100));
    _layout.set_core_shape(Rectangle<int32_t>(0, 0, 100, 100));

    auto* row = new Row("ROW0");
    auto* site = new Site("SITE");
    site->set_width(10);
    site->set_height(10);
    row->set_site(site);
    row->set_shape(Rectangle<int32_t>(0, 0, 100, 10));
    row->set_site_num(10);
    _layout.add_row(row);
    for (int32_t index = 0; index < 10; ++index) {
      _layout.add_row_orient(Orient::kN_R0);
    }

    auto* std_cell = new Cell("STD");
    std_cell->set_type(CELL_TYPE::kLogic);
    std_cell->set_width(10);
    std_cell->set_height(10);
    _layout.add_cell(std_cell);

    auto* wide_cell = new Cell("WIDE");
    wide_cell->set_type(CELL_TYPE::kLogic);
    wide_cell->set_width(20);
    wide_cell->set_height(10);
    _layout.add_cell(wide_cell);

    auto add_inst = [&](const std::string& name, int32_t ll_x, int32_t ll_y, Orient orient, Cell* cell_master) {
      auto* inst = new Instance(name);
      inst->set_cell_master(cell_master);
      inst->set_shape(ll_x, ll_y, ll_x + cell_master->get_width(), ll_y + cell_master->get_height());
      inst->set_instance_type(INSTANCE_TYPE::kNormal);
      inst->set_instance_state(INSTANCE_STATE::kPlaced);
      inst->set_orient(orient);
      _design.add_instance(inst);
    };

    add_inst("LEGAL", 0, 0, Orient::kN_R0, std_cell);
    add_inst("OUTSIDE", 90, 0, Orient::kN_R0, wide_cell);
    add_inst("ROW_MISALIGN", 15, 20, Orient::kN_R0, std_cell);
    add_inst("POWER_MISALIGN", 10, 0, Orient::kS_R180, std_cell);
    add_inst("OVERLAP_A", 20, 0, Orient::kN_R0, std_cell);
    add_inst("OVERLAP_B", 20, 0, Orient::kN_R0, std_cell);
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

std::string join_names(const std::vector<std::string>& names)
{
  std::string result;
  for (size_t index = 0; index < names.size(); ++index) {
    if (index != 0) {
      result += ", ";
    }
    result += names.at(index);
  }
  return result;
}

}  // namespace

int main()
{
  bool ok = true;
  auto& placer_db = PlacerDB::getInst();
  placer_db.initPlacerDB(IPL_TEST_CONFIG_PATH, new FixtureWrapper());

  LayoutChecker checker(&placer_db);
  const auto violations = checker.obtainViolationList();
  ok &= require(violations.size() == 4, "layout checker must expose one violation per failing class");

  size_t outside_cnt = 0;
  size_t row_site_cnt = 0;
  size_t power_cnt = 0;
  size_t overlap_cnt = 0;

  for (const auto& violation : violations) {
    switch (violation.type) {
      case LayoutViolationType::kOutsideCore:
        ++outside_cnt;
        ok &= require(violation.instance_names.size() == 1 && violation.instance_names.front() == "OUTSIDE",
                      "outside-core violation must point to the outside instance");
        break;
      case LayoutViolationType::kRowSiteAlignment:
        ++row_site_cnt;
        ok &= require(violation.instance_names.size() == 1 && violation.instance_names.front() == "ROW_MISALIGN",
                      "row/site violation must point to the misaligned instance");
        break;
      case LayoutViolationType::kPowerAlignment:
        ++power_cnt;
        ok &= require(violation.instance_names.size() == 1 && violation.instance_names.front() == "POWER_MISALIGN",
                      "power violation must point to the misoriented instance");
        break;
      case LayoutViolationType::kOverlap:
        ++overlap_cnt;
        ok &= require(violation.instance_names.size() == 2 && join_names(violation.instance_names) == "OVERLAP_A, OVERLAP_B",
                      "overlap violation must preserve a deterministic clique");
        break;
    }
  }

  ok &= require(outside_cnt == 1 && row_site_cnt == 1 && power_cnt == 1 && overlap_cnt == 1,
                "each violation class must be counted exactly once");
  ok &= require(!checker.isAllPlacedInstInsideCore(), "inside-core bool gate must fail on the outside instance");
  ok &= require(!checker.isAllPlacedInstAlignRowSite(), "row/site bool gate must fail on the misaligned instance");
  ok &= require(!checker.isAllPlacedInstAlignPower(), "power bool gate must fail on the misoriented instance");
  ok &= require(!checker.isNoOverlapAmongInsts(), "overlap bool gate must fail on the overlap clique");

  PlacerDB::destoryInst();
  return ok ? EXIT_SUCCESS : EXIT_FAILURE;
}
