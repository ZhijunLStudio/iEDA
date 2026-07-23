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
 * @file IRSolver.cc
 * @author shaozheqing (707005020@qq.com)
 * @brief
 * @version 0.1
 * @date 2023-08-18
 *
 * @copyright Copyright (c) 2023
 *
 */

#include "IRSolver.hh"

#include <Spectra/MatOp/SparseSymMatProd.h>
#include <Spectra/SymEigsSolver.h>

#include <Eigen/IterativeLinearSolvers>
#include <algorithm>
#include <cmath>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <limits>

#include "log/Log.hh"
#if CUDA_IR_SOLVER
#include "ir-solver-cuda/ir_solver.cuh"
#endif

namespace iir {

/**
 * @brief print matrix data for debug.
 *
 * @param G_matrix
 * @param base_index
 */
void PrintMatrix(Eigen::Map<Eigen::SparseMatrix<double>>& G_matrix,
                 Eigen::Index base_index, Eigen::Index num_nodes) {
  LOG_INFO << "start write matrix, num nodes: " << num_nodes
           << ", base index: " << base_index;
  std::ofstream out("/home/taosimin/iEDA24/iEDA/bin/matrix_m9_m7.txt",
                    std::ios::trunc);
  for (Eigen::Index i = base_index; i < base_index + num_nodes; ++i) {
    for (Eigen::Index j = base_index; j < base_index + num_nodes; ++j) {
      // LOG_INFO << "matrix element at (" << i << ", " << j
      //          << "): " << G_matrix.coeff(i, j);
      out << std::fixed << std::setprecision(6) << G_matrix.coeff(i, j) << " ";
    }
    out << "\n";
  }

  out.close();

  LOG_INFO << "end write matrix";
}

/**
 * @brief print sparse matrix in CSR.
 *
 * @param G_matrix
 */
void PrintCSCMatrix(Eigen::Map<Eigen::SparseMatrix<double>>& G_matrix) {
  std::ofstream out("matrix_sparse.txt", std::ios::trunc);

  // Convert Eigen::Map to Eigen::SparseMatrix
  Eigen::SparseMatrix<double> sparse_matrix = G_matrix;

  // Ensure the matrix is in compressed format
  sparse_matrix.makeCompressed();

  // Iterate over the columns of the sparse matrix (CSC format)
  for (int col = 0; col < sparse_matrix.cols(); ++col) {
    for (Eigen::SparseMatrix<double>::InnerIterator it(sparse_matrix, col); it;
         ++it) {
      Eigen::Index row = it.row();  // Row index
      double value = it.value();    // Non-zero value

      out << "Col: " << col << ", Row: " << row << ", Value: " << std::fixed
          << std::setprecision(6) << value << "\n";
    }
  }

  out.close();
}

/**
 * @brief print vector data for debug.
 *
 * @param v_vector
 */
void PrintVector(const Eigen::VectorXd& v_vector, const std::string& filename) {
  std::ofstream out(filename, std::ios::trunc);
  for (Eigen::Index i = 0; i < v_vector.size(); ++i) {
    // LOG_INFO << "vector element at (" << i << "): " << v_vector(i);
    out << std::scientific << v_vector(i) << "\n";
  }
  out.close();
}

/**
 * @brief print vector to csv for debug.
 *
 * @param data
 * @param filename
 */
void writeVectorToCsv(Eigen::VectorXd& data, const std::string& filename) {
  std::ofstream ofs(filename, std::ios::trunc);
  if (!ofs.is_open()) {
    std::cerr << "Failed to open file: " << filename << std::endl;
    return;
  }
  ofs << "index,value\n";  // CSV header
  for (Eigen::Index i = 0; i < data.size(); ++i) {
    ofs << i << "," << data(i) << "\n";
  }
  ofs.close();
}

/**
 * @brief get the ir drop from voltage vector.
 *
 * @param v_vector
 * @return std::vector<double>
 */
std::vector<double> IRSolver::getIRDrop(Eigen::VectorXd& v_vector) {
  double voltage_max = v_vector.maxCoeff();
  auto node_num = v_vector.size();
  std::vector<double> ir_drops;
  ir_drops.reserve(node_num);
  for (unsigned i = 0; i < node_num; ++i) {
    double val = v_vector(i);
    // LOG_INFO << "node " << i << " voltage: " << val;
    ir_drops.push_back(voltage_max - val);
  }

  return ir_drops;
}

/**
 * @brief solver the ir drop use LU decomposition.
 *
 * @param G_matrix
 * @param J_vector
 * @return std::vector<double>
 */
std::vector<double> IRLUSolver::operator()(
    Eigen::Map<Eigen::SparseMatrix<double>>& G_matrix,
    Eigen::VectorXd& J_vector) {
  _report = {};
  if (G_matrix.rows() == 0 || G_matrix.rows() != G_matrix.cols() || J_vector.size() != G_matrix.rows()
      || !J_vector.array().isFinite().all()) {
    _report.status = IRSolveStatus::kInvalidInput;
    _report.reason = "LU requires a non-empty square matrix and a finite matching RHS";
    LOG_ERROR << _report.reason;
    return {};
  }
  Eigen::SparseMatrix<double> A =
      G_matrix;  // Copy G_matrix to A for preconditioning

  // PrintMatrix(G_matrix, 0, G_matrix.rows());

  Eigen::SimplicialLLT<Eigen::SparseMatrix<double>> solver;
  // use comute directorly, mask below code.
  // solver.analyzePattern(G_matrix);
  // solver.factorize(G_matrix);
  solver.compute(A);

  LOG_INFO << "G matrix size: " << G_matrix.rows() << " * " << G_matrix.cols();

  auto ret_value = solver.info();
  if (ret_value != Eigen::Success) {
    _report.status = IRSolveStatus::kFactorizationFailure;
    _report.reason = "LU factorization failed with Eigen status " + std::to_string(static_cast<int>(ret_value));
    LOG_ERROR << _report.reason;
    return {};
  }

  Eigen::VectorXd v_vector = solver.solve(J_vector);
  if (solver.info() != Eigen::Success || !v_vector.array().isFinite().all()) {
    _report.status = IRSolveStatus::kNumericalFailure;
    _report.reason = "LU solve produced an invalid voltage vector";
    LOG_ERROR << _report.reason;
    return {};
  }

  const Eigen::VectorXd residual = A * v_vector - J_vector;
  _report.absolute_residual = residual.norm();
  _report.relative_residual = _report.absolute_residual / std::max(J_vector.norm(), std::numeric_limits<double>::epsilon());
  _report.status = IRSolveStatus::kConverged;

  // for debug
  // PrintVector(v_vector, "/home/taosimin/iEDA24/iEDA/bin/voltage.txt");
  // writeVectorToCsv(J_vector, "/home/taosimin/iEDA24/iEDA/bin/current.csv");
  // writeVectorToCsv(v_vector, "/home/taosimin/iEDA24/iEDA/bin/voltage.csv");

  auto ir_drops = getIRDrop(v_vector);

  return ir_drops;
}

/**
 * @brief CPU solver the ir drop use CG gradient.
 *
 * @param A
 * @param b
 * @param x0
 * @param tol
 * @param max_iter
 * @param lambda
 * @return Eigen::VectorXd
 */
struct CGResult {
  Eigen::VectorXd solution;
  IRSolveReport report;
};

auto conjugateGradient(const Eigen::SparseMatrix<double>& matrix,
                       const Eigen::VectorXd& rhs,
                       const Eigen::VectorXd& initial,
                       double relative_tolerance,
                       double absolute_tolerance,
                       int max_iter,
                       double lambda) -> CGResult {
  CGResult result{initial, {}};
  if (matrix.rows() == 0 || matrix.rows() != matrix.cols() || rhs.size() != matrix.rows() || initial.size() != rhs.size()
      || max_iter <= 0 || relative_tolerance < 0.0 || absolute_tolerance < 0.0 || !rhs.array().isFinite().all()
      || !initial.array().isFinite().all()) {
    result.report.status = IRSolveStatus::kInvalidInput;
    result.report.reason = "CG received invalid dimensions, values, tolerance, or iteration budget";
    return result;
  }

  Eigen::VectorXd inverse_diagonal(matrix.rows());
  for (Eigen::Index index = 0; index < matrix.rows(); ++index) {
    const double diagonal = matrix.coeff(index, index) + lambda;
    if (!std::isfinite(diagonal) || diagonal <= 0.0) {
      result.report.status = IRSolveStatus::kInvalidInput;
      result.report.reason = "CG requires a finite positive matrix diagonal";
      return result;
    }
    inverse_diagonal(index) = 1.0 / diagonal;
  }

  Eigen::SparseMatrix<double> transpose = matrix.transpose();
  const Eigen::SparseMatrix<double> asymmetry = matrix - transpose;
  const double matrix_norm = matrix.norm();
  if (!std::isfinite(matrix_norm) || matrix_norm == 0.0
      || asymmetry.norm() / matrix_norm > 1e-10) {
    result.report.status = IRSolveStatus::kInvalidInput;
    result.report.reason = "CG requires a finite symmetric conductance matrix";
    return result;
  }

  auto apply_matrix = [&matrix, lambda](const Eigen::VectorXd& value) {
    return matrix * value + lambda * value;
  };
  const double rhs_norm = std::max(rhs.norm(), std::numeric_limits<double>::epsilon());
  Eigen::VectorXd residual = rhs - apply_matrix(result.solution);

  const auto update_residual_report = [&result, rhs_norm](const Eigen::VectorXd& value) {
    result.report.absolute_residual = value.norm();
    result.report.relative_residual = result.report.absolute_residual / rhs_norm;
  };
  const auto converged = [&result, relative_tolerance, absolute_tolerance] {
    return result.report.absolute_residual <= absolute_tolerance && result.report.relative_residual <= relative_tolerance;
  };

  update_residual_report(residual);
  if (converged()) {
    result.report.status = IRSolveStatus::kConverged;
    return result;
  }

  Eigen::VectorXd preconditioned = inverse_diagonal.cwiseProduct(residual);
  Eigen::VectorXd direction = preconditioned;
  double residual_dot_preconditioned = residual.dot(preconditioned);
  if (!std::isfinite(residual_dot_preconditioned) || residual_dot_preconditioned <= 0.0) {
    result.report.status = IRSolveStatus::kNumericalFailure;
    result.report.reason = "CG initial preconditioned residual is not positive";
    return result;
  }

  for (int iteration = 1; iteration <= max_iter; ++iteration) {
    const Eigen::VectorXd matrix_direction = apply_matrix(direction);
    const double direction_curvature = direction.dot(matrix_direction);
    if (!std::isfinite(direction_curvature) || direction_curvature <= 0.0) {
      result.report.status = IRSolveStatus::kNumericalFailure;
      result.report.iterations = iteration - 1;
      result.report.reason = "CG encountered non-positive or non-finite pAp";
      return result;
    }

    const double alpha = residual_dot_preconditioned / direction_curvature;
    if (!std::isfinite(alpha)) {
      result.report.status = IRSolveStatus::kNumericalFailure;
      result.report.iterations = iteration - 1;
      result.report.reason = "CG step length is non-finite";
      return result;
    }
    result.solution += alpha * direction;
    if (iteration % 50 == 0) {
      residual = rhs - apply_matrix(result.solution);
    } else {
      residual -= alpha * matrix_direction;
    }
    result.report.iterations = iteration;
    update_residual_report(residual);
    if (!result.solution.array().isFinite().all() || !std::isfinite(result.report.absolute_residual)) {
      result.report.status = IRSolveStatus::kNumericalFailure;
      result.report.reason = "CG produced NaN or Inf";
      return result;
    }
    if (converged()) {
      result.report.status = IRSolveStatus::kConverged;
      return result;
    }

    preconditioned = inverse_diagonal.cwiseProduct(residual);
    const double next_residual_dot_preconditioned = residual.dot(preconditioned);
    if (!std::isfinite(next_residual_dot_preconditioned) || next_residual_dot_preconditioned <= 0.0) {
      result.report.status = IRSolveStatus::kNumericalFailure;
      result.report.reason = "CG preconditioned residual lost positive definiteness";
      return result;
    }
    const double beta = next_residual_dot_preconditioned / residual_dot_preconditioned;
    direction = preconditioned + beta * direction;
    residual_dot_preconditioned = next_residual_dot_preconditioned;
  }

  result.report.status = IRSolveStatus::kMaxIterations;
  result.report.reason = "CG exhausted the iteration budget before both residual gates passed";
  return result;
}

/**
 * @brief Guess-Seidel solver the ir drop.
 *
 * @param A
 * @param b
 * @param x0
 * @param tol
 * @param max_iter
 * @return Eigen::VectorXd
 */
Eigen::VectorXd gaussSeidel(const Eigen::SparseMatrix<double>& A,
                            const Eigen::VectorXd& b, const Eigen::VectorXd& x0,
                            double tol, int max_iter) {
  int n = A.rows();
  Eigen::VectorXd x = x0;
  Eigen::VectorXd x_prev(n);
  double residual;

  std::ofstream residual_file("gauss_seidel_residual.csv", std::ios::trunc);
  residual_file << "iteration,residual\n";

  for (int iter = 0; iter < max_iter; ++iter) {
    x_prev = x;

    // Gauss-Seidel iteration
    for (int i = 0; i < n; i++) {
      double sum = 0.0;
      for (Eigen::SparseMatrix<double>::InnerIterator it(A, i); it; ++it) {
        if (it.row() != i) {
          sum += it.value() * x(it.row());
        }
      }
      x(i) = (b(i) - sum) / A.coeff(i, i);

      // Apply constraints
      x(i) = std::max(x(i), x0(i) * 0.5);
    }

    // Calculate residual
    residual = (x - x_prev).norm() / x.norm();
    residual_file << iter + 1 << "," << residual << "\n";

    LOG_INFO_EVERY_N(100) << "Gauss-Seidel iteration " << iter + 1
                          << " residual: " << residual;

    if (residual < tol) {
      LOG_INFO << "Gauss-Seidel converged after " << iter + 1 << " iterations";
      break;
    }
  }

  residual_file.close();
  return x;
}

/**
 * @brief Calculate the condition number of matrix A.
 *
 * @param A
 * @return double
 */
double calculateConditionNumber(const Eigen::SparseMatrix<double>& A) {
  Eigen::MatrixXd denseA = A;
  using namespace Spectra;

  Eigen::MatrixXd M = denseA + denseA.transpose();

  // Construct matrix operation object using the wrapper class DenseSymMatProd
  DenseSymMatProd<double> op(M);

  // Construct eigen solver object, requesting the largest three eigenvalues
  SymEigsSolver<DenseSymMatProd<double>> eigs(op, 3, 6);

  // Initialize and compute
  eigs.init();
  // int nconv = eigs.compute(SortRule::LargestAlge);

  // Retrieve results
  Eigen::VectorXd evalues;
  if (eigs.info() == CompInfo::Successful) evalues = eigs.eigenvalues();

  LOG_INFO << "Largest eigenvalue: " << evalues.maxCoeff();
  LOG_INFO << "Smallest eigenvalue: " << evalues.minCoeff();

  return 0.0;
}

/**
 * @brief for debug, print top 10 elements of a vector.
 *
 * @param vec
 */
void PrintTopTenVectorElements(Eigen::VectorXd& vec) {
  // for debug
  // Get the top 10 elements of J_vector
  std::vector<std::pair<double, int>> indexed_values;
  for (int i = 0; i < vec.size(); ++i) {
    indexed_values.emplace_back(vec(i), i);
  }

  // Sort in descending order
  std::sort(indexed_values.begin(), indexed_values.end(),
            [](const std::pair<double, int>& a,
               const std::pair<double, int>& b) { return a.first < b.first; });

  // Print the top 10 elements
  LOG_INFO << "Top 10 elements in vec:";
  for (int i = 0; i < std::min(10, static_cast<int>(indexed_values.size()));
       ++i) {
    LOG_INFO << "Index: " << indexed_values[i].second
             << ", Value: " << indexed_values[i].first;
  }
}

/**
 * @brief solver the ir drop use CG gradient.
 *
 * @param G_matrix
 * @param J_vector
 * @return std::vector<double>
 */
std::vector<double> IRCGSolver::operator()(
    Eigen::Map<Eigen::SparseMatrix<double>>& G_matrix,
    Eigen::VectorXd& J_vector) {
  _report = {};
  // for debug
  // PrintVector(J_vector, "/home/taosimin/iEDA24/iEDA/bin/current.txt");
  // PrintMatrix(G_matrix, 0);
  // PrintCSCMatrix(G_matrix);

#if !CUDA_IR_SOLVER
  Eigen::SparseMatrix<double> A = G_matrix;

  // call the eigen CG solver
  // Eigen::ConjugateGradient<Eigen::SparseMatrix<double>,
  //                          Eigen::Lower | Eigen::Upper>
  //     cg;
  // cg.compute(A);
  // cg.setTolerance(_tolerance);
  // cg.setMaxIterations(_max_iteration);

  // cg.solve(J_vector);

  Eigen::VectorXd X0 = Eigen::VectorXd::Constant(J_vector.size(), _nominal_voltage);
  auto cg_result = conjugateGradient(A, J_vector, X0, _relative_tolerance, _absolute_tolerance, _max_iteration, _lambda);
  Eigen::VectorXd v_vector = std::move(cg_result.solution);
  _report = std::move(cg_result.report);
  if (!_report.converged()) {
    LOG_ERROR << "IR CG solver failed: " << _report.reason << ", iterations=" << _report.iterations
              << ", abs_residual=" << _report.absolute_residual << ", rel_residual=" << _report.relative_residual;
    return {};
  }

  // PrintVector(v_vector, "/home/taosimin/iEDA24/iEDA/bin/voltage.txt");

  LOG_INFO << "CPU solver X[0] result:" << v_vector(0) << std::endl;

#else
  Eigen::SparseMatrix<double> A = G_matrix;
  Eigen::VectorXd X0 =
      Eigen::VectorXd::Constant(J_vector.size(), _nominal_voltage);

  auto X = ir_cg_solver(A, J_vector, X0, _relative_tolerance, _max_iteration, _lambda);
  Eigen::VectorXd v_vector(X.size());
  for (decltype(X.size()) i = 0; i < X.size(); ++i) {
    v_vector(i) = X[i];
  }

  LOG_INFO << "GPU solver X[0] result:" << v_vector(0) << std::endl;
#endif

  Eigen::VectorXd residual = G_matrix * v_vector - J_vector;
  _report.absolute_residual = residual.norm();
  _report.relative_residual = _report.absolute_residual / std::max(J_vector.norm(), std::numeric_limits<double>::epsilon());
#if CUDA_IR_SOLVER
  _report.status = std::isfinite(_report.absolute_residual) && _report.absolute_residual <= _absolute_tolerance
                           && _report.relative_residual <= _relative_tolerance
                       ? IRSolveStatus::kConverged
                       : IRSolveStatus::kNumericalFailure;
  if (!_report.converged()) {
    _report.reason = "GPU IR solve did not satisfy residual gates";
    LOG_ERROR << _report.reason;
    return {};
  }
#endif
  LOG_INFO << "IR residual: abs=" << _report.absolute_residual << ", rel=" << _report.relative_residual
           << ", iterations=" << _report.iterations;

  auto ir_drops = getIRDrop(v_vector);

  return ir_drops;
}

}  // namespace iir
