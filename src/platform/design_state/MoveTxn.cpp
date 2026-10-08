// ***************************************************************************************
// Copyright (c) 2023-2025 Peng Cheng Laboratory
// Copyright (c) 2023-2025 Institute of Computing Technology, Chinese Academy of Sciences
// Copyright (c) 2023-2025 Beijing Institute of Open Source Chip
//
// iEDA is licensed under Mulan PSL v2.
// ***************************************************************************************
#include "MoveTxn.hh"

#include <exception>
#include <stdexcept>
#include <utility>

namespace ieda::platform {

MoveTxn::MoveTxn(DesignState& state, std::string label) : _state(&state), _label(std::move(label))
{
  _token = _state->acquireTransaction(_label);
  _active = true;
}

MoveTxn::~MoveTxn()
{
  rollbackNoThrow();
}

MoveTxn::MoveTxn(MoveTxn&& other) noexcept
    : _state(other._state),
      _token(other._token),
      _label(std::move(other._label)),
      _dirty(std::move(other._dirty)),
      _undo_actions(std::move(other._undo_actions)),
      _active(other._active)
{
  other._state = nullptr;
  other._token = 0;
  other._active = false;
}

MoveTxn& MoveTxn::operator=(MoveTxn&& other) noexcept
{
  if (this == &other) {
    return *this;
  }
  rollbackNoThrow();
  _state = other._state;
  _token = other._token;
  _label = std::move(other._label);
  _dirty = std::move(other._dirty);
  _undo_actions = std::move(other._undo_actions);
  _active = other._active;
  other._state = nullptr;
  other._token = 0;
  other._active = false;
  return *this;
}

void MoveTxn::recordUndo(Action undo)
{
  ensureActive();
  if (!undo) {
    throw std::invalid_argument("transaction undo action must not be empty");
  }
  _undo_actions.push_back(std::move(undo));
}

void MoveTxn::apply(Action action, Action undo)
{
  ensureActive();
  if (!action) {
    throw std::invalid_argument("transaction apply action must not be empty");
  }
  recordUndo(std::move(undo));
  try {
    action();
  } catch (...) {
    const auto original_error = std::current_exception();
    rollback();
    std::rethrow_exception(original_error);
  }
}

void MoveTxn::markDirty(const DirtySet& dirty)
{
  ensureActive();
  _dirty.merge(dirty);
}

void MoveTxn::commit()
{
  ensureActive();
  _state->commitTransaction(_token, _dirty);
  _undo_actions.clear();
  _active = false;
  _state = nullptr;
  _token = 0;
}

void MoveTxn::rollback()
{
  ensureActive();
  std::exception_ptr rollback_error;
  for (auto iter = _undo_actions.rbegin(); iter != _undo_actions.rend(); ++iter) {
    try {
      (*iter)();
    } catch (...) {
      if (rollback_error == nullptr) {
        rollback_error = std::current_exception();
      }
    }
  }

  _state->abortTransaction(_token);
  _undo_actions.clear();
  _active = false;
  _state = nullptr;
  _token = 0;

  if (rollback_error != nullptr) {
    try {
      std::rethrow_exception(rollback_error);
    } catch (const std::exception& error) {
      throw std::runtime_error(std::string("transaction rollback action failed: ") + error.what());
    } catch (...) {
      throw std::runtime_error("transaction rollback action failed with a non-standard exception");
    }
  }
}

void MoveTxn::ensureActive() const
{
  if (!_active || _state == nullptr) {
    throw std::logic_error("transaction is not active");
  }
}

void MoveTxn::rollbackNoThrow() noexcept
{
  if (!_active) {
    return;
  }
  try {
    rollback();
  } catch (...) {
    // Destructors cannot report a failed external undo. The explicit rollback API does.
  }
}

}  // namespace ieda::platform
