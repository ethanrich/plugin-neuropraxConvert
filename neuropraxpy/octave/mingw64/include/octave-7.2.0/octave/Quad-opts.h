// DO NOT EDIT!
// Generated automatically from /scratch/build/mxe-octave-w64/release/tmp-release-octave/octave-7.2.0/liboctave/numeric/Quad-opts.in.

#if ! defined (octave_Quad_options_h)
#define octave_Quad_options_h 1

#include <cmath>

#include <limits>



class
Quad_options
{
public:

  Quad_options (void)
    : m_absolute_tolerance (),
      m_relative_tolerance (),
      m_single_precision_absolute_tolerance (),
      m_single_precision_relative_tolerance (),
      m_reset ()
    {
      init ();
    }

  Quad_options (const Quad_options& opt)
    : m_absolute_tolerance (opt.m_absolute_tolerance),
      m_relative_tolerance (opt.m_relative_tolerance),
      m_single_precision_absolute_tolerance (opt.m_single_precision_absolute_tolerance),
      m_single_precision_relative_tolerance (opt.m_single_precision_relative_tolerance),
      m_reset (opt.m_reset)
    { }

  Quad_options& operator = (const Quad_options& opt)
    {
      if (this != &opt)
        {
          m_absolute_tolerance = opt.m_absolute_tolerance;
          m_relative_tolerance = opt.m_relative_tolerance;
          m_single_precision_absolute_tolerance = opt.m_single_precision_absolute_tolerance;
          m_single_precision_relative_tolerance = opt.m_single_precision_relative_tolerance;
          m_reset = opt.m_reset;
        }

      return *this;
    }

  ~Quad_options (void) { }

  void init (void)
    {
      m_absolute_tolerance = ::sqrt (std::numeric_limits<double>::epsilon ());
      m_relative_tolerance = ::sqrt (std::numeric_limits<double>::epsilon ());
      m_single_precision_absolute_tolerance = ::sqrt (std::numeric_limits<float>::epsilon ());
      m_single_precision_relative_tolerance = ::sqrt (std::numeric_limits<float>::epsilon ());
      m_reset = true;
    }

  void set_options (const Quad_options& opt)
    {
      m_absolute_tolerance = opt.m_absolute_tolerance;
      m_relative_tolerance = opt.m_relative_tolerance;
      m_single_precision_absolute_tolerance = opt.m_single_precision_absolute_tolerance;
      m_single_precision_relative_tolerance = opt.m_single_precision_relative_tolerance;
      m_reset = opt.m_reset;
    }

  void set_default_options (void) { init (); }

  void set_absolute_tolerance (double val)
    { m_absolute_tolerance = val; m_reset = true; }

  void set_relative_tolerance (double val)
    { m_relative_tolerance = val; m_reset = true; }

  void set_single_precision_absolute_tolerance (float val)
    { m_single_precision_absolute_tolerance = val; m_reset = true; }

  void set_single_precision_relative_tolerance (float val)
    { m_single_precision_relative_tolerance = val; m_reset = true; }
  double absolute_tolerance (void) const
    { return m_absolute_tolerance; }

  double relative_tolerance (void) const
    { return m_relative_tolerance; }

  float single_precision_absolute_tolerance (void) const
    { return m_single_precision_absolute_tolerance; }

  float single_precision_relative_tolerance (void) const
    { return m_single_precision_relative_tolerance; }

private:

  double m_absolute_tolerance;
  double m_relative_tolerance;
  float m_single_precision_absolute_tolerance;
  float m_single_precision_relative_tolerance;

protected:

  bool m_reset;
};

#endif
