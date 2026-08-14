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
 * @Date: 2022-03-06 14:45:25
 * @LastEditTime: 2023-03-03 10:07:55
 * @LastEditors: Shijian Chen  chenshj@pcl.ac.cn
 * @Description:
 * @FilePath: /irefactor/src/operation/iPL/source/module/global_placer/electrostatic_placer/NesterovPlace.hh
 * Contact : https://github.com/sjchanson
 */

#ifndef IPL_OPERATOR_GP_NESTEROV_PLACE_H
#define IPL_OPERATOR_GP_NESTEROV_PLACE_H

#include <float.h>

#include <cstdint>
#include <fstream>
#include <iostream>
#include <string>
#include <vector>

#include "Config.hh"
#include "Log.hh"
#include "NesterovPlaceContract.hh"
#include "PlacerDB.hh"
#include "config/NesterovPlaceConfig.hh"
#include "database/NesterovDatabase.hh"
namespace ipl {

// JSON (de)serialization of GPStateCheckpoint for cross-process resume (72c M2).
// Float values round-trip exactly through nlohmann::json (double represents
// every float; the reverse cast is lossless).
bool saveGPCheckpointFile(const std::string& path, const GPStateCheckpoint& checkpoint);
bool loadGPCheckpointFile(const std::string& path, GPStateCheckpoint& checkpoint);

struct NesterovPlaceResult
{
  bool success = false;
  NesterovPlaceOutcome outcome = NesterovPlaceOutcome::kNotRun;
  int32_t iterations = 0;
  int64_t hpwl = 0;
  float overflow = 0.0f;
  float gradient_norm = 0.0f;
  float step_length = 0.0f;
  float density_penalty = 0.0f;
  float route_util = 0.0f;
  std::string reason;
  std::vector<NesterovIterationRecord> iteration_records;
};

class NesterovPlace
{
 public:
  NesterovPlace() = delete;
  NesterovPlace(Config* config, PlacerDB* placer_db, bool enableJsonOutput = false);
  NesterovPlace(const NesterovPlace&) = delete;
  NesterovPlace(NesterovPlace&&) = delete;
  ~NesterovPlace();

  NesterovPlace& operator=(const NesterovPlace&) = delete;
  NesterovPlace& operator=(NesterovPlace&&) = delete;

  bool runNesterovPlace();
  const NesterovPlaceResult& lastResult() const { return _last_result; }
  const std::vector<NesterovIterationRecord>& iterationRecords() const { return _iteration_records; }
  void printNesterovDatabase();

  bool isJsonOutputEnabled() { return _enable_json_output; }

  // ---- persistent session API (GP tool-ification, M1) ----
  // The same NesterovPlace object is kept alive across calls so that the
  // Nesterov solver state (coordinates, gradients, steplength, momentum)
  // survives batch boundaries. Accepted-iteration budget semantics:
  // internal backtracking does not count; a batch only stops at a complete
  // accepted-iteration boundary or at a terminal condition.
  bool initializeSession();                              // placable list + initial gradients + pre-loop setup
  GPAdvanceOutcome advanceAcceptedIterations(int32_t budget);
  void finishSession();                                  // terminal tail: kMaxIter finalize + notify + write back
  void publishPlacement();                               // per-batch: notify + write back (does not touch solver state)
  bool isSessionFinished() const { return _last_result.outcome != NesterovPlaceOutcome::kNotRun; }
  int32_t currentIteration() const { return _current_iter; }

  // ---- checkpoint persistence (M2) ----
  GPStateCheckpoint captureCheckpoint() const;
  bool restoreCheckpoint(const GPStateCheckpoint& checkpoint);

 private:
  NesterovPlaceConfig _nes_config;
  NesterovDatabase* _nes_database;

  // For convergence acceleration and non-convergence treatment
  int64_t _best_hpwl = INT64_MAX;
  float _best_overflow = FLT_MAX;
  std::vector<float> _overflow_record_list;
  std::vector<float> _hpwl_record_list;
  float _quad_penalty_coeff = 0.005;
  int64_t _total_inst_area = 0;
  bool _enable_json_output = false;
  int32_t _global_right_padding = 0;

  // Persistent solve-loop state (hoisted from NesterovSolve() locals so the
  // session survives across advanceAcceptedIterations() calls).
  std::vector<NesInstance*> _placable_inst_list;
  std::vector<Point<float>> _next_slp_wirelength_grad_list;
  std::vector<Point<float>> _next_slp_density_grad_list;
  std::vector<Point<float>> _next_slp_sum_grad_list;
  std::ofstream _long_net_stream;
  std::ofstream _info_stream;
  int32_t _long_width = 0;
  int32_t _long_height = 0;
  bool _solve_setup_done = false;
  int32_t _current_iter = 0;
  float _sum_overflow = 0.0F;
  int64_t _prev_hpwl = 0;
  int64_t _cur_hpwl = 0;
  float _sum_overflow_threshold = 1e25F;
  float _hpwl_attach_sum_overflow = 1e25F;
  bool _max_phi_coef_record = false;
  int32_t _cur_opt_overflow_step = 0;
  int32_t _last_perturb_iter = -50;
  bool _is_add_quad_penalty = false;
  bool _is_cal_phi = false;
  bool _stop_placement = false;
  std::vector<Point<int32_t>> _best_position_list;
  std::vector<Point<int32_t>> _cur_position_list;
  std::vector<float> _best_density_scale_list;
  std::vector<float> _cur_density_scale_list;
  int32_t _finished_iter = 0;
  float _final_step_length = 0.0F;
  float _final_gradient_norm = 0.0F;
  float _final_route_util = 0.0F;

