# Install script for directory: /home/lxq/AiEDA/iEDA.ai/src/third_party/lefdef/lef

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
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include" TYPE FILE FILES
    "/home/lxq/AiEDA/iEDA.ai/src/third_party/lefdef/lef/lef/lef.tab.h"
    "/home/lxq/AiEDA/iEDA.ai/src/third_party/lefdef/lef/lef/lex.h"
    "/home/lxq/AiEDA/iEDA.ai/src/third_party/lefdef/lef/lef/crypt.hpp"
    "/home/lxq/AiEDA/iEDA.ai/src/third_party/lefdef/lef/lef/lefiArray.hpp"
    "/home/lxq/AiEDA/iEDA.ai/src/third_party/lefdef/lef/lef/lefiCrossTalk.hpp"
    "/home/lxq/AiEDA/iEDA.ai/src/third_party/lefdef/lef/lef/lefiDebug.hpp"
    "/home/lxq/AiEDA/iEDA.ai/src/third_party/lefdef/lef/lef/lefiDefs.hpp"
    "/home/lxq/AiEDA/iEDA.ai/src/third_party/lefdef/lef/lef/lefiEncryptInt.hpp"
    "/home/lxq/AiEDA/iEDA.ai/src/third_party/lefdef/lef/lef/lefiKRDefs.hpp"
    "/home/lxq/AiEDA/iEDA.ai/src/third_party/lefdef/lef/lef/lefiLayer.hpp"
    "/home/lxq/AiEDA/iEDA.ai/src/third_party/lefdef/lef/lef/lefiMacro.hpp"
    "/home/lxq/AiEDA/iEDA.ai/src/third_party/lefdef/lef/lef/lefiMisc.hpp"
    "/home/lxq/AiEDA/iEDA.ai/src/third_party/lefdef/lef/lef/lefiNonDefault.hpp"
    "/home/lxq/AiEDA/iEDA.ai/src/third_party/lefdef/lef/lef/lefiProp.hpp"
    "/home/lxq/AiEDA/iEDA.ai/src/third_party/lefdef/lef/lef/lefiPropType.hpp"
    "/home/lxq/AiEDA/iEDA.ai/src/third_party/lefdef/lef/lef/lefiUnits.hpp"
    "/home/lxq/AiEDA/iEDA.ai/src/third_party/lefdef/lef/lef/lefiUser.hpp"
    "/home/lxq/AiEDA/iEDA.ai/src/third_party/lefdef/lef/lef/lefiUtil.hpp"
    "/home/lxq/AiEDA/iEDA.ai/src/third_party/lefdef/lef/lef/lefiVia.hpp"
    "/home/lxq/AiEDA/iEDA.ai/src/third_party/lefdef/lef/lef/lefiViaRule.hpp"
    "/home/lxq/AiEDA/iEDA.ai/src/third_party/lefdef/lef/lef/lefrCallBacks.hpp"
    "/home/lxq/AiEDA/iEDA.ai/src/third_party/lefdef/lef/lef/lefrData.hpp"
    "/home/lxq/AiEDA/iEDA.ai/src/third_party/lefdef/lef/lef/lefrReader.hpp"
    "/home/lxq/AiEDA/iEDA.ai/src/third_party/lefdef/lef/lef/lefrSettings.hpp"
    "/home/lxq/AiEDA/iEDA.ai/src/third_party/lefdef/lef/lef/lefwWriterCalls.hpp"
    "/home/lxq/AiEDA/iEDA.ai/src/third_party/lefdef/lef/lef/lefwWriter.hpp"
    "/home/lxq/AiEDA/iEDA.ai/src/third_party/lefdef/lef/lefzlib/lefzlib.hpp"
    )
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE STATIC_LIBRARY FILES "/home/lxq/AiEDA/iEDA.ai/src/third_party/lefdef/lef/lib/liblef.a")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  include("/home/lxq/AiEDA/iEDA.ai/build-aes13/src/third_party/lefdef/lef/CMakeFiles/lef.dir/install-cxx-module-bmi-Release.cmake" OPTIONAL)
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE STATIC_LIBRARY FILES "/home/lxq/AiEDA/iEDA.ai/src/third_party/lefdef/lef/lib/liblefzlib.a")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  include("/home/lxq/AiEDA/iEDA.ai/build-aes13/src/third_party/lefdef/lef/CMakeFiles/lefzlib.dir/install-cxx-module-bmi-Release.cmake" OPTIONAL)
endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
if(CMAKE_INSTALL_LOCAL_ONLY)
  file(WRITE "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/third_party/lefdef/lef/install_local_manifest.txt"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
endif()
