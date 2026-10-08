#include "Logger.hpp"

#include <cstdlib>
#include <filesystem>
#include <fstream>
#include <sstream>
#include <string>
#include <sys/wait.h>
#include <unistd.h>

namespace {

std::string readFile(const std::filesystem::path& path)
{
  std::ifstream file(path);
  std::stringstream buffer;
  buffer << file.rdbuf();
  return buffer.str();
}

bool runLoggerLifecycleTest()
{
  const auto temp_dir = std::filesystem::temp_directory_path() / ("irt_logger_lifecycle_" + std::to_string(getpid()));
  std::filesystem::create_directories(temp_dir);
  const auto first_log = temp_dir / "first.log";
  const auto second_log = temp_dir / "second.log";

  irt::Logger::initInst();
  auto& logger = irt::Logger::getInst();
  logger.openLogFileStream(first_log.string());
  logger.info(irt::Loc::current(), "first-open-message");
  logger.openLogFileStream(second_log.string());
  logger.info(irt::Loc::current(), "second-open-message");
  logger.closeLogFileStream();
  logger.info(irt::Loc::current(), "after-close-message");
  irt::Logger::destroyInst();

  const std::string first_content = readFile(first_log);
  const std::string second_content = readFile(second_log);
  std::filesystem::remove_all(temp_dir);

  return first_content.find("first-open-message") != std::string::npos
         && first_content.find("second-open-message") == std::string::npos
         && first_content.find("after-close-message") == std::string::npos
         && second_content.find("second-open-message") != std::string::npos
         && second_content.find("after-close-message") == std::string::npos;
}

}  // namespace

int main()
{
  if (!runLoggerLifecycleTest()) {
    return EXIT_FAILURE;
  }
  std::cout.flush();

  const pid_t child = fork();
  if (child < 0) {
    return EXIT_FAILURE;
  }
  if (child == 0) {
    irt::Logger::initInst();
    RTLOG.error(irt::Loc::current(), "intentional error-path exit-code test");
  }

  int status = 0;
  if (waitpid(child, &status, 0) != child) {
    return EXIT_FAILURE;
  }
  return WIFEXITED(status) && WEXITSTATUS(status) == EXIT_FAILURE ? EXIT_SUCCESS : EXIT_FAILURE;
}
