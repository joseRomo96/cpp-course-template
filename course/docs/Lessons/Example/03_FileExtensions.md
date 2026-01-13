\addtogroup ExampleLesson_03_FileExtensions
## 3.0 Why File Extensions Are Chosen This Way

### 3.1 `.hpp` (Header Files)
Used for:

- public API declarations  
- class definitions  
- documentation blocks  

`hpp` is preferred over `.h` because it explicitly indicates C++ content.

### 3.2 `.cpp` (Implementation Files)
Used for:

- private/internal implementations  
- logic not exposed publicly  
- example drivers  
- unit test sources  

### 3.3 `.cc` (Unit Test Files)
Chosen to **distinguish tests** from regular `.cpp` sources.

This allows CMake to automatically discover tests:

```
course/tests/*.cc
student/tests/*.cc
```

### 3.4 `.dox` (Documentation Pages)
These are Markdown-style documentation pages consumed by Doxygen.
Using `.dox` avoids confusion with regular `*.md` files and supports:

- `@page`  
- `@ingroup`  
- `\addtogroup`  
