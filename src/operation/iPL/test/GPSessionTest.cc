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
//
// GP session equivalence tests (72c M1 acceptance). One scenario per process so every
// scenario starts from a fresh iDB/iPL state; the bash driver compares the artifacts:
//   seg20     start(20)                     -> coords.txt records.txt
//   seg10x2   start(10)+advance(10)         -> coords.txt records.txt (concatenated)
//   observe   start(10)+observe+advance(10) -> coords.txt records.txt (concatenated)
//   legacy    runGPResult() (full run)      -> coords.txt
//   full      gpRun(start, max_iter)        -> coords.txt
//   validate  request/state validation, no artifacts
//
// Invariants (checked by the driver):
//   - seg10x2/observe coords+records bitwise equal seg20 (segmentation equivalence,
//     observation non-interference)
//   - legacy coords bitwise equal full coords (legacy adapter ≡ session machinery)
//   - the second batch does not re-randomize (start_iteration == 11)

#include "PLAPI.hh"

#include <algorithm>
#include <cstdlib>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <map>
#include <memory>
#include <string>
#include <vector>

#include "NesterovPlace.hh"
#include "PlacerDB.hh"
#include "idm.h"

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

auto scenarioRoot(const std::string& scenario) -> std::string
{
  return "/tmp/ipl_gp_session_test/" + scenario;
}

bool initDesign(const std::string& scenario, const std::string& config_path = IPL_TEST_CONFIG_PATH)
{
  const std::string output_dir = scenarioRoot(scenario);
  dmInst->get_config().set_output_path(output_dir);
  dmInst->get_config().set_tech_lef_path(IPL_TEST_TECH_LEF_PATH);
  dmInst->get_config().set_lef_paths({IPL_TEST_TECH_LEF_PATH, IPL_TEST_CELLS_LEF_PATH});
  dmInst->get_config().set_def_path(IPL_TEST_DEF_PATH);
  std::filesystem::remove_all(output_dir);
  std::filesystem::create_directories(output_dir);

  if (!dmInst->readLef({IPL_TEST_TECH_LEF_PATH}, true)) {
    std::cerr << "[FAIL] iDB must load the technology LEF\n";
    return false;
  }
  if (!dmInst->readLef(std::vector<std::string>{IPL_TEST_CELLS_LEF_PATH})) {
    std::cerr << "[FAIL] iDB must load the standard-cell LEF\n";
    return false;
  }
  if (!dmInst->readDef(IPL_TEST_DEF_PATH)) {
    std::cerr << "[FAIL] iDB must load the focused GP DEF\n";
    return false;
  }

  auto* idb_builder = dmInst->get_idb_builder();
  iPLAPIInst.initAPI(config_path, idb_builder);
  return true;
}

bool dumpCoordinates(const std::string& scenario, const std::string& file_name = "coords.txt")
{
  // Real solver-published coordinates live on the iPL PlacerDB layer
  // (writeBackPlacerDB updates iPL Instance centers; the idb layer only syncs
  // via writeBackSourceDataBase at flow end). Dump PlacerDB centers so the
  // equivalence comparisons check actual placement, not the initial DEF.
  auto* design = PlacerDBInst.get_design();
  if (design == nullptr) {
    return false;
  }

  std::vector<std::string> lines;
  for (auto* inst : design->get_instance_list()) {
    if (inst == nullptr || inst->isFixed()) {
      continue;
    }
    const auto center = inst->get_center_coordi();
    lines.push_back(inst->get_name() + " " + std::to_string(center.get_x()) + " " + std::to_string(center.get_y()));
  }
  std::sort(lines.begin(), lines.end());

  std::filesystem::create_directories(scenarioRoot(scenario));
  std::ofstream out(scenarioRoot(scenario) + "/" + file_name);
  if (!out.good()) {
    return false;
  }
  for (const auto& line : lines) {
    out << line << '\n';
  }
  return out.good();
}

bool dumpRecords(const std::vector<ipl::GPIterationRecord>& records, const std::string& scenario)
{
  std::ofstream out(scenarioRoot(scenario) + "/records.txt");
  if (!out.good()) {
    return false;
  }
  for (const auto& record : records) {
    out << record.iter << ' ' << record.hpwl << ' ' << record.overflow << ' ' << record.step_length << ' '
        << record.gradient_norm << '\n';
  }
  return out.good();
}

void appendRecords(const std::vector<ipl::GPIterationRecord>& records, const std::string& scenario)
{
  std::ofstream out(scenarioRoot(scenario) + "/records.txt", std::ios::app);
  for (const auto& record : records) {
    out << record.iter << ' ' << record.hpwl << ' ' << record.overflow << ' ' << record.step_length << ' '
        << record.gradient_norm << '\n';
  }
}

int runSegmented(bool with_observation)
{
  bool ok = true;
  ipl::GPRunRequest start_request;
  start_request.mode = ipl::GPRunMode::kStart;
  start_request.accepted_iterations = 10;
  start_request.random_init = true;
  const auto first = iPLAPIInst.gpRun(start_request);
  ok &= require(first.ok, "first batch (start, 10) must succeed");
  ok &= require(first.start_iteration == 1 && first.end_iteration == 10 && first.executed_iterations == 10,
                "first batch must execute iterations 1-10");

  if (with_observation) {
    // Observation only: read the batch result and the published design. Reading
    // must not change the solver's numerical path.
    volatile const auto observed_hpwl = first.hpwl;
    volatile const auto observed_overflow = first.overflow;
    volatile const auto observed_records = first.iteration_records.size();
    const bool observed_design = dumpCoordinates("observe", "observation_probe_coords.txt");
    ok &= require(observed_design, "observation probe must be able to read the published design");
    (void) observed_hpwl;
    (void) observed_overflow;
    (void) observed_records;
  }

  ipl::GPRunRequest advance_request;
  advance_request.mode = ipl::GPRunMode::kAdvance;
  advance_request.accepted_iterations = 10;
  const auto second = iPLAPIInst.gpRun(advance_request);
  ok &= require(second.ok, "second batch (advance, 10) must succeed");
  ok &= require(second.start_iteration == 11, "second batch must continue from iteration 11 (no re-randomization)");

  const std::string scenario = with_observation ? "observe" : "seg10x2";
  ok &= require(dumpCoordinates(scenario), "must dump final coordinates");
  dumpRecords(first.iteration_records, scenario);
  appendRecords(second.iteration_records, scenario);

  iPLAPIInst.destoryInst();
  return ok ? EXIT_SUCCESS : EXIT_FAILURE;
}

