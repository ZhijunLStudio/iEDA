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
#pragma once

#include <algorithm>
#include <cstddef>
#include <string>
#include <utility>

namespace ipower {

enum class ActivitySource { kNone, kVcd, kVectorless };

struct ActivityReport {
  ActivitySource source = ActivitySource::kNone;
  double coverage = 0.0;
  double measured_coverage = 0.0;
  double defaulted_coverage = 0.0;
  double effective_coverage = 0.0;
  std::size_t total_vertices = 0;
  std::size_t annotated_vertices = 0;
  std::size_t defaulted_vertices = 0;
  bool vectorless_enabled = false;
  bool refused = true;
  std::string reason;
};

class ActivityProvenance {
 public:
  void markVcdLoaded() {
    _vcd_loaded = true;
    _vcd_error.clear();
    _total_vertices = 0;
    _annotated_vertices = 0;
  }

  void markVcdFailed(std::string reason) {
    _vcd_loaded = false;
    _vcd_error = std::move(reason);
    _total_vertices = 0;
    _annotated_vertices = 0;
  }

  void selectVectorless() { _vectorless_selected = true; }
  void clearVectorless() { _vectorless_selected = false; }

  void updateCoverage(std::size_t total_vertices,
                      std::size_t annotated_vertices) {
    _total_vertices = total_vertices;
    _annotated_vertices = std::min(total_vertices, annotated_vertices);
  }

  [[nodiscard]] bool hasActivitySelection() const {
    return _vcd_loaded || _vectorless_selected;
  }

  [[nodiscard]] bool isVectorlessSelected() const {
    return _vectorless_selected;
  }

  [[nodiscard]] ActivityReport report() const {
    ActivityReport result;
    result.total_vertices = _total_vertices;
    result.annotated_vertices = _annotated_vertices;
    result.vectorless_enabled = _vectorless_selected;

    const double measured_coverage =
        _total_vertices == 0
            ? 0.0
            : static_cast<double>(_annotated_vertices) /
                  static_cast<double>(_total_vertices);
    result.measured_coverage = measured_coverage;

    if (_vcd_loaded) {
      result.source = ActivitySource::kVcd;
      result.coverage = measured_coverage;
      result.defaulted_vertices =
          _vectorless_selected ? _total_vertices - _annotated_vertices : 0;
      result.defaulted_coverage =
          _vectorless_selected && _total_vertices > 0
              ? 1.0 - measured_coverage
              : 0.0;
      result.effective_coverage =
          _vectorless_selected && _total_vertices > 0 ? 1.0
                                                     : measured_coverage;
      result.refused = _annotated_vertices == 0 && !_vectorless_selected;
      if (result.refused) {
        result.reason = _total_vertices == 0
                            ? "power graph has no activity-eligible vertices"
                            : "VCD did not annotate any power-graph vertices";
      } else if (_vectorless_selected && _annotated_vertices == 0) {
        result.reason = "VCD coverage is empty; explicit vectorless fallback is in use";
      }
      return result;
    }

    if (_vectorless_selected) {
      result.source = ActivitySource::kVectorless;
      result.defaulted_vertices = _total_vertices;
      result.coverage = 0.0;
      result.defaulted_coverage = _total_vertices == 0 ? 0.0 : 1.0;
      result.effective_coverage = result.defaulted_coverage;
      result.refused = _total_vertices == 0;
      if (result.refused) {
        result.reason = "power graph has no activity-eligible vertices";
      }
      return result;
    }

    result.reason = _vcd_error.empty() ? "no activity source was selected"
                                       : _vcd_error;
    return result;
  }

 private:
  bool _vcd_loaded = false;
  bool _vectorless_selected = false;
  std::size_t _total_vertices = 0;
  std::size_t _annotated_vertices = 0;
  std::string _vcd_error;
};

inline const char* activitySourceName(ActivitySource source) {
  switch (source) {
    case ActivitySource::kVcd:
      return "vcd";
    case ActivitySource::kVectorless:
      return "vectorless";
    case ActivitySource::kNone:
      return "none";
  }
  return "none";
}

}  // namespace ipower
