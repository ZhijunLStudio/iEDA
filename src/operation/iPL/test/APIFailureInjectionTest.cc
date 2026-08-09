#include <cstdlib>
#include <filesystem>
#include <iostream>
#include <string>
#include <vector>

#include "PLAPI.hh"
#include "PlacerDB.hh"
#include "builder.h"
#include "idm.h"

#ifndef IPL_TEST_CONFIG_PATH
#define IPL_TEST_CONFIG_PATH "/home/lxq/AiEDA/iEDA.ai/benchmarks/designs/aes_sky130_a/workspace/iEDA_config/pl_default_config.json"
#endif

#ifndef IPL_TEST_TECH_LEF_PATH
#define IPL_TEST_TECH_LEF_PATH "/home/lxq/AiEDA/iEDA.ai/scripts/foundry/sky130/lef/sky130_fd_sc_hd.tlef"
#endif

#ifndef IPL_TEST_CELLS_LEF_PATH
#define IPL_TEST_CELLS_LEF_PATH "/home/lxq/AiEDA/iEDA.ai/scripts/foundry/sky130/lef/sky130_fd_sc_hd_merged.lef"
#endif

#ifndef IPL_TEST_DEF_PATH
#define IPL_TEST_DEF_PATH "/home/lxq/AiEDA/iEDA.ai/benchmarks/designs/gcd_sky130_a/def/gcd_place.def"
#endif

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

struct Fixture
{
  explicit Fixture(const std::string& name)
  {
    output_dir = std::filesystem::path("/tmp/ipl_api_failure_injection_test") / name;
    std::filesystem::remove_all(output_dir);
    std::filesystem::create_directories(output_dir);
    dmInst->get_config().set_output_path(output_dir.string());
    std::vector<std::string> lef_paths{IPL_TEST_TECH_LEF_PATH, IPL_TEST_CELLS_LEF_PATH};
    loaded = builder.buildLef(lef_paths, true) != nullptr && builder.buildDef(IPL_TEST_DEF_PATH) != nullptr;
    if (loaded) {
      iPLAPIInst.initAPI(IPL_TEST_CONFIG_PATH, &builder);
    }
  }

  ~Fixture()
  {
    if (loaded) {
      iPLAPIInst.destoryInst();
    }
  }

  std::filesystem::path output_dir;
  idb::IdbBuilder builder;
  bool loaded = false;
};

auto verifyStageFailure(const std::string& stage, ipl::PlacementStatusCode code, const char* reason) -> bool
{
  Fixture fixture(stage);
  bool ok = require(fixture.loaded, "failure injection fixture must load LEF and DEF");
  if (!ok) {
    return false;
  }
  const auto revision_before = PlacerDBInst.get_revision();
  iPLAPIInst.setFailureInjectionForTest(stage);
  const auto result = iPLAPIInst.runFlowResult();
  const auto& status = iPLAPIInst.lastRunStatus();
  ok &= require(!result.success, reason);
  ok &= require(status.failed_stage == stage && status.overall_reason.find("failure injected") != std::string::npos,
                "failure injection must preserve failed stage and reason");
  ok &= require(status.failedStatusCode() == code, "failure injection must preserve typed status code");
  if (stage == "legalization") {
    ok &= require(PlacerDBInst.get_revision() > revision_before,
                  "LG failure must retain only the already committed MP/GP revisions");
  } else {
    ok &= require(PlacerDBInst.get_revision() == revision_before,
                  "failure before a stage transaction must not commit a database revision");
  }
  if (stage == "macro_placement") {
    ok &= require(!status.global_placement.entered, "MP failure must block GP");
  } else if (stage == "global_placement") {
    ok &= require(!status.legalization.entered && !status.detail_placement.entered, "GP failure must block LG and DP");
  } else if (stage == "legalization") {
    ok &= require(!status.detail_placement.entered && !status.post_global_placement.entered,
                  "LG failure must block DP and PostGP");
  }
  return ok;
}

auto verifyDirectFailure(const std::string& stage, ipl::PlacementStatusCode code, const char* reason) -> bool
{
  Fixture fixture(stage);
  bool ok = require(fixture.loaded, "direct failure fixture must load LEF and DEF");
  if (!ok) {
    return false;
  }
  iPLAPIInst.setFailureInjectionForTest(stage);
  bool success = false;
  if (stage == "detail_placement") {
    success = iPLAPIInst.runDP();
  } else if (stage == "post_global_placement") {
    success = iPLAPIInst.runPostGP();
  } else if (stage == "writeback") {
    success = iPLAPIInst.writeBackSourceDataBase();
  }
  const auto& status = iPLAPIInst.lastRunStatus();
  ok &= require(!success, reason);
  ok &= require(status.failed_stage == (stage == "writeback" ? "artifact" : stage),
                "direct failure must publish the failed stage");
  ok &= require(status.failedStatusCode() == code, "direct failure must preserve typed status code");
  return ok;
}

}  // namespace

int main()
{
  bool ok = true;
  ok &= verifyStageFailure("macro_placement", ipl::PlacementStatusCode::kMPInfeasible,
                           "injected MP failure must fail runFlowResult");
  ok &= verifyStageFailure("global_placement", ipl::PlacementStatusCode::kGPInvalidMetric,
                           "injected GP failure must fail runFlowResult");
  ok &= verifyStageFailure("legalization", ipl::PlacementStatusCode::kLGSolverFailed,
                           "injected LG failure must fail runFlowResult");
  ok &= verifyDirectFailure("detail_placement", ipl::PlacementStatusCode::kDPFailed,
                            "injected DP failure must fail the DP API");
  ok &= verifyDirectFailure("post_global_placement", ipl::PlacementStatusCode::kPostGPFailed,
                            "injected PostGP failure must fail the PostGP API");
  ok &= verifyDirectFailure("writeback", ipl::PlacementStatusCode::kArtifactError,
                            "injected writeback failure must fail the writeback API");
  return ok ? EXIT_SUCCESS : EXIT_FAILURE;
}