int runSeg20()
{
  bool ok = true;
  ipl::GPRunRequest request;
  request.mode = ipl::GPRunMode::kStart;
  request.accepted_iterations = 20;
  request.random_init = true;
  const auto result = iPLAPIInst.gpRun(request);
  ok &= require(result.ok, "single batch (start, 20) must succeed");
  ok &= require(result.start_iteration == 1 && result.end_iteration == 20 && result.executed_iterations == 20,
                "single batch must execute iterations 1-20");
  ok &= require(dumpCoordinates("seg20"), "must dump final coordinates");
  ok &= require(dumpRecords(result.iteration_records, "seg20"), "must dump iteration records");

  iPLAPIInst.destoryInst();
  return ok ? EXIT_SUCCESS : EXIT_FAILURE;
}

int runLegacy()
{
  bool ok = true;
  const auto result = iPLAPIInst.runGPResult();
  ok &= require(result.status != ipl::PlacementStatusCode::kNotRun, "legacy runGPResult must return a typed status");
  ok &= require(dumpCoordinates("legacy"), "legacy run must dump final coordinates");

  iPLAPIInst.destoryInst();
  return ok ? EXIT_SUCCESS : EXIT_FAILURE;
}

int runSessionFull()
{
  bool ok = true;
  ipl::GPRunRequest request;
  request.mode = ipl::GPRunMode::kStart;
  request.accepted_iterations = 2000;  // max_iter in the focused test config
  request.random_init = true;
  const auto result = iPLAPIInst.gpRun(request);
  ok &= require(result.ok, "session full run must succeed");
  ok &= require(!result.session_active, "full run must reach a terminal condition");
  ok &= require(dumpCoordinates("full"), "session full run must dump final coordinates");

  iPLAPIInst.destoryInst();
  return ok ? EXIT_SUCCESS : EXIT_FAILURE;
}

int runSeg40()
{
  bool ok = true;
  ipl::GPRunRequest request;
  request.mode = ipl::GPRunMode::kStart;
  request.accepted_iterations = 40;
  request.random_init = true;
  const auto result = iPLAPIInst.gpRun(request);
  ok &= require(result.ok, "single batch (start, 40) must succeed");
  ok &= require(result.start_iteration == 1 && result.end_iteration == 40 && result.executed_iterations == 40,
                "single batch must execute iterations 1-40");
  ok &= require(dumpCoordinates("seg40"), "must dump final coordinates");
  ok &= require(dumpRecords(result.iteration_records, "seg40"), "must dump iteration records");

  iPLAPIInst.destoryInst();
  return ok ? EXIT_SUCCESS : EXIT_FAILURE;
}

int runCheckpointSave()
{
  bool ok = true;
  ipl::GPRunRequest request;
  request.mode = ipl::GPRunMode::kStart;
  request.accepted_iterations = 20;
  request.random_init = true;
  const auto result = iPLAPIInst.gpRun(request);
  ok &= require(result.ok, "checkpoint-save batch (start, 20) must succeed");
  ok &= require(result.session_active && !result.checkpoint_path.empty(), "budget-limited batch must auto-save a checkpoint");
  ok &= require(std::filesystem::exists(result.checkpoint_path), "auto-saved checkpoint file must exist");
  ok &= require(dumpCoordinates("ckpt_save"), "must dump mid-run coordinates");

  iPLAPIInst.destoryInst();
  return ok ? EXIT_SUCCESS : EXIT_FAILURE;
}

int runCheckpointResume()
{
  bool ok = true;
  // The checkpoint was produced by the ckpt_save scenario (separate process):
  // resuming here reproduces the exact 21..40 numerical path of seg40.
  ipl::GPRunRequest request;
  request.mode = ipl::GPRunMode::kResume;
  request.accepted_iterations = 20;
  request.checkpoint_path = "/tmp/ipl_gp_session_test/ckpt_save/pl/gp_session_checkpoint.json";
  const auto result = iPLAPIInst.gpRun(request);
  ok &= require(result.ok, "cross-process resume (20 iterations) must succeed");
  ok &= require(result.start_iteration == 21 && result.end_iteration == 40, "resumed batch must run iterations 21-40");
  ok &= require(dumpCoordinates("ckpt_resume"), "must dump final coordinates");
  ok &= require(dumpRecords(result.iteration_records, "ckpt_resume"), "must dump resumed batch records");

  iPLAPIInst.destoryInst();
  return ok ? EXIT_SUCCESS : EXIT_FAILURE;
}

int runResumeInProc()
{
  bool ok = true;
  ipl::GPRunRequest start_request;
  start_request.mode = ipl::GPRunMode::kStart;
  start_request.accepted_iterations = 20;
  start_request.random_init = true;
  const auto first = iPLAPIInst.gpRun(start_request);
  ok &= require(first.ok && !first.checkpoint_path.empty(), "first batch must auto-save a checkpoint");
  const std::string checkpoint_path = first.checkpoint_path;

  // Destroy the in-memory session; only the persisted checkpoint remains.
  iPLAPIInst.gpCloseSession();
  ok &= require(!iPLAPIInst.gpSessionActive(), "close must discard the in-memory session");

  ipl::GPRunRequest resume_request;
  resume_request.mode = ipl::GPRunMode::kResume;
  resume_request.accepted_iterations = 20;
  resume_request.checkpoint_path = checkpoint_path;
  const auto resumed = iPLAPIInst.gpRun(resume_request);
  ok &= require(resumed.ok, "in-process resume must succeed");
  ok &= require(resumed.start_iteration == 21 && resumed.end_iteration == 40, "resumed batch must run iterations 21-40");
  ok &= require(dumpCoordinates("resume_inproc"), "must dump final coordinates");
  ok &= require(dumpRecords(resumed.iteration_records, "resume_inproc"), "must dump resumed batch records");

  iPLAPIInst.destoryInst();
  return ok ? EXIT_SUCCESS : EXIT_FAILURE;
}

