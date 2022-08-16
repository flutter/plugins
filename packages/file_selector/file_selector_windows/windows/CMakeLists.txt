cmake_minimum_required(VERSION 3.14)
set(PROJECT_NAME "file_selector_windows")
project(${PROJECT_NAME} LANGUAGES CXX)

set(PLUGIN_NAME "${PROJECT_NAME}_plugin")

list(APPEND PLUGIN_SOURCES
  "file_dialog_controller.cpp"
  "file_dialog_controller.h"
  "file_selector_plugin.cpp"
  "file_selector_plugin.h"
  "messages.g.cpp"
  "messages.g.h"
  "string_utils.cpp"
  "string_utils.h"
)

add_library(${PLUGIN_NAME} SHARED
  "file_selector_windows.cpp"
  "include/file_selector_windows/file_selector_windows.h"
  ${PLUGIN_SOURCES}
)
apply_standard_settings(${PLUGIN_NAME})
set_target_properties(${PLUGIN_NAME} PROPERTIES CXX_VISIBILITY_PRESET hidden)
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)
target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include")
target_link_libraries(${PLUGIN_NAME} PRIVATE flutter flutter_wrapper_plugin)
# Override apply_standard_settings for exceptions due to
# https://developercommunity.visualstudio.com/t/stdany-doesnt-link-when-exceptions-are-disabled/376072
target_compile_definitions(${PLUGIN_NAME} PRIVATE "_HAS_EXCEPTIONS=1")

# List of absolute paths to libraries that should be bundled with the plugin
set(file_selector_bundled_libraries
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
  test/file_selector_plugin_test.cpp
  test/test_main.cpp
  test/test_file_dialog_controller.cpp
  test/test_file_dialog_controller.h
  test/test_utils.cpp
  test/test_utils.h
  ${PLUGIN_SOURCES}
)
apply_standard_settings(${TEST_RUNNER})
target_include_directories(${TEST_RUNNER} PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}")
target_link_libraries(${TEST_RUNNER} PRIVATE flutter_wrapper_plugin)
target_link_libraries(${TEST_RUNNER} PRIVATE gtest gmock)
# Override apply_standard_settings for exceptions due to
# https://developercommunity.visualstudio.com/t/stdany-doesnt-link-when-exceptions-are-disabled/376072
target_compile_definitions(${TEST_RUNNER} PRIVATE "_HAS_EXCEPTIONS=1")
# flutter_wrapper_plugin has link dependencies on the Flutter DLL.
add_custom_command(TARGET ${TEST_RUNNER} POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy_if_different
  "${FLUTTER_LIBRARY}" $<TARGET_FILE_DIR:${TEST_RUNNER}>
)

include(GoogleTest)
gtest_discover_tests(${TEST_RUNNER})
endif()
