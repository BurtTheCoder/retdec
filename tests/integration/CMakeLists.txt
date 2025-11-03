# Integration Tests for RetDec
# These tests verify end-to-end functionality across multiple components

cmake_minimum_required(VERSION 3.13)

# Integration tests require the full decompiler to be built
if(NOT RETDEC_TESTS)
    return()
endif()

# Find GoogleTest
find_package(GTest REQUIRED)

# Create integration test data directory
set(INTEGRATION_TEST_DATA_DIR "${CMAKE_CURRENT_SOURCE_DIR}/data")
file(MAKE_DIRECTORY "${INTEGRATION_TEST_DATA_DIR}")

# Define integration test executable
add_executable(retdec-integration-tests
    test_basic_decompilation.cpp
    test_architecture_support.cpp
)

target_link_libraries(retdec-integration-tests
    PRIVATE
        retdec::bin2llvmir
        retdec::llvmir2hll
        retdec::fileformat
        retdec::loader
        retdec::config
        retdec::common
        GTest::gtest
        GTest::gtest_main
)

target_include_directories(retdec-integration-tests
    PRIVATE
        ${CMAKE_SOURCE_DIR}/include
)

# Pass test data directory to tests
target_compile_definitions(retdec-integration-tests
    PRIVATE
        INTEGRATION_TEST_DATA_DIR="${INTEGRATION_TEST_DATA_DIR}"
)

# Add test to CTest
add_test(
    NAME retdec-integration-tests
    COMMAND retdec-integration-tests
)

# Set test properties
set_tests_properties(retdec-integration-tests
    PROPERTIES
        LABELS "integration"
        TIMEOUT 300
)

# Install integration tests (optional)
install(TARGETS retdec-integration-tests
    DESTINATION bin
)

message(STATUS "Integration tests configured")
