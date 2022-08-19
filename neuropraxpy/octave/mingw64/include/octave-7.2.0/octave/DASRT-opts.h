// DO NOT EDIT!
// Generated automatically from /scratch/build/mxe-octave-w64/release/tmp-release-octave/octave-7.2.0/liboctave/numeric/DASRT-opts.in.

#if ! defined (octave_DASRT_options_h)
#define octave_DASRT_options_h 1

#include <cmath>

#include <limits>

#include "DAERT.h"


class
DASRT_options
{
public:

  DASRT_options (void)
    : m_absolute_tolerance (),
      m_relative_tolerance (),
      m_initial_step_size (),
      m_maximum_order (),
      m_maximum_step_size (),
      m_step_limit (),
      m_reset ()
    {
      init ();
    }

  DASRT_options (const DASRT_options& opt)
    : m_absolute_tolerance (opt.m_absolute_tolerance),
      m_relative_tolerance (opt.m_relative_tolerance),
      m_initial_step_size (opt.m_initial_step_size),
      m_maximum_order (opt.m_maximum_order),
      m_maximum_step_size (opt.m_maximum_step_size),
      m_step_limit (opt.m_step_limit),
      m_reset (opt.m_reset)
    { }

  DASRT_options& operator = (const DASRT_options& opt)
    {
      if (this != &opt)
        {
          m_absolute_tolerance = opt.m_absolute_tolerance;
          m_relative_tolerance = opt.m_relative_tolerance;
          m_initial_step_size = opt.m_initial_step_size;
          m_maximum_order = opt.m_maximum_order;
          m_maximum_step_size = opt.m_maximum_step_size;
          m_step_limit = opt.m_step_limit;
          m_reset = opt.m_reset;
        }

      return *this;
    }

  ~DASRT_options (void) { }

  void init (void)
    {
      m_absolute_tolerance.resize (dim_vector (1, 1));
      m_absolute_tolerance(0) = ::sqrt (std::numeric_limits<double>::epsilon ());
      m_relative_tolerance.resize (dim_vector (1, 1));
      m_relative_tolerance(0) = ::sqrt (std::numeric_limits<double>::epsilon ());
      m_initial_step_size = -1.0;
      m_maximum_order = -1;
      m_maximum_step_size = -1.0;
      m_step_limit = -1;
      m_reset = true;
    }

  void set_options (const DASRT_options& opt)
    {
      m_absolute_tolerance = opt.m_absolute_tolerance;
      m_relative_tolerance = opt.m_relative_tolerance;
      m_initial_step_size = opt.m_initial_step_size;
      m_maximum_order = opt.m_maximum_order;
      m_maximum_step_size = opt.m_maximum_step_size;
      m_step_limit = opt.m_step_limit;
      m_reset = opt.m_reset;
    }

  void set_default_options (void) { init (); }

  void set_absolute_tolerance (double val)
    {
      m_absolute_tolerance.resize (dim_vector (1, 1));
      m_absolute_tolerance(0) = (val > 0.0) ? val : ::sqrt (std::numeric_limits<double>::epsilon ());
      m_reset = true;
    }

  void set_absolute_tolerance (const Array<double>& val)
    { m_absolute_tolerance = val; m_reset = true; }

  void set_relative_tolerance (double val)
    {
      m_relative_tolerance.resize (dim_vector (1, 1));
      m_relative_tolerance(0) = (val > 0.0) ? val : ::sqrt (std::numeric_limits<double>::epsilon ());
      m_reset = true;
    }

  void set_relative_tolerance (const Array<double>& val)
    { m_relative_tolerance = val; m_reset = true; }

  void set_initial_step_size (double val)
    { m_initial_step_size = (val >= 0.0) ? val : -1.0; m_reset = true; }

  void set_maximum_order (octave_idx_type val)
    { m_maximum_order = val; m_reset = true; }

  void set_maximum_step_size (double val)
    { m_maximum_step_size = (val >= 0.0) ? val : -1.0; m_reset = true; }

  void set_step_limit (octave_idx_type val)
    { m_step_limit = (val >= 0) ? val : -1; m_reset = true; }
  Array<double> absolute_tolerance (void) const
    { return m_absolute_tolerance; }

  Array<double> relative_tolerance (void) const
    { return m_relative_tolerance; }

  double initial_step_size (void) const
    { return m_initial_step_size; }

  octave_idx_type maximum_order (void) const
    { return m_maximum_order; }

  double maximum_step_size (void) const
    { return m_maximum_step_size; }

  octave_idx_type step_limit (void) const
    { return m_step_limit; }

private:

  Array<double> m_absolute_tolerance;
  Array<double> m_relative_tolerance;
  double m_initial_step_size;
  octave_idx_type m_maximum_order;
  double m_maximum_step_size;
  octave_idx_type m_step_limit;

protected:

  bool m_reset;
};

#endif
