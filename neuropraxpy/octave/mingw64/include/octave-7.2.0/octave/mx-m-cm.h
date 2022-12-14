// DO NOT EDIT -- generated by mk-ops.awk
#if ! defined (octave_mx_m_cm_h)
#define octave_mx_m_cm_h 1
#include "octave-config.h"
#include "CMatrix.h"
#include "dMatrix.h"
  extern OCTAVE_API ComplexMatrix operator + (const Matrix&, const ComplexMatrix&);
  extern OCTAVE_API ComplexMatrix operator - (const Matrix&, const ComplexMatrix&);
  extern OCTAVE_API ComplexMatrix product (const Matrix&, const ComplexMatrix&);
  extern OCTAVE_API ComplexMatrix quotient (const Matrix&, const ComplexMatrix&);
  extern OCTAVE_API boolMatrix mx_el_lt (const Matrix&, const ComplexMatrix&);
  extern OCTAVE_API boolMatrix mx_el_le (const Matrix&, const ComplexMatrix&);
  extern OCTAVE_API boolMatrix mx_el_ge (const Matrix&, const ComplexMatrix&);
  extern OCTAVE_API boolMatrix mx_el_gt (const Matrix&, const ComplexMatrix&);
  extern OCTAVE_API boolMatrix mx_el_eq (const Matrix&, const ComplexMatrix&);
  extern OCTAVE_API boolMatrix mx_el_ne (const Matrix&, const ComplexMatrix&);
  extern OCTAVE_API boolMatrix mx_el_and (const Matrix&, const ComplexMatrix&);
  extern OCTAVE_API boolMatrix mx_el_or (const Matrix&, const ComplexMatrix&);
#endif
