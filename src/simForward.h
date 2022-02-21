#ifndef SIMFORWARD_H
#define SIMFORWARD_H

# include <Eigen/Dense>


template <typename Type>
class Sim{
  typedef Eigen::Matrix<Type, Eigen::Dynamic, Eigen::Dynamic> MatrixXXT;
public:
  const Type foi;
  const int N;
  MatrixXXT tpm;
  MatrixXXT x_out;

  Sim(const Type foi,const int N):
    foi { foi },
    N { N },
    tpm {  MatrixXXT(3, 3) },
    x_out{ MatrixXXT(3, N) }
    {
      x_out.col(0) <<  1.0, 0.0, 0.0;
      tpm << 1.0 - foi, 0.2, 0.0,
             foi,       0.75,  0.5,
             0.0,       0.05, 0.5;
    };

  void stepForward(int i);
};

template <typename Type>
void Sim<Type>::stepForward(int i) {
  x_out.col(i) = tpm * x_out.col(i - 1);
}

template <typename Type>
Sim<Type>
simForward(const Type foi, const int N) {
  Sim<Type> sim(foi, N);
  for (int i = 1; i < N; i++) {
    sim.stepForward(i);
  }
  return (sim);
}


#endif