// ---- gap-1 / gap-2 scenarios ----

int runSeg40Congestion()
{
  bool ok = true;
  ipl::GPRunRequest request;
  request.mode = ipl::GPRunMode::kStart;
  request.accepted_iterations = 40;
  request.random_init = true;
  const auto result = iPLAPIInst.gpRun(request);
  ok &= require(result.ok, "congestion-enabled single batch (start, 40) must succeed");
  ok &= require(result.start_iteration == 1 && result.end_iteration == 40 && result.executed_iterations == 40,
                "congestion-enabled batch must execute iterations 1-40");
  ok &= require(dumpCoordinates("seg40_cg"), "must dump final coordinates");
  ok &= require(dumpRecords(result.iteration_records, "seg40_cg"), "must dump iteration records");

  iPLAPIInst.destoryInst();
  return ok ? EXIT_SUCCESS : EXIT_FAILURE;
}

int runCheckpointSaveCongestion()
{
  bool ok = true;
  ipl::GPRunRequest request;
  request.mode = ipl::GPRunMode::kStart;
  request.accepted_iterations = 20;
  request.random_init = true;
  const auto result = iPLAPIInst.gpRun(request);
  ok &= require(result.ok, "congestion-enabled checkpoint-save batch must succeed");
  ok &= require(result.session_active && std::filesystem::exists(result.checkpoint_path),
                "congestion-enabled batch must auto-save a checkpoint");
  ok &= require(dumpCoordinates("ckpt_save_cg"), "must dump mid-run coordinates");

  iPLAPIInst.destoryInst();
  return ok ? EXIT_SUCCESS : EXIT_FAILURE;
}

int runCheckpointResumeCongestion()
{
  bool ok = true;
  ipl::GPRunRequest request;
  request.mode = ipl::GPRunMode::kResume;
  request.accepted_iterations = 20;
  request.checkpoint_path = "/tmp/ipl_gp_session_test/ckpt_save_cg/pl/gp_session_checkpoint.json";
  const auto result = iPLAPIInst.gpRun(request);
  ok &= require(result.ok, "congestion-enabled cross-process resume must succeed");
  ok &= require(result.start_iteration == 21 && result.end_iteration == 40, "resumed batch must run iterations 21-40");
  ok &= require(dumpCoordinates("ckpt_resume_cg"), "must dump final coordinates");
  ok &= require(dumpRecords(result.iteration_records, "ckpt_resume_cg"), "must dump resumed batch records");

  iPLAPIInst.destoryInst();
  return ok ? EXIT_SUCCESS : EXIT_FAILURE;
}

int runConvergeMid()
{
  bool ok = true;
  ipl::GPRunRequest start_request;
  start_request.mode = ipl::GPRunMode::kStart;
  start_request.accepted_iterations = 20;
  start_request.random_init = true;
  const auto first = iPLAPIInst.gpRun(start_request);
  ok &= require(first.ok, "first batch (start, 20) must succeed");

  ipl::GPRunRequest advance_request;
  advance_request.mode = ipl::GPRunMode::kAdvance;
  advance_request.accepted_iterations = 1980;  // max_iter - 20; convergence fires mid-batch
  const auto second = iPLAPIInst.gpRun(advance_request);
  ok &= require(second.ok, "advance batch must succeed");
  ok &= require(!second.session_active, "natural convergence must terminate the session");
  ok &= require(second.stop_reason == ipl::GPStopReason::kTargetReached,
                "mid-batch natural convergence must report kTargetReached");
  ok &= require(second.executed_iterations < second.requested_iterations,
                "converged batch must execute fewer iterations than requested");
  ok &= require(second.start_iteration == 21 && second.end_iteration == 20 + second.executed_iterations,
                "iteration range must reflect the early stop");
  ok &= require(dumpCoordinates("conv_mid"), "must dump converged coordinates");

  iPLAPIInst.destoryInst();
  return ok ? EXIT_SUCCESS : EXIT_FAILURE;
}

int runDiverge()
{
  bool ok = true;

  ipl::GPRunRequest request;
  request.mode = ipl::GPRunMode::kStart;
  request.accepted_iterations = 50;
  request.random_init = true;
  const auto result = iPLAPIInst.gpRun(request);
  std::cout << "[PROBE] divergent run: ok=" << result.ok << " stop_reason=" << static_cast<int>(result.stop_reason)
            << " reason='" << result.reason << "'" << std::endl;
  ok &= require(!result.ok, "divergent config must fail the run");
  ok &= require(!result.session_active, "divergent run must not leave a session behind");
  ok &= require(result.stop_reason == ipl::GPStopReason::kDiverged || result.stop_reason == ipl::GPStopReason::kInvalidMetric,
                "divergent run must report kDiverged or kInvalidMetric");
  ok &= require(!iPLAPIInst.gpSessionActive(), "worker must stay alive with no active session after divergence");

  // Determinism + liveness: the same run fails again the same way, and the API
  // still answers subsequent requests instead of terminating the process.
  const auto again = iPLAPIInst.gpRun(request);
  ok &= require(!again.ok && again.stop_reason == result.stop_reason, "divergent run must be reproducible");

  ipl::GPRunRequest advance_request;
  advance_request.mode = ipl::GPRunMode::kAdvance;
  const auto advance = iPLAPIInst.gpRun(advance_request);
  ok &= require(!advance.ok && advance.stop_reason == ipl::GPStopReason::kRejected,
                "advance after divergence must be cleanly rejected");

  iPLAPIInst.destoryInst();
  return ok ? EXIT_SUCCESS : EXIT_FAILURE;
}

