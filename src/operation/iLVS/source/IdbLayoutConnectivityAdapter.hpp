// ***************************************************************************************
// Copyright (c) 2026-2030 Southeast University
// Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
//
// iEDA is licensed under Mulan PSL v2.
// ***************************************************************************************
#pragma once

#include "LayoutConnectivityExtractor.hpp"

namespace idb {
class IdbDesign;
}

namespace ilvs {

struct IdbLayoutExtractionOptions
{
  std::set<std::string> supported_layers;
  bool include_pdn_nets = false;
};

auto makeLayoutSnapshotFromIdb(idb::IdbDesign& design, const IdbLayoutExtractionOptions& options = {}) -> LayoutConnectivitySnapshot;
auto extractLayoutConnectivityGraphFromIdb(idb::IdbDesign& design, const IdbLayoutExtractionOptions& options = {}) -> LayoutExtractionResult;

}  // namespace ilvs
