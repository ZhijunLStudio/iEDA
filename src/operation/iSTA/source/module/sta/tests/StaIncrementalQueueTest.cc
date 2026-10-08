#include <iostream>
#include <stdexcept>

#include "StaIncremental.hh"
#include "StaVertex.hh"

int main()
{
  try {
    ista::StaIncremental incremental;
    ista::StaVertex vertex(nullptr);
    vertex.set_level(3);

    ista::StaResetPropagation invalidate_backward;
    invalidate_backward.set_is_bwd();
    invalidate_backward.set_incr_func(&incremental);
    if (!vertex.exec(invalidate_backward)) {
      throw std::runtime_error("backward invalidation failed");
    }
    if (incremental.pendingFwdCount() != 0 || incremental.pendingBwdCount() != 1) {
      throw std::runtime_error("backward invalidation entered the wrong queue");
    }
    if (!incremental.applyBwdQueue()) {
      throw std::runtime_error("backward propagation failed");
    }
    if (incremental.pendingBwdCount() != 0 || !vertex.is_bwd() || vertex.is_bwd_reset()) {
      throw std::runtime_error("backward queue was not applied and released");
    }

    vertex.reset_is_bwd();
    if (!vertex.exec(invalidate_backward) || incremental.pendingBwdCount() != 1) {
      throw std::runtime_error("second ECO could not invalidate the vertex again");
    }
    incremental.clearQueues();
    if (incremental.pendingBwdCount() != 0 || vertex.is_bwd_reset()) {
      throw std::runtime_error("queue clear did not release reset state");
    }

    std::cout << "StaIncremental queue tests passed\n";
    return 0;
  } catch (const std::exception& error) {
    std::cerr << "StaIncremental queue test failure: " << error.what() << '\n';
    return 1;
  }
}
