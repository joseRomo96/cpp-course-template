\addtogroup ExampleLesson_05_ExamplesVsUnitTests
## 5.0 Example Targets vs. Unit Tests

### 5.1 Example Executables (`*_target.cpp`)

Purpose:

- allow students to manually run simple programs  
- demonstrate usage of APIs  
- serve as debug entry points  

CMake finds them via:

```
course/examples/*.cpp
student/examples/*.cpp
```

### 5.2 Unit Tests (`*_unitTests.cc`)

Purpose:

- validate correctness  
- enforce requirements  
- run automatically through CTest  
- support auto-grading (CI)  

Instructor tests often include student public headers:

```cpp
#include <StudentExample_publicAPI.hpp>
```

And link against:

```
StudentLib  →  CourseLib
```

This ensures instructor evaluation is performed on student code.
