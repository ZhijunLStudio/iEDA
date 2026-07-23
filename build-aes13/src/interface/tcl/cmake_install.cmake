# Install script for directory: /home/lxq/AiEDA/iEDA.ai/src/interface/tcl

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
  include("/home/lxq/AiEDA/iEDA.ai/build-aes13/src/interface/tcl/tcl_util/cmake_install.cmake")
  include("/home/lxq/AiEDA/iEDA.ai/build-aes13/src/interface/tcl/tcl_config/cmake_install.cmake")
  include("/home/lxq/AiEDA/iEDA.ai/build-aes13/src/interface/tcl/tcl_idb/cmake_install.cmake")
  include("/home/lxq/AiEDA/iEDA.ai/build-aes13/src/interface/tcl/tcl_flow/cmake_install.cmake")
  include("/home/lxq/AiEDA/iEDA.ai/build-aes13/src/interface/tcl/tcl_icts/cmake_install.cmake")
  include("/home/lxq/AiEDA/iEDA.ai/build-aes13/src/interface/tcl/tcl_idrc/cmake_install.cmake")
  include("/home/lxq/AiEDA/iEDA.ai/build-aes13/src/interface/tcl/tcl_instance/cmake_install.cmake")
  include("/home/lxq/AiEDA/iEDA.ai/build-aes13/src/interface/tcl/tcl_irt/cmake_install.cmake")
  include("/home/lxq/AiEDA/iEDA.ai/build-aes13/src/interface/tcl/tcl_ifp/cmake_install.cmake")
  include("/home/lxq/AiEDA/iEDA.ai/build-aes13/src/interface/tcl/tcl_ipdn/cmake_install.cmake")
  include("/home/lxq/AiEDA/iEDA.ai/build-aes13/src/interface/tcl/tcl_ipnp/cmake_install.cmake")
  include("/home/lxq/AiEDA/iEDA.ai/build-aes13/src/interface/tcl/tcl_ipl/cmake_install.cmake")
  include("/home/lxq/AiEDA/iEDA.ai/build-aes13/src/interface/tcl/tcl_ito/cmake_install.cmake")
  include("/home/lxq/AiEDA/iEDA.ai/build-aes13/src/interface/tcl/tcl_ista/cmake_install.cmake")
  include("/home/lxq/AiEDA/iEDA.ai/build-aes13/src/interface/tcl/tcl_ipw/cmake_install.cmake")
  include("/home/lxq/AiEDA/iEDA.ai/build-aes13/src/interface/tcl/tcl_report/cmake_install.cmake")
  include("/home/lxq/AiEDA/iEDA.ai/build-aes13/src/interface/tcl/tcl_ino/cmake_install.cmake")
  include("/home/lxq/AiEDA/iEDA.ai/build-aes13/src/interface/tcl/tcl_feature/cmake_install.cmake")
  include("/home/lxq/AiEDA/iEDA.ai/build-aes13/src/interface/tcl/tcl_eval/cmake_install.cmake")
  include("/home/lxq/AiEDA/iEDA.ai/build-aes13/src/interface/tcl/tcl_eco/cmake_install.cmake")
  include("/home/lxq/AiEDA/iEDA.ai/build-aes13/src/interface/tcl/tcl_vec/cmake_install.cmake")
  include("/home/lxq/AiEDA/iEDA.ai/build-aes13/src/interface/tcl/tcl_notification/cmake_install.cmake")
  include("/home/lxq/AiEDA/iEDA.ai/build-aes13/src/interface/tcl/tcl_ircx/cmake_install.cmake")

endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
if(CMAKE_INSTALL_LOCAL_ONLY)
  file(WRITE "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/interface/tcl/install_local_manifest.txt"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
endif()
