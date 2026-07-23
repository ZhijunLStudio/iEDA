



add_library(flow_scheduler
  FlowScheduler.cpp
)

target_include_directories(flow_scheduler
  PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
)

add_executable(flow_scheduler_test EXCLUDE_FROM_ALL
  tests/FlowSchedulerTest.cpp
)

target_link_libraries(flow_scheduler_test PRIVATE flow_scheduler)
