#include <cstdlib>
#include <iostream>
#include <string>
#include <vector>

#include "DetailPlacer.hh"

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

    auto add_row = [&](const std::string& name, int32_t y) {
      auto* row = new Row(name);
      auto* site = new Site(name + "_SITE");
      site->set_width(10);
      site->set_height(10);
      row->set_site(site);
      row->set_shape(Rectangle<int32_t>(0, y, 100, y + 10));
      row->set_site_num(10);
      _layout.add_row(row);
    };
    add_row("ROW0", 0);
    add_row("ROW1", 10);
    for (int32_t index = 0; index < 20; ++index) {
      _layout.add_row_orient(Orient::kN_R0);
    }

    auto* cell = new Cell("STD");
    cell->set_type(CELL_TYPE::kLogic);
    cell->set_width(10);
    cell->set_height(10);
    _layout.add_cell(cell);

    _fixed = add_instance("FIXED", 20, 0, INSTANCE_STATE::kFixed, cell);
    _movable = add_instance("MOVABLE", 45, 0, INSTANCE_STATE::kPlaced, cell);
  }

  const Layout* get_layout() const override { return &_layout; }
  Design* get_design() const override { return const_cast<Design*>(&_design); }
  Instance* get_fixed() const { return _fixed; }
  Instance* get_movable() const { return _movable; }

  void writeDef(std::string) override {}
  void updateFromSourceDataBase() override {}
  void updateFromSourceDataBase(std::vector<std::string>) override {}
  bool writeBackSourceDatabase() override { return true; }
  void initInstancesForFragmentedRow() override {}
  void saveVerilogForDebug(std::string) override {}

 private:
  Instance* add_instance(const std::string& name, int32_t x, int32_t y, INSTANCE_STATE state, Cell* cell)
  {
    auto* inst = new Instance(name);
    inst->set_cell_master(cell);
    inst->set_shape(x, y, x + cell->get_width(), y + cell->get_height());
    inst->set_instance_type(INSTANCE_TYPE::kNormal);
    inst->set_instance_state(state);
    inst->set_orient(Orient::kN_R0);
    _design.add_instance(inst);
    return inst;
  }

  Layout _layout;
  Design _design;
  Instance* _fixed = nullptr;
  Instance* _movable = nullptr;
};

}  // namespace

int main()
{
  bool ok = true;
  auto& placer_db = PlacerDB::getInst();
  auto* wrapper = new FixtureWrapper();
  placer_db.initPlacerDB(IPL_TEST_CONFIG_PATH, wrapper);
  Config config(IPL_TEST_CONFIG_PATH);
  DetailPlacer detail_placer(&config, &placer_db);

  const auto before_revision = placer_db.get_revision();
  const auto fixed_coord = wrapper->get_fixed()->get_coordi();
  const auto result = detail_placer.runRowOpt();

  ok &= require(result.completed, "RowOpt must return a completed result");
  ok &= require(result.legal, "RowOpt result must report legal output");
  ok &= require(result.hpwl_before >= 0 && result.hpwl_after >= 0, "RowOpt HPWL fields must be finite non-negative values");
  ok &= require(result.reason.find("row optimization") != std::string::npos, "RowOpt result must include an auditable reason");
  ok &= require(placer_db.get_revision() == before_revision + 1, "successful RowOpt must commit one PlacerDB transaction");
  ok &= require(wrapper->get_fixed()->get_coordi().get_x() == fixed_coord.get_x()
                    && wrapper->get_fixed()->get_coordi().get_y() == fixed_coord.get_y(),
                "RowOpt must not move fixed instances");
  ok &= require(wrapper->get_movable()->get_coordi().get_y() == 0, "RowOpt must keep a movable instance on its legal row");
  ok &= require(wrapper->get_movable()->get_coordi().get_x() % 10 == 0, "RowOpt must align a movable instance to site width");

  PlacerDB::destoryInst();
  return ok ? EXIT_SUCCESS : EXIT_FAILURE;
}