int runMismatch()
{
  bool ok = true;
  // This process loads a MODIFIED placer config (different target_overflow);
  // resuming the checkpoint saved under the standard config must be rejected by
  // the config fingerprint before any solver state is touched.
  ipl::GPRunRequest request;
  request.mode = ipl::GPRunMode::kResume;
  request.accepted_iterations = 20;
  request.checkpoint_path = "/tmp/ipl_gp_session_test/ckpt_save/pl/gp_session_checkpoint.json";
  const auto result = iPLAPIInst.gpRun(request);
  ok &= require(!result.ok && result.stop_reason == ipl::GPStopReason::kRejected,
                "resume under a modified config must be rejected");
  ok &= require(!iPLAPIInst.gpSessionActive(), "rejected mismatch resume must not leave a session behind");
  ok &= require(result.reason.find("fingerprint") != std::string::npos, "rejection reason must mention the config fingerprint");

  iPLAPIInst.destoryInst();
  return ok ? EXIT_SUCCESS : EXIT_FAILURE;
}

int runSeg40MultiThread()
{
  bool ok = true;
  ipl::GPRunRequest request;
  request.mode = ipl::GPRunMode::kStart;
  request.accepted_iterations = 40;
  request.random_init = true;
  const auto result = iPLAPIInst.gpRun(request);
  ok &= require(result.ok, "multithread single batch (start, 40) must succeed");
  ok &= require(result.start_iteration == 1 && result.end_iteration == 40 && result.executed_iterations == 40,
                "multithread batch must execute iterations 1-40");
  ok &= require(dumpCoordinates("seg40_mt"), "must dump final coordinates");
  ok &= require(dumpRecords(result.iteration_records, "seg40_mt"), "must dump iteration records");

  iPLAPIInst.destoryInst();
  return ok ? EXIT_SUCCESS : EXIT_FAILURE;
}

int runCheckpointSaveMultiThread()
{
  bool ok = true;
  ipl::GPRunRequest request;
  request.mode = ipl::GPRunMode::kStart;
  request.accepted_iterations = 20;
  request.random_init = true;
  const auto result = iPLAPIInst.gpRun(request);
  ok &= require(result.ok, "multithread checkpoint-save batch must succeed");
  ok &= require(result.session_active && std::filesystem::exists(result.checkpoint_path),
                "multithread batch must auto-save a checkpoint");
  ok &= require(dumpCoordinates("ckpt_save_mt"), "must dump mid-run coordinates");

  iPLAPIInst.destoryInst();
  return ok ? EXIT_SUCCESS : EXIT_FAILURE;
}

int runCheckpointResumeMultiThread()
{
  bool ok = true;
  ipl::GPRunRequest request;
  request.mode = ipl::GPRunMode::kResume;
  request.accepted_iterations = 20;
  request.checkpoint_path = "/tmp/ipl_gp_session_test/ckpt_save_mt/pl/gp_session_checkpoint.json";
  const auto result = iPLAPIInst.gpRun(request);
  ok &= require(result.ok, "multithread cross-process resume must succeed");
  ok &= require(result.start_iteration == 21 && result.end_iteration == 40, "resumed batch must run iterations 21-40");
  ok &= require(dumpCoordinates("ckpt_resume_mt"), "must dump final coordinates");
  ok &= require(dumpRecords(result.iteration_records, "ckpt_resume_mt"), "must dump resumed batch records");

  iPLAPIInst.destoryInst();
  return ok ? EXIT_SUCCESS : EXIT_FAILURE;
}

// ---- M3 scenarios: session invalidation + relinearize ----

int runInvalidate()
{
  bool ok = true;
  ipl::GPRunRequest start_request;
  start_request.mode = ipl::GPRunMode::kStart;
  start_request.accepted_iterations = 10;
  start_request.random_init = true;
  const auto first = iPLAPIInst.gpRun(start_request);
  ok &= require(first.ok, "invalidate: first batch must succeed");

  // External tool (legalization) commits its own transaction -> revision bump.
  ok &= require(iPLAPIInst.runLG(), "invalidate: runLG must succeed on the published placement");

  ipl::GPRunRequest advance_request;
  advance_request.mode = ipl::GPRunMode::kAdvance;
  advance_request.accepted_iterations = 10;
  const auto advance = iPLAPIInst.gpRun(advance_request);
  ok &= require(!advance.ok && advance.stop_reason == ipl::GPStopReason::kRejected,
                "invalidate: advance after external placement changes must be rejected");
  ok &= require(advance.reason.find("invalidated") != std::string::npos,
                "invalidate: rejection reason must mention invalidation");

  // Relinearize: keep the legalized coordinates, rebuild solver state from them.
  // The invalidated session is auto-discarded by the start call (no explicit close).
  ipl::GPRunRequest relinearize_request;
  relinearize_request.mode = ipl::GPRunMode::kStart;
  relinearize_request.accepted_iterations = 10;
  relinearize_request.random_init = false;
  const auto relinearized = iPLAPIInst.gpRun(relinearize_request);
  ok &= require(relinearized.ok, "invalidate: keep-init start after close must succeed");
  ok &= require(relinearized.start_iteration == 1, "invalidate: relinearized session must restart at iteration 1");

  iPLAPIInst.destoryInst();
  return ok ? EXIT_SUCCESS : EXIT_FAILURE;
}

int runRelinearize()
{
  bool ok = true;
  ipl::GPRunRequest start_request;
  start_request.mode = ipl::GPRunMode::kStart;
  start_request.accepted_iterations = 10;
  start_request.random_init = true;
  const auto first = iPLAPIInst.gpRun(start_request);
  ok &= require(first.ok, "relinearize: first batch must succeed");

  ok &= require(iPLAPIInst.runLG(), "relinearize: runLG must succeed");
  iPLAPIInst.gpCloseSession();

  ipl::GPRunRequest relinearize_request;
  relinearize_request.mode = ipl::GPRunMode::kStart;
  relinearize_request.accepted_iterations = 10;
  relinearize_request.random_init = false;
  const auto relinearized = iPLAPIInst.gpRun(relinearize_request);
  ok &= require(relinearized.ok, "relinearize: keep-init start must succeed");
  ok &= require(relinearized.start_iteration == 1 && relinearized.end_iteration == 10,
                "relinearize: new session must run iterations 1-10");
  ok &= require(dumpCoordinates("relinearize"), "must dump relinearized coordinates");
  ok &= require(dumpRecords(relinearized.iteration_records, "relinearize"), "must dump relinearized records");

  iPLAPIInst.destoryInst();
  return ok ? EXIT_SUCCESS : EXIT_FAILURE;
}

