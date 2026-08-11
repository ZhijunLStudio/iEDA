// ***************************************************************************************
// Copyright (c) 2023-2025 Peng Cheng Laboratory
// Copyright (c) 2023-2025 Institute of Computing Technology, Chinese Academy of Sciences
// Copyright (c) 2023-2025 Beijing Institute of Open Source Chip
//
// iEDA is licensed under Mulan PSL v2.
// ***************************************************************************************
#include <chrono>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <stdexcept>
#include <string>

#include "json.hpp"
#include "quality_gate.h"

namespace {

void require(bool condition, const std::string& message)
{
  if (!condition) {
    throw std::runtime_error(message);
  }
}

void writeText(const std::filesystem::path& path, const std::string& text)
{
  std::filesystem::create_directories(path.parent_path());
  std::ofstream output(path, std::ios::trunc);
  output << text;
  require(static_cast<bool>(output), "cannot write fixture: " + path.string());
}

void writeJson(const std::filesystem::path& path, const nlohmann::json& payload)
{
  writeText(path, payload.dump(2) + "\n");
}

auto readJson(const std::filesystem::path& path) -> nlohmann::json
{
  std::ifstream input(path);
  nlohmann::json payload;
  input >> payload;
  require(static_cast<bool>(input), "cannot read generated report: " + path.string());
  return payload;
}

auto gateByName(const nlohmann::json& report, const std::string& name) -> nlohmann::json
{
  for (const auto& gate : report.at("gates")) {
    if (gate.value("name", "") == name) {
      return gate;
    }
  }
  throw std::runtime_error("missing gate: " + name);
}

}  // namespace

int main()
{
  const auto nonce = std::chrono::steady_clock::now().time_since_epoch().count();
  const auto root = std::filesystem::temp_directory_path() / ("ieda_quality_gate_test_" + std::to_string(nonce));
  const auto output_path = root / "quality_gate.json";
  const auto summary_path = root / "report" / "drc" / "drc_summary.json";
  int result = 0;

  try {
    writeText(root / "iRT_result.def", "VERSION 5.8 ;\n");
    writeText(root / "final.gds", "GDSII\n");
    writeText(root / "report" / "drc" / "iRT_drc.rpt", "| Total | 0 | 100.00% |\n");
    writeJson(root / "rt" / "detailed_router" / "iter_dr_series.json",
              {{"residual_drc", 0}, {"residual_drc_by_type", nlohmann::json::object()}});

    writeJson(summary_path,
              {{"schema_version", "ieda.drc.coverage.v1"},
               {"status", "partial_clean"},
               {"check_profile", "idrc_fast_check_v1"},
               {"signoff_clean", false},
               {"violation_count", 0}});
    require(iplf::writeQualityGateJson(output_path.string(), root.string(), "", ""), "cannot write partial-clean report");
    auto drc_gate = gateByName(readJson(output_path), "drc_clean");
    require(drc_gate.at("status") == "fail", "partial_clean passed the platform DRC gate");
    require(drc_gate.at("reason").get<std::string>().find("partial_clean") != std::string::npos,
            "partial_clean failure reason is not explicit");

    std::filesystem::remove(summary_path);
    require(iplf::writeQualityGateJson(output_path.string(), root.string(), "", ""), "cannot write missing-summary report");
    drc_gate = gateByName(readJson(output_path), "drc_clean");
    require(drc_gate.at("status") == "fail", "missing iDRC coverage summary passed the platform DRC gate");

    writeJson(summary_path,
              {{"schema_version", "ieda.drc.coverage.v0"},
               {"status", "signoff_clean"},
               {"check_profile", "signoff"},
               {"signoff_clean", true},
               {"violation_count", 0}});
    require(iplf::writeQualityGateJson(output_path.string(), root.string(), "", ""), "cannot write unsupported-schema report");
    drc_gate = gateByName(readJson(output_path), "drc_clean");
    require(drc_gate.at("status") == "fail", "unsupported coverage schema passed the platform DRC gate");
    require(drc_gate.at("reason").get<std::string>().find("unsupported schema") != std::string::npos,
            "unsupported coverage schema failure reason is not explicit");

    writeJson(summary_path,
              {{"schema_version", "ieda.drc.coverage.v1"},
               {"status", "signoff_clean"},
               {"signoff_clean", true},
               {"violation_count", 0}});
    require(iplf::writeQualityGateJson(output_path.string(), root.string(), "", ""), "cannot write missing-profile report");
    drc_gate = gateByName(readJson(output_path), "drc_clean");
    require(drc_gate.at("status") == "fail", "coverage summary without check_profile passed the platform DRC gate");
    require(drc_gate.at("reason").get<std::string>().find("no check profile") != std::string::npos,
            "missing check_profile failure reason is not explicit");

    writeJson(summary_path,
              {{"schema_version", "ieda.drc.coverage.v1"},
               {"status", "signoff_clean"},
               {"check_profile", "signoff"},
               {"signoff_clean", true},
               {"violation_count", 0}});
    require(iplf::writeQualityGateJson(output_path.string(), root.string(), "", ""), "cannot write signoff-clean report");
    drc_gate = gateByName(readJson(output_path), "drc_clean");
    require(drc_gate.at("status") == "pass", "explicit signoff-clean evidence did not pass the platform DRC gate");

    std::cout << "quality gate DRC coverage tests passed\n";
  } catch (const std::exception& error) {
    std::cerr << "quality gate DRC coverage test failure: " << error.what() << '\n';
    result = 1;
  }

  std::error_code cleanup_error;
  std::filesystem::remove_all(root, cleanup_error);
  return result;
}
