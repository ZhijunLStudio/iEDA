// ***************************************************************************************
// Copyright (c) 2026-2030 Southeast University
// Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
//
// iEDA is licensed under Mulan PSL v2.
// ***************************************************************************************

#include "LayoutConnectivityExtractor.hpp"

#include <algorithm>
#include <map>
#include <numeric>
#include <set>
#include <stdexcept>

namespace ilvs {
namespace {

auto normalize(LayoutRect rect) -> LayoutRect
{
  if (rect.lx > rect.ux) {
    std::swap(rect.lx, rect.ux);
  }
  if (rect.ly > rect.uy) {
    std::swap(rect.ly, rect.uy);
  }
  return rect;
}

auto overlaps(LayoutRect lhs, LayoutRect rhs) -> bool
{
  lhs = normalize(lhs);
  rhs = normalize(rhs);
  return lhs.lx <= rhs.ux && rhs.lx <= lhs.ux && lhs.ly <= rhs.uy && rhs.ly <= lhs.uy;
}

class DisjointSet
{
 public:
  explicit DisjointSet(std::size_t size) : _parent(size), _rank(size, 0) { std::iota(_parent.begin(), _parent.end(), 0); }

  auto find(std::size_t value) -> std::size_t
  {
    if (_parent.at(value) != value) {
      _parent[value] = find(_parent[value]);
    }
    return _parent[value];
  }

  void unite(std::size_t lhs, std::size_t rhs)
  {
    lhs = find(lhs);
    rhs = find(rhs);
    if (lhs == rhs) {
      return;
    }
    if (_rank[lhs] < _rank[rhs]) {
      std::swap(lhs, rhs);
    }
    _parent[rhs] = lhs;
    if (_rank[lhs] == _rank[rhs]) {
      ++_rank[lhs];
    }
  }

