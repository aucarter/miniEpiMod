#include <Rcpp.h>
#include <RcppEigen.h>
#include "simForward.h"

// [[Rcpp::export]]
Rcpp::List
simForwardR(double foi,int N){
  Sim<double> sim(simForward<double>(foi, N));
  return Rcpp::List::create(Rcpp::Named("x_out") = sim.x_out,
                            Rcpp::Named("tpm") = sim.tpm);
}
