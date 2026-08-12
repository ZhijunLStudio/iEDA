// ***************************************************************************************
// Copyright (c) 2026-2030 Southeast University
// Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
//
// iEDA is licensed under Mulan PSL v2.
// ***************************************************************************************

#include "LayoutConnectivityExtractor.hpp"

#include <stdexcept>
#include <string>

namespace {

void expect(bool condition, const std::string& message)
{
  if (!condition) {
    throw std::runtime_error(message);
  }
}

auto countKind(const ilvs::LvsGraph& graph, ilvs::VertexKind kind) -> int
{
  int count = 0;
  for (const auto& vertex : graph.vertices) {
    if (vertex.kind == kind) {
      ++count;
    }
  }
  return count;
}

void extractsShapeOverlapViaAndPinAttach()
{
  ilvs::LayoutConnectivitySnapshot snapshot;
  snapshot.provenance_id = "idb_fixture";
  snapshot.supported_layers = {"M1", "M2"};
  snapshot.shapes.push_back({"s1", "N1", "M1", {0, 0, 10, 10}});
  snapshot.shapes.push_back({"s2", "N1", "M1", {10, 0, 20, 10}});
  snapshot.vias.push_back({"v1", "N1", "M1", "M2", {18, 0, 22, 10}, {18, 0, 22, 10}});
  snapshot.shapes.push_back({"s3", "N1", "M2", {20, 0, 30, 10}});
  snapshot.pins.push_back({"p1", "U1", "INVX1", "A", "N1", "M1", {1, 1, 3, 3}});
  snapshot.pins.push_back({"p2", "U2", "INVX1", "Y", "N1", "M2", {25, 1, 28, 3}});

  const ilvs::LayoutExtractionResult result = ilvs::extractLayoutConnectivityGraph(snapshot);
  expect(result.stats.component_count == 1, "overlap/via should create one component");
  expect(result.stats.unattached_pin_count == 0, "pins should attach to conductor");
  expect(countKind(result.graph, ilvs::VertexKind::kInstance) == 2, "instance count mismatch");
  expect(countKind(result.graph, ilvs::VertexKind::kPin) == 2, "pin count mismatch");
  expect(countKind(result.graph, ilvs::VertexKind::kNet) == 1, "net count mismatch");
}

void reportsUnsupportedLayerAndUnattachedPin()
{
  ilvs::LayoutConnectivitySnapshot snapshot;
  snapshot.provenance_id = "unsupported_fixture";
  snapshot.supported_layers = {"M1"};
  snapshot.shapes.push_back({"s1", "N1", "M9", {0, 0, 10, 10}});
  snapshot.pins.push_back({"p1", "U1", "INVX1", "A", "N1", "M1", {1, 1, 3, 3}});

  const ilvs::LayoutExtractionResult result = ilvs::extractLayoutConnectivityGraph(snapshot);
  expect(result.graph.coverage.unsupported_layers.contains("M9"), "unsupported layer should be reported");
  expect(result.graph.coverage.unsupported_cells.contains("U1/A:no_anchor"), "unattached pin should be reported");
  expect(result.stats.unattached_pin_count == 1, "unattached pin count mismatch");
}

}  // namespace

void runLayoutConnectivityExtractorTests()
{
  extractsShapeOverlapViaAndPinAttach();
  reportsUnsupportedLayerAndUnattachedPin();
}
