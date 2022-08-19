// DO NOT EDIT -- generated by mk-ops.awk
#if ! defined (octave_mx_cs_nda_h)
#define octave_mx_cs_nda_h 1
#include "octave-config.h"
#include "CNDArray.h"
#include "oct-cmplx.h"
#include "dNDArray.h"
  extern OCTAVE_API ComplexNDArray operator + (const Complex&, const NDArray&);
  extern OCTAVE_API ComplexNDArray operator - (const Complex&, const NDArray&);
  extern OCTAVE_API ComplexNDArray operator * (const Complex&, const NDArray&);
  extern OCTAVE_API ComplexNDArray operator / (const Complex&, const NDArray&);
  extern OCTAVE_API boolNDArray mx_el_lt (const Complex&, const NDArray&);
  extern OCTAVE_API boolNDArray mx_el_le (const Complex&, const NDArray&);
  extern OCTAVE_API boolNDArray mx_el_ge (const Complex&, const NDArray&);
  extern OCTAVE_API boolNDArray mx_el_gt (const Complex&, const NDArray&);
  extern OCTAVE_API boolNDArray mx_el_eq (const Complex&, const NDArray&);
  extern OCTAVE_API boolNDArray mx_el_ne (const Complex&, const NDArray&);
  extern OCTAVE_API boolNDArray mx_el_and (const Complex&, const NDArray&);
  extern OCTAVE_API boolNDArray mx_el_or (const Complex&, const NDArray&);
  extern OCTAVE_API boolNDArray mx_el_and_not (const Complex&, const NDArray&);
  extern OCTAVE_API boolNDArray mx_el_or_not (const Complex&, const NDArray&);
#endif
