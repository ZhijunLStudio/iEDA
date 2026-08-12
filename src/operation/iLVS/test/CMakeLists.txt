add_executable(ilvs_core_test
    LvsCoreTest.cpp
)

target_link_libraries(ilvs_core_test
    PRIVATE
    ilvs_api
)

add_test(NAME ilvs_core_test COMMAND ilvs_core_test)
