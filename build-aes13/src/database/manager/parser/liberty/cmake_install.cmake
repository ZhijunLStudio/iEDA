# Install script for directory: /home/lxq/AiEDA/iEDA.ai/src/database/manager/parser/liberty

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "/usr/local")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "Release")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

# Install shared libraries without execute permission?
if(NOT DEFINED CMAKE_INSTALL_SO_NO_EXE)
  set(CMAKE_INSTALL_SO_NO_EXE "1")
endif()

# Is this installation the result of a crosscompile?
if(NOT DEFINED CMAKE_CROSSCOMPILING)
  set(CMAKE_CROSSCOMPILING "FALSE")
endif()

# Set path to fallback-tool for dependency-resolution.
if(NOT DEFINED CMAKE_OBJDUMP)
  set(CMAKE_OBJDUMP "/home/lxq/AiEDA/micromamba/envs/ieda-build/bin/x86_64-conda-linux-gnu-objdump")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  if(EXISTS "$ENV{DESTDIR}/home/taosimin/bin/iEDA_bin/test_lib" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}/home/taosimin/bin/iEDA_bin/test_lib")
    file(RPATH_CHECK
         FILE "$ENV{DESTDIR}/home/taosimin/bin/iEDA_bin/test_lib"
         RPATH "")
  endif()
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/home/taosimin/bin/iEDA_bin/test_lib")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/home/taosimin/bin/iEDA_bin" TYPE EXECUTABLE FILES "/home/lxq/AiEDA/iEDA.ai/bin/test_lib")
  if(EXISTS "$ENV{DESTDIR}/home/taosimin/bin/iEDA_bin/test_lib" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}/home/taosimin/bin/iEDA_bin/test_lib")
    file(RPATH_CHANGE
         FILE "$ENV{DESTDIR}/home/taosimin/bin/iEDA_bin/test_lib"
         OLD_RPATH "/home/lxq/AiEDA/iEDA.ai/build-aes13/lib:/home/lxq/AiEDA/iEDA.ai/build-aes13/src/database/manager/builder:/home/lxq/AiEDA/iEDA.ai/build-aes13/src/database/manager/service/def_service:/home/lxq/AiEDA/iEDA.ai/build-aes13/src/database/manager/service/lef_service:/home/lxq/AiEDA/iEDA.ai/build-aes13/src/database/data/design:/home/lxq/AiEDA/iEDA.ai/build-aes13/src/utility/string:/home/lxq/AiEDA/iEDA.ai/build-aes13/src/database/basic/geometry:/home/lxq/AiEDA/iEDA.ai/build-aes13/src/utility/log:"
         NEW_RPATH "")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/home/lxq/AiEDA/micromamba/envs/ieda-build/bin/x86_64-conda-linux-gnu-strip" "$ENV{DESTDIR}/home/taosimin/bin/iEDA_bin/test_lib")
    endif()
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  include("/home/lxq/AiEDA/iEDA.ai/build-aes13/src/database/manager/parser/liberty/CMakeFiles/test_lib.dir/install-cxx-module-bmi-Release.cmake" OPTIONAL)
endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
if(CMAKE_INSTALL_LOCAL_ONLY)
  file(WRITE "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/database/manager/parser/liberty/install_local_manifest.txt"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
endif()
