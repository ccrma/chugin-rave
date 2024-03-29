# TODO
# - [DONE] get copying over of libtorch .so and .so.1 files
# - have bundle install maybe? idk
# - upload a release with a readme

cmake_minimum_required(VERSION 3.0 FATAL_ERROR)
project(rave VERSION 0.0.1)

set_property(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY VS_STARTUP_PROJECT rave)


#######################
# Download pytorch libs
#######################

# include(FetchContent)
# Set(FETCHCONTENT_QUIET FALSE)

# # set(url https://download.pytorch.org/libtorch/cpu/libtorch-win-shared-with-deps-2.1.0%2Bcpu.zip)
# set(url https://download.pytorch.org/libtorch/cpu/libtorch-cxx11-abi-shared-with-deps-2.1.0%2Bcpu.zip)

# FetchContent_Declare(Torch
#   URL ${url}
#   # URL_HASH SHA256=${hash}
#   )

# FetchContent_MakeAvailable(Torch)
# list(APPEND CMAKE_PREFIX_PATH "${torch_SOURCE_DIR}")

# set(Torch_DIR "${torch_SOURCE_DIR}/share/cmake/Torch/")
# set(TORCH_INSTALL_PREFIX "${Torch_DIR}/")

option(BUILD_SHARED_LIBS "Build using shared libraries" OFF)

if(MSVC)
  set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /MT")
  set(CMAKE_CXX_FLAGS_MINSIZEREL  "${CMAKE_CXX_FLAGS_MINSIZEREL} /MT")
  set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_CXX_FLAGS_RELWITHDEBINFO} /MT")
  set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} /MT")
endif()

# the rpath is where the library will search for the *.so pytorch files
# set(CMAKE_INSTALL_RPATH "/usr/local/lib/chuck/Rave")

# this allows the chugin to search for dylibs in ./
if (LINUX)
   set(CMAKE_INSTALL_RPATH "$ORIGIN")
endif()

# set(CMAKE_POSITION_INDEPENDENT_CODE ON)

add_subdirectory(nn_tilde/src/backend) # DEEP LEARNING BACKEND
find_package(Torch REQUIRED)


####################################################################
# Because the libtorch cmake scripts are not set up to handle static
# build properly, this takes the returned ${TORCH_LIBRARIES} variable
# from find_package(Torch REQUIRED) and wraps a group around the link
# to libtorch_cpu.a This is needed to avoid circular dependencies with
# the other .a files
####################################################################

message(torch_libs=${TORCH_LIBRARIES})
set(_updated_torch_libs)

foreach (item ${TORCH_LIBRARIES})
    string(REGEX MATCH "libtorch_cpu.a" is_match "${item}")
    # once we find the offending file, wrap it in a group...
    if(is_match)
        list(APPEND _updated_torch_libs "-Wl,--start-group")
        list(APPEND _updated_torch_libs "${item}")
        list(APPEND _updated_torch_libs "-Wl,--end-group")
    else()
        list(APPEND _updated_torch_libs "${item}")
    endif()
endforeach()

# repalce the existing TORCH_LIBRARIES var with our new one
set(TORCH_LIBRARIES ${_updated_torch_libs})

include_directories(
    "${TORCH_INCLUDE_DIRS}" # libtorch headers
)

message(cmake_source_dir="${CMAKE_CURRENT_SOURCE_DIR}")

