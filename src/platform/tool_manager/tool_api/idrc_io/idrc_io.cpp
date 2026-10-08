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
#include "idrc_io.h"

#include <filesystem>

#include "DRCInterface.hpp"
#include "builder.h"
#include "feature_manager.h"
#include "file_drc.h"
#include "flow_config.h"
#include "idm.h"
#include "report_manager.h"

#ifdef USE_PROFILER
#include <gperftools/profiler.h>
#endif

namespace iplf {
namespace {

bool publishFile(const std::filesystem::path& source, const std::filesystem::path& destination)
{
  std::error_code error;
  if (!std::filesystem::is_regular_file(source, error) || error) {
    std::cerr << "iDRC artifact is missing: " << source << std::endl;
    return false;
  }
  if (!destination.parent_path().empty()) {
    std::filesystem::create_directories(destination.parent_path(), error);
    if (error) {
      std::cerr << "Cannot create iDRC report directory: " << destination.parent_path() << ": " << error.message() << std::endl;
      return false;
    }
  }

  const std::filesystem::path temporary_path = destination.string() + ".tmp";
  std::filesystem::copy_file(source, temporary_path, std::filesystem::copy_options::overwrite_existing, error);
  if (error) {
    std::cerr << "Cannot stage iDRC artifact " << source << ": " << error.message() << std::endl;
    return false;
  }
  std::filesystem::rename(temporary_path, destination, error);
  if (error) {
    error.clear();
    std::filesystem::remove(destination, error);
    error.clear();
    std::filesystem::rename(temporary_path, destination, error);
    if (error) {
      const std::string message = error.message();
      error.clear();
      std::filesystem::remove(temporary_path, error);
      std::cerr << "Cannot publish iDRC artifact " << destination << ": " << message << std::endl;
      return false;
    }
  }
  return true;
}

}  // namespace

DrcIO* DrcIO::_instance = nullptr;
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
bool DrcIO::runDRC(std::string config, std::string report_path, bool has_init)
{
  flowConfigInst->set_status_stage("iDRC - Design Rule Check");
  ieda::Stats stats;

  std::error_code error;
  if (report_path.empty()) {
    std::cerr << "iDRC report path is empty." << std::endl;
    return false;
  }

  error.clear();
  const std::filesystem::path report = std::filesystem::absolute(report_path, error);
  if (error) {
    std::cerr << "Cannot resolve iDRC report path " << report_path << ": " << error.message() << std::endl;
    return false;
  }
  std::filesystem::path run_directory;
  if (!has_init) {
    run_directory = report.string() + ".artifacts";
    std::map<std::string, std::any> config_map;
    config_map["-temp_directory_path"] = run_directory.string();
    DRCI.initDRC(config_map, false);
  } else {
    run_directory = DRCI.getTempDirectoryPath();
  }
  const bool check_succeeded = DRCI.checkDef();
  DRCI.destroyDRC();

  flowConfigInst->add_status_runtime(stats.elapsedRunTime());
  flowConfigInst->set_status_memmory(stats.memoryDelta());

  const bool report_published = publishFile(run_directory / "drc.log", report);
  const bool summary_published = publishFile(run_directory / "drc_summary.json", report.parent_path() / "drc_summary.json");
  const bool violations_published = publishFile(run_directory / "violations.json", report.parent_path() / "violations.json");
  const bool legacy_violations_published = publishFile(run_directory / "violation_map.json", report.parent_path() / "violation_map.json");
  return check_succeeded && report_published && summary_published && violations_published && legacy_violations_published;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
bool DrcIO::readDrcFromFile(std::string path)
{
  if (path.empty()) {
    return false;
  }

  FileDrcManager file(path, (int32_t) DrcDbId::kDrcDetailInfo);

  return file.readFile();
}

bool DrcIO::saveDrcToFile(std::string path)
{
  if (path.empty()) {
    return false;
  }

  FileDrcManager file(path, (int32_t) DrcDbId::kDrcDetailInfo);

  return file.writeFile();
}

std::map<std::string, std::map<std::string, std::vector<ids::Violation>>>& DrcIO::getDetailCheckResult(std::string path)
{
  return featureInst->get_type_layer_violation_map();
}

}  // namespace iplf
