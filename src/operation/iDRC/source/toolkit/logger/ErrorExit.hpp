#pragma once

#include <cstdlib>

namespace idrc {

[[noreturn]] inline void exitWithError()
{
  std::exit(EXIT_FAILURE);
}

}  // namespace idrc
