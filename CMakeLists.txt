cmake_minimum_required(VERSION 3.20)
project(cpp_course_template LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

option(ENABLE_TESTING  "Enable tests"         ON)
option(ENABLE_COVERAGE "Enable coverage flags" OFF)

# --------------------------------------------------
# Cobertura (opcional, para CI)
# --------------------------------------------------
if(ENABLE_COVERAGE)
    if(CMAKE_CXX_COMPILER_ID STREQUAL "AppleClang")
        message(STATUS "Building with coverage flags (AppleClang)")
        add_compile_options(-fprofile-arcs -ftest-coverage -O0 -g)
        link_libraries(-fprofile-arcs -ftest-coverage)
    elseif(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
        message(STATUS "Building with coverage flags (GNU/Clang)")
        add_compile_options(--coverage -O0 -g)
        link_libraries(--coverage)
    endif()
endif()



# --------------------------------------------------
# CourseLib  (código del profesor)
# --------------------------------------------------
file(GLOB_RECURSE COURSE_SRC CONFIGURE_DEPENDS
    "${CMAKE_CURRENT_LIST_DIR}/course/src/*.cpp"
)

add_library(CourseLib STATIC ${COURSE_SRC})

target_include_directories(CourseLib
    PUBLIC
        "${CMAKE_CURRENT_LIST_DIR}/course/include"
    PRIVATE
        "${CMAKE_CURRENT_LIST_DIR}/course/src"
)

# --------------------------------------------------
# StudentLib  (código del alumno)
#  - Depende de CourseLib para que el alumno pueda
#    usar la API del profesor sin tocar CMake.
# --------------------------------------------------
file(GLOB_RECURSE STUDENT_SRC CONFIGURE_DEPENDS
    "${CMAKE_CURRENT_LIST_DIR}/student/src/*.cpp"
)

add_library(StudentLib STATIC ${STUDENT_SRC})

target_include_directories(StudentLib
    PUBLIC
        "${CMAKE_CURRENT_LIST_DIR}/student/include"
    PRIVATE
        "${CMAKE_CURRENT_LIST_DIR}/student/src"
)

# StudentLib "incluye" CourseLib
target_link_libraries(StudentLib
    PUBLIC
        CourseLib
)

# --------------------------------------------------
# Examples (course + student)
#   Convención:
#     *_target.cpp  -> ejecutable
# --------------------------------------------------

# --- course/examples ---
file(GLOB COURSE_EXAMPLES CONFIGURE_DEPENDS
    "${CMAKE_CURRENT_LIST_DIR}/course/examples/*.cpp"
)

foreach(ex_file IN LISTS COURSE_EXAMPLES)
    get_filename_component(ex_name "${ex_file}" NAME_WE)  # p.ej. LectureExample_target

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
    get_filename_component(ex_name "${ex_file}" NAME_WE)  # p.ej. StudentExample_target

    add_executable(${ex_name} "${ex_file}")
    target_link_libraries(${ex_name}
        PRIVATE
            StudentLib           # ya arrastra CourseLib
    )
endforeach()

# --------------------------------------------------
# Tests (course + student)
#   Convención:
#     *_unitTests.cc -> ejecutable + ctest
# --------------------------------------------------
if(ENABLE_TESTING)
    include(CTest)
    enable_testing()

    include(FetchContent)

    FetchContent_Declare(
        googletest
        URL https://github.com/google/googletest/archive/refs/tags/v1.15.2.zip
    )

    # Evitamos que GoogleTest active tests internos
    set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)

    FetchContent_MakeAvailable(googletest)
    include(GoogleTest)

    # --- course/tests ---
    file(GLOB COURSE_TESTS CONFIGURE_DEPENDS
        "${CMAKE_CURRENT_LIST_DIR}/course/tests/*.cc"
    )

    foreach(test_file IN LISTS COURSE_TESTS)
        get_filename_component(test_name "${test_file}" NAME_WE) # LectureExample_unitTests

        add_executable(${test_name} "${test_file}")
        target_link_libraries(${test_name}
            PRIVATE
                StudentLib           # <- StudentLib, para poder testear código del alumno + CourseLib
                GTest::gtest
                GTest::gtest_main
        )

        add_test(
            NAME    ${test_name}
            COMMAND ${test_name}
        )
    endforeach()

    # --- student/tests ---
    file(GLOB STUDENT_TESTS CONFIGURE_DEPENDS
        "${CMAKE_CURRENT_LIST_DIR}/student/tests/*.cc"
    )

    foreach(test_file IN LISTS STUDENT_TESTS)
        get_filename_component(test_name "${test_file}" NAME_WE) # StudentExample_unitTests

        add_executable(${test_name} "${test_file}")
        target_link_libraries(${test_name}
            PRIVATE
                StudentLib    # ya arrastra CourseLib
                GTest::gtest
                GTest::gtest_main
        )

        add_test(
            NAME    ${test_name}
            COMMAND ${test_name}
        )
    endforeach()
endif()
