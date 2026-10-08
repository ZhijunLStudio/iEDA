// ***************************************************************************************
// Copyright (c) 2023-2025 Peng Cheng Laboratory
// Copyright (c) 2023-2025 Institute of Computing Technology, Chinese Academy of Sciences
// Copyright (c) 2023-2025 Beijing Institute of Open Source Chip
//
// iEDA is licensed under Mulan PSL v2.
// ***************************************************************************************
#pragma once

#include <cstdint>
#include <map>
#include <optional>
#include <string>
#include <vector>

namespace ieda::platform {

enum class ArtifactStatus : uint8_t
{
  kPending,
  kReady,
  kFailed,
  kUnsupported
};

enum class ArtifactFreshness : uint8_t
{
  kMissing,
  kFresh,
  kStale,
  kUnusable
};

struct ArtifactRecord
{
  std::string id;
  std::string type;
  std::string path;
  std::string sha256;
  uint64_t state_version = 0;
  std::string scenario;
  ArtifactStatus status = ArtifactStatus::kPending;
};

class ArtifactIndex
{
 public:
  bool upsert(ArtifactRecord artifact, std::string* error = nullptr);
  std::optional<ArtifactRecord> find(const std::string& id) const;
  std::vector<ArtifactRecord> list() const;
  ArtifactFreshness freshness(const std::string& id, uint64_t current_state_version) const;
  void clear();

  static bool isSha256(const std::string& value);

 private:
  std::map<std::string, ArtifactRecord> _artifacts;
};

}  // namespace ieda::platform
