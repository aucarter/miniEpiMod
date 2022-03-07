// Generated by TMBtools: do not edit by hand

#define TMB_LIB_INIT R_init_miniEpiMod_TMBExports
#include <TMB.hpp>
#include "miniEpiMod_tmb.hpp"

template<class Type>
Type objective_function<Type>::operator() () {
  DATA_STRING(model);
  if(model == "miniEpiMod_tmb") {
    return miniEpiMod_tmb(this);
  } else {
    Rf_error("Unknown model.");
  }
  return 0;
}
