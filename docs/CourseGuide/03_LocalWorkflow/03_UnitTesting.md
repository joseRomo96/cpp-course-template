\defgroup CG_LocalWorkflow_03_UnitTesting Unit Testing
\ingroup CG_03_LocalWorkflow
# Unit Testing System with CMake + CTest + GoogleTest

Comprehensive and Fully Explained Guide

This document explains **how CMake, GoogleTest, and CTest work
together** to create a robust, reproducible, and maintainable unit
testing infrastructure in the course project. The integration uses:

-   **FetchContent** to download a fixed, reproducible version of
    GoogleTest\
-   **Automatic GLOB discovery** for both instructor and student test
    files\
-   **CTest** to register and run all tests with a single command\
-   **One executable per test file**, enabling isolated debugging and
    clean test structure

This guide provides students with a transparent understanding of the
testing workflow used in modern C++ projects.

------------------------------------------------------------------------

## 1. Enabling the Test Block in CMake

```
if(ENABLE_TESTING)
endif()
```

To activate the testing system explicitly:

```
cmake -S . -B build -DENABLE_TESTING=ON
```

If omitted or set to `OFF`, the following will *not* occur:

-   GoogleTest will not be downloaded\
-   No test executables will be generated\
-   `ctest` will report zero tests

This allows the project to be built **without** the testing system when
desired.

------------------------------------------------------------------------

## 2. Activating CTest

```
include(CTest)
enable_testing()
```

### What this does:

-   `include(CTest)`\
    Imports CTest-related commands (like `add_test()`).

-   `enable_testing()`\
    Informs CMake that this project defines tests.

Without these lines, **CTest will not detect any tests**, even if
executables exist.

------------------------------------------------------------------------

## 3. Reproducible GoogleTest Download Using FetchContent

```
include(FetchContent)

FetchContent_Declare(
    googletest
    URL https://github.com/google/googletest/archive/refs/tags/v1.15.2.zip
)
```

### Why FetchContent?

-   Ensures every user downloads **the exact same version**\
-   Removes the need for system installations\
-   Ideal for CI/CD reproducibility and classroom consistency

------------------------------------------------------------------------

## 4. Disabling GoogleTest's Internal Tests

```
set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
```

This configuration:

-   Prevents GoogleTest from compiling its own internal tests\
-   Reduces overall compile time\
-   Avoids Windows runtime conflicts (MSVC CRT mismatch)

------------------------------------------------------------------------

## 5. Making GoogleTest Available

```
FetchContent_MakeAvailable(googletest)
include(GoogleTest)
```

This step:

-   Downloads and integrates GoogleTest\

-   Exposes the following CMake targets:

    -   `GTest::gtest`\
    -   `GTest::gtest_main`

-   Loads macros like `gtest_discover_tests()`

------------------------------------------------------------------------

## 6. Automatic Test Discovery for Instructor Tests (`course/tests/`)

### a) Discovering `.cc` test files

```
file(GLOB COURSE_TESTS CONFIGURE_DEPENDS
    "${CMAKE_CURRENT_LIST_DIR}/course/tests/*.cc"
)
```

-   Automatically finds all instructor test files\
-   `CONFIGURE_DEPENDS` allows adding new files without editing
    CMakeLists

Example detected file:

    course/tests/LectureExample_unitTests.cc

------------------------------------------------------------------------

### b) Generating a test executable name

```
get_filename_component(test_name "${test_file}" NAME_WE)
```

Example:

    LectureExample_unitTests.cc → LectureExample_unitTests

------------------------------------------------------------------------

### c) Creating the executable

```
add_executable(${test_name} "${test_file}")
```

Each test file → one executable.

------------------------------------------------------------------------

### d) Linking required libraries

```
target_link_libraries(${test_name}
    PRIVATE
        CourseLib
        GTest::gtest
        GTest::gtest_main
)
```

-   `CourseLib` = instructor library\
-   GoogleTest provides the test runner

------------------------------------------------------------------------

### e) Registering the test in CTest

```
add_test(NAME ${test_name} COMMAND ${test_name})
```

CTest now recognizes the test.

------------------------------------------------------------------------

## 7. Automatic Test Discovery for Student Tests (`student/tests/`)

Test discovery mechanism is identical:

```
file(GLOB STUDENT_TESTS CONFIGURE_DEPENDS
    "${CMAKE_CURRENT_LIST_DIR}/student/tests/*.cc"
)
```

Each student test executable links to:

-   `StudentLib`\
-   `GTest::gtest`\
-   `GTest::gtest_main`

`StudentLib` **already depends on CourseLib**, so students get full API
access.

------------------------------------------------------------------------

## 8. Running All Tests

Any file in:

    course/tests/*.cc
    student/tests/*.cc

→ becomes a registered CTest test.

### Build with tests enabled:

```
cmake -S . -B build -DENABLE_TESTING=ON
cmake --build build
```

### Run tests:

```
ctest --output-on-failure --test-dir build
```

------------------------------------------------------------------------

## Summary Table

  -----------------------------------------------------------------------------
  Directory          Contains               Links Against     Auto-Registered
  ------------------ ---------------------- ----------------- -----------------
  `course/tests/`    Instructor tests       CourseLib         Yes

  `student/tests/`   Student tests          StudentLib        Yes

  Both               GoogleTest runner      gtest /           Yes
                                            gtest_main        
  -----------------------------------------------------------------------------

------------------------------------------------------------------------

## Basic GoogleTest Skeleton

``` cpp
#include <gtest/gtest.h>
#include <LectureExample_publicAPI.hpp>
#include "../src/LectureExample_privateAPI.hpp"

using namespace LectureLib;

class LectureExampleTest : public ::testing::Test {
protected:
  void SetUp() override {}
  void TearDown() override {}
};

TEST_F(LectureExampleTest, PublicAPIRuns) {
  EXPECT_NO_THROW(MyPublicAPI());
}

TEST_F(LectureExampleTest, PrivateAPIRuns) {
  EXPECT_NO_THROW(MyPrivateAPI());
}
```

------------------------------------------------------------------------

## Extending Tests as a Student

``` cpp
TEST(MyStudentExampleTest, HandlesEdgeCase) {
    // Prepare test data
    // Call the function
    EXPECT_EQ(result, expected);
}
```

Student tests:

-   Are discovered automatically\
-   Run through CTest\
-   Appear in coverage reports

------------------------------------------------------------------------
