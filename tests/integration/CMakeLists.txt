# Integration Tests for RetDec
# These tests verify end-to-end functionality across multiple components

cmake_minimum_required(VERSION 3.13)

# Integration tests require the full decompiler to be built
if(NOT RETDEC_TESTS)
    message(STATUS "Integration tests skipped (RETDEC_TESTS=OFF)")
    return()
endif()

# Try to find or use GoogleTest
# RetDec builds its own GoogleTest, so we check if it's available
if(NOT TARGET googletest)
    # GoogleTest not built yet or not available
    # Try to find system GoogleTest
    find_package(GTest QUIET)

    if(NOT GTest_FOUND)
        message(STATUS "Integration tests skipped (GoogleTest not available)")
        message(STATUS "  - GoogleTest will be built by RetDec dependencies")
        message(STATUS "  - Integration tests can be enabled in a future build")
        return()
    endif()

    # Use system GoogleTest
    set(GTEST_TARGET GTest::gtest)
    set(GTEST_MAIN_TARGET GTest::gtest_main)
    message(STATUS "Integration tests using system GoogleTest")
else()
    # Use RetDec's built GoogleTest
    set(GTEST_TARGET googletest)
    set(GTEST_MAIN_TARGET googletest)
    message(STATUS "Integration tests using RetDec's GoogleTest")
endif()

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
        ${GTEST_TARGET}
        ${GTEST_MAIN_TARGET}
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

message(STATUS "Integration tests configured successfully")
