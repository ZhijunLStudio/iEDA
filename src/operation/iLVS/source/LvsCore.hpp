// ***************************************************************************************
// Copyright (c) 2026-2030 Southeast University
// Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
//
// iEDA is licensed under Mulan PSL v2.
// ***************************************************************************************
#pragma once

#include <cstdint>
#include <map>
#include <set>
#include <string>
#include <vector>

#include "json/json.hpp"

namespace ilvs {

enum class LvsState
{
  kInit,
  kInputsVerified,
  kExtracted,
  kMatched,
  kClean,
  kMismatch,
  kUnsupported,
  kInconclusive,
  kError
};

enum class LvsExitCode : int
{
  kClean = 0,
  kMismatch = 10,
  kUnsupported = 20,
  kInconclusive = 30,
  kInputError = 40,
  kToolError = 50
};

enum class VertexKind
{
  kInstance,
  kPin,
  kNet
};

enum class EdgeKind
{
  kPinOfInstance,
  kPinOnNet
};

enum class DiffKind
{
  kOpen,
  kShort,
  kMissing,
  kExtra,
  kPinSwap,
  kUnsupported,
  kInconclusive
};

struct LvsInputIdentity
{
  std::string path;
  std::string sha256;
  std::string object_id;
};

struct LvsManifest
{
  LvsInputIdentity reference;
  LvsInputIdentity layout;
  LvsInputIdentity tech_mapping;
  LvsInputIdentity binary;
};

struct LvsOptions
{
  int64_t graph_search_budget = 100000;
  bool fail_on_unsupported = true;
  std::map<std::string, std::vector<std::vector<std::string>>> equivalent_pin_groups;
};

struct LvsVertex
{
  std::string id;
  VertexKind kind = VertexKind::kNet;
  std::string name;
  std::string type;
  std::string role;
};

struct LvsEdge
{
  std::string a;
  std::string b;
  EdgeKind kind = EdgeKind::kPinOnNet;
};

struct LvsCoverage
{
  std::set<std::string> checked_layers;
  std::set<std::string> unsupported_layers;
  std::set<std::string> checked_cells;
  std::set<std::string> unsupported_cells;
};

struct LvsGraph
{
  std::string provenance_id;
  std::vector<LvsVertex> vertices;
  std::vector<LvsEdge> edges;
  LvsCoverage coverage;
};

struct LvsDiff
{
  DiffKind kind = DiffKind::kMissing;
  std::vector<std::string> ref_ids;
  std::vector<std::string> ext_ids;
  std::string reason;
};

struct LvsResult
{
  LvsState state = LvsState::kInit;
  LvsExitCode exit_code = LvsExitCode::kToolError;
  LvsManifest manifest;
  LvsOptions options;
  std::vector<LvsDiff> diffs;
  int64_t explored_states = 0;
  std::vector<std::string> diagnostics;
  LvsGraph reference_graph;
  LvsGraph extracted_graph;
};

auto toString(LvsState state) -> std::string;
auto toString(LvsExitCode code) -> std::string;
auto toString(VertexKind kind) -> std::string;
auto toString(EdgeKind kind) -> std::string;
auto toString(DiffKind kind) -> std::string;

auto parseGraphJson(const nlohmann::json& json, const std::string& provenance_id) -> LvsGraph;
auto loadGraphJsonFile(const std::string& path, const std::string& provenance_id) -> LvsGraph;

auto validateManifest(const LvsManifest& manifest, std::vector<std::string>& diagnostics) -> bool;
auto runConnectivityLvs(const LvsGraph& reference_graph, const LvsGraph& extracted_graph, const LvsManifest& manifest,
                        const LvsOptions& options = {}) -> LvsResult;
auto resultToJson(const LvsResult& result) -> nlohmann::ordered_json;
auto exitCodeForState(LvsState state) -> LvsExitCode;
auto writeResultJson(const LvsResult& result, const std::string& output_path) -> bool;

}  // namespace ilvs
