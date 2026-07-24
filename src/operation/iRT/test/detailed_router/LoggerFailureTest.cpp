#include "Logger.hpp"

#include <cstdlib>
#include <sys/wait.h>
#include <unistd.h>

int main()
{
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
