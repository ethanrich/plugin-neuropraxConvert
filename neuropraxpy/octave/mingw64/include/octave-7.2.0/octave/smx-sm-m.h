// DO NOT EDIT -- generated by mk-ops.awk
#if ! defined (octave_smx_sm_m_h)
#define octave_smx_sm_m_h 1
#include "octave-config.h"
#include "dMatrix.h"
#include "dSparse.h"
#include "Sparse-op-defs.h"
  extern OCTAVE_API Matrix operator + (const SparseMatrix&, const Matrix&);
  extern OCTAVE_API Matrix operator - (const SparseMatrix&, const Matrix&);
  extern OCTAVE_API SparseMatrix product (const SparseMatrix&, const Matrix&);
  extern OCTAVE_API SparseMatrix quotient (const SparseMatrix&, const Matrix&);
  extern OCTAVE_API SparseBoolMatrix mx_el_lt (const SparseMatrix&, const Matrix&);
  extern OCTAVE_API SparseBoolMatrix mx_el_le (const SparseMatrix&, const Matrix&);
  extern OCTAVE_API SparseBoolMatrix mx_el_ge (const SparseMatrix&, const Matrix&);
  extern OCTAVE_API SparseBoolMatrix mx_el_gt (const SparseMatrix&, const Matrix&);
  extern OCTAVE_API SparseBoolMatrix mx_el_eq (const SparseMatrix&, const Matrix&);
  extern OCTAVE_API SparseBoolMatrix mx_el_ne (const SparseMatrix&, const Matrix&);
  extern OCTAVE_API SparseBoolMatrix mx_el_and (const SparseMatrix&, const Matrix&);
  extern OCTAVE_API SparseBoolMatrix mx_el_or (const SparseMatrix&, const Matrix&);
#endif
