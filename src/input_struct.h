// Corresponding list object on the C++ side
#ifndef INPUT_STRUCT_H
#define INPUT_STRUCT_H

template<class Type>
struct input_list {
  int time_steps;
  vector<Type> data_mean;
  vector<Type> data_sd;
  vector<Type> data_idx;
  double second_order_diff_penalty;
  matrix<Type> foi_design;
  matrix<Type> tpm_base;
  input_list(SEXP x){ // Constructor
    time_steps = getListElement(x,"time_steps");
    data_mean = asVector<Type>(getListElement(x,"data_mean"));
    data_sd = asVector<Type>(getListElement(x,"data_sd"));
    data_idx = asVector<Type>(getListElement(x,"data_idx"));
    second_order_diff_penalty = getListElement(x,"second_order_diff_penalty");
    foi_design = asMatrix<Type>(getListElement(x,"foi_design"));
    tpm_base = asMatrix<Type>(getListElement(x,"tpm_base"));
  }
};

#endif