// DO NOT EDIT -- generated by mk-ops.awk
#if ! defined (octave_mx_nda_i8nda_h)
#define octave_mx_nda_i8nda_h 1
#include "octave-config.h"
#include "int8NDArray.h"
#include "dNDArray.h"
  extern OCTAVE_API int8NDArray operator + (const NDArray&, const int8NDArray&);
  extern OCTAVE_API int8NDArray operator - (const NDArray&, const int8NDArray&);
  extern OCTAVE_API int8NDArray product (const NDArray&, const int8NDArray&);
  extern OCTAVE_API int8NDArray quotient (const NDArray&, const int8NDArray&);
  extern OCTAVE_API boolNDArray mx_el_lt (const NDArray&, const int8NDArray&);
  extern OCTAVE_API boolNDArray mx_el_le (const NDArray&, const int8NDArray&);
  extern OCTAVE_API boolNDArray mx_el_ge (const NDArray&, const int8NDArray&);
  extern OCTAVE_API boolNDArray mx_el_gt (const NDArray&, const int8NDArray&);
  extern OCTAVE_API boolNDArray mx_el_eq (const NDArray&, const int8NDArray&);
  extern OCTAVE_API boolNDArray mx_el_ne (const NDArray&, const int8NDArray&);
  extern OCTAVE_API boolNDArray mx_el_and (const NDArray&, const int8NDArray&);
  extern OCTAVE_API boolNDArray mx_el_or (const NDArray&, const int8NDArray&);
  extern OCTAVE_API boolNDArray mx_el_not_and (const NDArray&, const int8NDArray&);
  extern OCTAVE_API boolNDArray mx_el_not_or (const NDArray&, const int8NDArray&);
  extern OCTAVE_API boolNDArray mx_el_and_not (const NDArray&, const int8NDArray&);
  extern OCTAVE_API boolNDArray mx_el_or_not (const NDArray&, const int8NDArray&);
#endif
