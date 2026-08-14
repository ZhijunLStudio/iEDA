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
 * @Date: 2022-10-24 21:17:18
 * @LastEditors: Shijian Chen  chenshj@pcl.ac.cn
 * @LastEditTime: 2023-03-11 14:20:43
 * @FilePath: /irefactor/src/operation/iPL/api/PLAPI.hh
 * @Description: Interface of iPL.
 */

#ifndef IPL_API_H
#define IPL_API_H

#include "PlacementStatus.hh"
#include "PlacementResult.hh"
#include "GPContract.hh"
#include "external_api/ExternalAPI.hh"
#include "report/PLReporter.hh"

namespace ieda_feature {
class PlaceSummary;
}  // namespace ieda_feature

namespace ipl {

#define iPLAPIInst ipl::PLAPI::getInst()

class NesterovPlace;
class PlacerDB;

// Opaque GP session state (solver object + stage transaction + per-batch record
// offset). Defined in PLAPI.cc so the api header stays independent of module
// internals.
struct GPSessionState;

class PLAPI
{
 public:
  static PLAPI& getInst();
  static void destoryInst();

  void initAPI(std::string pl_json_path, idb::IdbBuilder* idb_builder);
  bool runFlow();
  PlacementFlowResult runFlowResult();
  bool runAiFlow(const std::string& onnx_path, const std::string& normalization_path);
  PlacementFlowResult runAiFlowResult(const std::string& onnx_path, const std::string& normalization_path);
  void runIncrementalFlow();
  void insertLayoutFiller();

  bool runGP();
  PlacementFlowResult runGPResult();
  bool runMP();
  bool runNetworkFlowSpread();

  // ---- persistent GP session API (M1: in-memory session; M2 adds checkpoint persistence) ----
  // Segmented global placement: gpRun(kStart, N) builds a session and runs N accepted
  // iterations; gpRun(kAdvance, N) continues the same session. The legacy runGPResult()
  // path is unchanged and drives the same session primitives internally.
  GPRunResult gpRun(const GPRunRequest& request);
  bool gpSessionActive() const { return _gp_session_state != nullptr; }
  void gpCloseSession();

  bool runLG();
  bool runIncrLG();
  bool runIncrLG(std::vector<std::string> inst_name_list);
  bool runPostGP();
  bool runDP();
#ifdef ENABLE_AI
  bool runDPwithAiWireLengthPredictor(const std::string& onnx_path, const std::string& normalization_path);
#endif
  bool runBufferInsertion();
  bool writeBackSourceDataBase();

  std::string obtainTargetDir();

  void updatePlacerDB();
  void updatePlacerDB(std::vector<std::string> inst_list);

  std::vector<Rectangle<int32_t>> obtainAvailableWhiteSpaceList(std::pair<int32_t, int32_t> row_range,
                                                                std::pair<int32_t, int32_t> site_range);
  bool checkLegality();

  PLReporter* get_reporter() { return _reporter; }

  void reportPLInfo();
  void reportTopoInfo();
  void reportWLInfo(std::ofstream& feed);
  void reportSTWLInfo(std::ofstream& feed);
  void reportHPWLInfo(std::ofstream& feed);
  void reportLongNetInfo(std::ofstream& feed);
  void reportViolationInfo(std::ofstream& feed);
  void reportBinDensity(std::ofstream& feed);
  int32_t reportOverlapInfo(std::ofstream& feed);
  void reportLayoutWhiteInfo();
  void reportTimingInfo(std::ofstream& feed);
  void reportCongestionInfo(std::ofstream& feed);
  void reportPLBaseInfo(std::ofstream& feed);

  void notifyPLWLInfo(int stage);  // for indicator record: 0-GP, 1-LG, 2-DP
  void notifyPLTimingInfo(int stage);
  void notifySTAUpdateTimingRuntime();
  void notifyPLCongestionInfo(int stage);
  void notifyPLOriginInfo();

  bool isSTAStarted();
  bool isPlacerDBStarted();
  bool isAbucasLGStarted();

  // The following interfaces are only for iPL internal calls !
  // The following interfaces are only for iPL internal calls !
  // The following interfaces are only for iPL internal calls !

  void createPLDirectory();
  void printHPWLInfo();
  void printTimingInfo();
  void saveNetPinInfoForDebug(std::string path);
  void savePinListInfoForDebug(std::string path);
  void plotConnectionForDebug(std::vector<std::string> net_name_list, std::string path);
  void plotModuleListForDebug(std::vector<std::string> module_prefix_list, std::string path);
  void plotModuleStateForDebug(std::vector<std::string> special_inst_list, std::string path);

