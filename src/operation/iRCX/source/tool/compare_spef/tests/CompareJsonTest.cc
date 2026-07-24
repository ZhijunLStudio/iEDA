#include <filesystem>
#include <fstream>
#include <iostream>
#include <stdexcept>
#include <string_view>

#include "config/CompareSpefConfig.hh"
#include "data/CompareSpefData.hh"
#include "json/json.hpp"
#include "report/ReportWriter.hh"

namespace {

auto hasBlockingReason(const nlohmann::json& gate, std::string_view expected) -> bool
{
  for (const auto& reason : gate.at("blocking_reasons")) {
    if (reason.get<std::string>() == expected) {
      return true;
    }
  }
  return false;
}

}  // namespace

int main()
{
  try {
    const auto output_dir = std::filesystem::temp_directory_path() / "ieda_compare_spef_json";
    std::filesystem::remove_all(output_dir);

    ircx::compare_spef::Config config;
    config.test_file = "test.spef";
    config.reference_file = "reference.spef";
    config.output_dir = output_dir.string();
    config.emit_compare_json = true;

    ircx::compare_spef::Result result;
    result.summary.reference_net_count = 3;
    result.summary.test_net_count = 3;
    result.summary.matched_net_count = 3;
    result.summary.reference_coupling_count = 2;
    result.summary.test_coupling_count = 2;
    result.summary.reference_only_coupling_count = 1;
    result.summary.test_only_coupling_count = 1;
    result.tcap_rows = {
        {"n1", 1.0, 1.1, 0.1, 0.1},
        {"n2", 2.0, 1.8, -0.2, -0.1},
        {"n3", 3.0, 3.3, 0.3, 0.1},
        {"n0", 0.0, 0.2, 0.2, std::nullopt}};
    result.gcap_rows = {
        {{"n1", 0.5, 0.55, 0.05, 0.1}}};
    result.ccap_rows = {
        {"n1", "n2", 0.2, 0.18, -0.02, 1.0, -0.1}};
    result.p2p_rows = {
        {{"n1", 10.0, 11.0, 1.0, 0.1}, "a", "b", true, true}};

    ircx::compare_spef::ReportWriter writer(config);
    if (!writer.write(result)) {
      throw std::runtime_error("ReportWriter rejected valid comparison data");
    }

    std::ifstream input(output_dir / "compare.json");
    nlohmann::json json;
    input >> json;
    if (!input || json.at("schema_version") != "ieda.rcx.compare.v2") {
      throw std::runtime_error("machine-readable schema is missing");
    }
    const auto& coverage = json.at("coverage");
    if (coverage.at("matched_net_count") != 3 || coverage.at("reference_net_coverage") != 1.0
        || coverage.at("matched_coupling_count") != 1 || coverage.at("reference_coupling_coverage") != 0.5) {
      throw std::runtime_error("two-sided coverage was not emitted");
    }
    if (json.at("units").at("capacitance") != "fF"
        || json.at("sample_selection").at("role") != "sample_floor_not_acceptance_limit") {
      throw std::runtime_error("unit and sample-floor semantics are missing");
    }
    const auto& total_cap = json.at("metrics").at("total_capacitance");
    if (total_cap.at("count") != 4 || total_cap.at("absolute_p95").get<double>() <= 0.0
        || total_cap.at("relative_error_count") != 3 || total_cap.at("relative_error_excluded_count") != 1
        || total_cap.at("relative_p95").get<double>() <= 0.0 || total_cap.at("r_squared").is_null()) {
      throw std::runtime_error("component correlation statistics are incomplete");
    }
    const auto& gate = json.at("joint_gate");
    if (gate.at("gate") != "G8" || gate.at("verdict") != "incomplete" || gate.at("complete") != false || gate.at("pass") != false
        || gate.at("required_dimensions").at("ground_capacitance").at("status") != "measured"
        || gate.at("required_dimensions").at("wire_resistance").at("status") != "unsupported"
        || !hasBlockingReason(gate, "wire_resistance_not_decomposed")
        || !hasBlockingReason(gate, "critical_slack_not_compared")
        || !hasBlockingReason(gate, "frozen_acceptance_limits_not_attached")) {
      throw std::runtime_error("G8 joint gate can become falsely green");
    }

    ircx::compare_spef::Config empty_config = config;
    const auto empty_output_dir = output_dir / "empty";
    empty_config.output_dir = empty_output_dir.string();
    ircx::compare_spef::Result empty_result;
    empty_result.summary.reference_net_count = 1;
    empty_result.summary.test_net_count = 0;
    ircx::compare_spef::ReportWriter empty_writer(empty_config);
    if (!empty_writer.write(empty_result)) {
      throw std::runtime_error("ReportWriter rejected an empty comparison");
    }
    std::ifstream empty_input(empty_output_dir / "compare.json");
    nlohmann::json empty_json;
    empty_input >> empty_json;
    const auto& empty_metric = empty_json.at("metrics").at("ground_capacitance");
    const auto& empty_gate = empty_json.at("joint_gate");
    if (!empty_metric.at("absolute_p95").is_null() || !empty_metric.at("relative_p95").is_null()
        || !empty_json.at("coverage").at("test_net_coverage").is_null()
        || !hasBlockingReason(empty_gate, "ground_capacitance_has_no_samples")) {
      throw std::runtime_error("empty data was reported as a measured zero error");
    }

    std::cout << "CompareSpef JSON tests passed\n";
    return 0;
  } catch (const std::exception& error) {
    std::cerr << "CompareSpef JSON test failure: " << error.what() << '\n';
    return 1;
  }
}
