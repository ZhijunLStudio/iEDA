#include <iostream>
#include <string>
#include <utility>
#include <vector>

#include "IdbEnum.h"
#include "ista_io.h"

namespace {

bool require(bool condition, const std::string& message)
{
  if (!condition) {
    std::cerr << "[FAIL] " << message << '\n';
  } else {
    std::cout << "[PASS] " << message << '\n';
  }
  return condition;
}

}  // namespace

int main()
{
  std::pair<std::string, std::string> nets{"missing_source", "inserted_net"};
  std::vector<std::string> sinks{"missing_instance/A"};
  std::pair<std::string, std::string> buffer{"missing_buffer", "inserted_buffer"};

  const bool inserted = iplf::StaIO::getInstance()->insertBuffer(
      nets, sinks, buffer, {0, 0}, idb::IdbConnectType::kSignal);
  return require(!inserted, "invalid buffer insertion must return false without terminating the process") ? 0 : 1;
}