  void modifySTAOutputDir(std::string path);
  void initSTA(std::string path, bool init_log);
  void updateSTATiming();
  std::vector<std::string> obtainClockNameList();
  bool isClockNet(std::string net_name);
  bool isSequentialCell(std::string inst_name);
  bool isBufferCell(std::string cell_name);
  void updateSequentialProperty();

  bool insertSignalBuffer(std::pair<std::string, std::string> source_sink_net, std::vector<std::string> sink_pin_list,
                          std::pair<std::string, std::string> master_inst_buffer, std::pair<int, int> buffer_center_loc);

  void enableJsonOutput() { _enable_json_output = true; }
  bool isJsonOutputEnabled() { return _enable_json_output; }
  void resetFlowStatus() { _flow_status = PlacementFlowStatus{}; }
  const PlacementFlowStatus& lastRunStatus() const { return _flow_status; }

  // Focused failure-injection seam for API/command boundary regression tests.
  // Empty value disables injection and has no production-flow effect.
  void setFailureInjectionForTest(std::string stage) { _failure_injection_stage = std::move(stage); }
  void clearFailureInjectionForTest() { _failure_injection_stage.clear(); }

  /*****************************Timing-driven Placement: START*****************************/
  double obtainPinEarlySlack(std::string pin_name);
  double obtainPinLateSlack(std::string pin_name);
  double obtainPinEarlyArrivalTime(std::string pin_name);
  double obtainPinLateArrivalTime(std::string pin_name);
  double obtainPinEarlyRequiredTime(std::string pin_name);
  double obtainPinLateRequiredTime(std::string pin_name);
  double obtainWNS(const char* clock_name, ista::AnalysisMode mode);
  double obtainTNS(const char* clock_name, ista::AnalysisMode mode);
  double obtainEarlyWNS(const char* clock_name);
  double obtainEarlyTNS(const char* clock_name);
  double obtainLateWNS(const char* clock_name);
  double obtainLateTNS(const char* clock_name);
  void updateTiming(TopologyManager* topo_manager);
  void updatePartOfTiming(TopologyManager* topo_manager,
                          std::map<int32_t, std::vector<std::pair<Point<int32_t>, Point<int32_t>>>>& net_id_to_points_map);
  void updateTimingInstMovement(TopologyManager* topo_manager,
                                std::map<int32_t, std::vector<std::pair<Point<int32_t>, Point<int32_t>>>> net_id_to_points_map,
                                std::vector<std::string> moved_inst_list);
  float obtainPinCap(std::string inst_pin_name);
  float obtainAvgWireResUnitLengthUm();
  float obtainAvgWireCapUnitLengthUm();
  float obtainInstOutPinRes(std::string cell_name, std::string port_name);
  ieval::TimingNet* generateTimingNet(NetWork* network,
                                      const std::vector<std::pair<ipl::Point<int32_t>, ipl::Point<int32_t>>>& point_pair_list);
  void destroyTimingEval();

  /*****************************Timing-driven Placement: END*****************************/

  ieda_feature::PlaceSummary outputSummary(std::string step);

 private:
  static PLAPI* _s_ipl_api_instance;
  ExternalAPI* _external_api;
  PLReporter* _reporter;

  bool _enable_json_output = false;
  std::string _failure_injection_stage;
  PlacementFlowStatus _flow_status;

  // GP session (M1). The NesterovPlace object is kept alive across gpRun calls;
  // the stage transaction and the per-batch iteration-record offset belong to the
  // same session lifetime.
  std::unique_ptr<GPSessionState> _gp_session_state;

  GPRunResult gpRunStart(const GPRunRequest& request);
  GPRunResult gpRunAdvance(const GPRunRequest& request);
  GPRunResult gpRunResume(const GPRunRequest& request);
  GPRunResult gpFinalizeTerminal(GPRunResult result);

  PLAPI() = default;
  PLAPI(const PLAPI&) = delete;
  PLAPI(PLAPI&&) = delete;
  ~PLAPI();
  PLAPI& operator=(const PLAPI&) = delete;
  PLAPI& operator=(PLAPI&&) = delete;

  bool shouldInjectFailure(const std::string& stage) const { return _failure_injection_stage == stage; }
  bool failInjectedStage(const std::string& stage, PlacementStatusCode code, const std::string& reason);
  bool writePlacementStatus();
};

}  // namespace ipl

#endif  // IPL_API_H
