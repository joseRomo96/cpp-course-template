#include "StudentExample_privateAPI.hpp"

// Include any additional headers you need here.
#include <iostream>

namespace StudentLib {

// Minimal implementation that compiles; students must complete it.
void MyPublicAPI() {
    std::cout << "[LectureExample_StudentExample] MyPublicAPI() called" << std::endl;

    // Internal logic delegated to the private API.
    MyPrivateAPI();
}

void MyPrivateAPI() {
    std::cout << "[LectureExample_StudentExample] MyPrivateAPI() called" << std::endl;
}

} // namespace StudentLib
