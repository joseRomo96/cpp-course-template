#include "LectureExample_privateAPI.hpp"

#include <iostream>

namespace LectureLib {

void MyPublicAPI() {
    std::cout << "[LectureExample] MyPublicAPI() called" << std::endl;

    // Internal logic delegated to the private API.
    MyPrivateAPI();
}

void MyPrivateAPI() {
    std::cout << "[LectureExample] MyPrivateAPI() internal work" << std::endl;
}

} // namespace LectureLib
