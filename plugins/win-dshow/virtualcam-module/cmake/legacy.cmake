cmake_minimum_required(VERSION 3.5)
project(obs-virtualcam-module)

if(CMAKE_SIZEOF_VOID_P EQUAL 8)
  set(_output_suffix "64")
else()
  set(_output_suffix "32")
endif()

add_library(obs-virtualcam-module MODULE)
add_library(OBS::virtualcam-module ALIAS obs-virtualcam-module)

target_sources(
  obs-virtualcam-module
  PRIVATE sleepto.c
          sleepto.h
          placeholder.cpp
          virtualcam-module.cpp
          virtualcam-filter.cpp
          virtualcam-filter.hpp
          virtualcam-module.rc
          ../shared-memory-queue.c
          ../shared-memory-queue.h
          ../tiny-nv12-scale.c
          ../tiny-nv12-scale.h)

target_include_directories(obs-virtualcam-module PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/..)

set(MODULE_DESCRIPTION "HD Camera output module")

configure_file(${CMAKE_SOURCE_DIR}/cmake/bundle/windows/obs-module.rc.in virtualcam-module.rc)

target_sources(obs-virtualcam-module PRIVATE virtualcam-module.rc)

target_link_libraries(obs-virtualcam-module PRIVATE OBS::libdshowcapture OBS::libdshowcapture-external setupapi winmm
                                                    strmiids gdiplus)

target_link_options(obs-virtualcam-module PRIVATE "LINKER:/ignore:4104")

configure_file(${CMAKE_CURRENT_SOURCE_DIR}/virtualcam-module.def.in ${CMAKE_CURRENT_BINARY_DIR}/virtualcam-module.def)

target_sources(obs-virtualcam-module PRIVATE ${CMAKE_CURRENT_BINARY_DIR}/virtualcam-module.def)

target_include_directories(obs-virtualcam-module PRIVATE ${CMAKE_CURRENT_BINARY_DIR}/../config
                                                         ${CMAKE_SOURCE_DIR}/libobs)

target_compile_definitions(obs-virtualcam-module PRIVATE VIRTUALCAM_AVAILABLE UNICODE _UNICODE _CRT_SECURE_NO_WARNINGS
                                                         _CRT_NONSTDC_NO_WARNINGS OBS_LEGACY)

if(MSVC)
  target_compile_options(obs-virtualcam-module PRIVATE "$<IF:$<CONFIG:Debug>,/MTd,/MT>")
  add_target_resource(win-dshow "$<TARGET_PDB_FILE:obs-virtualcam-module>" "obs-plugins/win-dshow/" OPTIONAL)

endif()

set_target_properties(obs-virtualcam-module PROPERTIES FOLDER "plugins/win-dshow")

set_target_properties(obs-virtualcam-module PROPERTIES OUTPUT_NAME "obs-virtualcam-module${_output_suffix}")

add_target_resource(win-dshow "$<TARGET_FILE:obs-virtualcam-module>" "obs-plugins/win-dshow/")
