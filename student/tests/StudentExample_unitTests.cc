#include <gtest/gtest.h>
#include <StudentExample_publicAPI.h>
// In this course, testing the private API is allowed for learning purposes.
#include "../src/StudentExample_privateAPI.hpp"

namespace StudentLib {

TEST(StudentExampleTest, PublicAPIRuns) {
    // If the function does not crash or throw, the test passes.
    EXPECT_NO_FATAL_FAILURE(MyPublicAPI());
}

TEST(StudentExampleTest, PrivateAPIRuns) {
    // Students may test private functionality to verify internal behavior.
    EXPECT_NO_FATAL_FAILURE(MyPrivateAPI());
}

} // namespace StudentLib

// GoogleTest main entry point
int main(int argc, char** argv) {
    ::testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}
