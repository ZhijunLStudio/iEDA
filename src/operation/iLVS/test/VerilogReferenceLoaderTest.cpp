// ***************************************************************************************
// Copyright (c) 2026-2030 Southeast University
// Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
//
// iEDA is licensed under Mulan PSL v2.
// ***************************************************************************************

#include "VerilogReferenceLoader.hpp"

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

void parsesNamedGateLevelNetlist()
{
  const std::string verilog = R"(
module top(input a, input b, output y);
  wire n1;
  NAND2X1 U1 (.A(a), .B(b), .Y(n1));
  INVX1 U2 (.A(n1), .Y(y));
endmodule
)";
  const ilvs::LvsGraph graph = ilvs::loadVerilogReferenceGraph(verilog, {.top_module = "top"});
  expect(graph.provenance_id == "top", "top module provenance missing");
  expect(countKind(graph, ilvs::VertexKind::kInstance) == 2, "instance count mismatch");
  expect(countKind(graph, ilvs::VertexKind::kPin) == 5, "pin count mismatch");
  expect(countKind(graph, ilvs::VertexKind::kNet) == 4, "net count mismatch");
  expect(graph.coverage.checked_cells.contains("NAND2X1"), "NAND2X1 coverage missing");
  expect(graph.coverage.checked_cells.contains("INVX1"), "INVX1 coverage missing");
}

void rejectsUnsupportedAssign()
{
  bool rejected = false;
  try {
    (void) ilvs::loadVerilogReferenceGraph("module top(input a, output y); assign y = a; endmodule");
  } catch (const std::exception&) {
    rejected = true;
  }
  expect(rejected, "assign must be unsupported instead of silently skipped");
}

}  // namespace

void runVerilogReferenceLoaderTests()
{
  parsesNamedGateLevelNetlist();
  rejectsUnsupportedAssign();
}
