\addtogroup CG_02_DirectoryStructure

This page describes the structure of the repository and the purpose of
each top-level directory.

### 1.0 Top-Level Layout

```
cpp-course-template/
├── course/        → Instructor reference code
├── student/       → Student implementation code
├── docs/          → Doxyfile + mainpage + CourseGuide
├── cmake/         → Internal CMake utilities
├── .github/       → CI/CD configuration
└── CMakeLists.txt → Root CMake configuration
```

---

### 2.0 Instructor Code (`course/`)

```
course/
├── include/       → Public instructor API headers
├── src/           → Internal instructor implementation (.cpp)
├── examples/      → Instructor example executables
├── tests/         → Instructor tests (auto-grading)
└── docs/          → Extra documentation for instructor modules
```

Students should **not** modify files under `course/`.

---

### 3.0 Student Code (`student/`)

```
student/
├── include/       → Public headers students expose
├── src/           → Student implementations (.cpp/.hpp)
├── examples/      → Example programs
├── tests/         → Student tests
└── docs/          → Optional student documentation
```

Only `student/` is writable by students.

---

### 4.0 Documentation (`docs/`)

```
docs/
├── Doxyfile       → Doxygen configuration
├── mainpage.dox   → Global documentation portal
└── CourseGuide/   → Course Guide .dox pages
```

The Course Guide is separated from the instructor/student code trees to keep 
the documentation clean and reusable.

---

### 5.0 Libraries and Targets

CMake defines:

- **CourseLib** — built from `course/src`, with public headers in `course/include`
- **StudentLib** — built from `student/src`, public headers in `student/include`,  
  and **links against CourseLib**

Examples and tests follow naming conventions:

- `course/examples/*.cpp` → course example executables  
- `student/examples/*.cpp` → student example executables  
- `course/tests/*.cc` → course test executables (automatically registered with CTest)
- `student/tests/*.cc` → student test executables (automatically registered with CTest)
