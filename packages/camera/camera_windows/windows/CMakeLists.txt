cmake_minimum_required(VERSION 3.14)
set(PROJECT_NAME "camera_windows")
project(${PROJECT_NAME} LANGUAGES CXX)

# This value is used when generating builds using this plugin, so it must
# not be changed
set(PLUGIN_NAME "${PROJECT_NAME}_plugin")

list(APPEND PLUGIN_SOURCES
  "camera_plugin.h"
  "camera_plugin.cpp"
  "camera.h"
  "camera.cpp"
  "capture_controller.h"
  "capture_controller.cpp"
  "capture_controller_listener.h"
  "capture_engine_listener.h"
  "capture_engine_listener.cpp"
  "string_utils.h"
  "string_utils.cpp"
  "capture_device_info.h"
  "capture_device_info.cpp"
  "preview_handler.h"
  "preview_handler.cpp"
  "record_handler.h"
  "record_handler.cpp"
  "photo_handler.h"
  "photo_handler.cpp"
  "texture_handler.h"
  "texture_handler.cpp"
  "com_heap_ptr.h"
)

add_library(${PLUGIN_NAME} SHARED
  "camera_windows.cpp"
  "include/camera_windows/camera_windows.h"
  ${PLUGIN_SOURCES}
)

apply_standard_settings(${PLUGIN_NAME})
set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden)
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)
target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include")
target_link_libraries(${PLUGIN_NAME} PRIVATE flutter flutter_wrapper_plugin)
target_link_libraries(${PLUGIN_NAME} PRIVATE mf mfplat mfuuid d3d11)

# List of absolute paths to libraries that should be bundled with the plugin
set(camera_windows_bundled_libraries
  ""
  PARENT_SCOPE
)


# === Tests ===

if (${include_${PROJECT_NAME}_tests})
set(TEST_RUNNER "${PROJECT_NAME}_test")
enable_testing()
# TODO(stuartmorgan): Consider using a single shared, pre-checked-in googletest
# instance rather than downloading for each plugin. This approach makes sense
# for a template, but not for a monorepo with many plugins.
include(FetchContent)
FetchContent_Declare(
  googletest
  URL https://github.com/google/googletest/archive/release-1.11.0.zip
)
# Prevent overriding the parent project's compiler/linker settings
set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
# Disable install commands for gtest so it doesn't end up in the bundle.
set(INSTALL_GTEST OFF CACHE BOOL "Disable installation of googletest" FORCE)

FetchContent_MakeAvailable(googletest)

# The plugin's C API is not very useful for unit testing, so build the sources
# directly into the test binary rather than using the DLL.
add_executable(${TEST_RUNNER}
  test/mocks.h
  test/camera_plugin_test.cpp
  test/camera_test.cpp
  test/capture_controller_test.cpp
  ${PLUGIN_SOURCES}
)
apply_standard_settings(${TEST_RUNNER})
target_include_directories(${TEST_RUNNER} PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}")
target_link_libraries(${TEST_RUNNER} PRIVATE flutter_wrapper_plugin)
target_link_libraries(${TEST_RUNNER} PRIVATE mf mfplat mfuuid d3d11)
target_link_libraries(${TEST_RUNNER} PRIVATE gtest_main gmock)

# flutter_wrapper_plugin has link dependencies on the Flutter DLL.
add_custom_command(TARGET ${TEST_RUNNER} POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy_if_different
  "${FLUTTER_LIBRARY}" $<TARGET_FILE_DIR:${TEST_RUNNER}>
)

include(GoogleTest)
gtest_discover_tests(${TEST_RUNNER})
endif()
