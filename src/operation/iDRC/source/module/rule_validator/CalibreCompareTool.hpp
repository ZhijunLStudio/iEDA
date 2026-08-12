// ***************************************************************************************
// Copyright (c) 2023-2025 Peng Cheng Laboratory
// Copyright (c) 2023-2025 Institute of Computing Technology, Chinese Academy of Sciences
// Copyright (c) 2023-2025 Beijing Institute of Open Source Chip
//
// iEDA is licensed under Mulan PSL v2.
// ***************************************************************************************
#pragma once

#include <set>
#include <string>

#include "ViolationArtifact.hpp"

namespace idrc {

struct CalibreCompareConfig
{
  std::string idrc_artifact_path;
  std::string calibre_artifact_path;
  std::string output_report_path;
  std::set<std::string> supported_rule_types;
  CalibreCompareOptions options;
};

class CalibreCompareTool
{
 public:
  static auto run(const CalibreCompareConfig& config) -> bool;
  static auto runToReport(const CalibreCompareConfig& config, nlohmann::ordered_json* report, std::string* error = nullptr) -> bool;
};

}  // namespace idrc