// ---- M4 scenarios: local GP invariants + the control experiment ----

std::unique_ptr<ipl::NesterovPlace> restoreSolverFromCheckpoint(const std::string& checkpoint_path)
{
  ipl::GPStateCheckpoint checkpoint;
  if (!ipl::loadGPCheckpointFile(checkpoint_path, checkpoint)) {
    return nullptr;
  }
  auto session = std::make_unique<ipl::NesterovPlace>(PlacerDBInst.get_placer_config(), &PlacerDBInst, false);
  if (!session->restoreCheckpoint(checkpoint)) {
    return nullptr;
  }
  return session;
}

void dumpScopeStats(const std::vector<float>& coeffs, const std::string& scenario)
{
  int32_t active = 0;
  int32_t halo = 0;
  int32_t context = 0;
  for (float coeff : coeffs) {
    if (coeff >= 1.0F) {
      active++;
    } else if (coeff > 0.0F) {
      halo++;
    } else {
      context++;
    }
  }
  std::filesystem::create_directories(scenarioRoot(scenario));
  std::ofstream out(scenarioRoot(scenario) + "/scope_stats.txt");
  out << "active=" << active << " halo=" << halo << " context=" << context << '\n';
}

// Degeneration invariant: an explicit all-1 movement scope must reproduce the
// plain global path bitwise.
int runLocalDegenerate()
{
  bool ok = true;
  const std::string checkpoint_path = "/tmp/ipl_gp_session_test/ckpt_save/pl/gp_session_checkpoint.json";
  auto session = restoreSolverFromCheckpoint(checkpoint_path);
  ok &= require(session != nullptr, "degenerate: must restore the ckpt_save checkpoint");

  ipl::GPStateCheckpoint checkpoint;
  ipl::loadGPCheckpointFile(checkpoint_path, checkpoint);
  std::vector<float> all_ones(checkpoint.instance_names.size(), 1.0F);
  session->setMovementCoeffs(all_ones);
  const auto advance = session->advanceAcceptedIterations(20);
  ok &= require(advance == ipl::GPAdvanceOutcome::kBudgetReached, "degenerate: 20-iteration batch must finish on budget");
  session->publishPlacement();
  PlacerDBInst.updateTopoManager();
  PlacerDBInst.updateGridManager();
  ok &= require(dumpCoordinates("local_degenerate"), "must dump coordinates");

  iPLAPIInst.destoryInst();
  return ok ? EXIT_SUCCESS : EXIT_FAILURE;
}

// Zero-write invariant: context instances (coefficient 0) must not move at all
// during a local batch.
int runLocalContextFrozen()
{
  bool ok = true;
  const std::string checkpoint_path = "/tmp/ipl_gp_session_test/ckpt_save/pl/gp_session_checkpoint.json";
  ipl::GPStateCheckpoint checkpoint;
  ok &= require(ipl::loadGPCheckpointFile(checkpoint_path, checkpoint), "context-frozen: must load the checkpoint");

  auto session = restoreSolverFromCheckpoint(checkpoint_path);
  ok &= require(session != nullptr, "context-frozen: must restore the ckpt_save checkpoint");

  // Publish the restored (iter-20) state first: the invariant is "context must
  // not move DURING the batch", so the baseline is the batch-start placement.
  session->publishPlacement();
  PlacerDBInst.updateTopoManager();
  PlacerDBInst.updateGridManager();

  session->buildHotOverflowScope(0.2F, 0.5F);
  const auto& coeffs = session->movementCoeffs();
  int32_t context_count = 0;
  int32_t active_count = 0;
  for (float coeff : coeffs) {
    context_count += (coeff <= 0.0F) ? 1 : 0;
    active_count += (coeff >= 1.0F) ? 1 : 0;
  }
  dumpScopeStats(coeffs, "local_context_frozen");
  ok &= require(active_count > 0, "context-frozen: scope must contain at least one active instance");
  ok &= require(context_count > 0, "context-frozen: scope must leave at least one context instance");

  // Snapshot PlacerDB centers (the iter-20 published placement) by name.
  auto* design = PlacerDBInst.get_design();
  std::map<std::string, std::string> before;
  for (auto* inst : design->get_instance_list()) {
    if (inst == nullptr || inst->isFixed()) {
      continue;
    }
    const auto center = inst->get_center_coordi();
    before[inst->get_name()] = std::to_string(center.get_x()) + " " + std::to_string(center.get_y());
  }

  const auto advance = session->advanceAcceptedIterations(20);
  ok &= require(advance == ipl::GPAdvanceOutcome::kBudgetReached, "context-frozen: batch must finish on budget");
  session->publishPlacement();
  PlacerDBInst.updateTopoManager();
  PlacerDBInst.updateGridManager();

  // Every context instance must be bitwise at its pre-batch position.
  int32_t context_moved = 0;
  int32_t context_seen = 0;
  for (size_t i = 0; i < coeffs.size(); i++) {
    if (coeffs[i] > 0.0F) {
      continue;
    }
    context_seen++;
    for (auto* inst : design->get_instance_list()) {
      if (inst != nullptr && !inst->isFixed() && inst->get_name() == checkpoint.instance_names[i]) {
        const auto center = inst->get_center_coordi();
        const std::string after = std::to_string(center.get_x()) + " " + std::to_string(center.get_y());
        if (before[inst->get_name()] != after) {
          context_moved++;
        }
        break;
      }
    }
  }
  if (context_moved > 0) {
    std::cerr << "[DEBUG] context_moved=" << context_moved << " of " << context_seen << " context instances\n";
  }
  ok &= require(context_seen > 0, "context-frozen: must have observed context instances");
  ok &= require(context_moved == 0, "context-frozen: context instances must not move during a local batch");
  ok &= require(dumpCoordinates("local_context_frozen"), "must dump coordinates");

  iPLAPIInst.destoryInst();
  return ok ? EXIT_SUCCESS : EXIT_FAILURE;
}

