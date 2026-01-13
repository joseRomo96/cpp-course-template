\addtogroup ExampleLesson_06_CMakeIntegration
## 6.0 How CMake Builds Everything

CMake creates:

### 6.1 `CourseLib`
Built from:

```
course/src/
course/include/
```

This is **read-only** for students.

### 6.2 `StudentLib`
Built from:

```
student/src/
student/include/
```

And links against `CourseLib`.

### 6.3 Automatic discovery
CMake automatically creates executables for:

```
course/examples/*_target.cpp
student/examples/*_target.cpp
course/tests/*_unitTests.cc
student/tests/*_unitTests.cc
```

No manual changes required.
Students simply add files in the correct locations.
