#include "LvsCore.hpp"

#include <algorithm>
#include <cctype>
#include <fstream>
#include <sstream>
#include <stdexcept>
#include <tuple>

namespace ilvs {
namespace {

auto isSha256(const std::string& value) -> bool
{
  if (value.size() != 64) {
    return false;
  }
  return std::all_of(value.begin(), value.end(), [](unsigned char ch) { return std::isxdigit(ch) != 0; });
}

auto sortedVector(std::vector<std::string> values) -> std::vector<std::string>
{
  std::sort(values.begin(), values.end());
  values.erase(std::unique(values.begin(), values.end()), values.end());
  return values;
}

auto setToJson(const std::set<std::string>& values) -> nlohmann::ordered_json
{
  nlohmann::ordered_json json = nlohmann::ordered_json::array();
  for (const auto& value : values) {
    json.push_back(value);
  }
  return json;
}

auto vectorToJson(const std::vector<std::string>& values) -> nlohmann::ordered_json
{
  nlohmann::ordered_json json = nlohmann::ordered_json::array();
  for (const auto& value : values) {
    json.push_back(value);
  }
  return json;
}

auto identityToJson(const LvsInputIdentity& identity) -> nlohmann::ordered_json
{
  return {{"path", identity.path}, {"sha256", identity.sha256}, {"object_id", identity.object_id}};
}

auto coverageToJson(const LvsCoverage& coverage) -> nlohmann::ordered_json
{
  return {{"checked_layers", setToJson(coverage.checked_layers)},
          {"unsupported_layers", setToJson(coverage.unsupported_layers)},
          {"checked_cells", setToJson(coverage.checked_cells)},
          {"unsupported_cells", setToJson(coverage.unsupported_cells)}};
}

auto graphCountsToJson(const LvsGraph& graph) -> nlohmann::ordered_json
{
  int64_t instance_count = 0;
  int64_t pin_count = 0;
  int64_t net_count = 0;
  for (const auto& vertex : graph.vertices) {
    switch (vertex.kind) {
      case VertexKind::kInstance:
        ++instance_count;
        break;
      case VertexKind::kPin:
        ++pin_count;
        break;
      case VertexKind::kNet:
        ++net_count;
        break;
    }
  }
  return {{"vertices", graph.vertices.size()},
          {"edges", graph.edges.size()},
          {"instances", instance_count},
          {"pins", pin_count},
          {"nets", net_count}};
}

auto kindOrder(DiffKind kind) -> int
{
  switch (kind) {
    case DiffKind::kUnsupported:
      return 0;
    case DiffKind::kInconclusive:
      return 1;
    case DiffKind::kShort:
      return 2;
    case DiffKind::kOpen:
      return 3;
    case DiffKind::kMissing:
      return 4;
    case DiffKind::kExtra:
      return 5;
    case DiffKind::kPinSwap:
      return 6;
  }
  return 100;
}

auto parseVertexKind(const std::string& value) -> VertexKind
{
  if (value == "instance") {
    return VertexKind::kInstance;
  }
  if (value == "pin") {
    return VertexKind::kPin;
  }
  if (value == "net") {
    return VertexKind::kNet;
  }
  throw std::runtime_error("unknown vertex kind: " + value);
}

auto parseEdgeKind(const std::string& value) -> EdgeKind
{
  if (value == "pin_of_instance") {
    return EdgeKind::kPinOfInstance;
  }
  if (value == "pin_on_net") {
    return EdgeKind::kPinOnNet;
  }
  throw std::runtime_error("unknown edge kind: " + value);
}

auto normalizedPinRole(const std::string& cell_type, const std::string& role, const LvsOptions& options) -> std::string
{
  const auto cell_iter = options.equivalent_pin_groups.find(cell_type);
  if (cell_iter == options.equivalent_pin_groups.end()) {
    return role;
  }
  for (std::size_t group_index = 0; group_index < cell_iter->second.size(); ++group_index) {
    const auto& group = cell_iter->second[group_index];
    if (std::find(group.begin(), group.end(), role) != group.end()) {
      return "equiv:" + std::to_string(group_index);
    }
  }
  return role;
}

struct GraphIndex
{
  std::map<std::string, LvsVertex> vertices_by_id;
  std::map<std::string, std::vector<std::string>> pin_ids_by_instance;
  std::map<std::string, std::vector<std::string>> pin_ids_by_net;
  std::map<std::string, std::string> instance_id_by_pin;
  std::map<std::string, std::string> net_id_by_pin;
};

auto buildIndex(const LvsGraph& graph) -> GraphIndex
{
  GraphIndex index;
  for (const auto& vertex : graph.vertices) {
    if (!index.vertices_by_id.emplace(vertex.id, vertex).second) {
      throw std::runtime_error("duplicate graph vertex id: " + vertex.id);
    }
  }
  for (const auto& edge : graph.edges) {
    const auto a_iter = index.vertices_by_id.find(edge.a);
    const auto b_iter = index.vertices_by_id.find(edge.b);
    if (a_iter == index.vertices_by_id.end() || b_iter == index.vertices_by_id.end()) {
      throw std::runtime_error("edge references missing vertex: " + edge.a + " " + edge.b);
    }
    const LvsVertex& a = a_iter->second;
    const LvsVertex& b = b_iter->second;
    if (edge.kind == EdgeKind::kPinOfInstance) {
      const bool a_is_inst_pin = a.kind == VertexKind::kInstance && b.kind == VertexKind::kPin;
      const bool b_is_inst_pin = b.kind == VertexKind::kInstance && a.kind == VertexKind::kPin;
      if (!a_is_inst_pin && !b_is_inst_pin) {
        throw std::runtime_error("pin_of_instance edge must connect instance and pin");
      }
      const std::string& instance_id = a_is_inst_pin ? a.id : b.id;
      const std::string& pin_id = a_is_inst_pin ? b.id : a.id;
      const auto owner_iter = index.instance_id_by_pin.find(pin_id);
      if (owner_iter != index.instance_id_by_pin.end() && owner_iter->second != instance_id) {
        throw std::runtime_error("pin belongs to multiple instances: " + pin_id);
      }
      index.pin_ids_by_instance[instance_id].push_back(pin_id);
      index.instance_id_by_pin[pin_id] = instance_id;
    } else {
      const bool a_is_net_pin = a.kind == VertexKind::kNet && b.kind == VertexKind::kPin;
      const bool b_is_net_pin = b.kind == VertexKind::kNet && a.kind == VertexKind::kPin;
      if (!a_is_net_pin && !b_is_net_pin) {
        throw std::runtime_error("pin_on_net edge must connect net and pin");
      }
      const std::string& net_id = a_is_net_pin ? a.id : b.id;
      const std::string& pin_id = a_is_net_pin ? b.id : a.id;
      const auto owner_iter = index.net_id_by_pin.find(pin_id);
      if (owner_iter != index.net_id_by_pin.end() && owner_iter->second != net_id) {
        throw std::runtime_error("pin belongs to multiple nets: " + pin_id);
      }
      index.pin_ids_by_net[net_id].push_back(pin_id);
      index.net_id_by_pin[pin_id] = net_id;
    }
  }
  for (const auto& [id, vertex] : index.vertices_by_id) {
    if (vertex.kind == VertexKind::kPin && (!index.instance_id_by_pin.contains(id) || !index.net_id_by_pin.contains(id))) {
      throw std::runtime_error("pin is missing instance or net ownership: " + id);
    }
  }
  for (auto& [_, pin_ids] : index.pin_ids_by_instance) {
    pin_ids = sortedVector(pin_ids);
  }
  for (auto& [_, pin_ids] : index.pin_ids_by_net) {
    pin_ids = sortedVector(pin_ids);
  }
  return index;
}

auto vertexTypeRoleKey(const LvsVertex& vertex, const LvsOptions& options) -> std::string
{
  return toString(vertex.kind) + "|" + vertex.type + "|" + normalizedPinRole(vertex.type, vertex.role, options);
}

auto pinRoleKey(const LvsVertex& pin, const GraphIndex& index, const LvsOptions& options) -> std::string
{
  const auto inst_iter = index.instance_id_by_pin.find(pin.id);
  std::string cell_type;
  if (inst_iter != index.instance_id_by_pin.end()) {
    cell_type = index.vertices_by_id.at(inst_iter->second).type;
  }
  return normalizedPinRole(cell_type, pin.role, options);
}

auto pinVertexKey(const LvsVertex& pin, const GraphIndex& index, const LvsOptions& options) -> std::string
{
  const auto inst_iter = index.instance_id_by_pin.find(pin.id);
  std::string cell_type;
  if (inst_iter != index.instance_id_by_pin.end()) {
    cell_type = index.vertices_by_id.at(inst_iter->second).type;
  }
  return toString(pin.kind) + "|" + cell_type + "|" + normalizedPinRole(cell_type, pin.role, options);
}

auto incidentSignature(const std::string& vertex_id, const GraphIndex& index, const LvsOptions& options) -> std::string
{
  const auto vertex_iter = index.vertices_by_id.find(vertex_id);
  if (vertex_iter == index.vertices_by_id.end()) {
    return {};
  }
  const LvsVertex& vertex = vertex_iter->second;
  std::vector<std::string> neighbor_keys;
  if (vertex.kind == VertexKind::kInstance) {
    const auto pin_iter = index.pin_ids_by_instance.find(vertex.id);
    if (pin_iter != index.pin_ids_by_instance.end()) {
      for (const auto& pin_id : pin_iter->second) {
        const auto pin = index.vertices_by_id.at(pin_id);
        const auto net_iter = index.net_id_by_pin.find(pin_id);
        const std::string net_degree = net_iter == index.net_id_by_pin.end()
                                           ? "0"
                                           : std::to_string(index.pin_ids_by_net.at(net_iter->second).size());
        neighbor_keys.push_back(pinVertexKey(pin, index, options) + "@net_degree:" + net_degree);
      }
    }
  } else if (vertex.kind == VertexKind::kNet) {
    const auto pin_iter = index.pin_ids_by_net.find(vertex.id);
    if (pin_iter != index.pin_ids_by_net.end()) {
      for (const auto& pin_id : pin_iter->second) {
        const auto& pin = index.vertices_by_id.at(pin_id);
        const auto inst_iter = index.instance_id_by_pin.find(pin_id);
        std::string inst_type;
        if (inst_iter != index.instance_id_by_pin.end()) {
          inst_type = index.vertices_by_id.at(inst_iter->second).type;
        }
        neighbor_keys.push_back(pinVertexKey(pin, index, options) + "@inst:" + inst_type);
      }
    }
  } else {
    const auto inst_iter = index.instance_id_by_pin.find(vertex.id);
    const auto net_iter = index.net_id_by_pin.find(vertex.id);
    neighbor_keys.push_back(inst_iter == index.instance_id_by_pin.end() ? "inst:" : "inst:" + index.vertices_by_id.at(inst_iter->second).type);
    neighbor_keys.push_back(net_iter == index.net_id_by_pin.end() ? "net_degree:0"
                                                                 : "net_degree:" + std::to_string(index.pin_ids_by_net.at(net_iter->second).size()));
  }
  std::sort(neighbor_keys.begin(), neighbor_keys.end());
  const std::string base_key = vertex.kind == VertexKind::kPin ? pinVertexKey(vertex, index, options) : vertexTypeRoleKey(vertex, options);
  std::ostringstream stream;
  stream << base_key << "|degree:" << neighbor_keys.size();
  for (const auto& key : neighbor_keys) {
    stream << "|" << key;
  }
  return stream.str();
}

auto partitionBySignature(const LvsGraph& graph, const GraphIndex& index, const LvsOptions& options) -> std::map<std::string, std::vector<std::string>>
{
  std::map<std::string, std::vector<std::string>> partitions;
  for (const auto& vertex : graph.vertices) {
    partitions[incidentSignature(vertex.id, index, options)].push_back(vertex.id);
  }
  for (auto& [_, ids] : partitions) {
    ids = sortedVector(ids);
  }
  return partitions;
}

auto cellPinKey(const LvsVertex& pin, const GraphIndex& index, const LvsOptions& options) -> std::string
{
  const auto inst_iter = index.instance_id_by_pin.find(pin.id);
  std::string cell_type;
  if (inst_iter != index.instance_id_by_pin.end()) {
    cell_type = index.vertices_by_id.at(inst_iter->second).type;
  }
  return cell_type + "|" + pinRoleKey(pin, index, options);
}

auto netSignature(const std::string& net_id, const GraphIndex& index, const LvsOptions& options) -> std::vector<std::string>
{
  std::vector<std::string> signature;
  const auto pin_iter = index.pin_ids_by_net.find(net_id);
  if (pin_iter == index.pin_ids_by_net.end()) {
    return signature;
  }
  signature.reserve(pin_iter->second.size());
  for (const auto& pin_id : pin_iter->second) {
    signature.push_back(cellPinKey(index.vertices_by_id.at(pin_id), index, options));
  }
  return sortedVector(signature);
}

auto pinByCellRole(const GraphIndex& index, const LvsOptions& options) -> std::map<std::string, std::vector<std::string>>
{
  std::map<std::string, std::vector<std::string>> pins_by_key;
  for (const auto& [id, vertex] : index.vertices_by_id) {
    if (vertex.kind == VertexKind::kPin) {
      pins_by_key[cellPinKey(vertex, index, options)].push_back(id);
    }
  }
  for (auto& [_, ids] : pins_by_key) {
    ids = sortedVector(ids);
  }
  return pins_by_key;
}

auto pinNameKey(const LvsVertex& pin, const GraphIndex& index) -> std::string
{
  const auto inst_iter = index.instance_id_by_pin.find(pin.id);
  std::string inst_name;
  std::string cell_type;
  if (inst_iter != index.instance_id_by_pin.end()) {
    const auto& inst = index.vertices_by_id.at(inst_iter->second);
    inst_name = inst.name;
    cell_type = inst.type;
  }
  return inst_name + "|" + cell_type + "|" + pin.name;
}

auto pinByNameKey(const GraphIndex& index) -> std::map<std::string, std::string>
{
  std::map<std::string, std::string> result;
  for (const auto& [id, vertex] : index.vertices_by_id) {
    if (vertex.kind == VertexKind::kPin) {
      result.emplace(pinNameKey(vertex, index), id);
    }
  }
  return result;
}

void pushDiff(std::vector<LvsDiff>& diffs, DiffKind kind, std::vector<std::string> ref_ids, std::vector<std::string> ext_ids,
              std::string reason)
{
  diffs.push_back({kind, sortedVector(std::move(ref_ids)), sortedVector(std::move(ext_ids)), std::move(reason)});
}

void sortDiffs(std::vector<LvsDiff>& diffs)
{
  std::sort(diffs.begin(), diffs.end(), [](const LvsDiff& lhs, const LvsDiff& rhs) {
    return std::tuple(kindOrder(lhs.kind), lhs.reason, lhs.ref_ids, lhs.ext_ids)
           < std::tuple(kindOrder(rhs.kind), rhs.reason, rhs.ref_ids, rhs.ext_ids);
  });
  diffs.erase(std::unique(diffs.begin(), diffs.end(), [](const LvsDiff& lhs, const LvsDiff& rhs) {
                return lhs.kind == rhs.kind && lhs.ref_ids == rhs.ref_ids && lhs.ext_ids == rhs.ext_ids && lhs.reason == rhs.reason;
              }),
              diffs.end());
}

auto hasUnsupportedCoverage(const LvsGraph& graph) -> bool
{
  return !graph.coverage.unsupported_layers.empty() || !graph.coverage.unsupported_cells.empty();
}

auto graphToJson(const LvsGraph& graph) -> nlohmann::ordered_json
{
  return {{"provenance_id", graph.provenance_id}, {"counts", graphCountsToJson(graph)}, {"coverage", coverageToJson(graph.coverage)}};
}

auto diffToJson(const LvsDiff& diff) -> nlohmann::ordered_json
{
  return {{"kind", toString(diff.kind)}, {"ref_ids", vectorToJson(diff.ref_ids)}, {"ext_ids", vectorToJson(diff.ext_ids)}, {"reason", diff.reason}};
}

auto stringValue(const nlohmann::json& json, const char* key) -> std::string
{
  if (!json.contains(key) || !json.at(key).is_string()) {
    throw std::runtime_error(std::string("missing string field: ") + key);
  }
  return json.at(key).get<std::string>();
}

auto parseCoverage(const nlohmann::json& json) -> LvsCoverage
{
  LvsCoverage coverage;
  auto load_array = [&](const char* key, std::set<std::string>& target) {
    if (!json.contains(key)) {
      return;
    }
    if (!json.at(key).is_array()) {
      throw std::runtime_error(std::string("coverage field is not array: ") + key);
    }
    for (const auto& item : json.at(key)) {
      if (!item.is_string()) {
        throw std::runtime_error(std::string("coverage item is not string: ") + key);
      }
      target.insert(item.get<std::string>());
    }
  };
  load_array("checked_layers", coverage.checked_layers);
  load_array("unsupported_layers", coverage.unsupported_layers);
  load_array("checked_cells", coverage.checked_cells);
  load_array("unsupported_cells", coverage.unsupported_cells);
  return coverage;
}

}  // namespace

auto toString(LvsState state) -> std::string
{
  switch (state) {
    case LvsState::kInit:
      return "INIT";
    case LvsState::kInputsVerified:
      return "INPUTS_VERIFIED";
    case LvsState::kExtracted:
      return "EXTRACTED";
    case LvsState::kMatched:
      return "MATCHED";
    case LvsState::kClean:
      return "CLEAN";
    case LvsState::kMismatch:
      return "MISMATCH";
    case LvsState::kUnsupported:
      return "UNSUPPORTED";
    case LvsState::kInconclusive:
      return "INCONCLUSIVE";
    case LvsState::kError:
      return "ERROR";
  }
  return "ERROR";
}

auto toString(LvsExitCode code) -> std::string
{
  return std::to_string(static_cast<int>(code));
}

auto toString(VertexKind kind) -> std::string
{
  switch (kind) {
    case VertexKind::kInstance:
      return "instance";
    case VertexKind::kPin:
      return "pin";
    case VertexKind::kNet:
      return "net";
  }
  return "unknown";
}

auto toString(EdgeKind kind) -> std::string
{
  switch (kind) {
    case EdgeKind::kPinOfInstance:
      return "pin_of_instance";
    case EdgeKind::kPinOnNet:
      return "pin_on_net";
  }
  return "unknown";
}

auto toString(DiffKind kind) -> std::string
{
  switch (kind) {
    case DiffKind::kOpen:
      return "open";
    case DiffKind::kShort:
      return "short";
    case DiffKind::kMissing:
      return "missing";
    case DiffKind::kExtra:
      return "extra";
    case DiffKind::kPinSwap:
      return "pin_swap";
    case DiffKind::kUnsupported:
      return "unsupported";
    case DiffKind::kInconclusive:
      return "inconclusive";
  }
  return "unknown";
}

auto parseGraphJson(const nlohmann::json& json, const std::string& provenance_id) -> LvsGraph
{
  if (!json.is_object()) {
    throw std::runtime_error("graph json root is not object");
  }
  LvsGraph graph;
  graph.provenance_id = provenance_id;
  if (json.contains("provenance_id") && json.at("provenance_id").is_string()) {
    graph.provenance_id = json.at("provenance_id").get<std::string>();
  }
  if (!json.contains("vertices") || !json.at("vertices").is_array()) {
    throw std::runtime_error("graph vertices are missing");
  }
  for (const auto& item : json.at("vertices")) {
    LvsVertex vertex;
    vertex.id = stringValue(item, "id");
    vertex.kind = parseVertexKind(stringValue(item, "kind"));
    vertex.name = item.contains("name") && item.at("name").is_string() ? item.at("name").get<std::string>() : vertex.id;
    vertex.type = item.contains("type") && item.at("type").is_string() ? item.at("type").get<std::string>() : "";
    vertex.role = item.contains("role") && item.at("role").is_string() ? item.at("role").get<std::string>() : "";
    graph.vertices.push_back(std::move(vertex));
  }
  if (!json.contains("edges") || !json.at("edges").is_array()) {
    throw std::runtime_error("graph edges are missing");
  }
  for (const auto& item : json.at("edges")) {
    LvsEdge edge;
    edge.a = stringValue(item, "a");
    edge.b = stringValue(item, "b");
    edge.kind = parseEdgeKind(stringValue(item, "kind"));
    graph.edges.push_back(std::move(edge));
  }
  if (json.contains("coverage") && json.at("coverage").is_object()) {
    graph.coverage = parseCoverage(json.at("coverage"));
  }
  buildIndex(graph);
  return graph;
}

auto loadGraphJsonFile(const std::string& path, const std::string& provenance_id) -> LvsGraph
{
  std::ifstream input(path);
  if (!input.is_open()) {
    throw std::runtime_error("cannot open graph json: " + path);
  }
  nlohmann::json json;
  input >> json;
  return parseGraphJson(json, provenance_id);
}

auto validateManifest(const LvsManifest& manifest, std::vector<std::string>& diagnostics) -> bool
{
  auto validate_input = [&](const char* name, const LvsInputIdentity& identity) {
    if (identity.path.empty()) {
      diagnostics.push_back(std::string(name) + "_path_missing");
    }
    if (!isSha256(identity.sha256)) {
      diagnostics.push_back(std::string(name) + "_sha256_invalid");
    }
    if (identity.object_id.empty()) {
      diagnostics.push_back(std::string(name) + "_object_id_missing");
    }
  };

  validate_input("reference", manifest.reference);
  validate_input("layout", manifest.layout);
  validate_input("tech_mapping", manifest.tech_mapping);
  validate_input("binary", manifest.binary);
  if (manifest.reference.object_id == manifest.layout.object_id) {
    diagnostics.push_back("reference_layout_share_object");
  }
  if (!manifest.reference.path.empty() && manifest.reference.path == manifest.layout.path) {
    diagnostics.push_back("reference_layout_share_path");
  }
  if (manifest.reference.sha256 == manifest.layout.sha256) {
    diagnostics.push_back("reference_layout_share_hash");
  }
  return diagnostics.empty();
}

auto runConnectivityLvs(const LvsGraph& reference_graph, const LvsGraph& extracted_graph, const LvsManifest& manifest,
                        const LvsOptions& options) -> LvsResult
{
  LvsResult result;
  result.state = LvsState::kInit;
  result.exit_code = LvsExitCode::kToolError;
  result.manifest = manifest;
  result.options = options;
  result.reference_graph = reference_graph;
  result.extracted_graph = extracted_graph;

  if (!validateManifest(manifest, result.diagnostics)) {
    result.state = LvsState::kError;
    result.exit_code = LvsExitCode::kInputError;
    return result;
  }
  result.state = LvsState::kInputsVerified;

  try {
    const GraphIndex ref_index = buildIndex(reference_graph);
    const GraphIndex ext_index = buildIndex(extracted_graph);
    result.state = LvsState::kExtracted;

    if (options.fail_on_unsupported && (hasUnsupportedCoverage(reference_graph) || hasUnsupportedCoverage(extracted_graph))) {
      if (hasUnsupportedCoverage(reference_graph)) {
        pushDiff(result.diffs, DiffKind::kUnsupported, {}, {}, "reference graph contains unsupported coverage");
      }
      if (hasUnsupportedCoverage(extracted_graph)) {
        pushDiff(result.diffs, DiffKind::kUnsupported, {}, {}, "extracted graph contains unsupported coverage");
      }
      result.state = LvsState::kUnsupported;
      result.exit_code = LvsExitCode::kUnsupported;
      sortDiffs(result.diffs);
      return result;
    }

    const auto ref_partitions = partitionBySignature(reference_graph, ref_index, options);
    const auto ext_partitions = partitionBySignature(extracted_graph, ext_index, options);
    for (const auto& [signature, ref_ids] : ref_partitions) {
      const auto ext_iter = ext_partitions.find(signature);
      const std::size_t ext_size = ext_iter == ext_partitions.end() ? 0 : ext_iter->second.size();
      result.explored_states += static_cast<int64_t>(std::max(ref_ids.size(), ext_size));
      if (result.explored_states > options.graph_search_budget) {
        pushDiff(result.diffs, DiffKind::kInconclusive, ref_ids, ext_iter == ext_partitions.end() ? std::vector<std::string>{} : ext_iter->second,
                 "graph_search_budget_exhausted");
        result.state = LvsState::kInconclusive;
        result.exit_code = LvsExitCode::kInconclusive;
        sortDiffs(result.diffs);
        return result;
      }
      if (ext_size < ref_ids.size()) {
        pushDiff(result.diffs, DiffKind::kMissing, ref_ids, ext_iter == ext_partitions.end() ? std::vector<std::string>{} : ext_iter->second,
                 "reference signature has fewer extracted matches");
      } else if (ext_size > ref_ids.size()) {
        pushDiff(result.diffs, DiffKind::kExtra, ref_ids, ext_iter->second, "extracted signature has extra matches");
      }
    }
    for (const auto& [signature, ext_ids] : ext_partitions) {
      if (!ref_partitions.contains(signature)) {
        pushDiff(result.diffs, DiffKind::kExtra, {}, ext_ids, "extracted signature absent from reference");
      }
    }

    const auto ref_pin_by_key = pinByCellRole(ref_index, options);
    const auto ext_pin_by_key = pinByCellRole(ext_index, options);
    std::map<std::string, std::vector<std::string>> ext_net_to_ref_nets;
    std::map<std::string, std::vector<std::string>> ref_net_to_ext_nets;
    for (const auto& [pin_key, ref_pin_ids] : ref_pin_by_key) {
      const auto ext_iter = ext_pin_by_key.find(pin_key);
      if (ext_iter == ext_pin_by_key.end()) {
        continue;
      }
      const std::size_t pair_count = std::min(ref_pin_ids.size(), ext_iter->second.size());
      for (std::size_t index = 0; index < pair_count; ++index) {
        const auto ref_net_iter = ref_index.net_id_by_pin.find(ref_pin_ids[index]);
        const auto ext_net_iter = ext_index.net_id_by_pin.find(ext_iter->second[index]);
        if (ref_net_iter == ref_index.net_id_by_pin.end() || ext_net_iter == ext_index.net_id_by_pin.end()) {
          continue;
        }
        ref_net_to_ext_nets[ref_net_iter->second].push_back(ext_net_iter->second);
        ext_net_to_ref_nets[ext_net_iter->second].push_back(ref_net_iter->second);
      }
    }
    for (auto& [_, ids] : ext_net_to_ref_nets) {
      ids = sortedVector(ids);
    }
    for (auto& [_, ids] : ref_net_to_ext_nets) {
      ids = sortedVector(ids);
    }
    for (const auto& [ext_net_id, ref_net_ids] : ext_net_to_ref_nets) {
      if (ref_net_ids.size() > 1) {
        pushDiff(result.diffs, DiffKind::kShort, ref_net_ids, {ext_net_id}, "one extracted component maps multiple reference nets");
      }
    }
    for (const auto& [ref_net_id, ext_net_ids] : ref_net_to_ext_nets) {
      if (ext_net_ids.size() > 1) {
        pushDiff(result.diffs, DiffKind::kOpen, {ref_net_id}, ext_net_ids, "one reference net maps multiple extracted components");
      }
    }

    const auto ref_pins_by_name = pinByNameKey(ref_index);
    const auto ext_pins_by_name = pinByNameKey(ext_index);
    for (const auto& [name_key, ref_id] : ref_pins_by_name) {
      const auto ext_pin_iter = ext_pins_by_name.find(name_key);
      if (ext_pin_iter == ext_pins_by_name.end()) {
        continue;
      }
      const LvsVertex& ref_vertex = ref_index.vertices_by_id.at(ref_id);
      const LvsVertex& ext_vertex = ext_index.vertices_by_id.at(ext_pin_iter->second);
      const auto ref_inst_iter = ref_index.instance_id_by_pin.find(ref_id);
      const auto ext_inst_iter = ext_index.instance_id_by_pin.find(ext_pin_iter->second);
      if (ref_inst_iter == ref_index.instance_id_by_pin.end() || ext_inst_iter == ext_index.instance_id_by_pin.end()) {
        continue;
      }
      const std::string ref_cell = ref_index.vertices_by_id.at(ref_inst_iter->second).type;
      const std::string ext_cell = ext_index.vertices_by_id.at(ext_inst_iter->second).type;
      if (ref_cell == ext_cell && ref_vertex.role != ext_vertex.role
          && normalizedPinRole(ref_cell, ref_vertex.role, options) != normalizedPinRole(ext_cell, ext_vertex.role, options)) {
        pushDiff(result.diffs, DiffKind::kPinSwap, {ref_id}, {ext_pin_iter->second}, "pin role changed without explicit equivalence");
      }
    }

    std::set<std::vector<std::string>> ref_net_signatures;
    std::set<std::vector<std::string>> ext_net_signatures;
    for (const auto& [id, vertex] : ref_index.vertices_by_id) {
      if (vertex.kind == VertexKind::kNet) {
        ref_net_signatures.insert(netSignature(id, ref_index, options));
      }
    }
    for (const auto& [id, vertex] : ext_index.vertices_by_id) {
      if (vertex.kind == VertexKind::kNet) {
        ext_net_signatures.insert(netSignature(id, ext_index, options));
      }
    }
    for (const auto& signature : ref_net_signatures) {
      if (!ext_net_signatures.contains(signature)) {
        pushDiff(result.diffs, DiffKind::kMissing, {}, {}, "reference net signature missing in extracted graph");
      }
    }

    result.state = LvsState::kMatched;
    sortDiffs(result.diffs);
    result.state = result.diffs.empty() ? LvsState::kClean : LvsState::kMismatch;
    result.exit_code = exitCodeForState(result.state);
    return result;
  } catch (const std::exception& error) {
    result.state = LvsState::kError;
    result.exit_code = LvsExitCode::kToolError;
    result.diagnostics.push_back(error.what());
    return result;
  }
}

auto resultToJson(const LvsResult& result) -> nlohmann::ordered_json
{
  nlohmann::ordered_json diffs = nlohmann::ordered_json::array();
  for (const auto& diff : result.diffs) {
    diffs.push_back(diffToJson(diff));
  }
  return {{"schema_version", "ieda.lvs.summary.v1"},
          {"status", toString(result.state)},
          {"exit_code", static_cast<int>(result.exit_code)},
          {"clean", result.state == LvsState::kClean},
          {"manifest",
           {{"reference", identityToJson(result.manifest.reference)},
            {"layout", identityToJson(result.manifest.layout)},
            {"tech_mapping", identityToJson(result.manifest.tech_mapping)},
            {"binary", identityToJson(result.manifest.binary)}}},
          {"reference_graph", graphToJson(result.reference_graph)},
          {"extracted_graph", graphToJson(result.extracted_graph)},
          {"search_budget", result.options.graph_search_budget},
          {"explored_states", result.explored_states},
          {"diagnostics", vectorToJson(result.diagnostics)},
          {"diff_count", result.diffs.size()},
          {"diffs", std::move(diffs)}};
}

auto exitCodeForState(LvsState state) -> LvsExitCode
{
  switch (state) {
    case LvsState::kClean:
      return LvsExitCode::kClean;
    case LvsState::kMismatch:
      return LvsExitCode::kMismatch;
    case LvsState::kUnsupported:
      return LvsExitCode::kUnsupported;
    case LvsState::kInconclusive:
      return LvsExitCode::kInconclusive;
    case LvsState::kError:
      return LvsExitCode::kToolError;
    default:
      return LvsExitCode::kToolError;
  }
}

auto writeResultJson(const LvsResult& result, const std::string& output_path) -> bool
{
  std::ofstream output(output_path, std::ios::trunc);
  if (!output.is_open()) {
    return false;
  }
  output << resultToJson(result).dump(2) << '\n';
  return static_cast<bool>(output);
}

}  // namespace ilvs
