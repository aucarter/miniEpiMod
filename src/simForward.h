#ifndef SIMFORWARD_H
#define SIMFORWARD_H

# include <Eigen/Dense>


template <typename Type>
class Sim{
  // Use this as the Eigen matrix that can hold ADC
  typedef Eigen::Matrix<Type, Eigen::Dynamic, Eigen::Dynamic> MatrixXXT;
public:
  MatrixXXT foi;
  const int time_steps;
  MatrixXXT tpm_base;
  MatrixXXT x_out;

  Sim(const Eigen::Matrix<Type, Eigen::Dynamic, 1>& foi,const int time_steps):
    foi { foi },
    time_steps { time_steps },
    tpm_base { MatrixXXT(3, 3) },
    x_out{ MatrixXXT(3, time_steps) }
    {
      tpm_base << 1.0, 0.20, 0.0,
                  0.0, 0.75, 0.5,
                  0.0, 0.05, 0.5;
      MatrixXXT tpm = tpm_base;
      tpm.col(0) << 1 - foi(0), foi(0), 0;
      // Eigen::EigenSolver<MatrixXXT> es(tpm);
      // MatrixXXT first_ev = es.eigenvectors().real().col(0);
      // MatrixXXT ev_stand = first_ev / first_ev.sum();
      // x_out.col(0) = ev_stand;
      x_out.col(0) << 1, 0, 0;
      for (int i = 0; i < 100; i++) {
        x_out.col(0) = tpm * x_out.col(0);
      }
    };

  void stepForward(int i);
};

template <typename Type>
void Sim<Type>::stepForward(int i) {
  MatrixXXT tpm = tpm_base;
  tpm.col(0) << 1 - foi(i), foi(i), 0;
  x_out.col(i) = tpm * x_out.col(i - 1);
}

template <typename Type>
Sim<Type>
simForward(Eigen::Matrix<Type, Eigen::Dynamic, Eigen::Dynamic> foi, const int time_steps) {
  Sim<Type> sim(foi, time_steps);
  for (int i = 1; i < time_steps; i++) {
    sim.stepForward(i);
  }
  return (sim);
}


#endif
