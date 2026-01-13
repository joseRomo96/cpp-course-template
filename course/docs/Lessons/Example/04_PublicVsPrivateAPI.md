\addtogroup ExampleLesson_04_PrivateVsPublic
## 4.0 Public vs Private APIs

Both instructor and student code follow the same pattern:

### Public API
Located in:

```
include/<Module>_publicAPI.hpp
```

This file:

- defines what the module exposes  
- is visible to *other* modules  
- contains documentation blocks  
- contains declarations, not implementations  

### Private Implementation
Located in:

```
src/<Module>_privateAPI.cpp
```

This file:

- contains the actual logic  
- is not publicly visible  
- can include private helper functions/classes  

This separation teaches students how real-world C++ libraries are architected.
