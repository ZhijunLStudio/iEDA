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
 * @Date: 2022-03-09 15:09:04
 * @LastEditTime: 2022-04-06 12:01:32
 * @LastEditors: S.J Chen
 * @Description:
 * @FilePath: /iEDA/src/iPL/src/evaluator/wirelength/HPWirelength.cc
 * Contact : https://github.com/sjchanson
 */

#include "HPWirelength.hh"

#include <algorithm>
#include <cstdint>

#include "omp.h"

namespace ipl {

namespace {

auto networkHPWL(NetWork* network) -> int64_t
{
  if (network == nullptr || network->isIgnoreNetwork()) {
    return 0;
  }
  const auto nodes = network->get_node_list();
  if (nodes.size() < 2) {
    return 0;
  }

  int64_t lower_x = INT64_MAX;
  int64_t lower_y = INT64_MAX;
  int64_t upper_x = INT64_MIN;
  int64_t upper_y = INT64_MIN;
  std::size_t valid_nodes = 0;
  for (const auto* node : nodes) {
    if (node == nullptr) {
      continue;
    }
    const auto location = node->get_location();
    const int64_t x = location.get_x();
    const int64_t y = location.get_y();
    lower_x = std::min(lower_x, x);
    lower_y = std::min(lower_y, y);
    upper_x = std::max(upper_x, x);
    upper_y = std::max(upper_y, y);
    ++valid_nodes;
  }
  return valid_nodes < 2 ? 0 : (upper_x - lower_x) + (upper_y - lower_y);
}

}  // namespace

int64_t HPWirelength::obtainTotalWirelength()
{
  if (_topology_manager == nullptr) {
    return 0;
  }
  int64_t total_hpwl = 0;
  const auto& networks = _topology_manager->get_network_list();

#pragma omp parallel for reduction(+ : total_hpwl)
  for (std::size_t index = 0; index < networks.size(); ++index) {
    total_hpwl += networkHPWL(networks[index]);
  }
  return total_hpwl;
}

std::vector<std::vector<std::pair<int32_t, int32_t>>> HPWirelength::constructPointSets()
{
  std::vector<std::vector<std::pair<int32_t, int32_t>>> point_sets;
  if (_topology_manager == nullptr) {
    return point_sets;
  }

  for (auto* network : _topology_manager->get_network_list()) {
    if (network == nullptr || network->isIgnoreNetwork()) {
      continue;
    }
    std::vector<std::pair<int32_t, int32_t>> point_set;

    for (auto* node : network->get_node_list()) {
      if (node == nullptr) {
        continue;
      }
      Point<int32_t> node_loc = node->get_location();
      point_set.emplace_back(node_loc.get_x(), node_loc.get_y());
    }

    point_sets.push_back(point_set);
  }

  return point_sets;
}

int64_t HPWirelength::obtainNetWirelength(int32_t net_id)
{
  if (_topology_manager == nullptr) {
    return 0;
  }
  auto* network = _topology_manager->findNetworkById(net_id);
  return networkHPWL(network);
}

int64_t HPWirelength::obtainPartOfNetWirelength(int32_t net_id, int32_t sink_pin_id)
{
  if (_topology_manager == nullptr) {
    return 0;
  }

  auto* network = _topology_manager->findNetworkById(net_id);
  if (network != nullptr && !network->isIgnoreNetwork()) {
    auto* transmitter = network->get_transmitter();
    if (transmitter) {
      for (auto* receiver : network->get_receiver_list()) {
        if (receiver != nullptr && receiver->get_node_id() == sink_pin_id) {
          const int64_t delta_x = static_cast<int64_t>(transmitter->get_location().get_x()) - receiver->get_location().get_x();
          const int64_t delta_y = static_cast<int64_t>(transmitter->get_location().get_y()) - receiver->get_location().get_y();
          return std::abs(delta_x) + std::abs(delta_y);
        }
      }
    }
  }
  return 0;
}

}  // namespace ipl
