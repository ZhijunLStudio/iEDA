#pragma once

#include <functional>
#include <utility>

namespace ipl {

template <typename FlowRunner>
auto propagatePlacementFlowResult(FlowRunner&& run_flow) -> bool
{
  return std::invoke(std::forward<FlowRunner>(run_flow));
}

inline auto placementTclResult(bool placement_succeeded) -> unsigned
{
  return placement_succeeded ? 1U : 0U;
}

}  // namespace ipl
