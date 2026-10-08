// ***************************************************************************************
// Copyright (c) 2023-2025 Peng Cheng Laboratory
// Copyright (c) 2023-2025 Institute of Computing Technology, Chinese Academy of Sciences
// Copyright (c) 2023-2025 Beijing Institute of Open Source Chip
//
// iEDA is licensed under Mulan PSL v2.
// ***************************************************************************************
#include "FlowScheduler.hh"

#include <algorithm>
#include <cctype>
#include <fstream>
#include <iomanip>
#include <optional>
#include <sstream>
#include <system_error>
#include <utility>

namespace ieda::platform {

namespace {

struct ProductSnapshot
{
  std::filesystem::path path;
  uintmax_t size = 0;
  std::filesystem::file_time_type::rep modified = 0;
};

struct SuccessStamp
{
  std::string stage;
  std::string run_identity;
  double wall_ms = 0.0;
  std::vector<ProductSnapshot> products;
};

std::optional<SuccessStamp> readSuccessStamp(const std::filesystem::path& path)
{
  std::ifstream input(path);
  if (!input) {
    return std::nullopt;
  }

  SuccessStamp stamp;
  std::string key;
  unsigned format = 0;
  size_t product_count = 0;
  if (!(input >> key >> format) || key != "format" || format != 2U || !(input >> key >> std::quoted(stamp.stage))
      || key != "stage" || !(input >> key >> std::quoted(stamp.run_identity)) || key != "run_identity"
      || !(input >> key >> stamp.wall_ms) || key != "wall_ms" || !(input >> key >> product_count) || key != "product_count") {
    return std::nullopt;
  }

  stamp.products.reserve(product_count);
  for (size_t index = 0; index < product_count; ++index) {
    ProductSnapshot product;
    std::string path_string;
    if (!(input >> key >> std::quoted(path_string)) || key != "product" || !(input >> product.size >> product.modified)) {
      return std::nullopt;
    }
    product.path = std::move(path_string);
    stamp.products.push_back(std::move(product));
  }
  input >> std::ws;
  if (!input.eof()) {
    return std::nullopt;
  }
  return stamp;
}

}  // namespace

FlowScheduler::FlowScheduler(std::filesystem::path work_dir)
{
  setWorkDir(std::move(work_dir));
}

void FlowScheduler::registerStage(Stage stage)
{
  if (stage.name.empty()) {
    throw FlowContractError("stage name must not be empty");
  }
  if (!stage.run) {
    throw FlowContractError("stage '" + stage.name + "' has no run callback");
  }
  if (_stages.contains(stage.name)) {
    throw FlowContractError("duplicate stage registration: " + stage.name);
  }
  std::set<std::string> unique_dependencies;
  for (const auto& dependency : stage.prerequisites) {
    if (dependency.empty()) {
      throw FlowContractError("stage '" + stage.name + "' has an empty dependency");
    }
    if (!unique_dependencies.insert(dependency).second) {
      throw FlowContractError("stage '" + stage.name + "' repeats dependency '" + dependency + "'");
    }
  }
  _profile[stage.name] = {};
  _stages.emplace(stage.name, std::move(stage));
}

bool FlowScheduler::unregisterStage(const std::string& name)
{
  _profile.erase(name);
  _success_stamps.erase(name);
  return _stages.erase(name) != 0;
}

void FlowScheduler::clearStages()
{
  _stages.clear();
  resetRunState();
}

std::vector<std::string> FlowScheduler::validateAndTopologicalOrder() const
{
  std::map<std::string, size_t> indegree;
  std::map<std::string, std::vector<std::string>> dependents;
  for (const auto& [name, stage] : _stages) {
    static_cast<void>(stage);
    indegree[name] = 0;
  }
  for (const auto& [name, stage] : _stages) {
    for (const auto& dependency : stage.prerequisites) {
      if (!_stages.contains(dependency)) {
        throw FlowContractError("stage '" + name + "' requires missing stage '" + dependency + "'");
      }
      ++indegree[name];
      dependents[dependency].push_back(name);
    }
  }

  std::set<std::string> ready;
  for (const auto& [name, degree] : indegree) {
    if (degree == 0) {
      ready.insert(name);
    }
  }

  std::vector<std::string> order;
  order.reserve(_stages.size());
  while (!ready.empty()) {
    auto ready_iter = ready.begin();
    const std::string stage = *ready_iter;
    ready.erase(ready_iter);
    order.push_back(stage);
    for (const auto& dependent : dependents[stage]) {
      auto& degree = indegree[dependent];
      --degree;
      if (degree == 0) {
        ready.insert(dependent);
      }
    }
  }

  if (order.size() != _stages.size()) {
    std::vector<std::string> cycle_members;
    for (const auto& [name, degree] : indegree) {
      if (degree != 0) {
        cycle_members.push_back(name);
      }
    }
    std::ostringstream message;
    message << "cycle detected in flow contract";
    for (const auto& member : cycle_members) {
      message << (member == cycle_members.front() ? ": " : ", ") << member;
    }
    throw FlowContractError(message.str());
  }
  return order;
}

FlowRunResult FlowScheduler::run(const std::vector<std::string>& requested_plan)
{
  const auto topological_order = validateAndTopologicalOrder();
  const auto& plan = requested_plan.empty() ? topological_order : requested_plan;
  validatePlan(plan);

  FlowRunResult result;
  for (size_t index = 0; index < plan.size(); ++index) {
    const auto& stage_name = plan[index];
    auto& stage = _stages.at(stage_name);
    auto& stage_profile = _profile.at(stage_name);
    if (stage_profile.status == StageStatus::kSucceeded) {
      continue;
    }
    if (!isReady(stage_name)) {
      result.return_code = 1;
      result.failed_stage = stage_name;
      result.reason = "stage prerequisites are not satisfied";
      stage_profile.status = StageStatus::kBlocked;
      stage_profile.reason = result.reason;
      markRemainingBlocked(plan, index, "aborted after blocked stage '" + stage_name + "'");
      return result;
    }

    stage_profile = {};
    stage_profile.status = StageStatus::kRunning;
    const auto start = std::chrono::steady_clock::now();
    bool succeeded = false;
    try {
      if (stage.on_start) {
        stage.on_start();
      }
      succeeded = stage.run();
    } catch (const std::exception& error) {
      stage_profile.reason = std::string("stage callback threw: ") + error.what();
    } catch (...) {
      stage_profile.reason = "stage callback threw a non-standard exception";
    }
    const auto stop = std::chrono::steady_clock::now();
    stage_profile.wall_ms = std::chrono::duration<double, std::milli>(stop - start).count();
    result.executed_stages.push_back(stage_name);

    if (!succeeded) {
      if (stage_profile.reason.empty()) {
        stage_profile.reason = "stage callback returned false";
      }
      stage_profile.status = StageStatus::kFailed;
      result.return_code = 1;
      result.failed_stage = stage_name;
      result.reason = stage_profile.reason;
      markRemainingBlocked(plan, index, "aborted after failed stage '" + stage_name + "'");
      return result;
    }

    const auto missing_products = missingProducts(stage);
    if (!missing_products.empty()) {
      std::ostringstream message;
      message << "stage succeeded without required non-empty product";
      for (const auto& product : missing_products) {
        message << (product == missing_products.front() ? ": " : ", ") << product.string();
      }
      stage_profile.status = StageStatus::kFailed;
      stage_profile.reason = message.str();
      result.return_code = 1;
      result.failed_stage = stage_name;
      result.reason = stage_profile.reason;
      markRemainingBlocked(plan, index, "aborted after product assertion for stage '" + stage_name + "'");
      return result;
    }

    try {
      if (stage.on_success) {
        stage.on_success();
      }
      stage_profile.status = StageStatus::kSucceeded;
      stage_profile.reason.clear();
      stampSuccess(stage_name, stage_profile);
      _success_stamps.insert(stage_name);
    } catch (const std::exception& error) {
      stage_profile.status = StageStatus::kFailed;
      stage_profile.reason = std::string("success finalization failed: ") + error.what();
      result.return_code = 1;
      result.failed_stage = stage_name;
      result.reason = stage_profile.reason;
      markRemainingBlocked(plan, index, "aborted after finalization failure for stage '" + stage_name + "'");
      return result;
    }
  }
  return result;
}

bool FlowScheduler::isReady(const std::string& stage_name) const
{
  const auto stage_iter = _stages.find(stage_name);
  if (stage_iter == _stages.end()) {
    return false;
  }
  return std::all_of(stage_iter->second.prerequisites.begin(), stage_iter->second.prerequisites.end(),
                     [this](const std::string& dependency) { return hasSucceeded(dependency); });
}

bool FlowScheduler::hasSucceeded(const std::string& stage) const
{
  return _success_stamps.contains(stage);
}

StageStatus FlowScheduler::status(const std::string& stage) const
{
  const auto iter = _profile.find(stage);
  if (iter == _profile.end()) {
    throw FlowContractError("unknown stage: " + stage);
  }
  return iter->second.status;
}

void FlowScheduler::resetRunState()
{
  _success_stamps.clear();
  _profile.clear();
  for (const auto& [name, stage] : _stages) {
    static_cast<void>(stage);
    _profile[name] = {};
  }
}

void FlowScheduler::setWorkDir(std::filesystem::path work_dir)
{
  if (work_dir.empty()) {
    throw FlowContractError("flow work directory must not be empty");
  }
  _work_dir = std::filesystem::absolute(std::move(work_dir)).lexically_normal();
}

void FlowScheduler::setRunIdentity(std::string run_identity)
{
  if (run_identity.empty()) {
    throw FlowContractError("flow run identity must not be empty");
  }
  if (std::any_of(run_identity.begin(), run_identity.end(),
                  [](unsigned char character) { return std::iscntrl(character) != 0; })) {
    throw FlowContractError("flow run identity must not contain control characters");
  }
  _run_identity = std::move(run_identity);
}

std::vector<std::string> FlowScheduler::restoreRunState()
{
  if (_run_identity.empty()) {
    throw FlowContractError("cannot restore flow state without a run identity");
  }

  resetRunState();
  const auto order = validateAndTopologicalOrder();
  const auto stamp_directory = _stamp_dir.is_absolute() ? _stamp_dir : _work_dir / _stamp_dir;
  std::vector<std::string> restored;
  for (const auto& stage_name : order) {
    const auto& stage = _stages.at(stage_name);
    if (!std::all_of(stage.prerequisites.begin(), stage.prerequisites.end(),
                     [this](const std::string& dependency) { return hasSucceeded(dependency); })) {
      continue;
    }

    const auto stamp = readSuccessStamp(stamp_directory / ("SUCCESS_" + stage_name));
    if (!stamp || stamp->stage != stage_name || stamp->run_identity != _run_identity
        || stamp->products.size() != stage.expected_products.size()) {
      continue;
    }

    bool products_match = true;
    for (size_t index = 0; index < stage.expected_products.size(); ++index) {
      const auto resolved = resolveProduct(stage.expected_products[index]).lexically_normal();
      std::error_code error;
      const auto size = std::filesystem::file_size(resolved, error);
      if (error) {
        products_match = false;
        break;
      }
      error.clear();
      const auto modified = std::filesystem::last_write_time(resolved, error);
      if (error || stamp->products[index].path != resolved || stamp->products[index].size != size
          || stamp->products[index].modified != modified.time_since_epoch().count()) {
        products_match = false;
        break;
      }
    }
    if (!products_match) {
      continue;
    }

    auto& profile = _profile.at(stage_name);
    profile.status = StageStatus::kSucceeded;
    profile.wall_ms = stamp->wall_ms;
    _success_stamps.insert(stage_name);
    restored.push_back(stage_name);
  }
  return restored;
}

std::filesystem::path FlowScheduler::resolveProduct(const std::filesystem::path& product) const
{
  return product.is_absolute() ? product : _work_dir / product;
}

void FlowScheduler::validatePlan(const std::vector<std::string>& plan) const
{
  std::set<std::string> planned;
  std::set<std::string> available = _success_stamps;
  for (const auto& stage_name : plan) {
    const auto stage_iter = _stages.find(stage_name);
    if (stage_iter == _stages.end()) {
      throw FlowContractError("flow plan names unknown stage '" + stage_name + "'");
    }
    if (!planned.insert(stage_name).second) {
      throw FlowContractError("flow plan repeats stage '" + stage_name + "'");
    }
    for (const auto& dependency : stage_iter->second.prerequisites) {
      if (!available.contains(dependency)) {
        throw FlowContractError("stage '" + stage_name + "' appears before required stage '" + dependency + "'");
      }
    }
    available.insert(stage_name);
  }
}

std::vector<std::filesystem::path> FlowScheduler::missingProducts(const Stage& stage) const
{
  std::vector<std::filesystem::path> missing;
  std::error_code error;
  for (const auto& product : stage.expected_products) {
    const auto resolved = resolveProduct(product);
    error.clear();
    const bool regular_file = std::filesystem::is_regular_file(resolved, error);
    if (error || !regular_file) {
      missing.push_back(resolved);
      continue;
    }
    error.clear();
    const auto size = std::filesystem::file_size(resolved, error);
    if (error || size == 0) {
      missing.push_back(resolved);
    }
  }
  return missing;
}

void FlowScheduler::stampSuccess(const std::string& stage, const StageProfile& profile) const
{
  const auto stamp_directory = _stamp_dir.is_absolute() ? _stamp_dir : _work_dir / _stamp_dir;
  std::error_code error;
  std::filesystem::create_directories(stamp_directory, error);
  if (error) {
    throw FlowContractError("cannot create flow stamp directory '" + stamp_directory.string() + "': " + error.message());
  }

  const auto stamp_path = stamp_directory / ("SUCCESS_" + stage);
  const auto temporary_path = stamp_path.string() + ".tmp";
  {
    std::ofstream output(temporary_path, std::ios::trunc);
    if (!output) {
      throw FlowContractError("cannot write success stamp '" + temporary_path + "'");
    }
    const auto& expected_products = _stages.at(stage).expected_products;
    output << "format " << 2 << '\n';
    output << "stage " << std::quoted(stage) << '\n';
    output << "run_identity " << std::quoted(_run_identity) << '\n';
    output << "wall_ms " << profile.wall_ms << '\n';
    output << "product_count " << expected_products.size() << '\n';
    for (const auto& product : expected_products) {
      const auto resolved = resolveProduct(product).lexically_normal();
      std::error_code metadata_error;
      const auto size = std::filesystem::file_size(resolved, metadata_error);
      if (metadata_error) {
        throw FlowContractError("cannot snapshot product '" + resolved.string() + "': " + metadata_error.message());
      }
      metadata_error.clear();
      const auto modified = std::filesystem::last_write_time(resolved, metadata_error);
      if (metadata_error) {
        throw FlowContractError("cannot snapshot product '" + resolved.string() + "': " + metadata_error.message());
      }
      output << "product " << std::quoted(resolved.string()) << ' ' << size << ' ' << modified.time_since_epoch().count()
             << '\n';
    }
    output.flush();
    if (!output) {
      throw FlowContractError("failed while writing success stamp '" + temporary_path + "'");
    }
  }
  std::filesystem::remove(stamp_path, error);
  error.clear();
  std::filesystem::rename(temporary_path, stamp_path, error);
  if (error) {
    std::filesystem::remove(temporary_path);
    throw FlowContractError("cannot publish success stamp '" + stamp_path.string() + "': " + error.message());
  }
}

void FlowScheduler::markRemainingBlocked(const std::vector<std::string>& plan, size_t failed_index, const std::string& reason)
{
  for (size_t index = failed_index + 1; index < plan.size(); ++index) {
    auto& profile = _profile.at(plan[index]);
    if (profile.status == StageStatus::kPending) {
      profile.status = StageStatus::kBlocked;
      profile.reason = reason;
    }
  }
}

}  // namespace ieda::platform
