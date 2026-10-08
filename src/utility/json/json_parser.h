// ***************************************************************************************
// Copyright (c) 2023-2025 Peng Cheng Laboratory
// Copyright (c) 2023-2025 Institute of Computing Technology, Chinese Academy of Sciences
// Copyright (c) 2023-2025 Beijing Institute of Open Source Chip
//
// iEDA is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
// http://license.coscl.org.cn/MulanPSL2
//
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
//
// See the Mulan PSL v2 for more details.
// ***************************************************************************************

#pragma once
#pragma GCC diagnostic ignored "-Wunused-function"
/**
 * @File Name: json_parser.h
 * @Brief :
 * @Author : Yell (12112088@qq.com)
 * @Version : 1.0
 * @Creat Date : 2022-04-15
 *
 */
#include <sys/resource.h>
#include <sys/time.h>
#include <time.h>
#include <unistd.h>

#include <array>
#include <cassert>
#include <cmath>
#include <ctime>
#include <exception>
#include <fstream>
#include <iostream>
#include <map>
#include <queue>
#include <set>
#include <sstream>
#include <string>
#include <utility>
#include <vector>

#include "../string/Str.hh"
#include "json.hpp"
#include "zlib.h"

namespace ieda {

static nlohmann::json getJsonData(const nlohmann::json& value, const std::vector<std::string>& flag_list,
                                  nlohmann::json default_value = "")
{
  if (flag_list.empty()) {
    std::cout << "[json error] : The flag list is empty!" << std::endl;
    return default_value;
  }

  const nlohmann::json* current_value = &value;
  for (const auto& flag : flag_list) {
    if (!current_value->is_object()) {
      return default_value;
    }

    const auto json_iter = current_value->find(flag);
    if (json_iter == current_value->end() || json_iter->is_null()) {
      return default_value;
    }
    current_value = &(*json_iter);
  }

  return *current_value;
}

template <typename T>
static T getFileStream(const std::string& file_path)
{
  T file(file_path);
  if (!file.is_open()) {
    std::cout << "[json error] : Failed to open file = " << file_path << std::endl;
  }
  return file;
}

static bool read_gz_string(const std::string& file_path, std::string& content)
{
  content.clear();

  std::ifstream file(file_path, std::ios::binary);
  if (!file.is_open()) {
    std::cout << "[json error] : Failed to open file = " << file_path << std::endl;
    return false;
  }

  z_stream stream{};
  if (inflateInit2(&stream, 16 + MAX_WBITS) != Z_OK) {
    std::cout << "[json error] : Failed to initialize gzip decompressor for file = " << file_path << std::endl;
    return false;
  }
  struct InflateEndGuard
  {
    z_stream& stream;
    ~InflateEndGuard() { inflateEnd(&stream); }
  } inflate_end_guard{stream};

  constexpr size_t k_buffer_size = 64 * 1024;
  std::array<unsigned char, k_buffer_size> input_buffer{};
  std::array<unsigned char, k_buffer_size> output_buffer{};

  while (true) {
    if (stream.avail_in == 0) {
      file.read(reinterpret_cast<char*>(input_buffer.data()), static_cast<std::streamsize>(input_buffer.size()));
      const std::streamsize bytes_read = file.gcount();
      if (bytes_read <= 0) {
        if (file.bad()) {
          std::cout << "[json error] : Failed to read gzip file = " << file_path << std::endl;
        } else {
          std::cout << "[json error] : Truncated gzip file = " << file_path << std::endl;
        }
        content.clear();
        return false;
      }
      stream.next_in = input_buffer.data();
      stream.avail_in = static_cast<uInt>(bytes_read);
    }

    stream.next_out = output_buffer.data();
    stream.avail_out = static_cast<uInt>(output_buffer.size());
    const int inflate_status = inflate(&stream, Z_NO_FLUSH);
    const size_t bytes_written = output_buffer.size() - stream.avail_out;
    if (bytes_written > 0) {
      if (content.size() > content.max_size() - bytes_written) {
        std::cout << "[json error] : Gzip content is too large = " << file_path << std::endl;
        content.clear();
        return false;
      }
      try {
        content.append(reinterpret_cast<const char*>(output_buffer.data()), bytes_written);
      } catch (const std::exception& e) {
        std::cout << "[json error] : Failed to store gzip content = " << file_path << ", reason = " << e.what() << std::endl;
        content.clear();
        return false;
      }
    }

    if (inflate_status == Z_STREAM_END) {
      if (content.empty()) {
        std::cout << "[json error] : Empty gzip content = " << file_path << std::endl;
        content.clear();
        return false;
      }
      return true;
    }
    if (inflate_status != Z_OK) {
      std::cout << "[json error] : Failed to read gzip file = " << file_path << ", zlib status = " << inflate_status << std::endl;
      content.clear();
      return false;
    }
  }
}

static std::string get_gz_string(const std::string& file_path)
{
  std::string content;
  if (!read_gz_string(file_path, content)) {
    return "";
  }
  return content;
}

static std::istringstream getGzFileStream(const std::string& file_path)
{
  std::istringstream data_stream;
  if (ieda::Str::contain(file_path.c_str(), ".gz")) {
    std::string content;
    if (!read_gz_string(file_path, content)) {
      data_stream.setstate(std::ios::badbit);
      return data_stream;
    }
    data_stream.str(std::move(content));
  }
  return data_stream;
}

static std::ifstream getInputFileStream(const std::string& file_path)
{
  return getFileStream<std::ifstream>(file_path);
}

static void initJson(const std::string& file_path, nlohmann::json& json)
{
  json = nullptr;

  try {
    if (ieda::Str::contain(file_path.c_str(), ".gz")) {
      auto file_stream = getGzFileStream(file_path);
      if (!file_stream.good()) {
        return;
      }
      file_stream >> json;
    } else {
      auto file_stream = getFileStream<std::ifstream>(file_path);
      if (!file_stream.is_open()) {
        return;
      }
      file_stream >> json;
    }
  } catch (const nlohmann::json::exception& e) {
    std::cout << "[json error] : Failed to parse JSON file = " << file_path << ", reason = " << e.what() << std::endl;
    json = nullptr;
  } catch (const std::exception& e) {
    std::cout << "[json error] : Failed to read JSON file = " << file_path << ", reason = " << e.what() << std::endl;
    json = nullptr;
  }
}

static std::ofstream getOutputFileStream(const std::string& file_path)
{
  return getFileStream<std::ofstream>(file_path);
}

template <typename T>
static void closeFileStream(T& t)
{
  t.close();
}

template <typename T, typename... Args>
static std::string splice(T value, Args... args)
{
  std::stringstream oss;
  pushStream(oss, value, args...);
  std::string string = oss.str();
  oss.clear();
  return string;
}

template <typename Stream, typename T, typename... Args>
static void pushStream(Stream& stream, T t, Args... args)
{
  stream << t;
  pushStream(stream, args...);
  return;
}

template <typename Stream, typename T>
static void pushStream(Stream& stream, T t)
{
  stream << t;
}

}  // namespace ieda
