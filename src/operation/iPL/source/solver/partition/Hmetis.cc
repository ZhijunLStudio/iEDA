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
#include "Hmetis.hh"

#include <cerrno>
#include <cstdlib>
#include <cstring>
#include <filesystem>
#include <fstream>
#include <spawn.h>
#include <sys/wait.h>
#include <utility>

extern char** environ;

namespace ipl {
namespace {

namespace fs = std::filesystem;

class ScopedWorkDirectory
{
 public:
  explicit ScopedWorkDirectory(fs::path path) : _path(std::move(path)) {}

  ~ScopedWorkDirectory()
  {
    std::error_code error;
    fs::remove_all(_path, error);
  }

  const fs::path& path() const { return _path; }

 private:
  fs::path _path;
};

bool is_one_of(const std::string& value, const std::vector<std::string>& allowed)
{
  for (const auto& candidate : allowed) {
    if (value == candidate) {
      return true;
    }
  }
  return false;
}

bool is_valid_option(const std::string& ptype, const std::string& ctype, const std::string& rtype, const std::string& otype,
                     std::string* reason)
{
  if (!is_one_of(ptype, {"rb", "kway"})) {
    *reason = "unsupported hMetis partition type: " + ptype;
    return false;
  }
  if (!is_one_of(ctype, {"fc1", "gfc1", "fc2", "gfc2", "h1", "h2", "h12", "edge1", "gedge1", "edge2", "gedge2"})) {
    *reason = "unsupported hMetis coarsening type: " + ctype;
    return false;
  }
  if (!is_one_of(rtype, {"fast", "moderate", "slow", "krandom", "kpfast", "kpmoderate", "kpslow"})) {
    *reason = "unsupported hMetis refinement type: " + rtype;
    return false;
  }
  if (!is_one_of(otype, {"cut", "soed"})) {
    *reason = "unsupported hMetis objective type: " + otype;
    return false;
  }
  return true;
}

bool create_work_directory(const fs::path& output_root, fs::path* work_directory, std::string* reason)
{
  std::error_code error;
  fs::create_directories(output_root, error);
  if (error) {
    *reason = "cannot create hMetis output root '" + output_root.string() + "': " + error.message();
    return false;
  }

  auto directory_template = (output_root / "hmetis-XXXXXX").string();
  std::vector<char> mutable_template(directory_template.begin(), directory_template.end());
  mutable_template.push_back('\0');
  char* created_directory = mkdtemp(mutable_template.data());
  if (created_directory == nullptr) {
    *reason = "cannot create private hMetis work directory: " + std::string(std::strerror(errno));
    return false;
  }

  *work_directory = created_directory;
  return true;
}

bool write_hypergraph(const fs::path& file_name, int vertex_num, const std::vector<std::vector<int>>& hyper_edge_list,
                      std::string* reason)
{
  std::ofstream hgraph_file(file_name);
  if (!hgraph_file.is_open()) {
    *reason = "cannot open hMetis input file: " + file_name.string();
    return false;
  }

  hgraph_file << hyper_edge_list.size() << ' ' << vertex_num << '\n';
  for (const auto& hyper_edge : hyper_edge_list) {
    if (hyper_edge.empty()) {
      *reason = "hMetis hyperedge must contain at least one vertex";
      return false;
    }
    for (size_t index = 0; index < hyper_edge.size(); ++index) {
      const int vertex = hyper_edge[index];
      if (vertex < 0 || vertex >= vertex_num) {
        *reason = "hMetis hyperedge contains a vertex outside the declared range";
        return false;
      }
      hgraph_file << vertex + 1;
      hgraph_file << (index + 1 == hyper_edge.size() ? '\n' : ' ');
    }
  }
  hgraph_file.close();
  if (!hgraph_file) {
    *reason = "cannot write hMetis input file: " + file_name.string();
    return false;
  }
  return true;
}

bool run_process(const std::vector<std::string>& arguments, std::string* reason)
{
  std::vector<char*> argv;
  argv.reserve(arguments.size() + 1);
  for (const auto& argument : arguments) {
    argv.push_back(const_cast<char*>(argument.c_str()));
  }
  argv.push_back(nullptr);

  pid_t child_pid = 0;
  const int spawn_status = posix_spawnp(&child_pid, argv.front(), nullptr, nullptr, argv.data(), environ);
  if (spawn_status != 0) {
    *reason = "cannot execute hMetis: " + std::string(std::strerror(spawn_status));
    return false;
  }

  int wait_status = 0;
  while (waitpid(child_pid, &wait_status, 0) == -1) {
    if (errno != EINTR) {
      *reason = "cannot wait for hMetis: " + std::string(std::strerror(errno));
      return false;
    }
  }
  if (WIFEXITED(wait_status) && WEXITSTATUS(wait_status) == 0) {
    return true;
  }
  if (WIFEXITED(wait_status)) {
    *reason = "hMetis exited with status " + std::to_string(WEXITSTATUS(wait_status));
  } else if (WIFSIGNALED(wait_status)) {
    *reason = "hMetis was terminated by signal " + std::to_string(WTERMSIG(wait_status));
  } else {
    *reason = "hMetis terminated unexpectedly";
  }
  return false;
}

bool read_partition_result(const fs::path& solution_file, int vertex_num, int nparts, std::vector<int>* partition_result,
                           std::string* reason)
{
  std::error_code error;
  const auto solution_status = fs::symlink_status(solution_file, error);
  if (error || !fs::is_regular_file(solution_status)) {
    *reason = "hMetis did not create a regular partition result: " + solution_file.string();
    return false;
  }

  std::ifstream result_file(solution_file);
  if (!result_file.is_open()) {
    *reason = "cannot open hMetis partition result: " + solution_file.string();
    return false;
  }

  std::vector<int> parsed_result;
  parsed_result.reserve(vertex_num);
  for (int vertex = 0; vertex < vertex_num; ++vertex) {
    int cluster_index = 0;
    if (!(result_file >> cluster_index)) {
      *reason = "hMetis partition result contains fewer entries than vertices";
      return false;
    }
    if (cluster_index < 0 || cluster_index >= nparts) {
      *reason = "hMetis partition result contains an out-of-range partition index";
      return false;
    }
    parsed_result.push_back(cluster_index);
  }

  std::string trailing_token;
  if (result_file >> trailing_token) {
    *reason = "hMetis partition result contains more entries than vertices";
    return false;
  }
  if (!result_file.eof()) {
    *reason = "cannot read hMetis partition result";
    return false;
  }

  *partition_result = std::move(parsed_result);
  return true;
}

}  // namespace

void Hmetis::partition(int vertex_num, const std::vector<std::vector<int>>& hyper_edge_list)
{
  _partition_result.clear();
  _last_run_succeeded = false;
  _last_error.clear();
  _last_command_arguments.clear();

  if (vertex_num <= 0) {
    _last_error = "hMetis requires a positive vertex count";
  } else if (_nparts < 2) {
    _last_error = "hMetis requires at least two partitions";
  } else if (_hmetis_path.empty()) {
    _last_error = "hMetis executable path is empty";
  } else if (!is_valid_option(_ptype, _ctype, _rtype, _otype, &_last_error)) {
  } else if (_ufactor < 0.0F || _nruns <= 0 || _nvcycles <= 0 || _nvcycles > _nruns || _cmaxnet <= 0 || _rmaxnet <= 0) {
    _last_error = "hMetis numeric options are out of range";
  } else {
    fs::path work_directory;
    if (create_work_directory(_output_path, &work_directory, &_last_error)) {
      ScopedWorkDirectory cleanup(work_directory);
      const fs::path hgraph_file_name = cleanup.path() / "input.hgr";
      if (write_hypergraph(hgraph_file_name, vertex_num, hyper_edge_list, &_last_error)) {
        _last_command_arguments = {_hmetis_path,
                                   hgraph_file_name.string(),
                                   std::to_string(_nparts),
                                   "-ptype=" + _ptype,
                                   "-ctype=" + _ctype,
                                   "-rtype=" + _rtype,
                                   "-otype=" + _otype,
                                   "-ufactor=" + std::to_string(_ufactor),
                                   "-nruns=" + std::to_string(_nruns),
                                   "-nvcycles=" + std::to_string(_nvcycles),
                                   "-cmaxnet=" + std::to_string(_cmaxnet),
                                   "-rmaxnet=" + std::to_string(_rmaxnet),
                                   "-dbglvl=" + std::to_string(_dbglvl),
                                   "-seed=" + std::to_string(_seed)};
        if (_reconst) {
          _last_command_arguments.emplace_back("-reconst");
        }
        if (_kwayrefine) {
          _last_command_arguments.emplace_back("-kwayrefine");
        }

        if (run_process(_last_command_arguments, &_last_error)
            && read_partition_result(hgraph_file_name.string() + ".part." + std::to_string(_nparts), vertex_num, _nparts,
                                     &_partition_result, &_last_error)) {
          _last_run_succeeded = true;
        }
      }
    }
  }

  if (_last_run_succeeded) {
    LOG_INFO << "hMetis partition succeeded";
  } else {
    LOG_ERROR << "hMetis partition failed: " << _last_error;
    _partition_result.clear();
  }
}
}  // namespace ipl
