// ***************************************************************************************
// Copyright (c) 2023-2025 Peng Cheng Laboratory
// Copyright (c) 2023-2025 Institute of Computing Technology, Chinese Academy of Sciences
// Copyright (c) 2023-2025 Beijing Institute of Open Source Chip
//
// iEDA is licensed under Mulan PSL v2.
// ***************************************************************************************
#include "CalibreCompareTool.hpp"

#include <iostream>
#include <set>
#include <sstream>
#include <string>

namespace {

void printUsage()
{
  std::cerr
      << "Usage: idrc_calibre_compare -idrc <violations.json> -calibre <calibre.json> -out <report.json> "
         "-supported_rules <rule[,rule...]>\n"
      << "Options: -allow_context_mismatch -allow_missing_hashes -allow_false_negative -fail_on_false_positive "
         "-fail_on_unsupported\n";
}

auto splitRules(const std::string& value) -> std::set<std::string>
{
  std::set<std::string> rules;
  std::stringstream stream(value);
  std::string rule;
  while (std::getline(stream, rule, ',')) {
    if (!rule.empty()) {
      rules.insert(rule);
    }
  }
  return rules;
}

auto requireValue(int argc, char** argv, int* index, std::string* value) -> bool
{
  if (*index + 1 >= argc) {
    return false;
  }
  ++(*index);
  *value = argv[*index];
  return true;
}

}  // namespace

int main(int argc, char** argv)
{
  idrc::CalibreCompareConfig config;

  for (int index = 1; index < argc; ++index) {
    const std::string arg = argv[index];
    std::string value;
    if (arg == "-idrc") {
      if (!requireValue(argc, argv, &index, &config.idrc_artifact_path)) {
        printUsage();
        return 2;
      }
    } else if (arg == "-calibre") {
      if (!requireValue(argc, argv, &index, &config.calibre_artifact_path)) {
        printUsage();
        return 2;
      }
    } else if (arg == "-out") {
      if (!requireValue(argc, argv, &index, &config.output_report_path)) {
        printUsage();
        return 2;
      }
    } else if (arg == "-supported_rules") {
      if (!requireValue(argc, argv, &index, &value)) {
        printUsage();
        return 2;
      }
      config.supported_rule_types = splitRules(value);
    } else if (arg == "-allow_context_mismatch") {
      config.options.require_context_match = false;
    } else if (arg == "-allow_missing_hashes") {
      config.options.require_context_hashes = false;
    } else if (arg == "-allow_false_negative") {
      config.options.fail_on_false_negative = false;
    } else if (arg == "-fail_on_false_positive") {
      config.options.fail_on_false_positive = true;
    } else if (arg == "-fail_on_unsupported") {
      config.options.fail_on_unsupported = true;
    } else if (arg == "-h" || arg == "--help") {
      printUsage();
      return 0;
    } else {
      std::cerr << "Unknown idrc_calibre_compare option: " << arg << '\n';
      printUsage();
      return 2;
    }
  }

  return idrc::CalibreCompareTool::run(config) ? 0 : 1;
}
