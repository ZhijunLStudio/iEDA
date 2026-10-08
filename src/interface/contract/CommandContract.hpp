// ***************************************************************************************
// Copyright (c) 2023-2025 Peng Cheng Laboratory
// Copyright (c) 2023-2025 Institute of Computing Technology, Chinese Academy of Sciences
// Copyright (c) 2023-2025 Beijing Institute of Open Source Chip
//
// iEDA is licensed under Mulan PSL v2.
// ***************************************************************************************
#pragma once

#include <filesystem>
#include <fstream>
#include <set>
#include <sstream>
#include <string>
#include <vector>

#include "json/json.hpp"

namespace ieda::interface_contract {

inline constexpr const char* kCommandResultSchemaVersion = "ieda.interface.command_result.v1";

struct CommandProduct
{
  std::string name;
  std::filesystem::path path;
  std::string schema_key = "schema_version";
  std::string schema_value;
};

struct CommandContract
{
  std::string name;
  std::set<std::string> allowed_options;
  std::vector<std::string> dependencies;
  std::vector<CommandProduct> products;
  bool compat_mode = false;
};

struct CommandResult
{
  std::string command;
  bool ok = false;
  int rc = 1;
  std::string reason;
  bool api_success = false;
  bool deps_satisfied = false;
  bool products_valid = false;
  bool compat_mode = false;

  [[nodiscard]] int tclRc() const { return ok ? 1 : 0; }
};

inline auto validateOptions(const CommandContract& contract, const std::set<std::string>& options) -> std::string
{
  std::vector<std::string> unknown;
  for (const auto& option : options) {
    if (!contract.allowed_options.contains(option)) {
      unknown.push_back(option);
    }
  }
  if (unknown.empty() || contract.compat_mode) {
    return "";
  }

  std::ostringstream stream;
  stream << contract.name << ": unknown option(s): ";
  for (size_t index = 0; index < unknown.size(); ++index) {
    if (index > 0) {
      stream << ", ";
    }
    stream << unknown[index];
  }
  return stream.str();
}

inline auto validateDependencies(const CommandContract& contract, const std::set<std::string>& satisfied_dependencies) -> std::string
{
  std::vector<std::string> missing;
  for (const auto& dependency : contract.dependencies) {
    if (!satisfied_dependencies.contains(dependency)) {
      missing.push_back(dependency);
    }
  }
  if (missing.empty()) {
    return "";
  }

  std::ostringstream stream;
  stream << "missing dependency: ";
  for (size_t index = 0; index < missing.size(); ++index) {
    if (index > 0) {
      stream << ", ";
    }
    stream << missing[index];
  }
  return stream.str();
}

inline auto validateProducts(const std::vector<CommandProduct>& products) -> std::string
{
  for (const auto& product : products) {
    if (!std::filesystem::exists(product.path)) {
      return "missing product: " + product.name;
    }
    if (!product.schema_value.empty()) {
      std::ifstream input(product.path);
      if (!input.is_open()) {
        return "missing product: " + product.name;
      }
      nlohmann::json payload;
      try {
        input >> payload;
      } catch (const nlohmann::json::exception& error) {
        return "invalid product schema: " + product.name + ": " + error.what();
      }
      if (!payload.contains(product.schema_key) || payload[product.schema_key].get<std::string>() != product.schema_value) {
        return "unexpected product schema: " + product.name;
      }
    }
  }
  return "";
}

inline auto evaluateCommandResult(const CommandContract& contract, bool api_success, const std::set<std::string>& options,
                                  const std::set<std::string>& satisfied_dependencies) -> CommandResult
{
  const std::string option_error = validateOptions(contract, options);
  if (!option_error.empty()) {
    return {contract.name, false, 1, option_error, api_success, false, false, contract.compat_mode};
  }

  const std::string dependency_error = validateDependencies(contract, satisfied_dependencies);
  const std::string product_error = validateProducts(contract.products);
  const bool deps_ok = dependency_error.empty();
  const bool products_ok = product_error.empty();
  const bool ok = api_success && deps_ok && products_ok;

  std::string reason = "ok";
  if (!api_success) {
    reason = "api failed";
  } else if (!deps_ok) {
    reason = dependency_error;
  } else if (!products_ok) {
    reason = product_error;
  }

  return {contract.name, ok, ok ? 0 : 1, reason, api_success, deps_ok, products_ok, contract.compat_mode};
}

inline auto toJson(const CommandResult& result) -> std::string
{
  const nlohmann::ordered_json payload = {{"schema_version", kCommandResultSchemaVersion},
                                         {"command", result.command},
                                         {"ok", result.ok},
                                         {"rc", result.rc},
                                         {"reason", result.reason},
                                         {"api_success", result.api_success},
                                         {"deps_satisfied", result.deps_satisfied},
                                         {"products_valid", result.products_valid},
                                         {"compat_mode", result.compat_mode}};
  return payload.dump();
}

}  // namespace ieda::interface_contract
