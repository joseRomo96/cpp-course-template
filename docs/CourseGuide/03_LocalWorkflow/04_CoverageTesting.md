\defgroup CG_LocalWorkflow_04_CoverageTesting Coverage Testing
\ingroup CG_03_LocalWorkflow
# Coverage Testing with CMake, GCOV, and LCOV

Part of the Local Workflow System

## Introduction

Code coverage answers a simple question:

> *"Which lines of my code are actually executed by the tests?"*

In this project, coverage is enabled optionally via CMake and is
intended mainly for:

-   Continuous Integration (CI)
-   Instructor feedback
-   Students who want to evaluate how well their tests exercise the code

The build system uses a CMake option:

```
option(ENABLE_COVERAGE "Enable coverage flags" OFF)
```

When `ENABLE_COVERAGE=ON`, extra compiler and linker flags are added so
tools like **gcov** and **lcov** can generate coverage reports.

------------------------------------------------------------------------

## 1. Coverage Flags in CMake

Relevant section from `CMakeLists.txt`:

```
if(ENABLE_COVERAGE)
    if(CMAKE_CXX_COMPILER_ID STREQUAL "AppleClang")
        message(STATUS "Building with coverage flags (AppleClang)")
        add_compile_options(-fprofile-arcs -ftest-coverage -O0 -g)
        link_libraries(-fprofile-arcs -ftest-coverage)
    elseif(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
        message(STATUS "Building with coverage flags (GNU/Clang)")
        add_compile_options(--coverage -O0 -g)
        link_libraries(--coverage)
    endif()
endif()
```

### What this does:

-   Checks if `ENABLE_COVERAGE` is `ON`
-   Detects the compiler family:
    -   `AppleClang` → uses `-fprofile-arcs -ftest-coverage`
    -   `GNU` or `Clang` → uses `--coverage`
-   Disables optimizations (`-O0`) and keeps debug info (`-g`) so
    coverage is accurate and debuggable.

> Important: Coverage builds should generally be **Debug** builds with
> **no optimizations**, otherwise some lines may be optimized away and
> appear as "not executed".

------------------------------------------------------------------------

## 2. Configuring a Coverage Build

From the repository root:

```
cmake -S . -B build \
  -DENABLE_TESTING=ON \
  -DENABLE_COVERAGE=ON \
  -DCMAKE_BUILD_TYPE=Debug
```

This configuration:

-   Enables unit tests (required, since coverage is computed by running
    tests)
-   Enables coverage flags
-   Uses Debug build type (no optimization, easy to interpret)

To rebuild:

```
cmake --build build --parallel
```

------------------------------------------------------------------------

## 3. Running Tests to Collect Coverage Data

Coverage data is only generated when binaries are executed.\
To run all tests:

```
ctest --test-dir build --output-on-failure
```

After this step, the compiler/linker will have produced coverage data
files (e.g., `.gcda`, `.gcno`) under the `build/` directory.

------------------------------------------------------------------------

## 4. Generating Coverage Reports (GCOV + LCOV)

A typical workflow on Linux/macOS is:

1.  Clean previous build and coverage files\
2.  Configure a coverage build (`ENABLE_COVERAGE=ON`)\
3.  Build everything\
4.  Run the tests (with `ctest`)\
5.  Use `lcov` to capture and filter coverage data\
6.  Use `genhtml` to generate an HTML report

An example shell script (`scripts/code_coverage.sh`) might look like:

```
#!/usr/bin/env bash
set -e

BUILD_DIR="build"
COVERAGE_DIR="site/coverage"

echo "▶ Cleaning previous build and coverage..."
rm -rf "${BUILD_DIR}" "${COVERAGE_DIR}"

echo "▶ Configuring CMake (coverage + tests)..."
cmake -S . -B "${BUILD_DIR}" \
  -DENABLE_TESTING=ON \
  -DENABLE_COVERAGE=ON \
  -DCMAKE_BUILD_TYPE=Debug

echo "▶ Building project..."
cmake --build "${BUILD_DIR}" --parallel

echo "▶ Running tests..."
ctest --test-dir "${BUILD_DIR}" --output-on-failure

echo "▶ Capturing coverage with lcov..."
mkdir -p "${COVERAGE_DIR}"
lcov --directory "${BUILD_DIR}" --capture --output-file "${COVERAGE_DIR}/coverage.info"

echo "▶ Filtering out system and external files..."
lcov --remove "${COVERAGE_DIR}/coverage.info" \
     "/usr/*" \
     "*/_deps/*" \
     --output-file "${COVERAGE_DIR}/coverage_filtered.info"

echo "▶ Generating HTML report with genhtml..."
genhtml "${COVERAGE_DIR}/coverage_filtered.info" \
        --output-directory "${COVERAGE_DIR}"

echo "✔ Coverage report generated at ${COVERAGE_DIR}/index.html"
```

> Note: The exact script name and paths may vary in your repository,\
> but the idea remains: **configure with coverage → build → run tests →
> lcov + genhtml.**

------------------------------------------------------------------------

## 5. Typical Output Layout

Assuming the script writes to `site/coverage`, you get:

-   `site/coverage/index.html` -- main coverage dashboard
-   Subdirectories with per-file and per-directory coverage reports

This can later be integrated into a global course site, alongside:

-   `site/docs/html` -- Doxygen documentation\
-   `site/tests` -- test reports

See the **Doxygen** and **Unit Testing** documentation pages for how to
wire everything together in a unified `site/index.html`.

------------------------------------------------------------------------

## 6. Usage Summary

1.  Configure for coverage:

    ```
    cmake -S . -B build \
      -DENABLE_TESTING=ON \
      -DENABLE_COVERAGE=ON \
      -DCMAKE_BUILD_TYPE=Debug
    ```

2.  Build:

    ```
    cmake --build build --parallel
    ```

3.  Run tests:

    ```
    ctest --test-dir build --output-on-failure
    ```

4.  Generate report (via script such as `scripts/code_coverage.sh`):

    ```
    ./scripts/code_coverage.sh
    ```

5.  Open the report in a browser:

    ``` text
    open site/coverage/index.html
    ```

With this workflow, both instructors and students can evaluate how
thoroughly their tests exercise the code base and iteratively improve
test suites.

------------------------------------------------------------------------
