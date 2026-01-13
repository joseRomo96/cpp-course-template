\addtogroup ExampleLesson_02_RepositoryStructure
## 2.0 Why the Repository Is Organized This Way

A typical C++ project contains:

- **Headers** (`*.hpp`, `*.h`)  
- **Source files** (`*.cpp`)  
- **Tests**  
- **Examples / drivers**  
- **Documentation**  
- **Build scripts**  

The template organizes these into **strictly separated trees**:

```
course/    ← instructor-only
student/   ← student-only
docs/      ← documentation
cmake/     ← helper modules
.github/   ← CI pipelines
```

This separation ensures:

- students cannot accidentally modify instructor code  
- instructors can safely update course materials throughout the semester  
- tests can link against *both* student and instructor libraries  
- build rules remain consistent and reproducible  

This mirrors how large-scale engineering teams structure multi-module C++ systems.
