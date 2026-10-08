#include <cstdlib>
#include <iostream>
#include <string>
#include <vector>

#include "IDBWrapper.hh"
#include "builder.h"

namespace {

auto require(bool condition, const char* message) -> bool
{
  if (!condition) {
    std::cerr << "[FAIL] " << message << '\n';
  } else {
    std::cout << "[PASS] " << message << '\n';
  }
  return condition;
}

}  // namespace

int main()
{
  bool ok = true;

  const std::string tech_lef = "/home/lxq/AiEDA/iEDA.ai/scripts/foundry/sky130/lef/sky130_fd_sc_hd.tlef";
  const std::string cells_lef = "/home/lxq/AiEDA/iEDA.ai/scripts/foundry/sky130/lef/sky130_fd_sc_hd_merged.lef";
  const std::string def_path = "/home/lxq/AiEDA/iEDA.ai/benchmarks/designs/aes_sky130_a/def/aes_place.def";

  idb::IdbBuilder builder;
  std::vector<std::string> lef_paths = {tech_lef, cells_lef};
  ok &= require(builder.buildLef(lef_paths) != nullptr, "LEF builder must load sky130 cells");
  ok &= require(builder.buildDef(def_path) != nullptr, "DEF builder must load aes_place.def");

  ipl::IDBWrapper wrapper(&builder);

  auto* design = wrapper.get_design();
  auto* idb_design = builder.get_def_service()->get_design();

  ipl::Instance* mapped_inst = nullptr;
  idb::IdbInstance* mapped_idb_inst = nullptr;
  for (auto* inst : design->get_instance_list()) {
    if (inst == nullptr || inst->isFakeInstance() || inst->isFixed()) {
      continue;
    }
    auto* idb_inst = idb_design->get_instance_list()->find_instance(inst->get_name());
    if (idb_inst != nullptr && idb_inst->get_bounding_box() != nullptr) {
      mapped_inst = inst;
      mapped_idb_inst = idb_inst;
      break;
    }
  }

  ok &= require(mapped_inst != nullptr, "fixture must contain a mapped movable instance");
  if (mapped_inst != nullptr) {
    const auto original_coord = mapped_inst->get_coordi();
    const auto original_orient = mapped_inst->get_orient();
    const auto original_bbox = mapped_idb_inst->get_bounding_box();
    const int32_t target_x = original_coord.get_x() + 20;
    const int32_t target_y = original_coord.get_y();
    mapped_inst->update_coordi(target_x, target_y);
    mapped_inst->set_orient(ipl::Orient::kFS_MX);

    ok &= require(wrapper.writeBackSourceDatabase(), "write-back must update a mapped instance");
    auto* updated_bbox = mapped_idb_inst->get_bounding_box();
    ok &= require(updated_bbox != nullptr && updated_bbox->get_low_x() == target_x && updated_bbox->get_low_y() == target_y,
                  "write-back must persist the iPL coordinate into iDB");
    ok &= require(mapped_idb_inst->get_orient() == idb::IdbOrient::kFS_MX,
                  "write-back must persist the iPL orientation into iDB");
    ok &= require(wrapper.lastWriteBackResult().updated_count > 0, "write-back result must count updated instances");

    wrapper.updateFromSourceDataBase();
    ok &= require(mapped_inst->get_coordi().get_x() == target_x && mapped_inst->get_coordi().get_y() == target_y,
                  "source database refresh must round-trip the persisted coordinate");
    ok &= require(mapped_inst->get_orient() == ipl::Orient::kFS_MX,
                  "source database refresh must round-trip the persisted orientation");

    mapped_inst->update_coordi(original_coord);
    mapped_inst->set_orient(original_orient);
    ok &= require(wrapper.writeBackSourceDatabase(), "fixture must restore its original mapped placement");
    (void) original_bbox;
  }

  const auto bad_before = idb_design->get_instance_list()->get_instance_list().size();
  auto* protected_before = mapped_idb_inst == nullptr ? nullptr : mapped_idb_inst->get_bounding_box();
  const int32_t protected_x = protected_before == nullptr ? 0 : protected_before->get_low_x();
  const int32_t protected_y = protected_before == nullptr ? 0 : protected_before->get_low_y();
  auto* bad_inst = new ipl::Instance("BAD_NO_MASTER");
  bad_inst->set_instance_type(ipl::INSTANCE_TYPE::kNormal);
  bad_inst->set_instance_state(ipl::INSTANCE_STATE::kPlaced);
  bad_inst->set_shape(0, 0, 10, 10);
  design->add_instance(bad_inst);

  ok &= require(!wrapper.writeBackSourceDatabase(), "write-back must fail for an instance without a cell master");

  const auto& result = wrapper.lastWriteBackResult();
  ok &= require(result.outcome == ipl::IDBWriteBackOutcome::kPreflightFailed, "write-back must report a preflight failure");
  ok &= require(!result.execution_success, "write-back failure must clear execution_success");
  ok &= require(result.rollback_success, "rollback of a create failure must be reported as successful");
  ok &= require(result.reason.find("BAD_NO_MASTER") != std::string::npos, "write-back reason must name the failing instance");
  ok &= require(idb_design->get_instance_list()->get_instance_list().size() == bad_before,
                "preflight failure must not create or remove iDB instances");
  if (mapped_idb_inst != nullptr && mapped_idb_inst->get_bounding_box() != nullptr) {
    ok &= require(mapped_idb_inst->get_bounding_box()->get_low_x() == protected_x
                      && mapped_idb_inst->get_bounding_box()->get_low_y() == protected_y,
                  "preflight failure must not partially update an earlier mapped instance");
  }

  return ok ? EXIT_SUCCESS : EXIT_FAILURE;
}
