#ifndef MINIEPIMOD_TMB_HPP
#define MINIEPIMOD_TMB_HPP

#undef TMB_OBJECTIVE_PTR
#define TMB_OBJECTIVE_PTR obj

#include "../simForward.h"

template<class Type>
  Type miniEpiMod_tmb(objective_function<Type>* obj)
{

  using Eigen::Matrix;

  DATA_INTEGER(time_steps);
  DATA_VECTOR(data_mean);
  DATA_VECTOR(data_sd);
  DATA_IVECTOR(data_idx);
  DATA_SCALAR(second_order_diff_penalty);
  DATA_MATRIX(rt_design); 
  DATA_MATRIX(tpm_base);
  
  Type nll(0.0);

  // Priors
  PARAMETER_VECTOR(log_rt);
  vector<Type> rt = rt_design * exp(log_rt);
  nll -= dnorm(log_rt, Type(log(0.5)), Type(5.0), true).sum();
  Sim<Type> sim(simForward<Type>(rt, time_steps, tpm_base));

  // likelihood
  // TODO: look into using an array of indices to evaluate all at once (no for loop)
  for(int i = 0; i < data_idx.size(); i++) {
    nll -= dnorm(data_mean(i),
                sim.x_out(1, data_idx[i] - 1),
                data_sd(i), true);
  }

  
  
  // Second-order difference penalty
  for(int i = 0; i < log_rt.size() - 1; i++) {
    nll += second_order_diff_penalty * pow((log_rt(i + 2) - log_rt(i + 1)) - (log_rt(i + 1) - log_rt(i)), 2);
  }

  // REPORT(x_out);

  return Type(nll);
}

#undef TMB_OBJECTIVE_PTR
#define TMB_OBJECTIVE_PTR this

#endif
