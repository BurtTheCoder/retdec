
cmake_minimum_required(VERSION 3.13)

project(retdec
	LANGUAGES C CXX
	VERSION 5.0
)

# Set policy CMP0135 to NEW to use extraction timestamps for downloaded archives
# This prevents warnings about URL download timestamp behavior
if(POLICY CMP0135)
	cmake_policy(SET CMP0135 NEW)
endif()

include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/GetGitRevisionDescription.cmake)
get_git_head_revision(
	RETDEC_GIT_REFSPEC
	RETDEC_GIT_COMMIT_HASH
)
git_describe(
	RETDEC_GIT_VERSION_TAG
	"--tags"
)
string(TIMESTAMP RETDEC_BUILD_DATE UTC)

set(CMAKE_POSITION_INDEPENDENT_CODE ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Set the default build type to 'Release'.
if(NOT CMAKE_BUILD_TYPE)
	set(default_build_type "Release")
	message(STATUS "Setting build type to '${default_build_type}' as none was specified.")
	set(CMAKE_BUILD_TYPE "${default_build_type}" CACHE STRING "Choose the type of build." FORCE)
endif()

# Add code coverage support for Debug builds with tests enabled.
# gcov/lcov are not available on MSVC, so only apply to GCC/Clang.
if(CMAKE_BUILD_TYPE MATCHES Debug AND RETDEC_TESTS)
	if(NOT MSVC)
		set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} --coverage")
		set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} --coverage")
		set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} --coverage")
		message(STATUS "Code coverage enabled for Debug build with tests")
	endif()
endif()

## Includes.
include(GNUInstallDirs)
include(CMakePackageConfigHelpers)
include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/utils.cmake)
include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/options.cmake)

# RetDec, and some dependencies (e.g. LLVM, Keystone), require Python 3.
find_package(Python3 3.4 REQUIRED)
set(PYTHON_EXECUTABLE ${Python3_EXECUTABLE})

### Variables.

