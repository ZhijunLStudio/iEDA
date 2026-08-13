INCLUDE_DIRECTORIES(SYSTEM ${HOME_THIRDPARTY}/json)

if(BUILD_TESTING)
  add_executable(json_parser_safety_test test/JsonParserSafetyTest.cc)
  target_include_directories(json_parser_safety_test PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${HOME_UTILITY}/string
  )
  target_link_libraries(json_parser_safety_test PRIVATE str ZLIB::ZLIB)
  add_test(NAME json_parser_safety_test COMMAND $<TARGET_FILE:json_parser_safety_test>)
endif()
