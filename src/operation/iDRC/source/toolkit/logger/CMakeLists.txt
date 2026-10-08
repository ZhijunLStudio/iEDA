if(DEBUG_IDRC_LOGGER)
    message(STATUS "DRC: DEBUG_IDRC_LOGGER")
    set(CMAKE_BUILD_TYPE "Debug")
else()
    message(STATUS "DRC: RELEASE_IDRC_LOGGER")
    set(CMAKE_BUILD_TYPE "Release")
endif()

add_library(idrc_logger
    ${IDRC_TOOLKIT}/logger/Logger.cpp
)

target_link_libraries(idrc_logger
    PUBLIC
    idrc_data_manager
)

target_include_directories(idrc_logger
    PUBLIC
    ${IDRC_TOOLKIT}/logger
)

add_executable(idrc_logger_exit_test
    ${IDRC_TOOLKIT}/logger/tests/LoggerExitTest.cpp
    ${IDRC_TOOLKIT}/logger/Logger.cpp
)

target_include_directories(idrc_logger_exit_test
    PRIVATE
    ${IDRC_TOOLKIT}/logger
    ${IDRC_DATA_MANAGER}/advance
)

add_test(NAME idrc_logger_exit_test COMMAND idrc_logger_exit_test)