 private:
  std::vector<std::size_t> _parent;
  std::vector<int> _rank;
};

struct ConductiveItem
{
  std::string id;
  std::string net_name;
  std::string layer;
  LayoutRect rect;
};

auto isSupported(const std::set<std::string>& supported_layers, const std::string& layer) -> bool
{
  return supported_layers.empty() || supported_layers.contains(layer);
}

auto componentNetName(const std::vector<std::size_t>& item_ids, const std::vector<ConductiveItem>& items, const std::vector<LayoutPin>& pins,
                      const std::vector<std::size_t>& pin_ids) -> std::string
{
  std::set<std::string> names;
  for (const std::size_t item_id : item_ids) {
    if (!items.at(item_id).net_name.empty()) {
      names.insert(items.at(item_id).net_name);
    }
  }
  for (const std::size_t pin_id : pin_ids) {
    if (!pins.at(pin_id).expected_net.empty()) {
      names.insert(pins.at(pin_id).expected_net);
    }
  }
  if (names.size() == 1) {
    return *names.begin();
  }
  return {};
}

}  // namespace

auto extractLayoutConnectivityGraph(const LayoutConnectivitySnapshot& snapshot) -> LayoutExtractionResult
{
  LayoutExtractionResult result;
  result.graph.provenance_id = snapshot.provenance_id;
  result.stats.shape_count = static_cast<int64_t>(snapshot.shapes.size());
  result.stats.via_count = static_cast<int64_t>(snapshot.vias.size());
  result.stats.pin_count = static_cast<int64_t>(snapshot.pins.size());

  std::vector<ConductiveItem> items;
  for (const auto& shape : snapshot.shapes) {
    if (!isSupported(snapshot.supported_layers, shape.layer)) {
      result.graph.coverage.unsupported_layers.insert(shape.layer);
      continue;
    }
    result.graph.coverage.checked_layers.insert(shape.layer);
    items.push_back({shape.id, shape.net_name, shape.layer, normalize(shape.rect)});
  }
  for (const auto& via : snapshot.vias) {
    if (!isSupported(snapshot.supported_layers, via.lower_layer)) {
      result.graph.coverage.unsupported_layers.insert(via.lower_layer);
    }
    if (!isSupported(snapshot.supported_layers, via.upper_layer)) {
      result.graph.coverage.unsupported_layers.insert(via.upper_layer);
    }
    if (!isSupported(snapshot.supported_layers, via.lower_layer) || !isSupported(snapshot.supported_layers, via.upper_layer)) {
      continue;
    }
    result.graph.coverage.checked_layers.insert(via.lower_layer);
    result.graph.coverage.checked_layers.insert(via.upper_layer);
    items.push_back({via.id + ":lower", via.net_name, via.lower_layer, normalize(via.lower_rect)});
    items.push_back({via.id + ":upper", via.net_name, via.upper_layer, normalize(via.upper_rect)});
  }

  DisjointSet dsu(items.size());
  for (std::size_t lhs = 0; lhs < items.size(); ++lhs) {
    for (std::size_t rhs = lhs + 1; rhs < items.size(); ++rhs) {
      if (items[lhs].layer == items[rhs].layer && overlaps(items[lhs].rect, items[rhs].rect)) {
        dsu.unite(lhs, rhs);
      }
    }
  }
  for (std::size_t index = 0; index + 1 < items.size(); ++index) {
    const auto split = items[index].id.rfind(":lower");
    if (split != std::string::npos && items[index + 1].id == items[index].id.substr(0, split) + ":upper") {
      dsu.unite(index, index + 1);
    }
  }

  std::map<std::size_t, std::vector<std::size_t>> items_by_component;
  for (std::size_t index = 0; index < items.size(); ++index) {
    items_by_component[dsu.find(index)].push_back(index);
  }

  std::map<std::string, std::string> instance_type_by_name;
  std::map<std::size_t, std::vector<std::size_t>> pins_by_component;
  for (std::size_t pin_id = 0; pin_id < snapshot.pins.size(); ++pin_id) {
    const auto& pin = snapshot.pins[pin_id];
    if (!pin.cell_type.empty() && !pin.instance_name.empty()) {
      instance_type_by_name[pin.instance_name] = pin.cell_type;
      result.graph.coverage.checked_cells.insert(pin.cell_type);
    }
    if (!isSupported(snapshot.supported_layers, pin.layer)) {
      result.graph.coverage.unsupported_layers.insert(pin.layer);
      ++result.stats.unattached_pin_count;
      continue;
    }
    result.graph.coverage.checked_layers.insert(pin.layer);
    bool attached = false;
    for (const auto& [component, item_ids] : items_by_component) {
      for (const std::size_t item_id : item_ids) {
        if (items[item_id].layer == pin.layer && overlaps(items[item_id].rect, pin.rect)) {
          pins_by_component[component].push_back(pin_id);
          attached = true;
          break;
        }
      }
      if (attached) {
        break;
      }
    }
    if (!attached) {
      ++result.stats.unattached_pin_count;
      result.graph.coverage.unsupported_cells.insert(pin.instance_name + "/" + pin.pin_name + ":no_anchor");
    }
  }

  for (const auto& [inst_name, cell_type] : instance_type_by_name) {
    result.graph.vertices.push_back({"inst:" + inst_name, VertexKind::kInstance, inst_name, cell_type, ""});
  }

  for (const auto& [component, item_ids] : items_by_component) {
    const auto pin_iter = pins_by_component.find(component);
    const std::vector<std::size_t> pin_ids = pin_iter == pins_by_component.end() ? std::vector<std::size_t>{} : pin_iter->second;
    const std::string owner_net = componentNetName(item_ids, items, snapshot.pins, pin_ids);
    const std::string net_id = owner_net.empty() ? "component:" + std::to_string(component) : "net:" + owner_net;
    if (owner_net.empty()) {
      ++result.stats.conflicting_owner_count;
    }
    result.graph.vertices.push_back({net_id, VertexKind::kNet, owner_net.empty() ? net_id : owner_net, "", ""});
    for (const std::size_t pin_id : pin_ids) {
      const LayoutPin& pin = snapshot.pins.at(pin_id);
      const std::string pin_vertex_id = "pin:" + pin.instance_name + "/" + pin.pin_name;
      result.graph.vertices.push_back({pin_vertex_id, VertexKind::kPin, pin.pin_name, "", pin.pin_name});
      result.graph.edges.push_back({"inst:" + pin.instance_name, pin_vertex_id, EdgeKind::kPinOfInstance});
      result.graph.edges.push_back({pin_vertex_id, net_id, EdgeKind::kPinOnNet});
    }
  }
  result.stats.component_count = static_cast<int64_t>(items_by_component.size());
  return result;
}

}  // namespace ilvs
