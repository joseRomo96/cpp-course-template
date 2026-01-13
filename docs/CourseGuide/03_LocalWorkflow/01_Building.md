\defgroup CG_LocalWorkflow_01_Building Building
\ingroup CG_03_LocalWorkflow
# Building the Project Locally

Part of the Local Workflow Documentation

This document is part of the **local workflow** for the C++ course.
Here you will learn:

-   How to configure the project with CMake
-   How to compile libraries and examples
-   How to run unit tests
-   How to measure code coverage
-   How to generate documentation with Doxygen

Both **instructors** and **students** use the same infrastructure:

-   The instructor maintains `course/`
-   The student works inside `student/`

------------------------------------------------------------------------

## Project Structure Overview

The repository is organized as follows:

### **`course/`**

Reference code from the instructor (example implementations, tests,
utilities).
Students read this code but do not modify it.

### **`student/`**

The code students must complete.
All student solutions, their own tests, and their examples live here.

### **`cmake/`**

Helper CMake modules.

### **`docs/`**

Documentation written in Doxygen format (`.dox` or `.md`).

### **`scripts/`**

Automation scripts for testing, coverage, configuration, and
documentation.

### **`build/`**

Directory generated automatically by CMake during compilation.

------------------------------------------------------------------------

## Manual Compilation with CMake

To understand what happens internally, you can run the commands
manually.

From the repository root:

1) Create and configure the build directory
```
cmake -S . -B build \
  -DENABLE_TESTING=ON \
  -DCMAKE_BUILD_TYPE=Debug
```

2) Build everything (libraries and executables)
```
cmake --build build --parallel
```

This will build:

-   The instructor library: `CourseLib`
-   The student library: `StudentLib`
-   Instructor examples in `course/examples/`
-   Student examples in `student/examples/`

Executables appear inside `build/`, for example:

-   `build/LectureExample_target`
-   `build/StudentExample_target`

------------------------------------------------------------------------

## Compilation Using Scripts

The `scripts/` folder contains helper scripts to simplify the workflow.

On Linux/macOS, you can run:

```
./scripts/run_tests.sh
```

This script:

-   Cleans `build/`
-   Configures CMake with testing enabled
-   Compiles the project
-   Runs all unit tests

A simplified version:

```
#!/usr/bin/env bash
set -e

BUILD_DIR="build"

echo "▶ Cleaning previous build..."
rm -rf "${BUILD_DIR}"

echo "▶ Configuring CMake (tests)..."
cmake -S . -B "${BUILD_DIR}" \
  -DENABLE_TESTING=ON \
  -DCMAKE_BUILD_TYPE=Debug

echo "▶ Building project..."
cmake --build "${BUILD_DIR}" --parallel

echo "▶ Running unit tests..."
ctest --test-dir "${BUILD_DIR}" --output-on-failure

echo "✔ Tests finished."
```

The idea is to allow fast iteration without remembering every CMake
command,\
while still enabling you to inspect the scripts to understand what
happens *under the hood*.

------------------------------------------------------------------------

## Notes for Windows Users

On Windows, we recommend using **PowerShell** with `.ps1` scripts.\
An equivalent to `run_tests.sh` would be:

``` ps1
# scripts/run_tests.ps1
$ErrorActionPreference = "Stop"

$BUILD_DIR = "build"

Write-Host "▶ Cleaning previous build..."
if (Test-Path $BUILD_DIR) {
    Remove-Item -Recurse -Force $BUILD_DIR
}

Write-Host "▶ Configuring CMake (tests)..."
cmake -S . -B $BUILD_DIR `
  -DENABLE_TESTING=ON `
  -DCMAKE_BUILD_TYPE=Debug

Write-Host "▶ Building project..."
cmake --build $BUILD_DIR --parallel

Write-Host "▶ Running unit tests..."
ctest --test-dir $BUILD_DIR --output-on-failure

Write-Host "✔ Tests finished."
```

------------------------------------------------------------------------

For more details on interpreting test output or extending your own
tests,\
see the **Unit Testing** documentation page.
