# TODO
# - [DONE] get copying over of libtorch .so and .so.1 files
# - have bundle install maybe? idk
# - upload a release with a readme

cmake_minimum_required(VERSION 3.5 FATAL_ERROR)
project(rave VERSION 0.0.1)

set_property(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY VS_STARTUP_PROJECT rave)

#######################
# Download pytorch libs
#######################

include(FetchContent)
# Set(FETCHCONTENT_QUIET FALSE)

option(BUILD_SHARED_LIBS "Build using shared libraries" OFF)

# Set download url for system-specific pytorch libs
if(WIN32)
  if(GPU_BUILD) 
    message("building with GPU libs...")
    set(url "https://download.pytorch.org/libtorch/cu124/libtorch-win-shared-with-deps-2.4.0%2Bcu124.zip")
  else()
    set(url "https://download.pytorch.org/libtorch/cpu/libtorch-win-shared-with-deps-2.1.2%2Bcpu.zip")
  endif()
elseif(APPLE)
    if(CMAKE_OSX_ARCHITECTURES STREQUAL "arm64")
        # set(url "https://download.pytorch.org/libtorch/cpu/libtorch-macos-arm64-2.2.2.zip")
        set(url "https://chuck.stanford.edu/release/files/extra/lib/libtorch-macos-arm64-2.2.2.zip")
        set(urlomp "https://chuck.stanford.edu/release/files/extra/lib/libomp-macos-arm64.zip")
    elseif(CMAKE_OSX_ARCHITECTURES STREQUAL "x86_64")
        # set(url "https://download.pytorch.org/libtorch/cpu/libtorch-macos-2.0.1.zip")
        set(url "https://chuck.stanford.edu/release/files/extra/lib/libtorch-macos-2.0.1.zip")
    else()
        message(STATUS "Unknown architecture: ${CMAKE_SYSTEM_PROCESSOR}")
    endif()
else() # linux
    set(url "https://download.pytorch.org/libtorch/cpu/libtorch-cxx11-abi-shared-with-deps-2.1.2%2Bcpu.zip")
endif()

message("URL: ${url}")

# Download pytorch libs
FetchContent_Declare(
    pytorch
    URL ${url}
)

# Needed to get package locations and such
FetchContent_GetProperties(pytorch)
if(NOT pytorch_POPULATED)
    FetchContent_Populate(pytorch)
endif()

# Download libomp (workaround for macOS arm64 build)
if(APPLE AND CMAKE_OSX_ARCHITECTURES STREQUAL "arm64")
  FetchContent_Declare(
    libomp
    URL ${urlomp}
)

# Needed to get package locations and such
FetchContent_MakeAvailable(libomp)

endif()


# Cmake doesn't pick this up automatically for whatever reason...
set(Torch_DIR "${pytorch_SOURCE_DIR}/share/cmake/Torch")
find_package(Torch REQUIRED)

#######################
# Download chuck headers
#######################
#FetchContent_Declare(
#    cheaders
#    GIT_REPOSITORY https://github.com/nshaheed/cheaders.git
#    GIT_TAG test
#)
#FetchContent_MakeAvailable(cheaders)

if(MSVC)
  set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /MT")
  set(CMAKE_CXX_FLAGS_MINSIZEREL  "${CMAKE_CXX_FLAGS_MINSIZEREL} /MT")
  set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_CXX_FLAGS_RELWITHDEBINFO} /MT")
  set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} /MT")
endif()

# the rpath is where the library will search for the *.so pytorch files
# set(CMAKE_INSTALL_RPATH "/usr/local/lib/chuck/Rave")

# this allows the chugin to search for dylibs in ./
if (UNIX AND NOT APPLE)
   set(CMAKE_INSTALL_RPATH "$ORIGIN")
endif()

# Enable BUILD_RPATH_USE_ORIGIN
set(CMAKE_BUILD_WITH_INSTALL_RPATH TRUE)

# subdirectories from original nn_tilde code
add_subdirectory(nn_tilde/src/backend) # DEEP LEARNING BACKEND

# message(cmake_source_dir="${CMAKE_CURRENT_SOURCE_DIR}")

#############
# Add sources
#############

# list of chuck files
FILE(GLOB CK_SOURCES
  ${CMAKE_CURRENT_SOURCE_DIR}/cheaders/include/*.h
)

FILE(GLOB NN_TILDE_SOURCES
  ${CMAKE_CURRENT_SOURCE_DIR}/nn_tilde/src/backend/*.h
  ${CMAKE_CURRENT_SOURCE_DIR}/nn_tilde/src/frontend/maxmsp/shared/*.h)


# find all libtorch dlls that eventually need to be copied over
if (MSVC)
   FILE(GLOB Torch_DLLs
     "${pytorch_SOURCE_DIR}/lib/*.dll")
elseif(UNIX AND NOT APPLE) # linux??
    Message("in linux")
   FILE(GLOB Torch_so
     "${pytorch_SOURCE_DIR}/lib/*.so"
     "${pytorch_SOURCE_DIR}/lib/*.so.1"
   )
elseif(APPLE)
  FILE(GLOB Torch_so
     "${pytorch_SOURCE_DIR}/lib/*.dylib"
     "${libomp_SOURCE_DIR}/*.dylib"
)
endif()

FILE(GLOB readme
  "${CMAKE_CURRENT_SOURCE_DIR}/README.md"
  )

message(STATUS "torch_so")
message(Torch_so="${Torch_so}")
message(CMAKE_BINARY_DIR="${CMAKE_BINARY_DIR}")
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
# INSTALL(
  # TARGETS rave
  # LIBRARY DESTINATION "$ENV{HOME}/.chuck/lib/Rave"
  # LIBRARY DESTINATION "/usr/local/lib/chuck/"
  # LIBRARY DESTINATION ${CMAKE_INSTALL_RPATH}
  # ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
  # RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
# )

INSTALL(
  TARGETS rave
  LIBRARY DESTINATION "${CMAKE_BINARY_DIR}/Release/"
  )

message("library install dir: ${CMAKE_INSTALL_LIBDIR}")

file(GENERATE
    OUTPUT "$<TARGET_FILE_DIR:rave>/archive.zip"
    CONTENT "$<TARGET_FILE:rave>"
)

get_target_property(EXECUTABLE_LOCATION rave RUNTIME_OUTPUT_DIRECTORY)
message("Executable Location: ${EXECUTABLE_LOCATION}/rave")



#INSTALL(
#  FILES ${Torch_so}
#  DESTINATION "$ENV{HOME}/.chuck/lib/Rave")

Message("torch so ${Torch_so}")
INSTALL(
  FILES ${Torch_so}
  DESTINATION "${CMAKE_BINARY_DIR}/Release/")

INSTALL(
  FILES ${readme}
  DESTINATION "${CMAKE_BINARY_DIR}/Release/")

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
