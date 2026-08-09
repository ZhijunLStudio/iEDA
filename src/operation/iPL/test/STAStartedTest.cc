#include <cstdlib>
#include <iostream>
#include <string>
#include <vector>

#include "idm.h"
#include "ista_io.h"

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

  auto* sta_io = staInst;
  ok &= require(!sta_io->isInitSTA(), "STA must start uninitialized");

  const std::string sta_work_dir = "/tmp/ipl_sta_started_test";
  const std::string lib_path = "/home/lxq/AiEDA/iEDA.ai/scripts/foundry/sky130/lib/sky130_fd_sc_hd__tt_025C_1v80.lib";
  const std::string tech_lef = "/home/lxq/AiEDA/iEDA.ai/scripts/foundry/sky130/lef/sky130_fd_sc_hd.tlef";
  const std::string cells_lef = "/home/lxq/AiEDA/iEDA.ai/scripts/foundry/sky130/lef/sky130_fd_sc_hd_merged.lef";
  const std::string def_path = "/home/lxq/AiEDA/iEDA.ai/benchmarks/designs/aes_sky130_a/def/aes_place.def";
  const std::string sdc_path = "/home/lxq/AiEDA/iEDA.ai/benchmarks/designs/aes_sky130_a/sdc/aes.sdc";

  auto& config = dmInst->get_config();
  config.set_output_path(sta_work_dir);
  config.set_tech_lef_path(tech_lef);
  config.set_lef_paths({tech_lef, cells_lef});
  config.set_lib_paths({lib_path});
  config.set_def_path(def_path);
  config.set_sdc_path(sdc_path);

  std::vector<std::string> tech_lef_paths{tech_lef};
  std::vector<std::string> cells_lef_paths{cells_lef};
  ok &= require(dmInst->readLef(tech_lef_paths, true), "iDB must load sky130 tech LEF before STA init");
  ok &= require(dmInst->readLef(cells_lef_paths), "iDB must load sky130 cell LEF before STA init");
  ok &= require(dmInst->readDef(def_path), "iDB must load aes_place.def before STA init");
  ok &= require(sta_io->initSTA(sta_work_dir, false), "STA initialization must succeed on local sky130 assets");
  ok &= require(sta_io->buildGraph() != 0U, "STA graph build must succeed after initSTA");
  ok &= require(sta_io->isInitSTA(), "STA must report initialized after initSTA");

  return ok ? EXIT_SUCCESS : EXIT_FAILURE;
}