## Repository directories.
set(RETDEC_CMAKE_DIR                "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
set(RETDEC_DEPS_DIR                 "${CMAKE_CURRENT_SOURCE_DIR}/deps")
set(RETDEC_DOC_DIR                  "${CMAKE_CURRENT_SOURCE_DIR}/doc")
set(RETDEC_INCLUDE_DIR              "${CMAKE_CURRENT_SOURCE_DIR}/include")
set(RETDEC_SCRIPTS_DIR              "${CMAKE_CURRENT_SOURCE_DIR}/scripts")
set(RETDEC_SOURCE_DIR               "${CMAKE_CURRENT_SOURCE_DIR}/src")
set(RETDEC_SUPPORT_DIR              "${CMAKE_CURRENT_SOURCE_DIR}/support")
set(RETDEC_TESTS_DIR                "${CMAKE_CURRENT_SOURCE_DIR}/tests")
## Installation directories.
# Bins.
set(RETDEC_INSTALL_BIN_DIR          "${CMAKE_INSTALL_BINDIR}")
set(RETDEC_INSTALL_BIN_DIR_ABS      "${CMAKE_INSTALL_PREFIX}/${RETDEC_INSTALL_BIN_DIR}")
set(RETDEC_INSTALL_TESTS_DIR        "${RETDEC_INSTALL_BIN_DIR}")
# Includes.
set(RETDEC_INSTALL_INCLUDE_DIR      "${CMAKE_INSTALL_INCLUDEDIR}")
set(RETDEC_INSTALL_DEPS_INCLUDE_DIR "${RETDEC_INSTALL_INCLUDE_DIR}/retdec")
# Libs.
set(RETDEC_INSTALL_LIB_DIR          "${CMAKE_INSTALL_LIBDIR}")
set(RETDEC_INSTALL_LIB_DIR_ABS      "${CMAKE_INSTALL_PREFIX}/${RETDEC_INSTALL_LIB_DIR}")
# Data.
set(RETDEC_INSTALL_DATA_DIR         "${CMAKE_INSTALL_DATADIR}/retdec")
set(RETDEC_INSTALL_CMAKE_DIR        "${RETDEC_INSTALL_DATA_DIR}/cmake")
set(RETDEC_INSTALL_DOC_DIR          "${RETDEC_INSTALL_DATA_DIR}/doc")
set(RETDEC_INSTALL_SUPPORT_DIR      "${RETDEC_INSTALL_DATA_DIR}/support")
set(RETDEC_INSTALL_SUPPORT_DIR_ABS  "${CMAKE_INSTALL_PREFIX}/${RETDEC_INSTALL_SUPPORT_DIR}")

# On Linux and macOS, set RPATH relative to the origin of the installed
# executables (i.e. relative to the bin directory). This allows us to move the
# installation directory into a different location after installation, which is
# useful e.g. when the installation is performed on one machine but we want to
# run the executables on a different machine.
#
# On Windows, there is no need to set anything as DLLs are installed into the
# bin directory, where they are automatically picked up by executables.
#
# For more details, see
#  - https://github.com/avast/retdec/issues/77
#  - https://cmake.org/Wiki/CMake_RPATH_handling
if(APPLE)
	set(CMAKE_INSTALL_RPATH "@executable_path/../lib")
elseif(UNIX)
	set(CMAKE_INSTALL_RPATH "$ORIGIN/../lib")
endif()

# Suppress superfluous ranlib warnings about "*.a" having no symbols on MacOSX.
if (APPLE)
	set(CMAKE_C_ARCHIVE_CREATE   "<CMAKE_AR> Scr <TARGET> <LINK_FLAGS> <OBJECTS>")
	set(CMAKE_CXX_ARCHIVE_CREATE "<CMAKE_AR> Scr <TARGET> <LINK_FLAGS> <OBJECTS>")
	set(CMAKE_C_ARCHIVE_FINISH   "<CMAKE_RANLIB> -no_warning_for_no_symbols -c <TARGET>")
	set(CMAKE_CXX_ARCHIVE_FINISH "<CMAKE_RANLIB> -no_warning_for_no_symbols -c <TARGET>")
endif()

# Build all external projects in the same directory that is directly inside the
# build directory. This reduces path lengths, which is important on Windows as
# there is a limit on how long a path can be.
set(EP_PREFIX "${PROJECT_BINARY_DIR}/external")
set_directory_properties(PROPERTIES EP_PREFIX "${EP_PREFIX}")

# Compilation warnings.
if(MSVC)
	# Enable warnings at level 3 (reasonable level)
	# Level 4 (/W4) is too verbose for now, but can be enabled in future
	if(CMAKE_CXX_FLAGS MATCHES "/W[0-4]")
		string(REGEX REPLACE "/W[0-4]" "/W3" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
	else()
		set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /W3")
	endif()

	# Suppress specific warnings that are noisy or false positives
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /wd4101") # unreferenced local variable
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /wd4267") # conversion from 'size_t' to 'type', possible loss of data
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /wd4244") # conversion from 'type1' to 'type2', possible loss of data
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /wd4800") # forcing value to bool 'true' or 'false'

	# Silence C++17 deprecation warnings
	add_definitions(-D_SILENCE_CXX17_ITERATOR_BASE_CLASS_DEPRECATION_WARNING)

	if(RETDEC_MSVC_STATIC_RUNTIME)
		string(REPLACE "/MD" "/MT" CMAKE_CXX_FLAGS_RELEASE ${CMAKE_CXX_FLAGS_RELEASE})
		string(REPLACE "/MD" "/MT" CMAKE_C_FLAGS_RELEASE ${CMAKE_C_FLAGS_RELEASE})

		string(REPLACE "/MD" "/MT" CMAKE_CXX_FLAGS_RELWITHDEBINFO ${CMAKE_CXX_FLAGS_RELWITHDEBINFO})
		string(REPLACE "/MD" "/MT" CMAKE_C_FLAGS_RELWITHDEBINFO ${CMAKE_C_FLAGS_RELWITHDEBINFO})

		string(REPLACE "/MD" "/MT" CMAKE_CXX_FLAGS_MINSIZEREL ${CMAKE_CXX_FLAGS_MINSIZEREL})
		string(REPLACE "/MD" "/MT" CMAKE_C_FLAGS_MINSIZEREL ${CMAKE_C_FLAGS_MINSIZEREL})

		string(REPLACE "/MDd" "/MT" CMAKE_CXX_FLAGS_DEBUG ${CMAKE_CXX_FLAGS_DEBUG})
		string(REPLACE "/MDd" "/MT" CMAKE_C_FLAGS_DEBUG ${CMAKE_C_FLAGS_DEBUG})

		set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /MT")
		set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /MT")
		set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /MT")
		set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_CXX_FLAGS_RELWITHDEBINFO} /MT")
		set(CMAKE_CXX_FLAGS_MINSIZEREL "${CMAKE_CXX_FLAGS_MINSIZEREL} /MT")
		set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} /MT")
	endif()
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR
		CMAKE_CXX_COMPILER_ID STREQUAL "Clang" OR
		CMAKE_CXX_COMPILER_ID STREQUAL "AppleClang")
	# Unify visibility to meet LLVM's default.
	include(CheckCXXCompilerFlag)

	check_cxx_compiler_flag("-fvisibility-inlines-hidden" SUPPORTS_FVISIBILITY_INLINES_HIDDEN_FLAG)
	append_if(SUPPORTS_FVISIBILITY_INLINES_HIDDEN_FLAG "-fvisibility-inlines-hidden" CMAKE_CXX_FLAGS)

	# Enable standard warnings.
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wextra")

	# Enable additional warnings that are not included in -Wall and -Wextra.
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wcast-align")
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wcast-qual")
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wswitch-default")
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wuninitialized")
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wold-style-cast")

	# Disable warnings that produce more headaches than use.
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-unused-parameter")
endif()

