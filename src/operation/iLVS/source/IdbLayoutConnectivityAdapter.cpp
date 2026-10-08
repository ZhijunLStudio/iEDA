// ***************************************************************************************
// Copyright (c) 2026-2030 Southeast University
// Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
//
// iEDA is licensed under Mulan PSL v2.
// ***************************************************************************************

#include "IdbLayoutConnectivityAdapter.hpp"

#include "IdbDesign.h"
#include "IdbInstance.h"
#include "IdbLayer.h"
#include "IdbLayerShape.h"
#include "IdbNet.h"
#include "IdbPins.h"
#include "IdbRegularWire.h"
#include "IdbVias.h"

namespace ilvs {
namespace {

auto rectFromIdb(idb::IdbRect& rect) -> LayoutRect
{
  return {rect.get_low_x(), rect.get_low_y(), rect.get_high_x(), rect.get_high_y()};
}

auto rectFromIdb(idb::IdbRect* rect) -> LayoutRect
{
  if (rect == nullptr) {
    return {};
  }
  return {rect->get_low_x(), rect->get_low_y(), rect->get_high_x(), rect->get_high_y()};
}

auto layerName(idb::IdbLayer* layer) -> std::string
{
  return layer == nullptr ? "" : layer->get_name();
}

auto instanceName(idb::IdbPin* pin) -> std::string
{
  return pin != nullptr && pin->get_instance() != nullptr ? pin->get_instance()->get_name() : "";
}

auto cellType(idb::IdbPin* pin) -> std::string
{
  if (pin == nullptr || pin->get_instance() == nullptr || pin->get_instance()->get_cell_master() == nullptr) {
    return {};
  }
  return pin->get_instance()->get_cell_master()->get_name();
}

auto shouldIncludeNet(idb::IdbNet* net, bool include_pdn_nets) -> bool
{
  if (net == nullptr) {
    return false;
  }
  return include_pdn_nets || !net->is_pdn();
}

}  // namespace

auto makeLayoutSnapshotFromIdb(idb::IdbDesign& design, const IdbLayoutExtractionOptions& options) -> LayoutConnectivitySnapshot
{
  LayoutConnectivitySnapshot snapshot;
  snapshot.provenance_id = design.get_design_name().empty() ? "idb_layout" : design.get_design_name();
  snapshot.supported_layers = options.supported_layers;

  if (design.get_net_list() != nullptr) {
    for (idb::IdbNet* net : design.get_net_list()->get_net_list()) {
      if (!shouldIncludeNet(net, options.include_pdn_nets)) {
        continue;
      }
      const std::string net_name = net->get_net_name();
      if (net->get_wire_list() == nullptr) {
        continue;
      }
      int wire_index = 0;
      for (idb::IdbRegularWire* wire : net->get_wire_list()->get_wire_list()) {
        if (wire == nullptr) {
          continue;
        }
        int segment_index = 0;
        for (idb::IdbRegularWireSegment* segment : wire->get_segment_list()) {
          if (segment == nullptr) {
            continue;
          }
          const std::string segment_id = net_name + ":wire" + std::to_string(wire_index) + ":seg" + std::to_string(segment_index);
          if (segment->is_wire() || segment->is_rect()) {
            idb::IdbRect rect = segment->get_segment_rect();
            snapshot.shapes.push_back({segment_id, net_name, segment->get_layer_name(), rectFromIdb(rect)});
          }
          int via_index = 0;
          for (idb::IdbVia* via : segment->get_via_list()) {
            if (via == nullptr) {
              continue;
            }
            idb::IdbRect lower = via->get_bottom_bounding_box();
            idb::IdbRect upper = via->get_top_bounding_box();
            snapshot.vias.push_back({segment_id + ":via" + std::to_string(via_index),
                                     net_name,
                                     layerName(via->get_bottom_layer_shape().get_layer()),
                                     layerName(via->get_top_layer_shape().get_layer()),
                                     rectFromIdb(lower),
                                     rectFromIdb(upper)});
            ++via_index;
          }
          ++segment_index;
        }
        ++wire_index;
      }
    }
  }

  if (design.get_instance_list() != nullptr) {
    for (idb::IdbInstance* instance : design.get_instance_list()->get_instance_list()) {
      if (instance == nullptr || instance->get_pin_list() == nullptr) {
        continue;
      }
      for (idb::IdbPin* pin : instance->get_pin_list()->get_pin_list()) {
        if (pin == nullptr) {
          continue;
        }
        const std::string expected_net = pin->get_net() == nullptr ? pin->get_net_name() : pin->get_net()->get_net_name();
        for (idb::IdbLayerShape* layer_shape : pin->get_port_box_list()) {
          if (layer_shape == nullptr) {
            continue;
          }
          int rect_index = 0;
          for (idb::IdbRect* rect : layer_shape->get_rect_list()) {
            snapshot.pins.push_back({instanceName(pin) + "/" + pin->get_pin_name() + ":" + std::to_string(rect_index),
                                     instanceName(pin),
                                     cellType(pin),
                                     pin->get_pin_name(),
                                     expected_net,
                                     layerName(layer_shape->get_layer()),
                                     rectFromIdb(rect)});
            ++rect_index;
          }
        }
      }
    }
  }

  return snapshot;
}

auto extractLayoutConnectivityGraphFromIdb(idb::IdbDesign& design, const IdbLayoutExtractionOptions& options) -> LayoutExtractionResult
{
  return extractLayoutConnectivityGraph(makeLayoutSnapshotFromIdb(design, options));
}

}  // namespace ilvs
