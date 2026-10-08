// ***************************************************************************************
// Copyright (c) 2023-2025 Peng Cheng Laboratory
// Copyright (c) 2023-2025 Institute of Computing Technology, Chinese Academy of Sciences
// Copyright (c) 2023-2025 Beijing Institute of Open Source Chip
//
// iEDA is licensed under Mulan PSL v2.
// ***************************************************************************************
#include "ArtifactIndex.hh"

#include <cctype>

namespace ieda::platform {

bool ArtifactIndex::upsert(ArtifactRecord artifact, std::string* error)
{
  const auto fail = [error](const std::string& message) {
    if (error != nullptr) {
      *error = message;
    }
    return false;
  };

  if (artifact.id.empty()) {
    return fail("artifact id must not be empty");
  }
  if (artifact.type.empty()) {
    return fail("artifact type must not be empty");
  }
  if (artifact.status == ArtifactStatus::kReady) {
    if (artifact.path.empty()) {
      return fail("ready artifact path must not be empty");
    }
    if (!isSha256(artifact.sha256)) {
      return fail("ready artifact must carry a 64-digit SHA-256");
    }
  }

  _artifacts.insert_or_assign(artifact.id, std::move(artifact));
  if (error != nullptr) {
    error->clear();
  }
  return true;
}

std::optional<ArtifactRecord> ArtifactIndex::find(const std::string& id) const
{
  const auto iter = _artifacts.find(id);
  if (iter == _artifacts.end()) {
    return std::nullopt;
  }
  return iter->second;
}

std::vector<ArtifactRecord> ArtifactIndex::list() const
{
  std::vector<ArtifactRecord> artifacts;
  artifacts.reserve(_artifacts.size());
  for (const auto& [id, artifact] : _artifacts) {
    static_cast<void>(id);
    artifacts.push_back(artifact);
  }
  return artifacts;
}

ArtifactFreshness ArtifactIndex::freshness(const std::string& id, uint64_t current_state_version) const
{
  const auto artifact = find(id);
  if (!artifact.has_value()) {
    return ArtifactFreshness::kMissing;
  }
  if (artifact->status != ArtifactStatus::kReady) {
    return ArtifactFreshness::kUnusable;
  }
  return artifact->state_version == current_state_version ? ArtifactFreshness::kFresh : ArtifactFreshness::kStale;
}

void ArtifactIndex::clear()
{
  _artifacts.clear();
}

bool ArtifactIndex::isSha256(const std::string& value)
{
  if (value.size() != 64) {
    return false;
  }
  for (const unsigned char character : value) {
    if (std::isxdigit(character) == 0) {
      return false;
    }
  }
  return true;
}

}  // namespace ieda::platform
