// ***************************************************************************************
// Copyright (c) 2026 Peng Cheng Laboratory
//
// iEDA is licensed under Mulan PSL v2.
// ***************************************************************************************

#include <filesystem>
#include <fstream>
#include <iostream>
#include <string>

#include "json_parser.h"

namespace {

bool writeGzip(const std::filesystem::path& file_path, const std::string& content)
{
  gzFile file = gzopen(file_path.string().c_str(), "wb");
  if (file == nullptr) {
    return false;
  }

  const int bytes_written = gzwrite(file, content.data(), static_cast<unsigned int>(content.size()));
  const int close_status = gzclose(file);
  return bytes_written == static_cast<int>(content.size()) && close_status == Z_OK;
}

bool copyWithoutLastByte(const std::filesystem::path& source_path, const std::filesystem::path& destination_path)
{
  std::ifstream source(source_path, std::ios::binary);
  std::string compressed_content((std::istreambuf_iterator<char>(source)), std::istreambuf_iterator<char>());
  if (compressed_content.size() < 2) {
    return false;
  }
  compressed_content.pop_back();

  std::ofstream destination(destination_path, std::ios::binary);
  destination.write(compressed_content.data(), static_cast<std::streamsize>(compressed_content.size()));
  return destination.good();
}

int fail(const std::string& message)
{
  std::cerr << "JsonParserSafetyTest failure: " << message << std::endl;
  return 1;
}

}  // namespace

int main()
{
  const auto test_directory = std::filesystem::temp_directory_path() / "ieda_json_parser_safety_test";
  const auto gzip_path = test_directory / "valid.json.gz";
  const auto truncated_gzip_path = test_directory / "truncated.json.gz";
  const auto corrupt_gzip_path = test_directory / "corrupt.json.gz";
  const auto empty_gzip_path = test_directory / "empty.json.gz";
  const auto empty_content_gzip_path = test_directory / "empty_content.json.gz";
  const auto missing_gzip_path = test_directory / "missing.json.gz";
  const auto plain_json_path = test_directory / "plain.json";
  const auto invalid_plain_json_path = test_directory / "invalid_plain.json";

  std::error_code error;
  std::filesystem::create_directories(test_directory, error);
  if (error) {
    return fail("cannot create test directory");
  }

  const std::string json_text = R"({"config":{"width":42}})";
  if (!writeGzip(gzip_path, json_text)) {
    return fail("cannot write valid gzip input");
  }
  if (!writeGzip(empty_content_gzip_path, "")) {
    return fail("cannot write valid empty gzip input");
  }
  if (!copyWithoutLastByte(gzip_path, truncated_gzip_path)) {
    return fail("cannot create truncated gzip input");
  }
  {
    std::ofstream corrupt_gzip(corrupt_gzip_path, std::ios::binary);
    corrupt_gzip << "not a gzip stream";
  }
  {
    std::ofstream empty_gzip(empty_gzip_path, std::ios::binary);
  }

  if (ieda::get_gz_string(gzip_path.string()) != json_text) {
    return fail("valid gzip content was not read exactly");
  }
  if (!ieda::get_gz_string(truncated_gzip_path.string()).empty()) {
    return fail("truncated gzip content must be rejected");
  }
  if (!ieda::get_gz_string(corrupt_gzip_path.string()).empty()) {
    return fail("corrupt gzip content must be rejected");
  }
  if (!ieda::get_gz_string(empty_gzip_path.string()).empty()) {
    return fail("empty gzip content must be rejected");
  }
  if (!ieda::get_gz_string(empty_content_gzip_path.string()).empty()) {
    return fail("valid gzip with empty payload must be rejected");
  }
  if (!ieda::get_gz_string(missing_gzip_path.string()).empty()) {
    return fail("missing gzip input must be rejected");
  }

  auto gzip_stream = ieda::getGzFileStream(gzip_path.string());
  nlohmann::json parsed_json;
  gzip_stream >> parsed_json;
  if (ieda::getJsonData(parsed_json, {"config", "width"}, -1) != 42) {
    return fail("gzip stream did not parse JSON");
  }

  auto bad_gzip_stream = ieda::getGzFileStream(corrupt_gzip_path.string());
  if (bad_gzip_stream.good()) {
    return fail("corrupt gzip stream did not expose failure state");
  }

  nlohmann::json init_json;
  ieda::initJson(gzip_path.string(), init_json);
  if (ieda::getJsonData(init_json, {"config", "width"}, -1) != 42) {
    return fail("initJson did not parse valid gzip JSON");
  }
  init_json = nlohmann::json::object();
  ieda::initJson(corrupt_gzip_path.string(), init_json);
  if (!init_json.is_null()) {
    return fail("initJson did not reset JSON on corrupt gzip input");
  }

  if (ieda::getJsonData(parsed_json, {"config", "missing"}, "fallback") != "fallback") {
    return fail("missing JSON path did not return default");
  }
  if (ieda::getJsonData(parsed_json, {"config", "width", "nested"}, "fallback") != "fallback") {
    return fail("non-object JSON path did not return default");
  }

  {
    auto output_stream = ieda::getOutputFileStream(plain_json_path.string());
    output_stream << json_text;
  }
  auto input_stream = ieda::getInputFileStream(plain_json_path.string());
  nlohmann::json plain_json;
  input_stream >> plain_json;
  if (ieda::getJsonData(plain_json, {"config", "width"}, -1) != 42) {
    return fail("value-owned plain file stream did not parse JSON");
  }

  {
    std::ofstream invalid_plain_json(invalid_plain_json_path);
    invalid_plain_json << "{\"config\":";
  }
  init_json = nlohmann::json::object();
  ieda::initJson(invalid_plain_json_path.string(), init_json);
  if (!init_json.is_null()) {
    return fail("initJson did not reset JSON on invalid plain JSON input");
  }
  init_json = nlohmann::json::object();
  ieda::initJson((test_directory / "missing_plain.json").string(), init_json);
  if (!init_json.is_null()) {
    return fail("initJson did not reset JSON on missing plain JSON input");
  }

  std::filesystem::remove_all(test_directory, error);
  return 0;
}
