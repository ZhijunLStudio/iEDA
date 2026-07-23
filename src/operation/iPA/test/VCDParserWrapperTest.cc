// ***************************************************************************************
// Copyright (c) 2023-2025 Peng Cheng Laboratory
// Copyright (c) 2023-2025 Institute of Computing Technology, Chinese Academy of
// Sciences Copyright (c) 2023-2025 Beijing Institute of Open Source Chip
//
// iEDA is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan
// PSL v2. You may obtain a copy of Mulan PSL v2 at:
// http://license.coscl.org.cn/MulanPSL2
//
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY
// KIND, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO
// NON-INFRINGEMENT, MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
//
// See the Mulan PSL v2 for more details.
// ***************************************************************************************
#include "gtest/gtest.h"
#include "log/Log.hh"
#include "ops/read_vcd/RustVCDParserWrapper.hh"

#include <filesystem>

using namespace ipower;
using namespace ieda;

namespace {

class VCDParserWrapperTest : public testing::Test {
 protected:
  static void SetUpTestSuite() {
    char config[] = "test";
    char* argv[] = {config};
    Log::init(argv);
  }
  static void TearDownTestSuite() { Log::end(); }
};

std::filesystem::path testVcd() {
  return (std::filesystem::path(__FILE__).parent_path() /
          "../../../database/manager/parser/vcd/vcd_parser/benchmark/test1.vcd")
      .lexically_normal();
}

TEST_F(VCDParserWrapperTest, rust_reader) {
  ipower::RustVcdParserWrapper vcd_reader;
  ASSERT_EQ(vcd_reader.readVcdFile(testVcd().c_str()), 1U);
  ASSERT_EQ(vcd_reader.buildAnnotateDB("top_i"), 1U);
  ASSERT_EQ(vcd_reader.calcScopeToggleAndSp("top_i"), 1U);
  vcd_reader.printAnnotateDB(std::cout);
}

TEST_F(VCDParserWrapperTest, hierarchical_scope) {
  ipower::RustVcdParserWrapper vcd_reader;
  ASSERT_EQ(vcd_reader.readVcdFile(testVcd().c_str()), 1U);
  ASSERT_EQ(vcd_reader.buildAnnotateDB("test/top_i/sub_i"), 1U);
  EXPECT_EQ(vcd_reader.calcScopeToggleAndSp("test/top_i/sub_i"), 1U);
}

TEST_F(VCDParserWrapperTest, missing_scope_is_recoverable) {
  ipower::RustVcdParserWrapper vcd_reader;
  ASSERT_EQ(vcd_reader.readVcdFile(testVcd().c_str()), 1U);
  EXPECT_EQ(vcd_reader.buildAnnotateDB("test/top_i/missing"), 0U);
}

}  // namespace
