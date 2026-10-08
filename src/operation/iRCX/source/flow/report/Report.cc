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
#include "Report.hh"

#include <filesystem>
#include <fstream>

#include "PathUtils.hh"
#include "ProcessCorner.hpp"
#include "RCXConfig.hh"
#include "RCXData.hh"
#include "SpefDumper.hh"
#include "json/json.hpp"
#include "log/Log.hh"

namespace ircx {
namespace {

auto fileEvidence(const std::filesystem::path& path) -> nlohmann::json
{
  nlohmann::json evidence;
  evidence["path"] = path.string();
  std::error_code ec;
  const bool exists = std::filesystem::is_regular_file(path, ec) && !ec;
  evidence["exists"] = exists;
  evidence["non_empty"] = false;
  if (exists) {
    const auto size = std::filesystem::file_size(path, ec);
    if (!ec) {
      evidence["size_bytes"] = size;
      evidence["non_empty"] = size > 0;
    }
  }
  return evidence;
}

auto expectedSpefPath(const Str& output_dir, const LayoutData& layout, const RCXData::CornerData& corner) -> std::filesystem::path
{
  Str corner_name = corner.name;
  if (corner.process_corner != nullptr) {
    corner_name = corner.process_corner->get_technology();
  }
  return std::filesystem::path(output_dir) / (layout.design_name + "_" + corner_name + ".spef");
}

auto writeCoverageJson(const Str& output_dir, const RCXData& data) -> bool
{
  const auto coverage_path = std::filesystem::path(output_dir) / "rcx_coverage.json";
  nlohmann::json payload;
  payload["schema"] = "c-spef/v0";
  payload["source"] = "ircx";
  payload["trusted"] = true;
  payload["design"] = data.layout().design_name;
  payload["regular_net_count"] = data.layout().regular_net_count();
  payload["spef_files"] = nlohmann::json::array();
  payload["warnings"] = nlohmann::json::array();

  bool has_spef = false;
  for (const auto& corner : data.corner_data()) {
    const auto spef_path = expectedSpefPath(output_dir, data.layout(), corner);
    auto evidence = fileEvidence(spef_path);
    evidence["corner"] = corner.name;
    evidence["itf_file"] = corner.itf_file.empty() ? nlohmann::json(nullptr) : nlohmann::json(corner.itf_file);
    evidence["captab_file"] = corner.captab_file.empty() ? nlohmann::json(nullptr) : nlohmann::json(corner.captab_file);
    has_spef = has_spef || evidence.value("non_empty", false);
    payload["spef_files"].push_back(evidence);
  }

  payload["spef_file"] = payload["spef_files"].empty() ? nlohmann::json(nullptr) : payload["spef_files"].front()["path"];
  payload["trusted"] = has_spef;
  if (!has_spef) {
    payload["source"] = "missing";
    payload["warnings"].push_back("SPEF report completed without a non-empty SPEF file");
  }

  std::ofstream out(coverage_path);
  if (!out.is_open()) {
    LOG_ERROR << "report spef failed: cannot open coverage file " << coverage_path.string();
    return false;
  }
  out << payload.dump(2) << "\n";
  return true;
}

}  // namespace

auto Report::dumpSpef() -> bool
{
  const Str& output_dir = RCX_CONFIG_INST.get_output_dir();
  if (!path::ensure_dir(output_dir, "output_dir")) {
    return false;
  }

  RCXData& data = RCX_DATA_INST;
  const auto& corner_data = data.corner_data();
  if (corner_data.empty()) {
    LOG_ERROR << "report spef failed: process corners not loaded.";
    return false;
  }

  SpefDumper dumper;
  dumper.set_spef_context(&data.spef_context());
  dumper.set_layout_data(&data.layout());
  dumper.set_topo_pool(&data.topo_pool());
  dumper.set_rc_table(&data.rc_table());
  dumper.set_corner_data(&corner_data);
  dumper.set_layer_table(&data.layer_table());
  if (!dumper.dump(output_dir)) {
    return false;
  }

  if (!writeCoverageJson(output_dir, data)) {
    return false;
  }

  return true;
}

}  // namespace ircx
