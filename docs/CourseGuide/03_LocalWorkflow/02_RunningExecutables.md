\defgroup CG_LocalWorkflow_02_RunningExecutables Running Executables
\ingroup CG_03_LocalWorkflow
# Running Executables Locally  
Part of the Local Workflow System

## Introduction

After configuring and building the project with CMake, several executables are produced:

- **Instructor examples** from `course/examples/`
- **Student examples** from `student/examples/`
- **Test binaries** (when unit testing is enabled)

This document explains how these executables are named, where they are located, and how to run them on Linux/macOS and Windows.

---

## 1. Naming Conventions for Example Executables

In the CMake configuration, example source files follow this convention:

- Any `*.cpp` file inside `course/examples/` becomes an **instructor example executable**
- Any `*.cpp` file inside `student/examples/` becomes a **student example executable**

Relevant CMake snippets:

```cmake
# --- course/examples ---
file(GLOB COURSE_EXAMPLES CONFIGURE_DEPENDS
    "${CMAKE_CURRENT_LIST_DIR}/course/examples/*.cpp"
)

foreach(ex_file IN LISTS COURSE_EXAMPLES)
    get_filename_component(ex_name "${ex_file}" NAME_WE)  # e.g. LectureExample_target

    add_executable(${ex_name} "${ex_file}")
    target_link_libraries(${ex_name}
        PRIVATE
            CourseLib
    )
endforeach()

# --- student/examples ---
file(GLOB STUDENT_EXAMPLES CONFIGURE_DEPENDS
    "${CMAKE_CURRENT_LIST_DIR}/student/examples/*.cpp"
)

foreach(ex_file IN LISTS STUDENT_EXAMPLES)
    get_filename_component(ex_name "${ex_file}" NAME_WE)  # e.g. StudentExample_target

    add_executable(${ex_name} "${ex_file}")
    target_link_libraries(${ex_name}
        PRIVATE
            StudentLib           # already links CourseLib
    )
endforeach()
```

This means:

- `course/examples/LectureExample_target.cpp` → executable named `LectureExample_target`
- `student/examples/MySolution_target.cpp`   → executable named `MySolution_target`

---

## 2. Where Are the Executables Generated?

By default, CMake generates all build artifacts (libraries, executables, and test binaries) inside the `build/` directory specified at configuration time.

If you ran:

```sh
cmake -S . -B build
cmake --build build --parallel
```

Then the executables will be found under `build/`.  
Exact structure may vary by generator and platform, but a common layout on Makefile/Ninja generators is:

- `build/LectureExample_target`
- `build/StudentExample_target`
- `build/<test_name>` (for unit tests when testing is enabled)

You can quickly inspect the list of generated targets using:

```sh
cmake --build build --target help
```

This shows all buildable targets, including example and test executables.

---

## 3. Running Executables on Linux/macOS

### Option A: From the `build/` directory

```sh
cd build
./LectureExample_target
./StudentExample_target
```

### Option B: From the repository root

```sh
./build/LectureExample_target
./build/StudentExample_target
```

If an executable requires command-line arguments:

```sh
./build/MySolution_target arg1 arg2
```

---

## 4. Running Executables on Windows (PowerShell / CMD)

On Windows, after building with CMake (e.g., using the `Ninja` or `Unix Makefiles` generator), you can run:

```ps1
cd build
.\LectureExample_target.exe
.\StudentExample_target.exe
```

Or from the repository root:

```ps1
.\build\LectureExample_target.exe
.\build\StudentExample_target.exe
```

If you generated a Visual Studio solution, you can also:

- Open the generated `.sln` file in the `build/` directory with Visual Studio
- Set the desired target (e.g., `LectureExample_target`) as the startup project
- Run it directly from the IDE (with debugger support)

---

## 5. Running Test Binaries (vs Example Executables)

Unit test executables are also created when `ENABLE_TESTING=ON`.  
Each test file under:

- `course/tests/*.cc`
- `student/tests/*.cc`

becomes a GoogleTest-based executable, registered in CTest.

Although you usually run them via:

```sh
ctest --test-dir build --output-on-failure
```

you can also run an individual test binary directly:

```sh
./build/LectureExample_unitTests
```

This can be useful when debugging a specific failing test.

---

## 6. Typical Local Workflow

A common workflow for working with examples and tests is:

1. **Configure the project**

   ```sh
   cmake -S . -B build \
     -DENABLE_TESTING=ON \
     -DCMAKE_BUILD_TYPE=Debug
   ```

2. **Build everything**

   ```sh
   cmake --build build --parallel
   ```

3. **Run an example executable**

   ```sh
   ./build/LectureExample_target
   # or any other example you are working on
   ```

4. **Run unit tests (optional)**

   ```sh
   ctest --test-dir build --output-on-failure
   ```

This way, you can rapidly iterate on your solution code in `student/`, recompile, and immediately test the behavior via your example executables and the unit tests.

---

## 7. Troubleshooting

- **“No such file or directory” when running an executable**

  - Make sure you have built the project:
    ```sh
    cmake --build build --parallel
    ```
  - Verify the executable name with:
    ```sh
    ls build
    cmake --build build --target help
    ```

- **Executable builds, but crashes immediately**

  - Run it under a debugger (e.g., `gdb`, `lldb`, or Visual Studio).
  - Add logging or print statements in your `*_target.cpp` to inspect arguments and state.

- **Changes in `course/examples/` or `student/examples/` not reflected**

  - Rebuild:
    ```sh
    cmake --build build --parallel
    ```
  - If you added *new* example files, CMake will pick them up thanks to `CONFIGURE_DEPENDS`, but you may need to rerun:
    ```sh
    cmake -S . -B build
    ```

---

With this setup, running executables is straightforward and consistent across platforms, allowing you to focus on implementing and testing C++ logic rather than dealing with build system details.
