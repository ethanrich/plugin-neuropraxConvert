// DO NOT EDIT!
// Generated automatically from /scratch/build/mxe-octave-w64/release/tmp-release-octave/octave-7.2.0/liboctave/numeric/LSODE-opts.in.

#if ! defined (octave_LSODE_options_h)
#define octave_LSODE_options_h 1

#include <cmath>

#include <limits>

#include "ODE.h"


class
LSODE_options
{
public:

  LSODE_options (void)
    : m_absolute_tolerance (),
      m_relative_tolerance (),
      m_integration_method (),
      m_initial_step_size (),
      m_maximum_order (),
      m_maximum_step_size (),
      m_minimum_step_size (),
      m_step_limit (),
      m_reset ()
    {
      init ();
    }

  LSODE_options (const LSODE_options& opt)
    : m_absolute_tolerance (opt.m_absolute_tolerance),
      m_relative_tolerance (opt.m_relative_tolerance),
      m_integration_method (opt.m_integration_method),
      m_initial_step_size (opt.m_initial_step_size),
      m_maximum_order (opt.m_maximum_order),
      m_maximum_step_size (opt.m_maximum_step_size),
      m_minimum_step_size (opt.m_minimum_step_size),
      m_step_limit (opt.m_step_limit),
      m_reset (opt.m_reset)
    { }

  LSODE_options& operator = (const LSODE_options& opt)
    {
      if (this != &opt)
        {
          m_absolute_tolerance = opt.m_absolute_tolerance;
          m_relative_tolerance = opt.m_relative_tolerance;
          m_integration_method = opt.m_integration_method;
          m_initial_step_size = opt.m_initial_step_size;
          m_maximum_order = opt.m_maximum_order;
          m_maximum_step_size = opt.m_maximum_step_size;
          m_minimum_step_size = opt.m_minimum_step_size;
          m_step_limit = opt.m_step_limit;
          m_reset = opt.m_reset;
        }

      return *this;
    }

  ~LSODE_options (void) { }

  void init (void)
    {
      m_absolute_tolerance.resize (dim_vector (1, 1));
      m_absolute_tolerance(0) = ::sqrt (std::numeric_limits<double>::epsilon ());
      m_relative_tolerance = ::sqrt (std::numeric_limits<double>::epsilon ());
      m_integration_method = "stiff";
      m_initial_step_size = -1.0;
      m_maximum_order = -1;
      m_maximum_step_size = -1.0;
      m_minimum_step_size = 0.0;
      m_step_limit = 100000;
      m_reset = true;
    }

  void set_options (const LSODE_options& opt)
    {
      m_absolute_tolerance = opt.m_absolute_tolerance;
      m_relative_tolerance = opt.m_relative_tolerance;
      m_integration_method = opt.m_integration_method;
      m_initial_step_size = opt.m_initial_step_size;
      m_maximum_order = opt.m_maximum_order;
      m_maximum_step_size = opt.m_maximum_step_size;
      m_minimum_step_size = opt.m_minimum_step_size;
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
    { m_relative_tolerance = (val > 0.0) ? val : ::sqrt (std::numeric_limits<double>::epsilon ()); m_reset = true; }

  void set_integration_method (const std::string& val)
    {
      if (val == "stiff" || val == "bdf")
        m_integration_method = "stiff";
      else if (val == "non-stiff" || val == "adams")
        m_integration_method = "non-stiff";
      else
        (*current_liboctave_error_handler)
          ("lsode_options: method must be \"stiff\", \"bdf\", \"non-stiff\", or \"adams\"");
      m_reset = true;
    }

  void set_initial_step_size (double val)
    { m_initial_step_size = (val >= 0.0) ? val : -1.0; m_reset = true; }

  void set_maximum_order (octave_idx_type val)
    { m_maximum_order = val; m_reset = true; }

  void set_maximum_step_size (double val)
    { m_maximum_step_size = (val >= 0.0) ? val : -1.0; m_reset = true; }

  void set_minimum_step_size (double val)
    { m_minimum_step_size = (val >= 0.0) ? val : 0.0; m_reset = true; }

  void set_step_limit (octave_idx_type val)
    { m_step_limit = val; m_reset = true; }
  Array<double> absolute_tolerance (void) const
    { return m_absolute_tolerance; }

  double relative_tolerance (void) const
    { return m_relative_tolerance; }

  std::string integration_method (void) const
    { return m_integration_method; }

  double initial_step_size (void) const
    { return m_initial_step_size; }

  octave_idx_type maximum_order (void) const
    { return m_maximum_order; }

  double maximum_step_size (void) const
    { return m_maximum_step_size; }

  double minimum_step_size (void) const
    { return m_minimum_step_size; }

  octave_idx_type step_limit (void) const
    { return m_step_limit; }

private:

  Array<double> m_absolute_tolerance;
  double m_relative_tolerance;
  std::string m_integration_method;
  double m_initial_step_size;
  octave_idx_type m_maximum_order;
  double m_maximum_step_size;
  double m_minimum_step_size;
  octave_idx_type m_step_limit;

protected:

  bool m_reset;
};

#endif
