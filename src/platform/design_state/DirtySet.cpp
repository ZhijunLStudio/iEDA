// ***************************************************************************************
// Copyright (c) 2023-2025 Peng Cheng Laboratory
// Copyright (c) 2023-2025 Institute of Computing Technology, Chinese Academy of Sciences
// Copyright (c) 2023-2025 Beijing Institute of Open Source Chip
//
// iEDA is licensed under Mulan PSL v2.
// ***************************************************************************************
#include "DirtySet.hh"

#include <algorithm>
#include <stdexcept>

namespace ieda::platform {

namespace {

std::string kindName(ObjectKind kind)
{
  switch (kind) {
    case ObjectKind::kInstance:
      return "instance";
    case ObjectKind::kPin:
      return "pin";
    case ObjectKind::kNet:
      return "net";
  }
  throw std::invalid_argument("unknown design object kind");
}

}  // namespace

bool DirtySet::add(ObjectKey key)
{
  switch (key.kind) {
    case ObjectKind::kInstance:
      return _instances.insert(key).second;
    case ObjectKind::kPin:
      return _pins.insert(key).second;
    case ObjectKind::kNet:
      return _nets.insert(key).second;
  }
  throw std::invalid_argument("unknown design object kind");
}

bool DirtySet::addInstance(uint64_t id, uint32_t generation)
{
  return add({ObjectKind::kInstance, id, generation});
}

bool DirtySet::addPin(uint64_t id, uint32_t generation)
{
  return add({ObjectKind::kPin, id, generation});
}

bool DirtySet::addNet(uint64_t id, uint32_t generation)
{
  return add({ObjectKind::kNet, id, generation});
}

bool DirtySet::addRegion(DirtyRegion region)
{
  if (region.lower_x > region.upper_x) {
    std::swap(region.lower_x, region.upper_x);
  }
  if (region.lower_y > region.upper_y) {
    std::swap(region.lower_y, region.upper_y);
  }
  return _regions.insert(region).second;
}

bool DirtySet::addScenario(std::string scenario)
{
  if (scenario.empty()) {
    throw std::invalid_argument("dirty scenario name must not be empty");
  }
  return _scenarios.insert(std::move(scenario)).second;
}

void DirtySet::merge(const DirtySet& other)
{
  _instances.insert(other._instances.begin(), other._instances.end());
  _pins.insert(other._pins.begin(), other._pins.end());
  _nets.insert(other._nets.begin(), other._nets.end());
  _regions.insert(other._regions.begin(), other._regions.end());
  _scenarios.insert(other._scenarios.begin(), other._scenarios.end());
}

void DirtySet::clear()
{
  _instances.clear();
  _pins.clear();
  _nets.clear();
  _regions.clear();
  _scenarios.clear();
}

bool DirtySet::empty() const
{
  return _instances.empty() && _pins.empty() && _nets.empty() && _regions.empty() && _scenarios.empty();
}

size_t DirtySet::size() const
{
  return _instances.size() + _pins.size() + _nets.size() + _regions.size() + _scenarios.size();
}

std::vector<std::string> DirtySet::canonicalRecords() const
{
  std::vector<std::string> records;
  records.reserve(size());

  const auto append_objects = [&records](const std::set<ObjectKey>& objects) {
    for (const auto& object : objects) {
      records.push_back(kindName(object.kind) + ":" + std::to_string(object.id) + ":" + std::to_string(object.generation));
    }
  };
  append_objects(_instances);
  append_objects(_pins);
  append_objects(_nets);

  for (const auto& region : _regions) {
    records.push_back("region:" + std::to_string(region.layer) + ":" + std::to_string(region.lower_x) + ":"
                      + std::to_string(region.lower_y) + ":" + std::to_string(region.upper_x) + ":"
                      + std::to_string(region.upper_y));
  }
  for (const auto& scenario : _scenarios) {
    records.push_back("scenario:" + scenario);
  }
  return records;
}

}  // namespace ieda::platform
