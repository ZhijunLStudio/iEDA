#include "NoConfig.h"

#include <iostream>
#include <string>

int main()
{
  ino::NoConfig config;
  std::string error;

  if (config.validate(&error) || error != "insert_buffer must name a buffer cell master") {
    std::cerr << "empty insert_buffer was not rejected\n";
    return 1;
  }

  config.set_insert_buffer(" \t\n");
  error.clear();
  if (config.validate(&error)) {
    std::cerr << "whitespace insert_buffer was not rejected\n";
    return 1;
  }

  config.set_insert_buffer("BUF_X4");
  error.clear();
  if (!config.validate(&error) || !error.empty()) {
    std::cerr << "valid insert_buffer was rejected: " << error << '\n';
    return 1;
  }

  config.set_max_fanout(1);
  if (config.validate(&error) || error != "max_fanout must be at least 2") {
    std::cerr << "unsafe max_fanout was not rejected\n";
    return 1;
  }

  return 0;
}