  void resetOverflowRecordList();
  void resetHPWLRecordList();
  void initQuadPenaltyCoeff();
  bool checkPlateau(int32_t window, float threshold);
  void entropyInjection(float shrink_factor, float noise_intensity);
  bool checkDivergence(int32_t window, float threshold, bool is_routability = false);
  bool checkLongTimeOverflowUnchanged(int32_t window, float threshold);
  bool isFiniteMetric(float value) const;
  void resetRunState();
  void recordIteration(int32_t iter_num, float overflow, int64_t hpwl, float step_length, float gradient_norm, float route_util,
                       bool quad_penalty_enabled, bool entropy_injected);
  void finalizeResult(NesterovPlaceOutcome outcome, int32_t iterations, int64_t hpwl, float overflow, float gradient_norm,
                      float step_length, float density_penalty, float route_util, std::string reason);

  void initNesConfig(Config* config);
  void calculateAdaptiveBinCnt();
  void initNesDatabase(PlacerDB* placer_db);
  void wrapNesInstanceList();
  void wrapNesInstance(Instance* inst, NesInstance* nesInst);
  void wrapNesNetList();
  void wrapNesNet(Net* net, NesNet* nesNet);
  void wrapNesPinList();
  void wrapNesPin(Pin* pin, NesPin* nesPin);
  void completeConnection();

  void initFillerNesInstance();
  void initNesInstanceDensitySize();

  void initNesterovPlace(std::vector<NesInstance*>& inst_list);
  void NesterovSolve(std::vector<NesInstance*>& inst_list);
  void setupNesterovSolve();

  std::vector<NesInstance*> obtianPlacableNesInstanceList();

  void updateDensityCoordiLayoutInside(NesInstance* nInst, Rectangle<int32_t> core_shape);
  void updateDensityCenterCoordiLayoutInside(NesInstance* nInst, Point<int32_t>& center_coordi, Rectangle<int32_t> region_shape);

  void initGridManager();
  void initGridFixedArea();

  void initTopologyManager();
  void initNodes();
  void initNetWorks();
  void initGroups();
  void initArcs();
  void generatePortOutNetArc(Node* node);
  void generateNetArc(Node* node);
  void generateGroupArc(Node* node);
  void initHPWLEvaluator();
  void initWAWLGradientEvaluator();
  void initTimingAnnotation();
  void updateTopologyManager();

  void initBaseWirelengthCoef();
  void updateWirelengthCoef(float overflow);

  void updatePenaltyGradient(std::vector<NesInstance*>& nInst_list, std::vector<Point<float>>& sum_grads,
                             std::vector<Point<float>>& wirelength_grads, std::vector<Point<float>>& density_grads,
                             bool is_add_quad_penalty);

  Point<float> obtainWirelengthPrecondition(NesInstance* nInst);
  Point<float> obtainDensityPrecondition(NesInstance* nInst);

  Rectangle<int32_t> obtainFirstGridShape();
  int64_t obtainTotalArea(std::vector<NesInstance*>& inst_list);
  float obtainPhiCoef(float scaled_diff_hpwl, int32_t iteration_num);
  int64_t obtainTotalFillerArea(std::vector<NesInstance*>& inst_list);

  void writeBackPlacerDB();

  void updateMaxLengthNetWeight();
  void updateTimingNetWeight();
  void inflateInstancesByRouteUtil(std::vector<NesInstance*>& inst_list);

  // DEBUG.
  void printAcrossLongNet(std::ofstream& file_stream, int32_t max_width, int32_t max_height);
  void printIterationCoordi(std::ofstream& file_stream, int32_t cur_iter);
  void saveNesterovPlaceData(int32_t cur_iter);
  void plotInstJson(std::string file_name, int32_t cur_iter, float overflow);
  void printIterInfoToCsv(std::ofstream& file_stream, int32_t iter_num);
  void printDensityMapToCsv(std::string file_name);

  // Precondition Test
  std::vector<double> _global_diagonal_list;
  void initDiagonalIdentityMatrix(int32_t inst_size);
  void initDiagonalHkMatrix(std::vector<NesInstance*>& inst_list);
  void initDiagonalSkMatrix(std::vector<NesInstance*>& inst_list);
  void updatePenaltyGradientPre1(std::vector<NesInstance*>& nInst_list, std::vector<Point<float>>& sum_grads,
                                 std::vector<Point<float>>& wirelength_grads, std::vector<Point<float>>& density_grads);
  void updatePenaltyGradientPre2(std::vector<NesInstance*>& nInst_list, std::vector<Point<float>>& sum_grads,
                                 std::vector<Point<float>>& wirelength_grads, std::vector<Point<float>>& density_grads);
  
  void notifyPLBinSize();
  void notifyPLOverflowInfo(float final_overflow);
  void notifyPLPlaceDensity();

  NesterovPlaceResult _last_result;
  std::vector<NesterovIterationRecord> _iteration_records;
};
inline NesterovPlace::NesterovPlace(Config* config, PlacerDB* placer_db, bool enableJsonOutput)
    : _nes_database(nullptr), _enable_json_output(enableJsonOutput)
{
  initNesConfig(config);
  initNesDatabase(placer_db);
  initFillerNesInstance();
  initNesInstanceDensitySize();

  // init bin inst type
  _nes_database->_bin_grid->initNesInstanceTypeList(_nes_database->_nInstance_list);
}
inline NesterovPlace::~NesterovPlace()
{
  delete _nes_database;
}

}  // namespace ipl

#endif
