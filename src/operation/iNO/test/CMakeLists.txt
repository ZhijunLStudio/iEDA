set(CMAKE_BUILD_TYPE "Debug")

add_executable(test_run_no ${INO_TEST_PATH}/run_no.cpp)
target_link_libraries(test_run_no 
    PUBLIC
        ino_source 
        # irt_test_external_libs 
)

add_executable(ino_config_validation_test NoConfigValidationTest.cc)
target_include_directories(ino_config_validation_test PRIVATE ${INO_CONFIG_PATH})
add_test(NAME ino_config_validation_test COMMAND ino_config_validation_test)

add_executable(ino_failure_semantics_test FailureSemanticsTest.cc)
target_include_directories(ino_failure_semantics_test PRIVATE ${INO_MODULE_PATH}/fix_fanout)
add_test(NAME ino_failure_semantics_test COMMAND ino_failure_semantics_test)
