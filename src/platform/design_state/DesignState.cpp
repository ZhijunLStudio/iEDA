// ***************************************************************************************
// Copyright (c) 2023-2025 Peng Cheng Laboratory
// Copyright (c) 2023-2025 Institute of Computing Technology, Chinese Academy of Sciences
// Copyright (c) 2023-2025 Beijing Institute of Open Source Chip
//
// iEDA is licensed under Mulan PSL v2.
// ***************************************************************************************
#include "DesignState.hh"

#include <algorithm>
#include <array>
#include <iomanip>
#include <limits>
#include <sstream>
#include <stdexcept>
#include <string_view>
#include <utility>

namespace ieda::platform {

namespace {

constexpr std::array<uint32_t, 64> kSha256Constants{
    0x428a2f98U, 0x71374491U, 0xb5c0fbcfU, 0xe9b5dba5U, 0x3956c25bU, 0x59f111f1U, 0x923f82a4U, 0xab1c5ed5U,
    0xd807aa98U, 0x12835b01U, 0x243185beU, 0x550c7dc3U, 0x72be5d74U, 0x80deb1feU, 0x9bdc06a7U, 0xc19bf174U,
    0xe49b69c1U, 0xefbe4786U, 0x0fc19dc6U, 0x240ca1ccU, 0x2de92c6fU, 0x4a7484aaU, 0x5cb0a9dcU, 0x76f988daU,
    0x983e5152U, 0xa831c66dU, 0xb00327c8U, 0xbf597fc7U, 0xc6e00bf3U, 0xd5a79147U, 0x06ca6351U, 0x14292967U,
    0x27b70a85U, 0x2e1b2138U, 0x4d2c6dfcU, 0x53380d13U, 0x650a7354U, 0x766a0abbU, 0x81c2c92eU, 0x92722c85U,
    0xa2bfe8a1U, 0xa81a664bU, 0xc24b8b70U, 0xc76c51a3U, 0xd192e819U, 0xd6990624U, 0xf40e3585U, 0x106aa070U,
    0x19a4c116U, 0x1e376c08U, 0x2748774cU, 0x34b0bcb5U, 0x391c0cb3U, 0x4ed8aa4aU, 0x5b9cca4fU, 0x682e6ff3U,
    0x748f82eeU, 0x78a5636fU, 0x84c87814U, 0x8cc70208U, 0x90befffaU, 0xa4506cebU, 0xbef9a3f7U, 0xc67178f2U};

uint32_t rotateRight(uint32_t value, uint32_t bits)
{
  return (value >> bits) | (value << (32U - bits));
}

std::string sha256(std::string_view input)
{
  std::vector<uint8_t> bytes(input.begin(), input.end());
  const uint64_t bit_length = static_cast<uint64_t>(bytes.size()) * 8U;
  bytes.push_back(0x80U);
  while ((bytes.size() % 64U) != 56U) {
    bytes.push_back(0U);
  }
  for (int shift = 56; shift >= 0; shift -= 8) {
    bytes.push_back(static_cast<uint8_t>((bit_length >> shift) & 0xffU));
  }

  std::array<uint32_t, 8> hash{0x6a09e667U, 0xbb67ae85U, 0x3c6ef372U, 0xa54ff53aU,
                               0x510e527fU, 0x9b05688cU, 0x1f83d9abU, 0x5be0cd19U};

  for (size_t offset = 0; offset < bytes.size(); offset += 64U) {
    std::array<uint32_t, 64> words{};
    for (size_t index = 0; index < 16U; ++index) {
      const size_t base = offset + index * 4U;
      words[index] = (static_cast<uint32_t>(bytes[base]) << 24U) | (static_cast<uint32_t>(bytes[base + 1]) << 16U)
                     | (static_cast<uint32_t>(bytes[base + 2]) << 8U) | static_cast<uint32_t>(bytes[base + 3]);
    }
    for (size_t index = 16U; index < words.size(); ++index) {
      const uint32_t s0 = rotateRight(words[index - 15U], 7U) ^ rotateRight(words[index - 15U], 18U) ^ (words[index - 15U] >> 3U);
      const uint32_t s1 = rotateRight(words[index - 2U], 17U) ^ rotateRight(words[index - 2U], 19U) ^ (words[index - 2U] >> 10U);
      words[index] = words[index - 16U] + s0 + words[index - 7U] + s1;
    }

    uint32_t a = hash[0];
    uint32_t b = hash[1];
    uint32_t c = hash[2];
    uint32_t d = hash[3];
    uint32_t e = hash[4];
    uint32_t f = hash[5];
    uint32_t g = hash[6];
    uint32_t h = hash[7];

    for (size_t index = 0; index < words.size(); ++index) {
      const uint32_t sum1 = rotateRight(e, 6U) ^ rotateRight(e, 11U) ^ rotateRight(e, 25U);
      const uint32_t choice = (e & f) ^ ((~e) & g);
      const uint32_t temp1 = h + sum1 + choice + kSha256Constants[index] + words[index];
      const uint32_t sum0 = rotateRight(a, 2U) ^ rotateRight(a, 13U) ^ rotateRight(a, 22U);
      const uint32_t majority = (a & b) ^ (a & c) ^ (b & c);
      const uint32_t temp2 = sum0 + majority;
      h = g;
      g = f;
      f = e;
      e = d + temp1;
      d = c;
      c = b;
      b = a;
      a = temp1 + temp2;
    }

    hash[0] += a;
    hash[1] += b;
    hash[2] += c;
    hash[3] += d;
    hash[4] += e;
    hash[5] += f;
    hash[6] += g;
    hash[7] += h;
  }

  std::ostringstream result;
  result << std::hex << std::setfill('0');
  for (const auto value : hash) {
    result << std::setw(8) << value;
  }
  return result.str();
}

void appendCanonical(std::string& output, std::string_view value)
{
  output.append(std::to_string(value.size()));
  output.push_back(':');
  output.append(value);
}

}  // namespace

uint64_t DesignState::version() const
{
  std::lock_guard lock(_mutex);
  return _version;
}

bool DesignState::transactionActive() const
{
  std::lock_guard lock(_mutex);
  return _active_transaction_token != 0;
}

void DesignState::reset(DesignMetadata metadata)
{
  std::lock_guard lock(_mutex);
  if (_active_transaction_token != 0) {
    throw std::logic_error("cannot reset design state while a transaction is active");
  }
  _version = 0;
  _metadata = std::move(metadata);
  _dirty.clear();
  _artifacts.clear();
  _coverage.clear();
}

DesignMetadata DesignState::metadata() const
{
  std::lock_guard lock(_mutex);
  return _metadata;
}

DirtySnapshot DesignState::dirtySnapshot() const
{
  std::lock_guard lock(_mutex);
  return {_version, _dirty};
}

bool DesignState::acknowledgeDirty(uint64_t observed_state_version)
{
  std::lock_guard lock(_mutex);
  if (_active_transaction_token != 0 || observed_state_version != _version) {
    return false;
  }
  _dirty.clear();
  return true;
}

bool DesignState::publishArtifact(ArtifactRecord artifact, std::string* error)
{
  std::lock_guard lock(_mutex);
  artifact.state_version = _version;
  return _artifacts.upsert(std::move(artifact), error);
}

std::optional<ArtifactRecord> DesignState::artifact(const std::string& id) const
{
  std::lock_guard lock(_mutex);
  return _artifacts.find(id);
}

std::vector<ArtifactRecord> DesignState::artifacts() const
{
  std::lock_guard lock(_mutex);
  return _artifacts.list();
}

ArtifactFreshness DesignState::artifactFreshness(const std::string& id) const
{
  std::lock_guard lock(_mutex);
  return _artifacts.freshness(id, _version);
}

void DesignState::setCoverage(std::string domain, Coverage coverage)
{
  if (domain.empty()) {
    throw std::invalid_argument("coverage domain must not be empty");
  }
  std::lock_guard lock(_mutex);
  _coverage.insert_or_assign(std::move(domain), coverage);
}

std::optional<Coverage> DesignState::coverage(const std::string& domain) const
{
  std::lock_guard lock(_mutex);
  const auto iter = _coverage.find(domain);
  if (iter == _coverage.end()) {
    return std::nullopt;
  }
  return iter->second;
}

void DesignState::registerCanonicalProvider(std::string section, CanonicalProvider provider)
{
  if (section.empty()) {
    throw std::invalid_argument("canonical state section must not be empty");
  }
  if (!provider) {
    throw std::invalid_argument("canonical state provider must not be empty");
  }
  std::lock_guard lock(_mutex);
  if (_active_transaction_token != 0) {
    throw std::logic_error("cannot change canonical providers during a transaction");
  }
  _canonical_providers.insert_or_assign(std::move(section), std::move(provider));
}

bool DesignState::unregisterCanonicalProvider(const std::string& section)
{
  std::lock_guard lock(_mutex);
  if (_active_transaction_token != 0) {
    throw std::logic_error("cannot change canonical providers during a transaction");
  }
  return _canonical_providers.erase(section) != 0;
}

std::string DesignState::canonicalHash() const
{
  DesignMetadata metadata_copy;
  std::map<std::string, CanonicalProvider> providers_copy;
  {
    std::lock_guard lock(_mutex);
    metadata_copy = _metadata;
    providers_copy = _canonical_providers;
  }

  std::string canonical;
  appendCanonical(canonical, "ieda-design-state-v1");
  for (const auto& [name, value] : metadata_copy.units) {
    appendCanonical(canonical, "unit");
    appendCanonical(canonical, name);
    appendCanonical(canonical, value);
  }
  for (const auto& scenario : metadata_copy.active_scenarios) {
    appendCanonical(canonical, "scenario");
    appendCanonical(canonical, scenario);
  }
  for (const auto& [name, value] : metadata_copy.provenance) {
    appendCanonical(canonical, "provenance");
    appendCanonical(canonical, name);
    appendCanonical(canonical, value);
  }
  for (const auto& [section, provider] : providers_copy) {
    auto records = provider();
    std::sort(records.begin(), records.end());
    appendCanonical(canonical, "section");
    appendCanonical(canonical, section);
    appendCanonical(canonical, std::to_string(records.size()));
    for (const auto& record : records) {
      appendCanonical(canonical, record);
    }
  }
  return sha256(canonical);
}

uint64_t DesignState::acquireTransaction(const std::string& label)
{
  std::lock_guard lock(_mutex);
  if (_active_transaction_token != 0) {
    throw std::logic_error("nested or concurrent design transaction rejected; active transaction: " + _active_transaction_label);
  }
  if (_next_transaction_token == 0) {
    throw std::overflow_error("design transaction token overflow");
  }
  _active_transaction_token = _next_transaction_token++;
  _active_transaction_label = label;
  return _active_transaction_token;
}

void DesignState::commitTransaction(uint64_t token, const DirtySet& dirty)
{
  std::lock_guard lock(_mutex);
  if (token == 0 || token != _active_transaction_token) {
    throw std::logic_error("attempted to commit a transaction that does not own the design state");
  }
  if (_version == std::numeric_limits<uint64_t>::max()) {
    throw std::overflow_error("design state version overflow");
  }

  DirtySet merged = _dirty;
  merged.merge(dirty);
  _dirty = std::move(merged);
  ++_version;
  _active_transaction_token = 0;
  _active_transaction_label.clear();
}

void DesignState::abortTransaction(uint64_t token) noexcept
{
  std::lock_guard lock(_mutex);
  if (token == _active_transaction_token) {
    _active_transaction_token = 0;
    _active_transaction_label.clear();
  }
}

}  // namespace ieda::platform
