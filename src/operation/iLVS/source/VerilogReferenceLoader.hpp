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

struct VerilogReferenceOptions
{
  std::string top_module;
  bool fail_on_assign = true;
};

auto loadVerilogReferenceGraph(const std::string& verilog_text, const VerilogReferenceOptions& options = {}) -> LvsGraph;
auto loadVerilogReferenceGraphFile(const std::string& path, const VerilogReferenceOptions& options = {}) -> LvsGraph;

}  // namespace ilvs
