// DO NOT EDIT -- generated by mk-ops.awk
#if ! defined (octave_mx_m_cs_h)
#define octave_mx_m_cs_h 1
#include "octave-config.h"
#include "CMatrix.h"
#include "dMatrix.h"
#include "oct-cmplx.h"
  extern OCTAVE_API ComplexMatrix operator + (const Matrix&, const Complex&);
  extern OCTAVE_API ComplexMatrix operator - (const Matrix&, const Complex&);
  extern OCTAVE_API ComplexMatrix operator * (const Matrix&, const Complex&);
  extern OCTAVE_API ComplexMatrix operator / (const Matrix&, const Complex&);
  extern OCTAVE_API boolMatrix mx_el_lt (const Matrix&, const Complex&);
  extern OCTAVE_API boolMatrix mx_el_le (const Matrix&, const Complex&);
  extern OCTAVE_API boolMatrix mx_el_ge (const Matrix&, const Complex&);
  extern OCTAVE_API boolMatrix mx_el_gt (const Matrix&, const Complex&);
  extern OCTAVE_API boolMatrix mx_el_eq (const Matrix&, const Complex&);
  extern OCTAVE_API boolMatrix mx_el_ne (const Matrix&, const Complex&);
  extern OCTAVE_API boolMatrix mx_el_and (const Matrix&, const Complex&);
  extern OCTAVE_API boolMatrix mx_el_or (const Matrix&, const Complex&);
#endif
