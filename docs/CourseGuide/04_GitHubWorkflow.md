\addtogroup CG_04_GitHubWorkflow

This page explains how GitHub Actions, CI testing, and documentation publishing
work in the C++ Course Template. It includes setup steps for both **students**
and **instructors**, since **each fork** of the template can publish its own
GitHub Pages documentation site.

---

# 1.0 Purpose of the GitHub Workflow

The repository contains CI workflows under:

```
.github/workflows/
```

These workflows ensure that:

- the project **builds correctly**  
- unit tests **run automatically**  
- documentation is **generated with Doxygen**  
- GitHub Pages **publishes documentation sites**  

Both instructors and students use this system:

- **Students** publish a documentation site showing their progress  
- **Instructors** publish the official course documentation  

---

# 2.0 Initial Setup — Students **and** Instructors

GitHub Pages **cannot be enabled on an empty repository**.

A repository must contain at least one commit before the Pages settings appear.
Forks already contain commits, so students normally skip the initialization.

---

## 2.1 Initial Commit (Only for Manual Repositories)

If you created the repository manually:

```bash
git init
git add .
git commit -m "Initial commit: C++ Course Template"
git branch -M main
git remote add origin https://github.com/<username>/<course_name>.git
git push -u origin main
```

After this first push, GitHub Pages becomes available.

*Students who fork the instructor repo do not need this step.*

---

# 2.2 Enabling GitHub Pages (Students & Instructors)

To publish documentation automatically:

1. Navigate to the repository on GitHub  
2. Go to:  
   **Settings → Pages**  
3. Under **Build and Deployment**, set:  
   - **Source:** `GitHub Actions`  
4. Save.

Once enabled, GitHub will use the workflow provided in:

```
.github/workflows/docs.yml
```

This workflow:

- builds the documentation using Doxygen  
- uploads it as a Pages artifact  
- deploys it automatically  

---

# 2.3 GitHub Pages URLs

### Student fork documentation:

```
https://<your-username>.github.io/<course_name>/
```

### Instructor documentation:

```
https://<instructor-username>.github.io/<course_name>/
```

Each student can publish their **own version** of the documentation, which
updates automatically when they push commits.

---

# 2.4 Why Students Should Enable GitHub Pages

Publishing documentation helps students:

- track progress visually  
- review and understand their public APIs  
- verify documentation builds correctly  
- create a **professional portfolio site**  
- learn standard industry workflows  

This mirrors real software engineering environments where each developer
generates and publishes internal docs.

---

# 3.0 Understanding the CI Workflows

The repository provides two major workflow files.

---

## 3.1 `ci.yml` — Main CI Pipeline

This workflow:

- configures CMake  
- builds the project  
- runs all CTest unit tests  
- fails if any part of the project is incorrect  
- may generate coverage reports (if enabled)

This ensures:

- students cannot submit non‑compiling code  
- instructors receive consistent evaluation  
- PRs are validated automatically  

---

## 3.2 `docs.yml` — Documentation Deployment

This workflow:

1. builds documentation using Doxygen  
2. uploads it as a GitHub Pages artifact  
3. deploys the documentation site  

Once deployed, GitHub Pages will automatically update the site whenever the
workflow runs again on new commits.

---

# 4.0 Student Workflow

Students typically:

1. fork the instructor template  
2. clone their fork locally  
3. enable GitHub Pages for their fork  
4. push updates as they complete lessons  
5. verify:

   - CI build status  
   - unit test results  
   - documentation Pages site  

This gives immediate feedback and real-world experience with CI/CD pipelines.

---

# 5.0 Instructor Workflow

Instructors typically:

- maintain the `course/` directory  
- publish the official documentation site  
- manage GitHub Classroom or upstream updates  
- review student repositories or submissions  
- tag versions (e.g., `v1.0`, `2025A`)  

Students receive instructor updates by running:

```bash
git fetch upstream
git merge upstream/main
git push origin main
```

This preserves student progress while bringing in new lessons or fixes.

---

# 6.0 Summary

GitHub Workflow integration provides:

- automated builds  
- automated tests  
- automated documentation  
- live GitHub Pages sites  
- consistent evaluation  
- professional development workflow experience  

It is an essential part of the course template and mirrors modern software
engineering practices.

