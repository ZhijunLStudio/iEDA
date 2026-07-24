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
#include "api/Power.hh"

#include <filesystem>
#include <fstream>
#include <sstream>

#include "gtest/gtest.h"
#include "json/json.hpp"
#include "log/Log.hh"

namespace ipower {
namespace {

class PowerActivityReportTest : public testing::Test {
 protected:
  static void SetUpTestSuite() {
    char test_name[] = "PowerActivityReportTest";
    char* argv[] = {test_name};
    ieda::Log::init(argv);
    _power = Power::getOrCreatePower(nullptr);
  }

  static void TearDownTestSuite() {
    Power::destroyPower();
    _power = nullptr;
    ieda::Log::end();
  }

  static Power& power() { return *_power; }

 private:
  inline static Power* _power = nullptr;
};

TEST_F(PowerActivityReportTest, refused_json_has_no_numeric_power) {
  const auto report_path =
      std::filesystem::temp_directory_path() / "ipa_refused_power.json";
  std::filesystem::remove(report_path);

  EXPECT_EQ(power().reportSummaryPowerJSON(
                report_path.c_str(), PwrAnalysisMode::kAveraged),
            0U);

  std::ifstream report_stream(report_path);
  ASSERT_TRUE(report_stream.is_open());
  const nlohmann::json report = nlohmann::json::parse(report_stream);

  EXPECT_EQ(report.at("source"), "none");
  EXPECT_DOUBLE_EQ(report.at("coverage"), 0.0);
  EXPECT_TRUE(report.at("refused"));
  EXPECT_TRUE(report.at("total_power").is_null());
  EXPECT_TRUE(report.at("power_mw").at("value").is_null());
  EXPECT_TRUE(report.at("components_mw").is_null());

  const auto& activity = report.at("activity");
  EXPECT_EQ(activity.at("source"), "none");
  EXPECT_DOUBLE_EQ(activity.at("coverage"), 0.0);
  EXPECT_TRUE(activity.at("refused"));
  EXPECT_FALSE(activity.at("reason").get<std::string>().empty());

  std::filesystem::remove(report_path);
}

TEST_F(PowerActivityReportTest, refused_text_uses_na_not_power_value) {
  const auto report_path =
      std::filesystem::temp_directory_path() / "ipa_refused_power.txt";
  std::filesystem::remove(report_path);

  EXPECT_EQ(power().reportSummaryPower(
                report_path.c_str(), PwrAnalysisMode::kAveraged),
            0U);

  std::ifstream report_stream(report_path);
  ASSERT_TRUE(report_stream.is_open());
  std::ostringstream contents;
  contents << report_stream.rdbuf();

  EXPECT_NE(contents.str().find("source: none"), std::string::npos);
  EXPECT_NE(contents.str().find("coverage: 0.000000"),
            std::string::npos);
  EXPECT_NE(contents.str().find("refused: true"), std::string::npos);
  EXPECT_NE(contents.str().find("Total Power : N/A"), std::string::npos);

  std::filesystem::remove(report_path);
}

TEST_F(PowerActivityReportTest, refused_instance_reports_have_provenance) {
  const auto text_path =
      std::filesystem::temp_directory_path() / "ipa_refused_instance.txt";
  const auto csv_path =
      std::filesystem::temp_directory_path() / "ipa_refused_instance.csv";
  std::filesystem::remove(text_path);
  std::filesystem::remove(csv_path);

  EXPECT_EQ(power().reportInstancePower(
                text_path.c_str(), PwrAnalysisMode::kAveraged),
            0U);
  EXPECT_EQ(power().reportInstancePowerCSV(csv_path.c_str()), 0U);

  std::ifstream text_stream(text_path);
  std::ifstream csv_stream(csv_path);
  ASSERT_TRUE(text_stream.is_open());
  ASSERT_TRUE(csv_stream.is_open());
  std::ostringstream text_contents;
  std::ostringstream csv_contents;
  text_contents << text_stream.rdbuf();
  csv_contents << csv_stream.rdbuf();

  EXPECT_NE(text_contents.str().find("source: none"), std::string::npos);
  EXPECT_NE(text_contents.str().find("coverage: 0.000000"),
            std::string::npos);
  EXPECT_NE(text_contents.str().find("refused: true"),
            std::string::npos);
  EXPECT_NE(csv_contents.str().find("source,coverage,refused"),
            std::string::npos);
  EXPECT_NE(csv_contents.str().find("none,0,true"), std::string::npos);
  EXPECT_TRUE(power().getInstancePowerData().empty());
  EXPECT_TRUE(power().displayInstancePowerMap().empty());
  EXPECT_EQ(power().runIRAnalysis("VDD"), 0U);

  std::filesystem::remove(text_path);
  std::filesystem::remove(csv_path);
}

TEST_F(PowerActivityReportTest, successful_vcd_read_marks_vcd_source) {
  const auto vcd_path =
      (std::filesystem::path(__FILE__).parent_path() /
       "../../../database/manager/parser/vcd/vcd_parser/benchmark/test1.vcd")
          .lexically_normal();

  ASSERT_EQ(power().readRustVCD(vcd_path.c_str(), "top_i"), 1U);
  EXPECT_EQ(power().getActivityReport().source, ActivitySource::kVcd);
}

TEST_F(PowerActivityReportTest, vectorless_is_not_enabled_by_default) {
  PwrVertex vertex(nullptr);
  EXPECT_FALSE(power().isVectorlessActivityEnabled());
  EXPECT_FALSE(power().getVectorlessToggle().has_value());
  EXPECT_DOUBLE_EQ(vertex.getToggleData(std::nullopt), 0.0);
  EXPECT_FALSE(power().set_default_toggle(-0.01));
  EXPECT_FALSE(power().isVectorlessActivityEnabled());
  EXPECT_FALSE(power().getVectorlessToggle().has_value());
  EXPECT_DOUBLE_EQ(vertex.getToggleData(std::nullopt), 0.0);

  EXPECT_TRUE(power().set_default_toggle(0.02));
  EXPECT_TRUE(power().isVectorlessActivityEnabled());
  ASSERT_TRUE(power().getVectorlessToggle().has_value());
  EXPECT_DOUBLE_EQ(*power().getVectorlessToggle(), 0.02);
  EXPECT_DOUBLE_EQ(vertex.getToggleData(std::nullopt), 0.02);
}

}  // namespace
}  // namespace ipower
