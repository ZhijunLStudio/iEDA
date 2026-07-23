// ***************************************************************************************
// Copyright (c) 2023-2025 Peng Cheng Laboratory
// Copyright (c) 2023-2025 Institute of Computing Technology, Chinese Academy of Sciences
// Copyright (c) 2023-2025 Beijing Institute of Open Source Chip
//
// iEDA is licensed under Mulan PSL v2.
// ***************************************************************************************
#pragma once

#include <chrono>
#include <cstddef>
#include <cstdint>
#include <filesystem>
#include <functional>
#include <map>
#include <set>
#include <stdexcept>
#include <string>
#include <utility>
#include <vector>

namespace ieda::platform {

enum class StageStatus : uint8_t
{
  kPending,
  kRunning,
  kSucceeded,
  kFailed,
  kBlocked
};

struct Stage
{
  std::string name;
  std::vector<std::string> prerequisites;
  std::vector<std::filesystem::path> expected_products;
  std::function<bool()> run;
  std::function<void()> on_start;
  std::function<void()> on_success;
};

struct StageProfile
{
  StageStatus status = StageStatus::kPending;
  double wall_ms = 0.0;
  std::string reason;
};

struct FlowRunResult
{
  int return_code = 0;
  std::string failed_stage;
  std::string reason;
  std::vector<std::string> executed_stages;

  bool ok() const { return return_code == 0; }
};

class FlowContractError : public std::runtime_error
{
 public:
  using std::runtime_error::runtime_error;
};

class FlowScheduler
{
 public:
  explicit FlowScheduler(std::filesystem::path work_dir = std::filesystem::current_path());

  void registerStage(Stage stage);
  bool unregisterStage(const std::string& name);
  void clearStages();

  std::vector<std::string> validateAndTopologicalOrder() const;
  FlowRunResult run(const std::vector<std::string>& plan = {});

  bool isReady(const std::string& stage) const;
  bool hasSucceeded(const std::string& stage) const;
  StageStatus status(const std::string& stage) const;
  std::map<std::string, StageProfile> profile() const { return _profile; }

  void resetRunState();
  void setWorkDir(std::filesystem::path work_dir);
  const std::filesystem::path& workDir() const { return _work_dir; }
  void setStampDir(std::filesystem::path stamp_dir) { _stamp_dir = std::move(stamp_dir); }

 private:
  std::filesystem::path resolveProduct(const std::filesystem::path& product) const;
  void validatePlan(const std::vector<std::string>& plan) const;
  std::vector<std::filesystem::path> missingProducts(const Stage& stage) const;
  void stampSuccess(const std::string& stage, const StageProfile& profile) const;
  void markRemainingBlocked(const std::vector<std::string>& plan, size_t failed_index, const std::string& reason);

  std::filesystem::path _work_dir;
  std::filesystem::path _stamp_dir = ".ieda/stamps";
  std::map<std::string, Stage> _stages;
  std::map<std::string, StageProfile> _profile;
  std::set<std::string> _success_stamps;
};

}  // namespace ieda::platform