// Control experiment: from the same iter-20 checkpoint, branch A runs global
// 20 iterations and branch B runs a hot-overflow local scope for 20 iterations.
// Artifacts (records + coordinates + scope stats) are compared by the driver.
int runLocalControl()
{
  bool ok = true;
  const std::string checkpoint_path = "/tmp/ipl_gp_session_test/ckpt_save/pl/gp_session_checkpoint.json";
  ipl::GPStateCheckpoint checkpoint;
  ok &= require(ipl::loadGPCheckpointFile(checkpoint_path, checkpoint), "control: must load the checkpoint");
  const size_t record_offset = checkpoint.iteration_records.size();

  // Branch A: global.
  {
    auto session = restoreSolverFromCheckpoint(checkpoint_path);
    ok &= require(session != nullptr, "control: branch A must restore the checkpoint");
    ok &= require(session->advanceAcceptedIterations(20) == ipl::GPAdvanceOutcome::kBudgetReached, "control: branch A must finish");
    session->publishPlacement();
    PlacerDBInst.updateTopoManager();
    PlacerDBInst.updateGridManager();
    ok &= require(dumpCoordinates("local_global_branch"), "control: branch A must dump coordinates");

    const auto& all_records = session->iterationRecords();
    std::ofstream out(scenarioRoot("local_global_branch") + "/records.txt");
    for (auto it = all_records.begin() + record_offset; it != all_records.end(); ++it) {
      out << it->iter << ' ' << it->hpwl << ' ' << it->overflow << ' ' << it->step_length << ' ' << it->gradient_norm << '\n';
    }
  }

  // Branch B: local scope on the hottest overflow bins.
  {
    auto session = restoreSolverFromCheckpoint(checkpoint_path);
    ok &= require(session != nullptr, "control: branch B must restore the checkpoint");
    session->buildHotOverflowScope(0.2F, 0.5F);
    dumpScopeStats(session->movementCoeffs(), "local_scope_branch");
    ok &= require(session->advanceAcceptedIterations(20) == ipl::GPAdvanceOutcome::kBudgetReached, "control: branch B must finish");
    session->publishPlacement();
    PlacerDBInst.updateTopoManager();
    PlacerDBInst.updateGridManager();
    ok &= require(dumpCoordinates("local_scope_branch"), "control: branch B must dump coordinates");

    const auto& all_records = session->iterationRecords();
    std::ofstream out(scenarioRoot("local_scope_branch") + "/records.txt");
    for (auto it = all_records.begin() + record_offset; it != all_records.end(); ++it) {
      out << it->iter << ' ' << it->hpwl << ' ' << it->overflow << ' ' << it->step_length << ' ' << it->gradient_norm << '\n';
    }
  }

  iPLAPIInst.destoryInst();
  return ok ? EXIT_SUCCESS : EXIT_FAILURE;
}

// Ablation: does hot-bin scope selection beat a random scope of the same size?
// Branches (all from the same iter-20 checkpoint, 20 iterations each):
//   global / hot-0.2 / random-42 (same active count) / random-43
int runLocalAblate()
{
  bool ok = true;
  const std::string checkpoint_path = "/tmp/ipl_gp_session_test/ckpt_save/pl/gp_session_checkpoint.json";
  ipl::GPStateCheckpoint checkpoint;
  ok &= require(ipl::loadGPCheckpointFile(checkpoint_path, checkpoint), "ablate: must load the checkpoint");
  const size_t record_offset = checkpoint.iteration_records.size();

  const auto run_branch = [&](const std::string& tag, bool hot, bool random_scope, uint32_t seed) {
    auto session = restoreSolverFromCheckpoint(checkpoint_path);
    if (session == nullptr) {
      return false;
    }
    if (hot) {
      session->buildHotOverflowScope(0.2F, 0.5F);
      dumpScopeStats(session->movementCoeffs(), tag);
    } else if (random_scope) {
      // same active count as the hot scope, different seed for variance
      const size_t active_count = 134;
      session->buildRandomScope(active_count, 0.5F, seed);
      dumpScopeStats(session->movementCoeffs(), tag);
    }
    if (session->advanceAcceptedIterations(20) != ipl::GPAdvanceOutcome::kBudgetReached) {
      return false;
    }
    session->publishPlacement();
    PlacerDBInst.updateTopoManager();
    PlacerDBInst.updateGridManager();

    const auto& all_records = session->iterationRecords();
    std::filesystem::create_directories(scenarioRoot(tag));
    std::ofstream out(scenarioRoot(tag) + "/records.txt");
    if (!out.good()) {
      return false;
    }
    for (auto it = all_records.begin() + record_offset; it != all_records.end(); ++it) {
      out << it->iter << ' ' << it->hpwl << ' ' << it->overflow << ' ' << it->step_length << ' ' << it->gradient_norm << '\n';
    }
    return dumpCoordinates(tag);
  };

  ok &= require(run_branch("local_ablate_global", false, false, 0), "ablate: global branch");
  ok &= require(run_branch("local_ablate_hot", true, false, 0), "ablate: hot branch");
  ok &= require(run_branch("local_ablate_random42", false, true, 42), "ablate: random-42 branch");
  ok &= require(run_branch("local_ablate_random43", false, true, 43), "ablate: random-43 branch");

  iPLAPIInst.destoryInst();
  return ok ? EXIT_SUCCESS : EXIT_FAILURE;
}

