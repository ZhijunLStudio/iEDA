// ***************************************************************************************
// Copyright (c) 2026-2030 Southeast University
// Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
//
// iEDA is licensed under Mulan PSL v2.
// ***************************************************************************************
#pragma once

#include <string>

#include "LvsCore.hpp"

namespace ilvs {

class ILVSAPI
{
 public:
  ILVSAPI() = default;

  auto run(const LvsGraph& reference_graph, const LvsGraph& extracted_graph, const LvsManifest& manifest,
           const LvsOptions& options = {}) const -> LvsResult;
  auto runFromJsonFiles(const std::string& reference_graph_path, const std::string& extracted_graph_path, const LvsManifest& manifest,
                        const LvsOptions& options = {}) const -> LvsResult;
};

}  // namespace ilvs
