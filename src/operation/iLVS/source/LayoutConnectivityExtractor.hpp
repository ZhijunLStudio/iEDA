// ***************************************************************************************
// Copyright (c) 2026-2030 Southeast University
// Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
//
// iEDA is licensed under Mulan PSL v2.
// ***************************************************************************************
#pragma once

#include <map>
#include <set>
#include <string>
#include <vector>

#include "LvsCore.hpp"

namespace ilvs {

struct LayoutRect
{
  int32_t lx = 0;
  int32_t ly = 0;
  int32_t ux = 0;
  int32_t uy = 0;
};

struct LayoutShape
{
  std::string id;
  std::string net_name;
  std::string layer;
  LayoutRect rect;
};

struct LayoutVia
{
  std::string id;
  std::string net_name;
  std::string lower_layer;
  std::string upper_layer;
  LayoutRect lower_rect;
  LayoutRect upper_rect;
};

struct LayoutPin
{
  std::string id;
  std::string instance_name;
  std::string cell_type;
  std::string pin_name;
  std::string expected_net;
  std::string layer;
  LayoutRect rect;
};

struct LayoutConnectivitySnapshot
{
  std::string provenance_id = "layout_snapshot";
  std::set<std::string> supported_layers;
  std::vector<LayoutShape> shapes;
  std::vector<LayoutVia> vias;
  std::vector<LayoutPin> pins;
};

struct LayoutExtractionStats
{
  int64_t shape_count = 0;
  int64_t via_count = 0;
  int64_t pin_count = 0;
  int64_t component_count = 0;
  int64_t unattached_pin_count = 0;
  int64_t conflicting_owner_count = 0;
};

struct LayoutExtractionResult
{
  LvsGraph graph;
  LayoutExtractionStats stats;
};

auto extractLayoutConnectivityGraph(const LayoutConnectivitySnapshot& snapshot) -> LayoutExtractionResult;

}  // namespace ilvs