// Sweep: repeat the hot-vs-random ablation from a LATER checkpoint (iter 60)
// and across several active ratios, to check whether the "random ≈ hot" finding
// is specific to the iter-20 state.
int runLocalSweep()
{
  bool ok = true;

  // Advance to iteration 60 and save a fresh checkpoint.
  {
    ipl::GPRunRequest start_request;
    start_request.mode = ipl::GPRunMode::kStart;
    start_request.accepted_iterations = 60;
    start_request.random_init = true;
    const auto first = iPLAPIInst.gpRun(start_request);
    ok &= require(first.ok && first.session_active, "sweep: start(60) must leave an active session");
    ok &= require(std::filesystem::exists(first.checkpoint_path), "sweep: start(60) must auto-save a checkpoint");
    iPLAPIInst.gpCloseSession();
  }
  const std::string checkpoint_path = "/tmp/ipl_gp_session_test/local_sweep/pl/gp_session_checkpoint.json";
  ipl::GPStateCheckpoint checkpoint;
  ok &= require(ipl::loadGPCheckpointFile(checkpoint_path, checkpoint), "sweep: must load the iter-60 checkpoint");
  const size_t record_offset = checkpoint.iteration_records.size();

  const auto run_branch = [&](const std::string& tag, float ratio, bool random_scope, uint32_t seed) {
    auto session = restoreSolverFromCheckpoint(checkpoint_path);
    if (session == nullptr) {
      return false;
    }
    size_t active_count = 0;
    if (ratio > 0.0F) {
      session->buildHotOverflowScope(ratio, 0.5F);
      for (float coeff : session->movementCoeffs()) {
        active_count += (coeff >= 1.0F) ? 1 : 0;
      }
      dumpScopeStats(session->movementCoeffs(), tag);
    } else if (random_scope) {
      session->buildRandomScope(active_count, 0.5F, seed);
      dumpScopeStats(session->movementCoeffs(), tag);
    }
    if (session->advanceAcceptedIterations(20) != ipl::GPAdvanceOutcome::kBudgetReached) {
      return false;
    }
    session->publishPlacement();
    PlacerDBInst.updateTopoManager();
    PlacerDBInst.updateGridManager();

    const auto& all_records = session->iterationRecords();
    std::filesystem::create_directories(scenarioRoot(tag));
    std::ofstream out(scenarioRoot(tag) + "/records.txt");
    if (!out.good()) {
      return false;
    }
    for (auto it = all_records.begin() + record_offset; it != all_records.end(); ++it) {
      out << it->iter << ' ' << it->hpwl << ' ' << it->overflow << ' ' << it->step_length << ' ' << it->gradient_norm << '\n';
    }
    return dumpCoordinates(tag);
  };

  ok &= require(run_branch("sweep60_global", 0.0F, false, 0), "sweep: global branch");
  ok &= require(run_branch("sweep60_hot02", 0.2F, false, 0), "sweep: hot-0.2 branch");
  ok &= require(run_branch("sweep60_hot005", 0.05F, false, 0), "sweep: hot-0.05 branch");
  ok &= require(run_branch("sweep60_hot05", 0.5F, false, 0), "sweep: hot-0.5 branch");

  // random with the SAME active count as hot-0.2
  {
    auto session = restoreSolverFromCheckpoint(checkpoint_path);
    ok &= require(session != nullptr, "sweep: random branch must restore");
    session->buildHotOverflowScope(0.2F, 0.5F);
    size_t active_count = 0;
    for (float coeff : session->movementCoeffs()) {
      active_count += (coeff >= 1.0F) ? 1 : 0;
    }
    auto rnd = restoreSolverFromCheckpoint(checkpoint_path);
    ok &= require(rnd != nullptr, "sweep: random branch must restore");
    rnd->buildRandomScope(active_count, 0.5F, 42);
    dumpScopeStats(rnd->movementCoeffs(), "sweep60_random42");
    ok &= require(rnd->advanceAcceptedIterations(20) == ipl::GPAdvanceOutcome::kBudgetReached, "sweep: random branch must finish");
    rnd->publishPlacement();
    PlacerDBInst.updateTopoManager();
    PlacerDBInst.updateGridManager();
    const auto& all_records = rnd->iterationRecords();
    std::filesystem::create_directories(scenarioRoot("sweep60_random42"));
    std::ofstream out(scenarioRoot("sweep60_random42") + "/records.txt");
    for (auto it = all_records.begin() + record_offset; it != all_records.end(); ++it) {
      out << it->iter << ' ' << it->hpwl << ' ' << it->overflow << ' ' << it->step_length << ' ' << it->gradient_norm << '\n';
    }
    ok &= require(dumpCoordinates("sweep60_random42"), "sweep: random branch must dump");
  }

  iPLAPIInst.destoryInst();
  return ok ? EXIT_SUCCESS : EXIT_FAILURE;
}

// Seed plumbing: same seed reproduces the same placement; a different seed
// produces a different one (candidate-branching requirement).
int runSeedVary()
{
  bool ok = true;
  const auto run_start = [&](int32_t seed) {
    ipl::GPRunRequest request;
    request.mode = ipl::GPRunMode::kStart;
    request.accepted_iterations = 10;
    request.random_init = true;
    request.seed = seed;
    const auto result = iPLAPIInst.gpRun(request);
    return result.ok;
  };

  ok &= require(run_start(42), "seed: start with seed 42 must succeed");
  ok &= require(dumpCoordinates("seed42a"), "seed: must dump seed-42 run A");
  iPLAPIInst.gpCloseSession();

  ok &= require(run_start(42), "seed: second start with seed 42 must succeed");
  ok &= require(dumpCoordinates("seed42b"), "seed: must dump seed-42 run B");
  iPLAPIInst.gpCloseSession();

  ok &= require(run_start(43), "seed: start with seed 43 must succeed");
  ok &= require(dumpCoordinates("seed43"), "seed: must dump seed-43 run");
  iPLAPIInst.gpCloseSession();

  iPLAPIInst.destoryInst();
  return ok ? EXIT_SUCCESS : EXIT_FAILURE;
}