add_subdirectory(deps)
cond_add_subdirectory(doc RETDEC_DOC)
add_subdirectory(scripts)
add_subdirectory(src)
add_subdirectory(support)
add_subdirectory(tests)

# Create config version file.
write_basic_package_version_file(
	"${CMAKE_CURRENT_BINARY_DIR}/retdec-config-version.cmake"
	VERSION ${PROJECT_VERSION}
	COMPATIBILITY ExactVersion
)

# Create main RetDec CMake config file.
configure_file(
	"${CMAKE_CURRENT_LIST_DIR}/retdec-config.cmake"
	"${CMAKE_CURRENT_BINARY_DIR}/retdec-config.cmake"
	@ONLY
)

# Install CMake files.
install(
	FILES
		"${CMAKE_CURRENT_BINARY_DIR}/retdec-config.cmake"
		"${CMAKE_CURRENT_BINARY_DIR}/retdec-config-version.cmake"
	DESTINATION
		"${RETDEC_INSTALL_CMAKE_DIR}"
)

# Install licenses, readme, changelog, etc.
install(
	FILES
		CHANGELOG.md
		LICENSE
		LICENSE-PELIB
		LICENSE-THIRD-PARTY
		README.md
	DESTINATION
		"${RETDEC_INSTALL_DATA_DIR}"
)

# Install commit id file.
file(WRITE
	"${CMAKE_CURRENT_BINARY_DIR}/BUILD-ID"
	"RetDec ${RETDEC_GIT_VERSION_TAG} built from commit ${RETDEC_GIT_COMMIT_HASH} on ${RETDEC_BUILD_DATE} (UTC).\n"
)
install(
	FILES
		"${CMAKE_CURRENT_BINARY_DIR}/BUILD-ID"
	DESTINATION
		"${RETDEC_INSTALL_DATA_DIR}"
)
