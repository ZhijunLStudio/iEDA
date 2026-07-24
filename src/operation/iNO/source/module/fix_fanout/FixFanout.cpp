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
#include "FixFanout.h"
#include "builder.h"

#include "IdbEnum.h"
#include "api/TimingEngine.hh"
#include "api/TimingIDBAdapter.hh"

namespace ino {

FixFanout::FixFanout(ino::DbInterface *db_interface) : _db_interface(db_interface) {
  if (_db_interface != nullptr) {
    _timing_engine = _db_interface->get_timing_engine();
    _idb = _db_interface->get_idb();
    _max_fanout = _db_interface->get_max_fanout();
  }
}

/**
 * 临时修复io问题,此函数有问题可联系zzs
 */
FixResult FixFanout::fixIO() {
  if (_db_interface == nullptr || _idb == nullptr || _idb->get_def_service() == nullptr || _idb->get_lef_service() == nullptr) {
    return FixResult::failure("iNO database is not initialized");
  }

  auto* idb_design = _idb->get_def_service()->get_design();
  auto* idb_layout = _idb->get_lef_service()->get_layout();
  if (idb_design == nullptr || idb_layout == nullptr || idb_layout->get_cell_master_list() == nullptr) {
    return FixResult::failure("iNO design or layout is not initialized");
  }

  idb::IdbPins *idb_io_pin_list = idb_design->get_io_pin_list();
  if (idb_io_pin_list == nullptr) {
    return FixResult::failure("iNO design has no IO pin list");
  }
  std::string buffer_name = _db_interface->get_insert_buffer();
  auto* buffer_master = idb_layout->get_cell_master_list()->find_cell_master(buffer_name);
  if (buffer_master == nullptr) {
    return FixResult::failure("insert buffer cell master '" + buffer_name + "' was not found");
  }

  bool has_input = false;
  bool has_output = false;
  for (auto* term : buffer_master->get_term_list()) {
    if (term == nullptr) {
      continue;
    }
    has_input = has_input || term->get_direction() == idb::IdbConnectDirection::kInput;
    has_output = has_output || term->get_direction() == idb::IdbConnectDirection::kOutput;
  }
  if (!has_input || !has_output) {
    return FixResult::failure("insert buffer cell master '" + buffer_name + "' must have input and output pins");
  }

  for (auto* io_pin : idb_io_pin_list->get_pin_list()) {
    if (io_pin == nullptr || io_pin->get_term() == nullptr) {
      return FixResult::failure("iNO design contains an invalid IO pin");
    }
    if (io_pin->get_net() == nullptr || io_pin->get_net()->get_instance_pin_list() == nullptr) {
      continue;
    }
    for (auto* load_pin : io_pin->get_net()->get_instance_pin_list()->get_pin_list()) {
      if (load_pin == nullptr) {
        return FixResult::failure("an IO net contains an invalid load pin");
      }
    }
  }

  size_t      new_buf_idx = 0;
  size_t      new_net_idx = 0;

  for (idb::IdbPin *idb_io_pin : idb_io_pin_list->get_pin_list()) {
    if (idb_io_pin->get_net() == nullptr) {
      continue;
    }
    if (idb_io_pin->get_pin_name() == idb_io_pin->get_net()->get_net_name()) {
      idb::IdbNet               *io_net = idb_io_pin->get_net();
      std::vector<idb::IdbPin *> instance_pin_list =
          io_net->get_instance_pin_list()->get_pin_list();
      // 在io net中解开所有instance_pin
      for (idb::IdbPin *instance_pin : instance_pin_list) {
        if (!idb_design->disconnectPinFromNet(instance_pin)) {
          return FixResult::failure("failed to disconnect an IO net load");
        }
      }
      // 构建新的net
      idb::IdbNet *new_net = idb_design->createOrFindNet(idb_design->makeUniqueNetName("fixio_net_" + std::to_string(new_net_idx++)),
                                                         idb::IdbConnectType::kSignal, idb::IdbCreatePolicy::kErrorIfExists);
      if (new_net == nullptr) {
        return FixResult::failure("failed to create a fixIO net");
      }
      // 将原instance pin加入新net
      for (idb::IdbPin *instance_pin : instance_pin_list) {
        if (!idb_design->connectPinToNet(instance_pin, new_net)) {
          return FixResult::failure("failed to reconnect a fixIO load");
        }
      }
      // 生成buf
      idb::IdbInstance *new_buf = idb_design->createInstance(idb_design->makeUniqueInstanceName("fixio_buf_" + std::to_string(new_buf_idx++)),
                                                             buffer_name, idb::IdbInstanceType::kTiming, idb::IdbPlacementStatus::kNone,
                                                             idb::IdbOrient::kNone, 0, 0, idb::IdbCreatePolicy::kErrorIfExists);
      if (new_buf == nullptr) {
        return FixResult::failure("failed to create a fixIO buffer");
      }
      // 插入buf
      for (idb::IdbPin *buf_pin : new_buf->get_pin_list()->get_pin_list()) {
        if (buf_pin->get_term()->get_direction() == idb::IdbConnectDirection::kInput ||
            buf_pin->get_term()->get_direction() == idb::IdbConnectDirection::kOutput) {
          if (buf_pin->get_term()->get_direction() ==
              idb_io_pin->get_term()->get_direction()) {
            if (!idb_design->connectPinToNet(buf_pin, io_net)) {
              return FixResult::failure("failed to connect a fixIO buffer pin");
            }
          } else {
            if (!idb_design->connectPinToNet(buf_pin, new_net)) {
              return FixResult::failure("failed to connect a fixIO buffer pin");
            }
          }
        }
      }

    } else {
      idb::IdbNet *origin_net = idb_io_pin->get_net();
      // 在origin net中解开io pin
      if (!idb_design->disconnectPinFromNet(idb_io_pin)) {
        return FixResult::failure("failed to disconnect an IO pin");
      }
      // 加入原来的io net
      idb::IdbNet *io_net = idb_design->createOrFindNet(idb_io_pin->get_pin_name(), idb::IdbConnectType::kSignal);
      if (io_net == nullptr) {
        return FixResult::failure("failed to create an IO pin net");
      }
      if (!idb_design->connectPinToNet(idb_io_pin, io_net)) {
        return FixResult::failure("failed to reconnect an IO pin");
      }
      // 生成buf
      idb::IdbInstance *new_buf = idb_design->createInstance(idb_design->makeUniqueInstanceName("fixio_buf_" + std::to_string(new_buf_idx++)),
                                                             buffer_name, idb::IdbInstanceType::kTiming, idb::IdbPlacementStatus::kNone,
                                                             idb::IdbOrient::kNone, 0, 0, idb::IdbCreatePolicy::kErrorIfExists);
      if (new_buf == nullptr) {
        return FixResult::failure("failed to create a fixIO buffer");
      }
      // 插入buf
      for (idb::IdbPin *buf_pin : new_buf->get_pin_list()->get_pin_list()) {
        if (buf_pin->get_term()->get_direction() == idb::IdbConnectDirection::kInput ||
            buf_pin->get_term()->get_direction() == idb::IdbConnectDirection::kOutput) {
          if (buf_pin->get_term()->get_direction() ==
              idb_io_pin->get_term()->get_direction()) {
            if (!idb_design->connectPinToNet(buf_pin, io_net)) {
              return FixResult::failure("failed to connect a fixIO buffer pin");
            }
          } else {
            if (!idb_design->connectPinToNet(buf_pin, origin_net)) {
              return FixResult::failure("failed to connect a fixIO buffer pin");
            }
          }
        }
      }
    }
  }

  LOG_INFO << "[Result: ] Insert " << new_buf_idx << " fix_io buffers.\n";
  LOG_INFO << "[Result: ] Insert " << new_net_idx << " fix_io nets.\n";
  return FixResult::success(new_buf_idx);
}

FixResult FixFanout::fixFanout() {
  if (_db_interface == nullptr || _idb == nullptr || _timing_engine == nullptr || _idb->get_lef_service() == nullptr
      || _idb->get_def_service() == nullptr) {
    return FixResult::failure("iNO database or timing engine is not initialized");
  }

  _idb_layout = _idb->get_lef_service()->get_layout();
  _idb_design = _idb->get_def_service()->get_design();
  if (_idb_layout == nullptr || _idb_design == nullptr || _idb_layout->get_cell_master_list() == nullptr) {
    return FixResult::failure("iNO design or layout is not initialized");
  }
  if (_max_fanout < 2) {
    return FixResult::failure("max_fanout must be at least 2");
  }

  const auto buffer_name = _db_interface->get_insert_buffer();
  auto* buffer_master = _idb_layout->get_cell_master_list()->find_cell_master(buffer_name);
  if (buffer_master == nullptr) {
    return FixResult::failure("insert buffer cell master '" + buffer_name + "' was not found");
  }
  bool has_input = false;
  bool has_output = false;
  for (auto* term : buffer_master->get_term_list()) {
    if (term == nullptr) {
      continue;
    }
    has_input = has_input || term->get_direction() == idb::IdbConnectDirection::kInput;
    has_output = has_output || term->get_direction() == idb::IdbConnectDirection::kOutput;
  }
  if (!has_input || !has_output) {
    return FixResult::failure("insert buffer cell master '" + buffer_name + "' must have input and output pins");
  }

  _db_interface->set_eval_data();

  auto      *design_nl = _timing_engine->get_netlist();
  if (design_nl == nullptr) {
    return FixResult::failure("iNO timing netlist is not initialized");
  }

  auto* idb_adapter = dynamic_cast<ista::TimingIDBAdapter *>(_timing_engine->get_db_adapter());
  if (idb_adapter == nullptr) {
    return FixResult::failure("iNO timing database adapter is not initialized");
  }

  std::size_t inserted = 0;
  ista::Net *sta_net;
  FOREACH_NET(design_nl, sta_net) {
    auto fanout = (int)sta_net->getFanouts();
    const auto endpoint_disposition = classifyFanoutEndpoints(sta_net->getDriver() != nullptr, fanout);
    if (endpoint_disposition == FanoutEndpointDisposition::kSkipNoLoads) {
      continue;
    }
    if (endpoint_disposition == FanoutEndpointDisposition::kMissingDriver) {
      return FixResult::failure("loaded timing net '" + std::string(sta_net->get_name()) + "' has no driver");
    }

    IdbNet *db_net = idb_adapter->staToDb(sta_net);
    if (db_net == nullptr) {
      return FixResult::failure("failed to map timing net '" + std::string(sta_net->get_name()) + "' to iDB");
    }
    if (sta_net->isClockNet()) {
      _idb_design->setNetConnectType(db_net->get_net_name(), idb::IdbConnectType::kClock);
      continue;
    }
    if (fanout > _max_fanout) {
      _fanout_vio_num++;
      auto result = fixFanout(db_net);
      if (!result.ok) {
        return result;
      }
      inserted += result.inserted;
    }
  }

  LOG_INFO << "[Result: ] Find " << _fanout_vio_num << " Net with fanout violation.\n";
  LOG_INFO << "[Result: ] Insert " << _insert_instance_index - 1 << " Buffers.\n";

  _db_interface->report()->get_ofstream() << "[Result: ] Find " << _fanout_vio_num
                                          << " Net with fanout violation.\n"
                                             "[Result: ] Insert "
                                          << _insert_instance_index - 1 << " Buffers.\n";
  _db_interface->report()->get_ofstream().close();
  _db_interface->report()->reportTime(false);
  return FixResult::success(inserted);
}

FixResult FixFanout::fixFanout(IdbNet *net) {
  if (net == nullptr) {
    return FixResult::failure("fanout repair net is null");
  }

  auto load_pins = net->get_load_pins();
  for (auto* load_pin : load_pins) {
    if (load_pin == nullptr) {
      return FixResult::failure("fanout repair net contains an invalid load pin");
    }
  }
  const auto endpoint_disposition = classifyFanoutEndpoints(net->get_driving_pin() != nullptr, load_pins.size());
  if (endpoint_disposition == FanoutEndpointDisposition::kSkipNoLoads) {
    return FixResult::success();
  }
  if (endpoint_disposition == FanoutEndpointDisposition::kMissingDriver) {
    return FixResult::failure("loaded iDB net '" + net->get_net_name() + "' has no driver");
  }

  int  fanout = load_pins.size();
  bool have_switch_name = false;
  std::size_t inserted = 0;
  while (fanout > _max_fanout) {
    load_pins = net->get_load_pins();
    bool connect_to_port = false; // if net connect to a port need rename for the net
    for (auto pin : load_pins) {
      if (pin->is_io_pin()) {
        connect_to_port = true;
        break;
      }
    }
    /* code */
    IdbNet *in_net, *out_net;
    in_net = net;
    string net_name = ("fanout_net_" + std::to_string(_make_net_index));
    _make_net_index++;
    out_net = makeNet(net_name.c_str());
    if (out_net == nullptr) {
      return FixResult::failure("failed to create a fanout repair net");
    }

    string buf_name = ("fanout_buf_" + std::to_string(_insert_instance_index));
    _insert_instance_index++;

    auto         insert_buffer = _db_interface->get_insert_buffer();
    IdbInstance *insert_buf = makeInstance(insert_buffer, buf_name.c_str());
    if (insert_buf == nullptr) {
      return FixResult::failure("failed to create fanout buffer '" + buf_name + "'");
    }

    // get buf input_pin and output_pin
    IdbPin  *buf_input_pin = nullptr;
    IdbPin  *buf_output_pin = nullptr;
    IdbPins *buf_pins = insert_buf->get_pin_list();
    for (auto pin : buf_pins->get_pin_list()) {
      if (pin->get_term()->get_type() == idb::IdbConnectType::kPower ||
          pin->get_term()->get_type() == idb::IdbConnectType::kGround) {
        continue;
      }
      if (pin->get_term()->get_direction() == idb::IdbConnectDirection::kInput) {
        buf_input_pin = pin;
      } else if (pin->get_term()->get_direction() == idb::IdbConnectDirection::kOutput) {
        buf_output_pin = pin;
      }
    }
    if (buf_input_pin == nullptr || buf_output_pin == nullptr) {
      return FixResult::failure("fanout buffer '" + buf_name + "' has no input or output pin");
    }
    if (!connect(buf_input_pin, in_net) || !connect(buf_output_pin, out_net)) {
      return FixResult::failure("failed to connect fanout buffer '" + buf_name + "'");
    }
    ++inserted;
    for (int i = 0; i < _max_fanout; i++) {
      IdbPin *idb_pin = load_pins[i];
      if (connect_to_port && !have_switch_name) {
        string in_net_name = in_net->get_net_name();
        string out_net_name = out_net->get_net_name();
        const string temp_net_name = "__ino_fanout_swap_" + std::to_string(_make_net_index) + "_"
                                     + std::to_string(_insert_instance_index);
        auto* idb_adpat =
            dynamic_cast<ista::TimingIDBAdapter *>(_timing_engine->get_db_adapter());
        auto* in_sta_net = idb_adpat == nullptr ? nullptr : idb_adpat->dbToSta(in_net);
        auto* out_sta_net = idb_adpat == nullptr ? nullptr : idb_adpat->dbToSta(out_net);
        if (idb_adpat != nullptr && in_sta_net != nullptr && out_sta_net != nullptr) {
          idb_adpat->swapNetNames(in_sta_net, out_sta_net);
        } else {
          _idb_design->renameNet(in_net, temp_net_name);
          _idb_design->renameNet(out_net, in_net_name);
          _idb_design->renameNet(in_net, out_net_name);
        }
        have_switch_name = true;
      }
      // 1
      if (!disconnectPin(idb_pin, in_net)) {
        return FixResult::failure("failed to disconnect a fanout load");
      }
      // 2
      if (!connect(idb_pin, out_net)) {
        return FixResult::failure("failed to reconnect a fanout load");
      }
    }
    fanout = net->get_load_pins().size();
  }
  return FixResult::success(inserted);
}

IdbNet *FixFanout::makeNet(const char *name) {
  string str_name = _idb_design->makeUniqueNetName(name == nullptr ? "fanout_net_" : name);
  return _idb_design->createOrFindNet(str_name, idb::IdbConnectType::kSignal, idb::IdbCreatePolicy::kErrorIfExists);
}

IdbInstance *FixFanout::makeInstance(string master_name, string inst_name) {
  return _idb_design->createInstance(_idb_design->makeUniqueInstanceName(inst_name), master_name, idb::IdbInstanceType::kTiming,
                                     idb::IdbPlacementStatus::kNone, idb::IdbOrient::kNone, 0, 0,
                                     idb::IdbCreatePolicy::kErrorIfExists);
}

bool FixFanout::disconnectPin(IdbPin *dpin, IdbNet *dnet) {
  return _idb_design != nullptr && dpin != nullptr && dnet != nullptr && dpin->get_net() == dnet
         && _idb_design->disconnectPinFromNet(dpin);
}

bool FixFanout::connect(IdbPin *dpin, IdbNet *dnet) {
  return _idb_design != nullptr && dpin != nullptr && dnet != nullptr && _idb_design->connectPinToNet(dpin, dnet);
}

} // namespace ino
