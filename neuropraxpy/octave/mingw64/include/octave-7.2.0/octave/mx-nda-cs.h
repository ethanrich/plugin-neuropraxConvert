// DO NOT EDIT -- generated by mk-ops.awk
#if ! defined (octave_mx_nda_cs_h)
#define octave_mx_nda_cs_h 1
#include "octave-config.h"
#include "CNDArray.h"
#include "dNDArray.h"
#include "oct-cmplx.h"
  extern OCTAVE_API ComplexNDArray operator + (const NDArray&, const Complex&);
  extern OCTAVE_API ComplexNDArray operator - (const NDArray&, const Complex&);
  extern OCTAVE_API ComplexNDArray operator * (const NDArray&, const Complex&);
  extern OCTAVE_API ComplexNDArray operator / (const NDArray&, const Complex&);
  extern OCTAVE_API boolNDArray mx_el_lt (const NDArray&, const Complex&);
  extern OCTAVE_API boolNDArray mx_el_le (const NDArray&, const Complex&);
  extern OCTAVE_API boolNDArray mx_el_ge (const NDArray&, const Complex&);
  extern OCTAVE_API boolNDArray mx_el_gt (const NDArray&, const Complex&);
  extern OCTAVE_API boolNDArray mx_el_eq (const NDArray&, const Complex&);
  extern OCTAVE_API boolNDArray mx_el_ne (const NDArray&, const Complex&);
  extern OCTAVE_API boolNDArray mx_el_and (const NDArray&, const Complex&);
  extern OCTAVE_API boolNDArray mx_el_or (const NDArray&, const Complex&);
  extern OCTAVE_API boolNDArray mx_el_not_and (const NDArray&, const Complex&);
  extern OCTAVE_API boolNDArray mx_el_not_or (const NDArray&, const Complex&);
#endif
