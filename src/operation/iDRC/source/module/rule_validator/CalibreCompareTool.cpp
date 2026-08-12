// ***************************************************************************************
// Copyright (c) 2023-2025 Peng Cheng Laboratory
// Copyright (c) 2023-2025 Institute of Computing Technology, Chinese Academy of Sciences
// Copyright (c) 2023-2025 Beijing Institute of Open Source Chip
//
// iEDA is licensed under Mulan PSL v2.
// ***************************************************************************************
#include "CalibreCompareTool.hpp"

#include <filesystem>
#include <fstream>
#include <iostream>
#include <utility>

namespace idrc {
namespace {

auto readJsonFile(const std::string& path, nlohmann::json* json, std::string* error) -> bool
{
  std::ifstream input(path);
  if (!input.is_open()) {
    if (error != nullptr) {
      *error = "cannot open JSON artifact: " + path;
    }
    return false;
  }
  try {
    input >> *json;
  } catch (const std::exception& exception) {
    if (error != nullptr) {
      *error = "invalid JSON artifact " + path + ": " + exception.what();
    }
    return false;
  }
  return true;
}

auto writeJsonFile(const std::string& path, const nlohmann::ordered_json& json, std::string* error) -> bool
{
  const std::filesystem::path report_path(path);
  if (!report_path.parent_path().empty()) {
    std::error_code ec;
    std::filesystem::create_directories(report_path.parent_path(), ec);
    if (ec) {
      if (error != nullptr) {
        *error = "cannot create output directory for " + path + ": " + ec.message();
      }
      return false;
    }
  }

  const auto temporary_path = report_path.string() + ".tmp";
  {
    std::ofstream output(temporary_path, std::ios::trunc);
    if (!output.is_open()) {
      if (error != nullptr) {
        *error = "cannot open compare report for writing: " + temporary_path;
      }
      return false;
    }
    output << json.dump(2) << '\n';
    if (!output) {
      if (error != nullptr) {
        *error = "cannot write compare report: " + temporary_path;
      }
      return false;
    }
  }

  std::error_code ec;
  std::filesystem::rename(temporary_path, report_path, ec);
  if (ec) {
    std::filesystem::remove(temporary_path);
    if (error != nullptr) {
      *error = "cannot publish compare report " + path + ": " + ec.message();
    }
    return false;
  }
  return true;
}

auto effectiveSupportedRules(const CalibreCompareConfig& config) -> std::set<std::string>
{
  if (!config.supported_rule_types.empty()) {
    return config.supported_rule_types;
  }
  return config.options.supported_rule_types;
}

}  // namespace

auto CalibreCompareTool::runToReport(const CalibreCompareConfig& config, nlohmann::ordered_json* report, std::string* error) -> bool
{
  if (report == nullptr) {
    if (error != nullptr) {
      *error = "report output pointer is null";
    }
    return false;
  }
  *report = nlohmann::ordered_json::object();
  if (config.idrc_artifact_path.empty() || config.calibre_artifact_path.empty()) {
    if (error != nullptr) {
      *error = "iDRC and Calibre artifact paths are required";
    }
    return false;
  }

  const auto supported_rules = effectiveSupportedRules(config);
  if (supported_rules.empty()) {
    if (error != nullptr) {
      *error = "Calibre compare requires an explicit supported rule subset";
    }
    return false;
  }

  nlohmann::json idrc_artifact;
  nlohmann::json calibre_artifact;
  if (!readJsonFile(config.idrc_artifact_path, &idrc_artifact, error) || !readJsonFile(config.calibre_artifact_path, &calibre_artifact, error)) {
    return false;
  }

  std::string validation_reason;
  if (!validateViolationsArtifact(idrc_artifact, &validation_reason)) {
    if (error != nullptr) {
      *error = "invalid iDRC violation artifact: " + validation_reason;
    }
    return false;
  }
  if (!validateViolationsArtifact(calibre_artifact, &validation_reason)) {
    if (error != nullptr) {
      *error = "invalid Calibre violation artifact: " + validation_reason;
    }
    return false;
  }

  CalibreCompareOptions options = config.options;
  options.supported_rule_types = supported_rules;
  auto result = compareCalibreArtifacts(idrc_artifact, calibre_artifact, options);
  *report = std::move(result.report);
  (*report)["artifact"] = "idrc_calibre_compare";
  (*report)["inputs"] = {{"idrc_artifact_path", config.idrc_artifact_path}, {"calibre_artifact_path", config.calibre_artifact_path}};

  if (!config.output_report_path.empty() && !writeJsonFile(config.output_report_path, *report, error)) {
    return false;
  }
  return result.pass;
}

auto CalibreCompareTool::run(const CalibreCompareConfig& config) -> bool
{
  nlohmann::ordered_json report;
  std::string error;
  const bool pass = runToReport(config, &report, &error);
  if (!error.empty()) {
    std::cerr << "idrc_calibre_compare failed: " << error << '\n';
  }
  return pass;
}

}  // namespace idrc
