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
 * @Date: 2022-03-06 15:26:12
 * @LastEditTime: 2022-10-17 14:49:16
 * @LastEditors: sjchanson 13560469332@163.com
 * @Description:
 * @FilePath: /iEDA/src/iPL/src/operator/global_placer/nesterov_place/config/NesterovPlaceConfig.hh
 * Contact : https://github.com/sjchanson
 */

#ifndef IPL_OPERATOR_GP_NESTEROV_PLACE_CONFIG_H
#define IPL_OPERATOR_GP_NESTEROV_PLACE_CONFIG_H

#include <cmath>
#include <string>
#include <vector>

namespace ipl {

class NesterovPlaceConfig
{
 public:
  NesterovPlaceConfig()                                 = default;
  NesterovPlaceConfig(const NesterovPlaceConfig& other) = default;
  NesterovPlaceConfig(NesterovPlaceConfig&& other)      = default;
  ~NesterovPlaceConfig()                                = default;

  NesterovPlaceConfig& operator=(const NesterovPlaceConfig& other) = default;
  NesterovPlaceConfig& operator=(NesterovPlaceConfig&& other) = default;

  // getter.
  int32_t get_thread_num() const { return _thread_num; }
  int32_t get_info_iter_num() const { return _info_iter_num; }
  float   get_init_wirelength_coef() const { return _init_wirelength_coef; }
  float   get_reference_hpwl() const { return _reference_hpwl; }
  float   get_min_wirelength_force_bar() const { return _min_wirelength_force_bar; }
  bool    isAdaptiveBin() const { return _is_adaptive_bin; }
  float   get_target_density() const { return _target_density; }
  int32_t get_bin_cnt_x() const { return _bin_cnt_x; }
  int32_t get_bin_cnt_y() const { return _bin_cnt_y; }
  float   get_min_phi_coef() const { return _min_phi_coef; }
  float   get_max_phi_coef() const { return _max_phi_coef; }
  int32_t get_max_iter() const { return _max_iter; }
  int32_t get_max_back_track() const { return _max_back_track; }
  float   get_target_overflow() const { return _target_overflow; }
  float   get_initial_prev_coordi_update_coef() const { return _initial_prev_coordi_update_coef; }
  float   get_min_precondition() const { return _min_precondition; }
  float   get_init_density_penalty() const { return _init_density_penalty; }
  bool isOptMaxWirelength() const { return _is_opt_max_wirelength;}
  bool isOptTiming() const { return _is_opt_timing;}
  bool isOptCongestion() const { return _is_opt_congestion;}
  int32_t get_max_net_wirelength() const { return _max_net_wirelength;}
  int32_t get_global_padding() const { return _global_padding; }
  const std::vector<float>& get_opt_overflow_list() const { return _opt_overflow_list; }

  bool validate(std::string* reason = nullptr) const
  {
    const auto fail = [reason](const std::string& message) {
      if (reason != nullptr) {
        *reason = message;
      }
      return false;
    };

    if (_thread_num <= 0) {
      return fail("thread_num must be positive");
    }
    if (_info_iter_num <= 0) {
      return fail("info_iter_num must be positive");
    }
    if (!std::isfinite(_init_wirelength_coef) || _init_wirelength_coef <= 0.0f) {
      return fail("init_wirelength_coef must be positive and finite");
    }
    if (!std::isfinite(_reference_hpwl) || _reference_hpwl <= 0.0f) {
      return fail("reference_hpwl must be positive and finite");
    }
    if (!std::isfinite(_min_wirelength_force_bar)) {
      return fail("min_wirelength_force_bar must be finite");
    }
    if (!std::isfinite(_target_density) || _target_density <= 0.0f || _target_density >= 1.0f) {
      return fail("target_density must be in (0,1)");
    }
    if (_bin_cnt_x <= 0 || _bin_cnt_y <= 0) {
      return fail("bin counts must be positive");
    }
    if (_max_iter <= 0) {
      return fail("max_iter must be positive");
    }
    if (_max_back_track <= 0) {
      return fail("max_back_track must be positive");
    }
    if (!std::isfinite(_init_density_penalty) || _init_density_penalty <= 0.0f) {
      return fail("init_density_penalty must be positive and finite");
    }
    if (!std::isfinite(_target_overflow) || _target_overflow <= 0.0f || _target_overflow >= 1.0f) {
      return fail("target_overflow must be in (0,1)");
    }
    if (!std::isfinite(_initial_prev_coordi_update_coef) || _initial_prev_coordi_update_coef < 0.0f) {
      return fail("initial_prev_coordi_update_coef must be non-negative and finite");
    }
    if (!std::isfinite(_min_precondition) || _min_precondition <= 0.0f) {
      return fail("min_precondition must be positive and finite");
    }
    if (!std::isfinite(_min_phi_coef) || !std::isfinite(_max_phi_coef) || _min_phi_coef <= 0.0f || _max_phi_coef <= 0.0f
        || _min_phi_coef > _max_phi_coef) {
      return fail("phi coefficients must satisfy 0 < min_phi_coef <= max_phi_coef");
    }
    if (_is_opt_max_wirelength && _max_net_wirelength <= 0) {
      return fail("max_net_wirelength must be positive when max wirelength optimization is enabled");
    }
    if (_global_padding < 0) {
      return fail("global_padding must be non-negative");
    }

    return true;
  }

