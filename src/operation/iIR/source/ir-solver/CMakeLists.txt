cmake_minimum_required(VERSION 3.11)

set (CMAKE_CXX_STANDARD 20)

set(CMAKE_BUILD_TYPE "Release")
set(CMAKE_CXX_FLAGS_RELEASE "$ENV{CXXFLAGS} -O3 -Wall")

find_package(Eigen3 REQUIRED)
include_directories(${EIGEN3_INCLUDE_DIRS})

aux_source_directory(./ SRC)

if (BUILD_STATIC_LIB)
    add_library(ir_solver ${SRC})
else()
    add_library(ir_solver SHARED ${SRC})
    target_compile_options(ir_solver PRIVATE -fPIC)
endif()

target_include_directories(ir_solver PRIVATE ${HOME_THIRDPARTY}/spectra/include)

target_link_libraries(ir_solver PUBLIC usage Eigen3::Eigen log)

add_executable(ir_solver_gate_test EXCLUDE_FROM_ALL tests/IRSolverGateTest.cc)
target_include_directories(ir_solver_gate_test PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
target_link_libraries(ir_solver_gate_test PRIVATE ir_solver)

if (CUDA_IR_SOLVER)
    target_link_libraries(ir_solver PUBLIC ir-solver-cuda)
endif()
