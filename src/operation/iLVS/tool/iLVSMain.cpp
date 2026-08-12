// ***************************************************************************************
// Copyright (c) 2026-2030 Southeast University
// Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
//
// iEDA is licensed under Mulan PSL v2.
// ***************************************************************************************

#include "ILVSAPI.hpp"
#include "VerilogReferenceLoader.hpp"

#include <cstdlib>
#include <iostream>
#include <map>
#include <sstream>
#include <stdexcept>
#include <string>
#include <vector>

namespace {

auto usage() -> std::string
{
  return R"(Usage:
  iLVS (--ref_graph <json> | --ref_verilog <v>) --ext_graph <json> --tech <path> --out <json>
       --ref_hash <sha256> --ext_hash <sha256> --tech_hash <sha256> --binary_hash <sha256>
       [--ref_object <id>] [--ext_object <id>] [--tech_object <id>] [--binary_path <path>] [--binary_object <id>]
       [--top_module <name>] [--budget <states>] [--allow_unsupported] [--equiv_pin <cell:pin,pin>]
)";
}

auto split(const std::string& value, char delimiter) -> std::vector<std::string>
{
  std::vector<std::string> parts;
  std::stringstream stream(value);
  std::string part;
  while (std::getline(stream, part, delimiter)) {
    if (!part.empty()) {
      parts.push_back(part);
    }
  }
  return parts;
}

auto argOrDefault(const std::map<std::string, std::string>& args, const std::string& key, const std::string& fallback) -> std::string
{
  const auto iter = args.find(key);
  return iter == args.end() ? fallback : iter->second;
}

auto parseEquivalentPinGroup(const std::string& spec, ilvs::LvsOptions& options) -> bool
{
  const auto colon = spec.find(':');
  if (colon == std::string::npos || colon == 0 || colon + 1 >= spec.size()) {
    return false;
  }
  const std::string cell = spec.substr(0, colon);
  std::vector<std::string> pins = split(spec.substr(colon + 1), ',');
  if (pins.size() < 2) {
    return false;
  }
  options.equivalent_pin_groups[cell].push_back(std::move(pins));
  return true;
}

auto parseArgs(int argc, char** argv, std::map<std::string, std::string>& args, std::vector<std::string>& equiv_specs,
               ilvs::LvsOptions& options) -> bool
{
  for (int index = 1; index < argc; ++index) {
    const std::string key = argv[index];
    if (key == "--help" || key == "-h") {
      return false;
    }
    if (key == "--allow_unsupported") {
      options.fail_on_unsupported = false;
      continue;
    }
    if (key.rfind("--", 0) != 0 || index + 1 >= argc) {
      throw std::runtime_error("invalid argument: " + key);
    }
    const std::string value = argv[++index];
    if (key == "--equiv_pin") {
      equiv_specs.push_back(value);
    } else {
      args[key] = value;
    }
  }
  const std::vector<std::string> required = {"--ext_graph", "--tech", "--out", "--ref_hash", "--ext_hash", "--tech_hash", "--binary_hash"};
  for (const auto& key : required) {
    if (!args.contains(key) || args.at(key).empty()) {
      throw std::runtime_error("missing required argument: " + key);
    }
  }
  if (args.contains("--ref_graph") == args.contains("--ref_verilog")) {
    throw std::runtime_error("provide exactly one of --ref_graph or --ref_verilog");
  }
  if (args.contains("--budget")) {
    options.graph_search_budget = std::stoll(args.at("--budget"));
    if (options.graph_search_budget < 0) {
      throw std::runtime_error("budget must be non-negative");
    }
  }
  for (const auto& spec : equiv_specs) {
    if (!parseEquivalentPinGroup(spec, options)) {
      throw std::runtime_error("invalid --equiv_pin value: " + spec);
    }
  }
  return true;
}

}  // namespace

auto main(int argc, char** argv) -> int
{
  std::map<std::string, std::string> args;
  std::vector<std::string> equiv_specs;
  ilvs::LvsOptions options;

  try {
    if (!parseArgs(argc, argv, args, equiv_specs, options)) {
      std::cout << usage();
      return static_cast<int>(ilvs::LvsExitCode::kInputError);
    }

    ilvs::LvsManifest manifest;
    const std::string reference_path = args.contains("--ref_graph") ? args.at("--ref_graph") : args.at("--ref_verilog");
    manifest.reference = {reference_path, args.at("--ref_hash"), argOrDefault(args, "--ref_object", reference_path)};
    manifest.layout = {args.at("--ext_graph"), args.at("--ext_hash"), argOrDefault(args, "--ext_object", args.at("--ext_graph"))};
    manifest.tech_mapping = {args.at("--tech"), args.at("--tech_hash"), argOrDefault(args, "--tech_object", args.at("--tech"))};
    manifest.binary = {argOrDefault(args, "--binary_path", argv[0]), args.at("--binary_hash"),
                       argOrDefault(args, "--binary_object", argv[0])};

    const ilvs::ILVSAPI api;
    ilvs::LvsResult result;
    if (args.contains("--ref_graph")) {
      result = api.runFromJsonFiles(args.at("--ref_graph"), args.at("--ext_graph"), manifest, options);
    } else {
      ilvs::VerilogReferenceOptions verilog_options;
      verilog_options.top_module = argOrDefault(args, "--top_module", "");
      const ilvs::LvsGraph reference_graph = ilvs::loadVerilogReferenceGraphFile(args.at("--ref_verilog"), verilog_options);
      const ilvs::LvsGraph extracted_graph = ilvs::loadGraphJsonFile(args.at("--ext_graph"), "layout");
      result = api.run(reference_graph, extracted_graph, manifest, options);
    }
    if (!ilvs::writeResultJson(result, args.at("--out"))) {
      std::cerr << "failed to write LVS summary: " << args.at("--out") << '\n';
      return static_cast<int>(ilvs::LvsExitCode::kToolError);
    }
    return static_cast<int>(result.exit_code);
  } catch (const std::exception& error) {
    std::cerr << error.what() << '\n' << usage();
    return static_cast<int>(ilvs::LvsExitCode::kInputError);
  }
}
