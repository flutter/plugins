cmake_minimum_required(VERSION 3.10)
set(PROJECT_NAME "url_launcher_windows")
project(${PROJECT_NAME} LANGUAGES CXX)

set(PLUGIN_NAME "${PROJECT_NAME}_plugin")

add_library(${PLUGIN_NAME} SHARED
  "url_launcher_plugin.cpp"
)
apply_standard_settings(${PLUGIN_NAME})
set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden)
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)
target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include")
target_link_libraries(${PLUGIN_NAME} PRIVATE flutter flutter_wrapper_plugin)

# List of absolute paths to libraries that should be bundled with the plugin
set(file_chooser_bundled_libraries
  ""
  PARENT_SCOPE
)

# === Tests ===

if (${include_${PROJECT_NAME}_tests})
set(TEST_RUNNER_NAME "${PROJECT_NAME}_test")
enable_testing()
# TODO(stuartmorgan): Use a single shared, pre-checked-in googletest instance
# rather than downloading for each plugin. This approach makes sense for a
# template, but not for a monorepo with many plugins.
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

add_executable(${TEST_RUNNER_NAME}
  test/url_launcher_windows_test.cpp
)
target_link_libraries(${TEST_RUNNER_NAME}
  gtest_main
)
include(GoogleTest)
gtest_discover_tests(${TEST_RUNNER_NAME})
endif()