  // setter.
  void set_thread_num(int32_t num_thread) { _thread_num = num_thread; }
  void set_info_iter_num(int32_t info_iter_num) { _info_iter_num = info_iter_num; }
  void set_init_wirelength_coef(float coef) { _init_wirelength_coef = coef; }
  void set_reference_hpwl(float hpwl) { _reference_hpwl = hpwl; }
  void set_min_wirelength_force_bar(float bar) { _min_wirelength_force_bar = bar; }
  void set_target_density(float target_density) { _target_density = target_density; }
  void set_adaptive_bin(bool is_adaptive) { _is_adaptive_bin = is_adaptive; }
  void set_bin_cnt_x(float bin_cnt_x) { _bin_cnt_x = bin_cnt_x; }
  void set_bin_cnt_y(float bin_cnt_y) { _bin_cnt_y = bin_cnt_y; }
  void set_min_phi_coef(float min_phi_coef) { _min_phi_coef = min_phi_coef; }
  void set_max_phi_coef(float max_phi_coef) { _max_phi_coef = max_phi_coef; }
  void set_max_iter(int32_t max_iter) { _max_iter = max_iter; }
  void set_max_back_track(int32_t max_back_track) { _max_back_track = max_back_track; }
  void set_init_density_penalty(float init_density_penalty) { _init_density_penalty = init_density_penalty; }
  void set_target_overflow(float target_overflow) { _target_overflow = target_overflow; }
  void set_initial_prev_coordi_update_coef(float coef) { _initial_prev_coordi_update_coef = coef; }
  void set_min_precondition(float precondition) { _min_precondition = precondition; }
  void set_is_opt_max_wirelength(bool flag) { _is_opt_max_wirelength = flag;}
  void set_is_opt_timing(bool flag) { _is_opt_timing = flag; }
  void set_is_opt_congestion(bool flag) { _is_opt_congestion = flag;}
  void set_max_net_wirelength(int32_t max_wirelength) { _max_net_wirelength = max_wirelength;}
  void set_global_padding(int32_t padding) { _global_padding = padding; }
  void add_opt_target_overflow(float overflow) { _opt_overflow_list.push_back(overflow);}

 private:
  int32_t _thread_num = 1;
  int32_t _info_iter_num = 10;
  // about wirelength.
  float _init_wirelength_coef = 1.0F;
  float _reference_hpwl = 1.0F;
  float _min_wirelength_force_bar = 1.0F;

  // about density.
  float _target_density = 0.7F;
  bool _is_adaptive_bin = false;
  int32_t _bin_cnt_x = 16;
  int32_t _bin_cnt_y = 16;

  // about nesterov.
  int32_t _max_iter = 250;
  int32_t _max_back_track = 10;
  float _init_density_penalty = 1.0F;
  float _target_overflow = 0.1F;
  float _initial_prev_coordi_update_coef = 0.9F;
  float _min_precondition = 1.0e-6F;
  float _min_phi_coef = 0.1F;
  float _max_phi_coef = 0.98F;

  // about maxlength constraint
  bool _is_opt_max_wirelength = false;
  int32_t _max_net_wirelength = -1;

  // about timing.
  bool _is_opt_timing = false;

  // about congestion.
  bool _is_opt_congestion = false;

  // about opt target overflow list
  std::vector<float> _opt_overflow_list;

  // about global right padding (site count)
  int32_t _global_padding = 0;
};

}  // namespace ipl

#endif
