#include "ieco_via.h"

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
    const auto shape = ieco::parseECOViaRequest("shape");
    require(shape.status == ieco::ECOViaStatus::kSuccess, "shape request was rejected");
    require(shape.type == ieco::ECOViaType::kECOViaByShape, "shape request selected the wrong algorithm");

    const auto pattern = ieco::parseECOViaRequest("pattern");
    require(pattern.status == ieco::ECOViaStatus::kUnsupported, "unimplemented pattern request did not fail explicitly");
    require(pattern.type == ieco::ECOViaType::kECOViaByPattern, "pattern request lost its provenance");

    const auto unknown = ieco::parseECOViaRequest("typo");
    require(unknown.status == ieco::ECOViaStatus::kInvalidType, "unknown request silently selected an algorithm");
    require(unknown.type == ieco::ECOViaType::kECONone, "unknown request fell back to shape repair");

    require(ieco::ECOViaResult{ieco::ECOViaStatus::kSuccess, 0}.ok(), "zero repairs must remain a successful shape result");
    require(!ieco::ECOViaResult{ieco::ECOViaStatus::kUnsupported, 0}.ok(), "unsupported repair reported success");

    std::cout << "iECO via request tests passed\n";
    return 0;
  } catch (const std::exception& error) {
    std::cerr << error.what() << '\n';
    return 1;
  }
}
