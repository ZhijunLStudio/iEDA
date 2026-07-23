# Install script for directory: /home/lxq/AiEDA/iEDA.ai/src/third_party/lefdef/def

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
    "/home/lxq/AiEDA/iEDA.ai/src/third_party/lefdef/def/def/def.tab.h"
    "/home/lxq/AiEDA/iEDA.ai/src/third_party/lefdef/def/def/lex.h"
    "/home/lxq/AiEDA/iEDA.ai/src/third_party/lefdef/def/def/defiAlias.hpp"
    "/home/lxq/AiEDA/iEDA.ai/src/third_party/lefdef/def/def/defiAssertion.hpp"
    "/home/lxq/AiEDA/iEDA.ai/src/third_party/lefdef/def/def/defiBlockage.hpp"
    "/home/lxq/AiEDA/iEDA.ai/src/third_party/lefdef/def/def/defiComponent.hpp"
    "/home/lxq/AiEDA/iEDA.ai/src/third_party/lefdef/def/def/defiDebug.hpp"
    "/home/lxq/AiEDA/iEDA.ai/src/third_party/lefdef/def/def/defiDefs.hpp"
    "/home/lxq/AiEDA/iEDA.ai/src/third_party/lefdef/def/def/defiFill.hpp"
    "/home/lxq/AiEDA/iEDA.ai/src/third_party/lefdef/def/def/defiFPC.hpp"
    "/home/lxq/AiEDA/iEDA.ai/src/third_party/lefdef/def/def/defiGroup.hpp"
    "/home/lxq/AiEDA/iEDA.ai/src/third_party/lefdef/def/def/defiIOTiming.hpp"
    "/home/lxq/AiEDA/iEDA.ai/src/third_party/lefdef/def/def/defiKRDefs.hpp"
    "/home/lxq/AiEDA/iEDA.ai/src/third_party/lefdef/def/def/defiMisc.hpp"
    "/home/lxq/AiEDA/iEDA.ai/src/third_party/lefdef/def/def/defiNet.hpp"
    "/home/lxq/AiEDA/iEDA.ai/src/third_party/lefdef/def/def/defiNonDefault.hpp"
    "/home/lxq/AiEDA/iEDA.ai/src/third_party/lefdef/def/def/defiPartition.hpp"
    "/home/lxq/AiEDA/iEDA.ai/src/third_party/lefdef/def/def/defiPath.hpp"
    "/home/lxq/AiEDA/iEDA.ai/src/third_party/lefdef/def/def/defiPinCap.hpp"
    "/home/lxq/AiEDA/iEDA.ai/src/third_party/lefdef/def/def/defiPinProp.hpp"
    "/home/lxq/AiEDA/iEDA.ai/src/third_party/lefdef/def/def/defiProp.hpp"
    "/home/lxq/AiEDA/iEDA.ai/src/third_party/lefdef/def/def/defiPropType.hpp"
    "/home/lxq/AiEDA/iEDA.ai/src/third_party/lefdef/def/def/defiRegion.hpp"
    "/home/lxq/AiEDA/iEDA.ai/src/third_party/lefdef/def/def/defiRowTrack.hpp"
    "/home/lxq/AiEDA/iEDA.ai/src/third_party/lefdef/def/def/defiScanchain.hpp"
    "/home/lxq/AiEDA/iEDA.ai/src/third_party/lefdef/def/def/defiSite.hpp"
    "/home/lxq/AiEDA/iEDA.ai/src/third_party/lefdef/def/def/defiSlot.hpp"
    "/home/lxq/AiEDA/iEDA.ai/src/third_party/lefdef/def/def/defiTimingDisable.hpp"
    "/home/lxq/AiEDA/iEDA.ai/src/third_party/lefdef/def/def/defiUser.hpp"
    "/home/lxq/AiEDA/iEDA.ai/src/third_party/lefdef/def/def/defiUtil.hpp"
    "/home/lxq/AiEDA/iEDA.ai/src/third_party/lefdef/def/def/defiVia.hpp"
    "/home/lxq/AiEDA/iEDA.ai/src/third_party/lefdef/def/def/defrCallBacks.hpp"
    "/home/lxq/AiEDA/iEDA.ai/src/third_party/lefdef/def/def/defrData.hpp"
    "/home/lxq/AiEDA/iEDA.ai/src/third_party/lefdef/def/def/defrReader.hpp"
    "/home/lxq/AiEDA/iEDA.ai/src/third_party/lefdef/def/def/defrSettings.hpp"
    "/home/lxq/AiEDA/iEDA.ai/src/third_party/lefdef/def/def/defwWriterCalls.hpp"
    "/home/lxq/AiEDA/iEDA.ai/src/third_party/lefdef/def/def/defwWriter.hpp"
    "/home/lxq/AiEDA/iEDA.ai/src/third_party/lefdef/def/defzlib/defzlib.hpp"
    )
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE STATIC_LIBRARY FILES "/home/lxq/AiEDA/iEDA.ai/src/third_party/lefdef/def/lib/libdef.a")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  include("/home/lxq/AiEDA/iEDA.ai/build-aes13/src/third_party/lefdef/def/CMakeFiles/def.dir/install-cxx-module-bmi-Release.cmake" OPTIONAL)
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE STATIC_LIBRARY FILES "/home/lxq/AiEDA/iEDA.ai/src/third_party/lefdef/def/lib/libdefzlib.a")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  include("/home/lxq/AiEDA/iEDA.ai/build-aes13/src/third_party/lefdef/def/CMakeFiles/defzlib.dir/install-cxx-module-bmi-Release.cmake" OPTIONAL)
endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
if(CMAKE_INSTALL_LOCAL_ONLY)
  file(WRITE "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/third_party/lefdef/def/install_local_manifest.txt"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
endif()
