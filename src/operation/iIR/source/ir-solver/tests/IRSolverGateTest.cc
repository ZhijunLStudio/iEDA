#include <Eigen/Sparse>

#include <cmath>
#include <iostream>
#include <stdexcept>
#include <vector>

#include "IRSolver.hh"

namespace {

auto mapMatrix(Eigen::SparseMatrix<double>& matrix) -> Eigen::Map<Eigen::SparseMatrix<double>>
{
  matrix.makeCompressed();
  return {matrix.rows(), matrix.cols(), matrix.nonZeros(), matrix.outerIndexPtr(), matrix.innerIndexPtr(), matrix.valuePtr()};
}

}  // namespace

int main()
{
  try {
    Eigen::SparseMatrix<double> matrix(2, 2);
    const std::vector<Eigen::Triplet<double>> matrix_entries = {{0, 0, 2.0}, {0, 1, -1.0}, {1, 0, -1.0}, {1, 1, 2.0}};
    matrix.setFromTriplets(matrix_entries.begin(), matrix_entries.end());
    auto mapped_matrix = mapMatrix(matrix);
    Eigen::VectorXd rhs(2);
    rhs << 1.0, 0.0;

    iir::IRCGSolver solver(1.0);
    solver.set_relative_tolerance(1e-10);
    solver.set_absolute_tolerance(1e-10);
    solver.set_max_iteration(20);
    const auto drops = solver(mapped_matrix, rhs);
    if (!solver.get_report().converged() || drops.size() != 2 || solver.get_report().relative_residual > 1e-10) {
      throw std::runtime_error("well-conditioned SPD system did not pass residual gates");
    }

    Eigen::SparseMatrix<double> invalid_matrix(2, 2);
    const std::vector<Eigen::Triplet<double>> invalid_entries = {{0, 1, 1.0}, {1, 0, 1.0}};
    invalid_matrix.setFromTriplets(invalid_entries.begin(), invalid_entries.end());
    auto mapped_invalid = mapMatrix(invalid_matrix);
    const auto invalid_drops = solver(mapped_invalid, rhs);
    if (!invalid_drops.empty() || solver.get_report().status != iir::IRSolveStatus::kInvalidInput) {
      throw std::runtime_error("zero-diagonal matrix was not rejected");
    }

    std::cout << "IR solver gate tests passed\n";
    return 0;
  } catch (const std::exception& error) {
    std::cerr << "IR solver gate test failure: " << error.what() << '\n';
    return 1;
  }
}
