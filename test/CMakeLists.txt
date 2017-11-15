find_package(Threads)
set(TEST_SERVER_LIBRARY test_server)
add_library(${TEST_SERVER_LIBRARY}
    server.cpp)
target_link_libraries(${TEST_SERVER_LIBRARY}
    mongoose::mongoose
    ${CMAKE_THREAD_LIBS_INIT}
    ${CPR_LIBRARIES}
    GTest::gtest)
    
macro(add_cpr_test _TEST_NAME)
    add_executable(${_TEST_NAME}_tests
        ${_TEST_NAME}_tests.cpp)
    if(MSVC)
      # bypass https://github.com/google/googletest/issues/1036
      target_compile_options(${_TEST_NAME}_tests PRIVATE /wd4996)
    endif()
    target_link_libraries(${_TEST_NAME}_tests
        ${TEST_SERVER_LIBRARY}
        GTest::gtest
        ${CPR_LIBRARIES})
    add_test(NAME cpr_${_TEST_NAME}_tests COMMAND ${_TEST_NAME}_tests)
    # Group under the "tests" project folder in IDEs such as Visual Studio.
    set_property(TARGET ${_TEST_NAME}_tests PROPERTY FOLDER "tests")
    if(WIN32)
        set(DLL_PATH $<TARGET_FILE_DIR:CURL::libcurl>)
        set_tests_properties(cpr_${_TEST_NAME}_tests PROPERTIES ENVIRONMENT "PATH=${DLL_PATH}")
    endif()
endmacro()

add_cpr_test(get)
add_cpr_test(post)
add_cpr_test(session)
add_cpr_test(async)
add_cpr_test(proxy)
add_cpr_test(head)
add_cpr_test(delete)
add_cpr_test(put)
add_cpr_test(callback)
add_cpr_test(raw_body)
add_cpr_test(options)
add_cpr_test(patch)
add_cpr_test(error)
add_cpr_test(alternating)
add_cpr_test(util)
