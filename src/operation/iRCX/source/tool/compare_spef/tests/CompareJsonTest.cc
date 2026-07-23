#include <filesystem>
#include <fstream>
#include <iostream>
#include <stdexcept>

#include "config/CompareSpefConfig.hh"
#include "data/CompareSpefData.hh"
#include "json/json.hpp"
#include "report/ReportWriter.hh"

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
    result.tcap_rows = {
        {"n1", 1.0, 1.1, 0.1, 0.1},
        {"n2", 2.0, 1.8, -0.2, -0.1},
        {"n3", 3.0, 3.3, 0.3, 0.1}};
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
    if (!input || json.at("schema_version") != "ieda.rcx.compare.v1") {
      throw std::runtime_error("machine-readable schema is missing");
    }
    if (json.at("coverage").at("matched_net_count") != 3) {
      throw std::runtime_error("net coverage was not emitted");
    }
    const auto& total_cap = json.at("metrics").at("total_capacitance");
    if (total_cap.at("count") != 3 || total_cap.at("relative_p95").get<double>() <= 0.0 || total_cap.at("r_squared").is_null()) {
      throw std::runtime_error("component correlation statistics are incomplete");
    }

    std::cout << "CompareSpef JSON tests passed\n";
    return 0;
  } catch (const std::exception& error) {
    std::cerr << "CompareSpef JSON test failure: " << error.what() << '\n';
    return 1;
  }
}
