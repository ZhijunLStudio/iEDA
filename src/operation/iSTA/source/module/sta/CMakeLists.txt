cmake_minimum_required(VERSION 3.11)

set (CMAKE_CXX_STANDARD 20)

if(NOT DEFINED CMD_BUILD)
    set(CMAKE_BUILD_TYPE "Debug")
endif()

aux_source_directory(./ SRC)
add_library(sta ${SRC})

add_executable(sta_incremental_queue_test EXCLUDE_FROM_ALL
    tests/StaIncrementalQueueTest.cc)
target_include_directories(sta_incremental_queue_test PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
target_link_libraries(sta_incremental_queue_test PRIVATE sta usage)

target_link_libraries(sta 
    liberty 
    delay 
    spef 
    sdc 
    sdc-cmd 
    verilog 
    aocv-parser 
    graph sdc 
    absl::btree 
    tcl 
    time 
    report_table 
    stdc++fs 
    log
    yaml-cpp)

if (USE_CUDA_MODE)
target_link_libraries(sta
    delay-gpu 
    propagation-gpu
)
endif()
