#include "CommandContract.hpp"

#include <filesystem>
#include <fstream>
#include <iostream>
#include <stdexcept>

namespace {

void require(bool condition, const char* message)
{
  if (!condition) {
    throw std::runtime_error(message);
  }
}

}  // namespace

int main()
{
  try {
    namespace contract = ieda::interface_contract;
    const std::filesystem::path product = std::filesystem::temp_directory_path() / "interface_command_contract_product.json";
    {
      std::ofstream output(product, std::ios::trunc);
      output << "{\"schema_version\":\"demo.v1\"}\n";
    }

    contract::CommandContract command;
    command.name = "report_demo";
    command.allowed_options = {"-output"};
    command.dependencies = {"db_loaded"};
    command.products = {{"report", product, "schema_version", "demo.v1"}};

    const auto ok = contract::evaluateCommandResult(command, true, {"-output"}, {"db_loaded"});
    require(ok.ok, "contract should pass with API/dependency/product/schema");
    require(ok.tclRc() == 1, "successful Tcl rc should be 1");
    require(contract::toJson(ok).find("\"schema_version\":\"ieda.interface.command_result.v1\"") != std::string::npos,
            "result JSON schema missing");

    const auto missing_dep = contract::evaluateCommandResult(command, true, {"-output"}, {});
    require(!missing_dep.ok, "missing dependency should fail");
    require(missing_dep.tclRc() == 0, "failed Tcl rc should be 0");

    const auto unknown = contract::evaluateCommandResult(command, true, {"-typo"}, {"db_loaded"});
    require(!unknown.ok, "unknown option should fail");
    require(unknown.reason.find("unknown option") != std::string::npos, "unknown option reason missing");

    command.compat_mode = true;
    const auto compat = contract::evaluateCommandResult(command, true, {"-typo"}, {"db_loaded"});
    require(compat.ok, "compat mode should be explicit opt-in");
    require(compat.compat_mode, "compat mode flag missing");

    std::filesystem::remove(product);
    std::cout << "interface command contract C++ tests passed\n";
    return 0;
  } catch (const std::exception& error) {
    std::cerr << error.what() << '\n';
    return 1;
  }
}
