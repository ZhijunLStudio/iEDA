#include "ILVSAPI.hpp"

namespace ilvs {

auto ILVSAPI::run(const LvsGraph& reference_graph, const LvsGraph& extracted_graph, const LvsManifest& manifest,
                  const LvsOptions& options) const -> LvsResult
{
  return runConnectivityLvs(reference_graph, extracted_graph, manifest, options);
}

auto ILVSAPI::runFromJsonFiles(const std::string& reference_graph_path, const std::string& extracted_graph_path,
                               const LvsManifest& manifest, const LvsOptions& options) const -> LvsResult
{
  LvsResult result;
  result.manifest = manifest;
  result.options = options;
  try {
    const LvsGraph reference_graph = loadGraphJsonFile(reference_graph_path, "reference");
    const LvsGraph extracted_graph = loadGraphJsonFile(extracted_graph_path, "layout");
    return runConnectivityLvs(reference_graph, extracted_graph, manifest, options);
  } catch (const std::exception& error) {
    result.state = LvsState::kError;
    result.exit_code = LvsExitCode::kInputError;
    result.diagnostics.push_back(error.what());
    return result;
  }
}

}  // namespace ilvs
