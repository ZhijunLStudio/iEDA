// ***************************************************************************************
// Copyright (c) 2023-2025 Peng Cheng Laboratory
// Copyright (c) 2023-2025 Institute of Computing Technology, Chinese Academy of Sciences
// Copyright (c) 2023-2025 Beijing Institute of Open Source Chip
//
// iEDA is licensed under Mulan PSL v2.
// ***************************************************************************************

#include "ieco_via.h"

#include <fstream>
#include <sstream>

#include "json/json.hpp"

namespace ieco {
namespace {

auto rectToJson(const ECORect& rect) -> nlohmann::ordered_json
{
  return {{"lx", rect.lx}, {"ly", rect.ly}, {"ux", rect.ux}, {"uy", rect.uy}};
}

auto changedShapeToJson(const ECOViaShapeRequest& shape) -> nlohmann::ordered_json
{
  return {{"shape_id", shape.shape_id}, {"layer", shape.layer}, {"bbox", rectToJson(shape.bbox)}, {"net", shape.net}};
}

auto setToJson(const std::set<std::string>& values) -> nlohmann::ordered_json
{
  nlohmann::ordered_json json = nlohmann::ordered_json::array();
  for (const auto& value : values) {
    json.push_back(value);
  }
  return json;
}

auto vectorToJson(const std::vector<ECOViaShapeRequest>& values) -> nlohmann::ordered_json
{
  nlohmann::ordered_json json = nlohmann::ordered_json::array();
  for (const auto& value : values) {
    json.push_back(changedShapeToJson(value));
  }
  return json;
}

auto probeToJson(const ECOFullOracleResult::Probe& probe) -> nlohmann::ordered_json
{
  return {{"ran", probe.ran}, {"ok", probe.ok}, {"source", probe.source}, {"reason", probe.reason}};
}

auto stableHash(const std::string& input) -> std::string
{
  uint64_t hash = 1469598103934665603ULL;
  for (unsigned char ch : input) {
    hash ^= ch;
    hash *= 1099511628211ULL;
  }
  std::ostringstream stream;
  stream << std::hex << hash;
  return stream.str();
}

}  // namespace

std::string toString(ECOViaStatus status)
{
  switch (status) {
    case ECOViaStatus::kSuccess:
      return "success";
    case ECOViaStatus::kUnsupported:
      return "unsupported";
    case ECOViaStatus::kInvalidType:
      return "invalid_type";
    case ECOViaStatus::kRejected:
      return "rejected";
    case ECOViaStatus::kFailed:
      return "failed";
    case ECOViaStatus::kRolledBack:
      return "rolled_back";
  }
  return "failed";
}

std::string toString(ECORequestState state)
{
  switch (state) {
    case ECORequestState::kAccepted:
      return "accepted";
    case ECORequestState::kRejected:
      return "rejected";
    case ECORequestState::kUnsupported:
      return "unsupported";
    case ECORequestState::kFailed:
      return "failed";
    case ECORequestState::kRolledBack:
      return "rolled_back";
  }
  return "failed";
}

std::string toString(ECORouteEditOwner owner)
{
  switch (owner) {
    case ECORouteEditOwner::kPlatform:
      return "platform";
    case ECORouteEditOwner::kIRT:
      return "irt";
    case ECORouteEditOwner::kIECO:
      return "ieco";
    case ECORouteEditOwner::kUnknown:
      return "unknown";
  }
  return "unknown";
}

bool requiresFullOracle(const ECOViaConfig& config)
{
  return config.full_oracle_period > 0 && config.request_index > 0 && config.request_index % config.full_oracle_period == 0;
}

std::optional<ECOFullOracleResult> runPeriodicFullOracle(const ECOViaConfig& config, const ECOFullOracleProbes& probes)
{
  if (!requiresFullOracle(config)) {
    return std::nullopt;
  }

  ECOFullOracleResult result;
  result.ran = true;
  if (probes.run_irt) {
    result.irt = probes.run_irt();
  } else {
    result.irt = {false, false, "iRT", "iRT full oracle probe missing"};
  }
  if (probes.run_idrc) {
    result.idrc = probes.run_idrc();
  } else {
    result.idrc = {false, false, "iDRC", "iDRC full oracle probe missing"};
  }
  if (probes.run_ista) {
    result.ista = probes.run_ista();
  } else {
    result.ista = {false, false, "iSTA", "iSTA full oracle probe missing"};
  }

  result.irt_ok = result.irt.ran && result.irt.ok;
  result.idrc_ok = result.idrc.ran && result.idrc.ok;
  result.ista_ok = result.ista.ran && result.ista.ok;
  if (!result.ok()) {
    if (!result.irt_ok) {
      result.reason = result.irt.reason.empty() ? "iRT full oracle failed" : result.irt.reason;
    } else if (!result.idrc_ok) {
      result.reason = result.idrc.reason.empty() ? "iDRC full oracle failed" : result.idrc.reason;
    } else {
      result.reason = result.ista.reason.empty() ? "iSTA full oracle failed" : result.ista.reason;
    }
  }

  return result;
}

ECOViaResult evaluateLegacyViaRequest(std::string_view type)
{
  const ECOViaRequest request = parseECOViaRequest(type);
  if (request.status == ECOViaStatus::kUnsupported || request.status == ECOViaStatus::kInvalidType) {
    ECOViaResult result(request.status, 0);
    result.reason = request.reason;
    return result;
  }

  ECOViaResult result(ECOViaStatus::kRejected, 0);
  result.reason = "legacy shape via ECO requires structured shape request, routeECO owner, and local/full oracle";
  return result;
}

ECOViaResult evaluateShapeRequest(const std::optional<ECOViaShapeRequest>& request, const ECOViaConfig& config,
                                  const ECOOracleResult& oracle, std::string baseline_hash)
{
  ECOViaResult result;
  result.baseline_hash = std::move(baseline_hash);
  result.rollback_hash = result.baseline_hash;
  result.oracle = oracle;
  result.request_index = config.request_index;
  result.full_oracle_period = config.full_oracle_period;
  result.full_oracle_required = requiresFullOracle(config);
  result.full_oracle = config.full_oracle;
  result.route_edit_owner = config.route_edit_owner;
  result.direct_db_route_write_requested = config.direct_db_route_write_requested;

  if (!request.has_value()) {
    result.status = ECOViaStatus::kRejected;
    result.state = ECORequestState::kRejected;
    result.reason = "shape request missing";
    return result;
  }
  if (request->layer.empty()) {
    result.status = ECOViaStatus::kRejected;
    result.state = ECORequestState::kRejected;
    result.reason = "shape request missing layer";
    return result;
  }
  if (request->bbox.lx >= request->bbox.ux || request->bbox.ly >= request->bbox.uy) {
    result.status = ECOViaStatus::kRejected;
    result.state = ECORequestState::kRejected;
    result.reason = "shape request has invalid bbox";
    return result;
  }
  if (config.freeze_layers.contains(request->layer)) {
    result.status = ECOViaStatus::kRejected;
    result.state = ECORequestState::kRejected;
    result.reason = "shape request touches frozen layer";
    return result;
  }
  if (!config.eco_layers.empty() && !config.eco_layers.contains(request->layer)) {
    result.status = ECOViaStatus::kRejected;
    result.state = ECORequestState::kRejected;
    result.reason = "shape request layer is outside eco_layers";
    return result;
  }
  if (config.direct_db_route_write_requested || config.route_edit_owner == ECORouteEditOwner::kIECO
      || config.route_edit_owner == ECORouteEditOwner::kUnknown) {
    result.status = ECOViaStatus::kRejected;
    result.state = ECORequestState::kRejected;
    result.reason = "route edit must be orchestrated by platform or iRT routeECO";
    return result;
  }

  result.changed_shapes.push_back(*request);
  result.changed_shape_count = 1;
  result.via_count = 1;
  result.repaired_count = 1;
  if (!request->net.empty()) {
    result.affected_nets.insert(request->net);
  }
  result.committed_hash = stableHash(result.baseline_hash + request->layer + request->shape_id + request->net);

  if (!oracle.ok()) {
    result.status = ECOViaStatus::kRolledBack;
    result.state = ECORequestState::kRolledBack;
    result.repaired_count = 0;
    result.changed_shape_count = 0;
    result.via_count = 0;
    result.committed_hash.clear();
    result.reason = "local oracle rejected shape ECO";
    return result;
  }
  if (result.full_oracle_required && (!result.full_oracle.has_value() || !result.full_oracle->ok())) {
    result.status = ECOViaStatus::kRolledBack;
    result.state = ECORequestState::kRolledBack;
    result.repaired_count = 0;
    result.changed_shape_count = 0;
    result.via_count = 0;
    result.committed_hash.clear();
    result.reason = result.full_oracle.has_value() && !result.full_oracle->reason.empty() ? result.full_oracle->reason
                                                                                         : "periodic full oracle did not pass";
    return result;
  }

  result.status = ECOViaStatus::kSuccess;
  result.state = ECORequestState::kAccepted;
  return result;
}

ECOViaResult evaluateShapeRequestWithFullOracle(const std::optional<ECOViaShapeRequest>& request, ECOViaConfig config,
                                                const ECOOracleResult& oracle, std::string baseline_hash,
                                                const ECOFullOracleProbes& probes)
{
  if (auto full_oracle = runPeriodicFullOracle(config, probes); full_oracle.has_value()) {
    config.full_oracle = std::move(full_oracle);
  }
  return evaluateShapeRequest(request, config, oracle, std::move(baseline_hash));
}

std::string ecoViaReportJson(const ECOViaResult& result)
{
  const nlohmann::ordered_json json
      = {{"schema_version", "ieda.eco.via_report.v1"},
         {"request_state", toString(result.state)},
         {"status", toString(result.status)},
         {"ok", result.ok()},
         {"reason", result.reason},
         {"changed_shape_count", result.changed_shape_count},
         {"changed_shapes", vectorToJson(result.changed_shapes)},
         {"via_count", result.via_count},
         {"affected_nets", setToJson(result.affected_nets)},
         {"local_oracle",
          {{"drc_before", result.oracle.local_drc_before},
           {"drc_after", result.oracle.local_drc_after},
           {"drc_improvement", result.oracle.drcImprovement()},
           {"connectivity_ok", result.oracle.connectivity_ok},
           {"route_legal", result.oracle.route_legal},
           {"improved", result.oracle.improved()},
           {"ok", result.oracle.ok()}}},
         {"full_oracle",
          {{"required", result.full_oracle_required},
           {"request_index", result.request_index},
           {"period", result.full_oracle_period},
           {"ran", result.full_oracle.has_value() && result.full_oracle->ran},
           {"irt_ok", result.full_oracle.has_value() && result.full_oracle->irt_ok},
           {"idrc_ok", result.full_oracle.has_value() && result.full_oracle->idrc_ok},
           {"ista_ok", result.full_oracle.has_value() && result.full_oracle->ista_ok},
           {"ok", result.full_oracle.has_value() && result.full_oracle->ok()},
           {"reason", result.full_oracle.has_value() ? result.full_oracle->reason : ""},
           {"probes",
            {{"irt", result.full_oracle.has_value() ? probeToJson(result.full_oracle->irt) : probeToJson({})},
             {"idrc", result.full_oracle.has_value() ? probeToJson(result.full_oracle->idrc) : probeToJson({})},
             {"ista", result.full_oracle.has_value() ? probeToJson(result.full_oracle->ista) : probeToJson({})}}}}},
         {"route_eco",
          {{"owner", toString(result.route_edit_owner)},
           {"direct_db_route_write_requested", result.direct_db_route_write_requested},
           {"delegated_to_platform_or_irt",
            !result.direct_db_route_write_requested
                && (result.route_edit_owner == ECORouteEditOwner::kPlatform || result.route_edit_owner == ECORouteEditOwner::kIRT)}}},
         {"transaction",
          {{"baseline_hash", result.baseline_hash},
           {"committed_hash", result.committed_hash},
           {"rollback_hash", result.rollback_hash},
           {"rollback_matches_baseline", !result.rollback_hash.empty() && result.rollback_hash == result.baseline_hash}}}};
  return json.dump(2);
}

bool writeEcoViaReportJson(const ECOViaResult& result, const std::string& path)
{
  std::ofstream output(path, std::ios::trunc);
  if (!output.is_open()) {
    return false;
  }
  output << ecoViaReportJson(result) << '\n';
  return static_cast<bool>(output);
}

}  // namespace ieco