# list of chuck files
FILE(GLOB CK_SOURCES
  ${CMAKE_CURRENT_SOURCE_DIR}/cheaders/include/*.h
  # ${CMAKE_CURRENT_SOURCE_DIR}/../chuck/include/util_sndfile.c
)

# set_source_files_properties(CK_SOURCE PROPERTIES HEADER_FILE_ONLY TRUE)

FILE(GLOB NN_TILDE_SOURCES
  ${CMAKE_CURRENT_SOURCE_DIR}/nn_tilde/src/backend/*.h
  ${CMAKE_CURRENT_SOURCE_DIR}/nn_tilde/src/frontend/maxmsp/shared/*.h)

# CMake doesn't expand ~/ by default, so we do that here
get_filename_component(torch_dir_absolute ${Torch_DIR} ABSOLUTE)

# find all libtorch dlls that eventually need to be copied over
if (MSVC)
   FILE(GLOB Torch_DLLs
     "${Torch_DIR}/../../../lib/*.dll")
elseif(LINUX)
   FILE(GLOB Torch_so
     "${torch_dir_absolute}/../../../lib/*.so"
     "${torch_dir_absolute}/../../../lib/*.so.1"
   )
elseif(APPLE)
  message("in apple ${torch_dir_absolute}")
  FILE(GLOB Torch_so
     "${torch_dir_absolute}/../../../lib/*.dylib"
)
endif()

FILE(GLOB readme
  "${CMAKE_CURRENT_SOURCE_DIR}/README.md"
  )

message(STATUS "torch_so")
message(Torch_so="${Torch_so}")
message(CMAKE_BINARY_DIR="${CMAKE_BINARY_DIR}")
message(torch_dir_absolute"${torch_dir_absolute}")
message(NN_TILDE_SOURCES="${NN_TILDE_SOURCES}")
message(Torch_DLLS="${Torch_DLLs}")
message(Torch_DIR="${Torch_DIR}")

set(Sources
        "rave.cpp"
)

source_group("Sources" FILES ${Sources})

add_library(rave SHARED ${CK_SOURCES} ${NN_TILDE_SOURCES} ${Sources})

set_target_properties(rave PROPERTIES CXX_STANDARD 17)
# output as .chug file
set_target_properties(rave PROPERTIES OUTPUT_NAME "Rave.chug")
set_target_properties(rave PROPERTIES PREFIX "")
set_target_properties(rave PROPERTIES SUFFIX "")

# this allows the chugin to search for dylibs in ./
if (APPLE)
   set_target_properties(rave PROPERTIES
     BUILD_WITH_INSTALL_RPATH TRUE
     INSTALL_RPATH "@loader_path"
   )
endif()
# set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++17")

# target_compile_definitions(rave PUBLIC)

target_compile_definitions(rave
  PUBLIC
  # USE_BUILTIN_FFT
  __PLATFORM_LINUX__
  USE_PTHREADS
  )
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++17 -fPIC")


if(MSVC)
    target_compile_definitions(rave
    PUBLIC
    USE_BUILTIN_FFT
    NOMINMAX
    _WINDOWS
    WIN32
    __WINDOWS_MODERN__
    __PLATFORM_WIN32__
    __WINDOWS_DS__
   )
endif()

target_link_libraries(rave PRIVATE backend "${TORCH_LIBRARIES}")

# Include header directories
target_include_directories(rave PUBLIC
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/cheaders/include>
  # $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/../chuck/include/chuck_dl.h>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/nn_tilde/src/backend>
    $<INSTALL_INTERFACE:rave
    )



# Install library
INSTALL(
  TARGETS rave
  LIBRARY DESTINATION "$ENV{HOME}/.chuck/lib/Rave"
  # LIBRARY DESTINATION "/usr/local/lib/chuck/"
  # LIBRARY DESTINATION ${CMAKE_INSTALL_RPATH}
  # ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
  # RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  )

INSTALL(
  TARGETS rave
  LIBRARY DESTINATION "${CMAKE_BINARY_DIR}/Release/"
  )

message(STATUS "bindir")
message(CMAKE_INSTALL_PREFIX="${CMAKE_INSTALL_PREFIX}")
message(CMAKE_INSTALL_BINDIR="${CMAKE_INSTALL_BINDIR}")
message(CMAKE_INSTALL_LIBDIR="${CMAKE_INSTALL_LIBDIR}")


INSTALL(
  FILES ${Torch_so}
  DESTINATION "$ENV{HOME}/.chuck/lib/Rave")

INSTALL(
  FILES ${Torch_so}
  DESTINATION "${CMAKE_BINARY_DIR}/Release/")

INSTALL(
  FILES ${readme}
  DESTINATION "${CMAKE_BINARY_DIR}/Release/")

# INSTALL(
#   FILES ${Torch_so}
#   DESTINATION "/usr/local/lib/chuck")

# rename to .chug file
add_custom_command(TARGET ${PROJECT_NAME}
  POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy_if_different
  "$<TARGET_FILE:rave>"
  "$<TARGET_FILE_DIR:rave>/rave.chug")



if (MSVC)
  set_target_properties(${PROJECT_NAME} PROPERTIES
                        VS_DEBUGGER_COMMAND "C:\\Users\\nick\\Documents\\chuck\\src\\visual-studio\\Debug\\chuck.exe"
                        VS_DEBUGGER_COMMAND_ARGUMENTS "--chugin:build/Debug/rave.chug ../rave_test.ck")

  message(STATUS "in MSVC!")

  # copy chugin over to the relevant chuck dir
  add_custom_command(TARGET ${PROJECT_NAME}
                     POST_BUILD
                     COMMAND ${CMAKE_COMMAND} -E copy_if_different
                     "$<TARGET_FILE:rave>"
                     "%USERPROFILE%/Documents/ChucK/chugins/rave.chug")

  # rename to .chug file
  add_custom_command(TARGET ${PROJECT_NAME}
                     POST_BUILD
                     COMMAND ${CMAKE_COMMAND} -E copy_if_different
                     "$<TARGET_FILE:rave>"
                     "$<TARGET_FILE_DIR:rave>/rave.chug")

  # copy libtoch dlls to build directory (for unit tests)
  add_custom_command(TARGET ${PROJECT_NAME}  POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
		${Torch_DLLs}
        $<TARGET_FILE_DIR:rave>)
endif()

############################
### ~~~~~~ Unit Tests ~~~~~~
############################

#[[
set(UNIT_TEST_TARGET_NAME rave_test)
add_library(${UNIT_TEST_TARGET_NAME} SHARED)

target_sources(${UNIT_TEST_TARGET_NAME} PRIVATE
    rave_test.cpp
)
target_link_libraries(${UNIT_TEST_TARGET_NAME}
    PRIVATE
	MSUnitTestFramework::MSUnitTestFramework
	rave
	backend
)

enable_testing()

add_library(MSUnitTestFramework::MSUnitTestFramework SHARED IMPORTED)
set_target_properties(MSUnitTestFramework::MSUnitTestFramework PROPERTIES
  # INTERFACE_INCLUDE_DIRECTORIES "$ENV{VCInstallDir}Auxiliary/VS/UnitTest/include"
  # IMPORTED_IMPLIB "$ENV{VCInstallDir}Auxiliary/VS/UnitTest/lib/x86/Microsoft.VisualStudio.TestTools.CppUnitTestFramework.lib"
  IMPORTED_IMPLIB "C:/Program Files/Microsoft Visual Studio/2022/Community/VC/Auxiliary/VS/UnitTest/lib/x64/Microsoft.VisualStudio.TestTools.CppUnitTestFramework.lib"
  INTERFACE_INCLUDE_DIRECTORIES "C:/Program Files/Microsoft Visual Studio/2022/Community/VC/Auxiliary/VS/UnitTest/include"
)
set(MSUnitTestFramework_FOUND TRUE)
]]
