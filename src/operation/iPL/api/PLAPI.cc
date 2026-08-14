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
/*
 * @Author: S.J Chen
 * @Date: 2022-10-27 16:17:57
 * @LastEditors: Shijian Chen  chenshj@pcl.ac.cn
 * @LastEditTime: 2023-03-11 14:36:48
 * @FilePath: /irefactor/src/operation/iPL/api/PLAPI.cc
 * @Description:
 */
#include "PLAPI.hh"

#include <algorithm>
#include <filesystem>
#include <fstream>
#include <system_error>

#include "BufferInserter.hh"
#include "CenterPlace.hh"
#include "DetailPlacer.hh"
#include "IDBWrapper.hh"
#include "LayoutChecker.hh"
#include "Legalizer.hh"
#include "Log.hh"
#include "MacroPlacer.hh"
#include "NesterovPlace.hh"
#include "PlacerDB.hh"
#include "PostGP.hh"
#include "RandomPlace.hh"
#include "SteinerWirelength.hh"
#include "congestion_db.h"
#include "feature_ipl.h"
#include "netlist/Net.hh"
#include "src/MapFiller.h"
#include "timing_db.hh"
#include "wirelength_db.h"
#include "json/json.hpp"
namespace ipl {

namespace {

auto hasRoutableNet() -> bool
{
  return std::any_of(PlacerDBInst.get_design()->get_net_list().begin(), PlacerDBInst.get_design()->get_net_list().end(),
                     [](const Net* net) { return net != nullptr && net->get_pins().size() > 1U; });
}

auto stageStatusJson(const PlacementStageStatus& status) -> nlohmann::json
{
  return {{"status", placementStatusCodeName(status.code)},
          {"stage", status.stage},
          {"message", status.message},
          {"entered", status.entered},
          {"completed", status.completed},
          {"skipped", status.skipped},
          {"execution_success", status.execution_success},
          {"quality_success", status.quality_success},
          {"metrics_valid", status.metrics_valid},
          {"legal", status.legal},
          {"overflow", status.overflow},
          {"target_overflow", status.target_overflow},
          {"hpwl", status.hpwl},
          {"metric_before", status.metric_before},
          {"metric_after", status.metric_after},
          {"changed_count", status.changed_count},
          {"exhibit", status.exhibit}};
}

auto nesterovIterationExhibit(const std::vector<NesterovIterationRecord>& records) -> std::vector<std::string>
{
  std::vector<std::string> exhibit;
  exhibit.reserve(records.size());
  for (const auto& record : records) {
    exhibit.push_back(nlohmann::json{{"iter", record.iter},
                                    {"hpwl", record.hpwl},
                                    {"overflow", record.overflow},
                                    {"step_length", record.step_length},
                                    {"gradient_norm", record.gradient_norm},
                                    {"density_penalty", record.density_penalty},
                                    {"route_util", record.route_util},
                                    {"quad_penalty_enabled", record.quad_penalty_enabled},
                                    {"entropy_injected", record.entropy_injected}}
                          .dump());
  }
  return exhibit;
}

}  // namespace

// NOLINTBEGIN
ieval::TimingPin* wrapTimingTruePin(Node* node);
ieval::TimingPin* wrapTimingFakePin(int id, Point<int32_t> coordi);
// NOLINTEND

PLAPI& PLAPI::getInst()
{
  if (!_s_ipl_api_instance) {
    _s_ipl_api_instance = new PLAPI();
  }

  return *_s_ipl_api_instance;
}

void PLAPI::destoryInst()
{
  if (_s_ipl_api_instance->isAbucasLGStarted()) {
    LegalizerInst.destoryInst();
  }

  if (_s_ipl_api_instance->isPlacerDBStarted()) {
    PlacerDBInst.destoryInst();
  }

  if (_s_ipl_api_instance) {
    delete _s_ipl_api_instance;
    _s_ipl_api_instance = nullptr;
  }
}

PLAPI::~PLAPI()
{
  delete _external_api;
  delete _reporter;
}

void PLAPI::initAPI(std::string pl_json_path, idb::IdbBuilder* idb_builder)
{
  _flow_status = PlacementFlowStatus{};
  _external_api = new ExternalAPI();
  _reporter = new PLReporter(_external_api);

  // create external_api and reporter ptr
  createPLDirectory();

  char config[] = "info_ipl_glog";
  char* argv[] = {config};

  std::string log_home_path = this->obtainTargetDir() + "/pl/log/";
  // std::string design_name = idb_builder->get_def_service()->get_design()->get_design_name();
  // std::string home_path = "./evaluation_task/benchmark/" + design_name + "/pl_reports/";

  Log::makeSureDirectoryExist(log_home_path);
  Log::init(argv, log_home_path);
  IDBWrapper* idb_wrapper = new IDBWrapper(idb_builder);
  PlacerDBInst.initPlacerDB(pl_json_path, idb_wrapper);

  // prepare sta for timing aware mode placement
  if (PlacerDBInst.get_placer_config()->isTimingEffort()) {
    // sta has not been initialized
    if (!this->isSTAStarted()) {
      LOG_INFO << "Try to apply to start iSTA";
      // apply to start sta
      std::string sta_home_path = this->obtainTargetDir() + "/sta";
      this->initSTA(sta_home_path, false);

      // tmp for evalution.
      // std::string design_name = PlacerDBInst.get_design()->get_design_name();
      // std::string sta_path = "./evaluation_task/benchmark/" + design_name + "/sta_reports/sta";
      // this->modifySTAOutputDir(sta_path);

      this->updateSTATiming();
      PlacerDBInst.get_topo_manager()->updateALLNodeTopoId();
    }

    updateSequentialProperty();

    LOG_INFO << "Sucessfully update sequential property, the latest instance and net infomations are as follow: ";
    PlacerDBInst.printInstanceInfo();
    PlacerDBInst.printNetInfo();
  }
}

void PLAPI::createPLDirectory()
{
  std::string pl_dir = this->obtainTargetDir();
  if (pl_dir == "") {
    pl_dir = ".";
  }
  // create log and report folder
  if (!std::filesystem::exists(pl_dir + "/pl/log")) {
    if (std::filesystem::create_directories(pl_dir + "/pl/log")) {
      LOG_INFO << "Create folder " + pl_dir + "/pl/log for iPL log";
    } else {
      LOG_ERROR << "Cannot create " + pl_dir + "/pl/log for iPL log";
    }
  }
  if (!std::filesystem::exists(pl_dir + "/pl/report")) {
    if (std::filesystem::create_directories(pl_dir + "/pl/report")) {
      LOG_INFO << "Create folder " + pl_dir + "/pl/report for iPL report";
    } else {
      LOG_ERROR << "Cannot create " + pl_dir + "/pl/report for iPL report";
    }
  }
  if (!std::filesystem::exists(pl_dir + "/pl/plot")) {
    if (std::filesystem::create_directories(pl_dir + "/pl/plot")) {
      LOG_INFO << "Create folder " + pl_dir + "/pl/plot for iPL plot";
    } else {
      LOG_ERROR << "Cannot create " + pl_dir + "/pl/plot for iPL plot";
    }
  }
  if (!std::filesystem::exists(pl_dir + "/pl/gui")) {
    if (std::filesystem::create_directories(pl_dir + "/pl/gui")) {
      LOG_INFO << "Create folder " + pl_dir + "/pl/gui for iPL gui";
    } else {
      LOG_ERROR << "Cannot create " + pl_dir + "/pl/gui for iPL gui";
    }
  }
  if (!std::filesystem::exists(pl_dir + "/pl/density")) {
    if (std::filesystem::create_directories(pl_dir + "/pl/density")) {
      LOG_INFO << "Create folder " + pl_dir + "/pl/density for iPL density map";
    } else {
      LOG_ERROR << "Cannot create " + pl_dir + "/pl/density for iPL density map";
    }
  }
}

bool PLAPI::failInjectedStage(const std::string& stage, PlacementStatusCode code, const std::string& reason)
{
  if (!shouldInjectFailure(stage)) {
    return false;
  }
  _flow_status = PlacementFlowStatus{};
  _flow_status.failed_stage = stage;
  _flow_status.overall_reason = reason;
  auto status = PlacementStatusEvaluator::stage(stage, code, false, false, false, reason);
  if (stage == "macro_placement") {
    _flow_status.macro_placement = status;
  } else if (stage == "global_placement") {
    _flow_status.global_placement = status;
    _flow_status.gp_ran = true;
  } else if (stage == "legalization") {
    _flow_status.legalization = status;
    _flow_status.lg_ran = true;
  } else if (stage == "detail_placement") {
    _flow_status.detail_placement = status;
  } else if (stage == "post_global_placement") {
    _flow_status.post_global_placement = status;
  } else {
    _flow_status.artifact = PlacementStatusEvaluator::artifact(false, reason);
  }
  writePlacementStatus();
  return true;
}

bool PLAPI::writePlacementStatus()
{
  if (_flow_status.flow_complete && shouldInjectFailure("artifact")) {
    _failure_injection_stage.clear();
    _flow_status.flow_complete = false;
    _flow_status.artifact = PlacementStatusEvaluator::artifact(false, "failure injected before artifact publication");
    _flow_status.setFailure(_flow_status.artifact);
    return false;
  }
  if (!_flow_status.artifact.entered) {
    _flow_status.artifact = PlacementStatusEvaluator::artifact(true);
  }

  PlacementStatusCode overall_code = PlacementStatusCode::kNotRun;
  const PlacementStageStatus* stages[] = {&_flow_status.macro_placement,
                                          &_flow_status.global_placement,
                                          &_flow_status.buffer_insertion,
                                          &_flow_status.network_flow,
                                          &_flow_status.legalization,
                                          &_flow_status.post_global_placement,
                                          &_flow_status.detail_placement,
                                          &_flow_status.artifact};
  for (const auto* stage : stages) {
    if (stage->entered && (!stage->execution_success || !stage->quality_success)) {
      overall_code = stage->code;
      break;
    }
    if (stage->entered) {
      overall_code = stage->code;
    }
  }

  nlohmann::json summary{{"schema_version", 1},
                         {"status", placementStatusCodeName(overall_code)},
                         {"flow_complete", _flow_status.flow_complete},
                         {"execution_success", _flow_status.executionSuccess()},
                         {"quality_success", _flow_status.qualitySuccess()},
                         {"strict_success", _flow_status.strictSuccess()},
                         {"failed_stage", _flow_status.failed_stage},
                         {"reason", _flow_status.overall_reason},
                         {"macro_placement", stageStatusJson(_flow_status.macro_placement)},
                         {"global_placement", stageStatusJson(_flow_status.global_placement)},
                         {"buffer_insertion", stageStatusJson(_flow_status.buffer_insertion)},
                         {"network_flow", stageStatusJson(_flow_status.network_flow)},
                         {"legalization", stageStatusJson(_flow_status.legalization)},
                         {"post_global_placement", stageStatusJson(_flow_status.post_global_placement)},
                         {"detail_placement", stageStatusJson(_flow_status.detail_placement)},
                         {"artifact", stageStatusJson(_flow_status.artifact)}};

  const std::filesystem::path output_path = std::filesystem::path(obtainTargetDir()) / "pl" / "report" / "place_summary.json";
  const std::filesystem::path stage_report_path = output_path.parent_path() / "ipl_stage_report.json";
  const std::string serialized_summary = summary.dump(2) + '\n';
  for (const auto& artifact_path : {output_path, stage_report_path}) {
    const std::filesystem::path temporary_path = artifact_path.string() + ".tmp";
    {
      std::ofstream stream(temporary_path);
      if (!stream.good()) {
        _flow_status.artifact = PlacementStatusEvaluator::artifact(false, "cannot open placement status artifact");
        _flow_status.setFailure(_flow_status.artifact);
        LOG_ERROR << "Cannot write placement status artifact: " << temporary_path;
        return false;
      }
      stream << serialized_summary;
      stream.close();
      if (!stream) {
        _flow_status.artifact = PlacementStatusEvaluator::artifact(false, "failed while writing placement status artifact");
        _flow_status.setFailure(_flow_status.artifact);
        LOG_ERROR << "Failed while writing placement status artifact: " << temporary_path;
        return false;
      }
    }
    std::error_code error;
    std::filesystem::rename(temporary_path, artifact_path, error);
    if (error) {
      _flow_status.artifact
          = PlacementStatusEvaluator::artifact(false, "cannot publish placement status artifact: " + error.message());
      _flow_status.setFailure(_flow_status.artifact);
      LOG_ERROR << "Cannot publish placement status artifact " << artifact_path << ": " << error.message();
      return false;
    }
  }
  return true;
}

void PLAPI::runIncrementalFlow()
{
  resetFlowStatus();
  if (!runLG()) {
    LOG_FATAL << "Incremental flow legalization failed; see place_summary.json.";
    return;
  }
  notifyPLWLInfo(1);
  reportPLInfo();
  if (!writeBackSourceDataBase()) {
    return;
  }
  _flow_status.flow_complete = true;
  writePlacementStatus();
}

/*****************************Timing-driven Placement: Start*****************************/
double PLAPI::obtainPinEarlySlack(std::string pin_name)
{
  return _external_api->obtainPinEarlySlack(pin_name);
}

double PLAPI::obtainPinLateSlack(std::string pin_name)
{
  return _external_api->obtainPinLateSlack(pin_name);
}

double PLAPI::obtainPinEarlyArrivalTime(std::string pin_name)
{
  return _external_api->obtainPinEarlyArrivalTime(pin_name);
}

double PLAPI::obtainPinLateArrivalTime(std::string pin_name)
{
  return _external_api->obtainPinLateArrivalTime(pin_name);
}

double PLAPI::obtainPinEarlyRequiredTime(std::string pin_name)
{
  return _external_api->obtainPinEarlyRequiredTime(pin_name);
}

double PLAPI::obtainPinLateRequiredTime(std::string pin_name)
{
  return _external_api->obtainPinLateRequiredTime(pin_name);
}

double PLAPI::obtainWNS(const char* clock_name, ista::AnalysisMode mode)
{
  return _external_api->obtainWNS(clock_name, mode);
}

double PLAPI::obtainTNS(const char* clock_name, ista::AnalysisMode mode)
{
  return _external_api->obtainTNS(clock_name, mode);
}

double PLAPI::obtainEarlyWNS(const char* clock_name)
{
  return _external_api->obtainWNS(clock_name, ista::AnalysisMode::kMin);
}

double PLAPI::obtainEarlyTNS(const char* clock_name)
{
  return _external_api->obtainTNS(clock_name, ista::AnalysisMode::kMin);
}

double PLAPI::obtainLateWNS(const char* clock_name)
{
  return _external_api->obtainWNS(clock_name, ista::AnalysisMode::kMax);
}

double PLAPI::obtainLateTNS(const char* clock_name)
{
  return _external_api->obtainTNS(clock_name, ista::AnalysisMode::kMax);
}

void PLAPI::updateTiming(TopologyManager* topo_manager)
{
  SteinerWirelength steiner_wl(topo_manager);
  steiner_wl.updateAllNetWorkPointPair();

  std::vector<ieval::TimingNet*> timing_net_list;
  timing_net_list.reserve(topo_manager->get_network_list().size());
  for (auto* network : topo_manager->get_network_list()) {
    const auto& point_pair_list = steiner_wl.obtainPointPairList(network);
    ieval::TimingNet* timing_net = generateTimingNet(network, point_pair_list);
    timing_net_list.push_back(timing_net);
  }
  _external_api->updateEvalTiming(timing_net_list, PlacerDBInst.get_layout()->get_database_unit());
}

void PLAPI::updatePartOfTiming(TopologyManager* topo_manager,
                               std::map<int32_t, std::vector<std::pair<Point<int32_t>, Point<int32_t>>>>& net_id_to_points_map)
{
  std::vector<ieval::TimingNet*> timing_net_list;
  timing_net_list.reserve(net_id_to_points_map.size());

  for (auto net_pair : net_id_to_points_map) {
    NetWork* network = topo_manager->findNetworkById(net_pair.first);
    ieval::TimingNet* timing_net = generateTimingNet(network, net_pair.second);
    timing_net_list.push_back(timing_net);
  }

  _external_api->updateEvalTiming(timing_net_list, PlacerDBInst.get_layout()->get_database_unit());
}

void PLAPI::updateTimingInstMovement(TopologyManager* topo_manager,
                                     std::map<int32_t, std::vector<std::pair<Point<int32_t>, Point<int32_t>>>> net_id_to_points_map,
                                     std::vector<std::string> moved_inst_list)
{
  std::vector<ieval::TimingNet*> timing_net_list;
  timing_net_list.reserve(net_id_to_points_map.size());

  for (auto net_pair : net_id_to_points_map) {
    NetWork* network = topo_manager->findNetworkById(net_pair.first);
    ieval::TimingNet* timing_net = generateTimingNet(network, net_pair.second);
    timing_net_list.push_back(timing_net);
  }

  _external_api->updateEvalTiming(timing_net_list, moved_inst_list, 3, PlacerDBInst.get_layout()->get_database_unit());
}

float PLAPI::obtainPinCap(std::string inst_pin_name)
{
  return _external_api->obtainPinCap(inst_pin_name);
}

float PLAPI::obtainAvgWireResUnitLengthUm()
{
  return _external_api->obtainAvgWireResUnitLengthUm();
}

float PLAPI::obtainAvgWireCapUnitLengthUm()
{
  return _external_api->obtainAvgWireCapUnitLengthUm();
}

float PLAPI::obtainInstOutPinRes(std::string inst_name, std::string port_name)
{
  auto* inst = PlacerDBInst.get_design()->find_instance(inst_name);
  auto* cell = inst->get_cell_master();
  std::string cell_name = cell->get_name();
  return _external_api->obtainInstOutPinRes(cell_name, port_name);
}

ieval::TimingNet* PLAPI::generateTimingNet(NetWork* network,
                                           const std::vector<std::pair<ipl::Point<int32_t>, ipl::Point<int32_t>>>& point_pair_list)
{
  ieval::TimingNet* timing_net = new ieval::TimingNet();
  timing_net->net_name = network->get_name();
  std::map<Point<int32_t>, Node*, PointCMP> point_to_node;
  std::map<Point<int32_t>, ieval::TimingPin*, PointCMP> point_to_timing_pin;
  for (auto* node : network->get_node_list()) {
    const auto& node_loc = node->get_location();
    auto iter = point_to_node.find(node_loc);
    if (iter != point_to_node.end()) {
      auto* timing_pin_1 = wrapTimingTruePin(node);
      auto* timing_pin_2 = wrapTimingTruePin(iter->second);
      timing_net->pin_pair_list.push_back(std::make_pair(timing_pin_1, timing_pin_2));
    } else {
      point_to_node.emplace(node_loc, node);
    }
  }

  int fake_pin_id = 0;
  for (auto point_pair : point_pair_list) {
    if (point_pair.first == point_pair.second) {
      continue;
    }
    ieval::TimingPin* timing_pin_1 = nullptr;
    ieval::TimingPin* timing_pin_2 = nullptr;
    auto iter_1 = point_to_node.find(point_pair.first);
    if (iter_1 != point_to_node.end()) {
      auto iter_1_1 = point_to_timing_pin.find(point_pair.first);
      if (iter_1_1 != point_to_timing_pin.end()) {
        timing_pin_1 = iter_1_1->second;
      } else {
        timing_pin_1 = wrapTimingTruePin(iter_1->second);
        point_to_timing_pin.emplace(point_pair.first, timing_pin_1);
      }
    } else {
      auto iter_1_2 = point_to_timing_pin.find(point_pair.first);
      if (iter_1_2 != point_to_timing_pin.end()) {
        timing_pin_1 = iter_1_2->second;
      } else {
        timing_pin_1 = wrapTimingFakePin(fake_pin_id++, point_pair.first);
        point_to_timing_pin.emplace(point_pair.first, timing_pin_1);
      }
    }
    auto iter_2 = point_to_node.find(point_pair.second);
    if (iter_2 != point_to_node.end()) {
      auto iter_2_1 = point_to_timing_pin.find(point_pair.second);
      if (iter_2_1 != point_to_timing_pin.end()) {
        timing_pin_2 = iter_2_1->second;
      } else {
        timing_pin_2 = wrapTimingTruePin(iter_2->second);
        point_to_timing_pin.emplace(point_pair.second, timing_pin_2);
      }
    } else {
      auto iter_2_2 = point_to_timing_pin.find(point_pair.second);
      if (iter_2_2 != point_to_timing_pin.end()) {
        timing_pin_2 = iter_2_2->second;
      } else {
        timing_pin_2 = wrapTimingFakePin(fake_pin_id++, point_pair.second);
        point_to_timing_pin.emplace(point_pair.second, timing_pin_2);
      }
    }
    timing_net->pin_pair_list.push_back(std::make_pair(timing_pin_1, timing_pin_2));
  }
  return timing_net;
}

void PLAPI::destroyTimingEval()
{
  _external_api->destroyTimingEval();
}
/*****************************Timing-driven Placement: END*****************************/

bool PLAPI::runFlow()
{
  return runFlowResult().success;
}

PlacementFlowResult PLAPI::runFlowResult()
{
  resetFlowStatus();
  _flow_status.macro_placement = PlacementStatusEvaluator::skippedStage("macro_placement", "not entered");
  _flow_status.buffer_insertion = PlacementStatusEvaluator::skippedStage("buffer_insertion", "configuration disabled");
  _flow_status.network_flow = PlacementStatusEvaluator::skippedStage("network_flow", "configuration disabled");
  _flow_status.post_global_placement = PlacementStatusEvaluator::skippedStage("post_global_placement", "not selected");
  _flow_status.detail_placement = PlacementStatusEvaluator::skippedStage("detail_placement", "not selected");

  const auto abort_flow = [this](const std::string& stage, const std::string& reason) {
    _flow_status.failed_stage = stage;
    _flow_status.overall_reason = reason;
    _flow_status.flow_complete = false;
    writePlacementStatus();
    LOG_ERROR << reason << "; see place_summary.json.";
    return PlacementFlowResult::fromStatus(_flow_status);
  };

  if (!runMP()) {
    return abort_flow(_flow_status.failed_stage, _flow_status.overall_reason);
  }
  if (!runGP()) {
    return abort_flow(_flow_status.failed_stage, _flow_status.overall_reason);
  }
  // printHPWLInfo();
  // printTimingInfo();
  notifyPLWLInfo(0);
  if (PlacerDBInst.get_placer_config()->isTimingEffort() && isSTAStarted()) {
    notifyPLCongestionInfo(0);
    notifyPLTimingInfo(0);
  }

  if (PlacerDBInst.get_placer_config()->get_buffer_config().isMaxLengthOpt()) {
    std::cout << std::endl;
    if (!runBufferInsertion()) {
      return abort_flow(_flow_status.failed_stage, _flow_status.overall_reason);
    }
    printHPWLInfo();
  }

  if (PlacerDBInst.get_placer_config()->get_dp_config().isEnableNetworkflow()) {
    std::cout << std::endl;
    if (!runNetworkFlowSpread()) {
      return abort_flow(_flow_status.failed_stage, _flow_status.overall_reason);
    }
  }

  std::cout << std::endl;
  if (!runLG()) {
    return abort_flow(_flow_status.failed_stage, _flow_status.overall_reason);
  }
  // printHPWLInfo();
  // printTimingInfo();
  notifyPLWLInfo(1);
  if (PlacerDBInst.get_placer_config()->isTimingEffort() && isSTAStarted()) {
    notifyPLCongestionInfo(1);
    notifyPLTimingInfo(1);
  }

  std::cout << std::endl;
  if (PlacerDBInst.get_placer_config()->isTimingEffort() && isSTAStarted()) {
    if (!runPostGP()) {
      return abort_flow(_flow_status.failed_stage, _flow_status.overall_reason);
    }
  } else {
    if (!runDP()) {
      return abort_flow(_flow_status.failed_stage, _flow_status.overall_reason);
    }
  }
  // printHPWLInfo();
  // printTimingInfo();

  notifyPLWLInfo(2);
  if (PlacerDBInst.get_placer_config()->isTimingEffort() && isSTAStarted()) {
    notifyPLCongestionInfo(2);
    notifyPLTimingInfo(2);
  }

  std::cout << std::endl;

  // // update LG Database
  // LOG_INFO << "Repeated execution of legalization to support subsequent incremental legalization";
  // LegalizerInst.updateInstanceList();
  // LegalizerInst.runLegalize();
  // printHPWLInfo();
  // std::cout << std::endl;

  reportPLInfo();
  std::cout << std::endl;
  LOG_INFO << "Log has been writed to dir: ./result/pl/log/";

  if (PlacerDBInst.get_placer_config()->isTimingEffort() && isSTAStarted()) {
    notifySTAUpdateTimingRuntime();
    _reporter->reportTDPEvaluation();
  }

  if (isSTAStarted()) {
    _external_api->destroyTimingEval();
  }

  if (!writeBackSourceDataBase()) {
    return abort_flow(_flow_status.failed_stage, _flow_status.overall_reason);
  }
  _flow_status.flow_complete = true;
  if (!writePlacementStatus()) {
    return PlacementFlowResult::fromStatus(_flow_status);
  }
  if (!_flow_status.qualitySuccess()) {
    LOG_WARNING << "Placement completed with degraded quality; see place_summary.json.";
  }
  return PlacementFlowResult::fromStatus(_flow_status);
}

bool PLAPI::runAiFlow(const std::string& onnx_path, const std::string& normalization_path)
{
  return runAiFlowResult(onnx_path, normalization_path).success;
}

PlacementFlowResult PLAPI::runAiFlowResult(const std::string& onnx_path, const std::string& normalization_path)
{
  resetFlowStatus();
  _flow_status.macro_placement = PlacementStatusEvaluator::skippedStage("macro_placement", "not entered");
  _flow_status.buffer_insertion = PlacementStatusEvaluator::skippedStage("buffer_insertion", "configuration disabled");
  _flow_status.network_flow = PlacementStatusEvaluator::skippedStage("network_flow", "configuration disabled");
  _flow_status.post_global_placement = PlacementStatusEvaluator::skippedStage("post_global_placement", "not selected");
  _flow_status.detail_placement = PlacementStatusEvaluator::skippedStage("detail_placement", "not selected");
  const auto abort_flow = [this](const std::string& stage, const std::string& reason) {
    _flow_status.failed_stage = stage;
    _flow_status.overall_reason = reason;
    _flow_status.flow_complete = false;
    writePlacementStatus();
    LOG_ERROR << reason << "; see place_summary.json.";
    return PlacementFlowResult::fromStatus(_flow_status);
  };

  if (!runMP()) {
    return abort_flow(_flow_status.failed_stage, _flow_status.overall_reason);
  }
  if (!runGP()) {
    return abort_flow(_flow_status.failed_stage, _flow_status.overall_reason);
  }
  notifyPLWLInfo(0);
  if (PlacerDBInst.get_placer_config()->isTimingEffort() && isSTAStarted()) {
    notifyPLCongestionInfo(0);
    notifyPLTimingInfo(0);
  }

  if (PlacerDBInst.get_placer_config()->get_buffer_config().isMaxLengthOpt()) {
    std::cout << std::endl;
    if (!runBufferInsertion()) {
      return abort_flow(_flow_status.failed_stage, _flow_status.overall_reason);
    }
    printHPWLInfo();
  }

  if (PlacerDBInst.get_placer_config()->get_dp_config().isEnableNetworkflow()) {
    std::cout << std::endl;
    if (!runNetworkFlowSpread()) {
      return abort_flow(_flow_status.failed_stage, _flow_status.overall_reason);
    }
  }

  std::cout << std::endl;
  if (!runLG()) {
    return abort_flow(_flow_status.failed_stage, _flow_status.overall_reason);
  }
  notifyPLWLInfo(1);
  if (PlacerDBInst.get_placer_config()->isTimingEffort() && isSTAStarted()) {
    notifyPLCongestionInfo(1);
    notifyPLTimingInfo(1);
  }

  std::cout << std::endl;
  if (PlacerDBInst.get_placer_config()->isTimingEffort() && isSTAStarted()) {
    if (!runPostGP()) {
      return abort_flow(_flow_status.failed_stage, _flow_status.overall_reason);
    }
  } else {
#ifdef ENABLE_AI
    if (!runDPwithAiWireLengthPredictor(onnx_path, normalization_path)) {
      return abort_flow(_flow_status.failed_stage, _flow_status.overall_reason);
    }
#else
    if (!runDP()) {
      return abort_flow(_flow_status.failed_stage, _flow_status.overall_reason);
    }
#endif
  }
  notifyPLWLInfo(2);
  if (PlacerDBInst.get_placer_config()->isTimingEffort() && isSTAStarted()) {
    notifyPLCongestionInfo(2);
    notifyPLTimingInfo(2);
  }

  std::cout << std::endl;

  reportPLInfo();
  std::cout << std::endl;
  LOG_INFO << "Log has been writed to dir: ./result/pl/log/";
  if (PlacerDBInst.get_placer_config()->isTimingEffort() && isSTAStarted()) {
    notifySTAUpdateTimingRuntime();
    _reporter->reportTDPEvaluation();
  }

  if (isSTAStarted()) {
    _external_api->destroyTimingEval();
  }

  if (!writeBackSourceDataBase()) {
    return abort_flow(_flow_status.failed_stage, _flow_status.overall_reason);
  }
  _flow_status.flow_complete = true;
  if (!writePlacementStatus()) {
    return PlacementFlowResult::fromStatus(_flow_status);
  }
  if (!_flow_status.qualitySuccess()) {
    LOG_WARNING << "Placement completed with degraded quality; see place_summary.json.";
  }
  return PlacementFlowResult::fromStatus(_flow_status);
}

void PLAPI::insertLayoutFiller()
{
  notifyPLOriginInfo();
  MapFiller(&PlacerDBInst, PlacerDBInst.get_placer_config()).mapFillerCell();
  PlacerDBInst.updateGridManager();
  _reporter->reportEDAFillerEvaluation();
  reportPLInfo();
  reportLayoutWhiteInfo();
  writeBackSourceDataBase();
}

bool PLAPI::runMP()
{
  if (failInjectedStage("macro_placement", PlacementStatusCode::kMPInfeasible,
                        "failure injected before macro placement")) {
    return false;
  }
  MacroPlacer macro_placer(&PlacerDBInst);
  bool success = macro_placer.runMacroPlacement();
  HPWirelength hpwl(PlacerDBInst.get_topo_manager());
  if (success && macro_placer.get_macro_count() == 0) {
    _flow_status.macro_placement = PlacementStatusEvaluator::skippedStage("macro_placement", "no macros in design");
  } else {
    _flow_status.macro_placement = PlacementStatusEvaluator::macroPlacement(
        success, success, hpwl.obtainTotalWirelength(), success ? "" : "macro placement failed or produced no feasible legal placement");
  }
  _flow_status.macro_placement.exhibit = macro_placer.get_last_exhibit();
  _flow_status.setFailure(_flow_status.macro_placement);
  writePlacementStatus();
  return success;
}

bool PLAPI::runGP()
{
  return runGPResult().success;
}

PlacementFlowResult PLAPI::runGPResult()
{
  if (failInjectedStage("global_placement", PlacementStatusCode::kGPInvalidMetric,
                        "failure injected before global placement")) {
    return PlacementFlowResult::fromStage(_flow_status.global_placement);
  }
  auto transaction = PlacerDBInst.beginStageTransaction("global_placement");
  if (!transaction.active) {
    _flow_status.global_placement = PlacementStatusEvaluator::stage(
        "global_placement", PlacementStatusCode::kGPInvalidMetric, false, false, false,
        "global placement could not start a PlacerDB transaction");
    _flow_status.gp_ran = true;
    _flow_status.setFailure(_flow_status.global_placement);
    writePlacementStatus();
    return PlacementFlowResult::fromStage(_flow_status.global_placement);
  }

  // CenterPlace(&PlacerDBInst).runCenterPlace();
  RandomPlace(&PlacerDBInst).runRandomPlace();
  NesterovPlace nesterov_place(PlacerDBInst.get_placer_config(), &PlacerDBInst, isJsonOutputEnabled());
  nesterov_place.printNesterovDatabase();
  nesterov_place.runNesterovPlace();
  const auto& gp_run = nesterov_place.lastResult();
  const int64_t changed_instance_count = transaction.changedInstanceCount();

  HPWirelength hpwl(PlacerDBInst.get_topo_manager());
  switch (gp_run.outcome) {
    case NesterovPlaceOutcome::kConverged:
      _flow_status.global_placement = PlacementStatusEvaluator::stage(
          "global_placement", PlacementStatusCode::kOk, true, true, true, gp_run.reason, gp_run.hpwl, gp_run.hpwl,
          changed_instance_count, {});
      break;
    case NesterovPlaceOutcome::kOverflowTargetMiss:
    case NesterovPlaceOutcome::kMaxIter:
      _flow_status.global_placement = PlacementStatusEvaluator::stage(
          "global_placement", PlacementStatusCode::kGPOverflowTargetMiss, true, false, true, gp_run.reason, gp_run.hpwl,
          gp_run.hpwl, changed_instance_count, {});
      break;
    case NesterovPlaceOutcome::kInvalidMetric:
      _flow_status.global_placement = PlacementStatusEvaluator::stage(
          "global_placement", PlacementStatusCode::kGPInvalidMetric, false, false, false, gp_run.reason, gp_run.hpwl, gp_run.hpwl,
          changed_instance_count, {});
      break;
    case NesterovPlaceOutcome::kDiverged:
      _flow_status.global_placement = PlacementStatusEvaluator::stage(
          "global_placement", PlacementStatusCode::kGPDiverged, false, false, false, gp_run.reason, gp_run.hpwl, gp_run.hpwl,
          changed_instance_count, {});
      break;
    case NesterovPlaceOutcome::kNotRun:
      _flow_status.global_placement = PlacementStatusEvaluator::stage(
          "global_placement", PlacementStatusCode::kGPInvalidMetric, false, false, false, "global placement did not run", 0, 0, 0,
          {});
      break;
  }
  _flow_status.global_placement.overflow = gp_run.overflow;
  _flow_status.global_placement.target_overflow = PlacerDBInst.get_placer_config()->get_nes_config().get_target_overflow();
  _flow_status.global_placement.hpwl = gp_run.hpwl;
  _flow_status.global_placement.metric_after = gp_run.hpwl;
  _flow_status.global_placement.exhibit = nesterovIterationExhibit(gp_run.iteration_records);
  _flow_status.gp_ran = true;

  const bool stage_success = _flow_status.global_placement.execution_success && _flow_status.global_placement.quality_success;
  if (stage_success) {
    if (!PlacerDBInst.commitStageTransaction(transaction)) {
      _flow_status.global_placement = PlacementStatusEvaluator::stage(
          "global_placement", PlacementStatusCode::kGPInvalidMetric, false, false, false,
          "global placement could not commit its PlacerDB transaction", gp_run.hpwl, gp_run.hpwl, changed_instance_count);
      _flow_status.global_placement.changed_count = changed_instance_count;
    }
  } else if (!PlacerDBInst.rollbackStageTransaction(transaction)) {
    _flow_status.global_placement.message += "; failed to rollback global placement transaction";
  }

  _flow_status.setFailure(_flow_status.global_placement);
  writePlacementStatus();
  LOG_ERROR_IF(!_flow_status.global_placement.execution_success) << _flow_status.global_placement.message;
  return PlacementFlowResult::fromStage(_flow_status.global_placement);
}

namespace {
GPStopReason mapGpStopReason(NesterovPlaceOutcome outcome)
{
  switch (outcome) {
    case NesterovPlaceOutcome::kConverged:
      return GPStopReason::kTargetReached;
    case NesterovPlaceOutcome::kMaxIter:
      return GPStopReason::kMaxIter;
    case NesterovPlaceOutcome::kOverflowTargetMiss:
      return GPStopReason::kOverflowTargetMiss;
    case NesterovPlaceOutcome::kDiverged:
      return GPStopReason::kDiverged;
    case NesterovPlaceOutcome::kInvalidMetric:
      return GPStopReason::kInvalidMetric;
    case NesterovPlaceOutcome::kNotRun:
      return GPStopReason::kNotRun;
  }
  return GPStopReason::kNotRun;
}
}  // namespace

struct GPSessionState
{
  std::unique_ptr<NesterovPlace> session;
  PlacerDB::StageTransaction transaction;
  size_t record_offset = 0;
  // PlacerDB revision at session start. External tools (LG/DP/...) commit their
  // own stage transactions and bump the revision; a mismatch means the session's
  // solver state (momentum/gradients) no longer matches the design coordinates.
  int64_t base_revision = 0;
};

GPRunResult PLAPI::gpRun(const GPRunRequest& request)
{
  if (request.mode == GPRunMode::kStart) {
    return gpRunStart(request);
  }
  if (request.mode == GPRunMode::kResume) {
    return gpRunResume(request);
  }
  return gpRunAdvance(request);
}

GPRunResult PLAPI::gpRunStart(const GPRunRequest& request)
{
  GPRunResult result;
  result.requested_iterations = request.accepted_iterations;

  if (_gp_session_state != nullptr) {
    // An invalidated session (external LG/DP changed the design) cannot be
    // advanced and is discarded here: the relinearize flow (GP -> LG -> GP)
    // starts fresh from the modified coordinates without an explicit close.
    if (_gp_session_state->base_revision != PlacerDBInst.get_revision()) {
      gpCloseSession();
    } else {
      result.stop_reason = GPStopReason::kRejected;
      result.reason = "gp session already active; close it before starting a new one";
      return result;
    }
  }
  if (request.accepted_iterations <= 0) {
    result.stop_reason = GPStopReason::kRejected;
    result.reason = "accepted_iterations must be positive";
    return result;
  }

  _gp_session_state = std::make_unique<GPSessionState>();
  _gp_session_state->transaction = PlacerDBInst.beginStageTransaction("global_placement");
  if (!_gp_session_state->transaction.active) {
    _flow_status.global_placement = PlacementStatusEvaluator::stage(
        "global_placement", PlacementStatusCode::kGPInvalidMetric, false, false, false,
        "global placement could not start a PlacerDB transaction");
    _flow_status.gp_ran = true;
    _flow_status.setFailure(_flow_status.global_placement);
    writePlacementStatus();
    _gp_session_state.reset();
    result.stop_reason = GPStopReason::kRejected;
    result.reason = "global placement could not start a PlacerDB transaction";
    return result;
  }

  if (request.random_init) {
    RandomPlace(&PlacerDBInst).runRandomPlace(request.seed);
  }
  _gp_session_state->session
      = std::make_unique<NesterovPlace>(PlacerDBInst.get_placer_config(), &PlacerDBInst, isJsonOutputEnabled());
  _gp_session_state->session->printNesterovDatabase();
  _gp_session_state->record_offset = 0;
  _gp_session_state->base_revision = PlacerDBInst.get_revision();

  if (!_gp_session_state->session->initializeSession()) {
    // Initialization already finalized a terminal outcome (empty design,
    // invalid initial gradient, ...); close out through the same terminal path.
    return gpFinalizeTerminal(result);
  }

  return gpRunAdvance(request);
}

GPRunResult PLAPI::gpRunResume(const GPRunRequest& request)
{
  GPRunResult result;
  result.requested_iterations = request.accepted_iterations;

  if (_gp_session_state != nullptr) {
    result.stop_reason = GPStopReason::kRejected;
    result.reason = "gp session already active; close it before resuming from a checkpoint";
    return result;
  }
  if (request.accepted_iterations <= 0) {
    result.stop_reason = GPStopReason::kRejected;
    result.reason = "accepted_iterations must be positive";
    return result;
  }
  if (request.checkpoint_path.empty()) {
    result.stop_reason = GPStopReason::kRejected;
    result.reason = "kResume requires checkpoint_path";
    return result;
  }

  ipl::GPStateCheckpoint checkpoint;
  if (!ipl::loadGPCheckpointFile(request.checkpoint_path, checkpoint)) {
    result.stop_reason = GPStopReason::kRejected;
    result.reason = "cannot load gp checkpoint: " + request.checkpoint_path;
    return result;
  }

  _gp_session_state = std::make_unique<GPSessionState>();
  _gp_session_state->transaction = PlacerDBInst.beginStageTransaction("global_placement");
  if (!_gp_session_state->transaction.active) {
    _flow_status.global_placement = PlacementStatusEvaluator::stage(
        "global_placement", PlacementStatusCode::kGPInvalidMetric, false, false, false,
        "global placement could not start a PlacerDB transaction");
    _flow_status.gp_ran = true;
    _flow_status.setFailure(_flow_status.global_placement);
    writePlacementStatus();
    _gp_session_state.reset();
    result.stop_reason = GPStopReason::kRejected;
    result.reason = "global placement could not start a PlacerDB transaction";
    return result;
  }

  _gp_session_state->session
      = std::make_unique<NesterovPlace>(PlacerDBInst.get_placer_config(), &PlacerDBInst, isJsonOutputEnabled());
  _gp_session_state->session->printNesterovDatabase();
  if (!_gp_session_state->session->restoreCheckpoint(checkpoint)) {
    PlacerDBInst.rollbackStageTransaction(_gp_session_state->transaction);
    _gp_session_state.reset();
    result.stop_reason = GPStopReason::kRejected;
    result.reason = "gp checkpoint rejected: config fingerprint or design topology mismatch";
    return result;
  }
  // Batch record slicing continues after the restored records.
  _gp_session_state->record_offset = checkpoint.iteration_records.size();
  _gp_session_state->base_revision = PlacerDBInst.get_revision();

  return gpRunAdvance(request);
}

GPRunResult PLAPI::gpRunAdvance(const GPRunRequest& request)
{
  GPRunResult result;
  result.requested_iterations = request.accepted_iterations;

  if (_gp_session_state == nullptr) {
    result.stop_reason = GPStopReason::kRejected;
    result.reason = "no active gp session; call gpRun with mode=kStart first";
    return result;
  }
  if (request.accepted_iterations <= 0) {
    result.stop_reason = GPStopReason::kRejected;
    result.reason = "accepted_iterations must be positive";
    return result;
  }

  // Session invalidation (M3): external tools (LG/DP/manual edits) commit their
  // own transactions and bump the PlacerDB revision. Advancing a session whose
  // coordinates were externally changed would silently reuse stale momentum.
  if (_gp_session_state->base_revision != PlacerDBInst.get_revision()) {
    result.stop_reason = GPStopReason::kRejected;
    result.reason = "gp session invalidated by external placement changes; close it and start with random_init=0 (relinearize)";
    return result;
  }

  const int32_t iter_before = _gp_session_state->session->currentIteration();
  const auto advance = _gp_session_state->session->advanceAcceptedIterations(request.accepted_iterations);
  const int32_t iter_after = _gp_session_state->session->currentIteration();

  result.start_iteration = iter_before + 1;
  result.end_iteration = iter_after;
  result.executed_iterations = iter_after - iter_before;

  // Slice this batch's iteration records out of the cumulative session records.
  const auto& all_records = _gp_session_state->session->iterationRecords();
  if (_gp_session_state->record_offset <= all_records.size()) {
    for (auto it = all_records.begin() + _gp_session_state->record_offset; it != all_records.end(); ++it) {
      GPIterationRecord record;
      record.iter = it->iter;
      record.hpwl = it->hpwl;
      record.overflow = it->overflow;
      record.step_length = it->step_length;
      record.gradient_norm = it->gradient_norm;
      record.density_penalty = it->density_penalty;
      record.route_util = it->route_util;
      record.quad_penalty_enabled = it->quad_penalty_enabled;
      record.entropy_injected = it->entropy_injected;
      result.iteration_records.push_back(record);
    }
  }
  _gp_session_state->record_offset = all_records.size();

  const auto& last = _gp_session_state->session->lastResult();
  result.hpwl = last.hpwl;
  result.overflow = last.overflow;
  result.step_length = last.step_length;
  result.density_penalty = last.density_penalty;

  switch (advance) {
    case GPAdvanceOutcome::kBudgetReached:
      result.ok = true;
      result.session_active = true;
      result.stop_reason = GPStopReason::kBudgetReached;
      // Per-batch publish: make this batch's placement observable without
      // touching solver state (writeBackPlacerDB only reads solver coordinates).
      _gp_session_state->session->publishPlacement();
      PlacerDBInst.updateTopoManager();
      PlacerDBInst.updateGridManager();
      // Checkpoint-per-call (72b): every batch boundary persists the session so
      // a later process can resume it. Save failure keeps the in-memory session
      // usable but must surface as an error to the caller.
      result.checkpoint_path = obtainTargetDir() + "/pl/gp_session_checkpoint.json";
      if (!ipl::saveGPCheckpointFile(result.checkpoint_path, _gp_session_state->session->captureCheckpoint())) {
        result.ok = false;
        result.reason = "batch finished but checkpoint save failed: " + result.checkpoint_path;
      }
      break;
    case GPAdvanceOutcome::kFinished:
      result.ok = true;
      _gp_session_state->session->finishSession();
      PlacerDBInst.updateTopoManager();
      PlacerDBInst.updateGridManager();
      return gpFinalizeTerminal(result);
    case GPAdvanceOutcome::kAlreadyFinished:
      result.reason = "gp session has already reached a terminal condition";
      result.stop_reason = mapGpStopReason(last.outcome);
      return gpFinalizeTerminal(result);
    case GPAdvanceOutcome::kNotInitialized:
      result.ok = false;
      result.reason = "gp session was not initialized";
      result.stop_reason = GPStopReason::kRejected;
      break;
  }
  return result;
}

GPRunResult PLAPI::gpFinalizeTerminal(GPRunResult result)
{
  const auto& gp_run = _gp_session_state->session->lastResult();
  const int64_t changed_instance_count = _gp_session_state->transaction.changedInstanceCount();

  HPWirelength hpwl(PlacerDBInst.get_topo_manager());
  switch (gp_run.outcome) {
    case NesterovPlaceOutcome::kConverged:
      _flow_status.global_placement = PlacementStatusEvaluator::stage(
          "global_placement", PlacementStatusCode::kOk, true, true, true, gp_run.reason, gp_run.hpwl, gp_run.hpwl,
          changed_instance_count, {});
      break;
    case NesterovPlaceOutcome::kOverflowTargetMiss:
    case NesterovPlaceOutcome::kMaxIter:
      _flow_status.global_placement = PlacementStatusEvaluator::stage(
          "global_placement", PlacementStatusCode::kGPOverflowTargetMiss, true, false, true, gp_run.reason, gp_run.hpwl,
          gp_run.hpwl, changed_instance_count, {});
      break;
    case NesterovPlaceOutcome::kInvalidMetric:
      _flow_status.global_placement = PlacementStatusEvaluator::stage(
          "global_placement", PlacementStatusCode::kGPInvalidMetric, false, false, false, gp_run.reason, gp_run.hpwl, gp_run.hpwl,
          changed_instance_count, {});
      break;
    case NesterovPlaceOutcome::kDiverged:
      _flow_status.global_placement = PlacementStatusEvaluator::stage(
          "global_placement", PlacementStatusCode::kGPDiverged, false, false, false, gp_run.reason, gp_run.hpwl, gp_run.hpwl,
          changed_instance_count, {});
      break;
    case NesterovPlaceOutcome::kNotRun:
      _flow_status.global_placement = PlacementStatusEvaluator::stage(
          "global_placement", PlacementStatusCode::kGPInvalidMetric, false, false, false, "global placement did not run", 0, 0, 0,
          {});
      break;
  }
  _flow_status.global_placement.overflow = gp_run.overflow;
  _flow_status.global_placement.target_overflow = PlacerDBInst.get_placer_config()->get_nes_config().get_target_overflow();
  _flow_status.global_placement.hpwl = gp_run.hpwl;
  _flow_status.global_placement.metric_after = gp_run.hpwl;
  _flow_status.global_placement.exhibit = nesterovIterationExhibit(gp_run.iteration_records);
  _flow_status.gp_ran = true;

  const bool stage_success = _flow_status.global_placement.execution_success && _flow_status.global_placement.quality_success;
  if (stage_success) {
    if (!PlacerDBInst.commitStageTransaction(_gp_session_state->transaction)) {
      _flow_status.global_placement = PlacementStatusEvaluator::stage(
          "global_placement", PlacementStatusCode::kGPInvalidMetric, false, false, false,
          "global placement could not commit its PlacerDB transaction", gp_run.hpwl, gp_run.hpwl, changed_instance_count);
      _flow_status.global_placement.changed_count = changed_instance_count;
    }
  } else if (!PlacerDBInst.rollbackStageTransaction(_gp_session_state->transaction)) {
    _flow_status.global_placement.message += "; failed to rollback global placement transaction";
  }

  _flow_status.setFailure(_flow_status.global_placement);
  writePlacementStatus();
  LOG_ERROR_IF(!_flow_status.global_placement.execution_success) << _flow_status.global_placement.message;

  result.ok = !isNesterovHardFailure(gp_run.outcome);
  result.session_active = false;
  result.stop_reason = mapGpStopReason(gp_run.outcome);
  result.hpwl = gp_run.hpwl;
  result.overflow = gp_run.overflow;
  result.step_length = gp_run.step_length;
  result.density_penalty = gp_run.density_penalty;
  result.reason = gp_run.reason;

  _gp_session_state->transaction = PlacerDB::StageTransaction{};
  _gp_session_state->record_offset = 0;
  _gp_session_state.reset();
  return result;
}

void PLAPI::gpCloseSession()
{
  if (_gp_session_state == nullptr) {
    return;
  }
  // Discarding an unfinished session rolls back its stage transaction so the
  // design returns to the pre-session state (72b lineage semantics: close = discard).
  if (_gp_session_state->transaction.active) {
    PlacerDBInst.rollbackStageTransaction(_gp_session_state->transaction);
  }
  _gp_session_state.reset();
}

bool PLAPI::runLG()
{
  if (failInjectedStage("legalization", PlacementStatusCode::kLGSolverFailed,
                        "failure injected before legalization")) {
    return false;
  }
  auto transaction = PlacerDBInst.beginStageTransaction("legalization");
  if (!transaction.active) {
    _flow_status.legalization = PlacementStatusEvaluator::legalization(false, false, 0);
    _flow_status.legalization.message = "legalization could not start a PlacerDB transaction";
    _flow_status.lg_ran = true;
    _flow_status.setFailure(_flow_status.legalization);
    writePlacementStatus();
    return false;
  }

  LegalizerInst.initLegalizer(PlacerDBInst.get_placer_config(), &PlacerDBInst);
  const bool solver_success = LegalizerInst.runLegalize();
  const bool legal = solver_success && checkLegality();
  HPWirelength hpwl(PlacerDBInst.get_topo_manager());
  _flow_status.legalization = PlacementStatusEvaluator::legalization(solver_success, legal, hpwl.obtainTotalWirelength());
  _flow_status.lg_ran = true;

  const bool stage_success = _flow_status.legalization.execution_success && _flow_status.legalization.quality_success;
  if (stage_success) {
    if (!PlacerDBInst.commitStageTransaction(transaction)) {
      _flow_status.legalization = PlacementStatusEvaluator::legalization(false, false, hpwl.obtainTotalWirelength());
      _flow_status.legalization.message = "legalization could not commit its PlacerDB transaction";
    }
  } else if (!PlacerDBInst.rollbackStageTransaction(transaction)) {
    _flow_status.legalization.message += "; failed to rollback legalization transaction";
  }

  _flow_status.setFailure(_flow_status.legalization);
  writePlacementStatus();
  LOG_ERROR_IF(!_flow_status.legalization.execution_success) << _flow_status.legalization.message;
  return _flow_status.legalization.execution_success;
}

bool PLAPI::runIncrLG(std::vector<std::string> inst_name_list)
{
  auto* design = PlacerDBInst.get_design();
  std::vector<Instance*> inst_list;
  for (std::string inst_name : inst_name_list) {
    auto* inst = design->find_instance(inst_name);
    inst_list.push_back(inst);
  }

  LegalizerInst.updateInstanceList(inst_list);
  bool flag = LegalizerInst.runIncrLegalize();

  return flag;
}

bool PLAPI::runPostGP()
{
  if (failInjectedStage("post_global_placement", PlacementStatusCode::kPostGPFailed,
                        "failure injected before post global placement")) {
    return false;
  }
  auto transaction = PlacerDBInst.beginStageTransaction("post_global_placement");
  if (!transaction.active) {
    _flow_status.post_global_placement = PlacementStatusEvaluator::postGlobalPlacement(
        false, false, 0, 0, "post global placement could not start a PlacerDB transaction");
    _flow_status.setFailure(_flow_status.post_global_placement);
    writePlacementStatus();
    return false;
  }

  HPWirelength hpwl(PlacerDBInst.get_topo_manager());
  const int64_t metric_before = hpwl.obtainTotalWirelength();
  PostGP post_gp(PlacerDBInst.get_placer_config(), &PlacerDBInst);
  const bool success = post_gp.runIncrTimingPlace();
  const int64_t metric_after = hpwl.obtainTotalWirelength();
  const bool legal = success && checkLegality();
  _flow_status.post_global_placement
      = PlacementStatusEvaluator::postGlobalPlacement(success, legal, metric_before, metric_after);

  const bool stage_success = _flow_status.post_global_placement.execution_success && _flow_status.post_global_placement.quality_success;
  if (stage_success) {
    if (!PlacerDBInst.commitStageTransaction(transaction)) {
      _flow_status.post_global_placement = PlacementStatusEvaluator::postGlobalPlacement(
          false, false, metric_before, metric_after, "post global placement could not commit its PlacerDB transaction");
    }
  } else if (!PlacerDBInst.rollbackStageTransaction(transaction)) {
    _flow_status.post_global_placement.message += "; failed to rollback post global placement transaction";
  }

  _flow_status.setFailure(_flow_status.post_global_placement);
  writePlacementStatus();
  return success && legal;
}

bool PLAPI::runIncrLG()
{
  PlacerDBInst.updateFromSourceDataBase();
  LegalizerInst.updateInstanceList();
  bool flag = LegalizerInst.runIncrLegalize();
  return flag;
}

bool PLAPI::runDP()
{
  if (failInjectedStage("detail_placement", PlacementStatusCode::kDPFailed,
                        "failure injected before detail placement")) {
    return false;
  }
  HPWirelength hpwl(PlacerDBInst.get_topo_manager());
  const int64_t metric_before = hpwl.obtainTotalWirelength();
  bool legal_flag = checkLegality();
  if (!legal_flag) {
    _flow_status.detail_placement = PlacementStatusEvaluator::detailPlacement(false, false, metric_before, metric_before,
                                                                               "placement before detail placement is illegal");
    _flow_status.setFailure(_flow_status.detail_placement);
    writePlacementStatus();
    return false;
  }

  DetailPlacer detail_place(PlacerDBInst.get_placer_config(), &PlacerDBInst);
  const bool success = detail_place.runDetailPlace();
  const auto& dp_result = detail_place.lastResult();
  HPWirelength hpwl_after(PlacerDBInst.get_topo_manager());
  const int64_t metric_after = hpwl_after.obtainTotalWirelength();
  const bool legal_after = success ? checkLegality() : dp_result.legal_after;
  _flow_status.detail_placement = PlacementStatusEvaluator::detailPlacement(
      success, legal_after, metric_before, success ? metric_after : dp_result.hpwl_after, dp_result.reason);
  _flow_status.detail_placement.changed_count = dp_result.changed_count;
  _flow_status.detail_placement.exhibit = dp_result.operator_exhibit;
  _flow_status.setFailure(_flow_status.detail_placement);
  writePlacementStatus();
  return success && legal_after;
}

#ifdef ENABLE_AI
bool PLAPI::runDPwithAiWireLengthPredictor(const std::string& onnx_path, const std::string& normalization_path)
{
  HPWirelength hpwl(PlacerDBInst.get_topo_manager());
  const int64_t metric_before = hpwl.obtainTotalWirelength();
  bool legal_flag = checkLegality();
  if (!legal_flag) {
    _flow_status.detail_placement = PlacementStatusEvaluator::detailPlacement(false, false, metric_before, metric_before,
                                                                               "placement before detail placement is illegal");
    _flow_status.setFailure(_flow_status.detail_placement);
    writePlacementStatus();
    return false;
  }

  DetailPlacer detail_place(PlacerDBInst.get_placer_config(), &PlacerDBInst);

  if (!detail_place.init_ai_wirelength_model(onnx_path, normalization_path)) {
    LOG_ERROR << "Failed to load AI wirelength model: " << onnx_path;
    LOG_ERROR << "Falling back to traditional HPWL";
    return runDP();
  }

  const bool success = detail_place.runDetailPlace();
  const auto& dp_result = detail_place.lastResult();
  HPWirelength hpwl_after(PlacerDBInst.get_topo_manager());
  const int64_t metric_after = hpwl_after.obtainTotalWirelength();
  const bool legal_after = success ? checkLegality() : dp_result.legal_after;
  _flow_status.detail_placement = PlacementStatusEvaluator::detailPlacement(
      success, legal_after, metric_before, success ? metric_after : dp_result.hpwl_after, dp_result.reason);
  _flow_status.detail_placement.changed_count = dp_result.changed_count;
  _flow_status.setFailure(_flow_status.detail_placement);
  writePlacementStatus();
  return success && legal_after;
}
#endif

// run networkflow to spread cell
// Input: after global placement. Output: low density distribution result with overlap.
// Legalization is further needed.
bool PLAPI::runNetworkFlowSpread()
{
  HPWirelength hpwl(PlacerDBInst.get_topo_manager());
  const int64_t metric_before = hpwl.obtainTotalWirelength();
  DetailPlacer detail_place(PlacerDBInst.get_placer_config(), &PlacerDBInst);
  const bool success = detail_place.runDetailPlaceNFS();
  const auto& nfs_result = detail_place.lastNetworkFlowResult();
  const int64_t metric_after = hpwl.obtainTotalWirelength();
  _flow_status.network_flow = PlacementStatusEvaluator::optionalStage(
      "network_flow", success, PlacementStatusCode::kNFSFailed, metric_before, metric_after, nfs_result.reason,
      nfs_result.reason, nfs_result.moved_count);
  _flow_status.setFailure(_flow_status.network_flow);
  writePlacementStatus();
  return success;
}

void PLAPI::notifyPLWLInfo(int stage)
{
  // 1. origin method
  HPWirelength hpwl(PlacerDBInst.get_topo_manager());
  SteinerWirelength stwl(PlacerDBInst.get_topo_manager());
  stwl.updateAllNetWorkPointPair();
  PlacerDBInst.PL_HPWL[stage] = hpwl.obtainTotalWirelength();
  PlacerDBInst.PL_STWL[stage] = stwl.obtainTotalWirelength();

  // 2. most work in evalpro
  // this->writeBackSourceDataBase();
  // ieval::TotalWLSummary wl_summary = _external_api->evalproIDBWL();
  // PlacerDBInst.PL_HPWL[stage] = wl_summary.HPWL;
  // PlacerDBInst.PL_STWL[stage] = wl_summary.FLUTE;
  // PlacerDBInst.PL_GRWL[stage] = wl_summary.GRWL;
}

void PLAPI::notifyPLCongestionInfo(int stage)
{
  this->writeBackSourceDataBase();
  ieval::OverflowSummary overflow_summary = _external_api->evalproCongestion();
  PlacerDBInst.egr_tof[stage] = overflow_summary.total_overflow_union;
  PlacerDBInst.egr_mof[stage] = overflow_summary.max_overflow_union;
  PlacerDBInst.egr_ace[stage] = overflow_summary.weighted_average_overflow_union;

  float peak_average_pin_dens = _external_api->obtainPeakAvgPinDens();
  PlacerDBInst.pin_density[stage] = peak_average_pin_dens;
}

void PLAPI::notifyPLTimingInfo(int stage)
{
  this->updateTiming(PlacerDBInst.get_topo_manager());
  std::string clock_name = obtainClockNameList().at(0);
  float tns = obtainTNS(clock_name.c_str(), ista::AnalysisMode::kMax);
  float wns = obtainWNS(clock_name.c_str(), ista::AnalysisMode::kMax);

  PlacerDBInst.tns[stage] = tns;
  PlacerDBInst.wns[stage] = wns;

  float suggest_freq = 1000.0 / (_external_api->obtainTargetClockPeriodNS(clock_name) - wns);
  PlacerDBInst.suggest_freq[stage] = suggest_freq;
}

void PLAPI::notifySTAUpdateTimingRuntime()
{
  ieda::Stats sta_status;
  _external_api->updateSTATiming();
  double time_delta = sta_status.elapsedRunTime();
  PlacerDBInst.sta_update_time = time_delta;
}

void PLAPI::notifyPLOriginInfo()
{
  PlacerDBInst.init_inst_cnt = PlacerDBInst.get_design()->get_instance_list().size();
}

void PLAPI::modifySTAOutputDir(std::string path)
{
  _external_api->modifySTAOutputDir(path);
}

void PLAPI::initSTA(std::string path, bool init_log)
{
  _external_api->initSTA(path, init_log);
}

void PLAPI::updateSTATiming()
{
  _external_api->updateSTATiming();
}

bool PLAPI::isClockNet(std::string net_name)
{
  return _external_api->isClockNet(net_name);
}

bool PLAPI::isSequentialCell(std::string inst_name)
{
  return _external_api->isSequentialCell(inst_name);
}

bool PLAPI::isBufferCell(std::string cell_name)
{
  return _external_api->isBufferCell(cell_name);
}

void PLAPI::updateSequentialProperty()
{
  for (auto* inst : PlacerDBInst.get_design()->get_instance_list()) {
    if (inst->isOutsideInstance()) {
      continue;
    }

    if (!inst->get_cell_master()) {
      continue;
    }

    auto* cell_master = inst->get_cell_master();

    if (cell_master->isMacro()) {
      continue;
    }

    if (cell_master->isPhysicalFiller()) {
      continue;
    }

    if (isSequentialCell(inst->get_name())) {
      inst->get_cell_master()->set_type(CELL_TYPE::kFlipflop);
    }

    // buffer identification
    if (isBufferCell(cell_master->get_name())) {
      inst->get_cell_master()->set_type(CELL_TYPE::kLogicBuffer);
    }
  }

  for (auto* net : PlacerDBInst.get_design()->get_net_list()) {
    if (this->isClockNet(net->get_name())) {
      net->set_net_type(NET_TYPE::kClock);
      net->set_netweight(0.0f);
      net->set_net_state(NET_STATE::kDontCare);
    }
  }

  // clock buffer identification
  for (auto* inst : PlacerDBInst.get_design()->get_instance_list()) {
    if (inst->get_cell_master() && inst->get_cell_master()->isLogicBuffer()) {
      bool is_sequential = false;
      for (auto* pin : inst->get_pins()) {
        if (pin->get_net()->isClockNet()) {
          is_sequential = true;
          break;
        }
      }

      if (is_sequential) {
        inst->get_cell_master()->set_type(CELL_TYPE::kClockBuffer);
      }
    }
  }
}

std::vector<std::string> PLAPI::obtainClockNameList()
{
  return _external_api->obtainClockNameList();
}

bool PLAPI::runBufferInsertion()
{
  HPWirelength hpwl(PlacerDBInst.get_topo_manager());
  const int64_t metric_before = hpwl.obtainTotalWirelength();
  BufferInserter buffer_inserter(PlacerDBInst.get_placer_config(), &PlacerDBInst);
  const bool success = buffer_inserter.runBufferInsertionForMaxWireLength();
  const int64_t metric_after = hpwl.obtainTotalWirelength();
  _flow_status.buffer_insertion = PlacementStatusEvaluator::optionalStage(
      "buffer_insertion", success, PlacementStatusCode::kBufferFailed, metric_before, metric_after, "buffer insertion completed",
      "buffer insertion failed");
  _flow_status.setFailure(_flow_status.buffer_insertion);
  writePlacementStatus();
  return success;
}

void PLAPI::updatePlacerDB()
{
  PlacerDBInst.updateFromSourceDataBase();
}

void PLAPI::updatePlacerDB(std::vector<std::string> inst_list)
{
  PlacerDBInst.updateFromSourceDataBase(inst_list);
}

bool PLAPI::insertSignalBuffer(std::pair<std::string, std::string> source_sink_net, std::vector<std::string> sink_pin_list,
                               std::pair<std::string, std::string> master_inst_buffer, std::pair<int, int> buffer_center_loc)
{
  return _external_api->insertSignalBuffer(source_sink_net, sink_pin_list, master_inst_buffer, buffer_center_loc);
}

bool PLAPI::writeBackSourceDataBase()
{
  if (shouldInjectFailure("writeback")) {
    _failure_injection_stage.clear();
    _flow_status.artifact = PlacementStatusEvaluator::artifact(false, "failure injected during source database writeback");
    _flow_status.setFailure(_flow_status.artifact);
    writePlacementStatus();
    return false;
  }
  if (!PlacerDBInst.writeBackSourceDataBase()) {
    _flow_status.artifact = PlacementStatusEvaluator::artifact(false, "failed to write back source database");
    _flow_status.setFailure(_flow_status.artifact);
    writePlacementStatus();
    return false;
  }
  return true;
}

std::string PLAPI::obtainTargetDir()
{
  auto target_dir = _external_api->obtainTargetDir();
  if (target_dir == "") {
    target_dir = ".";
  }
  return target_dir;
}

std::vector<Rectangle<int32_t>> PLAPI::obtainAvailableWhiteSpaceList(std::pair<int32_t, int32_t> row_range,
                                                                     std::pair<int32_t, int32_t> site_range)
{
  assert(row_range.first < row_range.second && site_range.first < site_range.second);

  auto* grid_manager = PlacerDBInst.get_grid_manager();
  int32_t row_num = grid_manager->get_grid_cnt_y();
  int32_t site_num = grid_manager->get_grid_cnt_x();

  row_range.first < 0 ? row_range.first = 0 : row_range.first;
  row_range.second >= row_num ? row_range.second = (row_num - 1) : row_range.second;
  site_range.first < 0 ? site_range.first = 0 : site_range.first;
  site_range.second >= site_num ? site_range.second = (site_num - 1) : site_range.second;

  return grid_manager->obtainAvailableRectList(row_range.first, row_range.second, site_range.first, site_range.second, 1.0);
}

bool PLAPI::checkLegality()
{
  LayoutChecker checker(&PlacerDBInst);
  auto violations = checker.obtainViolationList();
  if (!violations.empty()) {
    LOG_ERROR << "Layout legality failed with " << violations.size() << " violation(s).";
    for (const auto& violation : violations) {
      std::string names;
      for (size_t index = 0; index < violation.instance_names.size(); ++index) {
        if (index != 0) {
          names += ", ";
        }
        names += violation.instance_names.at(index);
      }
      LOG_ERROR << layoutViolationTypeName(violation.type) << ": " << names << " (" << violation.reason << ")";
    }
  }
  return violations.empty();
}

bool PLAPI::isSTAStarted()
{
  return _external_api->isSTAStarted();
}

bool PLAPI::isPlacerDBStarted()
{
  return PlacerDBInst.isInitialized();
}

bool PLAPI::isAbucasLGStarted()
{
  // return AbacusLegalizerInst.isInitialized();
  return LegalizerInst.isInitialized();
}

// ugly: special case for timing
void PLAPI::reportPLInfo()
{
  LOG_INFO << "-----------------Start iPL Report Generation-----------------";

  ieda::Stats report_status;

  std::string output_dir = this->obtainTargetDir() + "/pl/report/";

  // std::string design_name = PlacerDBInst.get_design()->get_design_name();
  // std::string output_dir = "./evaluation_task/benchmark/" + design_name + "/pl_reports/";

  std::string summary_file = "summary_report.txt";
  std::ofstream summary_stream;
  summary_stream.open(output_dir + summary_file);
  if (!summary_stream.good()) {
    LOG_WARNING << "Cannot open file for summary report !";
  }
  summary_stream << "Generate the report at " << ieda::Time::getNowWallTime() << std::endl;

  // report base info
  reportPLBaseInfo(summary_stream);

  // report violation info
  reportViolationInfo(summary_stream);

  // report wirelength info
  reportWLInfo(summary_stream);

  // report density info
  reportBinDensity(summary_stream);

  // report timing info
  if (PlacerDBInst.get_placer_config()->isTimingEffort()) {
    reportTimingInfo(summary_stream);
  }

  // report congestion
  // if (PlacerDBInst.get_placer_config()->isCongestionEffort()) {
  //   reportCongestionInfo(summary_stream);
  // }
  summary_stream.close();

  double time_delta = report_status.elapsedRunTime();

  LOG_INFO << "Report Generation Total Time Elapsed: " << time_delta << "s";
  LOG_INFO << "-----------------Finish Report Generation-----------------";
}

void PLAPI::reportTopoInfo()
{
  _reporter->reportTopoInfo();
}

void PLAPI::reportWLInfo(std::ofstream& feed)
{
  _reporter->reportWLInfo(feed, this->obtainTargetDir() + "/pl/report");
}

void PLAPI::reportSTWLInfo(std::ofstream& feed)
{
  _reporter->reportSTWLInfo(feed);
}

void PLAPI::reportHPWLInfo(std::ofstream& feed)
{
  _reporter->reportHPWLInfo(feed);
}

void PLAPI::reportLongNetInfo(std::ofstream& feed)
{
  _reporter->reportLongNetInfo(feed);
}

void PLAPI::reportViolationInfo(std::ofstream& feed)
{
  _reporter->reportViolationInfo(feed, this->obtainTargetDir() + "/pl/report");
}

void PLAPI::reportBinDensity(std::ofstream& feed)
{
  _reporter->reportBinDensity(feed);
}

int32_t PLAPI::reportOverlapInfo(std::ofstream& feed)
{
  return _reporter->reportOverlapInfo(feed);
}

void PLAPI::reportLayoutWhiteInfo()
{
  _reporter->reportLayoutWhiteInfo(this->obtainTargetDir() + "/pl/report");
}

void PLAPI::reportTimingInfo(std::ofstream& feed)
{
  if (this->isSTAStarted()) {
    // this->initTimingEval();
    this->updateTiming(PlacerDBInst.get_topo_manager());
    _reporter->reportTimingInfo(feed);
  }
}

void PLAPI::reportCongestionInfo(std::ofstream& feed)
{
  _reporter->reportCongestionInfo(feed);
}

void PLAPI::reportPLBaseInfo(std::ofstream& feed)
{
  _reporter->reportPLBaseInfo(feed);
}

void PLAPI::printHPWLInfo()
{
  _reporter->printHPWLInfo();
}

void PLAPI::printTimingInfo()
{
  if (this->isSTAStarted()) {
    this->updateTiming(PlacerDBInst.get_topo_manager());
    _reporter->printTimingInfo();
  }
}

void PLAPI::saveNetPinInfoForDebug(std::string path)
{
  _reporter->saveNetPinInfoForDebug(path);
}

void PLAPI::savePinListInfoForDebug(std::string path)
{
  _reporter->savePinListInfoForDebug(path);
}

void PLAPI::plotConnectionForDebug(std::vector<std::string> net_name_list, std::string path)
{
  _reporter->plotConnectionForDebug(net_name_list, path);
}

void PLAPI::plotModuleListForDebug(std::vector<std::string> module_prefix_list, std::string path)
{
  _reporter->plotModuleListForDebug(module_prefix_list, path);
}

void PLAPI::plotModuleStateForDebug(std::vector<std::string> special_inst_list, std::string path)
{
  _reporter->plotModuleStateForDebug(special_inst_list, path);
}

ieval::TimingPin* wrapTimingTruePin(Node* node)
{
  ieval::TimingPin* timing_pin = new ieval::TimingPin();
  timing_pin->pin_name = node->get_name();
  timing_pin->x = node->get_location().get_x();
  timing_pin->y = node->get_location().get_y();
  timing_pin->is_real_pin = true;

  return timing_pin;
}

ieval::TimingPin* wrapTimingFakePin(int id, Point<int32_t> coordi)
{
  ieval::TimingPin* timing_pin = new ieval::TimingPin();
  timing_pin->pin_name = "fake_" + std::to_string(id);
  timing_pin->pin_id = id;
  timing_pin->x = coordi.get_x();
  timing_pin->y = coordi.get_y();
  timing_pin->is_real_pin = false;

  return timing_pin;
}

ieda_feature::PlaceSummary PLAPI::outputSummary(std::string step)
{
  ieda_feature::PlaceSummary summary;

  // 1:全局布局、详细布局、合法化都需要存储的数据参数，需要根据step存储不同的值
  auto place_density = PlacerDBInst.place_density;
  auto hpwl = PlacerDBInst.PL_HPWL;
  auto stwl = PlacerDBInst.PL_STWL;

  // 2:全局布局、详细布局需要存储的数据参数
  if (step == "place") {
    summary.gplace.place_density = place_density[0];
    summary.gplace.HPWL = hpwl[0];
    summary.gplace.STWL = stwl[0];

    summary.dplace.place_density = place_density[2];
    summary.dplace.HPWL = hpwl[2];
    summary.dplace.STWL = stwl[2];

    auto* pl_design = PlacerDBInst.get_design();
    summary.instance_cnt = pl_design->get_instances_range();
    int fix_inst_cnt = 0;
    for (auto* inst : pl_design->get_instance_list()) {
      if (inst->isFixed()) {
        fix_inst_cnt++;
      }
    }

    summary.fix_inst_cnt = fix_inst_cnt;
    summary.net_cnt = pl_design->get_nets_range();
    summary.total_pins = pl_design->get_pins_range();

    summary.bin_number = PlacerDBInst.get_placer_config()->get_nes_config().get_bin_cnt_x()
                         * PlacerDBInst.get_placer_config()->get_nes_config().get_bin_cnt_y();
    summary.bin_size_x = PlacerDBInst.bin_size_x;
    summary.bin_size_y = PlacerDBInst.bin_size_y;
    summary.overflow_number = PlacerDBInst.gp_overflow_number;
    summary.overflow = PlacerDBInst.gp_overflow;
  }
  // 3:合法化需要存储的数据参数
  else if (step == "legalization") {
    summary.lg_summary.pl_common_summary.HPWL = hpwl[1];
    summary.lg_summary.pl_common_summary.STWL = stwl[1];

    summary.lg_summary.lg_total_movement = PlacerDBInst.lg_total_movement;
    summary.lg_summary.lg_max_movement = PlacerDBInst.lg_max_movement;
  }

  return summary;
}

// private
PLAPI* PLAPI::_s_ipl_api_instance = nullptr;

}  // namespace ipl
