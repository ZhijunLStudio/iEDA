add_library(design_state
  ArtifactIndex.cpp
  DesignState.cpp
  DirtySet.cpp
  MoveTxn.cpp
)

target_include_directories(design_state
  PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
)

add_executable(design_state_test EXCLUDE_FROM_ALL
  tests/DesignStateTest.cpp
)

target_link_libraries(design_state_test PRIVATE design_state)
