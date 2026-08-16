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
 * @Date: 2022-03-06 14:45:35
 * @LastEditTime: 2023-03-09 10:04:58
 * @LastEditors: Shijian Chen  chenshj@pcl.ac.cn
 * @Description:
 * @FilePath: /irefactor/src/operation/iPL/source/module/global_placer/electrostatic_placer/NesterovPlace.cc
 * Contact : https://github.com/sjchanson
 */
#include "NesterovPlace.hh"

#include <limits.h>

#include <algorithm>
#include <boost/geometry.hpp>
#include <boost/polygon/polygon.hpp>
#include <cfloat>
#include <cmath>
#include <filesystem>
#include <map>
#include <numeric>
#include <random>
#include <set>
#include <unordered_map>
#include <utility>

#include "Log.hh"
#include "PLAPI.hh"
#include "ipl_io.h"
#include "json/json.hpp"
#include "omp.h"
#include "tool_manager.h"
#include "usage/usage.hh"

namespace gtl = boost::polygon;
using namespace gtl::operators;
typedef gtl::polygon_90_set_data<int> PolygonSet;

namespace ipl {

#define PRINT_LONG_NET 0
#define PRINT_COORDI 0
#define PLOT_IMAGE 1
#define RECORD_ITER_INFO 0
#define PRINT_DENSITY_MAP 0

#define SQRT2 1.414213562373095048801L

void NesterovPlace::initNesConfig(Config* config)
{
  _nes_config = config->get_nes_config();
  _global_right_padding = _nes_config.get_global_padding();

  // Legacy behavior: when max-wirelength/timing optimization is enabled from
  // the JSON surface, the config has no explicit opt_overflow_list and the
  // solver appends its historical default thresholds. If a config explicitly
  // supplied a list (including an empty one), keep it verbatim.
  if ((_nes_config.isOptMaxWirelength() || _nes_config.isOptTiming()) && !_nes_config.isOptOverflowListConfigured()
      && _nes_config.get_opt_overflow_list().empty()) {
    _nes_config.add_opt_target_overflow(0.15);
    _nes_config.add_opt_target_overflow(0.20);
    _nes_config.add_opt_target_overflow(0.25);
    _nes_config.add_opt_target_overflow(0.30);
  }
}

void NesterovPlace::initNesDatabase(PlacerDB* placer_db)
{
  _nes_database = new NesterovDatabase();
  _nes_database->_placer_db = placer_db;

  wrapNesInstanceList();
  wrapNesNetList();
  wrapNesPinList();
  completeConnection();

  if (_nes_config.isAdaptiveBin()) {
    this->calculateAdaptiveBinCnt();
    LOG_INFO << "Change to Adaptive Bin: (" << _nes_config.get_bin_cnt_x() << "," << _nes_config.get_bin_cnt_y() << ")" << std::endl;
  }

  initGridManager();
  initTopologyManager();
  notifyPLBinSize();
  initHPWLEvaluator();
  initWAWLGradientEvaluator();
  if (_nes_config.isOptTiming()) {
    initTimingAnnotation();
  }
}

void NesterovPlace::calculateAdaptiveBinCnt()
{
  int32_t inst_cnt = _nes_database->_nInstances_range;
  int32_t side_cnt = 2;
  while (side_cnt * side_cnt < inst_cnt) {
    side_cnt *= 2;
  }

  int32_t bin_cnt_x = side_cnt;
  int32_t bin_cnt_y = side_cnt;

  const Layout* layout = _nes_database->_placer_db->get_layout();
  int32_t core_width = layout->get_core_shape().get_width();
  int32_t core_height = layout->get_core_shape().get_height();

  if (core_width > core_height) {
    bin_cnt_x *= std::pow(2, static_cast<int32_t>(round(static_cast<float>(core_width) / core_height)) - 1);
  } else {
    bin_cnt_y *= std::pow(2, static_cast<int32_t>(round(static_cast<float>(core_height) / core_width)) - 1);
  }

  _nes_config.set_bin_cnt_x(bin_cnt_x);
  _nes_config.set_bin_cnt_y(bin_cnt_y);
}

void NesterovPlace::notifyPLBinSize()
{
  int32_t bin_size_x = _nes_database->_grid_manager->get_grid_size_x();
  int32_t bin_size_y = _nes_database->_grid_manager->get_grid_size_y();

  PlacerDBInst.bin_size_x = bin_size_x;
  PlacerDBInst.bin_size_y = bin_size_y;
}

void NesterovPlace::wrapNesInstanceList()
{
  auto inst_list = _nes_database->_placer_db->get_design()->get_instance_list();

  for (auto* inst : inst_list) {
    // skip the outside inst
    if (inst->isOutsideInstance()) {
      continue;
    }

    NesInstance* n_inst = new NesInstance(inst->get_name());

    wrapNesInstance(inst, n_inst);

    _nes_database->_nInstance_list.push_back(n_inst);
    _nes_database->_nInstance_map.emplace(inst, n_inst);
    _nes_database->_instance_map.emplace(n_inst, inst);
    n_inst->set_inst_id(_nes_database->_nInstances_range);
    _nes_database->_nInstances_range += 1;
  }
}

void NesterovPlace::wrapNesInstance(Instance* inst, NesInstance* nesInst)
{
  auto inst_shape = inst->get_shape();
  int32_t site_width = _nes_database->_placer_db->get_layout()->get_site_width();
  int32_t right_padding = _global_right_padding * site_width;
  nesInst->set_origin_shape(
      Rectangle<int32_t>(inst_shape.get_ll_x(), inst_shape.get_ll_y(), inst_shape.get_ur_x() + right_padding, inst_shape.get_ur_y()));

  if (inst->isFixed()) {
    nesInst->set_fixed();
  }

  if (inst->get_cell_master() && inst->get_cell_master()->isMacro()) {
    nesInst->set_macro();
  }
}

void NesterovPlace::wrapNesNetList()
{
  for (auto* net : _nes_database->_placer_db->get_design()->get_net_list()) {
    NesNet* n_net = new NesNet(net->get_name());

    wrapNesNet(net, n_net);

    _nes_database->_nNet_list.push_back(n_net);
    _nes_database->_nNet_map.emplace(net, n_net);
    _nes_database->_net_map.emplace(n_net, net);
    n_net->set_net_id(_nes_database->_nNets_range);
    _nes_database->_nNets_range += 1;
  }
}

void NesterovPlace::wrapNesNet(Net* net, NesNet* nesNet)
{
  nesNet->set_weight(net->get_net_weight());

  if (net->isDontCareNet()) {
    nesNet->set_dont_care();
  }
}

void NesterovPlace::wrapNesPinList()
{
  for (auto* pin : _nes_database->_placer_db->get_design()->get_pin_list()) {
    NesPin* n_pin = new NesPin(pin->get_name());

    wrapNesPin(pin, n_pin);

    _nes_database->_nPin_list.push_back(n_pin);
    _nes_database->_nPin_map.emplace(pin, n_pin);
    _nes_database->_pin_map.emplace(n_pin, pin);
    n_pin->set_pin_id(_nes_database->_nPins_range);
    _nes_database->_nPins_range += 1;
  }
}

void NesterovPlace::wrapNesPin(Pin* pin, NesPin* nesPin)
{
  int32_t origin_offset_x = pin->get_offset_coordi().get_x();
  int32_t origin_offset_y = pin->get_offset_coordi().get_y();

  auto* inst = pin->get_instance();
  if (!inst) {
    nesPin->set_offset_coordi(Point<int32_t>(origin_offset_x, origin_offset_y));
  } else {
    int32_t modify_offset_x = 0;
    int32_t modify_offset_y = 0;

    Orient inst_orient = inst->get_orient();
    if (inst_orient == Orient::kN_R0) {
      modify_offset_x = origin_offset_x;
      modify_offset_y = origin_offset_y;
    } else if (inst_orient == Orient::kW_R90) {
      modify_offset_x = (-1) * origin_offset_y;
      modify_offset_y = origin_offset_x;
    } else if (inst_orient == Orient::kS_R180) {
      modify_offset_x = (-1) * origin_offset_x;
      modify_offset_y = (-1) * origin_offset_y;
    } else if (inst_orient == Orient::kFW_MX90) {
      modify_offset_x = origin_offset_y;
      modify_offset_y = origin_offset_x;
    } else if (inst_orient == Orient::kFN_MY) {
      modify_offset_x = (-1) * origin_offset_x;
      modify_offset_y = origin_offset_y;
    } else if (inst_orient == Orient::kFE_MY90) {
      modify_offset_x = (-1) * origin_offset_y;
      modify_offset_y = (-1) * origin_offset_x;
    } else if (inst_orient == Orient::kFS_MX) {
      modify_offset_x = origin_offset_x;
      modify_offset_y = (-1) * origin_offset_y;
    } else if (inst_orient == Orient::kE_R270) {
      modify_offset_x = origin_offset_y;
      modify_offset_y = (-1) * origin_offset_x;
    } else {
      LOG_WARNING << inst->get_name() + " has not the orient!";
    }
    nesPin->set_offset_coordi(Point<int32_t>(modify_offset_x, modify_offset_y));
  }
  nesPin->set_center_coordi(std::move(pin->get_center_coordi()));
}

void NesterovPlace::completeConnection()
{
  for (auto pair : _nes_database->_nPin_map) {
    auto* pin = pair.first;
    auto* n_pin = pair.second;

    auto* inst = pin->get_instance();

    // skip the outside inst.
    if (inst && !inst->isOutsideInstance()) {
      auto* n_inst = _nes_database->_nInstance_map[inst];

      n_pin->set_nInstance(n_inst);
      n_inst->add_nPin(n_pin);
    }

    auto* net = pin->get_net();
    auto* n_net = _nes_database->_nNet_map[net];

    n_pin->set_nNet(n_net);

    auto* driver_pin = net->get_driver_pin();
    if (driver_pin) {
      if (driver_pin->get_name() == pin->get_name()) {
        n_net->set_driver(n_pin);
      } else {
        n_net->add_loader(n_pin);
      }
    } else {
      n_net->add_loader(n_pin);
    }
  }
}

void NesterovPlace::initGridManager()
{
  Rectangle<int32_t> core_shape = _nes_database->_placer_db->get_layout()->get_core_shape();
  int32_t grid_cnt_x = _nes_config.get_bin_cnt_x();
  int32_t grid_cnt_y = _nes_config.get_bin_cnt_y();
  float target_density = _nes_config.get_target_density();

  GridManager* grid_manager = new GridManager(core_shape, grid_cnt_x, grid_cnt_y, target_density, _nes_config.get_thread_num());
  _nes_database->_grid_manager = grid_manager;

  // BinGrid specially need to parallel
  _nes_database->_bin_grid = new BinGrid(grid_manager);
  _nes_database->_bin_grid->set_thread_nums(_nes_config.get_thread_num());
  int route_cap_h = _nes_database->_placer_db->get_layout()->get_route_cap_h();
  int route_cap_v = _nes_database->_placer_db->get_layout()->get_route_cap_v();
  int partial_route_cap_h = _nes_database->_placer_db->get_layout()->get_partial_route_cap_h();
  int partial_route_cap_v = _nes_database->_placer_db->get_layout()->get_partial_route_cap_v();
  _nes_database->_bin_grid->set_route_cap_h(route_cap_h);
  _nes_database->_bin_grid->set_route_cap_v(route_cap_v);
  _nes_database->_bin_grid->set_partial_route_cap_h(partial_route_cap_h);
  _nes_database->_bin_grid->set_partial_route_cap_v(partial_route_cap_v);

  _nes_database->_density = new Density(grid_manager);
  _nes_database->_density_gradient = new ElectricFieldGradient(grid_manager);  // TODO : be optional.
}

void NesterovPlace::initTopologyManager()
{
  TopologyManager* topo_manager = new TopologyManager();
  _nes_database->_topology_manager = topo_manager;

  this->initNodes();
  this->initNetWorks();
  this->initGroups();
  this->initArcs();

  if (_nes_config.isOptTiming()) {
    topo_manager->updateALLNodeTopoId();
  }
}

void NesterovPlace::initNodes()
{
  auto* topo_manager = _nes_database->_topology_manager;
  for (auto pair : _nes_database->_pin_map) {
    auto* n_pin = pair.first;
    Node* node = new Node(n_pin->get_name());
    node->set_location(std::move(n_pin->get_center_coordi()));
    auto* pl_pin = pair.second;

    // set node type.
    if (pl_pin->isInstanceInput() || pl_pin->isIOInput()) {
      node->set_node_type(NODE_TYPE::kInput);
    } else if (pl_pin->isInstanceOutput() || pl_pin->isIOOutput()) {
      node->set_node_type(NODE_TYPE::kOutput);
    } else if (pl_pin->isInstanceInputOutput() || pl_pin->isIOInputOutput()) {
      node->set_node_type(NODE_TYPE::kInputOutput);
    } else {
      node->set_node_type(NODE_TYPE::kNone);
    }

    // set is io node
    if (pl_pin->isIOPort()) {
      node->set_is_io();
    }
    topo_manager->add_node(node);
    node->set_node_id(n_pin->get_pin_id());  // not match in origin order
  }
  topo_manager->sortNodeList();
}

void NesterovPlace::initNetWorks()
{
  auto* topo_manager = _nes_database->_topology_manager;
  for (auto pair : _nes_database->_net_map) {
    auto* n_net = pair.first;
    NetWork* network = new NetWork(n_net->get_name());

    network->set_net_weight(n_net->get_weight());

    auto* pl_net = pair.second;

    // set network type.
    if (pl_net->isClockNet()) {
      network->set_network_type(NETWORK_TYPE::kClock);
    } else if (pl_net->isFakeNet()) {
      network->set_network_type(NETWORK_TYPE::kFakeNet);
    } else if (pl_net->isSignalNet()) {
      network->set_network_type(NETWORK_TYPE::kSignal);
    } else {
      network->set_network_type(NETWORK_TYPE::kNone);
    }

    NesPin* driver = n_net->get_driver();
    if (driver) {
      Node* transmitter = topo_manager->findNodeById(driver->get_pin_id());
      transmitter->set_network(network);
      network->set_transmitter(transmitter);
    }

    for (auto* loader : n_net->get_loader_list()) {
      Node* receiver = topo_manager->findNodeById(loader->get_pin_id());
      receiver->set_network(network);
      network->add_receiver(receiver);
    }

    topo_manager->add_network(network);
    network->set_network_id(n_net->get_net_id());  // not match in origin order.
  }
  topo_manager->sortNetworkList();
}

void NesterovPlace::initGroups()
{
  auto* topo_manager = _nes_database->_topology_manager;
  for (auto pair : _nes_database->_instance_map) {
    auto* n_inst = pair.first;
    Group* group = new Group(n_inst->get_name());

    auto* pl_inst = pair.second;
    // set group type.
    auto* cell_master = pl_inst->get_cell_master();
    if (cell_master) {
      if (cell_master->isFlipflop()) {
        group->set_group_type(GROUP_TYPE::kFlipflop);
      } else if (cell_master->isClockBuffer()) {
        group->set_group_type(GROUP_TYPE::kClockBuffer);
      } else if (cell_master->isLogicBuffer()) {
        group->set_group_type(GROUP_TYPE::kLogicBuffer);
      } else if (cell_master->isMacro()) {
        group->set_group_type(GROUP_TYPE::kMacro);
      } else if (cell_master->isIOCell()) {
        group->set_group_type(GROUP_TYPE::kIOCell);
      } else if (cell_master->isLogic()) {
        group->set_group_type(GROUP_TYPE::kLogic);
      } else {
        group->set_group_type(GROUP_TYPE::kNone);
      }
    } else {
      group->set_group_type(GROUP_TYPE::kNone);
    }

    for (auto* n_pin : n_inst->get_nPin_list()) {
      Node* node = topo_manager->findNodeById(n_pin->get_pin_id());
      node->set_group(group);
      group->add_node(node);
    }
    topo_manager->add_group(group);
    group->set_group_id(pl_inst->get_inst_id());  // not match in origin order.
  }
  topo_manager->sortGroupList();
}

void NesterovPlace::initArcs()
{
  auto* topo_manager = _nes_database->_topology_manager;
  for (auto* node : topo_manager->get_node_list()) {
    // TODO: Consider the INPUT & OUTPUT Case.
    if (node->is_io_node()) {
      if (node->get_node_type() == NODE_TYPE::kOutput) {
        this->generateNetArc(node);
      }

    } else {
      if (node->get_node_type() == NODE_TYPE::kInput) {
        this->generateNetArc(node);
      } else if (node->get_node_type() == NODE_TYPE::kOutput) {
        this->generateGroupArc(node);
      }
    }
  }
  topo_manager->sortArcList();
}

void NesterovPlace::generatePortOutNetArc(Node* node)
{
  auto* topo_manager = _nes_database->_topology_manager;
  auto* network = node->get_network();
  if (network) {
    for (auto* sink_node : network->get_receiver_list()) {
      Arc* net_arc = new Arc(node, sink_node);
      net_arc->set_arc_type(ARC_TYPE::kNetArc);
      node->add_output_arc(net_arc);
      sink_node->add_input_arc(net_arc);
      topo_manager->add_arc(net_arc);
    }
  }
}

void NesterovPlace::generateNetArc(Node* node)
{
  auto* topo_manager = _nes_database->_topology_manager;
  auto* network = node->get_network();
  if (network) {
    auto* driver_node = network->get_transmitter();
    if (driver_node) {
      Arc* net_arc = new Arc(driver_node, node);
      net_arc->set_arc_type(ARC_TYPE::kNetArc);
      driver_node->add_output_arc(net_arc);
      node->add_input_arc(net_arc);
      topo_manager->add_arc(net_arc);
    }
  }
}

void NesterovPlace::generateGroupArc(Node* node)
{
  auto* topo_manager = _nes_database->_topology_manager;
  auto* group = node->get_group();
  if (group) {
    auto input_list = group->obtainInputNodes();
    for (auto* input_node : input_list) {
      NetWork* input_net = input_node->get_network();
      if (input_net->get_network_type() != NETWORK_TYPE::kClock && group->get_group_type() == GROUP_TYPE::kFlipflop) {
        continue;
      }

      Arc* group_arc = new Arc(input_node, node);
      group_arc->set_arc_type(ARC_TYPE::kGroupArc);
      input_node->add_output_arc(group_arc);
      node->add_input_arc(group_arc);
      topo_manager->add_arc(group_arc);
    }
  }
}

void NesterovPlace::initHPWLEvaluator()
{
  _nes_database->_wirelength = new HPWirelength(_nes_database->_topology_manager);
}

void NesterovPlace::initWAWLGradientEvaluator()
{
  _nes_database->_wirelength_gradient = new WAWirelengthGradient(_nes_database->_topology_manager);
}

void NesterovPlace::initTimingAnnotation()
{
  _nes_database->_timing_annotation = new TimingAnnotation(_nes_database->_topology_manager);
}

void NesterovPlace::initFillerNesInstance()
{
  std::vector<int32_t> edge_x_assemble;
  std::vector<int32_t> edge_y_assemble;

  // record area.
  int64_t nonplace_area = 0;
  int64_t occupied_area = 0;

  Rectangle<int32_t> core_rect = _nes_database->_placer_db->get_layout()->get_core_shape();
  PolygonSet ps;
  for (auto* n_inst : _nes_database->_nInstance_list) {
    Rectangle<int32_t> n_inst_shape = n_inst->get_origin_shape();
    int64_t shape_area_x = static_cast<int64_t>(n_inst_shape.get_width());
    int64_t shape_area_y = static_cast<int64_t>(n_inst_shape.get_height());

    // skip fixed nInsts.
    if (n_inst->isFixed()) {
      ps.insert(
          gtl::rectangle_data<int>(n_inst_shape.get_ll_x(), n_inst_shape.get_ll_y(), n_inst_shape.get_ur_x(), n_inst_shape.get_ur_y()));
      continue;
    }
    if (n_inst->isMacro()) {
      occupied_area += shape_area_x * shape_area_y * _nes_config.get_target_density();
    } else {
      occupied_area += shape_area_x * shape_area_y;
    }

    edge_x_assemble.push_back(shape_area_x);
    edge_y_assemble.push_back(shape_area_y);
  }
  for (auto* blockage : _nes_database->_placer_db->get_design()->get_region_list()) {
    for (auto boundary : blockage->get_boundaries()) {
      // non_place_instance_area += boundary_width * boundary_height;
      auto rect = gtl::rectangle_data<int>(boundary.get_ll_x(), boundary.get_ll_y(), boundary.get_ur_x(), boundary.get_ur_y());
      ps.insert(rect);
    }
  }
  ps &= gtl::rectangle_data<int>(core_rect.get_ll_x(), core_rect.get_ll_y(), core_rect.get_ur_x(), core_rect.get_ur_y());

  std::vector<gtl::rectangle_data<int>> rects;
  ps.get_rectangles(rects);

  for (const auto& rect : rects) {
    nonplace_area += 1LL * boost::polygon::area(rect);
  }

  // sort
  std::sort(edge_x_assemble.begin(), edge_x_assemble.end());
  std::sort(edge_y_assemble.begin(), edge_y_assemble.end());

  int64_t edge_x_sum = 0, edge_y_sum = 0;

  int min_idx = edge_x_assemble.size() * 0.05;
  int max_idx = edge_y_assemble.size() * 0.95;
  for (int i = min_idx; i < max_idx; i++) {
    edge_x_sum += edge_x_assemble[i];
    edge_y_sum += edge_y_assemble[i];
  }

  // Avoid division by zero
  int idx_range = max_idx - min_idx;
  if (idx_range <= 0) {
    LOG_WARNING << "Invalid index range for filler calculation (min_idx=" << min_idx << ", max_idx=" << max_idx << "), using fallback values";
    idx_range = 1;
    if (!edge_x_assemble.empty()) {
      edge_x_sum = edge_x_assemble[0];
      edge_y_sum = edge_y_assemble[0];
    }
  }

  int avg_edge_x = static_cast<int>(edge_x_sum / idx_range);
  int avg_edge_y = static_cast<int>(edge_y_sum / idx_range);

  Rectangle<int32_t> core_shape = _nes_database->_placer_db->get_layout()->get_core_shape();
  int64_t core_area = static_cast<int64_t>(core_shape.get_width()) * static_cast<int64_t>(core_shape.get_height());
  int64_t white_space_area = core_area - nonplace_area;
  int64_t movable_area = white_space_area * _nes_config.get_target_density();
  int64_t total_filler_area = movable_area - occupied_area;

  LOG_ERROR_IF(total_filler_area < 0) << "Detect: Negative filler area \n"
                                      << "       The reason may be target_density setting: try to improve target_density \n";

  std::mt19937 rand_val(0);

  // int32_t filler_cnt = total_filler_area / (avg_edge_x * avg_edge_y);

  // Avoid division by zero - check if avg_edge dimensions are valid
  int32_t filler_cnt = 0;
  if (avg_edge_x > 0 && avg_edge_y > 0 && total_filler_area > 0) {
    int64_t filler_area_per_cell = static_cast<int64_t>(avg_edge_x) * static_cast<int64_t>(avg_edge_y);
    filler_cnt = std::ceil(static_cast<float>(total_filler_area) / static_cast<float>(filler_area_per_cell));
  } else {
    LOG_WARNING << "Invalid filler parameters: avg_edge_x=" << avg_edge_x
                << ", avg_edge_y=" << avg_edge_y
                << ", total_filler_area=" << total_filler_area
                << " - skipping filler insertion";
  }

  for (int i = 0; i < filler_cnt; i++) {
    auto rand_x = rand_val();
    auto rand_y = rand_val();

    NesInstance* filler = new NesInstance("filler_" + std::to_string(i));

    int32_t center_x = rand_x % core_shape.get_width() + core_shape.get_ll_x();
    int32_t center_y = rand_y % core_shape.get_height() + core_shape.get_ll_y();
    int32_t lower_x = center_x - avg_edge_x / 2;
    int32_t lower_y = center_y - avg_edge_y / 2;

    filler->set_filler();
    filler->set_origin_shape(Rectangle<int32_t>(lower_x, lower_y, lower_x + avg_edge_x, lower_y + avg_edge_y));

    _nes_database->_nInstance_list.push_back(filler);
    filler->set_inst_id(_nes_database->_nInstances_range);
    _nes_database->_nInstances_range += 1;
  }
}

void NesterovPlace::initNesInstanceDensitySize()
{
  for (auto* n_inst : _nes_database->_nInstance_list) {
    if (n_inst->isFixed()) {
      n_inst->set_density_shape(n_inst->get_origin_shape());
      n_inst->set_density_scale(1.0F);
      continue;
    }

    float scale_x = 0, scale_y = 0;
    int32_t density_size_x = 0, density_size_y = 0;

    Rectangle<int32_t> first_grid_shape = this->obtainFirstGridShape();

    int32_t grid_size_x = first_grid_shape.get_width();
    int32_t grid_size_y = first_grid_shape.get_height();

    Rectangle<int32_t> n_inst_shape = n_inst->get_origin_shape();
    int32_t n_inst_width = n_inst_shape.get_width();
    int32_t n_inst_height = n_inst_shape.get_height();

    if (n_inst_width < static_cast<int32_t>(SQRT2 * grid_size_x)) {
      scale_x = static_cast<float>(n_inst_width) / (SQRT2 * grid_size_x);
      density_size_x = static_cast<int32_t>(SQRT2 * grid_size_x);
    } else {
      scale_x = 1.0F;
      density_size_x = n_inst_width;
    }

    if (n_inst_height < static_cast<int32_t>(SQRT2 * grid_size_y)) {
      scale_y = static_cast<float>(n_inst_height) / (SQRT2 * grid_size_y);
      density_size_y = static_cast<int32_t>(SQRT2 * grid_size_y);
    } else {
      scale_y = 1.0F;
      density_size_y = n_inst_height;
    }

    n_inst->set_density_shape(Rectangle<int32_t>(n_inst_shape.get_ll_x(), n_inst_shape.get_ll_y(), n_inst_shape.get_ll_x() + density_size_x,
                                                 n_inst_shape.get_ll_y() + density_size_y));
    n_inst->set_density_scale(scale_x * scale_y);
  }
}

bool NesterovPlace::isFiniteMetric(float value) const
{
  return std::isfinite(value);
}

void NesterovPlace::resetRunState()
{
  _last_result = NesterovPlaceResult{};
  _iteration_records.clear();
  _best_hpwl = INT64_MAX;
  _best_overflow = FLT_MAX;
  _nes_database->_is_diverged = false;
  resetOverflowRecordList();
  resetHPWLRecordList();
}

void NesterovPlace::recordIteration(int32_t iter_num, float overflow, int64_t hpwl, float step_length, float gradient_norm,
                                    float route_util, bool quad_penalty_enabled, bool entropy_injected)
{
  NesterovIterationRecord record;
  record.iter = iter_num;
  record.hpwl = hpwl;
  record.overflow = overflow;
  record.step_length = step_length;
  record.gradient_norm = gradient_norm;
  record.density_penalty = _nes_database->_density_penalty;
  record.route_util = route_util;
  record.quad_penalty_enabled = quad_penalty_enabled;
  record.entropy_injected = entropy_injected;
  std::string reason;
  if (!validateNesterovIterationRecord(record, _iteration_records.empty() ? 0 : _iteration_records.back().iter, &reason)) {
    _nes_database->_is_diverged = true;
    finalizeResult(NesterovPlaceOutcome::kInvalidMetric, iter_num, hpwl, overflow, gradient_norm, step_length,
                   record.density_penalty, route_util, reason);
    return;
  }
  _iteration_records.push_back(record);
}

void NesterovPlace::finalizeResult(NesterovPlaceOutcome outcome, int32_t iterations, int64_t hpwl, float overflow, float gradient_norm,
                                   float step_length, float density_penalty, float route_util, std::string reason)
{
  _last_result.success = (outcome == NesterovPlaceOutcome::kConverged);
  _last_result.outcome = outcome;
  _last_result.iterations = iterations;
  _last_result.hpwl = hpwl;
  _last_result.overflow = overflow;
  _last_result.gradient_norm = gradient_norm;
  _last_result.step_length = step_length;
  _last_result.density_penalty = density_penalty;
  _last_result.route_util = route_util;
  _last_result.reason = std::move(reason);
  _last_result.iteration_records = _iteration_records;
}

bool NesterovPlace::runNesterovPlace()
{
  std::cout << std::endl;
  LOG_INFO << "-----------------Start Global Placement-----------------";
  ieda::Stats gp_status;
  resetRunState();

  std::vector<NesInstance*> placable_inst_list = std::move(this->obtianPlacableNesInstanceList());
  if (placable_inst_list.empty()) {
    finalizeResult(NesterovPlaceOutcome::kInvalidMetric, 0, 0, 0.0F, 0.0F, 0.0F, 0.0F, 0.0F,
                   "global placement requires at least one movable instance");
    return false;
  }
  initNesterovPlace(placable_inst_list);

  // main
  NesterovSolve(placable_inst_list);
  if (isNesterovHardFailure(_last_result.outcome)) {
    LOG_ERROR << "Global placement terminated: " << _last_result.reason;
    return false;
  }
  PlacerDBInst.updateTopoManager();
  PlacerDBInst.updateGridManager();

  double time_delta = gp_status.elapsedRunTime();
  LOG_INFO << "Global Placement Total Time Elapsed: " << time_delta << "s";
  LOG_INFO << "-----------------Finish Global Placement-----------------";
  return _last_result.success;
}

void NesterovPlace::initNesterovPlace(std::vector<NesInstance*>& inst_list)
{
  size_t inst_size = inst_list.size();

  std::vector<Point<int32_t>> prev_coordi_list(inst_size, Point<int32_t>());
  std::vector<Point<float>> prev_wirelength_grad_list(inst_size, Point<float>());
  std::vector<Point<float>> prev_density_grad_list(inst_size, Point<float>());
  std::vector<Point<float>> prev_sum_grad_list(inst_size, Point<float>());
  std::vector<Point<int32_t>> current_coordi_list(inst_size, Point<int32_t>());
  std::vector<Point<float>> current_wirelength_grad_list(inst_size, Point<float>());
  std::vector<Point<float>> current_density_grad_list(inst_size, Point<float>());
  std::vector<Point<float>> current_sum_grad_list(inst_size, Point<float>());

  // initial coordi vector.
  Rectangle<int32_t> core_shape = _nes_database->_placer_db->get_layout()->get_core_shape();

#pragma omp parallel for num_threads(_nes_config.get_thread_num())
  for (size_t i = 0; i < inst_size; i++) {
    auto* n_inst = inst_list[i];
    this->updateDensityCoordiLayoutInside(n_inst, core_shape);
    current_coordi_list[i] = Point<int32_t>(n_inst->get_density_center_coordi().get_x(), n_inst->get_density_center_coordi().get_y());
  }

  initGridFixedArea();
  // update current density gradient force.
  _nes_database->_bin_grid->updateBinGrid(inst_list, _nes_config.get_thread_num());
  _nes_database->_density_gradient->updateDensityForce(_nes_config.get_thread_num(), false);

  _total_inst_area = this->obtainTotalArea(inst_list);
  if (_total_inst_area <= 0) {
    _nes_database->_is_diverged = true;
    finalizeResult(NesterovPlaceOutcome::kInvalidMetric, 0, _nes_database->_wirelength->obtainTotalWirelength(), 0.0F, 0.0F, 0.0F,
                   0.0F, 0.0F, "global placement requires positive movable instance area");
    return;
  }
  float sum_overflow = static_cast<float>(_nes_database->_bin_grid->get_overflow_area_without_filler()) / _total_inst_area;

  // update current wirelength gradient force.
  initBaseWirelengthCoef();
  updateWirelengthCoef(sum_overflow);
  float wirelength_coef = _nes_database->_wirelength_coef;
  updateTopologyManager();
  _nes_database->_wirelength_gradient->updateWirelengthForce(wirelength_coef, wirelength_coef, _nes_config.get_min_wirelength_force_bar(),
                                                             _nes_config.get_thread_num());

  // update current target penalty object.
  updatePenaltyGradient(inst_list, current_sum_grad_list, current_wirelength_grad_list, current_density_grad_list, false);

  if (_nes_database->_is_diverged) {
    finalizeResult(NesterovPlaceOutcome::kInvalidMetric, 0, _nes_database->_wirelength->obtainTotalWirelength(), sum_overflow,
                   _nes_database->_wirelength_grad_sum + _nes_database->_density_grad_sum, 0.0F,
                   _nes_database->_density_penalty, 0.0F, "global placement produced an invalid initial gradient");
    return;
  }

  // update initial prev coordinates.
#pragma omp parallel for num_threads(_nes_config.get_thread_num())
  for (size_t i = 0; i < inst_size; i++) {
    auto* n_inst = inst_list[i];

    int32_t prev_coordi_x
        = current_coordi_list[i].get_x() + _nes_config.get_initial_prev_coordi_update_coef() * current_sum_grad_list[i].get_x();
    int32_t prev_coordi_y
        = current_coordi_list[i].get_y() + _nes_config.get_initial_prev_coordi_update_coef() * current_sum_grad_list[i].get_y();
    Point<int32_t> prev_coordi(prev_coordi_x, prev_coordi_y);
    n_inst->updateDensityCenterLocation(prev_coordi);
    this->updateDensityCoordiLayoutInside(n_inst, core_shape);
    prev_coordi_list[i] = Point<int32_t>(n_inst->get_density_center_coordi().get_x(), n_inst->get_density_center_coordi().get_y());
  }

  // update prev density gradient force.
  _nes_database->_bin_grid->updateBinGrid(inst_list, _nes_config.get_thread_num());
  _nes_database->_density_gradient->updateDensityForce(_nes_config.get_thread_num(), false);

  // update prev wirelength gradient force.
  updateTopologyManager();
  _nes_database->_wirelength_gradient->updateWirelengthForce(wirelength_coef, wirelength_coef, _nes_config.get_min_wirelength_force_bar(),
                                                             _nes_config.get_thread_num());

  // update prev target penalty object.
  updatePenaltyGradient(inst_list, prev_sum_grad_list, prev_wirelength_grad_list, prev_density_grad_list, false);

  if (_nes_database->_is_diverged) {
    finalizeResult(NesterovPlaceOutcome::kInvalidMetric, 0, _nes_database->_wirelength->obtainTotalWirelength(), sum_overflow,
                   _nes_database->_wirelength_grad_sum + _nes_database->_density_grad_sum, 0.0F,
                   _nes_database->_density_penalty, 0.0F, "global placement produced an invalid previous gradient");
    return;
  }

  // init quad penalty
  initQuadPenaltyCoeff();

  // init density penalty.
  if (_nes_database->_is_diverged || !isFiniteMetric(_nes_database->_wirelength_grad_sum)
      || !isFiniteMetric(_nes_database->_density_grad_sum) || _nes_database->_density_grad_sum <= 0.0F) {
    _nes_database->_is_diverged = true;
    finalizeResult(NesterovPlaceOutcome::kInvalidMetric, 0, _nes_database->_wirelength->obtainTotalWirelength(), sum_overflow,
                   _nes_database->_wirelength_grad_sum + _nes_database->_density_grad_sum, 0.0F, 0.0F, 0.0F,
                   "global placement produced an invalid initial gradient");
    return;
  }
  _nes_database->_density_penalty
      = (_nes_database->_wirelength_grad_sum / _nes_database->_density_grad_sum) * _nes_config.get_init_density_penalty();
  if (!isFiniteMetric(_nes_database->_density_penalty) || _nes_database->_density_penalty < 0.0F) {
    _nes_database->_is_diverged = true;
    finalizeResult(NesterovPlaceOutcome::kInvalidMetric, 0, _nes_database->_wirelength->obtainTotalWirelength(), sum_overflow,
                   _nes_database->_wirelength_grad_sum + _nes_database->_density_grad_sum, 0.0F,
                   _nes_database->_density_penalty, 0.0F, "global placement produced an invalid initial density penalty");
    return;
  }

  // init nesterov solver.
  _nes_database->_nesterov_solver->initNesterov(prev_coordi_list, prev_sum_grad_list, current_coordi_list, current_sum_grad_list);

  // Test Preconditon.
  // initDiagonalIdentityMatrix(inst_size);
  // initDiagonalHkMatrix(inst_list);
  // initDiagonalSkMatrix(inst_list);
}

std::vector<NesInstance*> NesterovPlace::obtianPlacableNesInstanceList()
{
  std::vector<NesInstance*> placable_list;
  for (auto* n_inst : _nes_database->_nInstance_list) {
    if (n_inst->isFixed()) {
      continue;
    }
    placable_list.push_back(n_inst);
  }
  return placable_list;
}

void NesterovPlace::updateDensityCoordiLayoutInside(NesInstance* n_inst, Rectangle<int32_t> core_shape)
{
  int32_t target_lower_x = n_inst->get_density_coordi().get_x();
  int32_t target_lower_y = n_inst->get_density_coordi().get_y();
  int32_t target_edge_x = n_inst->get_density_shape().get_width();
  int32_t target_edge_y = n_inst->get_density_shape().get_height();

  if (target_lower_x < core_shape.get_ll_x()) {
    target_lower_x = core_shape.get_ll_x();
  }

  if (target_lower_y < core_shape.get_ll_y()) {
    target_lower_y = core_shape.get_ll_y();
  }

  if (target_lower_x + target_edge_x > core_shape.get_ur_x()) {
    target_lower_x = core_shape.get_ur_x() - target_edge_x;
  }

  if (target_lower_y + target_edge_y > core_shape.get_ur_y()) {
    target_lower_y = core_shape.get_ur_y() - target_edge_y;
  }

  n_inst->updateDensityLocation(Point<int32_t>(target_lower_x, target_lower_y));
}

void NesterovPlace::updateDensityCenterCoordiLayoutInside(NesInstance* n_inst, Point<int32_t>& center_coordi, Rectangle<int32_t> core_shape)
{
  int32_t target_edge_x = n_inst->get_density_shape().get_width();
  int32_t target_edge_y = n_inst->get_density_shape().get_height();

  int32_t target_lower_x = center_coordi.get_x() - 0.5 * target_edge_x;
  int32_t target_lower_y = center_coordi.get_y() - 0.5 * target_edge_y;

  if (target_lower_x < core_shape.get_ll_x()) {
    target_lower_x = core_shape.get_ll_x();
  }

  if (target_lower_y < core_shape.get_ll_y()) {
    target_lower_y = core_shape.get_ll_y();
  }

  if (target_lower_x + target_edge_x > core_shape.get_ur_x()) {
    target_lower_x = core_shape.get_ur_x() - target_edge_x;
  }

  if (target_lower_y + target_edge_y > core_shape.get_ur_y()) {
    target_lower_y = core_shape.get_ur_y() - target_edge_y;
  }

  center_coordi = Point<int32_t>(target_lower_x + std::ceil(0.5 * target_edge_x), target_lower_y + std::ceil(0.5 * target_edge_y));
}

void NesterovPlace::initGridFixedArea()
{
  auto* grid_manager = _nes_database->_grid_manager;

  grid_manager->clearAllOccupiedArea();

  // #pragma omp parallel for num_threads(_nes_config.get_thread_num())
  for (auto* n_inst : _nes_database->_nInstance_list) {
    if (!n_inst->isFixed()) {
      continue;
    }

    std::vector<Grid*> overlap_grid_list;
    auto origin_shape = std::move(n_inst->get_origin_shape());
    grid_manager->obtainOverlapGridList(overlap_grid_list, origin_shape);
    for (auto* grid : overlap_grid_list) {
      int64_t overlap_area = grid_manager->obtainOverlapArea(grid, n_inst->get_origin_shape());

      // #pragma omp atomic
      grid->fixed_area += overlap_area * grid->available_ratio;
      // grid->add_fixed_area(overlap_area * grid->get_available_ratio());
    }
  }

  // add blockage.
  auto region_list = _nes_database->_placer_db->get_design()->get_region_list();
  for (auto* region : region_list) {
    if (region->isFence()) {
      std::vector<Grid*> overlap_grid_list;
      for (auto boundary : region->get_boundaries()) {
        grid_manager->obtainOverlapGridList(overlap_grid_list, boundary);
        for (auto* grid : overlap_grid_list) {
          // tmp fix overlap area between fixed inst and blockage.
          if (grid->fixed_area != 0) {
            continue;
          }

          // if (grid->get_fixed_area() != 0) {
          //   continue;
          // }
          int64_t overlap_area = grid_manager->obtainOverlapArea(grid, boundary);

          grid->fixed_area += overlap_area * grid->available_ratio;
          // grid->add_fixed_area(overlap_area * grid->get_available_ratio());
        }
      }
    }
  }
}

void NesterovPlace::updateTopologyManager()
{
  auto* topo_manager = _nes_database->_topology_manager;
  int32_t thread_num = _nes_config.get_thread_num();

  int32_t net_chunk_size = std::max(int(_nes_database->_nNet_list.size() / thread_num / 16), 1);
#pragma omp parallel for num_threads(thread_num) schedule(dynamic, net_chunk_size)
  for (auto* n_net : _nes_database->_nNet_list) {
    if (n_net->isDontCare()) {
      continue;
    }
    auto* network = topo_manager->findNetworkById(n_net->get_net_id());
    network->set_net_weight(n_net->get_weight());
  }

  int32_t pin_chunk_size = std::max(int(_nes_database->_nPin_list.size() / thread_num / 16), 1);
#pragma omp parallel for num_threads(thread_num) schedule(dynamic, pin_chunk_size)
  for (auto* n_pin : _nes_database->_nPin_list) {
    auto* node = topo_manager->findNodeById(n_pin->get_pin_id());
    node->set_location(n_pin->get_center_coordi());
  }
}

Rectangle<int32_t> NesterovPlace::obtainFirstGridShape()
{
  auto& first_grid = _nes_database->_grid_manager->get_grid_2d_list()[0][0];

  return first_grid.shape;

  // auto* first_grid = _nes_database->_grid_manager->get_row_list()[0]->get_grid_list()[0];

  // return first_grid->get_shape();
}

int64_t NesterovPlace::obtainTotalArea(std::vector<NesInstance*>& inst_list)
{
  int64_t total_area = 0;
  for (auto* n_inst : inst_list) {
    if (n_inst->isFiller()) {
      continue;
    }

    int64_t n_inst_width = static_cast<int64_t>(n_inst->get_origin_shape().get_width());
    int64_t n_inst_height = static_cast<int64_t>(n_inst->get_origin_shape().get_height());

    if (n_inst->isMacro()) {
      total_area += static_cast<int64_t>(n_inst_width * n_inst_height * _nes_config.get_target_density());
    } else {
      total_area += n_inst_width * n_inst_height;
    }
  }

  return total_area;
}

int64_t NesterovPlace::obtainTotalFillerArea(std::vector<NesInstance*>& inst_list)
{
  int64_t total_filler_area = 0;

  for (auto* n_inst : inst_list) {
    if (n_inst->isFiller()) {
      int64_t n_inst_width = static_cast<int64_t>(n_inst->get_origin_shape().get_width());
      int64_t n_inst_height = static_cast<int64_t>(n_inst->get_origin_shape().get_height());
      total_filler_area += n_inst_width * n_inst_height;
    }
  }

  return total_filler_area;
}

void NesterovPlace::initBaseWirelengthCoef()
{
  Rectangle<int32_t> first_grid_shape = this->obtainFirstGridShape();
  _nes_database->_base_wirelength_coef
      = _nes_config.get_init_wirelength_coef() / (static_cast<float>(first_grid_shape.get_half_perimeter()) * 0.5);
}

void NesterovPlace::updateWirelengthCoef(float overflow)
{
  if (overflow > 1.0) {
    _nes_database->_wirelength_coef = 0.1;
  } else if (overflow < 0.1) {
    _nes_database->_wirelength_coef = 10.0;
  } else {
    _nes_database->_wirelength_coef = 1.0 / pow(10.0, (overflow - 0.1) * 20 / 9.0 - 1.0);
  }

  _nes_database->_wirelength_coef *= _nes_database->_base_wirelength_coef;
}

void NesterovPlace::initDiagonalIdentityMatrix(int32_t inst_size)
{
  _global_diagonal_list.resize(2 * inst_size, 1.0);
}

void NesterovPlace::initDiagonalHkMatrix(std::vector<NesInstance*>& inst_list)
{
  size_t inst_size = inst_list.size();
  _global_diagonal_list.resize(2 * inst_size, 1.0);

  for (size_t i = 0; i < inst_size; i++) {
    auto* cur_n_inst = inst_list[i];
    Point<float> wirelength_precondition = std::move(obtainWirelengthPrecondition(cur_n_inst));
    Point<float> density_precondition = std::move(obtainDensityPrecondition(cur_n_inst));
    float coeff = wirelength_precondition.get_x() + _nes_database->_density_penalty * density_precondition.get_x();
    _global_diagonal_list[i] = static_cast<double>(coeff);
    _global_diagonal_list[inst_size + i] = static_cast<double>(coeff);
  }
}

void NesterovPlace::initDiagonalSkMatrix(std::vector<NesInstance*>& inst_list)
{
  size_t inst_size = inst_list.size();
  _global_diagonal_list.resize(2 * inst_size, 1.0);

  for (size_t i = 0; i < inst_size; i++) {
    auto* cur_n_inst = inst_list[i];
    Point<float> wirelength_precondition = std::move(obtainWirelengthPrecondition(cur_n_inst));
    Point<float> density_precondition = std::move(obtainDensityPrecondition(cur_n_inst));
    float coeff = wirelength_precondition.get_x() + _nes_database->_density_penalty * density_precondition.get_x();
    _global_diagonal_list[i] = static_cast<double>(1 / coeff);
    _global_diagonal_list[inst_size + i] = static_cast<double>(1 / coeff);
  }
}

void NesterovPlace::updatePenaltyGradientPre1(std::vector<NesInstance*>& nInst_list, std::vector<Point<float>>& sum_grads,
                                              std::vector<Point<float>>& wirelength_grads, std::vector<Point<float>>& density_grads)
{
  // if((_nes_database->_nesterov_solver->get_current_iter()) % 100 == 0){
  //   LOG_INFO << "Iteration: "<< _nes_database->_nesterov_solver->get_current_iter() <<" Reset precondition.";
  //   _global_diagonal_list.clear();
  //   initDiagonalHkMatrix(nInst_list);
  // }
  _nes_database->_density_grad_sum = 0.0F;

  // const auto& front_coordi_list = _nes_database->_nesterov_solver->get_current_coordis();
  // const auto& current_coordi_list = _nes_database->_nesterov_solver->get_next_coordis();
  // const auto& front_grad_list = _nes_database->_nesterov_solver->get_current_grads();
  // const auto& current_grad_list = _nes_database->_nesterov_solver->get_next_grads();

  // // prcondition method 1
  // size_t inst_size = nInst_list.size();
  // std::vector<double> front_ski_x(inst_size);
  // std::vector<double> front_ski_y(inst_size);
  // std::vector<double> front_yki_x(inst_size);
  // std::vector<double> front_yki_y(inst_size);
  // double sk2hk_variable = 0.0;
  // double yksk_variable = 0.0;
  // for(size_t i=0; i < inst_size; i++){
  //   front_ski_x[i] = current_coordi_list[i].get_x() - front_coordi_list[i].get_x();
  //   front_ski_y[i] = current_coordi_list[i].get_y() - front_coordi_list[i].get_y();
  //   sk2hk_variable += (front_ski_x[i] * front_ski_x[i] * _global_diagonal_list[i]);
  //   sk2hk_variable += (front_ski_y[i] * front_ski_y[i] * _global_diagonal_list[i+inst_size]);

  //   front_yki_x[i] = current_grad_list[i].get_x() - front_grad_list[i].get_x();
  //   front_yki_y[i] = current_grad_list[i].get_y() - front_grad_list[i].get_y();
  //   yksk_variable += (front_yki_x[i] * front_ski_x[i] + front_yki_y[i] * front_ski_y[i]);
  // }

  for (size_t i = 0; i < nInst_list.size(); i++) {
    auto& cur_n_inst = nInst_list[i];

    wirelength_grads[i] = std::move(_nes_database->_wirelength_gradient->obtainWirelengthGradient(
        cur_n_inst->get_inst_id(), _nes_database->_wirelength_coef, _nes_database->_wirelength_coef));
    density_grads[i] = std::move(
        _nes_database->_density_gradient->obtainDensityGradient(cur_n_inst->get_density_shape(), cur_n_inst->get_density_scale(), 0, 0.0f));

    _nes_database->_wirelength_grad_sum += fabs(wirelength_grads[i].get_x());
    _nes_database->_wirelength_grad_sum += fabs(wirelength_grads[i].get_y());

    _nes_database->_density_grad_sum += fabs(density_grads[i].get_x());
    _nes_database->_density_grad_sum += fabs(density_grads[i].get_y());

    sum_grads[i].set_x(wirelength_grads[i].get_x() + _nes_database->_density_penalty * density_grads[i].get_x());
    sum_grads[i].set_y(wirelength_grads[i].get_y() + _nes_database->_density_penalty * density_grads[i].get_y());

    // // prcondition method 1
    // double hksk_x = _global_diagonal_list[i] * front_ski_x[i];
    // double hksk_y = _global_diagonal_list[inst_size + i] * front_ski_y[i];
    // float hki_x = static_cast<float>(_global_diagonal_list[i] - (hksk_x * hksk_x) / sk2hk_variable + (front_yki_x[i] * front_yki_x[i]) /
    // yksk_variable); float hki_y = static_cast<float>(_global_diagonal_list[inst_size + i] - (hksk_y * hksk_y) / sk2hk_variable +
    // (front_yki_y[i] * front_yki_y[i]) / yksk_variable); Point<float> sum_precondition(hki_x,hki_y);

    // if (sum_precondition.get_x() <= _nes_config.get_min_precondition()) {
    //   sum_precondition.set_x(_nes_config.get_min_precondition());
    // }
    // if (sum_precondition.get_y() <= _nes_config.get_min_precondition()) {
    //   sum_precondition.set_y(_nes_config.get_min_precondition());
    // }

    Point<float> sum_precondition(1.0, 1.0);

    sum_grads[i].set_x(sum_grads[i].get_x() / sum_precondition.get_x());
    sum_grads[i].set_y(sum_grads[i].get_y() / sum_precondition.get_y());

    // _global_diagonal_list[i] = hki_x;
    // _global_diagonal_list[inst_size + i] = hki_y;
  }

  if (std::isnan(_nes_database->_wirelength_grad_sum) || std::isinf(_nes_database->_wirelength_grad_sum)
      || std::isnan(_nes_database->_density_grad_sum) || std::isinf(_nes_database->_density_grad_sum)) {
    _nes_database->_is_diverged = true;
  }
}

void NesterovPlace::updatePenaltyGradientPre2(std::vector<NesInstance*>& nInst_list, std::vector<Point<float>>& sum_grads,
                                              std::vector<Point<float>>& wirelength_grads, std::vector<Point<float>>& density_grads)
{
  _nes_database->_wirelength_grad_sum = 0.0F;
  _nes_database->_density_grad_sum = 0.0F;

  const auto& front_coordi_list = _nes_database->_nesterov_solver->get_current_coordis();
  const auto& current_coordi_list = _nes_database->_nesterov_solver->get_next_coordis();
  const auto& front_grad_list = _nes_database->_nesterov_solver->get_current_grads();
  const auto& current_grad_list = _nes_database->_nesterov_solver->get_next_grads();

  // prcondition method 2
  size_t inst_size = nInst_list.size();
  std::vector<double> front_ski_x(inst_size);
  std::vector<double> front_ski_y(inst_size);
  std::vector<double> front_yki_x(inst_size);
  std::vector<double> front_yki_y(inst_size);
  double yksk_variable = 0.0;
  for (size_t i = 0; i < inst_size; i++) {
    front_ski_x[i] = current_coordi_list[i].get_x() - front_coordi_list[i].get_x();
    front_ski_y[i] = current_coordi_list[i].get_y() - front_coordi_list[i].get_y();
    front_yki_x[i] = current_grad_list[i].get_x() - front_grad_list[i].get_x();
    front_yki_y[i] = current_grad_list[i].get_y() - front_grad_list[i].get_y();
    yksk_variable += (front_yki_x[i] * front_ski_x[i] + front_yki_y[i] * front_ski_y[i]);
  }

  for (size_t i = 0; i < nInst_list.size(); i++) {
    auto& cur_n_inst = nInst_list[i];

    wirelength_grads[i] = std::move(_nes_database->_wirelength_gradient->obtainWirelengthGradient(
        cur_n_inst->get_inst_id(), _nes_database->_wirelength_coef, _nes_database->_wirelength_coef));
    density_grads[i] = std::move(
        _nes_database->_density_gradient->obtainDensityGradient(cur_n_inst->get_density_shape(), cur_n_inst->get_density_scale(), 0, 0.0f));

    _nes_database->_wirelength_grad_sum += fabs(wirelength_grads[i].get_x());
    _nes_database->_wirelength_grad_sum += fabs(wirelength_grads[i].get_y());

    _nes_database->_density_grad_sum += fabs(density_grads[i].get_x());
    _nes_database->_density_grad_sum += fabs(density_grads[i].get_y());

    sum_grads[i].set_x(wirelength_grads[i].get_x() + _nes_database->_density_penalty * density_grads[i].get_x());
    sum_grads[i].set_y(wirelength_grads[i].get_y() + _nes_database->_density_penalty * density_grads[i].get_y());

    // prcondition method 2
    double bk_coeff_x = (1.0 - front_ski_x[i] * front_yki_x[i] / yksk_variable);
    double bk_coeff_y = (1.0 - front_ski_y[i] * front_yki_y[i] / yksk_variable);
    float bki_x
        = static_cast<float>((bk_coeff_x * bk_coeff_x * _global_diagonal_list[i]) + (front_ski_x[i] * front_ski_x[i]) / yksk_variable);
    float bki_y = static_cast<float>((bk_coeff_y * bk_coeff_y * _global_diagonal_list[inst_size + i])
                                     + (front_ski_y[i] * front_ski_y[i]) / yksk_variable);
    Point<float> sum_precondition(bki_x, bki_y);

    if (sum_precondition.get_x() >= _nes_config.get_min_precondition()) {
      sum_precondition.set_x(_nes_config.get_min_precondition());
    }
    if (sum_precondition.get_y() >= _nes_config.get_min_precondition()) {
      sum_precondition.set_y(_nes_config.get_min_precondition());
    }

    sum_grads[i].set_x(sum_grads[i].get_x() * sum_precondition.get_x());
    sum_grads[i].set_y(sum_grads[i].get_y() * sum_precondition.get_y());

    _global_diagonal_list[i] = bki_x;
    _global_diagonal_list[inst_size + i] = bki_y;
  }

  if (std::isnan(_nes_database->_wirelength_grad_sum) || std::isinf(_nes_database->_wirelength_grad_sum)
      || std::isnan(_nes_database->_density_grad_sum) || std::isinf(_nes_database->_density_grad_sum)) {
    _nes_database->_is_diverged = true;
  }
}

void NesterovPlace::updatePenaltyGradient(std::vector<NesInstance*>& nInst_list, std::vector<Point<float>>& sum_grads,
                                          std::vector<Point<float>>& wirelength_grads, std::vector<Point<float>>& density_grads,
                                          bool is_add_quad_penalty)
{
  _nes_database->_wirelength_grad_sum = 0.0F;
  _nes_database->_density_grad_sum = 0.0F;

#pragma omp parallel for num_threads(_nes_config.get_thread_num())
  for (size_t i = 0; i < nInst_list.size(); i++) {
    auto& cur_n_inst = nInst_list[i];

    wirelength_grads[i] = std::move(_nes_database->_wirelength_gradient->obtainWirelengthGradient(
        cur_n_inst->get_inst_id(), _nes_database->_wirelength_coef, _nes_database->_wirelength_coef));
    density_grads[i] = std::move(_nes_database->_density_gradient->obtainDensityGradient(
        cur_n_inst->get_density_shape(), cur_n_inst->get_density_scale(), is_add_quad_penalty, _quad_penalty_coeff));
  }

  float density_penalty = _nes_database->_density_penalty;
  if (is_add_quad_penalty) {
    density_penalty *= (1.0 + 2 * _quad_penalty_coeff * _nes_database->_density_gradient->get_sum_phi());
    density_penalty *= 2;
  }

  for (size_t i = 0; i < nInst_list.size(); i++) {
    auto& cur_n_inst = nInst_list[i];
    _nes_database->_wirelength_grad_sum += fabs(wirelength_grads[i].get_x());
    _nes_database->_wirelength_grad_sum += fabs(wirelength_grads[i].get_y());

    _nes_database->_density_grad_sum += fabs(density_grads[i].get_x());
    _nes_database->_density_grad_sum += fabs(density_grads[i].get_y());

    sum_grads[i].set_x(wirelength_grads[i].get_x() + density_penalty * density_grads[i].get_x());
    sum_grads[i].set_y(wirelength_grads[i].get_y() + density_penalty * density_grads[i].get_y());

    Point<float> wirelength_precondition = std::move(obtainWirelengthPrecondition(cur_n_inst));
    Point<float> density_precondition = std::move(obtainDensityPrecondition(cur_n_inst));
    Point<float> sum_precondition(wirelength_precondition.get_x() + _nes_database->_density_penalty * density_precondition.get_x(),
                                  wirelength_precondition.get_y() + _nes_database->_density_penalty * density_precondition.get_y());

    if (sum_precondition.get_x() <= _nes_config.get_min_precondition()) {
      sum_precondition.set_x(_nes_config.get_min_precondition());
    }
    if (sum_precondition.get_y() <= _nes_config.get_min_precondition()) {
      sum_precondition.set_y(_nes_config.get_min_precondition());
    }

    sum_grads[i].set_x(sum_grads[i].get_x() / sum_precondition.get_x());
    sum_grads[i].set_y(sum_grads[i].get_y() / sum_precondition.get_y());

    // Local scope (M4): scale the preconditioned gradient by the movement
    // coefficient. Empty scope = global GP, bit-identical to no masking.
    if (!_move_coeff_list.empty()) {
      sum_grads[i].set_x(sum_grads[i].get_x() * _move_coeff_list[i]);
      sum_grads[i].set_y(sum_grads[i].get_y() * _move_coeff_list[i]);
    }
  }

  if (std::isnan(_nes_database->_wirelength_grad_sum) || std::isinf(_nes_database->_wirelength_grad_sum)
      || std::isnan(_nes_database->_density_grad_sum) || std::isinf(_nes_database->_density_grad_sum)) {
    _nes_database->_is_diverged = true;
  }
}

Point<float> NesterovPlace::obtainWirelengthPrecondition(NesInstance* n_inst)
{
  float wl_factor = 0.0;
  for (auto* n_pin : n_inst->get_nPin_list()) {
    wl_factor += n_pin->get_nNet()->get_weight();
  }
  return Point<float>(wl_factor, wl_factor);
}

Point<float> NesterovPlace::obtainDensityPrecondition(NesInstance* n_inst)
{
  float n_inst_width = static_cast<float>(n_inst->get_origin_shape().get_width());
  float n_inst_height = static_cast<float>(n_inst->get_origin_shape().get_height());

  float area_val = n_inst_width * n_inst_height;
  return Point<float>(area_val, area_val);
}

float NesterovPlace::obtainPhiCoef(float scaled_diff_hpwl, int32_t iteration_num)
{
  float ret_coef = (scaled_diff_hpwl < 0) ? _nes_config.get_max_phi_coef() * std::max(std::pow(0.9999, float(iteration_num)), 0.98)
                                          : _nes_config.get_max_phi_coef() * pow(_nes_config.get_max_phi_coef(), scaled_diff_hpwl * -1.0);
  ret_coef = std::min(_nes_config.get_max_phi_coef(), ret_coef);
  ret_coef = std::max(_nes_config.get_min_phi_coef(), ret_coef);
  return ret_coef;
}

void NesterovPlace::NesterovSolve(std::vector<NesInstance*>& inst_list)
{
  // Legacy driver: run the session from setup to terminal in one shot.
  // Behavior is bit-equivalent to the pre-session implementation.
  _placable_inst_list = inst_list;
  setupNesterovSolve();
  if (_last_result.outcome != NesterovPlaceOutcome::kNotRun) {
    return;
  }
  advanceAcceptedIterations(INT32_MAX);
  finishSession();
}

void NesterovPlace::setupNesterovSolve()
{
  if (_last_result.outcome != NesterovPlaceOutcome::kNotRun) {
    return;
  }
  // diverged control.
  if (_nes_database->_is_diverged) {
    LOG_ERROR << "Detect diverged, The reason may be parameters setting.";
    finalizeResult(NesterovPlaceOutcome::kDiverged, 0, 0, 0.0f, 0.0f, 0.0f, _nes_database->_density_penalty, 0.0f,
                   "diverged before optimization started");
    return;
  }

  const size_t inst_size = _placable_inst_list.size();

  _prev_hpwl = _nes_database->_wirelength->obtainTotalWirelength();

  _next_slp_wirelength_grad_list.assign(inst_size, Point<float>());
  _next_slp_density_grad_list.assign(inst_size, Point<float>());
  _next_slp_sum_grad_list.assign(inst_size, Point<float>());

  _sum_overflow_threshold = 1e25;
  _hpwl_attach_sum_overflow = 1e25;
  _max_phi_coef_record = false;

  // opt setting
  const std::vector<float>& opt_overflow_list = _nes_config.get_opt_overflow_list();
  _cur_opt_overflow_step = opt_overflow_list.size() - 1;

  // prepare for long net opt.
  if (PRINT_LONG_NET) {
    float layout_ratio = 0.5;
    auto core_shape = _nes_database->_placer_db->get_layout()->get_core_shape();
    _long_width = core_shape.get_width() * layout_ratio;
    _long_height = core_shape.get_height() * layout_ratio;
    _long_net_stream.open(iPLAPIInst.obtainTargetDir() + "/pl/AcrossLongNet_process.txt");
    if (!_long_net_stream.good()) {
      LOG_WARNING << "Cannot open file for recording across long net !";
    }
  }

  // prepare for iter info record
  if (RECORD_ITER_INFO) {
    _info_stream.open(iPLAPIInst.obtainTargetDir() + "/pl/plIterInfo.csv");
    if (!_info_stream.good()) {
      LOG_WARNING << "Cannot open file for iter info record !";
    }
  }

  // prepare for convergence acceleration and non-convergence treatment
  _last_perturb_iter = -50;
  _is_add_quad_penalty = false;
  _is_cal_phi = false;
  _stop_placement = false;
  _best_position_list.resize(inst_size);
  _cur_position_list.resize(inst_size);
  // WP-PL-01: snapshot density_scale with best placement so diverge rollback restores inflation.
  _best_density_scale_list.assign(inst_size, 1.0f);
  _cur_density_scale_list.assign(inst_size, 1.0f);
  _finished_iter = 0;
  _final_step_length = 0.0f;
  _final_gradient_norm = 0.0f;
  _final_route_util = 0.0f;

  if (_nes_config.isOptCongestion()) {
    _nes_database->_bin_grid->evalRouteCap(_nes_config.get_thread_num());
    // _nes_database->_bin_grid->plotRouteCap();
  }

  _solve_setup_done = true;
}

GPAdvanceOutcome NesterovPlace::advanceAcceptedIterations(int32_t budget)
{
  if (!_solve_setup_done) {
    return GPAdvanceOutcome::kNotInitialized;
  }
  if (_last_result.outcome != NesterovPlaceOutcome::kNotRun) {
    return GPAdvanceOutcome::kAlreadyFinished;
  }
  if (budget <= 0) {
    return GPAdvanceOutcome::kBudgetReached;
  }

  auto* solver = _nes_database->_nesterov_solver;
  const size_t inst_size = _placable_inst_list.size();

  // Local scope (M4): snapshot the batch-start coordinates; context instances
  // (coefficient 0) are pinned to them for the whole batch.
  if (!_move_coeff_list.empty()) {
    _frozen_coord_list.resize(inst_size);
    for (size_t i = 0; i < inst_size; i++) {
      _frozen_coord_list[i] = _placable_inst_list[i]->get_density_center_coordi();
    }
  }

  Rectangle<int32_t> core_shape = _nes_database->_placer_db->get_layout()->get_core_shape();

  // opt setting
  const std::vector<float>& opt_overflow_list = _nes_config.get_opt_overflow_list();

  // algorithm core loop.
  const int64_t last_iter = std::min<int64_t>(_nes_config.get_max_iter(), static_cast<int64_t>(_current_iter) + budget);
  for (int32_t iter_num = _current_iter + 1; iter_num <= last_iter; iter_num++) {
    bool iter_entropy_injected = false;
    solver->runNextIter(iter_num, _nes_config.get_thread_num());
    int32_t num_backtrack = 0;
    for (; num_backtrack < _nes_config.get_max_back_track(); num_backtrack++) {
      auto& next_coordi_list = solver->get_next_coordis();
      auto& next_slp_coordi_list = solver->get_next_slp_coordis();

#pragma omp parallel for num_threads(_nes_config.get_thread_num())
      for (size_t i = 0; i < inst_size; i++) {
        Point<int32_t> next_coordi(next_coordi_list[i].get_x(), next_coordi_list[i].get_y());
        Point<int32_t> next_slp_coordi(next_slp_coordi_list[i].get_x(), next_slp_coordi_list[i].get_y());

        // Local scope (M4): freeze context (coeff 0) at the batch-start position
        // and scale halo (0<coeff<1) movement; active (coeff 1) passes through.
        if (!_move_coeff_list.empty()) {
          const float coeff = _move_coeff_list[i];
          if (coeff <= 0.0F) {
            next_coordi = _frozen_coord_list[i];
            next_slp_coordi = _frozen_coord_list[i];
          } else if (coeff < 1.0F) {
            next_coordi.set_x(_frozen_coord_list[i].get_x()
                              + static_cast<int32_t>(coeff * (next_coordi.get_x() - _frozen_coord_list[i].get_x())));
            next_coordi.set_y(_frozen_coord_list[i].get_y()
                              + static_cast<int32_t>(coeff * (next_coordi.get_y() - _frozen_coord_list[i].get_y())));
            next_slp_coordi.set_x(_frozen_coord_list[i].get_x()
                                  + static_cast<int32_t>(coeff * (next_slp_coordi.get_x() - _frozen_coord_list[i].get_x())));
            next_slp_coordi.set_y(_frozen_coord_list[i].get_y()
                                  + static_cast<int32_t>(coeff * (next_slp_coordi.get_y() - _frozen_coord_list[i].get_y())));
          }
        }

        updateDensityCenterCoordiLayoutInside(_placable_inst_list[i], next_coordi, core_shape);
        solver->correctNextCoordi(i, next_coordi);
        _cur_position_list[i] = next_coordi;
        _cur_density_scale_list[i] = _placable_inst_list[i]->get_density_scale();

        updateDensityCenterCoordiLayoutInside(_placable_inst_list[i], next_slp_coordi, core_shape);
        solver->correctNextSLPCoordi(i, next_slp_coordi);
        _placable_inst_list[i]->updateDensityCenterLocation(next_slp_coordi);
      }

      _nes_database->_bin_grid->updateBinGrid(_placable_inst_list, _nes_config.get_thread_num());

      // print density map for debug
      if (iter_num == 60 && PRINT_DENSITY_MAP) {
        printDensityMapToCsv("density_map_" + std::to_string(iter_num));
      }

      _nes_database->_density_gradient->updateDensityForce(_nes_config.get_thread_num(), _is_cal_phi);

      updateTopologyManager();

      _sum_overflow = static_cast<float>(_nes_database->_bin_grid->get_overflow_area_without_filler()) / _total_inst_area;
      _cur_hpwl = _nes_database->_wirelength->obtainTotalWirelength();
      const float gradient_norm = _nes_database->_wirelength_grad_sum + _nes_database->_density_grad_sum;
      const float step_length = solver->get_next_steplength();
      const float route_util = _nes_config.isOptCongestion()
                                   ? std::max(_nes_database->_grid_manager->get_h_util_max(),
                                              _nes_database->_grid_manager->get_v_util_max())
                                   : 0.0F;
      if (!isFiniteMetric(_sum_overflow) || _sum_overflow < 0.0f || _cur_hpwl < 0 || !isFiniteMetric(gradient_norm)
          || gradient_norm < 0.0F || !isFiniteMetric(step_length) || step_length < 0.0F
          || !isFiniteMetric(_nes_database->_density_penalty) || _nes_database->_density_penalty < 0.0F
          || !isFiniteMetric(route_util) || route_util < 0.0F) {
        _nes_database->_is_diverged = true;
        finalizeResult(NesterovPlaceOutcome::kInvalidMetric, iter_num, _cur_hpwl, _sum_overflow,
                       gradient_norm, step_length, _nes_database->_density_penalty, route_util,
                       "global placement produced an invalid metric");
        break;
      }
      // Congestion information is refreshed in the congestion-aware branch below
      // as soon as density overflow enters its operating window.

      if (!_nes_config.isOptCongestion()) {
        _nes_database->_wirelength_gradient->updateWirelengthForce(_nes_database->_wirelength_coef, _nes_database->_wirelength_coef,
                                                                   _nes_config.get_min_wirelength_force_bar(),
                                                                   _nes_config.get_thread_num());
      } else {
        // Enter congestion-aware wirelength earlier: overflow<=0.75 (was 0.5).
        if (_sum_overflow > 0.75f) {
          _nes_database->_wirelength_gradient->updateWirelengthForce(_nes_database->_wirelength_coef, _nes_database->_wirelength_coef,
                                                                     _nes_config.get_min_wirelength_force_bar(),
                                                                     _nes_config.get_thread_num());
        } else {
          // LUT-RUDY based congestion-driven optimization.
          _nes_database->_bin_grid->evalRouteDem(_nes_database->_topology_manager->get_network_list(), _nes_config.get_thread_num());
          _nes_database->_bin_grid->fastGaussianBlur();
          _nes_database->_bin_grid->evalRouteUtil();
          // Congestion shapes the wirelength force directly. Density-scale
          // inflation was removed here: repeated inflation had positive
          // feedback and drove the solver to 3-7x overflow on real designs.
          iter_entropy_injected = true;
          // _nes_database->_bin_grid->plotOverflowUtil(_sum_overflow, iter_num);

          // TODO: GR based congestion-driven optimization.
          // writeBackPlacerDB();
          // PlacerDBInst.writeBackSourceDataBase();
          // eval::EvalAPI& eval_api = eval::EvalAPI::initInst();
          // std::vector<float> gr_congestion = eval_api.evalGRCong();

          auto grid_manager = _nes_database->_bin_grid->get_grid_manager();
          _nes_database->_wirelength_gradient->updateWirelengthForceDirect(_nes_database->_wirelength_coef, _nes_database->_wirelength_coef,
                                                                           _nes_config.get_min_wirelength_force_bar(),
                                                                           _nes_config.get_thread_num(), grid_manager);
        }
      }

  // update next target penalty object.
  updatePenaltyGradient(_placable_inst_list, _next_slp_sum_grad_list, _next_slp_wirelength_grad_list, _next_slp_density_grad_list, _is_add_quad_penalty);

  if (_nes_database->_is_diverged) {
    finalizeResult(NesterovPlaceOutcome::kInvalidMetric, iter_num, _cur_hpwl, _sum_overflow,
                   _nes_database->_wirelength_grad_sum + _nes_database->_density_grad_sum, solver->get_next_steplength(),
                   _nes_database->_density_penalty, _final_route_util, "global placement produced an invalid gradient");
    break;
  }

  float current_steplength = solver->get_next_steplength();
  solver->calculateNextSteplength(_next_slp_sum_grad_list);
  float next_steplength = solver->get_next_steplength();

  if (next_steplength > current_steplength * 0.95) {
    break;
  } else {
    solver->runBackTrackIter(_nes_config.get_thread_num());
  }
}

  if (num_backtrack == _nes_config.get_max_back_track()) {
    LOG_ERROR << "Detect divergence,"
              << " The reason may be high init_density_penalty value";
    _nes_database->_is_diverged = true;
  }

  if (_nes_database->_is_diverged && _last_result.outcome == NesterovPlaceOutcome::kNotRun) {
    finalizeResult(NesterovPlaceOutcome::kDiverged, iter_num, _prev_hpwl, _sum_overflow,
                   _nes_database->_wirelength_grad_sum + _nes_database->_density_grad_sum, solver->get_next_steplength(),
                   _nes_database->_density_penalty, _final_route_util, "nesterov diverged during iteration");
    break;
  }

  if (RECORD_ITER_INFO) {
    if (iter_num == 1) {
      _info_stream << "WireLength Grad Sum,Density Grad Sum,Density Weight,StepLength" << std::endl;
    }
    printIterInfoToCsv(_info_stream, iter_num);
  }

  _final_step_length = solver->get_next_steplength();
  _final_gradient_norm = _nes_database->_wirelength_grad_sum + _nes_database->_density_grad_sum;
  if (_nes_config.isOptCongestion()) {
    _final_route_util = std::max(_nes_database->_grid_manager->get_h_util_max(), _nes_database->_grid_manager->get_v_util_max());
  }
  recordIteration(iter_num, _sum_overflow, _prev_hpwl, _final_step_length, _final_gradient_norm, _final_route_util, _is_add_quad_penalty,
                  iter_entropy_injected);
  if (_last_result.outcome == NesterovPlaceOutcome::kInvalidMetric) {
    break;
  }

if (_nes_config.isOptMaxWirelength()) {
  if (_cur_opt_overflow_step >= 0 && _sum_overflow < opt_overflow_list[_cur_opt_overflow_step]) {
    // update net weight.
    updateMaxLengthNetWeight();
    --_cur_opt_overflow_step;
    LOG_INFO << "[NesterovSolve] Begin update netweight for max wirelength constraint.";
  }
}

if (_nes_config.isOptTiming()) {
  if (_cur_opt_overflow_step >= 0 && _sum_overflow < opt_overflow_list[_cur_opt_overflow_step]) {
    // update net weight.
    updateTimingNetWeight();
    --_cur_opt_overflow_step;
    LOG_INFO << "[NesterovSolve] Update netweight for timing improvement.";
  }
}

updateWirelengthCoef(_sum_overflow);
if (!_max_phi_coef_record && _sum_overflow < 0.35f) {
  _max_phi_coef_record = true;
  _nes_config.set_max_phi_coef(0.985 * _nes_config.get_max_phi_coef());
}

_cur_hpwl = _nes_database->_wirelength->obtainTotalWirelength();

float phi_coef = obtainPhiCoef(static_cast<float>(_cur_hpwl - _prev_hpwl) / _nes_config.get_reference_hpwl(), iter_num);
_prev_hpwl = _cur_hpwl;
_nes_database->_density_penalty *= phi_coef;

// print info.
if (iter_num == 1 || iter_num % _nes_config.get_info_iter_num() == 0) {
  LOG_INFO << "[NesterovSolve] Iter: " << iter_num << " overflow: " << _sum_overflow << " HPWL: " << _prev_hpwl;

  if (PRINT_LONG_NET) {
    _long_net_stream << "CURRENT ITERATION: " << iter_num << std::endl;
    _long_net_stream << std::endl;
    printAcrossLongNet(_long_net_stream, _long_width, _long_height);
  }

  if (isJsonOutputEnabled()) {
    plotInstJson("inst_" + std::to_string(iter_num), iter_num, _sum_overflow);

    printDensityMapToCsv("density/density_map_" + std::to_string(iter_num));
  }
}

if (iter_num == 1 || iter_num % 5 == 0) {
  if (PRINT_COORDI) {
    saveNesterovPlaceData(iter_num);
  }
}

if (_sum_overflow_threshold > _sum_overflow) {
  _sum_overflow_threshold = _sum_overflow;
  _hpwl_attach_sum_overflow = _prev_hpwl;
}

  if (_sum_overflow < 0.32f && _sum_overflow - _sum_overflow_threshold >= 0.05f && _hpwl_attach_sum_overflow * 1.25f < _prev_hpwl) {
    LOG_ERROR << "Detect divergence. \n"
              << "    The reason may be max_phi_cof value: try to decrease max_phi_cof";
    _nes_database->_is_diverged = true;
    finalizeResult(NesterovPlaceOutcome::kDiverged, iter_num, _prev_hpwl, _sum_overflow, _final_gradient_norm, _final_step_length,
                   _nes_database->_density_penalty, _final_route_util, "overflow and HPWL diverged");
    break;
  }

_overflow_record_list.push_back(_sum_overflow);
_hpwl_record_list.push_back(_cur_hpwl);

if (_sum_overflow < _best_overflow) {
  _best_hpwl = _cur_hpwl;
  _best_overflow = _sum_overflow;
  _best_position_list.swap(_cur_position_list);
  _best_density_scale_list.swap(_cur_density_scale_list);
}

if (_sum_overflow < _nes_config.get_target_overflow() * 4 && _sum_overflow > _nes_config.get_target_overflow() * 1.1) {
  if (checkDivergence(3, 0.03 * _sum_overflow) || checkLongTimeOverflowUnchanged(100, 0.03 * _sum_overflow)) {
    // rollback to best pos (+ density_scale when congestion inflation was active).
    for (size_t i = 0; i < inst_size; i++) {
      updateDensityCenterCoordiLayoutInside(_placable_inst_list[i], _best_position_list[i], core_shape);
      if (_nes_config.isOptCongestion()) {
        _placable_inst_list[i]->set_density_scale(_best_density_scale_list[i]);
      }
    }
    _sum_overflow = _best_overflow;
    _prev_hpwl = _best_hpwl;

    _stop_placement = true;
  }
}

if (iter_num - _last_perturb_iter > 50 && checkPlateau(50, 0.01)) {
  if (_sum_overflow > 0.9) {
    // quad mode
    _is_add_quad_penalty = true;
    _is_cal_phi = true;
    LOG_INFO << "Try to enable quadratic penalty for density to accelerate convergence";
    if (_sum_overflow > 0.95) {
      float noise_intensity = std::min(std::max(40 + (120 - 40) * (_sum_overflow - 0.95) * 10, 40.0), 90.0)
                              * _nes_database->_placer_db->get_layout()->get_site_width();
      entropyInjection(0.996, noise_intensity);
      LOG_INFO << "Try to entropy injection with noise intensity = " << noise_intensity << " to help convergence";
    }
    _last_perturb_iter = iter_num;
  }
}

// minimun iteration is 30
  if ((iter_num > 30 && _sum_overflow <= _nes_config.get_target_overflow()) || _stop_placement) {
  if (PRINT_LONG_NET) {
    _long_net_stream << "CURRENT ITERATION: " << iter_num << std::endl;
    _long_net_stream << std::endl;
    printAcrossLongNet(_long_net_stream, _long_width, _long_height);
    _long_net_stream.close();
  }

  if (RECORD_ITER_INFO) {
    _info_stream.close();
  }

  if (PRINT_COORDI) {
    saveNesterovPlaceData(iter_num);
    }

    LOG_INFO << "[NesterovSolve] Finished with Overflow:" << _sum_overflow << " HPWL : " << _prev_hpwl;
    bool converged = (iter_num > 30 && _sum_overflow <= _nes_config.get_target_overflow());
    // Plateau rollback near the target is a usable global placement: the
    // solver recovered its best-observed state and further iterations do not
    // improve it. Accept it instead of discarding the transaction and leaving
    // an unusable result (observed on picorv32 full-netlist around ov=0.117).
    if (!converged && _stop_placement && _sum_overflow <= _nes_config.get_target_overflow() * 1.2F) {
      converged = true;
      LOG_INFO << "[NesterovSolve] Accepting near-target plateau placement within 20% of target overflow.";
    }
    finalizeResult(converged ? NesterovPlaceOutcome::kConverged : NesterovPlaceOutcome::kOverflowTargetMiss, iter_num, _prev_hpwl,
                   _sum_overflow, _final_gradient_norm, _final_step_length, _nes_database->_density_penalty, _final_route_util,
                   converged ? "global placement converged" : "global placement stopped before reaching target overflow");
    break;
  }

  _finished_iter = iter_num;
  }

  _current_iter = _finished_iter;
  return (_last_result.outcome != NesterovPlaceOutcome::kNotRun) ? GPAdvanceOutcome::kFinished : GPAdvanceOutcome::kBudgetReached;
}

void NesterovPlace::finishSession()
{
  if (_nes_database->_is_diverged) {
    LOG_ERROR << "Detect divergence, The reason may be parameters setting.";
    return;
  }

  if (_last_result.outcome == NesterovPlaceOutcome::kNotRun) {
    finalizeResult(NesterovPlaceOutcome::kMaxIter, _finished_iter, _prev_hpwl, _sum_overflow, _final_gradient_norm, _final_step_length,
                   _nes_database->_density_penalty, _final_route_util, "global placement reached max_iter");
  }

  publishPlacement();
}

void NesterovPlace::publishPlacement()
{
  notifyPLOverflowInfo(_sum_overflow);
  notifyPLPlaceDensity();

  // update PlacerDB.
  writeBackPlacerDB();
}

bool NesterovPlace::initializeSession()
{
  resetRunState();
  _placable_inst_list = this->obtianPlacableNesInstanceList();
  if (_placable_inst_list.empty()) {
    finalizeResult(NesterovPlaceOutcome::kInvalidMetric, 0, 0, 0.0F, 0.0F, 0.0F, 0.0F, 0.0F,
                   "global placement requires at least one movable instance");
    return false;
  }
  initNesterovPlace(_placable_inst_list);
  setupNesterovSolve();
  return _last_result.outcome == NesterovPlaceOutcome::kNotRun;
}

GPStateCheckpoint NesterovPlace::captureCheckpoint() const
{
  GPStateCheckpoint checkpoint;
  checkpoint.current_iter = _current_iter;
  checkpoint.sum_overflow = _sum_overflow;
  checkpoint.prev_hpwl = _prev_hpwl;
  checkpoint.cur_hpwl = _cur_hpwl;
  checkpoint.sum_overflow_threshold = _sum_overflow_threshold;
  checkpoint.hpwl_attach_sum_overflow = _hpwl_attach_sum_overflow;
  checkpoint.max_phi_coef_record = _max_phi_coef_record;
  checkpoint.cur_opt_overflow_step = _cur_opt_overflow_step;
  checkpoint.last_perturb_iter = _last_perturb_iter;
  checkpoint.is_add_quad_penalty = _is_add_quad_penalty;
  checkpoint.is_cal_phi = _is_cal_phi;
  checkpoint.stop_placement = _stop_placement;
  checkpoint.best_hpwl = _best_hpwl;
  checkpoint.best_overflow = _best_overflow;
  checkpoint.quad_penalty_coeff = _quad_penalty_coeff;
  checkpoint.total_inst_area = _total_inst_area;
  checkpoint.finished_iter = _finished_iter;
  checkpoint.final_step_length = _final_step_length;
  checkpoint.final_gradient_norm = _final_gradient_norm;
  checkpoint.final_route_util = _final_route_util;
  checkpoint.overflow_record_list = _overflow_record_list;
  checkpoint.hpwl_record_list = _hpwl_record_list;
  checkpoint.iteration_records = _iteration_records;
  checkpoint.wirelength_coef = _nes_database->_wirelength_coef;
  checkpoint.density_penalty = _nes_database->_density_penalty;
  checkpoint.is_diverged = _nes_database->_is_diverged;
  checkpoint.max_phi_coef = _nes_config.get_max_phi_coef();

  checkpoint.net_weights.reserve(_nes_database->_nNet_list.size());
  checkpoint.net_delta_weights.reserve(_nes_database->_nNet_list.size());
  for (auto* n_net : _nes_database->_nNet_list) {
    checkpoint.net_weights.push_back(n_net->get_weight());
    checkpoint.net_delta_weights.push_back(n_net->get_delta_weight());
  }
  checkpoint.config_fingerprint = computeConfigFingerprint();
  checkpoint.config_state = _nes_config.captureState();
  checkpoint.config_state_valid = true;

  checkpoint.best_position_list = _best_position_list;
  checkpoint.cur_position_list = _cur_position_list;
  checkpoint.best_density_scale_list = _best_density_scale_list;
  checkpoint.cur_density_scale_list = _cur_density_scale_list;

  checkpoint.instance_names.reserve(_placable_inst_list.size());
  checkpoint.instance_density_coords.reserve(_placable_inst_list.size());
  checkpoint.instance_density_scales.reserve(_placable_inst_list.size());
  for (auto* n_inst : _placable_inst_list) {
    checkpoint.instance_names.push_back(n_inst->get_name());
    checkpoint.instance_density_coords.push_back(n_inst->get_density_center_coordi());
    checkpoint.instance_density_scales.push_back(n_inst->get_density_scale());
  }

  checkpoint.solver = _nes_database->_nesterov_solver->captureState();
  return checkpoint;
}

std::string NesterovPlace::computeConfigFingerprint() const
{
  // Canonical serialization of every NesterovPlaceConfig value that can affect
  // the numerical path. Keys are sorted by nlohmann::json (std::map backing) so
  // the string is order-independent. bin_cnt_x/bin_cnt_y are the EFFECTIVE
  // (post-adaptive-recalc) values, which is what the solver actually uses.
  // max_phi_coef is EXCLUDED: it is runtime-mutated session state, persisted
  // separately in GPStateCheckpoint::max_phi_coef.
  const nlohmann::json fingerprint = nlohmann::json{
      {"thread_num", _nes_config.get_thread_num()},
      {"info_iter_num", _nes_config.get_info_iter_num()},
      {"init_wirelength_coef", _nes_config.get_init_wirelength_coef()},
      {"reference_hpwl", _nes_config.get_reference_hpwl()},
      {"min_wirelength_force_bar", _nes_config.get_min_wirelength_force_bar()},
      {"is_adaptive_bin", _nes_config.isAdaptiveBin()},
      {"target_density", _nes_config.get_target_density()},
      {"bin_cnt_x", _nes_config.get_bin_cnt_x()},
      {"bin_cnt_y", _nes_config.get_bin_cnt_y()},
      {"min_phi_coef", _nes_config.get_min_phi_coef()},
      {"max_iter", _nes_config.get_max_iter()},
      {"max_back_track", _nes_config.get_max_back_track()},
      {"target_overflow", _nes_config.get_target_overflow()},
      {"initial_prev_coordi_update_coef", _nes_config.get_initial_prev_coordi_update_coef()},
      {"min_precondition", _nes_config.get_min_precondition()},
      {"init_density_penalty", _nes_config.get_init_density_penalty()},
      {"is_opt_max_wirelength", _nes_config.isOptMaxWirelength()},
      {"is_opt_timing", _nes_config.isOptTiming()},
      {"is_opt_congestion", _nes_config.isOptCongestion()},
      {"max_net_wirelength", _nes_config.get_max_net_wirelength()},
      {"global_padding", _nes_config.get_global_padding()},
      {"opt_overflow_list", _nes_config.get_opt_overflow_list()},
      {"timing_hold_slack_guard", _nes_config.get_timing_hold_slack_guard()},
  };
  return fingerprint.dump();
}

bool NesterovPlace::restoreCheckpoint(const GPStateCheckpoint& checkpoint)
{
  // Config fingerprint first: resuming under a different placer config silently
  // produces a meaningless numerical path, so reject before touching state.
  if (checkpoint.config_fingerprint != computeConfigFingerprint()) {
    // Pre-hold-guard checkpoints predate timing_hold_slack_guard in the
    // fingerprint. Normalize that one key and resume with legacy guard=0.
    try {
      auto current = nlohmann::json::parse(computeConfigFingerprint());
      auto saved = nlohmann::json::parse(checkpoint.config_fingerprint);
      current.erase("timing_hold_slack_guard");
      saved.erase("timing_hold_slack_guard");
      if (current != saved) {
        LOG_ERROR << "[GP checkpoint] config fingerprint mismatch; resume requires the same placer config that saved the checkpoint";
        return false;
      }
      _nes_config.set_timing_hold_slack_guard(0.0F);
      LOG_WARNING << "[GP checkpoint] resumed a pre-hold-guard checkpoint with timing_hold_slack_guard=0";
    } catch (const std::exception& error) {
      LOG_ERROR << "[GP checkpoint] config fingerprint mismatch; resume requires the same placer config that saved the checkpoint";
      return false;
    }
  }

  // Topology fingerprint: the placable list must match the checkpoint exactly.
  _placable_inst_list = this->obtianPlacableNesInstanceList();
  if (_placable_inst_list.size() != checkpoint.instance_names.size()
      || _placable_inst_list.size() != checkpoint.instance_density_coords.size()) {
    LOG_ERROR << "[GP checkpoint] placable instance count mismatch: design has " << _placable_inst_list.size()
              << ", checkpoint has " << checkpoint.instance_names.size();
    return false;
  }
  for (size_t i = 0; i < _placable_inst_list.size(); ++i) {
    if (_placable_inst_list[i]->get_name() != checkpoint.instance_names[i]) {
      LOG_ERROR << "[GP checkpoint] placable instance mismatch at index " << i << ": design has '"
                << _placable_inst_list[i]->get_name() << "', checkpoint has '" << checkpoint.instance_names[i] << "'";
      return false;
    }
  }

  _current_iter = checkpoint.current_iter;
  _sum_overflow = checkpoint.sum_overflow;
  _prev_hpwl = checkpoint.prev_hpwl;
  _cur_hpwl = checkpoint.cur_hpwl;
  _sum_overflow_threshold = checkpoint.sum_overflow_threshold;
  _hpwl_attach_sum_overflow = checkpoint.hpwl_attach_sum_overflow;
  _max_phi_coef_record = checkpoint.max_phi_coef_record;
  _cur_opt_overflow_step = checkpoint.cur_opt_overflow_step;
  _last_perturb_iter = checkpoint.last_perturb_iter;
  _is_add_quad_penalty = checkpoint.is_add_quad_penalty;
  _is_cal_phi = checkpoint.is_cal_phi;
  _stop_placement = checkpoint.stop_placement;
  _best_hpwl = checkpoint.best_hpwl;
  _best_overflow = checkpoint.best_overflow;
  _quad_penalty_coeff = checkpoint.quad_penalty_coeff;
  _total_inst_area = checkpoint.total_inst_area;
  _finished_iter = checkpoint.finished_iter;
  _final_step_length = checkpoint.final_step_length;
  _final_gradient_norm = checkpoint.final_gradient_norm;
  _final_route_util = checkpoint.final_route_util;
  _overflow_record_list = checkpoint.overflow_record_list;
  _hpwl_record_list = checkpoint.hpwl_record_list;
  _iteration_records = checkpoint.iteration_records;
  _best_position_list = checkpoint.best_position_list;
  _cur_position_list = checkpoint.cur_position_list;
  _best_density_scale_list = checkpoint.best_density_scale_list;
  _cur_density_scale_list = checkpoint.cur_density_scale_list;

  _nes_database->_wirelength_coef = checkpoint.wirelength_coef;
  _nes_database->_density_penalty = checkpoint.density_penalty;
  _nes_database->_is_diverged = checkpoint.is_diverged;
  initBaseWirelengthCoef();  // deterministic rebuild (config + grid shape)
  _nes_config.set_max_phi_coef(checkpoint.max_phi_coef);

  // Per-net weights (max-wirelength / timing net-weight updates; empty
  // opt_overflow_list in the default config surface means these are usually 1.0,
  // but any mutated state must resume exactly).
  if (checkpoint.net_weights.size() != _nes_database->_nNet_list.size()) {
    LOG_ERROR << "[GP checkpoint] net weight count mismatch: design has " << _nes_database->_nNet_list.size()
              << " nets, checkpoint has " << checkpoint.net_weights.size();
    return false;
  }
  for (size_t i = 0; i < _nes_database->_nNet_list.size(); ++i) {
    _nes_database->_nNet_list[i]->set_weight(checkpoint.net_weights[i]);
    _nes_database->_nNet_list[i]->set_delta_weight(checkpoint.net_delta_weights[i]);
  }

  // Grid.fixed_area is written once by initGridFixedArea() during the normal
  // start path and is NOT cleared by clearAllOccupiedArea(); both the overflow
  // (obtainGridOverflowArea) and the density (obtainGridDensity) depend on it,
  // so a restored session must rebuild it or every downstream metric drifts.
  initGridFixedArea();

  // Scratch vectors and congestion prep normally created by setupNesterovSolve()
  // (skipped on the restore path): size them so the advance loop writes in-bounds.
  _next_slp_wirelength_grad_list.assign(_placable_inst_list.size(), Point<float>());
  _next_slp_density_grad_list.assign(_placable_inst_list.size(), Point<float>());
  _next_slp_sum_grad_list.assign(_placable_inst_list.size(), Point<float>());
  if (_nes_config.isOptCongestion()) {
    _nes_database->_bin_grid->evalRouteCap(_nes_config.get_thread_num());
  }

  _nes_database->_nesterov_solver->restoreState(checkpoint.solver);

  for (size_t i = 0; i < _placable_inst_list.size(); ++i) {
    Point<int32_t> density_coord = checkpoint.instance_density_coords[i];
    _placable_inst_list[i]->updateDensityCenterLocation(density_coord);
    _placable_inst_list[i]->set_density_scale(checkpoint.instance_density_scales[i]);
  }

  _solve_setup_done = true;
  return true;
}

namespace {
struct HotBin
{
  int32_t idx;
  int64_t overflow;
};

std::vector<HotBin> collectHotOverflowBins(GridManager* grid_manager)
{
  auto& grid_2d = grid_manager->get_grid_2d_list();
  const int32_t cnt_x = grid_manager->get_grid_cnt_x();
  const int32_t cnt_y = grid_manager->get_grid_cnt_y();
  std::vector<HotBin> hot;
  for (int32_t y = 0; y < cnt_y; y++) {
    for (int32_t x = 0; x < cnt_x; x++) {
      const int64_t overflow = grid_2d[y][x].obtainGridOverflowArea();
      if (overflow > 0) {
        hot.push_back({y * cnt_x + x, overflow});
      }
    }
  }
  return hot;
}

void keepHottestBins(std::vector<HotBin>& hot, size_t take)
{
  if (hot.empty()) {
    return;
  }
  take = std::min(take, hot.size());
  if (take == 0) {
    hot.clear();
    return;
  }
  // top-k selection without sorting every overflowing bin (large designs can
  // have millions of occupied bins; only the first `take` are ever used).
  std::nth_element(hot.begin(), hot.begin() + take, hot.end(),
                   [](const HotBin& lhs, const HotBin& rhs) { return lhs.overflow > rhs.overflow; });
  hot.resize(take);
  std::sort(hot.begin(), hot.end(), [](const HotBin& lhs, const HotBin& rhs) { return lhs.overflow > rhs.overflow; });
}
}  // namespace

void NesterovPlace::setMovementCoeffs(const std::vector<float>& move_coeff_list)
{
  _move_coeff_list = move_coeff_list;
  syncLocalFixedFlags();
}

void NesterovPlace::syncLocalFixedFlags()
{
  // Fixed-set local GP: Context instances (coefficient 0) are not merely
  // gradient-masked; they become fixed density obstacles for this batch. Halo
  // and Active remain movable charge. The BinGrid routes their area into
  // Grid::local_fixed_area, which is cleared together with occupied_area and
  // therefore never leaks across batches or checkpoints.
  for (size_t i = 0; i < _placable_inst_list.size(); i++) {
    const bool local_fixed = i < _move_coeff_list.size() && _move_coeff_list[i] <= 0.0F;
    _placable_inst_list[i]->set_local_fixed(local_fixed);
  }
}

void NesterovPlace::buildHotOverflowScope(float active_ratio, float halo_coeff, int32_t halo_hops)
{
  auto* grid_manager = _nes_database->_grid_manager;
  // Refresh the bin grid from the current instance coordinates: after a
  // checkpoint restore (or an external coordinate change) the grid occupancy is
  // stale, and the scope must reflect where the hotspots actually are.
  _nes_database->_bin_grid->updateBinGrid(_placable_inst_list, _nes_config.get_thread_num());
  const int32_t cnt_x = grid_manager->get_grid_cnt_x();
  const int32_t cnt_y = grid_manager->get_grid_cnt_y();

  auto hot = collectHotOverflowBins(grid_manager);
  const size_t n = _placable_inst_list.size();
  std::vector<float> coeffs(n, 0.0F);
  if (hot.empty() || n == 0) {
    setMovementCoeffs(coeffs);
    return;
  }

  // Active: instances whose density center falls in the hottest overflowing bins.
  const size_t take = std::max<size_t>(1, std::min<size_t>(hot.size(), static_cast<size_t>(hot.size() * active_ratio)));
  keepHottestBins(hot, take);
  std::set<int32_t> hot_bins;
  for (const auto& bin : hot) {
    hot_bins.insert(bin.idx);
  }

  const auto region = grid_manager->get_shape();
  const int32_t bin_w = grid_manager->get_grid_size_x();
  const int32_t bin_h = grid_manager->get_grid_size_y();

  std::vector<bool> active(n, false);
  for (size_t i = 0; i < n; i++) {
    const auto center = _placable_inst_list[i]->get_density_center_coordi();
    int32_t gx = (center.get_x() - region.get_ll_x()) / bin_w;
    int32_t gy = (center.get_y() - region.get_ll_y()) / bin_h;
    gx = std::clamp(gx, 0, cnt_x - 1);
    gy = std::clamp(gy, 0, cnt_y - 1);
    if (hot_bins.count(gy * cnt_x + gx) != 0) {
      active[i] = true;
      coeffs[i] = 1.0F;
    }
  }

  // Halo: net-hop closure around the active set.
  applyNetHaloClosure(active, coeffs, halo_coeff, halo_hops);

  setMovementCoeffs(coeffs);
}

void NesterovPlace::applyNetHaloClosure(const std::vector<bool>& active, std::vector<float>& coeffs, float halo_coeff, int32_t halo_hops)
{
  const size_t n = _placable_inst_list.size();
  if (n == 0 || halo_hops <= 0) {
    return;
  }

  // Sorted (net_id, instance_index) pairs replace the previous
  // std::map<int32_t, std::vector<int32_t>>. For a 10M-instance design the map
  // version costs GBs of overhead and minutes of allocation; a flat sorted
  // array is one allocation of 2*|pin| integers and two binary-search ranges
  // per frontier pin.
  std::vector<std::pair<int32_t, int32_t>> net_to_insts;
  net_to_insts.reserve(_nes_database->_nPin_list.size());
  for (size_t i = 0; i < n; i++) {
    for (auto* n_pin : _placable_inst_list[i]->get_nPin_list()) {
      net_to_insts.emplace_back(n_pin->get_nNet()->get_net_id(), static_cast<int32_t>(i));
    }
  }
  std::sort(net_to_insts.begin(), net_to_insts.end());

  // Multi-hop halo with geometric decay: hop 1 moves at halo_coeff, hop 2 at
  // halo_coeff^2, etc. The frontier advances one net hop per level, so large
  // scopes relax into the surrounding context instead of ending at a hard
  // one-hop boundary.
  std::vector<int32_t> frontier;
  frontier.reserve(n);
  for (size_t i = 0; i < n; i++) {
    if (active[i]) {
      frontier.push_back(static_cast<int32_t>(i));
    }
  }

  float level_coeff = halo_coeff;
  for (int32_t hop = 1; hop <= halo_hops; hop++) {
    if (frontier.empty()) {
      break;
    }
    std::vector<int32_t> next_frontier;
    next_frontier.reserve(frontier.size());
    for (const int32_t i : frontier) {
      for (auto* n_pin : _placable_inst_list[i]->get_nPin_list()) {
        const int32_t net_id = n_pin->get_nNet()->get_net_id();
        const auto range = std::equal_range(net_to_insts.begin(), net_to_insts.end(), std::make_pair(net_id, 0),
                                            [](const auto& lhs, const auto& rhs) { return lhs.first < rhs.first; });
        for (auto it = range.first; it != range.second; ++it) {
          const int32_t j = it->second;
          if (!active[j] && coeffs[j] == 0.0F) {
            coeffs[j] = level_coeff;
            next_frontier.push_back(j);
          }
        }
      }
    }
    frontier.swap(next_frontier);
    level_coeff *= halo_coeff;
    if (level_coeff <= 0.0F) {
      break;
    }
  }
}

bool NesterovPlace::buildInstanceScope(const std::vector<std::string>& seed_instance_names, float halo_coeff, int32_t halo_hops)
{
  const size_t n = _placable_inst_list.size();
  std::vector<float> coeffs(n, 0.0F);
  std::vector<bool> active(n, false);
  if (n == 0 || seed_instance_names.empty()) {
    setMovementCoeffs(coeffs);
    return n != 0;
  }

  std::unordered_map<std::string, size_t> index_by_name;
  index_by_name.reserve(n);
  for (size_t i = 0; i < n; i++) {
    index_by_name.emplace(_placable_inst_list[i]->get_name(), i);
  }

  for (const auto& name : seed_instance_names) {
    const auto it = index_by_name.find(name);
    if (it == index_by_name.end()) {
      LOG_ERROR << "[GP local scope] unknown movable instance: " << name;
      return false;
    }
    active[it->second] = true;
    coeffs[it->second] = 1.0F;
  }

  applyNetHaloClosure(active, coeffs, halo_coeff, halo_hops);
  setMovementCoeffs(coeffs);
  return true;
}

void NesterovPlace::buildRegionScope(const Rectangle<int32_t>& region, float halo_coeff, int32_t halo_hops)
{
  const size_t n = _placable_inst_list.size();
  std::vector<float> coeffs(n, 0.0F);
  std::vector<bool> active(n, false);
  if (n == 0 || region.get_ll_x() >= region.get_ur_x() || region.get_ll_y() >= region.get_ur_y()) {
    setMovementCoeffs(coeffs);
    return;
  }

  for (size_t i = 0; i < n; i++) {
    const auto shape = _placable_inst_list[i]->get_density_shape();
    const bool overlaps = shape.get_ll_x() < region.get_ur_x() && shape.get_ur_x() > region.get_ll_x()
                         && shape.get_ll_y() < region.get_ur_y() && shape.get_ur_y() > region.get_ll_y();
    if (overlaps) {
      active[i] = true;
      coeffs[i] = 1.0F;
    }
  }

  applyNetHaloClosure(active, coeffs, halo_coeff, halo_hops);
  setMovementCoeffs(coeffs);
}

void NesterovPlace::buildLongNetScope(size_t active_count, float halo_coeff, int32_t halo_hops)
{
  const size_t n = _placable_inst_list.size();
  std::vector<float> coeffs(n, 0.0F);
  std::vector<bool> active(n, false);
  if (n == 0 || active_count == 0) {
    setMovementCoeffs(coeffs);
    return;
  }

  std::vector<std::pair<int64_t, int32_t>> pin_scores;
  pin_scores.reserve(_nes_database->_nPin_list.size());
  for (size_t i = 0; i < n; i++) {
    for (auto* n_pin : _placable_inst_list[i]->get_nPin_list()) {
      const int64_t wirelength = _nes_database->_wirelength->obtainNetWirelength(n_pin->get_nNet()->get_net_id());
      pin_scores.emplace_back(wirelength, static_cast<int32_t>(i));
    }
  }
  // top-k by wirelength; duplicate instance indices are deduplicated while
  // scanning, so the selected set has exactly min(active_count, n) cells.
  std::sort(pin_scores.begin(), pin_scores.end(),
            [](const auto& lhs, const auto& rhs) { return lhs.first > rhs.first; });

  size_t selected = 0;
  for (const auto& [wirelength, index] : pin_scores) {
    (void) wirelength;
    if (selected >= active_count) {
      break;
    }
    if (!active[index]) {
      active[index] = true;
      coeffs[index] = 1.0F;
      selected++;
    }
  }

  applyNetHaloClosure(active, coeffs, halo_coeff, halo_hops);
  setMovementCoeffs(coeffs);
}

void NesterovPlace::evaluateRouteUtilObservation()
{
  auto* bin_grid = _nes_database->_bin_grid;
  if (bin_grid == nullptr || _nes_database->_topology_manager == nullptr) {
    return;
  }
  bin_grid->evalRouteCap(_nes_config.get_thread_num());
  bin_grid->evalRouteDem(_nes_database->_topology_manager->get_network_list(), _nes_config.get_thread_num());
  bin_grid->fastGaussianBlur();
  bin_grid->evalRouteUtil();
  _final_route_util = std::max(_nes_database->_grid_manager->get_h_util_max(),
                               _nes_database->_grid_manager->get_v_util_max());
}

void NesterovPlace::refreshGridOccupation()
{
  _nes_database->_bin_grid->updateBinGrid(_placable_inst_list, _nes_config.get_thread_num());
}

GPRunScopeEffect NesterovPlace::computeScopeEffect() const
{
  GPRunScopeEffect effect;
  if (_move_coeff_list.empty()) {
    // Global batch: no movement mask, no write-boundary distinction.
    return effect;
  }

  effect.scope_applied = true;
  if (_move_coeff_list.size() != _placable_inst_list.size() || _frozen_coord_list.size() != _placable_inst_list.size()) {
    effect.in_scope = false;
    return effect;
  }

  for (size_t i = 0; i < _placable_inst_list.size(); i++) {
    const float coeff = _move_coeff_list[i];
    if (coeff <= 0.0F) {
      effect.context_written++;
    } else if (coeff >= 1.0F) {
      effect.active_written++;
    } else {
      effect.halo_written++;
    }

    if (std::isnan(coeff) || coeff < 0.0F || coeff > 1.0F) {
      effect.in_scope = false;
    }

    const auto current = _placable_inst_list[i]->get_density_center_coordi();
    const auto start = _frozen_coord_list[i];
    const int64_t dx = static_cast<int64_t>(current.get_x()) - static_cast<int64_t>(start.get_x());
    const int64_t dy = static_cast<int64_t>(current.get_y()) - static_cast<int64_t>(start.get_y());
    const float displacement = static_cast<float>(std::llabs(dx) + std::llabs(dy));
    effect.max_displacement = std::max(effect.max_displacement, displacement);
    if (coeff <= 0.0F && displacement != 0.0F) {
      effect.context_moved++;
    }
  }
  return effect;
}

GPOverflowReport NesterovPlace::buildOverflowReport(int32_t top_n) const
{
  GPOverflowReport report;
  auto* grid_manager = _nes_database->_grid_manager;
  if (grid_manager == nullptr) {
    return report;
  }

  const auto core = grid_manager->get_shape();
  report.bin_cnt_x = grid_manager->get_grid_cnt_x();
  report.bin_cnt_y = grid_manager->get_grid_cnt_y();
  report.bin_size_x = grid_manager->get_grid_size_x();
  report.bin_size_y = grid_manager->get_grid_size_y();
  report.core_ll_x = core.get_ll_x();
  report.core_ll_y = core.get_ll_y();
  report.core_ur_x = core.get_ur_x();
  report.core_ur_y = core.get_ur_y();

  auto hot = collectHotOverflowBins(grid_manager);
  report.overflowing_bin_count = static_cast<int32_t>(hot.size());
  report.total_overflow_area = 0;
  report.peak_density = 0.0F;

  auto& grid_2d = grid_manager->get_grid_2d_list();
  for (int32_t y = 0; y < report.bin_cnt_y; y++) {
    for (int32_t x = 0; x < report.bin_cnt_x; x++) {
      const auto& grid = grid_2d[y][x];
      report.peak_density = std::max(report.peak_density, grid.obtainGridDensity());
    }
  }
  for (const auto& bin : hot) {
    report.total_overflow_area += bin.overflow;
  }
  report.total_overflow_ratio = _total_inst_area > 0 ? static_cast<float>(report.total_overflow_area) / _total_inst_area : 0.0F;

  if (top_n > 0) {
    keepHottestBins(hot, static_cast<size_t>(top_n));
    report.bins.reserve(hot.size());
    for (const auto& bin : hot) {
      const auto& grid = grid_2d[bin.idx / report.bin_cnt_x][bin.idx % report.bin_cnt_x];
      GPBinReport bin_report;
      bin_report.row = bin.idx / report.bin_cnt_x;
      bin_report.col = bin.idx % report.bin_cnt_x;
      bin_report.ll_x = grid.shape.get_ll_x();
      bin_report.ll_y = grid.shape.get_ll_y();
      bin_report.ur_x = grid.shape.get_ur_x();
      bin_report.ur_y = grid.shape.get_ur_y();
      bin_report.grid_area = grid.grid_area;
      bin_report.occupied_area = grid.occupied_area;
      bin_report.fixed_area = grid.fixed_area;
      bin_report.local_fixed_area = grid.local_fixed_area;
      bin_report.available_area = std::max<int64_t>(0, grid.obtainAvailableArea());
      bin_report.overflow_area = bin.overflow;
      bin_report.density = grid.obtainGridDensity();
      bin_report.density_target = grid.density_target;
      report.bins.push_back(bin_report);
    }
  }
  return report;
}

void NesterovPlace::setRegionDensityTargets(const std::vector<Rectangle<int32_t>>& regions, float target)
{
  auto* grid_manager = _nes_database->_grid_manager;
  for (const auto& region : regions) {
    Rectangle<int32_t> rect = region;
    std::vector<Grid*> overlap_grid_list;
    grid_manager->obtainOverlapGridList(overlap_grid_list, rect);
    for (auto* grid : overlap_grid_list) {
      grid->density_target = target;
    }
  }
}

void NesterovPlace::clearRegionDensityTargets()
{
  auto& grid_2d = _nes_database->_grid_manager->get_grid_2d_list();
  for (auto& grid_row : grid_2d) {
    for (auto& grid : grid_row) {
      grid.density_target = 1.0F;
    }
  }
}

void NesterovPlace::buildHotOverflowDensityTargets(float top_ratio, float target)
{
  auto* grid_manager = _nes_database->_grid_manager;
  _nes_database->_bin_grid->updateBinGrid(_placable_inst_list, _nes_config.get_thread_num());
  auto& grid_2d = grid_manager->get_grid_2d_list();
  const int32_t cnt_x = grid_manager->get_grid_cnt_x();

  auto hot = collectHotOverflowBins(grid_manager);
  const size_t take = std::max<size_t>(1, std::min<size_t>(hot.size(), static_cast<size_t>(hot.size() * top_ratio)));
  keepHottestBins(hot, take);
  for (const auto& bin : hot) {
    grid_2d[bin.idx / cnt_x][bin.idx % cnt_x].density_target = target;
  }
}

void NesterovPlace::buildRandomScope(size_t active_count, float halo_coeff, uint32_t seed, int32_t halo_hops)
{
  const size_t n = _placable_inst_list.size();
  std::vector<float> coeffs(n, 0.0F);
  if (n == 0) {
    setMovementCoeffs(coeffs);
    return;
  }

  std::vector<size_t> indices(n);
  std::iota(indices.begin(), indices.end(), 0);
  std::mt19937 rng(seed);
  std::shuffle(indices.begin(), indices.end(), rng);

  std::vector<bool> active(n, false);
  const size_t take = std::min(active_count, n);
  for (size_t k = 0; k < take; k++) {
    active[indices[k]] = true;
    coeffs[indices[k]] = 1.0F;
  }
  applyNetHaloClosure(active, coeffs, halo_coeff, halo_hops);
  setMovementCoeffs(coeffs);
}

void to_json(nlohmann::json& json_obj, const Point<int32_t>& point)
{
  json_obj = nlohmann::json::array({point.get_x(), point.get_y()});
}

void from_json(const nlohmann::json& json_obj, Point<int32_t>& point)
{
  point.set_x(json_obj.at(0).get<int32_t>());
  point.set_y(json_obj.at(1).get<int32_t>());
}

void to_json(nlohmann::json& json_obj, const Point<float>& point)
{
  json_obj = nlohmann::json::array({point.get_x(), point.get_y()});
}

void from_json(const nlohmann::json& json_obj, Point<float>& point)
{
  point.set_x(json_obj.at(0).get<float>());
  point.set_y(json_obj.at(1).get<float>());
}

void to_json(nlohmann::json& json_obj, const NesterovIterationRecord& record)
{
  json_obj = nlohmann::json{{"iter", record.iter},
                            {"hpwl", record.hpwl},
                            {"overflow", record.overflow},
                            {"step_length", record.step_length},
                            {"gradient_norm", record.gradient_norm},
                            {"density_penalty", record.density_penalty},
                            {"route_util", record.route_util},
                            {"quad_penalty_enabled", record.quad_penalty_enabled},
                            {"entropy_injected", record.entropy_injected}};
}

void from_json(const nlohmann::json& json_obj, NesterovIterationRecord& record)
{
  record.iter = json_obj.at("iter").get<int32_t>();
  record.hpwl = json_obj.at("hpwl").get<int64_t>();
  record.overflow = json_obj.at("overflow").get<float>();
  record.step_length = json_obj.at("step_length").get<float>();
  record.gradient_norm = json_obj.at("gradient_norm").get<float>();
  record.density_penalty = json_obj.at("density_penalty").get<float>();
  record.route_util = json_obj.at("route_util").get<float>();
  record.quad_penalty_enabled = json_obj.at("quad_penalty_enabled").get<bool>();
  record.entropy_injected = json_obj.at("entropy_injected").get<bool>();
}

void to_json(nlohmann::json& json_obj, const NesterovPlaceConfig::State& state)
{
  json_obj = nlohmann::json{{"thread_num", state.thread_num},
                            {"info_iter_num", state.info_iter_num},
                            {"init_wirelength_coef", state.init_wirelength_coef},
                            {"reference_hpwl", state.reference_hpwl},
                            {"min_wirelength_force_bar", state.min_wirelength_force_bar},
                            {"target_density", state.target_density},
                            {"is_adaptive_bin", state.is_adaptive_bin},
                            {"bin_cnt_x", state.bin_cnt_x},
                            {"bin_cnt_y", state.bin_cnt_y},
                            {"min_phi_coef", state.min_phi_coef},
                            {"max_phi_coef", state.max_phi_coef},
                            {"max_iter", state.max_iter},
                            {"max_back_track", state.max_back_track},
                            {"init_density_penalty", state.init_density_penalty},
                            {"target_overflow", state.target_overflow},
                            {"initial_prev_coordi_update_coef", state.initial_prev_coordi_update_coef},
                            {"min_precondition", state.min_precondition},
                            {"is_opt_max_wirelength", state.is_opt_max_wirelength},
                            {"is_opt_timing", state.is_opt_timing},
                            {"is_opt_congestion", state.is_opt_congestion},
                            {"max_net_wirelength", state.max_net_wirelength},
                            {"global_padding", state.global_padding},
                            {"opt_overflow_list", state.opt_overflow_list},
                            {"opt_overflow_list_configured", state.opt_overflow_list_configured},
                            {"timing_hold_slack_guard", state.timing_hold_slack_guard}};
}

void from_json(const nlohmann::json& json_obj, NesterovPlaceConfig::State& state)
{
  state.thread_num = json_obj.at("thread_num").get<int32_t>();
  state.info_iter_num = json_obj.at("info_iter_num").get<int32_t>();
  state.init_wirelength_coef = json_obj.at("init_wirelength_coef").get<float>();
  state.reference_hpwl = json_obj.at("reference_hpwl").get<float>();
  state.min_wirelength_force_bar = json_obj.at("min_wirelength_force_bar").get<float>();
  state.target_density = json_obj.at("target_density").get<float>();
  state.is_adaptive_bin = json_obj.at("is_adaptive_bin").get<bool>();
  state.bin_cnt_x = json_obj.at("bin_cnt_x").get<int32_t>();
  state.bin_cnt_y = json_obj.at("bin_cnt_y").get<int32_t>();
  state.min_phi_coef = json_obj.at("min_phi_coef").get<float>();
  state.max_phi_coef = json_obj.at("max_phi_coef").get<float>();
  state.max_iter = json_obj.at("max_iter").get<int32_t>();
  state.max_back_track = json_obj.at("max_back_track").get<int32_t>();
  state.init_density_penalty = json_obj.at("init_density_penalty").get<float>();
  state.target_overflow = json_obj.at("target_overflow").get<float>();
  state.initial_prev_coordi_update_coef = json_obj.at("initial_prev_coordi_update_coef").get<float>();
  state.min_precondition = json_obj.at("min_precondition").get<float>();
  state.is_opt_max_wirelength = json_obj.at("is_opt_max_wirelength").get<bool>();
  state.is_opt_timing = json_obj.at("is_opt_timing").get<bool>();
  state.is_opt_congestion = json_obj.at("is_opt_congestion").get<bool>();
  state.max_net_wirelength = json_obj.at("max_net_wirelength").get<int32_t>();
  state.global_padding = json_obj.at("global_padding").get<int32_t>();
  state.opt_overflow_list = json_obj.at("opt_overflow_list").get<std::vector<float>>();
  state.opt_overflow_list_configured = json_obj.at("opt_overflow_list_configured").get<bool>();
  // Checkpoints written before the hold-guard feature predate this key. They
  // resume with the legacy no-guard behavior (0.0), selected by the fingerprint
  // compatibility path in restoreCheckpoint().
  state.timing_hold_slack_guard = json_obj.value("timing_hold_slack_guard", 0.0F);
}

void to_json(nlohmann::json& json_obj, const Nesterov::State& state)
{
  json_obj = nlohmann::json{{"current_iter", state.current_iter},
                            {"current_parameter", state.current_parameter},
                            {"next_parameter", state.next_parameter},
                            {"current_steplength", state.current_steplength},
                            {"next_steplength", state.next_steplength},
                            {"current_coordis", state.current_coordis},
                            {"next_coordis", state.next_coordis},
                            {"current_slp_coordis", state.current_slp_coordis},
                            {"next_slp_coordis", state.next_slp_coordis},
                            {"current_gradients", state.current_gradients},
                            {"next_gradients", state.next_gradients}};
}

void from_json(const nlohmann::json& json_obj, Nesterov::State& state)
{
  state.current_iter = json_obj.at("current_iter").get<int32_t>();
  state.current_parameter = json_obj.at("current_parameter").get<float>();
  state.next_parameter = json_obj.at("next_parameter").get<float>();
  state.current_steplength = json_obj.at("current_steplength").get<float>();
  state.next_steplength = json_obj.at("next_steplength").get<float>();
  state.current_coordis = json_obj.at("current_coordis").get<std::vector<Point<int32_t>>>();
  state.next_coordis = json_obj.at("next_coordis").get<std::vector<Point<int32_t>>>();
  state.current_slp_coordis = json_obj.at("current_slp_coordis").get<std::vector<Point<int32_t>>>();
  state.next_slp_coordis = json_obj.at("next_slp_coordis").get<std::vector<Point<int32_t>>>();
  state.current_gradients = json_obj.at("current_gradients").get<std::vector<Point<float>>>();
  state.next_gradients = json_obj.at("next_gradients").get<std::vector<Point<float>>>();
}

void to_json(nlohmann::json& json_obj, const GPStateCheckpoint& checkpoint)
{
  json_obj = nlohmann::json{
      {"current_iter", checkpoint.current_iter},
      {"sum_overflow", checkpoint.sum_overflow},
      {"prev_hpwl", checkpoint.prev_hpwl},
      {"cur_hpwl", checkpoint.cur_hpwl},
      {"sum_overflow_threshold", checkpoint.sum_overflow_threshold},
      {"hpwl_attach_sum_overflow", checkpoint.hpwl_attach_sum_overflow},
      {"max_phi_coef_record", checkpoint.max_phi_coef_record},
      {"cur_opt_overflow_step", checkpoint.cur_opt_overflow_step},
      {"last_perturb_iter", checkpoint.last_perturb_iter},
      {"is_add_quad_penalty", checkpoint.is_add_quad_penalty},
      {"is_cal_phi", checkpoint.is_cal_phi},
      {"stop_placement", checkpoint.stop_placement},
      {"best_hpwl", checkpoint.best_hpwl},
      {"best_overflow", checkpoint.best_overflow},
      {"quad_penalty_coeff", checkpoint.quad_penalty_coeff},
      {"total_inst_area", checkpoint.total_inst_area},
      {"finished_iter", checkpoint.finished_iter},
      {"final_step_length", checkpoint.final_step_length},
      {"final_gradient_norm", checkpoint.final_gradient_norm},
      {"final_route_util", checkpoint.final_route_util},
      {"overflow_record_list", checkpoint.overflow_record_list},
      {"hpwl_record_list", checkpoint.hpwl_record_list},
      {"iteration_records", checkpoint.iteration_records},
      {"wirelength_coef", checkpoint.wirelength_coef},
      {"density_penalty", checkpoint.density_penalty},
      {"is_diverged", checkpoint.is_diverged},
      {"net_weights", checkpoint.net_weights},
      {"net_delta_weights", checkpoint.net_delta_weights},
      {"config_fingerprint", checkpoint.config_fingerprint},
      {"config_state", checkpoint.config_state},
      {"config_state_valid", checkpoint.config_state_valid},
      {"max_phi_coef", checkpoint.max_phi_coef},
      {"instance_names", checkpoint.instance_names},
      {"instance_density_coords", checkpoint.instance_density_coords},
      {"instance_density_scales", checkpoint.instance_density_scales},
      {"best_position_list", checkpoint.best_position_list},
      {"cur_position_list", checkpoint.cur_position_list},
      {"best_density_scale_list", checkpoint.best_density_scale_list},
      {"cur_density_scale_list", checkpoint.cur_density_scale_list},
      {"solver", checkpoint.solver},
  };
}

void from_json(const nlohmann::json& json_obj, GPStateCheckpoint& checkpoint)
{
  checkpoint.current_iter = json_obj.at("current_iter").get<int32_t>();
  checkpoint.sum_overflow = json_obj.at("sum_overflow").get<float>();
  checkpoint.prev_hpwl = json_obj.at("prev_hpwl").get<int64_t>();
  checkpoint.cur_hpwl = json_obj.at("cur_hpwl").get<int64_t>();
  checkpoint.sum_overflow_threshold = json_obj.at("sum_overflow_threshold").get<float>();
  checkpoint.hpwl_attach_sum_overflow = json_obj.at("hpwl_attach_sum_overflow").get<float>();
  checkpoint.max_phi_coef_record = json_obj.at("max_phi_coef_record").get<bool>();
  checkpoint.cur_opt_overflow_step = json_obj.at("cur_opt_overflow_step").get<int32_t>();
  checkpoint.last_perturb_iter = json_obj.at("last_perturb_iter").get<int32_t>();
  checkpoint.is_add_quad_penalty = json_obj.at("is_add_quad_penalty").get<bool>();
  checkpoint.is_cal_phi = json_obj.at("is_cal_phi").get<bool>();
  checkpoint.stop_placement = json_obj.at("stop_placement").get<bool>();
  checkpoint.best_hpwl = json_obj.at("best_hpwl").get<int64_t>();
  checkpoint.best_overflow = json_obj.at("best_overflow").get<float>();
  checkpoint.quad_penalty_coeff = json_obj.at("quad_penalty_coeff").get<float>();
  checkpoint.total_inst_area = json_obj.at("total_inst_area").get<int64_t>();
  checkpoint.finished_iter = json_obj.at("finished_iter").get<int32_t>();
  checkpoint.final_step_length = json_obj.at("final_step_length").get<float>();
  checkpoint.final_gradient_norm = json_obj.at("final_gradient_norm").get<float>();
  checkpoint.final_route_util = json_obj.at("final_route_util").get<float>();
  checkpoint.overflow_record_list = json_obj.at("overflow_record_list").get<std::vector<float>>();
  checkpoint.hpwl_record_list = json_obj.at("hpwl_record_list").get<std::vector<float>>();
  checkpoint.iteration_records = json_obj.at("iteration_records").get<std::vector<NesterovIterationRecord>>();
  checkpoint.wirelength_coef = json_obj.at("wirelength_coef").get<float>();
  checkpoint.density_penalty = json_obj.at("density_penalty").get<float>();
  checkpoint.is_diverged = json_obj.at("is_diverged").get<bool>();
  checkpoint.net_weights = json_obj.at("net_weights").get<std::vector<float>>();
  checkpoint.net_delta_weights = json_obj.at("net_delta_weights").get<std::vector<float>>();
  checkpoint.config_fingerprint = json_obj.at("config_fingerprint").get<std::string>();
  checkpoint.config_state = json_obj.value("config_state", NesterovPlaceConfig::State{});
  checkpoint.config_state_valid = json_obj.value("config_state_valid", false);
  checkpoint.max_phi_coef = json_obj.at("max_phi_coef").get<float>();
  checkpoint.instance_names = json_obj.at("instance_names").get<std::vector<std::string>>();
  checkpoint.instance_density_coords = json_obj.at("instance_density_coords").get<std::vector<Point<int32_t>>>();
  checkpoint.instance_density_scales = json_obj.at("instance_density_scales").get<std::vector<float>>();
  checkpoint.best_position_list = json_obj.at("best_position_list").get<std::vector<Point<int32_t>>>();
  checkpoint.cur_position_list = json_obj.at("cur_position_list").get<std::vector<Point<int32_t>>>();
  checkpoint.best_density_scale_list = json_obj.at("best_density_scale_list").get<std::vector<float>>();
  checkpoint.cur_density_scale_list = json_obj.at("cur_density_scale_list").get<std::vector<float>>();
  checkpoint.solver = json_obj.at("solver").get<Nesterov::State>();
}

bool saveGPCheckpointFile(const std::string& path, const GPStateCheckpoint& checkpoint)
{
  try {
    const std::filesystem::path target(path);
    if (target.has_parent_path()) {
      std::filesystem::create_directories(target.parent_path());
    }
    const std::filesystem::path tmp = target.string() + ".tmp";
    std::ofstream stream(tmp);
    if (!stream.good()) {
      return false;
    }
    stream << nlohmann::json(checkpoint).dump(2);
    stream.close();
    std::filesystem::rename(tmp, target);  // atomic replace: a killed writer never corrupts the previous checkpoint
    return true;
  } catch (const std::exception& e) {
    LOG_ERROR << "[GP checkpoint] save failed: " << e.what();
    return false;
  }
}

bool loadGPCheckpointFile(const std::string& path, GPStateCheckpoint& checkpoint)
{
  try {
    std::ifstream stream(path);
    if (!stream.good()) {
      LOG_ERROR << "[GP checkpoint] cannot open file: " << path;
      return false;
    }
    nlohmann::json json_obj = nlohmann::json::parse(stream);
    checkpoint = json_obj.get<GPStateCheckpoint>();
    return true;
  } catch (const std::exception& e) {
    LOG_ERROR << "[GP checkpoint] load failed: " << e.what();
    return false;
  }
}

void to_json(nlohmann::json& json_obj, const GPBinReport& report)
{
  json_obj = nlohmann::json{{"row", report.row},
                            {"col", report.col},
                            {"ll_x", report.ll_x},
                            {"ll_y", report.ll_y},
                            {"ur_x", report.ur_x},
                            {"ur_y", report.ur_y},
                            {"grid_area", report.grid_area},
                            {"occupied_area", report.occupied_area},
                            {"fixed_area", report.fixed_area},
                            {"local_fixed_area", report.local_fixed_area},
                            {"available_area", report.available_area},
                            {"overflow_area", report.overflow_area},
                            {"density", report.density},
                            {"density_target", report.density_target}};
}

void to_json(nlohmann::json& json_obj, const GPOverflowReport& report)
{
  json_obj = nlohmann::json{{"bin_cnt_x", report.bin_cnt_x},
                            {"bin_cnt_y", report.bin_cnt_y},
                            {"bin_size_x", report.bin_size_x},
                            {"bin_size_y", report.bin_size_y},
                            {"core_ll_x", report.core_ll_x},
                            {"core_ll_y", report.core_ll_y},
                            {"core_ur_x", report.core_ur_x},
                            {"core_ur_y", report.core_ur_y},
                            {"overflowing_bin_count", report.overflowing_bin_count},
                            {"total_overflow_area", report.total_overflow_area},
                            {"total_overflow_ratio", report.total_overflow_ratio},
                            {"peak_density", report.peak_density},
                            {"bins", report.bins}};
}

bool saveGPOverflowReportFile(const std::string& path, const GPOverflowReport& report)
{
  try {
    const std::filesystem::path target(path);
    if (target.has_parent_path()) {
      std::filesystem::create_directories(target.parent_path());
    }
    const std::filesystem::path tmp = target.string() + ".tmp";
    std::ofstream stream(tmp);
    if (!stream.good()) {
      return false;
    }
    stream << nlohmann::json(report).dump(2);
    stream.close();
    std::filesystem::rename(tmp, target);
    return true;
  } catch (const std::exception& e) {
    LOG_ERROR << "[GP grid report] save failed: " << e.what();
    return false;
  }
}

void NesterovPlace::notifyPLOverflowInfo(float final_overflow)
{
  PlacerDBInst.gp_overflow = final_overflow;

  std::vector<Grid*> grid_list;
  _nes_database->_grid_manager->obtainOverflowIllegalGridList(grid_list);
  PlacerDBInst.gp_overflow_number = grid_list.size();
}

void NesterovPlace::notifyPLPlaceDensity()
{
  auto* grid_manager = _nes_database->_grid_manager;
  PlacerDBInst.place_density[0] = grid_manager->obtainAvgGridDensity();
}

void NesterovPlace::plotInstJson(std::string file_name, int32_t cur_iter, float overflow)
{
  auto core_shape = _nes_database->_placer_db->get_layout()->get_core_shape();
  std::vector<NesInstance*>& inst_list = _nes_database->_nInstance_list;
  nlohmann::json plot = nlohmann::json::object();

  // Initialize the plot object
  plot["instances"] = nlohmann::json::array();
  plot["real_width"] = core_shape.get_width();
  plot["real_height"] = core_shape.get_height();
  plot["num_obj"] = _nes_database->_nInstance_list.size();
  plot["ll_x"] = core_shape.get_ll_x();
  plot["ll_y"] = core_shape.get_ll_y();
  plot["iter"] = cur_iter;

  int32_t core_shift_x = core_shape.get_ll_x();
  int32_t core_shift_y = core_shape.get_ll_y();

  for (auto* inst : inst_list) {
    int32_t inst_real_width = inst->get_origin_shape().get_width();
    int32_t inst_real_height = inst->get_origin_shape().get_height();
    auto inst_center = inst->get_density_center_coordi();
    inst_center.set_x(inst_center.get_x() - core_shift_x);
    inst_center.set_y(inst_center.get_y() - core_shift_y);

    plot["instances"].push_back({{"id", inst->get_inst_id()},
                                 {"name", inst->get_name()},
                                 {"x", inst_center.get_x()},
                                 {"y", inst_center.get_y()},
                                 {"width", inst_real_width},
                                 {"height", inst_real_height},
                                 {"is_macro", inst->isMacro()},
                                 {"is_filler", inst->isFiller()}});
  }

  std::ofstream out_file(iPLAPIInst.obtainTargetDir() + "/pl/plot/" + file_name + ".json");
  out_file << plot.dump(2);
  out_file.close();
}

void NesterovPlace::printIterInfoToCsv(std::ofstream& file_stream, int32_t iter_num)
{
  file_stream << _nes_database->_wirelength_grad_sum << "," << _nes_database->_density_grad_sum * _nes_database->_density_penalty << ","
              << _nes_database->_density_penalty << "," << _nes_database->_nesterov_solver->get_next_steplength() << std::endl;
  ;
}

void NesterovPlace::printDensityMapToCsv(std::string file_name)
{
  std::ofstream file_stream;
  file_stream.open(iPLAPIInst.obtainTargetDir() + "/pl/" + file_name + ".csv");
  if (!file_stream.good()) {
    LOG_WARNING << "Cannot open file for density map calculation!";
  }

  int32_t grid_cnt_y = _nes_database->_grid_manager->get_grid_cnt_y();
  int32_t grid_cnt_x = _nes_database->_grid_manager->get_grid_cnt_x();
  float available_ratio = _nes_database->_grid_manager->get_available_ratio();
  auto& grid_2d_list = _nes_database->_grid_manager->get_grid_2d_list();

  for (int32_t i = grid_cnt_y - 1; i >= 0; i--) {
    for (int32_t j = 0; j < grid_cnt_x; j++) {
      file_stream << grid_2d_list[i][j].obtainGridDensity() / available_ratio << ",";
    }
    file_stream << std::endl;
  }

  file_stream.close();
}

void NesterovPlace::writeBackPlacerDB()
{
  // #pragma omp parallel for num_threads(_nes_config.get_thread_num())
  int32_t site_width = _nes_database->_placer_db->get_layout()->get_site_width();
  int32_t right_padding = _global_right_padding * site_width;
  int32_t center_compensation_x = right_padding / 2;

  for (auto pair : _nes_database->_instance_map) {
    auto* n_inst = pair.first;
    auto* inst = pair.second;

    auto inst_center = n_inst->get_density_center_coordi();
    inst_center.set_x(inst_center.get_x() - center_compensation_x);
    inst->update_center_coordi(inst_center);
  }
  PlacerDBInst.updateGridManager();
}

void NesterovPlace::updateMaxLengthNetWeight()
{
  int32_t max_wirelength_constraint = _nes_config.get_max_net_wirelength();

  for (auto* n_net : _nes_database->_nNet_list) {
    if (n_net->isDontCare()) {
      continue;
    }

    int32_t n_net_wirelength = _nes_database->_wirelength->obtainNetWirelength(n_net->get_net_id());
    int32_t delta = n_net_wirelength - max_wirelength_constraint;
    if (delta < 0) {
      continue;
    }

    float wl_overflow = static_cast<float>(delta) / max_wirelength_constraint;
    float pre_delta_weight = n_net->get_delta_weight();
    float cur_delta_weight = static_cast<float>(1 + exp(1)) / (1 + exp(-wl_overflow)) - 1;
    float delta_weight = 0.5 * pre_delta_weight + 0.5 * cur_delta_weight;

    n_net->set_weight(n_net->get_weight() + delta_weight);
    n_net->set_delta_weight(delta_weight);
  }
}

void NesterovPlace::updateTimingNetWeight()
{
  float cita = 0.2;

  auto* topo_manager = _nes_database->_topology_manager;
  auto* timing_annotation = _nes_database->_timing_annotation;
  auto& nNet_list = _nes_database->_nNet_list;
  std::vector<float> prev_miu_list;
  prev_miu_list.resize(nNet_list.size());
  float prev_max_centrality = timing_annotation->get_max_centrality();
  for (size_t i = 0; i < nNet_list.size(); i++) {
    if (Utility().isFloatApproximatelyZero(prev_max_centrality)) {
      prev_miu_list[i] = 0.0f;
      continue;
    }

    auto* n_net = nNet_list[i];
    auto* network = topo_manager->findNetworkById(n_net->get_net_id());
    if (n_net->isDontCare()) {
      prev_miu_list[i] = 0.0f;
    } else {
      prev_miu_list[i] = timing_annotation->get_network_centrality(network) / prev_max_centrality;
    }
  }

  timing_annotation->updateSTATimingFull();
  timing_annotation->updateCriticalityAndCentralityFull();

  float cur_max_centrality = timing_annotation->get_max_centrality();
  const float hold_guard = _nes_config.get_timing_hold_slack_guard();
  int32_t hold_limited_net_count = 0;
  for (size_t i = 0; i < nNet_list.size(); i++) {
    if (Utility().isFloatApproximatelyZero(cur_max_centrality)) {
      break;
    }

    auto* n_net = nNet_list[i];
    auto* network = topo_manager->findNetworkById(n_net->get_net_id());
    if (n_net->isDontCare() || (network != nullptr && network->get_network_type() == NETWORK_TYPE::kClock)) {
      //
    } else {
      float cur_miu = timing_annotation->get_network_centrality(network) / cur_max_centrality;
      float delta_weight = cita * prev_miu_list[i] + (1 - cita) * cur_miu;

      // Hold-aware guard: setup-driven net weighting shortens wires and can
      // turn a small positive hold margin negative. Scale the weight bump down
      // as the net's early (hold) slack approaches the configured guard.
      if (hold_guard > 0.0F) {
        float early_slack = 1.0F;
        auto* driver = network->get_transmitter();
        if (driver != nullptr) {
          early_slack = timing_annotation->get_node_early_slack(driver->get_node_id());
        }
        for (auto* receiver : network->get_receiver_list()) {
          early_slack = std::min(early_slack, timing_annotation->get_node_early_slack(receiver->get_node_id()));
        }
        float hold_scale = early_slack >= hold_guard ? 1.0F : (early_slack > 0.0F ? early_slack / hold_guard : 0.0F);
        if (hold_scale < 1.0F) {
          ++hold_limited_net_count;
          delta_weight *= hold_scale;
        }
      }

      float cur_netweight = n_net->get_weight() + delta_weight;
      n_net->set_weight(cur_netweight);
    }
  }
  if (hold_limited_net_count > 0) {
    LOG_INFO << "[NesterovSolve] timing hold guard limited " << hold_limited_net_count << " nets.";
  }
}

void NesterovPlace::printNesterovDatabase()
{
  int32_t nes_inst_cnt = _nes_database->_nInstance_list.size();
  int32_t fixed_nes_inst_cnt = 0;
  int32_t macro_nes_inst_cnt = 0;
  int32_t stdcell_nes_inst_cnt = 0;
  int32_t filler_nes_inst_cnt = 0;

  for (auto n_inst : _nes_database->_nInstance_list) {
    if (n_inst->isFixed()) {
      fixed_nes_inst_cnt++;
    }

    if (n_inst->isMacro()) {
      macro_nes_inst_cnt++;
    } else {
      stdcell_nes_inst_cnt++;
      if (n_inst->isFiller()) {
        filler_nes_inst_cnt++;
      }
    }
  }

  LOG_INFO << "NesInstances Num : " << nes_inst_cnt;
  LOG_INFO << "1. Macro Num : " << macro_nes_inst_cnt;
  LOG_INFO << "2. Stdcell Num : " << stdcell_nes_inst_cnt;
  LOG_INFO << "2.1 Filler Num : " << filler_nes_inst_cnt;
  LOG_INFO << "Fixed NesInstances Num : " << fixed_nes_inst_cnt;

  int32_t nes_net_cnt = _nes_database->_nNet_list.size();
  int32_t dont_care_net_cnt = 0;
  int32_t set_weight_net_cnt = 0;

  for (auto n_net : _nes_database->_nNet_list) {
    if (n_net->isDontCare()) {
      dont_care_net_cnt++;
    }

    if (fabs(n_net->get_weight() - 1.0F) >= 1e-5) {
      set_weight_net_cnt++;
    }
  }

  LOG_INFO << "NesNets Num : " << nes_net_cnt;
  LOG_INFO << "Dont Care Num : " << dont_care_net_cnt;
  LOG_INFO << "Set NetWeight Num : " << set_weight_net_cnt;

  LOG_INFO << "NesPins Num : " << _nes_database->_nPin_list.size();

  int32_t bin_size_x = _nes_database->_grid_manager->get_grid_size_x();
  int32_t bin_size_y = _nes_database->_grid_manager->get_grid_size_y();
  LOG_INFO << "BinGrid Info";
  LOG_INFO << "BinCnt(x * y) : " << _nes_config.get_bin_cnt_x() << " * " << _nes_config.get_bin_cnt_y();
  LOG_INFO << "BinSize(width , height) : " << bin_size_x << " , " << bin_size_y;
  LOG_INFO << "Target Density : " << _nes_config.get_target_density();
}

void NesterovPlace::printAcrossLongNet(std::ofstream& long_net_stream, int32_t max_width, int32_t max_height)
{
  auto* topo_manager = _nes_database->_topology_manager;
  auto core_shape = _nes_database->_placer_db->get_layout()->get_core_shape();
  int32_t core_width = core_shape.get_width();
  int32_t core_height = core_shape.get_height();

  int net_count = 0;

  for (auto* network : topo_manager->get_network_list()) {
    auto shape = network->obtainNetWorkShape();
    int32_t network_width = shape.get_width();
    int32_t network_height = shape.get_height();

    if (network_width > max_width && network_height > max_height) {
      long_net_stream << "Net : " << network->get_name() << " Width/CoreWidth " << network_width << "/" << core_width
                      << " Height/CoreHeight " << network_height << "/" << core_height << std::endl;
      ++net_count;
    } else if (network_width > max_width) {
      long_net_stream << "Net : " << network->get_name() << " Width/CoreWidth " << network_width << "/" << core_width << std::endl;
      ++net_count;
    } else if (network_height > max_height) {
      long_net_stream << "Net : " << network->get_name() << " Height/CoreHeight " << network_height << "/" << core_height << std::endl;
      ++net_count;
    }
  }

  long_net_stream << std::endl;
  long_net_stream << "SUMMARY : "
                  << "AcrossLongNets / Total Nets = " << net_count << " / " << topo_manager->get_network_list().size() << std::endl;
  long_net_stream << std::endl << std::endl;
}

void NesterovPlace::saveNesterovPlaceData(int32_t cur_iter)
{
  iplf::plInst->clearFileInstanceList();

  for (auto pair : _nes_database->_instance_map) {
    auto* nes_inst = pair.first;

    if (nes_inst->isFiller()) {
      continue;
    }

    auto* inst = pair.second;
    int32_t coordi_x = nes_inst->get_density_center_coordi().get_x() - inst->get_shape_width() / 2;
    int32_t coordi_y = nes_inst->get_density_center_coordi().get_y() - inst->get_shape_height() / 2;

    std::string orient;
    if (inst->get_orient() == Orient::kN_R0) {
      orient = "N_R0";
    } else if (inst->get_orient() == Orient::kS_R180) {
      orient = "S_R180";
    } else if (inst->get_orient() == Orient::kFN_MY) {
      orient = "FN_MY";
    } else if (inst->get_orient() == Orient::kFS_MX) {
      orient = "FS_MX";
    }

    iplf::plInst->addFileInstance(nes_inst->get_name(), coordi_x, coordi_y, (int8_t) inst->get_orient());
  }

  iplf::plInst->saveInstanceDataToDirectory(iPLAPIInst.obtainTargetDir() + "/pl/gui/");
}

void NesterovPlace::printIterationCoordi(std::ofstream& long_net_stream, int32_t cur_iter)
{
  for (auto pair : _nes_database->_instance_map) {
    auto* nes_inst = pair.first;

    if (nes_inst->isFiller()) {
      continue;
    }

    auto* inst = pair.second;
    int32_t coordi_x = nes_inst->get_density_center_coordi().get_x() - inst->get_shape_width() / 2;
    int32_t coordi_y = nes_inst->get_density_center_coordi().get_y() - inst->get_shape_height() / 2;

    std::string orient;
    if (inst->get_orient() == Orient::kN_R0) {
      orient = "N_R0";
    } else if (inst->get_orient() == Orient::kS_R180) {
      orient = "S_R180";
    } else if (inst->get_orient() == Orient::kFN_MY) {
      orient = "FN_MY";
    } else if (inst->get_orient() == Orient::kFS_MX) {
      orient = "FS_MX";
    }

    long_net_stream << nes_inst->get_name() << " " << coordi_x << "," << coordi_y << " " << orient << std::endl;
  }
}

void NesterovPlace::resetOverflowRecordList()
{
  _overflow_record_list.clear();
}

void NesterovPlace::resetHPWLRecordList()
{
  _hpwl_record_list.clear();
}

void NesterovPlace::initQuadPenaltyCoeff()
{
  int64_t cur_overflow = std::max((int64_t) 1, _nes_database->_bin_grid->get_overflow_area_without_filler());

  // density weight subgradient preconditioner
  float density_weight_grad_precond = 1.0 / cur_overflow;
  _quad_penalty_coeff = _quad_penalty_coeff / 2 * density_weight_grad_precond;
}

bool NesterovPlace::checkPlateau(int32_t window, float threshold)
{
  int32_t cur_size = static_cast<int32_t>(_overflow_record_list.size());
  if (cur_size < window) {
    return false;
  }

  float max = FLT_MIN;
  float min = FLT_MAX;
  float avg = 0.0;
  auto iter_end = _overflow_record_list.rbegin() + window;
  for (auto it = _overflow_record_list.rbegin(); it != iter_end; it++) {
    *it > max ? max = *it : max;
    *it < min ? min = *it : min;
    avg += *it;
  }

  return (max - min) / (avg / window) < threshold;
}

void NesterovPlace::entropyInjection(float shrink_factor, float noise_intensity)
{
  int64_t center_x = 0;
  int64_t center_y = 0;
  int32_t movable_inst_cnt = 0;
  // cal all movable instance mean center
  for (auto* inst : _nes_database->_nInstance_list) {
    if (inst->isFixed()) {
      continue;
    }
    auto inst_center = std::move(inst->get_density_center_coordi());
    center_x += inst_center.get_x();
    center_y += inst_center.get_y();
    movable_inst_cnt++;
  }

  center_x /= movable_inst_cnt;
  center_y /= movable_inst_cnt;

  int32_t seed = 1000;
  std::default_random_engine gen(seed);
  std::normal_distribution<float> dis(0, 1);
  for (auto* inst : _nes_database->_nInstance_list) {
    if (inst->isFixed()) {
      continue;
    }
    auto inst_center = std::move(inst->get_density_center_coordi());

    // shrink all movable insts
    int32_t new_x = (inst_center.get_x() - center_x) * shrink_factor + center_x;
    int32_t new_y = (inst_center.get_y() - center_y) * shrink_factor + center_y;

    // add some noise
    new_x += noise_intensity * dis(gen);
    new_y += noise_intensity * dis(gen);

    inst->updateDensityCenterLocation(new_x, new_y);
  }
}

bool NesterovPlace::checkDivergence(int32_t window, float threshold, bool is_routability)
{
  const bool diverged = detectNesterovDivergence(_overflow_record_list, _hpwl_record_list, window, threshold,
                                                 _nes_config.get_target_overflow(), _best_overflow, _best_hpwl, is_routability);
  if (diverged) {
    LOG_WARNING << "Detect divergence in the recent Nesterov metric window";
  }
  return diverged;
}

bool NesterovPlace::checkLongTimeOverflowUnchanged(int32_t window, float threshold)
{
  if (static_cast<int32_t>(_overflow_record_list.size()) < window) {
    return false;
  }

  int32_t begin_idx = static_cast<int32_t>(_overflow_record_list.size() - window);
  int32_t end_idx = static_cast<int32_t>(_overflow_record_list.size());

  float overflow_mean = 0.0f;
  float overflow_max = FLT_MIN;
  float overflow_min = FLT_MAX;

  for (int32_t i = begin_idx; i < end_idx; i++) {
    float overflow = _overflow_record_list[i];
    overflow_mean += overflow;
    overflow > overflow_max ? overflow_max = overflow : overflow;
    overflow < overflow_min ? overflow_min = overflow : overflow;
  }

  overflow_mean /= window;

  if (overflow_mean <= 0.0F) {
    return false;
  }
  float overflow_ratio = (overflow_max - overflow_min) / overflow_mean;
  if (overflow_ratio < 0.8 * threshold) {
    LOG_WARNING << "Detect divergence: overflow plateau ( " << overflow_ratio << " < " << (0.8 * threshold) << ")";
    return true;
  } else {
    return false;
  }
}

}  // namespace ipl
