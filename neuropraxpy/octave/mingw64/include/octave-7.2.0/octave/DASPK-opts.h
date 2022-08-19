// DO NOT EDIT!
// Generated automatically from /scratch/build/mxe-octave-w64/release/tmp-release-octave/octave-7.2.0/liboctave/numeric/DASPK-opts.in.

#if ! defined (octave_DASPK_options_h)
#define octave_DASPK_options_h 1

#include <cmath>

#include <limits>

#include "DAE.h"


class
DASPK_options
{
public:

  DASPK_options (void)
    : m_absolute_tolerance (),
      m_relative_tolerance (),
      m_compute_consistent_initial_condition (),
      m_use_initial_condition_heuristics (),
      m_initial_condition_heuristics (),
      m_print_initial_condition_info (),
      m_exclude_algebraic_variables_from_error_test (),
      m_algebraic_variables (),
      m_enforce_inequality_constraints (),
      m_inequality_constraint_types (),
      m_initial_step_size (),
      m_maximum_order (),
      m_maximum_step_size (),
      m_reset ()
    {
      init ();
    }

  DASPK_options (const DASPK_options& opt)
    : m_absolute_tolerance (opt.m_absolute_tolerance),
      m_relative_tolerance (opt.m_relative_tolerance),
      m_compute_consistent_initial_condition (opt.m_compute_consistent_initial_condition),
      m_use_initial_condition_heuristics (opt.m_use_initial_condition_heuristics),
      m_initial_condition_heuristics (opt.m_initial_condition_heuristics),
      m_print_initial_condition_info (opt.m_print_initial_condition_info),
      m_exclude_algebraic_variables_from_error_test (opt.m_exclude_algebraic_variables_from_error_test),
      m_algebraic_variables (opt.m_algebraic_variables),
      m_enforce_inequality_constraints (opt.m_enforce_inequality_constraints),
      m_inequality_constraint_types (opt.m_inequality_constraint_types),
      m_initial_step_size (opt.m_initial_step_size),
      m_maximum_order (opt.m_maximum_order),
      m_maximum_step_size (opt.m_maximum_step_size),
      m_reset (opt.m_reset)
    { }

  DASPK_options& operator = (const DASPK_options& opt)
    {
      if (this != &opt)
        {
          m_absolute_tolerance = opt.m_absolute_tolerance;
          m_relative_tolerance = opt.m_relative_tolerance;
          m_compute_consistent_initial_condition = opt.m_compute_consistent_initial_condition;
          m_use_initial_condition_heuristics = opt.m_use_initial_condition_heuristics;
          m_initial_condition_heuristics = opt.m_initial_condition_heuristics;
          m_print_initial_condition_info = opt.m_print_initial_condition_info;
          m_exclude_algebraic_variables_from_error_test = opt.m_exclude_algebraic_variables_from_error_test;
          m_algebraic_variables = opt.m_algebraic_variables;
          m_enforce_inequality_constraints = opt.m_enforce_inequality_constraints;
          m_inequality_constraint_types = opt.m_inequality_constraint_types;
          m_initial_step_size = opt.m_initial_step_size;
          m_maximum_order = opt.m_maximum_order;
          m_maximum_step_size = opt.m_maximum_step_size;
          m_reset = opt.m_reset;
        }

      return *this;
    }

  ~DASPK_options (void) { }

  void init (void)
    {
      m_absolute_tolerance.resize (dim_vector (1, 1));
      m_absolute_tolerance(0) = ::sqrt (std::numeric_limits<double>::epsilon ());
      m_relative_tolerance.resize (dim_vector (1, 1));
      m_relative_tolerance(0) = ::sqrt (std::numeric_limits<double>::epsilon ());
      m_initial_condition_heuristics.resize (dim_vector (6, 1));
      m_initial_condition_heuristics(0) = 5.0;
      m_initial_condition_heuristics(1) = 6.0;
      m_initial_condition_heuristics(2) = 5.0;
      m_initial_condition_heuristics(3) = 0.0;
      m_initial_condition_heuristics(4) = ::pow (std::numeric_limits<double>::epsilon (), 2.0/3.0);
      m_initial_condition_heuristics(5) = 0.01;
      m_algebraic_variables.resize (dim_vector (1, 1));
      m_algebraic_variables(0) = 0;
      m_inequality_constraint_types.resize (dim_vector (1, 1));
      m_inequality_constraint_types(0) = 0;
      m_initial_step_size = -1.0;
      m_maximum_order = 5;
      m_maximum_step_size = -1.0;
      m_reset = true;
    }

  void set_options (const DASPK_options& opt)
    {
      m_absolute_tolerance = opt.m_absolute_tolerance;
      m_relative_tolerance = opt.m_relative_tolerance;
      m_compute_consistent_initial_condition = opt.m_compute_consistent_initial_condition;
      m_use_initial_condition_heuristics = opt.m_use_initial_condition_heuristics;
      m_initial_condition_heuristics = opt.m_initial_condition_heuristics;
      m_print_initial_condition_info = opt.m_print_initial_condition_info;
      m_exclude_algebraic_variables_from_error_test = opt.m_exclude_algebraic_variables_from_error_test;
      m_algebraic_variables = opt.m_algebraic_variables;
      m_enforce_inequality_constraints = opt.m_enforce_inequality_constraints;
      m_inequality_constraint_types = opt.m_inequality_constraint_types;
      m_initial_step_size = opt.m_initial_step_size;
      m_maximum_order = opt.m_maximum_order;
      m_maximum_step_size = opt.m_maximum_step_size;
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

  void set_compute_consistent_initial_condition (octave_idx_type val)
    { m_compute_consistent_initial_condition = val; m_reset = true; }

  void set_use_initial_condition_heuristics (octave_idx_type val)
    { m_use_initial_condition_heuristics = val; m_reset = true; }

  void set_initial_condition_heuristics (const Array<double>& val)
    { m_initial_condition_heuristics = val; m_reset = true; }

  void set_print_initial_condition_info (octave_idx_type val)
    { m_print_initial_condition_info = val; m_reset = true; }

  void set_exclude_algebraic_variables_from_error_test (octave_idx_type val)
    { m_exclude_algebraic_variables_from_error_test = val; m_reset = true; }

  void set_algebraic_variables (int val)
    {
      m_algebraic_variables.resize (dim_vector (1, 1));
      m_algebraic_variables(0) = val;
      m_reset = true;
    }

  void set_algebraic_variables (const Array<octave_idx_type>& val)
    { m_algebraic_variables = val; m_reset = true; }

  void set_enforce_inequality_constraints (octave_idx_type val)
    { m_enforce_inequality_constraints = val; m_reset = true; }

  void set_inequality_constraint_types (octave_idx_type val)
    {
      m_inequality_constraint_types.resize (dim_vector (1, 1));
      m_inequality_constraint_types(0) = val;
      m_reset = true;
    }

  void set_inequality_constraint_types (const Array<octave_idx_type>& val)
    { m_inequality_constraint_types = val; m_reset = true; }

  void set_initial_step_size (double val)
    { m_initial_step_size = (val >= 0.0) ? val : -1.0; m_reset = true; }

  void set_maximum_order (octave_idx_type val)
    { m_maximum_order = val; m_reset = true; }

  void set_maximum_step_size (double val)
    { m_maximum_step_size = (val >= 0.0) ? val : -1.0; m_reset = true; }
  Array<double> absolute_tolerance (void) const
    { return m_absolute_tolerance; }

  Array<double> relative_tolerance (void) const
    { return m_relative_tolerance; }

  octave_idx_type compute_consistent_initial_condition (void) const
    { return m_compute_consistent_initial_condition; }

  octave_idx_type use_initial_condition_heuristics (void) const
    { return m_use_initial_condition_heuristics; }

  Array<double> initial_condition_heuristics (void) const
    { return m_initial_condition_heuristics; }

  octave_idx_type print_initial_condition_info (void) const
    { return m_print_initial_condition_info; }

  octave_idx_type exclude_algebraic_variables_from_error_test (void) const
    { return m_exclude_algebraic_variables_from_error_test; }

  Array<octave_idx_type> algebraic_variables (void) const
    { return m_algebraic_variables; }

  octave_idx_type enforce_inequality_constraints (void) const
    { return m_enforce_inequality_constraints; }

  Array<octave_idx_type> inequality_constraint_types (void) const
    { return m_inequality_constraint_types; }

  double initial_step_size (void) const
    { return m_initial_step_size; }

  octave_idx_type maximum_order (void) const
    { return m_maximum_order; }

  double maximum_step_size (void) const
    { return m_maximum_step_size; }

private:

  Array<double> m_absolute_tolerance;
  Array<double> m_relative_tolerance;
  octave_idx_type m_compute_consistent_initial_condition;
  octave_idx_type m_use_initial_condition_heuristics;
  Array<double> m_initial_condition_heuristics;
  octave_idx_type m_print_initial_condition_info;
  octave_idx_type m_exclude_algebraic_variables_from_error_test;
  Array<octave_idx_type> m_algebraic_variables;
  octave_idx_type m_enforce_inequality_constraints;
  Array<octave_idx_type> m_inequality_constraint_types;
  double m_initial_step_size;
  octave_idx_type m_maximum_order;
  double m_maximum_step_size;

protected:

  bool m_reset;
};

#endif
