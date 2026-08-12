message(STATUS "")
message(STATUS "############## LVS: START CMAKE ##############")

set(CMAKE_CXX_STANDARD 20)

set(HOME_ILVS ${HOME_OPERATION}/iLVS)
set(ILVS_API ${HOME_ILVS}/api)
set(ILVS_SOURCE ${HOME_ILVS}/source)
set(ILVS_TOOL ${HOME_ILVS}/tool)
set(ILVS_TEST ${HOME_ILVS}/test)

add_subdirectory(${ILVS_SOURCE})
add_subdirectory(${ILVS_API})
add_subdirectory(${ILVS_TOOL})
add_subdirectory(${ILVS_TEST})

message(STATUS "############## LVS: END CMAKE ##############")
