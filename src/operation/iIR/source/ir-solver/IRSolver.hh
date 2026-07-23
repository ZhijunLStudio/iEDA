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
/**
 * @file IRSolver.hh
 * @author shaozheqing (707005020@qq.com)
 * @brief The IR Solver to solve AX=b.
 * @version 0.1
 * @date 2023-08-18
 *
 * @copyright Copyright (c) 2023
 *
 */

#pragma once
#include <Eigen/Dense>
#include <Eigen/Sparse>
#include <Eigen/SparseLU>
#include <cstdint>
#include <map>
#include <string>

namespace iir {

enum class IRSolveStatus : uint8_t {
  kNotRun,
  kConverged,
  kInvalidInput,
  kNumericalFailure,
  kMaxIterations,
  kFactorizationFailure,
};

struct IRSolveReport {
  IRSolveStatus status = IRSolveStatus::kNotRun;
  int iterations = 0;
  double absolute_residual = 0.0;
  double relative_residual = 0.0;
  std::string reason;

  bool converged() const { return status == IRSolveStatus::kConverged; }
};

void PrintMatrix(Eigen::Map<Eigen::SparseMatrix<double>>& G_matrix,
                 Eigen::Index base_index);

/**
 * @brief The static IR solver to solve AX=b.
 *
 */
class IRSolver {
 public:
  IRSolver() = default;
  virtual ~IRSolver() = default;

  virtual std::vector<double> operator()(
      Eigen::Map<Eigen::SparseMatrix<double>>& G_matrix,
      Eigen::VectorXd& J_vector) = 0;

  std::vector<double> getIRDrop(Eigen::VectorXd& v_vector);
  const IRSolveReport& get_report() const { return _report; }

 protected:
  IRSolveReport _report;
};

/**
 * @brief The solver use LU decomposition to solve AX=b.
 *
 */
class IRLUSolver : public IRSolver {
 public:
  IRLUSolver() = default;
  ~IRLUSolver() override = default;

  std::vector<double> operator()(
      Eigen::Map<Eigen::SparseMatrix<double>>& G_matrix,
      Eigen::VectorXd& J_vector) override;
};

/**
 * @brief The solver use CG gradient to solver AX=b.
 *
 */
class IRCGSolver : public IRSolver {
 public:
  IRCGSolver(double nominal_voltage) : _nominal_voltage(nominal_voltage) {}
  ~IRCGSolver() override = default;
  std::vector<double> operator()(
      Eigen::Map<Eigen::SparseMatrix<double>>& G_matrix,
      Eigen::VectorXd& J_vector) override;

  void set_relative_tolerance(double tolerance) { _relative_tolerance = tolerance; }
  void set_absolute_tolerance(double tolerance) { _absolute_tolerance = tolerance; }
  void set_max_iteration(int max_iteration) { _max_iteration = max_iteration; }

 private:
  double _nominal_voltage;

  double _relative_tolerance = 1e-8;
  double _absolute_tolerance = 1e-10;
  int _max_iteration = 1000;

  double _lambda = 0;  //!< Regularization parameter.
};

}  // namespace iir
