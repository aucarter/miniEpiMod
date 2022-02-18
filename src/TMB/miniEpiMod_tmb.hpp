#ifndef MINIEPIMOD_TMB_HPP
#define MINIEPIMOD_TMB_HPP

#undef TMB_OBJECTIVE_PTR
#define TMB_OBJECTIVE_PTR obj

#include "../simForward.h"

template<class Type>
  Type miniEpiMod_tmb(objective_function<Type>* obj)
{

  using Eigen::Matrix;

  DATA_INTEGER(N);
  DATA_VECTOR(data_mean);
  DATA_VECTOR(data_sd);
  DATA_IVECTOR(data_idx);

  Type nll(0.0);

  // Priors
  PARAMETER(log_foi);
  Type foi = exp(log_foi);
  nll -= dnorm(log(foi), Type(log(0.5)), Type(1.0), true);
  Sim<Type> sim(simForward<Type>(foi, N));

  // likelihood
  for(int i = 0; i < data_idx.size(); i++) {
    nll -= dnorm(data_mean(i),
                sim.x_out(1, data_idx[i] - 1),
                data_sd(i), true);
  }



  // REPORT(x_out);

  return Type(nll);
}

#undef TMB_OBJECTIVE_PTR
#define TMB_OBJECTIVE_PTR this

#endif
