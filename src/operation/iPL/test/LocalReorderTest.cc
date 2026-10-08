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
  explicit FixtureWrapper(int32_t instance_count = 1)
  {
    _layout.set_die_shape(Rectangle<int32_t>(0, 0, 100, 20));
    _layout.set_core_shape(Rectangle<int32_t>(0, 0, 100, 20));
    for (int32_t row_index = 0; row_index < 2; ++row_index) {
      auto* row = new Row("ROW" + std::to_string(row_index));
      auto* site = new Site("SITE" + std::to_string(row_index));
      site->set_width(10);
      site->set_height(10);
      row->set_site(site);
      row->set_shape(Rectangle<int32_t>(0, row_index * 10, 100, row_index * 10 + 10));
      row->set_site_num(10);
      _layout.add_row(row);
    }
    for (int32_t index = 0; index < 20; ++index) {
      _layout.add_row_orient(Orient::kN_R0);
    }

    auto* cell = new Cell("STD");
    cell->set_type(CELL_TYPE::kLogic);
    cell->set_width(10);
    cell->set_height(10);
    _layout.add_cell(cell);
    _fixed = add_instance("FIXED", 20, 0, INSTANCE_STATE::kFixed, cell);
    for (int32_t index = 0; index < instance_count; ++index) {
      _movables.push_back(add_instance("MOVABLE" + std::to_string(index), 40 + index * 10, 0, INSTANCE_STATE::kPlaced, cell));
    }
  }

  const Layout* get_layout() const override { return &_layout; }
  Design* get_design() const override { return const_cast<Design*>(&_design); }
  Instance* get_fixed() const { return _fixed; }
  Instance* get_movable() const { return _movables.front(); }
  const std::vector<Instance*>& get_movables() const { return _movables; }

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
  std::vector<Instance*> _movables;
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

  const auto fixed_before = wrapper->get_fixed()->get_coordi();
  const auto movable_before = wrapper->get_movable()->get_coordi();
  const auto revision_before = placer_db.get_revision();
  const auto result = detail_placer.runLocalReorder();

  ok &= require(result.isSuccessful(), "local reorder no-op must be a successful result");
  ok &= require(result.outcome == LocalReorderOutcome::kNoOp, "local reorder must expose an explicit no-op outcome");
  ok &= require(result.candidate_count == 0, "single movable instance must produce no adjacent candidates");
  ok &= require(result.accepted_count == 0 && result.changed_count == 0, "local reorder no-op must accept and move nothing");
  ok &= require(result.hpwl_before == result.hpwl_after, "local reorder no-op must preserve HPWL");
  ok &= require(result.reason.find("local reorder") != std::string::npos, "local reorder reason must identify the stage");
  ok &= require(placer_db.get_revision() == revision_before, "local reorder no-op must not advance PlacerDB revision");
  ok &= require(wrapper->get_fixed()->get_coordi().get_x() == fixed_before.get_x()
                    && wrapper->get_fixed()->get_coordi().get_y() == fixed_before.get_y(),
                "local reorder must not move fixed instances");
  ok &= require(wrapper->get_movable()->get_coordi().get_x() == movable_before.get_x()
                    && wrapper->get_movable()->get_coordi().get_y() == movable_before.get_y(),
                "local reorder no-op must preserve movable coordinates");

  PlacerDB::destoryInst();

  auto* multi_wrapper = new FixtureWrapper(4);
  auto& multi_db = PlacerDB::getInst();
  multi_db.initPlacerDB(IPL_TEST_CONFIG_PATH, multi_wrapper);
  Config multi_config(IPL_TEST_CONFIG_PATH);
  multi_config.get_dp_config().set_local_reorder_max_window(3);
  multi_config.get_dp_config().set_local_reorder_budget(2);
  DetailPlacer multi_detail_placer(&multi_config, &multi_db);
  const auto multi_result = multi_detail_placer.runLocalReorder();
  ok &= require(multi_result.isSuccessful(), "multi-instance local reorder must complete legally");
  ok &= require(multi_result.max_window == 3 && multi_result.window_count > 0,
                "local reorder must expose the configured multi-instance window");
  ok &= require(multi_result.search_count <= 2 && multi_result.budget_exhausted,
                "local reorder must stop at the configured search budget");
  ok &= require(multi_result.candidate_count == multi_result.search_count,
                "local reorder candidate count must equal bounded search count");
  const auto multi_coordinates = multi_wrapper->get_movables();
  std::vector<Point<int32_t>> first_run_coordinates;
  for (auto* inst : multi_coordinates) {
    first_run_coordinates.push_back(inst->get_coordi());
  }
  PlacerDB::destoryInst();

  auto* deterministic_wrapper = new FixtureWrapper(4);
  auto& deterministic_db = PlacerDB::getInst();
  deterministic_db.initPlacerDB(IPL_TEST_CONFIG_PATH, deterministic_wrapper);
  Config deterministic_config(IPL_TEST_CONFIG_PATH);
  deterministic_config.get_dp_config().set_local_reorder_max_window(3);
  deterministic_config.get_dp_config().set_local_reorder_budget(2);
  DetailPlacer deterministic_detail_placer(&deterministic_config, &deterministic_db);
  const auto deterministic_result = deterministic_detail_placer.runLocalReorder();
  ok &= require(deterministic_result.search_count == 2 && deterministic_result.budget_exhausted,
                "local reorder must be deterministic under the same window and budget");
  for (size_t index = 0; index < deterministic_wrapper->get_movables().size(); ++index) {
    const auto coordinate = deterministic_wrapper->get_movables().at(index)->get_coordi();
    ok &= require(coordinate.get_x() == first_run_coordinates.at(index).get_x()
                      && coordinate.get_y() == first_run_coordinates.at(index).get_y(),
                  "local reorder must produce deterministic coordinates");
  }
  PlacerDB::destoryInst();
  return ok ? EXIT_SUCCESS : EXIT_FAILURE;
}
