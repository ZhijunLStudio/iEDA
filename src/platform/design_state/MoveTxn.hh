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
#include <string>
#include <vector>

#include "DesignState.hh"

namespace ieda::platform {

class MoveTxn
{
 public:
  using Action = std::function<void()>;

  explicit MoveTxn(DesignState& state, std::string label = {});
  ~MoveTxn();

  MoveTxn(const MoveTxn&) = delete;
  MoveTxn& operator=(const MoveTxn&) = delete;
  MoveTxn(MoveTxn&& other) noexcept;
  MoveTxn& operator=(MoveTxn&& other) noexcept;

  void recordUndo(Action undo);
  void apply(Action action, Action undo);
  void markDirty(const DirtySet& dirty);

  void commit();
  void rollback();

  bool active() const { return _active; }
  const std::string& label() const { return _label; }
  const DirtySet& dirty() const { return _dirty; }

 private:
  void ensureActive() const;
  void rollbackNoThrow() noexcept;

  DesignState* _state = nullptr;
  uint64_t _token = 0;
  std::string _label;
  DirtySet _dirty;
  std::vector<Action> _undo_actions;
  bool _active = false;
};

}  // namespace ieda::platform