int runValidate()
{
  bool ok = true;

  // advance without a session -> rejected
  ipl::GPRunRequest advance_request;
  advance_request.mode = ipl::GPRunMode::kAdvance;
  const auto no_session = iPLAPIInst.gpRun(advance_request);
  ok &= require(!no_session.ok && no_session.stop_reason == ipl::GPStopReason::kRejected,
                "advance without a session must be rejected");

  // resume without a checkpoint path -> rejected
  ipl::GPRunRequest resume_no_path;
  resume_no_path.mode = ipl::GPRunMode::kResume;
  const auto no_path = iPLAPIInst.gpRun(resume_no_path);
  ok &= require(!no_path.ok && no_path.stop_reason == ipl::GPStopReason::kRejected,
                "resume without checkpoint_path must be rejected");

  // resume with a nonexistent checkpoint -> rejected
  ipl::GPRunRequest resume_bogus;
  resume_bogus.mode = ipl::GPRunMode::kResume;
  resume_bogus.checkpoint_path = "/tmp/ipl_gp_session_test/does_not_exist.json";
  const auto bogus = iPLAPIInst.gpRun(resume_bogus);
  ok &= require(!bogus.ok && bogus.stop_reason == ipl::GPStopReason::kRejected,
                "resume with a nonexistent checkpoint must be rejected");

  // zero iterations -> rejected
  ipl::GPRunRequest zero_request;
  zero_request.mode = ipl::GPRunMode::kStart;
  zero_request.accepted_iterations = 0;
  const auto zero = iPLAPIInst.gpRun(zero_request);
  ok &= require(!zero.ok && zero.stop_reason == ipl::GPStopReason::kRejected, "zero-iteration start must be rejected");
  ok &= require(!iPLAPIInst.gpSessionActive(), "rejected start must not leave a session behind");

  // start with keep-init (no RandomPlace) succeeds
  ipl::GPRunRequest keep_request;
  keep_request.mode = ipl::GPRunMode::kStart;
  keep_request.accepted_iterations = 5;
  keep_request.random_init = false;
  const auto keep = iPLAPIInst.gpRun(keep_request);
  ok &= require(keep.ok && keep.executed_iterations == 5, "keep-init start must run the requested iterations");

  // second start while a session is active -> rejected
  ipl::GPRunRequest second_start;
  second_start.mode = ipl::GPRunMode::kStart;
  const auto busy = iPLAPIInst.gpRun(second_start);
  ok &= require(!busy.ok && busy.stop_reason == ipl::GPStopReason::kRejected, "start with an active session must be rejected");

  // close discards the session; start works again
  iPLAPIInst.gpCloseSession();
  ok &= require(!iPLAPIInst.gpSessionActive(), "close must discard the session");
  const auto again = iPLAPIInst.gpRun(keep_request);
  ok &= require(again.ok, "start after close must succeed");
  iPLAPIInst.gpCloseSession();

  iPLAPIInst.destoryInst();
  return ok ? EXIT_SUCCESS : EXIT_FAILURE;
}

}  // namespace

int main(int argc, char** argv)
{
  if (argc < 2) {
    std::cerr << "usage: " << argv[0] << " --scenario {seg20|seg40|seg10x2|observe|ckpt_save|ckpt_resume|resume_inproc|"
              << "seg40_cg|ckpt_save_cg|ckpt_resume_cg|seg40_mt|ckpt_save_mt|ckpt_resume_mt|conv_mid|diverge|mismatch|invalidate|relinearize|legacy|full|validate}\n";
    return EXIT_FAILURE;
  }
  const std::string arg = argv[1];
  const std::string scenario = (arg.rfind("--scenario=", 0) == 0) ? arg.substr(11) : argv[2];

  if (scenario == "seg40_cg" || scenario == "ckpt_save_cg" || scenario == "ckpt_resume_cg") {
    if (!initDesign(scenario, IPL_TEST_CONFIG_PATH_CONGESTION)) {
      return EXIT_FAILURE;
    }
  } else if (scenario == "seg40_mt" || scenario == "ckpt_save_mt" || scenario == "ckpt_resume_mt") {
    if (!initDesign(scenario, IPL_TEST_CONFIG_PATH_MULTITHREAD)) {
      return EXIT_FAILURE;
    }
  } else if (scenario == "diverge") {
    if (!initDesign(scenario, IPL_TEST_CONFIG_PATH_DIVERGENCE)) {
      return EXIT_FAILURE;
    }
  } else if (scenario == "mismatch") {
    if (!initDesign(scenario, IPL_TEST_CONFIG_PATH_MODIFIED)) {
      return EXIT_FAILURE;
    }
  } else if (!initDesign(scenario)) {
    return EXIT_FAILURE;
  }

  if (scenario == "seg20") {
    return runSeg20();
  }
  if (scenario == "seg40") {
    return runSeg40();
  }
  if (scenario == "seg10x2") {
    return runSegmented(false);
  }
  if (scenario == "observe") {
    return runSegmented(true);
  }
  if (scenario == "ckpt_save") {
    return runCheckpointSave();
  }
  if (scenario == "ckpt_resume") {
    return runCheckpointResume();
  }
  if (scenario == "seg40_cg") {
    return runSeg40Congestion();
  }
  if (scenario == "ckpt_save_cg") {
    return runCheckpointSaveCongestion();
  }
  if (scenario == "ckpt_resume_cg") {
    return runCheckpointResumeCongestion();
  }
  if (scenario == "seg40_mt") {
    return runSeg40MultiThread();
  }
  if (scenario == "ckpt_save_mt") {
    return runCheckpointSaveMultiThread();
  }
  if (scenario == "ckpt_resume_mt") {
    return runCheckpointResumeMultiThread();
  }
  if (scenario == "conv_mid") {
    return runConvergeMid();
  }
  if (scenario == "diverge") {
    return runDiverge();
  }
  if (scenario == "mismatch") {
    return runMismatch();
  }
  if (scenario == "invalidate") {
    return runInvalidate();
  }
  if (scenario == "relinearize") {
    return runRelinearize();
  }
  if (scenario == "local_degenerate") {
    return runLocalDegenerate();
  }
  if (scenario == "local_context_frozen") {
    return runLocalContextFrozen();
  }
  if (scenario == "local_control") {
    return runLocalControl();
  }
  if (scenario == "local_ablate") {
    return runLocalAblate();
  }
  if (scenario == "local_sweep") {
    return runLocalSweep();
  }
  if (scenario == "seed_vary") {
    return runSeedVary();
  }
  if (scenario == "resume_inproc") {
    return runResumeInProc();
  }
  if (scenario == "legacy") {
    return runLegacy();
  }
  if (scenario == "full") {
    return runSessionFull();
  }
  if (scenario == "validate") {
    return runValidate();
  }

  std::cerr << "unknown scenario: " << scenario << '\n';
  return EXIT_FAILURE;
}
