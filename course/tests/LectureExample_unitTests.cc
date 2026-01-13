#include <gtest/gtest.h>
#include <LectureExample_publicAPI.hpp>
// Note: normally you DO NOT test private APIs directly
#include "../src/LectureExample_privateAPI.hpp"

TEST(LectureExampleTest, PublicAPIRuns) {
    // If the function does not crash or throw, the test passes
    EXPECT_NO_FATAL_FAILURE(LectureLib::MyPublicAPI());
}

TEST(LectureExampleTest, PrivateAPIRuns) {
    EXPECT_NO_FATAL_FAILURE(LectureLib::MyPrivateAPI());
}

// GoogleTest main entry point
int main(int argc, char** argv) {
    ::testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}
