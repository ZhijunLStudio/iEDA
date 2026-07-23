# Install script for directory: /home/lxq/AiEDA/iEDA.ai/src/operation

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

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for each subdirectory.
  include("/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iDRC/cmake_install.cmake")
  include("/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iECO/cmake_install.cmake")
  include("/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iFP/cmake_install.cmake")
  include("/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iIR/cmake_install.cmake")
  include("/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iLO/cmake_install.cmake")
  include("/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iTM/cmake_install.cmake")
  include("/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iPDN/cmake_install.cmake")
  include("/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iPNP/cmake_install.cmake")
  include("/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iPL/cmake_install.cmake")
  include("/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRT/cmake_install.cmake")
  include("/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iSTA/cmake_install.cmake")
  include("/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iPA/cmake_install.cmake")
  include("/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iTO/cmake_install.cmake")
  include("/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iCTS/cmake_install.cmake")
  include("/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iNO/cmake_install.cmake")
  include("/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/cmake_install.cmake")

endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
if(CMAKE_INSTALL_LOCAL_ONLY)
  file(WRITE "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/install_local_manifest.txt"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
endif()
