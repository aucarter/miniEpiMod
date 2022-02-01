#include <RcppEigen.h>
//[[Rcpp::depends(RcppEigen)]]
//[[Rcpp::export]]
Eigen::MatrixXd simForward(Eigen::VectorXd x,
                     Eigen::MatrixXd tpm,
                     int N){
  Eigen::MatrixXd x_out(x.size(), N);
  x_out.col(0) = x;
  for (int i = 0; i < N; i++) {
    x = tpm * x;
    x_out.col(i) = x;
  }
  return (x_out);
}
