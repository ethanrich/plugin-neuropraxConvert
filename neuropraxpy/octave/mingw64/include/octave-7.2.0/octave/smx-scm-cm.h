// DO NOT EDIT -- generated by mk-ops.awk
#if ! defined (octave_smx_scm_cm_h)
#define octave_smx_scm_cm_h 1
#include "octave-config.h"
#include "CMatrix.h"
#include "CSparse.h"
#include "Sparse-op-defs.h"
  extern OCTAVE_API ComplexMatrix operator + (const SparseComplexMatrix&, const ComplexMatrix&);
  extern OCTAVE_API ComplexMatrix operator - (const SparseComplexMatrix&, const ComplexMatrix&);
  extern OCTAVE_API SparseComplexMatrix product (const SparseComplexMatrix&, const ComplexMatrix&);
  extern OCTAVE_API SparseComplexMatrix quotient (const SparseComplexMatrix&, const ComplexMatrix&);
  extern OCTAVE_API SparseBoolMatrix mx_el_lt (const SparseComplexMatrix&, const ComplexMatrix&);
  extern OCTAVE_API SparseBoolMatrix mx_el_le (const SparseComplexMatrix&, const ComplexMatrix&);
  extern OCTAVE_API SparseBoolMatrix mx_el_ge (const SparseComplexMatrix&, const ComplexMatrix&);
  extern OCTAVE_API SparseBoolMatrix mx_el_gt (const SparseComplexMatrix&, const ComplexMatrix&);
  extern OCTAVE_API SparseBoolMatrix mx_el_eq (const SparseComplexMatrix&, const ComplexMatrix&);
  extern OCTAVE_API SparseBoolMatrix mx_el_ne (const SparseComplexMatrix&, const ComplexMatrix&);
  extern OCTAVE_API SparseBoolMatrix mx_el_and (const SparseComplexMatrix&, const ComplexMatrix&);
  extern OCTAVE_API SparseBoolMatrix mx_el_or (const SparseComplexMatrix&, const ComplexMatrix&);
#endif