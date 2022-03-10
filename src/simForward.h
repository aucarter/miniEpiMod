#ifndef SIMFORWARD_H
#define SIMFORWARD_H

# include <Eigen/Dense>

template <typename Type>
class Sim{
  // Use this as the Eigen matrix that can hold ADC
  typedef Eigen::Matrix<Type, Eigen::Dynamic, Eigen::Dynamic> MatrixXXT;
public:
  MatrixXXT rt;
  const int time_steps;
  MatrixXXT tpm_base;
  MatrixXXT x_out;

  Sim(
    const Eigen::Matrix<Type, Eigen::Dynamic, 1>& rt,
    const int time_steps,
    const Eigen::Matrix<Type, Eigen::Dynamic, Eigen::Dynamic>& tpm_base
  ):
    rt { rt },
    time_steps { time_steps },
    tpm_base { tpm_base },
    x_out{ MatrixXXT(tpm_base.rows(), time_steps) }
    {
      // Set up TPM
      MatrixXXT tpm = tpm_base;
      tpm(0, 0) = 1 - rt(0);
      tpm(1, 0) = rt(0);
      // Set up initial state
      x_out.col(0) = Eigen::Matrix<Type, 1, Eigen::Dynamic>::Zero(tpm_base.rows());
      x_out(0, 0) = 0.99;
      x_out(1, 0) = 0.01;
      for (int i = 0; i < 100; i++) {
        tpm(0, 0) = 1 - rt(0) * x_out(1, 0);
        tpm(1, 0) = rt(0) * x_out(1, 0);
        x_out.col(0) = tpm * x_out.col(0);
      }
    };

  void stepForward(int i);
};

template <typename Type>
void Sim<Type>::stepForward(int i) {
  MatrixXXT tpm = tpm_base;
  tpm(0, 0) = 1 - rt(i) * x_out(1, i - 1);
  tpm(1, 0) = rt(i) * x_out(1, i - 1);
  x_out.col(i) = tpm * x_out.col(i - 1);
}

template <typename Type>
Sim<Type>
simForward(Eigen::Matrix<Type, Eigen::Dynamic, 1> rt, const int time_steps,
           Eigen::Matrix<Type, Eigen::Dynamic, Eigen::Dynamic> tpm_base) {
  Sim<Type> sim(rt, time_steps, tpm_base);
  for (int i = 1; i < time_steps; i++) {
    sim.stepForward(i);
  }
  return (sim);
}


#endif
