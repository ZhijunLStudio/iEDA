// ***************************************************************************************
// Copyright (c) 2023-2025 Peng Cheng Laboratory
// Copyright (c) 2023-2025 Institute of Computing Technology, Chinese Academy of Sciences
// Copyright (c) 2023-2025 Beijing Institute of Open Source Chip
//
// iEDA is licensed under Mulan PSL v2.
// ***************************************************************************************
#include "FlowScheduler.hh"

#include <algorithm>
#include <fstream>
#include <sstream>
#include <system_error>
#include <utility>

namespace ieda::platform {

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
    output << "stage=" << stage << '\n';
    output << "wall_ms=" << profile.wall_ms << '\n';
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
