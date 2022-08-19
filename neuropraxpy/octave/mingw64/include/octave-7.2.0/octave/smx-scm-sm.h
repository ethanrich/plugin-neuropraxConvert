// DO NOT EDIT -- generated by mk-ops.awk
#if ! defined (octave_smx_scm_sm_h)
#define octave_smx_scm_sm_h 1
#include "octave-config.h"
#include "CSparse.h"
#include "dSparse.h"
#include "Sparse-op-defs.h"
  extern OCTAVE_API SparseComplexMatrix operator + (const SparseComplexMatrix&, const SparseMatrix&);
  extern OCTAVE_API SparseComplexMatrix operator - (const SparseComplexMatrix&, const SparseMatrix&);
  extern OCTAVE_API SparseComplexMatrix product (const SparseComplexMatrix&, const SparseMatrix&);
  extern OCTAVE_API SparseComplexMatrix quotient (const SparseComplexMatrix&, const SparseMatrix&);
  extern OCTAVE_API SparseBoolMatrix mx_el_lt (const SparseComplexMatrix&, const SparseMatrix&);
  extern OCTAVE_API SparseBoolMatrix mx_el_le (const SparseComplexMatrix&, const SparseMatrix&);
  extern OCTAVE_API SparseBoolMatrix mx_el_ge (const SparseComplexMatrix&, const SparseMatrix&);
  extern OCTAVE_API SparseBoolMatrix mx_el_gt (const SparseComplexMatrix&, const SparseMatrix&);
  extern OCTAVE_API SparseBoolMatrix mx_el_eq (const SparseComplexMatrix&, const SparseMatrix&);
  extern OCTAVE_API SparseBoolMatrix mx_el_ne (const SparseComplexMatrix&, const SparseMatrix&);
  extern OCTAVE_API SparseBoolMatrix mx_el_and (const SparseComplexMatrix&, const SparseMatrix&);
  extern OCTAVE_API SparseBoolMatrix mx_el_or (const SparseComplexMatrix&, const SparseMatrix&);
#endif
