hunter_config(mongoose VERSION 5.6)
if(MSVC)
  # bypass https://github.com/google/googletest/issues/1036
  hunter_config(GTest VERSION ${HUNTER_GTest_VERSION} CMAKE_ARGS CMAKE_CXX_FLAGS=/wd4996)
endif()