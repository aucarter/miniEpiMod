#include <Rcpp.h>
#include <RcppEigen.h>
#include "simForward.h"

// [[Rcpp::export]]
Rcpp::List
simForwardR(const Eigen::Map<Eigen::MatrixXd> foi, int time_steps){
  Sim<double> sim(simForward<double>(foi, time_steps));
  return Rcpp::List::create(Rcpp::Named("x_out") = sim.x_out,
                            Rcpp::Named("tpm_base") = sim.tpm_base);
}
