#include "solver/partition/Hmetis.hh"

#include <sys/stat.h>
#include <unistd.h>

#include <cstdlib>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <algorithm>
#include <string>
#include <vector>

namespace {

namespace fs = std::filesystem;

bool require(bool condition, const std::string& message)
{
  if (!condition) {
    std::cerr << "[FAIL] " << message << '\n';
  } else {
    std::cout << "[PASS] " << message << '\n';
  }
  return condition;
}

fs::path make_temp_directory()
{
  std::string directory_template = (fs::temp_directory_path() / "ipl_hmetis_security_XXXXXX").string();
  std::vector<char> mutable_template(directory_template.begin(), directory_template.end());
  mutable_template.push_back('\0');
  char* directory = mkdtemp(mutable_template.data());
  return directory == nullptr ? fs::path{} : fs::path(directory);
}

bool write_executable(const fs::path& path, const std::string& script)
{
  std::ofstream stream(path);
  stream << script;
  stream.close();
  return stream.good() && chmod(path.c_str(), 0700) == 0;
}

bool test_arg_vector_execution(const fs::path& root)
{
  const fs::path executable = root / "fake hmetis with spaces";
  const std::string script = "#!/bin/sh\n"
                             "input=\"$1\"\n"
                             "nparts=\"$2\"\n"
                             "printf '0\\n1\\n0\\n' > \"${input}.part.${nparts}\"\n"
                             "printf '%s\\n' \"$@\" > \"${input}.args\"\n";
  if (!require(write_executable(executable, script), "test hMetis executable is created")) {
    return false;
  }

  ipl::Hmetis hmetis;
  hmetis.set_hmetis_path(executable.string());
  hmetis.set_output_path((root / "work root with spaces").string());
  hmetis.set_nparts(2);
  hmetis.set_seed(17);
  hmetis.partition(3, {{0, 1}, {1, 2}});

  bool ok = true;
  ok &= require(hmetis.last_run_succeeded(), "argv execution accepts executable and workspace paths containing spaces");
  ok &= require(hmetis.get_result() == std::vector<int>({0, 1, 0}), "only a complete current partition result is accepted");
  const auto& arguments = hmetis.last_command_arguments();
  ok &= require(arguments.size() >= 14 && arguments[0] == executable.string() && arguments[2] == "2"
                    && std::find(arguments.begin(), arguments.end(), "-seed=17") != arguments.end(),
                "executed argv is retained for verification with one argument per option");
  ok &= require(!fs::exists(root / "work root with spaces" / "input.hgr.part.2"),
                "private hMetis work files are removed after successful parsing");
  return ok;
}

bool test_injection_and_stale_result_rejection(const fs::path& root)
{
  const fs::path output_root = root / "failure output";
  fs::create_directories(output_root);
  {
    std::ofstream stale_result(output_root / "input.txt.part.2");
    stale_result << "0\n1\n0\n";
  }

  const fs::path marker = root / "shell-injection-marker";
  const fs::path actual_executable = root / "writer";
  if (!require(write_executable(actual_executable, "#!/bin/sh\nexit 0\n"), "shell payload prefix executable is created")) {
    return false;
  }

  ipl::Hmetis hmetis;
  hmetis.set_output_path(output_root.string());
  hmetis.set_hmetis_path(actual_executable.string() + ";touch " + marker.string());
  hmetis.partition(3, {{0, 1}, {1, 2}});

  bool ok = true;
  ok &= require(!hmetis.last_run_succeeded(), "invalid executable path reports an execution failure");
  ok &= require(hmetis.get_result().empty(), "failed execution never consumes a stale partition result");
  ok &= require(!fs::exists(marker), "semicolon in configured executable path is never interpreted by a shell");
  ok &= require(hmetis.last_error().find("cannot execute hMetis") != std::string::npos,
                "failure exposes a typed execution error for callers");
  return ok;
}

bool test_failed_process_output_is_rejected(const fs::path& root)
{
  const fs::path executable = root / "failing writer";
  const std::string script = "#!/bin/sh\n"
                             "input=\"$1\"\n"
                             "nparts=\"$2\"\n"
                             "printf '0\\n1\\n0\\n' > \"${input}.part.${nparts}\"\n"
                             "exit 42\n";
  if (!require(write_executable(executable, script), "failing hMetis executable is created")) {
    return false;
  }

  ipl::Hmetis hmetis;
  hmetis.set_hmetis_path(executable.string());
  hmetis.set_output_path((root / "failed writer output").string());
  hmetis.set_nparts(2);
  hmetis.partition(3, {{0, 1}, {1, 2}});

  bool ok = true;
  ok &= require(!hmetis.last_run_succeeded(), "non-zero hMetis exit status is reported as failure");
  ok &= require(hmetis.get_result().empty(), "partition output from a failed hMetis process is ignored");
  ok &= require(hmetis.last_error().find("hMetis exited with status 42") != std::string::npos,
                "non-zero hMetis exit status is retained for callers");
  return ok;
}

}  // namespace

int main()
{
  const fs::path root = make_temp_directory();
  if (root.empty()) {
    std::cerr << "[FAIL] cannot create temporary test directory\n";
    return EXIT_FAILURE;
  }

  const bool ok = test_arg_vector_execution(root) && test_injection_and_stale_result_rejection(root)
                  && test_failed_process_output_is_rejected(root);
  std::error_code error;
  fs::remove_all(root, error);
  return ok ? EXIT_SUCCESS : EXIT_FAILURE;
}
