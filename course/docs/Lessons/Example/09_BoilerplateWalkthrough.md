\addtogroup ExampleLesson_09_Boilerplate
## 9.0 Boilerplate Code Walkthrough

### 9.1 Instructor Boilerplate Code (`CourseLib`)

#### Public header — `course/include/LectureExample_publicAPI.hpp`

```
#ifndef LECTURE_EXAMPLE_PUBLIC_API_HPP
#define LECTURE_EXAMPLE_PUBLIC_API_HPP

namespace LectureLib {

void MyPublicAPI();

} // namespace LectureLib

#endif
```

#### Implementation — `course/src/LectureExample_privateAPI.cpp`

```
#include "LectureExample_publicAPI.hpp"
#include <iostream>

namespace LectureLib {

void MyPublicAPI() {
    std::cout << "[Lecture] Public API called\n";
}

void MyPrivateAPI() {
    std::cout << "[Lecture] Private API called\n";
}

} // namespace LectureLib
```

#### Example — `course/examples/LectureExample_target.cpp`

```
#include <LectureExample_publicAPI.hpp>
#include <iostream>

int main() {
    std::cout << "[Example] Calling instructor public API...\n";
    LectureLib::MyPublicAPI();
    return 0;
}
```

**Running the example produces:**

```
[Example] Calling instructor public API...
[Lecture] Public API called
```

Because:

1. The example prints a header message  
2. It calls `LectureLib::MyPublicAPI()`  
3. That function prints its own message  
4. This validates correct linking between example → library → implementation  


---

### 9.2 Student Boilerplate Code (`StudentLib`)

#### Public header — `student/include/StudentExample_publicAPI.hpp`

```
#ifndef STUDENT_EXAMPLE_PUBLIC_API_HPP
#define STUDENT_EXAMPLE_PUBLIC_API_HPP

namespace StudentLib {

void MyPublicAPI();

} // namespace StudentLib

#endif
```

#### Implementation — `student/src/StudentExample_privateAPI.cpp`

```
#include "StudentExample_publicAPI.hpp"
#include <iostream>

namespace StudentLib {

void MyPublicAPI() {
    std::cout << "[Student] Public API called\n";
}

void MyPrivateAPI() {
    std::cout << "[Student] Private API called\n";
}

} // namespace StudentLib
```

#### Example — `student/examples/StudentExample_target.cpp`

```
#include <StudentExample_publicAPI.hpp>
#include <iostream>

int main() {
    std::cout << "[Example] Calling student public API...\n";
    StudentLib::MyPublicAPI();
    return 0;
}
```

**Output:**

```
[Example] Calling student public API...
[Student] Public API called
```

**This confirms:**

- correct linking  
- correct include paths  
- correct namespace usage  
- the student library is functional  

---

### 9.3 How Instructor Tests Validate Student Code

Example test:

```
#include <StudentExample_publicAPI.hpp>
#include <cassert>

int main() {
    StudentLib::MyPublicAPI();
    assert(1 == 1);
    return 0;
}
```

**Why instructor tests use student headers:**

- tests validate *student* public APIs  
- they must not depend on internal student files  
- linking ensures student implementations exist  

This is identical to how real-world library consumers depend strictly on public headers.

---
