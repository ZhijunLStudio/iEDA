#include <iostream>
#include <sys/wait.h>
#include <unistd.h>

#include "ErrorExit.hpp"

int main()
{
  const pid_t child = fork();
  if (child < 0) {
    std::cerr << "fork failed\n";
    return 1;
  }
  if (child == 0) {
    idrc::exitWithError();
  }

  int status = 0;
  if (waitpid(child, &status, 0) != child || !WIFEXITED(status) || WEXITSTATUS(status) == 0) {
    std::cerr << "fatal iDRC error did not return EXIT_FAILURE\n";
    return 1;
  }
  std::cout << "iDRC logger exit-code test passed\n";
  return 0;
}
