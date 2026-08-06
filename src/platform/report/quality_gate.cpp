// ***************************************************************************************
// Copyright (c) 2023-2025 Peng Cheng Laboratory
// Copyright (c) 2023-2025 Institute of Computing Technology, Chinese Academy of Sciences
// Copyright (c) 2023-2025 Beijing Institute of Open Source Chip
//
// iEDA is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
// http://license.coscl.org.cn/MulanPSL2
//
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
//
// See the Mulan PSL v2 for more details.
// ***************************************************************************************
#include "quality_gate.h"

#include <algorithm>
#include <chrono>
#include <filesystem>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <optional>
#include <regex>
#include <sstream>
#include <string>
#include <utility>
#include <vector>

#include "json.hpp"

namespace iplf {
namespace {

struct GateResult
{
  std::string name;
  std::string status;
  std::string severity;
  std::string domain;
  std::string reason;
  nlohmann::json evidence;
};

std::string timestampNow()
{
  const auto now = std::chrono::system_clock::now();
  const auto time = std::chrono::system_clock::to_time_t(now);
  std::tm tm{};
#if defined(_WIN32)
  localtime_s(&tm, &time);
#else
  localtime_r(&time, &tm);
#endif
  std::ostringstream oss;
  oss << std::put_time(&tm, "%Y-%m-%dT%H:%M:%S%z");
  return oss.str();
}

std::filesystem::path resultRoot(const std::string& configured_output_path)
{
  std::string output_path = configured_output_path;
  if (output_path.empty()) {
    output_path = ".";
  }
  return std::filesystem::path(output_path);
}

bool fileExists(const std::filesystem::path& path)
{
  std::error_code ec;
  return !path.empty() && std::filesystem::exists(path, ec) && std::filesystem::is_regular_file(path, ec) && !ec;
}

bool nonEmptyFileExists(const std::filesystem::path& path)
{
  std::error_code ec;
  return fileExists(path) && std::filesystem::file_size(path, ec) > 0 && !ec;
}

nlohmann::json fileEvidence(const std::filesystem::path& path)
{
  nlohmann::json evidence;
  evidence["path"] = path.string();
  evidence["exists"] = fileExists(path);
  if (evidence["exists"].get<bool>()) {
    std::error_code ec;
    const auto size = std::filesystem::file_size(path, ec);
    if (!ec) {
      evidence["size_bytes"] = size;
    }
  }
  return evidence;
}

std::optional<nlohmann::json> readJson(const std::filesystem::path& path)
{
  if (!nonEmptyFileExists(path)) {
    return std::nullopt;
  }
  try {
    std::ifstream input(path);
    nlohmann::json payload;
    input >> payload;
    return payload;
  } catch (...) {
    return std::nullopt;
  }
}

bool boolValue(const nlohmann::json& payload, const std::vector<std::string>& keys, bool default_value = false)
{
  for (const auto& key : keys) {
    if (payload.contains(key) && payload[key].is_boolean()) {
      return payload[key].get<bool>();
    }
  }
  return default_value;
}

bool anyBoolValue(const nlohmann::json& payload, const std::vector<std::string>& keys)
{
  for (const auto& key : keys) {
    if (payload.contains(key) && payload[key].is_boolean() && payload[key].get<bool>()) {
      return true;
    }
  }
  return false;
}

std::string stringValue(const nlohmann::json& payload, const std::vector<std::string>& keys)
{
  for (const auto& key : keys) {
    if (payload.contains(key) && payload[key].is_string()) {
      return payload[key].get<std::string>();
    }
  }
  return "";
}

bool textIsTrustedSource(const std::string& text, const std::vector<std::string>& trusted_values)
{
  for (const auto& trusted : trusted_values) {
    if (text == trusted) {
      return true;
    }
  }
  return false;
}

std::optional<int64_t> integerValue(const nlohmann::json& payload, const std::vector<std::string>& keys)
{
  for (const auto& key : keys) {
    if (payload.contains(key) && payload[key].is_number_integer()) {
      return payload[key].get<int64_t>();
    }
  }
  return std::nullopt;
}

double numericValue(const nlohmann::json& payload, const std::vector<std::string>& keys, double default_value = 0.0)
{
  for (const auto& key : keys) {
    if (payload.contains(key) && payload[key].is_number()) {
      return payload[key].get<double>();
    }
  }
  return default_value;
}

std::optional<double> firstRegexDouble(const std::filesystem::path& path, const std::regex& regex)
{
  if (!nonEmptyFileExists(path)) {
    return std::nullopt;
  }
  std::ifstream input(path);
  std::string line;
  while (std::getline(input, line)) {
    std::smatch match;
    if (!std::regex_search(line, match, regex)) {
      continue;
    }
    try {
      return std::stod(match[1].str());
    } catch (...) {
      return std::nullopt;
    }
  }
  return std::nullopt;
}

bool fileMatchesRegex(const std::filesystem::path& path, const std::regex& regex)
{
  if (!nonEmptyFileExists(path)) {
    return false;
  }
  std::ifstream input(path);
  std::string line;
  while (std::getline(input, line)) {
    if (std::regex_search(line, regex)) {
      return true;
    }
  }
  return false;
}

GateResult makeGate(const std::string& name, const std::string& status, const std::string& severity, const std::string& domain,
                    const std::string& reason, nlohmann::json evidence = nlohmann::json::object())
{
  return GateResult{name, status, severity, domain, reason, std::move(evidence)};
}

nlohmann::json gateToJson(const GateResult& gate)
{
  return nlohmann::json{{"name", gate.name},
                        {"status", gate.status},
                        {"severity", gate.severity},
                        {"domain", gate.domain},
                        {"reason", gate.reason.empty() ? nlohmann::json(nullptr) : nlohmann::json(gate.reason)},
                        {"evidence", gate.evidence}};
}

GateResult checkFlowCompletion(const std::filesystem::path& root)
{
  const auto routed_def = root / "iRT_result.def";
  nlohmann::json evidence;
  evidence["routed_def"] = fileEvidence(routed_def);
  evidence["final_gds"] = fileEvidence(root / "final.gds");
  if (!nonEmptyFileExists(routed_def)) {
    return makeGate("flow_completion", "fail", "hard", "flow", "missing non-empty routed DEF", evidence);
  }
  return makeGate("flow_completion", "pass", "hard", "flow", "", evidence);
}

GateResult checkLayoutExport(const std::filesystem::path& root)
{
  const auto final_gds = root / "final.gds";
  nlohmann::json evidence = fileEvidence(final_gds);
  if (!nonEmptyFileExists(final_gds)) {
    return makeGate("layout_export", "fail", "hard", "flow", "final.gds is missing; downstream signoff cannot inspect GDS", evidence);
  }
  return makeGate("layout_export", "pass", "hard", "flow", "", evidence);
}

GateResult checkDrcClean(const std::filesystem::path& root)
{
  const auto primary_series_path = root / "rt" / "detailed_router" / "iter_dr_series.json";
  const auto report_series_path = root / "report" / "rt" / "detailed_router" / "iter_dr_series.json";
  const auto series_path = nonEmptyFileExists(primary_series_path) ? primary_series_path : report_series_path;
  nlohmann::json evidence;
  evidence["iter_dr_series"] = fileEvidence(series_path);
  evidence["iter_dr_series_candidates"] = nlohmann::json::array({fileEvidence(primary_series_path), fileEvidence(report_series_path)});
  evidence["drc_report"] = fileEvidence(root / "report" / "drc" / "iRT_drc.rpt");

  const auto series = readJson(series_path);
  if (!series.has_value()) {
    return makeGate("drc_clean", "fail", "hard", "signoff", "missing detailed-router residual DRC JSON", evidence);
  }

  evidence["residual_drc_by_type"] = series->value("residual_drc_by_type", nlohmann::json::object());
  evidence["top_residual_drc_types"] = series->value("top_residual_drc_types", nlohmann::json::array());
  const auto residual_drc = integerValue(*series, {"residual_drc", "violation_num"});
  if (!residual_drc.has_value()) {
    return makeGate("drc_clean", "fail", "hard", "signoff", "iter_dr_series.json has no residual DRC count", evidence);
  }

  evidence["residual_drc"] = *residual_drc;
  if (*residual_drc != 0) {
    return makeGate("drc_clean", "fail", "hard", "signoff", "residual detailed-route DRC is non-zero", evidence);
  }
  return makeGate("drc_clean", "pass", "hard", "signoff", "", evidence);
}

GateResult checkConstraints(const std::filesystem::path& root, const std::string& configured_sdc_path)
{
  const std::filesystem::path sdc_path(configured_sdc_path);
  const auto sdc_lint_path = root / "timing" / "sdc_lint.json";
  nlohmann::json evidence = fileEvidence(sdc_path);
  evidence["sdc_lint"] = fileEvidence(sdc_lint_path);
  const auto sdc_lint = readJson(sdc_lint_path);
  if (sdc_lint.has_value()) {
    evidence["sdc_lint_summary"] = *sdc_lint;
  }
  if (!nonEmptyFileExists(sdc_path)) {
    return makeGate("constraints_loaded", "fail", "hard", "signoff", "configured SDC is missing or empty", evidence);
  }
  std::ifstream input(sdc_path);
  std::string line;
  int non_comment_lines = 0;
  bool has_clock = false;
  bool has_input_delay = false;
  bool has_output_delay = false;
  bool has_input_slew_or_driver = false;
  bool has_output_load = false;
  bool has_clock_uncertainty = false;
  while (std::getline(input, line)) {
    const auto first = line.find_first_not_of(" \t\r\n");
    if (first == std::string::npos || line[first] == '#') {
      continue;
    }
    ++non_comment_lines;
    if (line.find("create_clock") != std::string::npos || line.find("create_generated_clock") != std::string::npos) {
      has_clock = true;
    }
    if (line.find("set_input_delay") != std::string::npos) {
      has_input_delay = true;
    }
    if (line.find("set_output_delay") != std::string::npos) {
      has_output_delay = true;
    }
    if (line.find("set_input_transition") != std::string::npos || line.find("set_driving_cell") != std::string::npos) {
      has_input_slew_or_driver = true;
    }
    if (line.find("set_load") != std::string::npos) {
      has_output_load = true;
    }
    if (line.find("set_clock_uncertainty") != std::string::npos) {
      has_clock_uncertainty = true;
    }
  }
  evidence["non_comment_lines"] = non_comment_lines;
  evidence["has_clock"] = has_clock;
  evidence["has_input_delay"] = has_input_delay;
  evidence["has_output_delay"] = has_output_delay;
  evidence["has_input_slew_or_driver"] = has_input_slew_or_driver;
  evidence["has_output_load"] = has_output_load;
  evidence["has_clock_uncertainty"] = has_clock_uncertainty;
  if (non_comment_lines == 0) {
    return makeGate("constraints_loaded", "fail", "hard", "signoff", "configured SDC has no effective constraints", evidence);
  }
  if (!has_clock) {
    return makeGate("constraints_loaded", "fail", "hard", "signoff", "configured SDC has no create_clock/create_generated_clock", evidence);
  }
  if (!has_input_delay || !has_output_delay || !has_input_slew_or_driver || !has_clock_uncertainty) {
    return makeGate("constraints_loaded", "fail", "hard", "signoff",
                    "configured SDC lacks I/O delay, input slew/driver, or uncertainty evidence", evidence);
  }
  return makeGate("constraints_loaded", "pass", "hard", "signoff", "", evidence);
}

nlohmann::json timingNetDelayEvidence(const std::filesystem::path& root)
{
  nlohmann::json evidence;
  evidence["timing_report_candidates"] = nlohmann::json::array();
  evidence["sample_count"] = 0;
  evidence["nonzero_sample_count"] = 0;
  evidence["max_path_net_delay"] = 0.0;

  const auto timing_root = root / "timing";
  std::error_code ec;
  if (!std::filesystem::exists(timing_root, ec)) {
    evidence["timing_dir"] = fileEvidence(timing_root);
    return evidence;
  }

  std::vector<std::filesystem::path> reports;
  for (const auto& entry : std::filesystem::recursive_directory_iterator(timing_root, ec)) {
    if (ec) {
      break;
    }
    if (entry.is_regular_file(ec) && entry.path().extension() == ".rpt") {
      reports.push_back(entry.path());
    }
  }

  static const std::regex path_net_delay_regex(R"(path\s+net\s+delay.*?([-+]?[0-9]*\.?[0-9]+)\s*\()", std::regex::icase);
  int sample_count = 0;
  int nonzero_count = 0;
  double max_delay = 0.0;
  for (const auto& report : reports) {
    nlohmann::json report_evidence = fileEvidence(report);
    int report_samples = 0;
    int report_nonzero = 0;
    std::ifstream input(report);
    std::string line;
    while (std::getline(input, line)) {
      std::smatch match;
      if (!std::regex_search(line, match, path_net_delay_regex)) {
        continue;
      }
      try {
        const auto delay = std::stod(match[1].str());
        ++sample_count;
        ++report_samples;
        max_delay = std::max(max_delay, delay);
        if (delay > 0.0) {
          ++nonzero_count;
          ++report_nonzero;
        }
      } catch (...) {
      }
    }
    report_evidence["path_net_delay_samples"] = report_samples;
    report_evidence["nonzero_path_net_delay_samples"] = report_nonzero;
    evidence["timing_report_candidates"].push_back(report_evidence);
  }

  evidence["sample_count"] = sample_count;
  evidence["nonzero_sample_count"] = nonzero_count;
  evidence["max_path_net_delay"] = max_delay;
  return evidence;
}

bool rcxCoverageHasSpefFile(const nlohmann::json& coverage)
{
  if (coverage.contains("spef_file") && coverage["spef_file"].is_string()) {
    return nonEmptyFileExists(coverage["spef_file"].get<std::string>());
  }
  if (coverage.contains("spef_files") && coverage["spef_files"].is_array()) {
    for (const auto& spef_file : coverage["spef_files"]) {
      if (spef_file.is_string() && nonEmptyFileExists(spef_file.get<std::string>())) {
        return true;
      }
      if (spef_file.is_object() && spef_file.value("non_empty", false)) {
        return true;
      }
    }
  }

  return false;
}

bool rcxCoverageIsTrusted(const nlohmann::json& coverage)
{
  const auto source = stringValue(coverage, {"source", "status"});
  if (source == "missing" || source == "none" || source == "unsupported" || source == "skipped") {
    return false;
  }

  return boolValue(coverage, {"trusted"}) && rcxCoverageHasSpefFile(coverage);
}

GateResult checkSpefBackedSta(const std::filesystem::path& root, const std::string& configured_spef_path)
{
  const std::filesystem::path config_spef(configured_spef_path);
  const auto coverage_path = root / "rcx" / "rcx_coverage.json";
  nlohmann::json evidence;
  evidence["configured_spef"] = fileEvidence(config_spef);
  evidence["rcx_coverage"] = fileEvidence(coverage_path);
  evidence["timing_net_delay"] = timingNetDelayEvidence(root);

  bool spef_available = nonEmptyFileExists(config_spef);
  bool rcx_trusted = false;
  const auto coverage = readJson(coverage_path);
  if (coverage.has_value()) {
    evidence["coverage_summary"] = *coverage;
    rcx_trusted = rcxCoverageIsTrusted(*coverage);
  }

  if (!spef_available && !coverage.has_value()) {
    return makeGate("spef_backed_sta", "fail", "hard", "signoff", "missing SPEF path and RCX coverage evidence", evidence);
  }

  if (!spef_available && !rcx_trusted) {
    return makeGate("spef_backed_sta", "fail", "hard", "signoff", "STA is not backed by trusted SPEF/RCX evidence", evidence);
  }

  const int sample_count = evidence["timing_net_delay"].value("sample_count", 0);
  const int nonzero_count = evidence["timing_net_delay"].value("nonzero_sample_count", 0);
  if (sample_count == 0) {
    return makeGate("spef_backed_sta", "fail", "hard", "signoff", "timing report has no path net delay samples", evidence);
  }
  if (nonzero_count == 0) {
    return makeGate("spef_backed_sta", "fail", "hard", "signoff", "timing report path net delay samples are all zero", evidence);
  }

  return makeGate("spef_backed_sta", "pass", "hard", "signoff", "", evidence);
}

GateResult checkActivityBackedPower(const std::filesystem::path& root)
{
  const auto activity_path = root / "power" / "activity_source.json";
  nlohmann::json evidence;
  evidence["activity_source"] = fileEvidence(activity_path);

  const auto activity = readJson(activity_path);
  if (!activity.has_value()) {
    return makeGate("activity_backed_power", "fail", "hard", "signoff", "missing power activity provenance", evidence);
  }

  evidence["activity_summary"] = *activity;
  if (boolValue(*activity, {"refused"})) {
    return makeGate("activity_backed_power", "fail", "hard", "signoff", "power activity was refused", evidence);
  }

  const auto source = stringValue(*activity, {"activity_source", "source"});
  const bool trusted_source = textIsTrustedSource(source, {"vcd", "saif", "VCD", "SAIF"});
  const bool trusted_flag = boolValue(*activity, {"trusted"});
  const double measured_coverage = numericValue(*activity, {"measured_coverage", "coverage"});
  evidence["trusted_source"] = trusted_source;
  evidence["trusted_flag"] = trusted_flag;
  evidence["measured_coverage"] = measured_coverage;
  if (trusted_flag && trusted_source && measured_coverage > 0.0) {
    return makeGate("activity_backed_power", "pass", "hard", "signoff", "", evidence);
  }

  return makeGate("activity_backed_power", "fail", "hard", "signoff",
                  "power uses vectorless/default activity instead of trusted VCD/SAIF", evidence);
}

GateResult checkPdnReady(const std::filesystem::path& root)
{
  const auto pdn_path = root / "report" / "pdn_status.json";
  nlohmann::json evidence;
  evidence["pdn_status"] = fileEvidence(pdn_path);

  const auto pdn = readJson(pdn_path);
  if (!pdn.has_value()) {
    return makeGate("pdn_ready", "warn", "soft", "evidence", "missing PDN status evidence", evidence);
  }

  evidence["pdn_summary"] = *pdn;
  if (anyBoolValue(*pdn, {"ir_ready", "pdn_ready", "special_nets_detected"})) {
    return makeGate("pdn_ready", "pass", "soft", "evidence", "", evidence);
  }
  return makeGate("pdn_ready", "warn", "soft", "evidence", "PDN status does not indicate IR readiness", evidence);
}

bool pdnStatusIndicatesIrRun(const nlohmann::json& pdn)
{
  if (anyBoolValue(pdn, {"ir_run", "ir_drop_run", "ir_analyzed", "analysis_run"})) {
    return true;
  }
  const auto status = stringValue(pdn, {"ir_status", "status"});
  return status == "run" || status == "checked" || status == "pass" || status == "analyzed";
}

bool irStatusIndicatesRun(const nlohmann::json& status)
{
  if (!boolValue(status, {"trusted"})) {
    return false;
  }
  if (!status.contains("sample_count") || !status["sample_count"].is_number_integer() || status["sample_count"].get<int64_t>() <= 0) {
    return false;
  }
  if (status.contains("nets") && status["nets"].is_array() && !status["nets"].empty()) {
    return true;
  }
  return status.contains("worst_drop") || status.contains("worst_ir_drop") || status.contains("max_ir_drop")
         || status.contains("avg_drop") || status.contains("avg_ir_drop");
}

GateResult checkIrDrop(const std::filesystem::path& root)
{
  const auto pdn_path = root / "report" / "pdn_status.json";
  const auto power_ir_status_path = root / "power" / "ir_drop_status.json";
  const auto report_ir_status_path = root / "report" / "ir_drop_status.json";
  nlohmann::json evidence;
  evidence["pdn_status"] = fileEvidence(pdn_path);
  evidence["power_ir_drop_status"] = fileEvidence(power_ir_status_path);
  evidence["report_ir_drop_status"] = fileEvidence(report_ir_status_path);
  evidence["ir_drop_report"] = fileEvidence(root / "report" / "ir_drop.rpt");
  evidence["ir_report"] = fileEvidence(root / "ir" / "ir_drop.rpt");

  for (const auto& status_path : {power_ir_status_path, report_ir_status_path}) {
    const auto ir_status = readJson(status_path);
    if (ir_status.has_value()) {
      evidence["ir_drop_status"] = *ir_status;
      if (irStatusIndicatesRun(*ir_status)) {
        return makeGate("ir_drop_analyzed", "pass", "hard", "signoff", "", evidence);
      }
    }
  }

  const auto pdn = readJson(pdn_path);
  if (pdn.has_value()) {
    evidence["pdn_summary"] = *pdn;
    if (pdnStatusIndicatesIrRun(*pdn)) {
      return makeGate("ir_drop_analyzed", "fail", "hard", "signoff", "PDN only indicates IR readiness; missing IR-drop result evidence",
                      evidence);
    }
  }

  if (nonEmptyFileExists(root / "report" / "ir_drop.rpt") || nonEmptyFileExists(root / "ir" / "ir_drop.rpt")) {
    return makeGate("ir_drop_analyzed", "fail", "hard", "signoff",
                    "IR report exists but lacks structured trusted status evidence", evidence);
  }

  return makeGate("ir_drop_analyzed", "fail", "hard", "signoff", "IR-drop analysis evidence is missing or only marked IR-ready",
                  evidence);
}

GateResult checkCongestionSummary(const std::filesystem::path& root)
{
  const auto congestion_path = root / "congestion_summary.json";
  nlohmann::json evidence;
  evidence["congestion_summary"] = fileEvidence(congestion_path);

  const auto congestion = readJson(congestion_path);
  if (!congestion.has_value()) {
    return makeGate("congestion_summary", "fail", "hard", "signoff", "missing congestion_summary.json", evidence);
  }

  evidence["schema"] = congestion->value("schema", "");
  evidence["summary"] = congestion->value("summary", nlohmann::json::object());
  if (congestion->value("valid", true) == false) {
    return makeGate("congestion_summary", "fail", "hard", "signoff", "congestion summary exists but is marked invalid", evidence);
  }
  return makeGate("congestion_summary", "pass", "hard", "signoff", "", evidence);
}

nlohmann::json parseWirelengthReport(const std::filesystem::path& root)
{
  const auto wirelength_path = root / "report" / "wirelength.rpt";
  nlohmann::json result;
  result["file"] = fileEvidence(wirelength_path);
  if (!nonEmptyFileExists(wirelength_path)) {
    return result;
  }

  static const std::regex hpwl_regex(R"(\|\s*HPWL\s*\|\s*([-+]?[0-9]*\.?[0-9]+))", std::regex::icase);
  static const std::regex flute_regex(R"(\|\s*FLUTE\s*\|\s*([-+]?[0-9]*\.?[0-9]+))", std::regex::icase);
  static const std::regex egr_regex(R"(\|\s*EGR\s*\|\s*([-+]?[0-9]*\.?[0-9]+))", std::regex::icase);
  if (const auto value = firstRegexDouble(wirelength_path, hpwl_regex)) {
    result["hpwl"] = *value;
  }
  if (const auto value = firstRegexDouble(wirelength_path, flute_regex)) {
    result["flute"] = *value;
  }
  if (const auto value = firstRegexDouble(wirelength_path, egr_regex)) {
    result["egr"] = *value;
  }
  return result;
}

nlohmann::json parsePowerReport(const std::filesystem::path& root)
{
  const auto power_path = root / "power" / "aes_cipher_top.pwr";
  const auto power_json_path = root / "power" / "aes_cipher_top.pwr.json";
  const auto activity_path = root / "power" / "activity_source.json";
  nlohmann::json result;
  result["report"] = fileEvidence(power_path);
  result["json_report"] = fileEvidence(power_json_path);
  result["activity_source_file"] = fileEvidence(activity_path);

  const auto power_json = readJson(power_json_path);
  if (power_json.has_value()) {
    result["json_summary"] = *power_json;
  }
  const auto activity = readJson(activity_path);
  if (activity.has_value()) {
    result["activity_source"] = activity->value("activity_source", activity->value("source", ""));
    result["activity_trusted"] = activity->value("trusted", false);
    result["toggle_default"] = numericValue(*activity, {"toggle_default"}, 0.0);
  }

  static const std::regex switch_regex(R"(Net\s+Switch\s+Power\s*==\s*([-+]?[0-9]*\.?[0-9]+(?:[eE][-+]?[0-9]+)?))");
  static const std::regex internal_regex(R"(Cell\s+Internal\s+Power\s*==\s*([-+]?[0-9]*\.?[0-9]+(?:[eE][-+]?[0-9]+)?))");
  static const std::regex leakage_regex(R"(Cell\s+Leakage\s+Power\s*==\s*([-+]?[0-9]*\.?[0-9]+(?:[eE][-+]?[0-9]+)?))");
  static const std::regex total_regex(R"(Total\s+Power\s*==\s*([-+]?[0-9]*\.?[0-9]+(?:[eE][-+]?[0-9]+)?))");
  static const std::regex nonfinite_regex(R"((^|[^A-Za-z0-9_])[-+]?nan([^A-Za-z0-9_]|$))", std::regex::icase);
  if (const auto value = firstRegexDouble(power_path, switch_regex)) {
    result["switch_power_w"] = *value;
  }
  if (const auto value = firstRegexDouble(power_path, internal_regex)) {
    result["internal_power_w"] = *value;
  }
  if (const auto value = firstRegexDouble(power_path, leakage_regex)) {
    result["leakage_power_w"] = *value;
  }
  if (const auto value = firstRegexDouble(power_path, total_regex)) {
    result["total_power_w"] = *value;
  }
  result["has_nonfinite_power_value"] = fileMatchesRegex(power_path, nonfinite_regex);
  result["finite_total_power"] = result.contains("total_power_w") && !result["has_nonfinite_power_value"].get<bool>();
  return result;
}

nlohmann::json buildStageObservations(const std::filesystem::path& root)
{
  nlohmann::json observations;
  observations["schema"] = "c-stage-observations/v1";
  observations["schema_version"] = 1;

  const auto place_summary_path = root / "pl" / "report" / "place_summary.json";
  const auto congestion_path = root / "congestion_summary.json";
  const auto iter_delta_path = root / "rt" / "detailed_router" / "iter_delta.json";
  const auto iter_series_path = root / "rt" / "detailed_router" / "iter_dr_series.json";

  observations["files"] = {{"place_summary", fileEvidence(place_summary_path)},
                           {"congestion_summary", fileEvidence(congestion_path)},
                           {"iter_delta", fileEvidence(iter_delta_path)},
                           {"iter_dr_series", fileEvidence(iter_series_path)}};

  const auto place_summary = readJson(place_summary_path);
  if (place_summary.has_value()) {
    observations["placement"]["status"] = place_summary->value("status", "");
    observations["placement"]["flow_complete"] = place_summary->value("flow_complete", false);
    observations["placement"]["quality_success"] = place_summary->value("quality_success", false);
    if (place_summary->contains("legalization") && (*place_summary)["legalization"].is_object()) {
      const auto& legalization = (*place_summary)["legalization"];
      observations["placement"]["legalization"] = {{"status", legalization.value("status", "")},
                                                   {"legal", legalization.value("legal", false)},
                                                   {"hpwl", legalization.value("hpwl", 0.0)},
                                                   {"overflow", legalization.value("overflow", 0.0)}};
    }
  }

  observations["routing"]["wirelength"] = parseWirelengthReport(root);
  const auto congestion = readJson(congestion_path);
  if (congestion.has_value()) {
    observations["routing"]["congestion"] = congestion->value("summary", nlohmann::json::object());
    if (observations["routing"]["congestion"].empty()) {
      observations["routing"]["congestion"] = {{"average", congestion->value("average", 0.0)},
                                               {"total_overflow", congestion->value("total_overflow", 0.0)},
                                               {"max_overflow", congestion->value("max_overflow", 0.0)},
                                               {"top1_pct", congestion->value("top1_pct", 0.0)},
                                               {"top5_pct", congestion->value("top5_pct", 0.0)}};
    }
  }

  const auto iter_delta = readJson(iter_delta_path);
  if (iter_delta.has_value()) {
    observations["routing"]["iter_delta"] = *iter_delta;
  }
  const auto iter_series = readJson(iter_series_path);
  if (iter_series.has_value()) {
    observations["routing"]["detailed_route"] = {{"residual_drc", iter_series->value("residual_drc", -1)},
                                                 {"residual_drc_by_type",
                                                  iter_series->value("residual_drc_by_type", nlohmann::json::object())},
                                                 {"top_residual_drc_types",
                                                  iter_series->value("top_residual_drc_types", nlohmann::json::array())},
                                                 {"plateau_detected", iter_series->value("plateau_detected", false)},
                                                 {"route_complete", iter_series->value("route_complete", false)}};
  }

  observations["timing"]["net_delay"] = timingNetDelayEvidence(root);
  observations["power"] = parsePowerReport(root);

  if (observations["placement"].contains("legalization") && observations["routing"].contains("wirelength")
      && observations["routing"]["wirelength"].contains("hpwl")) {
    const double place_hpwl = observations["placement"]["legalization"].value("hpwl", 0.0);
    const double route_hpwl = observations["routing"]["wirelength"].value("hpwl", 0.0);
    observations["deltas"]["hpwl_route_minus_place"] = route_hpwl - place_hpwl;
  }
  if (observations["routing"].contains("iter_delta") && observations["routing"]["iter_delta"].contains("iterations")
      && observations["routing"]["iter_delta"]["iterations"].is_array() && !observations["routing"]["iter_delta"]["iterations"].empty()) {
    const auto& iterations = observations["routing"]["iter_delta"]["iterations"];
    const int64_t first_drc = iterations.front().value("drc_total", 0);
    const int64_t last_drc = iterations.back().value("drc_total", first_drc);
    observations["deltas"]["drc_last_minus_first"] = last_drc - first_drc;
  }

  return observations;
}

GateResult checkStageObservability(const nlohmann::json& observations)
{
  nlohmann::json evidence;
  evidence["has_placement"] = observations.contains("placement");
  evidence["has_congestion"] = observations.contains("routing") && observations["routing"].contains("congestion");
  evidence["has_iter_delta"] = observations.contains("routing") && observations["routing"].contains("iter_delta");
  evidence["has_timing_net_delay"] = observations.contains("timing") && observations["timing"].contains("net_delay");
  evidence["has_power"] = observations.contains("power") && observations["power"].contains("report");

  const bool complete = evidence["has_placement"].get<bool>() && evidence["has_congestion"].get<bool>()
                        && evidence["has_iter_delta"].get<bool>() && evidence["has_timing_net_delay"].get<bool>()
                        && evidence["has_power"].get<bool>();
  if (!complete) {
    return makeGate("stage_observability", "warn", "soft", "evidence", "missing one or more stage observation snapshots", evidence);
  }
  return makeGate("stage_observability", "pass", "soft", "evidence", "", evidence);
}

nlohmann::json buildReport(const std::filesystem::path& root, const std::vector<GateResult>& gates,
                           const nlohmann::json& stage_observations)
{
  int hard_fail = 0;
  int hard_pass = 0;
  int warn = 0;
  int soft_pass = 0;
  int flow_fail = 0;
  int flow_pass = 0;
  int signoff_fail = 0;
  int signoff_pass = 0;

  nlohmann::json gate_array = nlohmann::json::array();
  for (const auto& gate : gates) {
    gate_array.push_back(gateToJson(gate));
    if (gate.severity == "hard" && gate.status == "fail") {
      ++hard_fail;
    } else if (gate.severity == "hard" && gate.status == "pass") {
      ++hard_pass;
    } else if (gate.status == "warn") {
      ++warn;
    } else if (gate.severity == "soft" && gate.status == "pass") {
      ++soft_pass;
    }
    if (gate.domain == "flow" && gate.status == "fail") {
      ++flow_fail;
    } else if (gate.domain == "flow" && gate.status == "pass") {
      ++flow_pass;
    } else if (gate.domain == "signoff" && gate.status == "fail") {
      ++signoff_fail;
    } else if (gate.domain == "signoff" && gate.status == "pass") {
      ++signoff_pass;
    }
  }

  const bool flow_success = flow_fail == 0;
  const bool signoff_success = flow_success && signoff_fail == 0;

  return nlohmann::json{{"schema", "c-quality-gate/v2"},
                        {"schema_version", 2},
                        {"stage", "post_route"},
                        {"generated_at", timestampNow()},
                        {"output_path", root.string()},
                        {"flow_success", flow_success},
                        {"signoff_success", signoff_success},
                        {"overall_status", signoff_success ? "pass" : "fail"},
                        {"flow_status", flow_success ? "pass" : "fail"},
                        {"signoff_status", signoff_success ? "pass" : "fail"},
                        {"flow", {{"success", flow_success}, {"pass", flow_pass}, {"fail", flow_fail}}},
                        {"signoff", {{"success", signoff_success}, {"pass", signoff_pass}, {"fail", signoff_fail}}},
                        {"summary",
                         {{"hard_pass", hard_pass}, {"hard_fail", hard_fail}, {"soft_pass", soft_pass}, {"warn", warn}}},
                        {"stage_observations", stage_observations},
                        {"gates", gate_array}};
}

}  // namespace

bool writeQualityGateJson(const std::string& file_name, const std::string& result_path, const std::string& sdc_path,
                          const std::string& spef_path)
{
  const auto root = resultRoot(result_path);
  std::vector<GateResult> gates;
  gates.push_back(checkFlowCompletion(root));
  gates.push_back(checkLayoutExport(root));
  gates.push_back(checkDrcClean(root));
  gates.push_back(checkConstraints(root, sdc_path));
  gates.push_back(checkSpefBackedSta(root, spef_path));
  gates.push_back(checkActivityBackedPower(root));
  gates.push_back(checkPdnReady(root));
  gates.push_back(checkIrDrop(root));
  gates.push_back(checkCongestionSummary(root));
  const nlohmann::json stage_observations = buildStageObservations(root);
  gates.push_back(checkStageObservability(stage_observations));

  std::filesystem::path report_path = file_name.empty() ? root / "quality_gate.json" : std::filesystem::path(file_name);
  try {
    if (!report_path.parent_path().empty()) {
      std::filesystem::create_directories(report_path.parent_path());
    }
    std::ofstream output(report_path, std::ios::out | std::ios_base::trunc);
    if (!output.is_open()) {
      std::cerr << "Failed to open quality gate report: " << report_path << std::endl;
      return false;
    }
    output << buildReport(root, gates, stage_observations).dump(2) << std::endl;
  } catch (const std::exception& e) {
    std::cerr << "Failed to write quality gate report: " << e.what() << std::endl;
    return false;
  }

  std::cout << "Quality gate report written to " << report_path << std::endl;
  return true;
}

}  // namespace iplf
