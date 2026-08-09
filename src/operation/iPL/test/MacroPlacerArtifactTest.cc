#include "PLAPI.hh"

#include <cstdlib>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <string>
#include <vector>

#include "builder.h"
#include "idm.h"
#include "json/json.hpp"

namespace {

using Json = nlohmann::json;

auto require(bool condition, const char* message) -> bool
{
  if (!condition) {
    std::cerr << "[FAIL] " << message << '\n';
  } else {
    std::cout << "[PASS] " << message << '\n';
  }
  return condition;
}

auto writeMacroDef(const std::filesystem::path& path, bool route_halo) -> bool
{
  std::ofstream stream(path);
  if (!stream.good()) {
    return false;
  }
  stream << "VERSION 5.8 ;\n"
         << "DIVIDERCHAR \"/\" ;\n"
         << "BUSBITCHARS \"[]\" ;\n"
         << "DESIGN macro_artifact ;\n"
         << "UNITS DISTANCE MICRONS 1000 ;\n"
         << "DIEAREA ( 0 0 ) ( 2000000 2000000 ) ;\n";
  for (int32_t row = 0; row < 735; ++row) {
    stream << "ROW ROW_" << row << " unithd 0 " << row * 2720 << ' ' << (row % 2 == 0 ? "N" : "FS")
           << " DO 4347 BY 1 STEP 460 0 ;\n";
  }
  stream << "TRACKS X 240 DO 4166 STEP 480 LAYER li1 ;\n"
         << "TRACKS Y 185 DO 5405 STEP 370 LAYER li1 ;\n"
         << "TRACKS X 185 DO 5405 STEP 370 LAYER met1 ;\n"
         << "TRACKS Y 185 DO 5405 STEP 370 LAYER met1 ;\n"
         << "TRACKS X 240 DO 4166 STEP 480 LAYER met2 ;\n"
         << "TRACKS Y 240 DO 4166 STEP 480 LAYER met2 ;\n"
         << "TRACKS X 370 DO 2702 STEP 740 LAYER met3 ;\n"
         << "TRACKS Y 370 DO 2702 STEP 740 LAYER met3 ;\n"
         << "TRACKS X 480 DO 2083 STEP 960 LAYER met4 ;\n"
         << "TRACKS Y 480 DO 2083 STEP 960 LAYER met4 ;\n"
         << "TRACKS X 185 DO 600 STEP 3330 LAYER met5 ;\n"
         << "TRACKS Y 185 DO 600 STEP 3330 LAYER met5 ;\n"
         << "COMPONENTS 2 ;\n"
         << " - MACRO0 sky130_sram_1rw1r_44x64_8 + PLACED ( 100000 100000 ) N ;\n"
         << " - MACRO1 sky130_sram_1rw1r_44x64_8 + PLACED ( 1200000 1200000 ) N ;\n"
         << "END COMPONENTS\n";
  if (route_halo) {
    stream << "REGIONS 1 ;\n"
           << " - MACRO0_ROUTEHALO ( 0 0 ) ( 700000 700000 ) + TYPE FENCE ;\n"
           << "END REGIONS\n";
  }
  stream << "END DESIGN\n";
  return static_cast<bool>(stream);
}

auto runCase(const std::filesystem::path& root, bool route_halo, int32_t& macro_x, int32_t& macro_y) -> bool
{
  const auto def_path = root / (route_halo ? "macro_on.def" : "macro_off.def");
  const auto output_dir = root / (route_halo ? "on" : "off");
  const auto tech_lef = std::filesystem::path(IPL_TEST_TECH_LEF_PATH);
  const auto macro_lef = std::filesystem::path(IPL_TEST_MACRO_LEF_PATH);
  if (!writeMacroDef(def_path, route_halo)) {
    return false;
  }

  dmInst->get_config().set_output_path(output_dir.string());
  idb::IdbBuilder builder;
  std::vector<std::string> lef_paths{tech_lef.string(), macro_lef.string()};
  if (builder.buildLef(lef_paths, true) == nullptr || builder.buildDef(def_path.string()) == nullptr) {
    return false;
  }

  iPLAPIInst.initAPI(IPL_TEST_CONFIG_PATH, &builder);
  const bool success = iPLAPIInst.runMP();
  bool ok = require(success, route_halo ? "real macro placer route-halo case must succeed"
                                         : "real macro placer off case must succeed");
  const auto& status = iPLAPIInst.lastRunStatus().macro_placement;
  ok &= require(status.entered && status.completed && status.execution_success && status.quality_success,
                "real macro placement must publish an entered successful stage");
  ok &= require(status.legal && !status.exhibit.empty(), "real macro placement must publish legality and exhibit fields");

  int64_t candidate_count = 0;
  bool has_macro_summary = false;
  for (const auto& line : status.exhibit) {
    if (line.rfind("candidate_count=", 0) == 0) {
      candidate_count = std::stoll(line.substr(std::string("candidate_count=").size()));
    }
    has_macro_summary = has_macro_summary || line.find("MACRO0 candidate=(") != std::string::npos;
  }
  ok &= require(candidate_count > 0 && has_macro_summary, "real macro exhibit must include candidate count and macro summary");

  const auto stage_report_path = output_dir / "pl" / "report" / "ipl_stage_report.json";
  std::ifstream report_stream(stage_report_path);
  Json report;
  if (report_stream.good()) {
    report_stream >> report;
  }
  ok &= require(std::filesystem::exists(stage_report_path) && report.contains("macro_placement"),
                "real placer_run_mp must emit ipl_stage_report.json");
  if (report.contains("macro_placement")) {
    ok &= require(report.at("macro_placement").at("entered").get<bool>()
                      && report.at("macro_placement").at("status").get<std::string>() == "OK",
                  "macro artifact must preserve typed MP status");
  }

  const auto writeback_path = output_dir / "iPL_result.def";
  ok &= require(iPLAPIInst.writeBackSourceDataBase(), "real macro placement must write back source database");
  auto* instance = builder.get_def_service()->get_design()->get_instance_list()->find_instance("MACRO0");
  ok &= require(instance != nullptr && instance->is_placed(), "real macro must be placed in the source database");
  if (instance != nullptr) {
    macro_x = instance->get_coordinate()->get_x();
    macro_y = instance->get_coordinate()->get_y();
  }
  ok &= require(builder.saveDef(writeback_path.string()), "real macro placement must serialize the updated source database");
  ok &= require(std::filesystem::exists(writeback_path), "real macro placement writeback must publish iPL_result.def");
  iPLAPIInst.destoryInst();
  return ok;
}

}  // namespace

int main()
{
  const std::filesystem::path root = "/tmp/ipl_macro_placer_artifact_test";
  std::filesystem::remove_all(root);
  std::filesystem::create_directories(root);
  int32_t off_x = 0;
  int32_t off_y = 0;
  int32_t on_x = 0;
  int32_t on_y = 0;
  bool ok = runCase(root, false, off_x, off_y);
  ok &= runCase(root, true, on_x, on_y);
  ok &= require(off_x != on_x || off_y != on_y, "real route-halo off/on must change the selected macro location");
  return ok ? EXIT_SUCCESS : EXIT_FAILURE;
}
