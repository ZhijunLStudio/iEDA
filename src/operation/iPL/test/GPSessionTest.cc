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

bool initDesign(const std::string& scenario)
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
  iPLAPIInst.initAPI(IPL_TEST_CONFIG_PATH, idb_builder);
  return true;
}

bool dumpCoordinates(const std::string& scenario, const std::string& file_name = "coords.txt")
{
  auto* idb_builder = dmInst->get_idb_builder();
  auto* design = idb_builder->get_def_service()->get_design();
  if (design == nullptr) {
    return false;
  }

  std::vector<std::string> lines;
  for (auto* inst : design->get_instance_list()->get_instance_list()) {
    auto* coord = inst->get_coordinate();
    lines.push_back(inst->get_name() + " " + std::to_string(coord->get_x()) + " " + std::to_string(coord->get_y()));
  }
  std::sort(lines.begin(), lines.end());

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
    std::cerr << "usage: " << argv[0]
              << " --scenario {seg20|seg40|seg10x2|observe|ckpt_save|ckpt_resume|resume_inproc|legacy|full|validate}\n";
    return EXIT_FAILURE;
  }
  const std::string arg = argv[1];
  const std::string scenario = (arg.rfind("--scenario=", 0) == 0) ? arg.substr(11) : argv[2];

  if (!initDesign(scenario)) {
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
