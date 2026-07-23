// ***************************************************************************************
// Copyright (c) 2023-2025 Peng Cheng Laboratory
// Copyright (c) 2023-2025 Institute of Computing Technology, Chinese Academy of Sciences
// Copyright (c) 2023-2025 Beijing Institute of Open Source Chip
//
// iEDA is licensed under Mulan PSL v2.
// ***************************************************************************************
#pragma once

#include <cstdint>
#include <functional>
#include <map>
#include <mutex>
#include <optional>
#include <set>
#include <string>
#include <vector>

#include "ArtifactIndex.hh"
#include "DirtySet.hh"

namespace ieda::platform {

class MoveTxn;

struct Coverage
{
  uint64_t checked = 0;
  uint64_t skipped = 0;
  uint64_t unsupported = 0;
  uint64_t refused = 0;

  uint64_t total() const { return checked + skipped + unsupported + refused; }
  bool fullyChecked() const { return total() > 0 && skipped == 0 && unsupported == 0 && refused == 0; }
};

struct DesignMetadata
{
  std::map<std::string, std::string> units;
  std::set<std::string> active_scenarios;
  std::map<std::string, std::string> provenance;
};

struct DirtySnapshot
{
  uint64_t state_version = 0;
  DirtySet dirty;
};

class DesignState
{
 public:
  using CanonicalProvider = std::function<std::vector<std::string>()>;

  DesignState() = default;
  DesignState(const DesignState&) = delete;
  DesignState& operator=(const DesignState&) = delete;

  uint64_t version() const;
  bool transactionActive() const;

  void reset(DesignMetadata metadata = {});
  DesignMetadata metadata() const;

  DirtySnapshot dirtySnapshot() const;
  bool acknowledgeDirty(uint64_t observed_state_version);

  bool publishArtifact(ArtifactRecord artifact, std::string* error = nullptr);
  std::optional<ArtifactRecord> artifact(const std::string& id) const;
  std::vector<ArtifactRecord> artifacts() const;
  ArtifactFreshness artifactFreshness(const std::string& id) const;

  void setCoverage(std::string domain, Coverage coverage);
  std::optional<Coverage> coverage(const std::string& domain) const;

  void registerCanonicalProvider(std::string section, CanonicalProvider provider);
  bool unregisterCanonicalProvider(const std::string& section);
  std::string canonicalHash() const;

 private:
  friend class MoveTxn;

  uint64_t acquireTransaction(const std::string& label);
  void commitTransaction(uint64_t token, const DirtySet& dirty);
  void abortTransaction(uint64_t token) noexcept;

  mutable std::mutex _mutex;
  uint64_t _version = 0;
  uint64_t _next_transaction_token = 1;
  uint64_t _active_transaction_token = 0;
  std::string _active_transaction_label;
  DesignMetadata _metadata;
  DirtySet _dirty;
  ArtifactIndex _artifacts;
  std::map<std::string, Coverage> _coverage;
  std::map<std::string, CanonicalProvider> _canonical_providers;
};

}  // namespace ieda::platform
