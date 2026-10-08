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
#include "api/ActivityProvenance.hh"

#include "gtest/gtest.h"

namespace ipower {
namespace {

TEST(ActivityProvenanceTest, no_source_is_refused) {
  ActivityProvenance provenance;

  const ActivityReport report = provenance.report();
  EXPECT_EQ(report.source, ActivitySource::kNone);
  EXPECT_DOUBLE_EQ(report.coverage, 0.0);
  EXPECT_TRUE(report.refused);
  EXPECT_FALSE(provenance.hasActivitySelection());
}

TEST(ActivityProvenanceTest, vcd_reports_measured_coverage) {
  ActivityProvenance provenance;
  provenance.markVcdLoaded();
  provenance.updateCoverage(10, 4);

  const ActivityReport report = provenance.report();
  EXPECT_EQ(report.source, ActivitySource::kVcd);
  EXPECT_DOUBLE_EQ(report.coverage, 0.4);
  EXPECT_DOUBLE_EQ(report.measured_coverage, 0.4);
  EXPECT_EQ(report.annotated_vertices, 4U);
  EXPECT_EQ(report.defaulted_vertices, 0U);
  EXPECT_FALSE(report.refused);
  EXPECT_TRUE(report.reason.empty());
}

TEST(ActivityProvenanceTest, empty_vcd_coverage_is_refused) {
  ActivityProvenance provenance;
  provenance.markVcdLoaded();
  provenance.updateCoverage(10, 0);

  const ActivityReport report = provenance.report();
  EXPECT_EQ(report.source, ActivitySource::kVcd);
  EXPECT_DOUBLE_EQ(report.coverage, 0.0);
  EXPECT_TRUE(report.refused);
  EXPECT_FALSE(report.reason.empty());
}

TEST(ActivityProvenanceTest, vectorless_requires_explicit_selection) {
  ActivityProvenance provenance;
  provenance.updateCoverage(8, 0);
  EXPECT_TRUE(provenance.report().refused);

  provenance.selectVectorless();
  const ActivityReport report = provenance.report();
  EXPECT_EQ(report.source, ActivitySource::kVectorless);
  EXPECT_DOUBLE_EQ(report.coverage, 0.0);
  EXPECT_DOUBLE_EQ(report.measured_coverage, 0.0);
  EXPECT_DOUBLE_EQ(report.defaulted_coverage, 1.0);
  EXPECT_DOUBLE_EQ(report.effective_coverage, 1.0);
  EXPECT_EQ(report.defaulted_vertices, 8U);
  EXPECT_FALSE(report.refused);
  EXPECT_TRUE(report.reason.empty());
}

TEST(ActivityProvenanceTest, explicit_vectorless_can_cover_vcd_gaps) {
  ActivityProvenance provenance;
  provenance.markVcdLoaded();
  provenance.selectVectorless();
  provenance.updateCoverage(10, 4);

  const ActivityReport report = provenance.report();
  EXPECT_EQ(report.source, ActivitySource::kVcd);
  EXPECT_DOUBLE_EQ(report.coverage, 0.4);
  EXPECT_DOUBLE_EQ(report.defaulted_coverage, 0.6);
  EXPECT_DOUBLE_EQ(report.effective_coverage, 1.0);
  EXPECT_EQ(report.defaulted_vertices, 6U);
  EXPECT_TRUE(report.vectorless_enabled);
  EXPECT_FALSE(report.refused);
}

}  // namespace
}  // namespace ipower
