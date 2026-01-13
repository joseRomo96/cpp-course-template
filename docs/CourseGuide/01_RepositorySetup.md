\addtogroup CG_01_RepositorySetup

This page explains how to fork, clone, and prepare the repository for
local development, including how to fetch updates from the instructor.

### 1.0 Creating Your Fork (Required for Students)

Students must **fork the instructor repository** so they can:

- commit freely in their own fork
- push their own work without affecting classmates
- submit pull requests if required
- receive instructor updates during the semester

**Step 1 — Open the instructor repository**

Visit:

```
https://github.com/<instructor>/<course_name>
```

Click **Fork** in the top-right corner and select your GitHub account.

**Step 2 — Clone your fork locally**

```bash
git clone https://github.com/<your-username>/<course_name>.git
cd <course_name>
```

**Step 3 — Add instructor repo as upstream**

```bash
git remote add upstream https://github.com/<instructor>/<course_name>.git
```

**Step 4 — Verify remotes**

```bash
git remote -v
```

Expected:

```
origin    https://github.com/<your-username>/<course_name>.git (fetch)
origin    https://github.com/<your-username>/<course_name>.git (push)
upstream  https://github.com/<instructor>/<course_name>.git (fetch)
upstream  https://github.com/<instructor>/<course_name>.git (push)
```

**Step 5 — Keeping fork updated**

```bash
git fetch upstream
git checkout main
git merge upstream/main
git push origin main
```

---

### 2.0 Required Toolchain

You need:

- CMake 3.20+
- C++17 compiler (GCC/Clang/MSVC)
- Git

Recommended:

- gcovr (coverage)
- lcov
- Doxygen + Graphviz

---

### 3.0 Verify Installation

```bash
cmake --version
g++ --version
git --version
```

---

### 4.0 First Local Configuration

```bash
cmake -B build -DCMAKE_BUILD_TYPE=Debug
```

---

### 5.0 First Build

```bash
cmake --build build --parallel
```

This compiles:

- CourseLib  
- StudentLib  
- instructor examples  
- student examples  
- instructor tests  
- student tests  

---

### 6.0 Instructor Notes (Optional)

Instructors may:

- update `course/` with lessons
- patch template issues
- tag releases

Students update via:

```bash
git fetch upstream
git merge upstream/main
```
