// ***************************************************************************************
// Copyright (c) 2023-2025 Peng Cheng Laboratory
// Copyright (c) 2023-2025 Institute of Computing Technology, Chinese Academy of Sciences
// Copyright (c) 2023-2025 Beijing Institute of Open Source Chip
//
// iEDA is licensed under Mulan PSL v2.
// ***************************************************************************************
#pragma once

#include <compare>
#include <cstddef>
#include <cstdint>
#include <set>
#include <string>
#include <vector>

namespace ieda::platform {

enum class ObjectKind : uint8_t
{
  kInstance,
  kPin,
  kNet
};

struct ObjectKey
{
  ObjectKind kind = ObjectKind::kInstance;
  uint64_t id = 0;
  uint32_t generation = 0;

  auto operator<=>(const ObjectKey&) const = default;
};

struct DirtyRegion
{
  int32_t layer = -1;
  int64_t lower_x = 0;
  int64_t lower_y = 0;
  int64_t upper_x = 0;
  int64_t upper_y = 0;

  auto operator<=>(const DirtyRegion&) const = default;
};

class DirtySet
{
 public:
  bool add(ObjectKey key);
  bool addInstance(uint64_t id, uint32_t generation = 0);
  bool addPin(uint64_t id, uint32_t generation = 0);
  bool addNet(uint64_t id, uint32_t generation = 0);
  bool addRegion(DirtyRegion region);
  bool addScenario(std::string scenario);

  void merge(const DirtySet& other);
  void clear();

  bool empty() const;
  size_t size() const;

  const std::set<ObjectKey>& instances() const { return _instances; }
  const std::set<ObjectKey>& pins() const { return _pins; }
  const std::set<ObjectKey>& nets() const { return _nets; }
  const std::set<DirtyRegion>& regions() const { return _regions; }
  const std::set<std::string>& scenarios() const { return _scenarios; }

  std::vector<std::string> canonicalRecords() const;

 private:
  std::set<ObjectKey> _instances;
  std::set<ObjectKey> _pins;
  std::set<ObjectKey> _nets;
  std::set<DirtyRegion> _regions;
  std::set<std::string> _scenarios;
};

}  // namespace ieda::platform
