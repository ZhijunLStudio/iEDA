// ***************************************************************************************
// Copyright (c) 2026-2030 Southeast University
// Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
//
// iEDA is licensed under Mulan PSL v2.
// ***************************************************************************************

#include "ILVSAPI.hpp"

#include <exception>
#include <iostream>
#include <stdexcept>
#include <string>

namespace {

constexpr char kRefHash[] = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa";
constexpr char kExtHash[] = "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb";
constexpr char kTechHash[] = "cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc";
constexpr char kBinaryHash[] = "dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd";

void expect(bool condition, const std::string& message)
{
  if (!condition) {
    throw std::runtime_error(message);
  }
}

auto manifest() -> ilvs::LvsManifest
{
  return {{"ref.v", kRefHash, "reference_netlist"},
          {"layout.idb", kExtHash, "layout_database"},
          {"tech.map", kTechHash, "tech_mapping"},
          {"iLVS", kBinaryHash, "ilvs_binary"}};
}

void addInstance(ilvs::LvsGraph& graph, const std::string& id, const std::string& name, const std::string& type)
{
  graph.vertices.push_back({id, ilvs::VertexKind::kInstance, name, type, ""});
  graph.coverage.checked_cells.insert(type);
}

void addNet(ilvs::LvsGraph& graph, const std::string& id, const std::string& name)
{
  graph.vertices.push_back({id, ilvs::VertexKind::kNet, name, "", ""});
}

void addPin(ilvs::LvsGraph& graph, const std::string& inst_id, const std::string& pin_id, const std::string& name,
            const std::string& role, const std::string& net_id)
{
  graph.vertices.push_back({pin_id, ilvs::VertexKind::kPin, name, "", role});
  graph.edges.push_back({inst_id, pin_id, ilvs::EdgeKind::kPinOfInstance});
  graph.edges.push_back({pin_id, net_id, ilvs::EdgeKind::kPinOnNet});
}

auto makeSingleInverter(const std::string& prefix, const std::string& inst_name) -> ilvs::LvsGraph
{
  ilvs::LvsGraph graph;
  graph.provenance_id = prefix;
  graph.coverage.checked_layers.insert("M1");
  addInstance(graph, prefix + "_i0", inst_name, "INVX1");
  addNet(graph, prefix + "_n_a", prefix + "_net_a");
  addNet(graph, prefix + "_n_y", prefix + "_net_y");
  addPin(graph, prefix + "_i0", prefix + "_p_a", "A", "A", prefix + "_n_a");
  addPin(graph, prefix + "_i0", prefix + "_p_y", "Y", "Y", prefix + "_n_y");
  return graph;
}

auto makeChain(const std::string& prefix) -> ilvs::LvsGraph
{
  ilvs::LvsGraph graph;
  graph.provenance_id = prefix;
  graph.coverage.checked_layers.insert("M1");
  addInstance(graph, prefix + "_i1", "U1", "INVX1");
  addInstance(graph, prefix + "_i2", "U2", "INVX1");
  addNet(graph, prefix + "_n_in", "IN");
  addNet(graph, prefix + "_n_mid", "MID");
  addNet(graph, prefix + "_n_out", "OUT");
  addPin(graph, prefix + "_i1", prefix + "_p1_a", "A", "A", prefix + "_n_in");
  addPin(graph, prefix + "_i1", prefix + "_p1_y", "Y", "Y", prefix + "_n_mid");
  addPin(graph, prefix + "_i2", prefix + "_p2_a", "A", "A", prefix + "_n_mid");
  addPin(graph, prefix + "_i2", prefix + "_p2_y", "Y", "Y", prefix + "_n_out");
  return graph;
}

auto makeSymmetricPair(const std::string& prefix) -> ilvs::LvsGraph
{
  ilvs::LvsGraph graph;
  graph.provenance_id = prefix;
  graph.coverage.checked_layers.insert("M1");
  addInstance(graph, prefix + "_i1", "U_LEFT", "INVX1");
  addInstance(graph, prefix + "_i2", "U_RIGHT", "INVX1");
  addNet(graph, prefix + "_n_a1", "A1");
  addNet(graph, prefix + "_n_y1", "Y1");
  addNet(graph, prefix + "_n_a2", "A2");
  addNet(graph, prefix + "_n_y2", "Y2");
  addPin(graph, prefix + "_i1", prefix + "_p1_a", "A", "A", prefix + "_n_a1");
  addPin(graph, prefix + "_i1", prefix + "_p1_y", "Y", "Y", prefix + "_n_y1");
  addPin(graph, prefix + "_i2", prefix + "_p2_a", "A", "A", prefix + "_n_a2");
  addPin(graph, prefix + "_i2", prefix + "_p2_y", "Y", "Y", prefix + "_n_y2");
  return graph;
}

auto makeOpenChain(const std::string& prefix) -> ilvs::LvsGraph
{
  ilvs::LvsGraph graph;
  graph.provenance_id = prefix;
  graph.coverage.checked_layers.insert("M1");
  addInstance(graph, prefix + "_i1", "U1", "INVX1");
  addInstance(graph, prefix + "_i2", "U2", "INVX1");
  addNet(graph, prefix + "_n_in", "IN");
  addNet(graph, prefix + "_n_mid_a", "MID_A");
  addNet(graph, prefix + "_n_mid_b", "MID_B");
  addNet(graph, prefix + "_n_out", "OUT");
  addPin(graph, prefix + "_i1", prefix + "_p1_a", "A", "A", prefix + "_n_in");
  addPin(graph, prefix + "_i1", prefix + "_p1_y", "Y", "Y", prefix + "_n_mid_a");
  addPin(graph, prefix + "_i2", prefix + "_p2_a", "A", "A", prefix + "_n_mid_b");
  addPin(graph, prefix + "_i2", prefix + "_p2_y", "Y", "Y", prefix + "_n_out");
  return graph;
}

auto makeShortChain(const std::string& prefix) -> ilvs::LvsGraph
{
  ilvs::LvsGraph graph;
  graph.provenance_id = prefix;
  graph.coverage.checked_layers.insert("M1");
  addInstance(graph, prefix + "_i1", "U1", "INVX1");
  addInstance(graph, prefix + "_i2", "U2", "INVX1");
  addNet(graph, prefix + "_n_merged", "MERGED");
  addNet(graph, prefix + "_n_out", "OUT");
  addPin(graph, prefix + "_i1", prefix + "_p1_a", "A", "A", prefix + "_n_merged");
  addPin(graph, prefix + "_i1", prefix + "_p1_y", "Y", "Y", prefix + "_n_merged");
  addPin(graph, prefix + "_i2", prefix + "_p2_a", "A", "A", prefix + "_n_merged");
  addPin(graph, prefix + "_i2", prefix + "_p2_y", "Y", "Y", prefix + "_n_out");
  return graph;
}

auto makePinSwapGraph(bool swapped) -> ilvs::LvsGraph
{
  ilvs::LvsGraph graph;
  graph.provenance_id = swapped ? "swap_ext" : "swap_ref";
  graph.coverage.checked_layers.insert("M1");
  addInstance(graph, "nand_i0", "U_NAND", "NAND2X1");
  addNet(graph, "nand_n_a", "A_NET");
  addNet(graph, "nand_n_b", "B_NET");
  addNet(graph, "nand_n_y", "Y_NET");
  addPin(graph, "nand_i0", "nand_p_a", "A", swapped ? "B" : "A", "nand_n_a");
  addPin(graph, "nand_i0", "nand_p_b", "B", swapped ? "A" : "B", "nand_n_b");
  addPin(graph, "nand_i0", "nand_p_y", "Y", "Y", "nand_n_y");
  return graph;
}

auto run(const ilvs::LvsGraph& reference_graph, const ilvs::LvsGraph& extracted_graph, const ilvs::LvsOptions& options = {})
    -> ilvs::LvsResult
{
  const ilvs::ILVSAPI api;
  return api.run(reference_graph, extracted_graph, manifest(), options);
}

auto hasDiff(const ilvs::LvsResult& result, ilvs::DiffKind kind) -> bool
{
  for (const auto& diff : result.diffs) {
    if (diff.kind == kind) {
      return true;
    }
  }
  return false;
}

void cleanRenameIgnoresNames()
{
  const ilvs::LvsResult result = run(makeSingleInverter("ref", "U1"), makeSingleInverter("ext", "renamed_inst"));
  expect(result.state == ilvs::LvsState::kClean, "renamed clean graph should be CLEAN");
  expect(result.exit_code == ilvs::LvsExitCode::kClean, "CLEAN must exit 0");
}

void cleanSymmetricPartition()
{
  const ilvs::LvsResult result = run(makeSymmetricPair("ref"), makeSymmetricPair("ext"));
  expect(result.state == ilvs::LvsState::kClean, "symmetric clean graph should be CLEAN");
}

void detectsOpen()
{
  const ilvs::LvsResult result = run(makeChain("ref"), makeOpenChain("ext"));
  expect(result.state == ilvs::LvsState::kMismatch, "open graph should be MISMATCH");
  expect(hasDiff(result, ilvs::DiffKind::kOpen), "open diff missing");
}

void detectsShort()
{
  const ilvs::LvsResult result = run(makeChain("ref"), makeShortChain("ext"));
  expect(result.state == ilvs::LvsState::kMismatch, "short graph should be MISMATCH");
  expect(hasDiff(result, ilvs::DiffKind::kShort), "short diff missing");
}

void detectsMissing()
{
  const ilvs::LvsResult result = run(makeChain("ref"), makeSingleInverter("ext", "U1"));
  expect(result.state == ilvs::LvsState::kMismatch, "missing graph should be MISMATCH");
  expect(hasDiff(result, ilvs::DiffKind::kMissing), "missing diff missing");
}

void detectsExtra()
{
  const ilvs::LvsResult result = run(makeSingleInverter("ref", "U1"), makeChain("ext"));
  expect(result.state == ilvs::LvsState::kMismatch, "extra graph should be MISMATCH");
  expect(hasDiff(result, ilvs::DiffKind::kExtra), "extra diff missing");
}

void detectsPinSwapWithoutEquivalence()
{
  const ilvs::LvsResult result = run(makePinSwapGraph(false), makePinSwapGraph(true));
  expect(result.state == ilvs::LvsState::kMismatch, "pin swap should be MISMATCH without equivalence");
  expect(hasDiff(result, ilvs::DiffKind::kPinSwap), "pin_swap diff missing");
}

void acceptsExplicitEquivalentPins()
{
  ilvs::LvsOptions options;
  options.equivalent_pin_groups["NAND2X1"].push_back({"A", "B"});
  const ilvs::LvsResult result = run(makePinSwapGraph(false), makePinSwapGraph(true), options);
  expect(result.state == ilvs::LvsState::kClean, "explicit equivalent pins should be CLEAN");
  expect(!hasDiff(result, ilvs::DiffKind::kPinSwap), "equivalent pins should not emit pin_swap");
}

void unsupportedIsNonClean()
{
  ilvs::LvsGraph reference_graph = makeSingleInverter("ref", "U1");
  ilvs::LvsGraph extracted_graph = makeSingleInverter("ext", "U1");
  extracted_graph.coverage.unsupported_layers.insert("M99");
  const ilvs::LvsResult result = run(reference_graph, extracted_graph);
  expect(result.state == ilvs::LvsState::kUnsupported, "unsupported coverage should be UNSUPPORTED");
  expect(result.exit_code == ilvs::LvsExitCode::kUnsupported, "UNSUPPORTED exit code mismatch");
}

void budgetExhaustionIsInconclusive()
{
  ilvs::LvsOptions options;
  options.graph_search_budget = 0;
  const ilvs::LvsResult result = run(makeSingleInverter("ref", "U1"), makeSingleInverter("ext", "U1"), options);
  expect(result.state == ilvs::LvsState::kInconclusive, "budget exhaustion should be INCONCLUSIVE");
  expect(result.exit_code == ilvs::LvsExitCode::kInconclusive, "INCONCLUSIVE exit code mismatch");
}

void manifestRejectsSharedReferenceAndLayout()
{
  ilvs::LvsManifest bad_manifest = manifest();
  bad_manifest.layout.sha256 = bad_manifest.reference.sha256;
  const ilvs::ILVSAPI api;
  const ilvs::LvsResult result = api.run(makeSingleInverter("ref", "U1"), makeSingleInverter("ext", "U1"), bad_manifest);
  expect(result.state == ilvs::LvsState::kError, "shared manifest source should be ERROR");
  expect(result.exit_code == ilvs::LvsExitCode::kInputError, "shared manifest source should be input error");
}

void summaryJsonIsStable()
{
  const ilvs::LvsResult lhs = run(makeChain("ref"), makeOpenChain("ext"));
  const ilvs::LvsResult rhs = run(makeChain("ref"), makeOpenChain("ext"));
  expect(ilvs::resultToJson(lhs).dump(2) == ilvs::resultToJson(rhs).dump(2), "summary JSON should be stable");
}

}  // namespace

auto main() -> int
{
  try {
    cleanRenameIgnoresNames();
    cleanSymmetricPartition();
    detectsOpen();
    detectsShort();
    detectsMissing();
    detectsExtra();
    detectsPinSwapWithoutEquivalence();
    acceptsExplicitEquivalentPins();
    unsupportedIsNonClean();
    budgetExhaustionIsInconclusive();
    manifestRejectsSharedReferenceAndLayout();
    summaryJsonIsStable();
  } catch (const std::exception& error) {
    std::cerr << error.what() << '\n';
    return 1;
  }
  std::cout << "iLVS core tests passed\n";
  return 0;
}
