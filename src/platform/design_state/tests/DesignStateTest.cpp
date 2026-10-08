#include <algorithm>
#include <iostream>
#include <random>
#include <stdexcept>
#include <string>
#include <vector>

#include "ArtifactIndex.hh"
#include "DesignState.hh"
#include "MoveTxn.hh"

namespace {

using ieda::platform::ArtifactFreshness;
using ieda::platform::ArtifactRecord;
using ieda::platform::ArtifactStatus;
using ieda::platform::DesignState;
using ieda::platform::DirtySet;
using ieda::platform::MoveTxn;

void expect(bool condition, const std::string& message)
{
  if (!condition) {
    throw std::runtime_error(message);
  }
}

void testCommitAndDirtyDedup()
{
  DesignState state;
  DirtySet first;
  first.addInstance(7, 1);
  first.addInstance(7, 1);
  first.addNet(9);
  first.addScenario("slow");

  MoveTxn transaction(state, "commit");
  transaction.markDirty(first);
  transaction.markDirty(first);
  transaction.commit();

  expect(state.version() == 1, "a commit must increment the version exactly once");
  const auto snapshot = state.dirtySnapshot();
  expect(snapshot.dirty.instances().size() == 1, "dirty instances must be deduplicated");
  expect(snapshot.dirty.nets().size() == 1, "dirty nets must be deduplicated");
  expect(snapshot.dirty.scenarios().size() == 1, "dirty scenarios must be deduplicated");
  expect(state.acknowledgeDirty(snapshot.state_version), "current dirty snapshot must be acknowledged");
  expect(state.dirtySnapshot().dirty.empty(), "acknowledged dirty set must be empty");
}

void testRollbackHashAndDestructor()
{
  DesignState state;
  std::vector<int> placement{10, 20, 30};
  state.registerCanonicalProvider("placement", [&placement] {
    std::vector<std::string> records;
    for (size_t index = 0; index < placement.size(); ++index) {
      records.push_back(std::to_string(index) + ":" + std::to_string(placement[index]));
    }
    return records;
  });
  const auto before = state.canonicalHash();

  try {
    MoveTxn transaction(state, "exception rollback");
    const int old_value = placement[1];
    transaction.recordUndo([&placement, old_value] { placement[1] = old_value; });
    placement[1] = 999;
    throw std::runtime_error("injected evaluator failure");
  } catch (const std::runtime_error&) {
  }

  expect(state.version() == 0, "rollback must not increment the version");
  expect(state.canonicalHash() == before, "destructor rollback must restore the canonical hash");
  expect(!state.transactionActive(), "destructor rollback must release transaction ownership");
}

void testNestedTransactionRejected()
{
  DesignState state;
  MoveTxn outer(state, "outer");
  bool rejected = false;
  try {
    MoveTxn inner(state, "inner");
  } catch (const std::logic_error&) {
    rejected = true;
  }
  expect(rejected, "nested transactions must be rejected");
  outer.rollback();
}

void testArtifactFreshness()
{
  DesignState state;
  ArtifactRecord spef{"route.spef", "SPEF", "/tmp/route.spef", std::string(64, 'a'), 0, "slow", ArtifactStatus::kReady};
  std::string error;
  expect(state.publishArtifact(spef, &error), "valid SHA-256 artifact must be accepted: " + error);
  expect(state.artifactFreshness("route.spef") == ArtifactFreshness::kFresh, "new artifact must be fresh");

  MoveTxn transaction(state, "route ECO");
  transaction.commit();
  expect(state.artifactFreshness("route.spef") == ArtifactFreshness::kStale, "design commit must stale an older artifact");

  spef.sha256 = "not-a-hash";
  expect(!state.publishArtifact(spef, &error), "ready artifact without SHA-256 must be rejected");
}

void testCanonicalOrderAndRandomRollback()
{
  DesignState left;
  DesignState right;
  std::vector<std::string> ascending{"a", "b", "c"};
  std::vector<std::string> descending{"c", "b", "a"};
  left.registerCanonicalProvider("objects", [&ascending] { return ascending; });
  right.registerCanonicalProvider("objects", [&descending] { return descending; });
  expect(left.canonicalHash() == right.canonicalHash(), "canonical hash must not depend on insertion order");

  std::mt19937 generator(20260723U);
  std::uniform_int_distribution<size_t> index_distribution(0, ascending.size() - 1);
  for (int iteration = 0; iteration < 128; ++iteration) {
    const auto before = left.canonicalHash();
    const size_t index = index_distribution(generator);
    MoveTxn transaction(left, "random ECO rollback");
    const auto old_value = ascending[index];
    transaction.recordUndo([&ascending, index, old_value] { ascending[index] = old_value; });
    ascending[index] += std::to_string(iteration);
    transaction.rollback();
    expect(left.canonicalHash() == before, "random ECO rollback changed canonical state");
  }
}

}  // namespace

int main()
{
  try {
    testCommitAndDirtyDedup();
    testRollbackHashAndDestructor();
    testNestedTransactionRejected();
    testArtifactFreshness();
    testCanonicalOrderAndRandomRollback();
    std::cout << "DesignState tests passed\n";
    return 0;
  } catch (const std::exception& error) {
    std::cerr << "DesignState test failure: " << error.what() << '\n';
    return 1;
  }
}
