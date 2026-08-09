#include "module/global_placer/electrostatic_placer/config/NesterovPlaceConfig.hh"

#include <cstdlib>
#include <iostream>
#include <limits>
#include <string>

namespace {

auto require(bool condition, const char* message) -> bool
{
  if (!condition) {
    std::cerr << "[FAIL] " << message << '\n';
  } else {
    std::cout << "[PASS] " << message << '\n';
  }
  return condition;
}

}  // namespace

int main()
{
  bool ok = true;

  ipl::NesterovPlaceConfig cfg;
  std::string reason;
  ok &= require(cfg.validate(&reason), "default NesterovPlaceConfig must validate");
  ok &= require(reason.empty(), "valid config must not leave an error reason");
  ok &= require(cfg.get_thread_num() == 1 && cfg.get_info_iter_num() == 10 && cfg.get_max_iter() == 250
                    && cfg.get_max_back_track() == 10,
                "default iteration controls must match the reviewed snapshot");
  ok &= require(cfg.get_target_density() == 0.7F && cfg.get_target_overflow() == 0.1F
                    && cfg.get_bin_cnt_x() == 16 && cfg.get_bin_cnt_y() == 16,
                "default density controls must match the reviewed snapshot");
  ok &= require(!cfg.isOptMaxWirelength() && !cfg.isOptTiming() && !cfg.isOptCongestion(),
                "experimental GP optimization strategies must remain disabled by default");

  cfg.set_thread_num(0);
  ok &= require(!cfg.validate(&reason) && reason == "thread_num must be positive", "invalid thread count must fail validation");

  cfg.set_thread_num(1);
  cfg.set_target_density(1.0f);
  ok &= require(!cfg.validate(&reason) && reason == "target_density must be in (0,1)", "invalid target density must fail validation");

  cfg.set_target_density(0.7f);
  cfg.set_min_phi_coef(0.95f);
  cfg.set_max_phi_coef(0.9f);
  ok &= require(!cfg.validate(&reason) && reason == "phi coefficients must satisfy 0 < min_phi_coef <= max_phi_coef",
                "invalid phi coefficient order must fail validation");

  cfg.set_max_phi_coef(1.05f);
  ok &= require(cfg.validate(&reason), "legacy phi coefficients above one remain valid");

  cfg.set_initial_prev_coordi_update_coef(100.0f);
  ok &= require(cfg.validate(&reason), "legacy initial coordinate coefficient remains valid");

  cfg.set_min_wirelength_force_bar(-300.0f);
  ok &= require(cfg.validate(&reason), "negative wirelength force barrier remains valid");

  cfg.set_min_wirelength_force_bar(std::numeric_limits<float>::quiet_NaN());
  ok &= require(!cfg.validate(&reason) && reason == "min_wirelength_force_bar must be finite",
                "non-finite wirelength force barrier must fail validation");

  return ok ? EXIT_SUCCESS : EXIT_FAILURE;
}
