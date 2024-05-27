macro(set_cache_variable VAR_NAME VAR_DESCRIPTION)
    set(${VAR_NAME} ${${VAR_NAME}} CACHE INTERNAL ${VAR_DESCRIPTION})
    message(STATUS "Set ${VAR_NAME} to ${${VAR_NAME}}.")
endmacro()


# Code coverage

if(BUILD_CPR_TESTS AND GENERATE_COVERAGE)
    set(CMAKE_BUILD_TYPE COVERAGE CACHE INTERNAL "Coverage enabled build")
    message(STATUS "Enabling gcov support")
    if(NOT "${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
        set(COVERAGE_FLAG "--coverage")
    endif()
    set(CMAKE_CXX_FLAGS_COVERAGE
        "-g -O0 ${COVERAGE_FLAG} -fprofile-arcs -ftest-coverage"
        CACHE STRING "Flags used by the C++ compiler during coverage builds."
        FORCE)
    set(CMAKE_C_FLAGS_COVERAGE
        "-g -O0 ${COVERAGE_FLAG} -fprofile-arcs -ftest-coverage"
        CACHE STRING "Flags used by the C compiler during coverage builds."
        FORCE)
    set(CMAKE_EXE_LINKER_FLAGS_COVERAGE
        ""
        CACHE STRING "Flags used for linking binaries during coverage builds."
        FORCE)
    set(CMAKE_SHARED_LINKER_FLAGS_COVERAGE
        ""
        CACHE STRING "Flags used by the shared libraries linker during coverage builds."
        FORCE)
    mark_as_advanced(
        CMAKE_CXX_FLAGS_COVERAGE
        CMAKE_C_FLAGS_COVERAGE
        CMAKE_EXE_LINKER_FLAGS_COVERAGE
        CMAKE_SHARED_LINKER_FLAGS_COVERAGE)
endif()


# Curl configuration

if(NOT HUNTER_ENABLED)
    if(USE_SYSTEM_CURL)
        find_package(CURL)
        add_library(CURL::libcurl UNKNOWN IMPORTED GLOBAL)
        set_target_properties(
            CURL::libcurl
            PROPERTIES
            INTERFACE_INCLUDE_DIRECTORIES "${CURL_INCLUDE_DIRS}"
            IMPORTED_LOCATION "${CURL_LIBRARIES}"
        )
    elseif(NOT CURL_FOUND)
        message(STATUS "Not using system Curl, using built-in curl project instead.")
        option(BUILD_TESTING "Set to ON to build cURL tests." OFF)
        option(BUILD_CURL_EXE "Set to ON to build cURL executable." OFF)
        add_subdirectory(curl)
        target_include_directories(libcurl INTERFACE ${CURL_SOURCE_DIR}/include)

        set_cache_variable(CURL_FOUND "Set if libcurl is found or built")
        add_library(CURL::libcurl ALIAS libcurl)
        
        # Group under the "external" project folder in IDEs such as Visual Studio.
        if(BUILD_CURL_EXE)
            set_property(TARGET curl PROPERTY FOLDER "external")
        endif()
        
        set_property(TARGET libcurl PROPERTY FOLDER "external")
    endif()

    # GTest configuration

    if(BUILD_CPR_TESTS)
        if(USE_SYSTEM_GTEST)
            find_package(GTest)

            add_library(GTest::gtest ALIAS GTest::GTest)
            add_library(GTest::main ALIAS GTest::Main)
        endif()
        if(NOT USE_SYSTEM_GTEST OR NOT GTEST_FOUND)
            message(STATUS "Not using system gtest, using built-in googletest project instead.")
            if(MSVC)
                # By default, GTest compiles on Windows in CRT static linkage mode. We use this
                # variable to force it into using the CRT in dynamic linkage (DLL), just as CPR
                # does.
                set(gtest_force_shared_crt ON CACHE BOOL "Force gtest to use the shared c runtime")
            endif()
            add_subdirectory(googletest)

            target_include_directories(gtest INTERFACE ${gtest_SOURCE_DIR}/include)
            target_compile_options(gtest PUBLIC $<$<BOOL:${MSVC}>:/wd4996>)

            set_cache_variable(GTEST_FOUND "Set if libgtest was found or built")
    
            # Group under the "tests/gtest" project folder in IDEs such as Visual Studio.
            set_property(TARGET gtest PROPERTY FOLDER "tests/gtest")
            set_property(TARGET gtest_main PROPERTY FOLDER "tests/gtest")
            
            add_library(GTest::gtest ALIAS gtest)
            add_library(GTest::main ALIAS gtest_main)
        endif()

    endif()


    # Mongoose configuration

    if(BUILD_CPR_TESTS)
        message(STATUS "Building mongoose project for test support.")
        add_subdirectory(mongoose)
        set(MONGOOSE_FOUND TRUE)
        
        target_include_directories(mongoose INTERFACE ${CMAKE_CURRENT_SOURCE_DIR})

        set_cache_variable(MONGOOSE_FOUND "Set if libmongoose was found or built")
    
        # Group under the "external" project folder in IDEs such as Visual Studio.
        set_property(TARGET mongoose PROPERTY FOLDER "external")

        add_library(mongoose::mongoose ALIAS mongoose)
    endif()
endif() # HUNTER_ENABLED
