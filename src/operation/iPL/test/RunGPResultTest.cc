#include "PLAPI.hh"

#include <cmath>
#include <cstdlib>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <string>
#include <vector>

#include "idm.h"
#include "json/json.hpp"

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
  // LZJ: previous runs (other users) can leave an undeletable directory behind;
  // use a per-user suffix so the test remains re-runnable on shared machines.
  const std::string output_dir = "/tmp/ipl_run_gp_result_test_lzj";
  const std::string pl_json_file = IPL_TEST_CONFIG_PATH;
  dmInst->get_config().set_output_path(output_dir);
  dmInst->get_config().set_tech_lef_path(IPL_TEST_TECH_LEF_PATH);
  dmInst->get_config().set_lef_paths({IPL_TEST_TECH_LEF_PATH, IPL_TEST_CELLS_LEF_PATH});
  dmInst->get_config().set_def_path(IPL_TEST_DEF_PATH);
  std::filesystem::remove_all(output_dir);
  std::filesystem::create_directories(output_dir);

  ok &= require(dmInst->readLef({IPL_TEST_TECH_LEF_PATH}, true), "iDB must load the technology LEF");
  ok &= require(dmInst->readLef(std::vector<std::string>{IPL_TEST_CELLS_LEF_PATH}),
                "iDB must load the standard-cell LEF");
  ok &= require(dmInst->readDef(IPL_TEST_DEF_PATH), "iDB must load the focused GP DEF");
  if (!ok) {
    return EXIT_FAILURE;
  }

  auto* idb_builder = dmInst->get_idb_builder();
  iPLAPIInst.initAPI(pl_json_file, idb_builder);

  const bool macro_result = iPLAPIInst.runMP();
  ok &= require(macro_result, "runMP must succeed when the design has no macros to place");
  ok &= require(!iPLAPIInst.lastRunStatus().macro_placement.entered
                    && iPLAPIInst.lastRunStatus().macro_placement.skipped
                    && iPLAPIInst.lastRunStatus().macro_placement.message == "no macros in design",
                "runMP must publish an explicit skipped status for a no-macro design");
  ok &= require(iPLAPIInst.lastRunStatus().failed_stage.empty() && iPLAPIInst.lastRunStatus().overall_reason.empty(),
                "a skipped macro placement must not populate the flow failure fields");

  const auto result = iPLAPIInst.runGPResult();
  ok &= require(result.status != ipl::PlacementStatusCode::kNotRun, "runGPResult must return a typed placement status");
  ok &= require(result.status == iPLAPIInst.lastRunStatus().global_placement.code,
                "runGPResult must preserve the GP stage status code");
  ok &= require(result.success == (iPLAPIInst.lastRunStatus().global_placement.execution_success
                                   && iPLAPIInst.lastRunStatus().global_placement.quality_success),
                "runGPResult must preserve the GP stage success contract");

  const auto stage_report_path = std::filesystem::path(output_dir) / "pl" / "report" / "ipl_stage_report.json";
  std::ifstream stage_report_stream(stage_report_path);
  nlohmann::json stage_report;
  if (stage_report_stream.good()) {
    stage_report_stream >> stage_report;
  }
  ok &= require(stage_report_stream.good() || std::filesystem::exists(stage_report_path),
                "runGPResult must emit the stage report artifact");
  if (stage_report.contains("global_placement")) {
    const auto& gp = stage_report.at("global_placement");
    ok &= require(gp.contains("status") && gp.contains("changed_count") && gp.contains("metric_before")
                      && gp.contains("metric_after"),
                  "stage report must expose GP status and metric fields");
    ok &= require(gp.contains("exhibit") && gp.at("exhibit").is_array() && !gp.at("exhibit").empty(),
                  "stage report must expose non-empty Nesterov iteration exhibit");
    int32_t previous_iter = 0;
    for (const auto& serialized_record : gp.at("exhibit")) {
      const auto record = nlohmann::json::parse(serialized_record.get<std::string>());
      ok &= require(record.contains("iter") && record.contains("hpwl") && record.contains("overflow")
                        && record.contains("step_length") && record.contains("gradient_norm")
                        && record.contains("density_penalty") && record.contains("route_util")
                        && record.contains("quad_penalty_enabled") && record.contains("entropy_injected"),
                    "each iteration exhibit record must preserve the stable GP schema");
      const int32_t iter = record.at("iter").get<int32_t>();
      ok &= require(iter > previous_iter, "Nesterov exhibit iteration numbers must be strictly increasing");
      previous_iter = iter;
      ok &= require(record.at("hpwl").get<int64_t>() >= 0 && std::isfinite(record.at("overflow").get<double>())
                        && std::isfinite(record.at("step_length").get<double>())
                        && std::isfinite(record.at("gradient_norm").get<double>())
                        && std::isfinite(record.at("density_penalty").get<double>())
                        && std::isfinite(record.at("route_util").get<double>()),
                    "Nesterov exhibit numeric metrics must be finite and non-negative where required");
    }
    ok &= require(gp.at("changed_count").get<int64_t>() >= 0,
                  "stage report must expose a non-negative changed instance count");
  }

  iPLAPIInst.destoryInst();
  return ok ? EXIT_SUCCESS : EXIT_FAILURE;
}
