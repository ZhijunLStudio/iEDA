#include "RustVCDParserWrapper.hh"

#include <filesystem>
#include <string>
#include <vector>

#include "string/Str.hh"

namespace ipower {

namespace {

std::vector<std::string> splitScopePath(const char* scope_path) {
  std::vector<std::string> components;
  if (scope_path == nullptr) {
    return components;
  }
  std::string path(scope_path);
  size_t begin = 0;
  while (begin < path.size()) {
    const size_t end = path.find('/', begin);
    const std::string component = path.substr(begin, end == std::string::npos ? std::string::npos : end - begin);
    if (!component.empty()) {
      components.push_back(component);
    }
    if (end == std::string::npos) {
      break;
    }
    begin = end + 1;
  }
  return components;
}

RustVCDScope* findDirectChild(RustVCDScope* parent, const std::string& name) {
  if (parent == nullptr) {
    return nullptr;
  }
  auto children = parent->children_scope;
  void* child;
  FOREACH_VEC_ELEM(&children, void, child) {
    void* child_ptr = rust_convert_rc_ref_cell_scope(child);
    RustVCDScope* child_scope = rust_convert_vcd_scope(child_ptr);
    if (child_scope != nullptr && ieda::Str::equal(child_scope->name, name.c_str())) {
      return child_scope;
    }
  }
  return nullptr;
}

RustVCDScope* findScopeByName(RustVCDScope* parent, const std::string& name) {
  if (parent == nullptr) {
    return nullptr;
  }
  if (ieda::Str::equal(parent->name, name.c_str())) {
    return parent;
  }
  auto children = parent->children_scope;
  void* child;
  FOREACH_VEC_ELEM(&children, void, child) {
    void* child_ptr = rust_convert_rc_ref_cell_scope(child);
    RustVCDScope* child_scope = rust_convert_vcd_scope(child_ptr);
    if (auto* found = findScopeByName(child_scope, name); found != nullptr) {
      return found;
    }
  }
  return nullptr;
}

RustVCDScope* findScope(RustVCDScope* root, const char* scope_path) {
  const auto components = splitScopePath(scope_path);
  if (root == nullptr || components.empty()) {
    return nullptr;
  }
  if (components.size() == 1) {
    return findScopeByName(root, components.front());
  }

  RustVCDScope* current = nullptr;
  size_t index = 0;
  if (ieda::Str::equal(root->name, components.front().c_str())) {
    current = root;
    index = 1;
  } else {
    current = findScopeByName(root, components.front());
    index = 1;
  }
  for (; current != nullptr && index < components.size(); ++index) {
    current = findDirectChild(current, components[index]);
  }
  return current;
}

}  // namespace

unsigned RustVcdParserWrapper::readVcdFile(const char* vcd_file_path) {
  if (vcd_file_path == nullptr || vcd_file_path[0] == '\0') {
    LOG_ERROR << "VCD path is empty";
    return 0;
  }
  std::error_code error;
  if (!std::filesystem::is_regular_file(vcd_file_path, error) || error) {
    LOG_ERROR << "VCD file does not exist: " << vcd_file_path;
    return 0;
  }
  RustVcdReader vcd_reader;
  _vcd_file_ptr = vcd_reader.readVcdFile(vcd_file_path);
  if (_vcd_file_ptr == nullptr) {
    LOG_ERROR << "failed to parse VCD file: " << vcd_file_path;
    return 0;
  }
  _vcd_file = rust_convert_vcd_file(_vcd_file_ptr);
  if (_vcd_file == nullptr || _vcd_file->scope_root == nullptr) {
    LOG_ERROR << "VCD file has no root scope: " << vcd_file_path;
    return 0;
  }
  return 1U;
}

unsigned RustVcdParserWrapper::buildAnnotateDB(const char* top_instance_name) {
  if (_vcd_file == nullptr || _vcd_file->scope_root == nullptr) {
    LOG_ERROR << "build VCD annotation failed: no VCD file was loaded";
    return 0;
  }
  auto* root_scope = static_cast<RustVCDScope*>(_vcd_file->scope_root);
  RustVCDScope* found_scope = findScope(root_scope, top_instance_name);
  if (found_scope == nullptr) {
    LOG_ERROR << "VCD scope not found: " << (top_instance_name == nullptr ? "<null>" : top_instance_name);
    return 0;
  }
  _top_instance_scope = found_scope;

  // TODO(to shaozheqing),config the annotate simualtion time and time scale.
  /*set simualtion time for annotate database*/
  if (_end_time) {
    // User set timescale end time
    if (_begin_time) {
      // User set timescale begin time
      _annotate_db.set_simulation_duration(_end_time.value() -
                                           _begin_time.value());
    } else {
      _annotate_db.set_simulation_duration(_end_time.value());
    }
  } else {
    // User did not set timescale end time, use the simulation end time
    // FIXME(to shaozheqing) set simulation end time
    int64_t simulation_end_time = _vcd_file->end_time;
    _annotate_db.set_simulation_duration(simulation_end_time);
  }

  /*set timescale for annotate database*/
  auto time_scale = _vcd_file->time_resolution;
  auto scale_unit = _vcd_file->time_unit;
  _annotate_db.set_timescale(time_scale, scale_unit);

  /*build annotate database according the scope*/
  std::function<void(RustVCDScope*, AnnotateInstance*)>
      build_scope_instance_signal = [this, &build_scope_instance_signal](
                                        RustVCDScope* the_scope,
                                        AnnotateInstance* parent_instance) {
        auto the_scope_instance =
            std::make_unique<AnnotateInstance>(the_scope->name);
        auto* the_scope_instance_ptr = the_scope_instance.get();
        if (!parent_instance) {
          _annotate_db.set_top_instance(std::move(the_scope_instance));
        } else {
          parent_instance->addChildInstance(std::move(the_scope_instance));
        }

        // TODO add signal to struct
        auto scope_signals = the_scope->scope_signals;
        void* scope_signal;
        FOREACH_VEC_ELEM(&scope_signals, void, scope_signal) {
          void* signal_ptr = rust_convert_rc_ref_cell_signal(scope_signal);
          RustVCDSignal* signal = rust_convert_vcd_signal(signal_ptr);
          if (signal == nullptr || signal->name == nullptr) {
            LOG_WARNING << "skip invalid VCD signal record";
            continue;
          }

          if (signal->signal_type != VCDVariableType::kVarWire) {
            continue;
          }
          if (signal->signal_size == 1) {
            // scalar signal
            std::string signal_name(signal->name);

            void* c_bus_index = signal->bus_index;

            if (c_bus_index) {
              Indexes* bus_index = rust_convert_signal_index(c_bus_index);
              if (bus_index != nullptr) {
                signal_name += "[" + std::to_string(bus_index->lindex) + "]";
              }
            }

            auto annotate_signal =
                std::make_unique<AnnotateSignal>(signal_name);
            the_scope_instance_ptr->addSignal(std::move(annotate_signal));
          } else {
            // bus signal
            void* c_bus_index = signal->bus_index;
            if (c_bus_index == nullptr) {
              LOG_WARNING << "skip VCD bus signal without an index: " << signal->name;
              continue;
            }
            Indexes* bus_index = rust_convert_signal_index(c_bus_index);
            if (bus_index == nullptr) {
              LOG_WARNING << "skip VCD bus signal with an invalid index: " << signal->name;
              continue;
            }
            int lindex = bus_index->lindex;
            int rindex = bus_index->rindex;
            for (auto i = rindex; i <= lindex; ++i) {
              std::string signal_name(signal->name);
              std::string name = signal_name + "[" + std::to_string(i) + "]";

              auto annotate_signal = std::make_unique<AnnotateSignal>(name);
              the_scope_instance_ptr->addSignal(std::move(annotate_signal));
            }
          }
        }

        auto children_scopes = the_scope->children_scope;
        void* child_scope;
        FOREACH_VEC_ELEM(&children_scopes, void, child_scope) {
          void* children_scope_ptr =
              rust_convert_rc_ref_cell_scope(child_scope);
          RustVCDScope* cur_child_scope =
              rust_convert_vcd_scope(children_scope_ptr);
          if (cur_child_scope != nullptr) {
            build_scope_instance_signal(cur_child_scope, the_scope_instance_ptr);
          }
        }
      };

  build_scope_instance_signal(_top_instance_scope, nullptr);

  return 1;
}

unsigned RustVcdParserWrapper::calcScopeToggleAndSp(
    const char* top_instance_name) {
  if (_vcd_file_ptr == nullptr || _top_instance_scope == nullptr || top_instance_name == nullptr || top_instance_name[0] == '\0') {
    LOG_ERROR << "calculate VCD activity failed: VCD file or scope is not initialized";
    return 0;
  }
  LOG_INFO << "calculate toggle and sp for scope " << top_instance_name;

  RustTcAndSpResVecs* res_vecs =
      rust_calc_scope_tc_sp(top_instance_name, _vcd_file_ptr);
  if (res_vecs == nullptr) {
    LOG_ERROR << "failed to calculate VCD activity for scope " << top_instance_name;
    return 0;
  }
  auto signal_tc_vec = res_vecs->signal_tc_vec;
  auto signal_sp_vec = res_vecs->signal_duration_vec;

  std::map<std::string, std::pair<RustSignalTC*, RustSignalDuration*>> signal_map;
  void* signal_tc;
  FOREACH_VEC_ELEM(&signal_tc_vec, void, signal_tc) {
    RustSignalTC* cur_signal_tc = rust_convert_signal_tc(signal_tc);
    signal_map[cur_signal_tc->signal_name].first = cur_signal_tc;
  }

  void* signal_sp;
  FOREACH_VEC_ELEM(&signal_sp_vec, void, signal_sp) {
    RustSignalDuration* cur_signal_sp = rust_convert_signal_duration(signal_sp);
    signal_map[cur_signal_sp->signal_name].second = cur_signal_sp;
  }

  /*set data to annotate db*/
  auto* top_instance = _annotate_db.get_top_instance();
  std::function<void(AnnotateInstance*)> traverse_instance =
      [&traverse_instance, this, &signal_tc_vec,
       &signal_sp_vec, &signal_map](auto* instance) {
        LOG_INFO << "traverse instance "
                 << instance->get_module_instance_name();

        AnnotateSignal* signal;
        FOREACH_SIGNAL(instance, signal) {
          LOG_INFO_EVERY_N(100) << "traverse signal " << signal->get_signal_name();

          auto& signal_name = signal->get_signal_name();
          auto* record_data = signal->get_record_data();

          if (signal_map.find(std::string(signal_name)) == signal_map.end()) {
            LOG_INFO << "signal " << signal_name << " not found in vcd tc sp result";
            continue;
          }

          auto* cur_signal_tc = signal_map[std::string(signal_name)].first;
          auto* cur_signal_sp = signal_map[std::string(signal_name)].second;

          // set toggle
          if (cur_signal_tc == nullptr || cur_signal_sp == nullptr) {
            LOG_WARNING << "incomplete VCD activity record for signal " << signal_name;
            continue;
          }
          auto cur_tc = cur_signal_tc->signal_tc;
          AnnotateToggle annotate_toggle;
          annotate_toggle.set_TC(cur_tc);
          (*record_data).set_toggle_record(std::move(annotate_toggle));
          
          // set sp
          AnnotateTime annotate_time(
              cur_signal_sp->bit_0_duration, cur_signal_sp->bit_1_duration,
              cur_signal_sp->bit_x_duration, cur_signal_sp->bit_z_duration);
          (*record_data).set_time_record(std::move(annotate_time));
        }

        AnnotateInstance* child_instance;
        FOREACH_CHILD_INSTANCE(instance, child_instance) {
          traverse_instance(child_instance);
        }
      };

  traverse_instance(top_instance);

  return 1;
}
}  // namespace ipower
