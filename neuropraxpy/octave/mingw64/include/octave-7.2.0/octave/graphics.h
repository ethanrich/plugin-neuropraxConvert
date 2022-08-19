// DO NOT EDIT!  Generated automatically by genprops.awk.

////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2007-2022 The Octave Project Developers
//
// See the file COPYRIGHT.md in the top-level directory of this
// distribution or <https://octave.org/copyright/>.
//
// This file is part of Octave.
//
// Octave is free software: you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Octave is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Octave; see the file COPYING.  If not, see
// <https://www.gnu.org/licenses/>.
//
////////////////////////////////////////////////////////////////////////

#if ! defined (octave_graphics_h)
#define octave_graphics_h 1

#include "octave-config.h"

#include <cctype>
#include <cmath>

#include <algorithm>
#include <list>
#include <map>
#include <memory>
#include <set>
#include <sstream>
#include <string>
#include <unordered_map>
#include <vector>

#include "caseless-str.h"

#include "errwarn.h"
#include "graphics-handle.h"
#include "graphics-toolkit.h"
#include "oct-map.h"
#include "oct-mutex.h"
#include "oct-refcount.h"
#include "ov.h"
#include "text-renderer.h"

OCTAVE_NAMESPACE_BEGIN

// FIXME: maybe this should be a configure option?
// Matlab defaults to "Helvetica", but that causes problems for many
// gnuplot users.
#if ! defined (OCTAVE_DEFAULT_FONTNAME)
#define OCTAVE_DEFAULT_FONTNAME "*"
#endif

// ---------------------------------------------------------------------

class OCTINTERP_API base_scaler
{
public:
  base_scaler (void) { }

  virtual ~base_scaler (void) = default;

  virtual Matrix scale (const Matrix&) const
  {
    error ("invalid axis scale");
  }

  virtual NDArray scale (const NDArray&) const
  {
    error ("invalid axis scale");
  }

  virtual double scale (double) const
  {
    error ("invalid axis scale");
  }

  virtual double unscale (double) const
  {
    error ("invalid axis scale");
  }

  virtual base_scaler * clone () const
  { return new base_scaler (); }

  virtual bool is_linear (void) const
  { return false; }
};

class lin_scaler : public base_scaler
{
public:
  lin_scaler (void) { }

  Matrix scale (const Matrix& m) const { return m; }

  NDArray scale (const NDArray& m) const { return m; }

  double scale (double d) const { return d; }

  double unscale (double d) const { return d; }

  base_scaler * clone (void) const { return new lin_scaler (); }

  bool is_linear (void) const { return true; }
};

class log_scaler : public base_scaler
{
public:
  log_scaler (void) { }

  Matrix scale (const Matrix& m) const
  {
    Matrix retval (m.rows (), m.cols ());

    do_scale (m.data (), retval.fortran_vec (), m.numel ());

    return retval;
  }

  NDArray scale (const NDArray& m) const
  {
    NDArray retval (m.dims ());

    do_scale (m.data (), retval.fortran_vec (), m.numel ());

    return retval;
  }

  double scale (double d) const
  { return log10 (d); }

  double unscale (double d) const
  { return std::pow (10.0, d); }

  base_scaler * clone (void) const
  { return new log_scaler (); }

private:
  void do_scale (const double *src, double *dest, int n) const
  {
    for (int i = 0; i < n; i++)
      dest[i] = log10 (src[i]);
  }
};

class OCTINTERP_API neg_log_scaler : public base_scaler
{
public:
  neg_log_scaler (void) { }

  Matrix scale (const Matrix& m) const
  {
    Matrix retval (m.rows (), m.cols ());

    do_scale (m.data (), retval.fortran_vec (), m.numel ());

    return retval;
  }

  NDArray scale (const NDArray& m) const
  {
    NDArray retval (m.dims ());

    do_scale (m.data (), retval.fortran_vec (), m.numel ());

    return retval;
  }

  double scale (double d) const
  { return -log10 (-d); }

  double unscale (double d) const
  { return -std::pow (10.0, -d); }

  base_scaler * clone (void) const
  { return new neg_log_scaler (); }

private:
  void do_scale (const double *src, double *dest, int n) const
  {
    for (int i = 0; i < n; i++)
      dest[i] = -log10 (-src[i]);
  }
};

class OCTINTERP_API scaler
{
public:
  scaler (void) : m_rep (new base_scaler ()) { }

  scaler (const scaler& s) : m_rep (s.m_rep->clone ()) { }

  scaler (const std::string& s)
    : m_rep (s == "log"
             ? new log_scaler ()
             : (s == "neglog"
                ? new neg_log_scaler ()
                : (s == "linear"
                   ? new lin_scaler ()
                   : new base_scaler ())))
  { }

  ~scaler (void) { delete m_rep; }

  Matrix scale (const Matrix& m) const
  { return m_rep->scale (m); }

  NDArray scale (const NDArray& m) const
  { return m_rep->scale (m); }

  double scale (double d) const
  { return m_rep->scale (d); }

  double unscale (double d) const
  { return m_rep->unscale (d); }

  bool is_linear (void) const
  { return m_rep->is_linear (); }

  scaler& operator = (const scaler& s)
  {
    if (&s != this)
      {
        if (m_rep)
          {
            delete m_rep;
            m_rep = nullptr;
          }

        m_rep = s.m_rep->clone ();
      }

    return *this;
  }

  scaler& operator = (const std::string& s)
  {
    if (m_rep)
      {
        delete m_rep;
        m_rep = nullptr;
      }

    if (s == "log")
      m_rep = new log_scaler ();
    else if (s == "neglog")
      m_rep = new neg_log_scaler ();
    else if (s == "linear")
      m_rep = new lin_scaler ();
    else
      m_rep = new base_scaler ();

    return *this;
  }

private:
  base_scaler *m_rep;
};

// ---------------------------------------------------------------------

class OCTINTERP_API property;

// FIXME: These values should probably be defined inside a namespace or
// class, but which one is most appropriate?  For now, prefix with
// "GCB_" to avoid conflict with PERSISTENT token ID used in the lexer.
// The lexer token IDs should probably also be fixed...

enum listener_mode { GCB_POSTSET, GCB_PERSISTENT, GCB_PREDELETE };

class OCTINTERP_API base_property
{
public:
  friend class property;

public:
  base_property (void)
    : m_id (-1), m_count (1), m_name (), m_parent (), m_hidden (),
      m_listeners ()
  { }

  base_property (const std::string& s, const graphics_handle& h)
    : m_id (-1), m_count (1), m_name (s), m_parent (h), m_hidden (false),
      m_listeners ()
  { }

  base_property (const base_property& p)
    : m_id (-1), m_count (1), m_name (p.m_name), m_parent (p.m_parent),
      m_hidden (p.m_hidden), m_listeners ()
  { }

  virtual ~base_property (void) = default;

  bool ok (void) const { return m_parent.ok (); }

  std::string get_name (void) const { return m_name; }

  void set_name (const std::string& s) { m_name = s; }

  graphics_handle get_parent (void) const { return m_parent; }

  void set_parent (const graphics_handle& h) { m_parent = h; }

  bool is_hidden (void) const { return m_hidden; }

  void set_hidden (bool flag) { m_hidden = flag; }

  virtual bool is_radio (void) const { return false; }

  int get_id (void) const { return m_id; }

  void set_id (int d) { m_id = d; }

  // Sets property value, notifies graphics toolkit.
  // If do_run is true, runs associated listeners.
  OCTINTERP_API bool set (const octave_value& v, bool do_run = true,
                          bool do_notify_toolkit = true);

  virtual octave_value get (void) const
  {
    error (R"(get: invalid property "%s")", m_name.c_str ());
  }

  virtual std::string values_as_string (void) const
  {
    error (R"(values_as_string: invalid property "%s")", m_name.c_str ());
  }

  virtual Cell values_as_cell (void) const
  {
    error (R"(values_as_cell: invalid property "%s")", m_name.c_str ());
  }

  base_property& operator = (const octave_value& val)
  {
    set (val);
    return *this;
  }

  void add_listener (const octave_value& v, listener_mode mode = GCB_POSTSET)
  {
    octave_value_list& l = m_listeners[mode];
    l.resize (l.length () + 1, v);
  }

  void delete_listener (const octave_value& v = octave_value (),
                        listener_mode mode = GCB_POSTSET)
  {
    octave_value_list& l = m_listeners[mode];

    if (v.is_defined ())
      {
        bool found = false;
        int i;

        for (i = 0; i < l.length (); i++)
          {
            if (v.internal_rep () == l(i).internal_rep ())
              {
                found = true;
                break;
              }
          }
        if (found)
          {
            for (int j = i; j < l.length () - 1; j++)
              l(j) = l(j + 1);

            l.resize (l.length () - 1);
          }
      }
    else
      {
        if (mode == GCB_PERSISTENT)
          l.resize (0);
        else
          {
            octave_value_list lnew (0);
            octave_value_list& lp = m_listeners[GCB_PERSISTENT];
            for (int i = l.length () - 1; i >= 0 ; i--)
              {
                for (int j = 0; j < lp.length (); j++)
                  {
                    if (l(i).internal_rep () == lp(j).internal_rep ())
                      {
                        lnew.resize (lnew.length () + 1, l(i));
                        break;
                      }
                  }
              }
            l = lnew;
          }
      }

  }

  OCTINTERP_API void run_listeners (listener_mode mode = GCB_POSTSET);

  virtual base_property * clone (void) const
  { return new base_property (*this); }

protected:
  virtual bool do_set (const octave_value&)
  {
    error (R"(set: invalid property "%s")", m_name.c_str ());
  }

private:
  typedef std::map<listener_mode, octave_value_list> listener_map;
  typedef std::map<listener_mode, octave_value_list>::iterator
    listener_map_iterator;
  typedef std::map<listener_mode, octave_value_list>::const_iterator
    listener_map_const_iterator;

private:
  int m_id;
  octave::refcount<octave_idx_type> m_count;
  std::string m_name;
  graphics_handle m_parent;
  bool m_hidden;
  listener_map m_listeners;
};

// ---------------------------------------------------------------------

class OCTINTERP_API string_property : public base_property
{
public:
  string_property (const std::string& s, const graphics_handle& h,
                   const std::string& val = "")
    : base_property (s, h), m_str (val) { }

  string_property (const string_property& p)
    : base_property (p), m_str (p.m_str) { }

  octave_value get (void) const
  { return octave_value (m_str); }

  std::string string_value (void) const { return m_str; }

  string_property& operator = (const octave_value& val)
  {
    set (val);
    return *this;
  }

  base_property * clone (void) const { return new string_property (*this); }

protected:
  bool do_set (const octave_value& val)
  {
    if (! val.is_string ())
      error (R"(set: invalid string property value for "%s")",
             get_name ().c_str ());

    std::string new_str = val.string_value ();

    if (new_str != m_str)
      {
        m_str = new_str;
        return true;
      }
    return false;
  }

private:
  std::string m_str;
};

// ---------------------------------------------------------------------

class OCTINTERP_API string_array_property : public base_property
{
public:
  enum desired_enum { string_t, cell_t };

  string_array_property (const std::string& s, const graphics_handle& h,
                         const std::string& val = "", const char& sep = '|',
                         const desired_enum& typ = string_t)
    : base_property (s, h), m_desired_type (typ), m_separator (sep), m_str ()
  {
    std::size_t pos = 0;

    while (true)
      {
        std::size_t new_pos = val.find_first_of (m_separator, pos);

        if (new_pos == std::string::npos)
          {
            m_str.append (val.substr (pos));
            break;
          }
        else
          m_str.append (val.substr (pos, new_pos - pos));

        pos = new_pos + 1;
      }
  }

  string_array_property (const std::string& s, const graphics_handle& h,
                         const Cell& c, const char& sep = '|',
                         const desired_enum& typ = string_t)
    : base_property (s, h), m_desired_type (typ), m_separator (sep), m_str ()
  {
    if (! c.iscellstr ())
      error (R"(set: invalid order property value for "%s")",
             get_name ().c_str ());

    string_vector strings (c.numel ());

    for (octave_idx_type i = 0; i < c.numel (); i++)
      strings[i] = c(i).string_value ();

    m_str = strings;
  }

  string_array_property (const string_array_property& p)
    : base_property (p), m_desired_type (p.m_desired_type),
      m_separator (p.m_separator), m_str (p.m_str) { }

  octave_value get (void) const
  {
    if (m_desired_type == string_t)
      return octave_value (string_value ());
    else
      return octave_value (cell_value ());
  }

  std::string string_value (void) const
  {
    std::string s;

    for (octave_idx_type i = 0; i < m_str.numel (); i++)
      {
        s += m_str[i];
        if (i != m_str.numel () - 1)
          s += m_separator;
      }

    return s;
  }

  Cell cell_value (void) const {return Cell (m_str);}

  string_vector string_vector_value (void) const { return m_str; }

  string_array_property& operator = (const octave_value& val)
  {
    set (val);
    return *this;
  }

  base_property * clone (void) const
  { return new string_array_property (*this); }

protected:
  bool do_set (const octave_value& val)
  {
    if (val.is_string () && val.rows () == 1)
      {
        bool replace = false;
        std::string new_str = val.string_value ();
        string_vector strings;
        std::size_t pos = 0;

        // Split single string on delimiter (usually '|')
        while (pos != std::string::npos)
          {
            std::size_t new_pos = new_str.find_first_of (m_separator, pos);

            if (new_pos == std::string::npos)
              {
                strings.append (new_str.substr (pos));
                break;
              }
            else
              strings.append (new_str.substr (pos, new_pos - pos));

            pos = new_pos + 1;
          }

        if (m_str.numel () == strings.numel ())
          {
            for (octave_idx_type i = 0; i < m_str.numel (); i++)
              if (strings[i] != m_str[i])
                {
                  replace = true;
                  break;
                }
          }
        else
          replace = true;

        m_desired_type = string_t;

        if (replace)
          {
            m_str = strings;
            return true;
          }
      }
    else if (val.is_string ())  // multi-row character matrix
      {
        bool replace = false;
        charMatrix chm = val.char_matrix_value ();
        octave_idx_type nel = chm.rows ();
        string_vector strings (nel);

        if (nel != m_str.numel ())
          replace = true;
        for (octave_idx_type i = 0; i < nel; i++)
          {
            strings[i] = chm.row_as_string (i);
            if (! replace && strings[i] != m_str[i])
              replace = true;
          }

        m_desired_type = string_t;

        if (replace)
          {
            m_str = strings;
            return true;
          }
      }
    else if (val.iscellstr ())
      {
        bool replace = false;
        Cell new_cell = val.cell_value ();

        string_vector strings = new_cell.cellstr_value ();

        octave_idx_type nel = strings.numel ();

        if (nel != m_str.numel ())
          replace = true;
        else
          {
            for (octave_idx_type i = 0; i < nel; i++)
              {
                if (strings[i] != m_str[i])
                  {
                    replace = true;
                    break;
                  }
              }
          }

        m_desired_type = cell_t;

        if (replace)
          {
            m_str = strings;
            return true;
          }
      }
    else
      error (R"(set: invalid string property value for "%s")",
             get_name ().c_str ());

    return false;
  }

private:
  desired_enum m_desired_type;
  char m_separator;
  string_vector m_str;
};

// ---------------------------------------------------------------------

class OCTINTERP_API text_label_property : public base_property
{
public:
  enum type { char_t, cellstr_t };

  text_label_property (const std::string& s, const graphics_handle& h,
                       const std::string& val = "")
    : base_property (s, h), m_value (val), m_stored_type (char_t)
  { }

  text_label_property (const std::string& s, const graphics_handle& h,
                       const NDArray& nda)
    : base_property (s, h), m_stored_type (char_t)
  {
    octave_idx_type nel = nda.numel ();

    m_value.resize (nel);

    for (octave_idx_type i = 0; i < nel; i++)
      {
        std::ostringstream buf;
        buf << nda(i);
        m_value[i] = buf.str ();
      }
  }

  text_label_property (const std::string& s, const graphics_handle& h,
                       const Cell& c)
    : base_property (s, h), m_stored_type (cellstr_t)
  {
    octave_idx_type nel = c.numel ();

    m_value.resize (nel);

    for (octave_idx_type i = 0; i < nel; i++)
      {
        octave_value tmp = c(i);

        if (tmp.is_string ())
          m_value[i] = c(i).string_value ();
        else
          {
            double d = c(i).double_value ();

            std::ostringstream buf;
            buf << d;
            m_value[i] = buf.str ();
          }
      }
  }

  text_label_property (const text_label_property& p)
    : base_property (p), m_value (p.m_value), m_stored_type (p.m_stored_type)
  { }

  bool empty (void) const
  {
    octave_value tmp = get ();
    return tmp.isempty ();
  }

  octave_value get (void) const
  {
    if (m_stored_type == char_t)
      return octave_value (char_value ());
    else
      return octave_value (cell_value ());
  }

  std::string string_value (void) const
  {
    return m_value.empty () ? "" : m_value[0];
  }

  string_vector string_vector_value (void) const { return m_value; }

  charMatrix char_value (void) const { return charMatrix (m_value, ' '); }

  Cell cell_value (void) const {return Cell (m_value); }

  text_label_property& operator = (const octave_value& val)
  {
    set (val);
    return *this;
  }

  base_property * clone (void) const { return new text_label_property (*this); }

protected:

  bool do_set (const octave_value& val)
  {
    if (val.is_string ())
      {
        m_value = val.string_vector_value ();

        m_stored_type = char_t;
      }
    else if (val.iscell ())
      {
        Cell c = val.cell_value ();

        octave_idx_type nel = c.numel ();

        m_value.resize (nel);

        for (octave_idx_type i = 0; i < nel; i++)
          {
            octave_value tmp = c(i);

            if (tmp.is_string ())
              m_value[i] = c(i).string_value ();
            else
              {
                double d = c(i).double_value ();

                std::ostringstream buf;
                buf << d;
                m_value[i] = buf.str ();
              }
          }

        m_stored_type = cellstr_t;
      }
    else
      {
        NDArray nda;

        try
          {
            nda = val.array_value ();
          }
        catch (octave::execution_exception& ee)
          {
            error (ee, R"(set: invalid string property value for "%s")",
                   get_name ().c_str ());
          }

        octave_idx_type nel = nda.numel ();

        m_value.resize (nel);

        for (octave_idx_type i = 0; i < nel; i++)
          {
            std::ostringstream buf;
            buf << nda(i);
            m_value[i] = buf.str ();
          }

        m_stored_type = char_t;
      }

    return true;
  }

private:
  string_vector m_value;
  type m_stored_type;
};

// ---------------------------------------------------------------------

class OCTINTERP_API radio_values
{
public:
  OCTINTERP_API radio_values (const std::string& opt_string = "");

  radio_values (const radio_values& a)
    : m_default_val (a.m_default_val), m_possible_vals (a.m_possible_vals) { }

  radio_values& operator = (const radio_values& a)
  {
    if (&a != this)
      {
        m_default_val = a.m_default_val;
        m_possible_vals = a.m_possible_vals;
      }

    return *this;
  }

  std::string default_value (void) const { return m_default_val; }

  bool validate (const std::string& val, std::string& match)
  {
    bool retval = true;

    if (! contains (val, match))
      error ("invalid value = %s", val.c_str ());

    return retval;
  }

  bool contains (const std::string& val, std::string& match)
  {
    std::size_t k = 0;

    std::size_t len = val.length ();

    std::string first_match;

    for (const auto& possible_val : m_possible_vals)
      {
        if (possible_val.compare (val, len))
          {
            if (len == possible_val.length ())
              {
                // We found a full match (consider the case of val == "replace"
                // with possible values "replace" and "replacechildren").  Any
                // other matches are irrelevant, so set match and return now.
                match = possible_val;
                return true;
              }
            else
              {
                if (k == 0)
                  first_match = possible_val;

                k++;
              }
          }
      }

    if (k == 1)
      {
        match = first_match;
        return true;
      }
    else
      return false;
  }

  OCTINTERP_API std::string values_as_string (void) const;

  OCTINTERP_API Cell values_as_cell (void) const;

  octave_idx_type nelem (void) const { return m_possible_vals.size (); }

private:
  // Might also want to cache
  std::string m_default_val;
  std::set<caseless_str> m_possible_vals;
};

class OCTINTERP_API radio_property : public base_property
{
public:
  radio_property (const std::string& nm, const graphics_handle& h,
                  const radio_values& v = radio_values ())
    : base_property (nm, h),
      m_vals (v), m_current_val (v.default_value ()) { }

  radio_property (const std::string& nm, const graphics_handle& h,
                  const std::string& v)
    : base_property (nm, h),
      m_vals (v), m_current_val (m_vals.default_value ()) { }

  radio_property (const std::string& nm, const graphics_handle& h,
                  const radio_values& v, const std::string& def)
    : base_property (nm, h),
      m_vals (v), m_current_val (def) { }

  radio_property (const radio_property& p)
    : base_property (p), m_vals (p.m_vals), m_current_val (p.m_current_val) { }

  octave_value get (void) const { return octave_value (m_current_val); }

  const std::string& current_value (void) const { return m_current_val; }

  std::string values_as_string (void) const { return m_vals.values_as_string (); }

  Cell values_as_cell (void) const { return m_vals.values_as_cell (); }

  bool is (const caseless_str& v) const
  { return v.compare (m_current_val); }

  bool is_radio (void) const { return true; }

  radio_property& operator = (const octave_value& val)
  {
    set (val);
    return *this;
  }

  base_property * clone (void) const { return new radio_property (*this); }

protected:
  bool do_set (const octave_value& newval)
  {
    if (! newval.is_string ())
      error (R"(set: invalid value for radio property "%s")",
             get_name ().c_str ());

    std::string s = newval.string_value ();

    std::string match;

    if (! m_vals.validate (s, match))
      error (R"(set: invalid value for radio property "%s" (value = %s))",
             get_name ().c_str (), s.c_str ());

    if (match != m_current_val)
      {
        if (s.length () != match.length ())
          warning_with_id ("Octave:abbreviated-property-match",
                           "%s: allowing %s to match %s value %s",
                           "set", s.c_str (), get_name ().c_str (),
                           match.c_str ());
        m_current_val = match;
        return true;
      }
    return false;
  }

private:
  radio_values m_vals;
  std::string m_current_val;
};

// ---------------------------------------------------------------------

class OCTINTERP_API color_values
{
public:
  color_values (double r = 0, double g = 0, double b = 1)
    : m_rgb (1, 3)
  {
    m_rgb(0) = r;
    m_rgb(1) = g;
    m_rgb(2) = b;

    validate ();
  }

  color_values (const std::string& str)
    : m_rgb (1, 3)
  {
    if (! str2rgb (str))
      error ("invalid color specification: %s", str.c_str ());
  }

  color_values (const color_values& c)
    : m_rgb (c.m_rgb)
  { }

  color_values& operator = (const color_values& c)
  {
    if (&c != this)
      m_rgb = c.m_rgb;

    return *this;
  }

  bool operator == (const color_values& c) const
  {
    return (m_rgb(0) == c.m_rgb(0)
            && m_rgb(1) == c.m_rgb(1)
            && m_rgb(2) == c.m_rgb(2));
  }

  bool operator != (const color_values& c) const
  { return ! (*this == c); }

  Matrix rgb (void) const { return m_rgb; }

  operator octave_value (void) const { return m_rgb; }

  void validate (void) const
  {
    for (int i = 0; i < 3; i++)
      {
        if (m_rgb(i) < 0 ||  m_rgb(i) > 1)
          error ("invalid RGB color specification");
      }
  }

private:
  Matrix m_rgb;

  OCTINTERP_API bool str2rgb (const std::string& str);
};

class OCTINTERP_API color_property : public base_property
{
public:
  color_property (const color_values& c, const radio_values& v)
    : base_property ("", graphics_handle ()),
      m_current_type (color_t), m_color_val (c), m_radio_val (v),
      m_current_val (v.default_value ())
  { }

  color_property (const radio_values& v, const color_values& c)
    : base_property ("", graphics_handle ()),
      m_current_type (radio_t), m_color_val (c), m_radio_val (v),
      m_current_val (v.default_value ())
  { }

  color_property (const std::string& nm, const graphics_handle& h,
                  const color_values& c = color_values (),
                  const radio_values& v = radio_values ())
    : base_property (nm, h),
      m_current_type (color_t), m_color_val (c), m_radio_val (v),
      m_current_val (v.default_value ())
  { }

  color_property (const std::string& nm, const graphics_handle& h,
                  const radio_values& v)
    : base_property (nm, h),
      m_current_type (radio_t), m_color_val (color_values ()), m_radio_val (v),
      m_current_val (v.default_value ())
  { }

  color_property (const std::string& nm, const graphics_handle& h,
                  const std::string& v)
    : base_property (nm, h),
      m_current_type (radio_t), m_color_val (color_values ()), m_radio_val (v),
      m_current_val (m_radio_val.default_value ())
  { }

  color_property (const std::string& nm, const graphics_handle& h,
                  const color_property& v)
    : base_property (nm, h),
      m_current_type (v.m_current_type), m_color_val (v.m_color_val),
      m_radio_val (v.m_radio_val), m_current_val (v.m_current_val)
  { }

  color_property (const color_property& p)
    : base_property (p), m_current_type (p.m_current_type),
      m_color_val (p.m_color_val), m_radio_val (p.m_radio_val),
      m_current_val (p.m_current_val) { }

  octave_value get (void) const
  {
    if (m_current_type == color_t)
      return m_color_val.rgb ();

    return m_current_val;
  }

  bool is_rgb (void) const { return (m_current_type == color_t); }

  bool is_radio (void) const { return (m_current_type == radio_t); }

  bool is (const std::string& v) const
  { return (is_radio () && m_current_val == v); }

  Matrix rgb (void) const
  {
    if (m_current_type != color_t)
      error ("color has no RGB value");

    return m_color_val.rgb ();
  }

  const std::string& current_value (void) const
  {
    if (m_current_type != radio_t)
      error ("color has no radio value");

    return m_current_val;
  }

  color_property& operator = (const octave_value& val)
  {
    set (val);
    return *this;
  }

  operator octave_value (void) const { return get (); }

  base_property * clone (void) const { return new color_property (*this); }

  std::string values_as_string (void) const
  { return m_radio_val.values_as_string (); }

  Cell values_as_cell (void) const { return m_radio_val.values_as_cell (); }

protected:
  OCTINTERP_API bool do_set (const octave_value& newval);

private:
  enum current_enum { color_t, radio_t } m_current_type;
  color_values m_color_val;
  radio_values m_radio_val;
  std::string m_current_val;
};

// ---------------------------------------------------------------------

enum finite_type
{
  NO_CHECK,
  FINITE,
  NOT_NAN,
  NOT_INF
};

class OCTINTERP_API double_property : public base_property
{
public:
  double_property (const std::string& nm, const graphics_handle& h,
                   double d = 0)
    : base_property (nm, h),
      m_current_val (d), m_finite_constraint (NO_CHECK),
      m_minval (std::pair<double, bool> (octave_NaN, true)),
      m_maxval (std::pair<double, bool> (octave_NaN, true)) { }

  double_property (const double_property& p)
    : base_property (p), m_current_val (p.m_current_val),
      m_finite_constraint (NO_CHECK),
      m_minval (std::pair<double, bool> (octave_NaN, true)),
      m_maxval (std::pair<double, bool> (octave_NaN, true)) { }

  octave_value get (void) const { return octave_value (m_current_val); }

  double double_value (void) const { return m_current_val; }

  double_property& operator = (const octave_value& val)
  {
    set (val);
    return *this;
  }

  base_property * clone (void) const
  {
    double_property *p = new double_property (*this);

    p->m_finite_constraint = m_finite_constraint;
    p->m_minval = m_minval;
    p->m_maxval = m_maxval;

    return p;
  }

  void add_constraint (const std::string& type, double val, bool inclusive)
  {
    if (type == "min")
      m_minval = std::pair<double, bool> (val, inclusive);
    else if (type == "max")
      m_maxval = std::pair<double, bool> (val, inclusive);
  }

  void add_constraint (const finite_type finite)
  { m_finite_constraint = finite; }

protected:
  bool do_set (const octave_value& v)
  {
    if (! v.is_scalar_type () || ! v.isreal ())
      error (R"(set: invalid value for double property "%s")",
             get_name ().c_str ());

    double new_val = v.double_value ();

    // Check min and max
    if (! octave::math::isnan (m_minval.first))
      {
        if (m_minval.second && m_minval.first > new_val)
          error (R"(set: "%s" must be greater than or equal to %g)",
                 get_name ().c_str (), m_minval.first);
        else if (! m_minval.second && m_minval.first >= new_val)
          error (R"(set: "%s" must be greater than %g)",
                 get_name ().c_str (), m_minval.first);
      }

    if (! octave::math::isnan (m_maxval.first))
      {
        if (m_maxval.second && m_maxval.first < new_val)
          error (R"(set: "%s" must be less than or equal to %g)",
                 get_name ().c_str (), m_maxval.first);
        else if (! m_maxval.second && m_maxval.first <= new_val)
          error (R"(set: "%s" must be less than %g)",
                 get_name ().c_str (), m_maxval.first);
      }

    if (m_finite_constraint == NO_CHECK) { /* do nothing */ }
    else if (m_finite_constraint == FINITE)
      {
        if (! octave::math::isfinite (new_val))
          error (R"(set: "%s" must be finite)", get_name ().c_str ());
      }
    else if (m_finite_constraint == NOT_NAN)
      {
        if (octave::math::isnan (new_val))
          error (R"(set: "%s" must not be nan)", get_name ().c_str ());
      }
    else if (m_finite_constraint == NOT_INF)
      {
        if (octave::math::isinf (new_val))
          error (R"(set: "%s" must not be infinite)", get_name ().c_str ());
      }

    if (new_val != m_current_val)
      {
        m_current_val = new_val;
        return true;
      }

    return false;
  }

private:
  double m_current_val;
  finite_type m_finite_constraint;
  std::pair<double, bool> m_minval, m_maxval;
};

// ---------------------------------------------------------------------

class OCTINTERP_API double_radio_property : public base_property
{
public:
  double_radio_property (double d, const radio_values& v)
    : base_property ("", graphics_handle ()),
      m_current_type (double_t), m_dval (d), m_radio_val (v),
      m_current_val (v.default_value ())
  { }

  double_radio_property (const std::string& nm, const graphics_handle& h,
                         const std::string& v)
    : base_property (nm, h),
      m_current_type (radio_t), m_dval (0), m_radio_val (v),
      m_current_val (m_radio_val.default_value ())
  { }

  double_radio_property (const std::string& nm, const graphics_handle& h,
                         const double_radio_property& v)
    : base_property (nm, h),
      m_current_type (v.m_current_type), m_dval (v.m_dval),
      m_radio_val (v.m_radio_val), m_current_val (v.m_current_val)
  { }

  double_radio_property (const double_radio_property& p)
    : base_property (p), m_current_type (p.m_current_type),
      m_dval (p.m_dval), m_radio_val (p.m_radio_val),
      m_current_val (p.m_current_val) { }

  octave_value get (void) const
  {
    if (m_current_type == double_t)
      return m_dval;

    return m_current_val;
  }

  bool is_double (void) const { return (m_current_type == double_t); }

  bool is_radio (void) const { return (m_current_type == radio_t); }

  bool is (const std::string& v) const
  { return (is_radio () && m_current_val == v); }

  double double_value (void) const
  {
    if (m_current_type != double_t)
      error ("%s: property has no double", get_name ().c_str ());

    return m_dval;
  }

  const std::string& current_value (void) const
  {
    if (m_current_type != radio_t)
      error ("%s: property has no radio value", get_name ().c_str ());

    return m_current_val;
  }

  double_radio_property& operator = (const octave_value& val)
  {
    set (val);
    return *this;
  }

  operator octave_value (void) const { return get (); }

  base_property * clone (void) const
  { return new double_radio_property (*this); }

protected:
  OCTINTERP_API bool do_set (const octave_value& v);

private:
  enum current_enum { double_t, radio_t } m_current_type;
  double m_dval;
  radio_values m_radio_val;
  std::string m_current_val;
};

// ---------------------------------------------------------------------

class OCTINTERP_API array_property : public base_property
{
public:
  array_property (void)
    : base_property ("", graphics_handle ()), m_data (Matrix ()),
      m_min_val (), m_max_val (), m_min_pos (), m_max_neg (),
      m_type_constraints (), m_size_constraints (), m_finite_constraint (NO_CHECK),
      m_minval (std::pair<double, bool> (octave_NaN, true)),
      m_maxval (std::pair<double, bool> (octave_NaN, true))
  {
    get_data_limits ();
  }

  array_property (const std::string& nm, const graphics_handle& h,
                  const octave_value& m)
    : base_property (nm, h), m_data (m.issparse () ? m.full_value () : m),
      m_min_val (), m_max_val (), m_min_pos (), m_max_neg (),
      m_type_constraints (), m_size_constraints (), m_finite_constraint (NO_CHECK),
      m_minval (std::pair<double, bool> (octave_NaN, true)),
      m_maxval (std::pair<double, bool> (octave_NaN, true))
  {
    get_data_limits ();
  }

  // This copy constructor is only intended to be used
  // internally to access min/max values; no need to
  // copy constraints.
  array_property (const array_property& p)
    : base_property (p), m_data (p.m_data),
      m_min_val (p.m_min_val), m_max_val (p.m_max_val), m_min_pos (p.m_min_pos), m_max_neg (p.m_max_neg),
      m_type_constraints (), m_size_constraints (), m_finite_constraint (NO_CHECK),
      m_minval (std::pair<double, bool> (octave_NaN, true)),
      m_maxval (std::pair<double, bool> (octave_NaN, true))
  { }

  octave_value get (void) const { return m_data; }

  void add_constraint (const std::string& type)
  { m_type_constraints.insert (type); }

  void add_constraint (const dim_vector& dims)
  { m_size_constraints.push_back (dims); }

  void add_constraint (const finite_type finite)
  { m_finite_constraint = finite; }

  void add_constraint (const std::string& type, double val, bool inclusive)
  {
    if (type == "min")
      m_minval = std::pair<double, bool> (val, inclusive);
    else if (type == "max")
      m_maxval = std::pair<double, bool> (val, inclusive);
  }

  double min_val (void) const { return m_min_val; }
  double max_val (void) const { return m_max_val; }
  double min_pos (void) const { return m_min_pos; }
  double max_neg (void) const { return m_max_neg; }

  Matrix get_limits (void) const
  {
    Matrix m (1, 4);

    m(0) = min_val ();
    m(1) = max_val ();
    m(2) = min_pos ();
    m(3) = max_neg ();

    return m;
  }

  array_property& operator = (const octave_value& val)
  {
    set (val);
    return *this;
  }

  base_property * clone (void) const
  {
    array_property *p = new array_property (*this);

    p->m_type_constraints = m_type_constraints;
    p->m_size_constraints = m_size_constraints;
    p->m_finite_constraint = m_finite_constraint;
    p->m_minval = m_minval;
    p->m_maxval = m_maxval;

    return p;
  }

protected:
  bool do_set (const octave_value& v)
  {
    octave_value tmp = (v.issparse () ? v.full_value () : v);

    if (! validate (tmp))
      error (R"(invalid value for array property "%s")",
             get_name ().c_str ());

    // FIXME: should we check for actual data change?
    if (! is_equal (tmp))
      {
        m_data = tmp;

        get_data_limits ();

        return true;
      }

    return false;
  }

private:
  OCTINTERP_API bool validate (const octave_value& v);

  OCTINTERP_API bool is_equal (const octave_value& v) const;

  OCTINTERP_API void get_data_limits (void);

protected:
  octave_value m_data;
  double m_min_val;
  double m_max_val;
  double m_min_pos;
  double m_max_neg;
  std::set<std::string> m_type_constraints;
  std::list<dim_vector> m_size_constraints;
  finite_type m_finite_constraint;
  std::pair<double, bool> m_minval, m_maxval;
};

class OCTINTERP_API row_vector_property : public array_property
{
public:
  row_vector_property (const std::string& nm, const graphics_handle& h,
                       const octave_value& m)
    : array_property (nm, h, m)
  {
    add_constraint (dim_vector (-1, 1));
    add_constraint (dim_vector (1, -1));
    add_constraint (dim_vector (0, 0));
  }

  row_vector_property (const row_vector_property& p)
    : array_property (p)
  {
    add_constraint (dim_vector (-1, 1));
    add_constraint (dim_vector (1, -1));
    add_constraint (dim_vector (0, 0));
  }

  void add_constraint (const std::string& type)
  {
    array_property::add_constraint (type);
  }

  void add_constraint (const dim_vector& dims)
  {
    array_property::add_constraint (dims);
  }

  void add_constraint (const finite_type finite)
  {
    array_property::add_constraint (finite);
  }

  void add_constraint (const std::string& type, double val, bool inclusive)
  {
    array_property::add_constraint (type, val, inclusive);
  }

  void add_constraint (octave_idx_type len)
  {
    m_size_constraints.remove (dim_vector (1, -1));
    m_size_constraints.remove (dim_vector (-1, 1));
    m_size_constraints.remove (dim_vector (0, 0));

    add_constraint (dim_vector (1, len));
    add_constraint (dim_vector (len, 1));
  }

  row_vector_property& operator = (const octave_value& val)
  {
    set (val);
    return *this;
  }

  base_property * clone (void) const
  {
    row_vector_property *p = new row_vector_property (*this);

    p->m_type_constraints = m_type_constraints;
    p->m_size_constraints = m_size_constraints;
    p->m_finite_constraint = m_finite_constraint;
    p->m_minval = m_minval;
    p->m_maxval = m_maxval;

    return p;
  }

protected:
  bool do_set (const octave_value& v)
  {
    bool retval = array_property::do_set (v);

    dim_vector dv = m_data.dims ();

    if (dv(0) > 1 && dv(1) == 1)
      {
        int tmp = dv(0);
        dv(0) = dv(1);
        dv(1) = tmp;

        m_data = m_data.reshape (dv);
      }

    return retval;
  }

private:
  OCTINTERP_API bool validate (const octave_value& v);
};

// ---------------------------------------------------------------------

class OCTINTERP_API bool_property : public radio_property
{
public:
  bool_property (const std::string& nm, const graphics_handle& h,
                 bool val)
    : radio_property (nm, h, radio_values (val ? "{on}|off" : "on|{off}"))
  { }

  bool_property (const std::string& nm, const graphics_handle& h,
                 const char *val)
    : radio_property (nm, h, radio_values (std::string (val) == "on" ?
                                           "{on}|off" : "on|{off}"), val)
  { }

  bool_property (const bool_property& p)
    : radio_property (p) { }

  bool is_on (void) const { return is ("on"); }

  bool_property& operator = (const octave_value& val)
  {
    set (val);
    return *this;
  }

  base_property * clone (void) const { return new bool_property (*this); }

protected:
  bool do_set (const octave_value& val)
  {
    if (val.is_bool_scalar ())
      return radio_property::do_set (val.bool_value () ? "on" : "off");
    else
      return radio_property::do_set (val);
  }
};

// ---------------------------------------------------------------------

class OCTINTERP_API handle_property : public base_property
{
public:
  handle_property (const std::string& nm, const graphics_handle& h,
                   const graphics_handle& val = graphics_handle ())
    : base_property (nm, h),
      m_current_val (val) { }

  handle_property (const handle_property& p)
    : base_property (p), m_current_val (p.m_current_val) { }

  octave_value get (void) const { return m_current_val.as_octave_value (); }

  graphics_handle handle_value (void) const { return m_current_val; }

  handle_property& operator = (const octave_value& val)
  {
    set (val);
    return *this;
  }

  handle_property& operator = (const graphics_handle& h)
  {
    set (octave_value (h.value ()));
    return *this;
  }

  void invalidate (void)
  { m_current_val = octave::numeric_limits<double>::NaN (); }

  base_property * clone (void) const { return new handle_property (*this); }

  void add_constraint (const std::string& type)
  { m_type_constraints.insert (type); }

protected:
  OCTINTERP_API bool do_set (const octave_value& v);
  std::set<std::string> m_type_constraints;

private:
  graphics_handle m_current_val;
};

// ---------------------------------------------------------------------

class OCTINTERP_API any_property : public base_property
{
public:
  any_property (const std::string& nm, const graphics_handle& h,
                const octave_value& m = Matrix ())
    : base_property (nm, h), m_data (m) { }

  any_property (const any_property& p)
    : base_property (p), m_data (p.m_data) { }

  octave_value get (void) const { return m_data; }

  any_property& operator = (const octave_value& val)
  {
    set (val);
    return *this;
  }

  base_property * clone (void) const { return new any_property (*this); }

protected:
  bool do_set (const octave_value& v)
  {
    m_data = v;
    return true;
  }

private:
  octave_value m_data;
};

// ---------------------------------------------------------------------

class OCTINTERP_API children_property : public base_property
{
public:
  children_property (void)
    : base_property ("", graphics_handle ()), m_children_list ()
  {
    do_init_children (Matrix ());
  }

  children_property (const std::string& nm, const graphics_handle& h,
                     const Matrix& val)
    : base_property (nm, h), m_children_list ()
  {
    do_init_children (val);
  }

  children_property (const children_property& p)
    : base_property (p), m_children_list ()
  {
    do_init_children (p.m_children_list);
  }

  children_property& operator = (const octave_value& val)
  {
    set (val);
    return *this;
  }

  base_property * clone (void) const { return new children_property (*this); }

  bool remove_child (double val)
  {
    return do_remove_child (val);
  }

  void adopt (double val)
  {
    do_adopt_child (val);
  }

  Matrix get_children (void) const
  {
    return do_get_children (false);
  }

  Matrix get_hidden (void) const
  {
    return do_get_children (true);
  }

  Matrix get_all (void) const
  {
    return do_get_all_children ();
  }

  octave_value get (void) const
  {
    return octave_value (get_children ());
  }

  void delete_children (bool clear = false, bool from_root = false)
  {
    do_delete_children (clear, from_root);
  }

  void renumber (graphics_handle old_gh, graphics_handle new_gh)
  {
    for (auto& hchild : m_children_list)
      {
        if (hchild == old_gh)
          {
            hchild = new_gh.value ();
            return;
          }
      }

    error ("children_list::renumber: child not found!");
  }

private:
  typedef std::list<double>::iterator children_list_iterator;
  typedef std::list<double>::const_iterator const_children_list_iterator;
  std::list<double> m_children_list;

protected:
  bool do_set (const octave_value& val)
  {
    Matrix new_kids;

    try
      {
        new_kids = val.matrix_value ();
      }
    catch (octave::execution_exception& ee)
      {
        error (ee, "set: children must be an array of graphics handles");
      }

    octave_idx_type nel = new_kids.numel ();

    const Matrix new_kids_column = new_kids.reshape (dim_vector (nel, 1));

    bool is_ok = true;
    bool add_hidden = true;

    const Matrix visible_kids = do_get_children (false);

    if (visible_kids.numel () == new_kids.numel ())
      {
        Matrix t1 = visible_kids.sort ();
        Matrix t2 = new_kids_column.sort ();
        Matrix t3 = get_hidden ().sort ();

        if (t1 != t2)
          is_ok = false;

        if (t1 == t3)
          add_hidden = false;
      }
    else
      is_ok = false;

    if (! is_ok)
      error ("set: new children must be a permutation of existing children");

    Matrix tmp = new_kids_column;

    if (add_hidden)
      tmp.stack (get_hidden ());

    m_children_list.clear ();

    // Don't use do_init_children here, as that reverses the
    // order of the list, and we don't want to do that if setting
    // the child list directly.
    for (octave_idx_type i = 0; i < tmp.numel (); i++)
      m_children_list.push_back (tmp.xelem (i));

    return is_ok;
  }

private:
  void do_init_children (const Matrix& val)
  {
    m_children_list.clear ();
    for (octave_idx_type i = 0; i < val.numel (); i++)
      m_children_list.push_front (val.xelem (i));
  }

  void do_init_children (const std::list<double>& val)
  {
    m_children_list.clear ();
    m_children_list = val;
  }

  OCTINTERP_API Matrix do_get_children (bool return_hidden) const;

  Matrix do_get_all_children (void) const
  {
    Matrix retval (m_children_list.size (), 1);
    octave_idx_type i = 0;

    for (const auto& hchild : m_children_list)
      retval(i++) = hchild;

    return retval;
  }

  bool do_remove_child (double child)
  {
    for (auto it = m_children_list.begin (); it != m_children_list.end (); it++)
      {
        if (*it == child)
          {
            m_children_list.erase (it);
            return true;
          }
      }
    return false;
  }

  void do_adopt_child (double val)
  {
    m_children_list.push_front (val);
  }

  void do_delete_children (bool clear, bool from_root);
};

// ---------------------------------------------------------------------

class OCTINTERP_API callback_property : public base_property
{
public:
  callback_property (const std::string& nm, const graphics_handle& h,
                     const octave_value& m)
    : base_property (nm, h), m_callback (m) { }

  callback_property (const callback_property& p)
    : base_property (p), m_callback (p.m_callback) { }

  octave_value get (void) const { return m_callback; }

  OCTINTERP_API void execute (const octave_value& data = octave_value ()) const;

  bool is_defined (void) const
  {
    return (m_callback.is_defined () && ! m_callback.isempty ());
  }

  callback_property& operator = (const octave_value& val)
  {
    set (val);
    return *this;
  }

  base_property * clone (void) const { return new callback_property (*this); }

protected:
  bool do_set (const octave_value& v)
  {
    if (! validate (v))
      error (R"(invalid value for callback property "%s")",
             get_name ().c_str ());

    m_callback = v;
    return true;
    return false;
  }

private:
  OCTINTERP_API bool validate (const octave_value& v) const;

private:
  octave_value m_callback;
};

// ---------------------------------------------------------------------

class OCTINTERP_API property
{
public:
  property (void) : m_rep (new base_property ("", graphics_handle ()))
  { }

  property (base_property *bp, bool persist = false) : m_rep (bp)
  { if (persist) m_rep->m_count++; }

  property (const property& p) : m_rep (p.m_rep)
  {
    m_rep->m_count++;
  }

  ~property (void)
  {
    if (--m_rep->m_count == 0)
      delete m_rep;
  }

  bool ok (void) const
  { return m_rep->ok (); }

  std::string get_name (void) const
  { return m_rep->get_name (); }

  void set_name (const std::string& name)
  { m_rep->set_name (name); }

  graphics_handle get_parent (void) const
  { return m_rep->get_parent (); }

  void set_parent (const graphics_handle& h)
  { m_rep->set_parent (h); }

  bool is_hidden (void) const
  { return m_rep->is_hidden (); }

  void set_hidden (bool flag)
  { m_rep->set_hidden (flag); }

  bool is_radio (void) const
  { return m_rep->is_radio (); }

  int get_id (void) const
  { return m_rep->get_id (); }

  void set_id (int d)
  { m_rep->set_id (d); }

  octave_value get (void) const
  { return m_rep->get (); }

  bool set (const octave_value& val, bool do_run = true,
            bool do_notify_toolkit = true)
  { return m_rep->set (val, do_run, do_notify_toolkit); }

  std::string values_as_string (void) const
  { return m_rep->values_as_string (); }

  Cell values_as_cell (void) const
  { return m_rep->values_as_cell (); }

  property& operator = (const octave_value& val)
  {
    *m_rep = val;
    return *this;
  }

  property& operator = (const property& p)
  {
    if (m_rep && --m_rep->m_count == 0)
      delete m_rep;

    m_rep = p.m_rep;
    m_rep->m_count++;

    return *this;
  }

  void add_listener (const octave_value& v, listener_mode mode = GCB_POSTSET)
  { m_rep->add_listener (v, mode); }

  void delete_listener (const octave_value& v = octave_value (),
                        listener_mode mode = GCB_POSTSET)
  { m_rep->delete_listener (v, mode); }

  void run_listeners (listener_mode mode = GCB_POSTSET)
  { m_rep->run_listeners (mode); }

  static OCTINTERP_API property
  create (const std::string& name, const graphics_handle& parent,
          const caseless_str& type, const octave_value_list& args);

  property clone (void) const
  { return property (m_rep->clone ()); }

#if 0
  const string_property& as_string_property (void) const
  { return *(dynamic_cast<string_property *> (m_rep)); }

  const radio_property& as_radio_property (void) const
  { return *(dynamic_cast<radio_property *> (m_rep)); }

  const color_property& as_color_property (void) const
  { return *(dynamic_cast<color_property *> (m_rep)); }

  const double_property& as_double_property (void) const
  { return *(dynamic_cast<double_property *> (m_rep)); }

  const bool_property& as_bool_property (void) const
  { return *(dynamic_cast<bool_property *> (m_rep)); }

  const handle_property& as_handle_property (void) const
  { return *(dynamic_cast<handle_property *> (m_rep)); }
#endif

private:
  base_property *m_rep;
};

// ---------------------------------------------------------------------

typedef std::pair<std::string, octave_value> pval_pair;

class OCTINTERP_API pval_vector : public std::vector<pval_pair>
{
public:
  const_iterator find (const std::string pname) const
  {
    const_iterator it;

    for (it = (*this).begin (); it != (*this).end (); it++)
      if (pname == (*it).first)
        return it;

    return (*this).end ();
  }

  iterator find (const std::string pname)
  {
    iterator it;

    for (it = (*this).begin (); it != (*this).end (); it++)
      if (pname == (*it).first)
        return it;

    return (*this).end ();
  }

  octave_value lookup (const std::string pname) const
  {
    octave_value retval;

    const_iterator it = find (pname);

    if (it != (*this).end ())
      retval = (*it).second;

    return retval;
  }

  octave_value& operator [] (const std::string pname)
  {
    iterator it = find (pname);

    if (it == (*this).end ())
      {
        push_back (pval_pair (pname, octave_value ()));
        return (*this).back ().second;
      }

    return (*it).second;
  }

  void erase (const std::string pname)
  {
    iterator it = find (pname);
    if (it != (*this).end ())
      erase (it);
  }

  void erase (iterator it)
  {
    std::vector<pval_pair>::erase (it);
  }

};

class OCTINTERP_API property_list
{
public:
  typedef pval_vector pval_map_type;
  typedef std::map<std::string, pval_map_type> plist_map_type;

  typedef pval_map_type::iterator pval_map_iterator;
  typedef pval_map_type::const_iterator pval_map_const_iterator;

  typedef plist_map_type::iterator plist_map_iterator;
  typedef plist_map_type::const_iterator plist_map_const_iterator;

  property_list (const plist_map_type& m = plist_map_type ())
    : m_plist_map (m) { }

  ~property_list (void) = default;

  OCTINTERP_API void set (const caseless_str& name, const octave_value& val);

  OCTINTERP_API octave_value lookup (const caseless_str& name) const;

  plist_map_iterator begin (void) { return m_plist_map.begin (); }
  plist_map_const_iterator begin (void) const { return m_plist_map.begin (); }

  plist_map_iterator end (void) { return m_plist_map.end (); }
  plist_map_const_iterator end (void) const { return m_plist_map.end (); }

  plist_map_iterator find (const std::string& go_name)
  {
    return m_plist_map.find (go_name);
  }

  plist_map_const_iterator find (const std::string& go_name) const
  {
    return m_plist_map.find (go_name);
  }

  OCTINTERP_API octave_scalar_map
  as_struct (const std::string& prefix_arg) const;

private:
  plist_map_type m_plist_map;
};

// ---------------------------------------------------------------------

class base_graphics_object;
class graphics_object;

class OCTINTERP_API base_properties
{
public:
  base_properties (const std::string& ty = "unknown",
                   const graphics_handle& mh = graphics_handle (),
                   const graphics_handle& p = graphics_handle ());

  virtual ~base_properties (void) = default;

  virtual std::string graphics_object_name (void) const { return "unknown"; }

  OCTINTERP_API void mark_modified (void);

  OCTINTERP_API void override_defaults (base_graphics_object& obj);

  virtual void init_integerhandle (const octave_value&)
  {
    panic_impossible ();
  }

  // Look through DEFAULTS for properties with given CLASS_NAME, and
  // apply them to the current object with set (virtual method).

  OCTINTERP_API void
  set_from_list (base_graphics_object& obj, property_list& defaults);

  void insert_property (const std::string& name, property p)
  {
    p.set_name (name);
    p.set_parent (m___myhandle__);
    m_all_props[name] = p;
  }

  virtual void set (const caseless_str&, const octave_value&);

  virtual octave_value get (const caseless_str& pname) const;

  virtual octave_value get (const std::string& pname) const
  {
    return get (caseless_str (pname));
  }

  virtual octave_value get (const char *pname) const
  {
    return get (caseless_str (pname));
  }

  virtual octave_value get (bool all = false) const;

  // FIXME: It seems like this function should be const, but that is
  // currently not possible with the way that properties are stored as
  // specific types in the graphics_object classes.
  virtual property get_property (const caseless_str& pname);

  virtual bool has_property (const caseless_str&) const
  {
    panic_impossible ();
    return false;
  }

  bool is_modified (void) const { return is___modified__ (); }

  virtual void remove_child (const graphics_handle& h, bool = false)
  {
    if (m_children.remove_child (h.value ()))
      {
        m_children.run_listeners ();
        mark_modified ();
      }
  }

  virtual void adopt (const graphics_handle& h)
  {
    m_children.adopt (h.value ());
    m_children.run_listeners ();
    mark_modified ();
  }

  virtual octave::graphics_toolkit get_toolkit (void) const;

  virtual Matrix
  get_boundingbox (bool /* finternal */ = false,
                   const Matrix& /* parent_pix_size */ = Matrix ()) const
  { return Matrix (1, 4, 0.0); }

  virtual void update_boundingbox (void);

  virtual void update_autopos (const std::string& elem_type);

  virtual void add_listener (const caseless_str&, const octave_value&,
                             listener_mode = GCB_POSTSET);

  virtual void delete_listener (const caseless_str&, const octave_value&,
                                listener_mode = GCB_POSTSET);

  void set_beingdeleted (const octave_value& val)
  {
    m_beingdeleted.set (val, true, false);
    update_beingdeleted ();
  }

  void set_tag (const octave_value& val) { m_tag = val; }

  OCTINTERP_API void set_parent (const octave_value& val);

  Matrix get_children (void) const
  {
    return m_children.get_children ();
  }

  Matrix get_all_children (void) const
  {
    return m_children.get_all ();
  }

  Matrix get_hidden_children (void) const
  {
    return m_children.get_hidden ();
  }

  OCTINTERP_API void
  get_children_of_type (const caseless_str& type, bool get_invisible,
                        bool traverse,
                        std::list<graphics_object> &children_list) const;

  void set_modified (const octave_value& val) { set___modified__ (val); }

  void set___modified__ (const octave_value& val) { m___modified__ = val; }

  // Redirect calls to "uicontextmenu" to "contextmenu".

  graphics_handle get_uicontextmenu (void) const
  {
    return get_contextmenu ();
  }

  void set_uicontextmenu (const octave_value& val)
  {
    set_contextmenu (val);
  }

  void reparent (const graphics_handle& new_parent) { m_parent = new_parent; }

  // Update data limits for AXIS_TYPE (xdata, ydata, etc.) in the parent
  // axes object.

  virtual void update_axis_limits (const std::string& axis_type) const;

  virtual void update_axis_limits (const std::string& axis_type,
                                   const graphics_handle& h) const;

  virtual void update_contextmenu (void) const;

  virtual void delete_children (bool clear = false, bool from_root = false)
  {
    m_children.delete_children (clear, from_root);
  }

  void renumber_child (graphics_handle old_gh, graphics_handle new_gh)
  {
    m_children.renumber (old_gh, new_gh);
  }

  void renumber_parent (graphics_handle new_gh)
  {
    m_parent = new_gh;
  }

  static OCTINTERP_API property_list::pval_map_type factory_defaults (void);

  // FIXME: These functions should be generated automatically by the
  //        genprops.awk script.
  //
  // EMIT_BASE_PROPERTIES_GET_FUNCTIONS

  virtual octave_value get_alim (void) const { return octave_value (); }
  virtual octave_value get_clim (void) const { return octave_value (); }
  virtual octave_value get_xlim (void) const { return octave_value (); }
  virtual octave_value get_ylim (void) const { return octave_value (); }
  virtual octave_value get_zlim (void) const { return octave_value (); }

  virtual bool is_aliminclude (void) const { return false; }
  virtual bool is_climinclude (void) const { return false; }
  virtual bool is_xliminclude (void) const { return false; }
  virtual bool is_yliminclude (void) const { return false; }
  virtual bool is_zliminclude (void) const { return false; }

  OCTINTERP_API bool is_handle_visible (void) const;

  OCTINTERP_API std::set<std::string> dynamic_property_names (void) const;

  OCTINTERP_API bool has_dynamic_property (const std::string& pname) const;

protected:
  std::set<std::string> m_dynamic_properties;

  OCTINTERP_API void
  set_dynamic (const caseless_str& pname, const octave_value& val);

  OCTINTERP_API octave_value get_dynamic (const caseless_str& pname) const;

  OCTINTERP_API octave_value get_dynamic (bool all = false) const;

  OCTINTERP_API property get_property_dynamic (const caseless_str& pname) const;

public:


  static std::set<std::string> core_property_names (void);

  static std::set<std::string> readonly_property_names (void);

  static bool has_core_property (const caseless_str& pname);

  static bool has_readonly_property (const caseless_str& pname);

  std::set<std::string> all_property_names (void) const;

protected:

  bool_property m_beingdeleted;
  radio_property m_busyaction;
  callback_property m_buttondownfcn;
  children_property m_children;
  bool_property m_clipping;
  handle_property m_contextmenu;
  callback_property m_createfcn;
  callback_property m_deletefcn;
  radio_property m_handlevisibility;
  bool_property m_hittest;
  bool_property m_interruptible;
  handle_property m_parent;
  radio_property m_pickableparts;
  bool_property m_selected;
  bool_property m_selectionhighlight;
  string_property m_tag;
  string_property m_type;
  handle_property m_uicontextmenu;
  any_property m_userdata;
  bool_property m_visible;
  any_property m___appdata__;
  bool_property m___modified__;
  graphics_handle m___myhandle__;

public:

  enum
  {
    ID_BEINGDELETED = 0,
    ID_BUSYACTION = 1,
    ID_BUTTONDOWNFCN = 2,
    ID_CHILDREN = 3,
    ID_CLIPPING = 4,
    ID_CONTEXTMENU = 5,
    ID_CREATEFCN = 6,
    ID_DELETEFCN = 7,
    ID_HANDLEVISIBILITY = 8,
    ID_HITTEST = 9,
    ID_INTERRUPTIBLE = 10,
    ID_PARENT = 11,
    ID_PICKABLEPARTS = 12,
    ID_SELECTED = 13,
    ID_SELECTIONHIGHLIGHT = 14,
    ID_TAG = 15,
    ID_TYPE = 16,
    ID_UICONTEXTMENU = 17,
    ID_USERDATA = 18,
    ID_VISIBLE = 19,
    ID___APPDATA__ = 20,
    ID___MODIFIED__ = 21,
    ID___MYHANDLE__ = 22
  };

  bool is_beingdeleted (void) const { return m_beingdeleted.is_on (); }
  std::string get_beingdeleted (void) const { return m_beingdeleted.current_value (); }

  bool busyaction_is (const std::string& v) const { return m_busyaction.is (v); }
  std::string get_busyaction (void) const { return m_busyaction.current_value (); }

  void execute_buttondownfcn (const octave_value& new_data = octave_value ()) const { m_buttondownfcn.execute (new_data); }
  octave_value get_buttondownfcn (void) const { return m_buttondownfcn.get (); }

  bool is_clipping (void) const { return m_clipping.is_on (); }
  std::string get_clipping (void) const { return m_clipping.current_value (); }

  graphics_handle get_contextmenu (void) const { return m_contextmenu.handle_value (); }

  void execute_createfcn (const octave_value& new_data = octave_value ()) const { m_createfcn.execute (new_data); }
  octave_value get_createfcn (void) const { return m_createfcn.get (); }

  void execute_deletefcn (const octave_value& new_data = octave_value ()) const { m_deletefcn.execute (new_data); }
  octave_value get_deletefcn (void) const { return m_deletefcn.get (); }

  bool handlevisibility_is (const std::string& v) const { return m_handlevisibility.is (v); }
  std::string get_handlevisibility (void) const { return m_handlevisibility.current_value (); }

  bool is_hittest (void) const { return m_hittest.is_on (); }
  std::string get_hittest (void) const { return m_hittest.current_value (); }

  bool is_interruptible (void) const { return m_interruptible.is_on (); }
  std::string get_interruptible (void) const { return m_interruptible.current_value (); }

  graphics_handle get_parent (void) const { return m_parent.handle_value (); }

  bool pickableparts_is (const std::string& v) const { return m_pickableparts.is (v); }
  std::string get_pickableparts (void) const { return m_pickableparts.current_value (); }

  bool is_selected (void) const { return m_selected.is_on (); }
  std::string get_selected (void) const { return m_selected.current_value (); }

  bool is_selectionhighlight (void) const { return m_selectionhighlight.is_on (); }
  std::string get_selectionhighlight (void) const { return m_selectionhighlight.current_value (); }

  std::string get_tag (void) const { return m_tag.string_value (); }

  std::string get_type (void) const { return m_type.string_value (); }

  octave_value get_userdata (void) const { return m_userdata.get (); }

  bool is_visible (void) const { return m_visible.is_on (); }
  std::string get_visible (void) const { return m_visible.current_value (); }

  octave_value get___appdata__ (void) const { return m___appdata__.get (); }

  bool is___modified__ (void) const { return m___modified__.is_on (); }
  std::string get___modified__ (void) const { return m___modified__.current_value (); }

  graphics_handle get___myhandle__ (void) const { return m___myhandle__; }


  void set_busyaction (const octave_value& val)
  {
    if (m_busyaction.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_buttondownfcn (const octave_value& val)
  {
    if (m_buttondownfcn.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_children (const octave_value& val)
  {
    if (m_children.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_clipping (const octave_value& val)
  {
    if (m_clipping.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_contextmenu (const octave_value& val)
  {
    if (m_contextmenu.set (val, true))
      {
        update_contextmenu ();
        mark_modified ();
      }
  }

  void set_createfcn (const octave_value& val)
  {
    if (m_createfcn.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_deletefcn (const octave_value& val)
  {
    if (m_deletefcn.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_handlevisibility (const octave_value& val)
  {
    if (m_handlevisibility.set (val, true))
      {
        update_handlevisibility ();
        mark_modified ();
      }
  }

  void set_hittest (const octave_value& val)
  {
    if (m_hittest.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_interruptible (const octave_value& val)
  {
    if (m_interruptible.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_pickableparts (const octave_value& val)
  {
    if (m_pickableparts.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_selected (const octave_value& val)
  {
    if (m_selected.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_selectionhighlight (const octave_value& val)
  {
    if (m_selectionhighlight.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_userdata (const octave_value& val)
  {
    if (m_userdata.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_visible (const octave_value& val)
  {
    if (m_visible.set (val, true))
      {
        update_visible ();
        mark_modified ();
      }
  }

  void set___appdata__ (const octave_value& val)
  {
    if (m___appdata__.set (val, true))
      {
        mark_modified ();
      }
  }


  virtual void update_beingdeleted (void) { };

  virtual void update_handlevisibility (void);

  virtual void update_visible (void) { };

protected:
  struct cmp_caseless_str
  {
  public:
    bool operator () (const caseless_str& a, const caseless_str& b) const
    {
      std::string a1 = a;
      std::transform (a1.begin (), a1.end (), a1.begin (), tolower);
      std::string b1 = b;
      std::transform (b1.begin (), b1.end (), b1.begin (), tolower);

      return a1 < b1;
    }
  };

  std::map<caseless_str, property, cmp_caseless_str> m_all_props;

protected:

  virtual void init (void)
  {
    m_contextmenu.add_constraint ("uicontextmenu");
  }
};

class OCTINTERP_API base_graphics_object
{
public:
  friend class graphics_object;

  base_graphics_object (void) : m_toolkit_flag (false) { }

  // No copying!

  base_graphics_object (const base_graphics_object&) = delete;

  base_graphics_object& operator = (const base_graphics_object&) = delete;

  virtual ~base_graphics_object (void) = default;

  virtual void mark_modified (void)
  {
    if (! valid_object ())
      error ("base_graphics_object::mark_modified: invalid graphics object");

    get_properties ().mark_modified ();
  }

  virtual void override_defaults (base_graphics_object& obj)
  {
    if (! valid_object ())
      error ("base_graphics_object::override_defaults: invalid graphics object");
    get_properties ().override_defaults (obj);
  }

  void build_user_defaults_map (property_list::pval_map_type& def,
                                const std::string go_name) const;

  virtual void set_from_list (property_list& plist)
  {
    if (! valid_object ())
      error ("base_graphics_object::set_from_list: invalid graphics object");

    get_properties ().set_from_list (*this, plist);
  }

  virtual void set (const caseless_str& pname, const octave_value& pval)
  {
    if (! valid_object ())
      error ("base_graphics_object::set: invalid graphics object");

    get_properties ().set (pname, pval);
  }

  virtual void set_defaults (const std::string&)
  {
    error ("base_graphics_object::set_defaults: invalid graphics object");
  }

  // The following version of the get method is not declared virtual
  // because no derived class overrides it.

  octave_value get (bool all = false) const
  {
    if (! valid_object ())
      error ("base_graphics_object::get: invalid graphics object");

    return get_properties ().get (all);
  }

  virtual octave_value get (const caseless_str& pname) const
  {
    if (! valid_object ())
      error ("base_graphics_object::get: invalid graphics object");

    return get_properties ().get (pname);
  }

  virtual octave_value get_default (const caseless_str&) const;

  virtual octave_value get_factory_default (const caseless_str&) const;

  virtual octave_value get_defaults (void) const
  {
    error ("base_graphics_object::get_defaults: invalid graphics object");
  }

  virtual property_list get_defaults_list (void) const
  {
    if (! valid_object ())
      error ("base_graphics_object::get_defaults_list: invalid graphics object");

    return property_list ();
  }

  virtual octave_value get_factory_defaults (void) const
  {
    error ("base_graphics_object::get_factory_defaults: invalid graphics object");
  }

  virtual property_list get_factory_defaults_list (void) const
  {
    error ("base_graphics_object::get_factory_defaults_list: invalid graphics object");
  }

  virtual bool has_readonly_property (const caseless_str& pname) const
  {
    return base_properties::has_readonly_property (pname);
  }

  // FIXME: It seems like this function should be const, but that is
  // currently not possible.
  virtual std::string values_as_string (void);

  // FIXME: It seems like this function should be const, but that is
  // currently not possible.
  virtual std::string value_as_string (const std::string& prop);

  // FIXME: It seems like this function should be const, but that is
  // currently not possible.
  virtual octave_scalar_map values_as_struct (void);

  virtual graphics_handle get_parent (void) const
  {
    if (! valid_object ())
      error ("base_graphics_object::get_parent: invalid graphics object");

    return get_properties ().get_parent ();
  }

  graphics_handle get_handle (void) const
  {
    if (! valid_object ())
      error ("base_graphics_object::get_handle: invalid graphics object");

    return get_properties ().get___myhandle__ ();
  }

  virtual void remove_child (const graphics_handle& h, bool from_root = false)
  {
    if (! valid_object ())
      error ("base_graphics_object::remove_child: invalid graphics object");

    get_properties ().remove_child (h, from_root);
  }

  virtual void adopt (const graphics_handle& h)
  {
    if (! valid_object ())
      error ("base_graphics_object::adopt: invalid graphics object");

    get_properties ().adopt (h);
  }

  virtual void reparent (const graphics_handle& np)
  {
    if (! valid_object ())
      error ("base_graphics_object::reparent: invalid graphics object");

    get_properties ().reparent (np);
  }

  virtual void defaults (void) const
  {
    if (! valid_object ())
      error ("base_graphics_object::default: invalid graphics object");

    std::string msg = (type () + "::defaults");
    err_not_implemented (msg.c_str ());
  }

  virtual base_properties& get_properties (void)
  {
    static base_properties properties;
    warning ("base_graphics_object::get_properties: invalid graphics object");
    return properties;
  }

  virtual const base_properties& get_properties (void) const
  {
    static base_properties properties;
    warning ("base_graphics_object::get_properties: invalid graphics object");
    return properties;
  }

  virtual void update_axis_limits (const std::string& axis_type);

  virtual void update_axis_limits (const std::string& axis_type,
                                   const graphics_handle& h);

  virtual bool valid_object (void) const { return false; }

  bool valid_toolkit_object (void) const { return m_toolkit_flag; }

  virtual std::string type (void) const
  {
    return (valid_object () ? get_properties ().graphics_object_name ()
                            : "unknown");
  }

  bool isa (const std::string& go_name) const
  {
    return type () == go_name;
  }

  virtual octave::graphics_toolkit get_toolkit (void) const
  {
    if (! valid_object ())
      error ("base_graphics_object::get_toolkit: invalid graphics object");

    return get_properties ().get_toolkit ();
  }

  virtual void add_property_listener (const std::string& nm,
                                      const octave_value& v,
                                      listener_mode mode = GCB_POSTSET)
  {
    if (valid_object ())
      get_properties ().add_listener (nm, v, mode);
  }

  virtual void delete_property_listener (const std::string& nm,
                                         const octave_value& v,
                                         listener_mode mode = GCB_POSTSET)
  {
    if (valid_object ())
      get_properties ().delete_listener (nm, v, mode);
  }

  virtual void remove_all_listeners (void);

  virtual void reset_default_properties (void);

protected:
  virtual void initialize (const graphics_object& go)
  {
    if (! m_toolkit_flag)
      m_toolkit_flag = get_toolkit ().initialize (go);
  }

  virtual void finalize (const graphics_object& go)
  {
    if (m_toolkit_flag)
      {
        get_toolkit ().finalize (go);
        m_toolkit_flag = false;
      }
  }

  virtual void update (const graphics_object& go, int id)
  {
    if (m_toolkit_flag)
      get_toolkit ().update (go, id);
  }

protected:

  // A flag telling whether this object is a valid object
  // in the backend context.
  bool m_toolkit_flag;
};

class OCTINTERP_API graphics_object
{
public:

  graphics_object (void) : m_rep (new base_graphics_object ()) { }

  graphics_object (base_graphics_object *new_rep) : m_rep (new_rep) { }

  graphics_object (const graphics_object&) = default;

  graphics_object& operator = (const graphics_object&) = default;

  ~graphics_object (void) = default;

  void mark_modified (void) { m_rep->mark_modified (); }

  void override_defaults (base_graphics_object& obj)
  {
    m_rep->override_defaults (obj);
  }

  void override_defaults (void)
  {
    m_rep->override_defaults (*m_rep);
  }

  void build_user_defaults_map (property_list::pval_map_type& def,
                                const std::string go_name) const
  {
    m_rep->build_user_defaults_map (def, go_name);
  }

  void set_from_list (property_list& plist) { m_rep->set_from_list (plist); }

  void set (const caseless_str& name, const octave_value& val)
  {
    m_rep->set (name, val);
  }

  OCTINTERP_API void set (const octave_value_list& args);

  OCTINTERP_API void set (const Array<std::string>& names, const Cell& values,
                          octave_idx_type row);

  OCTINTERP_API void set (const octave_map& m);

  OCTINTERP_API void set_value_or_default (const caseless_str& name,
                                           const octave_value& val);

  void set_defaults (const std::string& mode) { m_rep->set_defaults (mode); }

  octave_value get (bool all = false) const { return m_rep->get (all); }

  octave_value get (const caseless_str& name) const
  {
    return name.compare ("default")
           ? get_defaults ()
           : (name.compare ("factory")
              ? get_factory_defaults () : m_rep->get (name));
  }

  octave_value get (const std::string& name) const
  {
    return get (caseless_str (name));
  }

  octave_value get (const char *name) const
  {
    return get (caseless_str (name));
  }

  octave_value get_default (const caseless_str& name) const
  {
    return m_rep->get_default (name);
  }

  octave_value get_factory_default (const caseless_str& name) const
  {
    return m_rep->get_factory_default (name);
  }

  octave_value get_defaults (void) const { return m_rep->get_defaults (); }

  property_list get_defaults_list (void) const
  {
    return m_rep->get_defaults_list ();
  }

  octave_value get_factory_defaults (void) const
  {
    return m_rep->get_factory_defaults ();
  }

  property_list get_factory_defaults_list (void) const
  {
    return m_rep->get_factory_defaults_list ();
  }

  bool has_readonly_property (const caseless_str& pname) const
  {
    return m_rep->has_readonly_property (pname);
  }

  // FIXME: It seems like this function should be const, but that is
  // currently not possible.
  std::string values_as_string (void) { return m_rep->values_as_string (); }

  // FIXME: It seems like this function should be const, but that is
  // currently not possible.
  std::string value_as_string (const std::string& prop)
  {
    return m_rep->value_as_string (prop);
  }

  // FIXME: It seems like this function should be const, but that is
  // currently not possible.
  octave_map values_as_struct (void) { return m_rep->values_as_struct (); }

  graphics_handle get_parent (void) const { return m_rep->get_parent (); }

  graphics_handle get_handle (void) const { return m_rep->get_handle (); }

  OCTINTERP_API graphics_object get_ancestor (const std::string& type) const;

  void remove_child (const graphics_handle& h) { m_rep->remove_child (h); }

  void adopt (const graphics_handle& h) { m_rep->adopt (h); }

  void reparent (const graphics_handle& h) { m_rep->reparent (h); }

  void defaults (void) const { m_rep->defaults (); }

  bool isa (const std::string& go_name) const { return m_rep->isa (go_name); }

  base_properties& get_properties (void) { return m_rep->get_properties (); }

  const base_properties& get_properties (void) const
  {
    return m_rep->get_properties ();
  }

  void update_axis_limits (const std::string& axis_type)
  {
    m_rep->update_axis_limits (axis_type);
  }

  void update_axis_limits (const std::string& axis_type,
                           const graphics_handle& h)
  {
    m_rep->update_axis_limits (axis_type, h);
  }

  bool valid_object (void) const { return m_rep->valid_object (); }

  std::string type (void) const { return m_rep->type (); }

  operator bool (void) const { return m_rep->valid_object (); }

  // FIXME: These functions should be generated automatically by the
  //        genprops.awk script.
  //
  // EMIT_GRAPHICS_OBJECT_GET_FUNCTIONS

  octave_value get_alim (void) const
  { return get_properties ().get_alim (); }

  octave_value get_clim (void) const
  { return get_properties ().get_clim (); }

  octave_value get_xlim (void) const
  { return get_properties ().get_xlim (); }

  octave_value get_ylim (void) const
  { return get_properties ().get_ylim (); }

  octave_value get_zlim (void) const
  { return get_properties ().get_zlim (); }

  bool is_aliminclude (void) const
  { return get_properties ().is_aliminclude (); }

  bool is_climinclude (void) const
  { return get_properties ().is_climinclude (); }

  bool is_xliminclude (void) const
  { return get_properties ().is_xliminclude (); }

  bool is_yliminclude (void) const
  { return get_properties ().is_yliminclude (); }

  bool is_zliminclude (void) const
  { return get_properties ().is_zliminclude (); }

  bool is_handle_visible (void) const
  { return get_properties ().is_handle_visible (); }

  octave::graphics_toolkit get_toolkit (void) const
  { return m_rep->get_toolkit (); }

  void add_property_listener (const std::string& nm, const octave_value& v,
                              listener_mode mode = GCB_POSTSET)
  { m_rep->add_property_listener (nm, v, mode); }

  void delete_property_listener (const std::string& nm, const octave_value& v,
                                 listener_mode mode = GCB_POSTSET)
  { m_rep->delete_property_listener (nm, v, mode); }

  void remove_all_listeners (void) { m_rep->remove_all_listeners (); }

  void initialize (void) { m_rep->initialize (*this); }

  void finalize (void) { m_rep->finalize (*this); }

  void update (int id) { m_rep->update (*this, id); }

  void reset_default_properties (void)
  { m_rep->reset_default_properties (); }

private:

  std::shared_ptr<base_graphics_object> m_rep;
};

// ---------------------------------------------------------------------

class OCTINTERP_API root_figure : public base_graphics_object
{
public:

  // The gh_manager constructor creates the single instance of
  // the root_figure object.

  friend class gh_manager;

  class OCTINTERP_API properties : public base_properties
  {
  public:
    OCTINTERP_API void
    remove_child (const graphics_handle& h, bool from_root = false);

    OCTINTERP_API Matrix
    get_boundingbox (bool internal = false,
                     const Matrix& parent_pix_size = Matrix ()) const;

    // See the genprops.awk script for an explanation of the
    // properties declarations.

    // FIXME: Properties that still don't have callbacks are:
    // monitorpositions, pointerlocation, pointerwindow.
    // Note that these properties are not yet used by Octave, so setting
    // them will have no effect.

    // FIXME: The commandwindowsize property has been deprecated in Matlab
    //        and is now available through matlab.desktop.comandwindow.size.
    //        Until Octave has something similar, keep this property in root.

    // Programming note: Keep property list sorted if new ones are added.

public:
  properties (const graphics_handle& mh, const graphics_handle& p);

  ~properties (void) { }

  void set (const caseless_str& pname, const octave_value& val);

  octave_value get (bool all = false) const;

  octave_value get (const caseless_str& pname) const;

  octave_value get (const std::string& pname) const
  {
    return get (caseless_str (pname));
  }

  octave_value get (const char *pname) const
  {
    return get (caseless_str (pname));
  }

  property get_property (const caseless_str& pname);

  std::string graphics_object_name (void) const { return s_go_name; }

  static property_list::pval_map_type factory_defaults (void);

private:
  static std::string s_go_name;

public:


  static std::set<std::string> core_property_names (void);

  static std::set<std::string> readonly_property_names (void);

  static bool has_core_property (const caseless_str& pname);

  static bool has_readonly_property (const caseless_str& pname);

  std::set<std::string> all_property_names (void) const;

  bool has_property (const caseless_str& pname) const;

private:

  handle_property m_callbackobject;
  array_property m_commandwindowsize;
  handle_property m_currentfigure;
  string_property m_fixedwidthfontname;
  array_property m_monitorpositions;
  array_property m_pointerlocation;
  double_property m_pointerwindow;
  double_property m_screendepth;
  double_property m_screenpixelsperinch;
  array_property m_screensize;
  bool_property m_showhiddenhandles;
  radio_property m_units;

public:

  enum
  {
    ID_CALLBACKOBJECT = 1000,
    ID_COMMANDWINDOWSIZE = 1001,
    ID_CURRENTFIGURE = 1002,
    ID_FIXEDWIDTHFONTNAME = 1003,
    ID_MONITORPOSITIONS = 1004,
    ID_POINTERLOCATION = 1005,
    ID_POINTERWINDOW = 1006,
    ID_SCREENDEPTH = 1007,
    ID_SCREENPIXELSPERINCH = 1008,
    ID_SCREENSIZE = 1009,
    ID_SHOWHIDDENHANDLES = 1010,
    ID_UNITS = 1011
  };

  graphics_handle get_callbackobject (void) const { return m_callbackobject.handle_value (); }

  octave_value get_commandwindowsize (void) const { return m_commandwindowsize.get (); }

  graphics_handle get_currentfigure (void) const { return m_currentfigure.handle_value (); }

  std::string get_fixedwidthfontname (void) const { return m_fixedwidthfontname.string_value (); }

  octave_value get_monitorpositions (void) const { return m_monitorpositions.get (); }

  octave_value get_pointerlocation (void) const { return m_pointerlocation.get (); }

  double get_pointerwindow (void) const { return m_pointerwindow.double_value (); }

  double get_screendepth (void) const { return m_screendepth.double_value (); }

  double get_screenpixelsperinch (void) const { return m_screenpixelsperinch.double_value (); }

  octave_value get_screensize (void) const { return m_screensize.get (); }

  bool is_showhiddenhandles (void) const { return m_showhiddenhandles.is_on (); }
  std::string get_showhiddenhandles (void) const { return m_showhiddenhandles.current_value (); }

  bool units_is (const std::string& v) const { return m_units.is (v); }
  std::string get_units (void) const { return m_units.current_value (); }


  void set_callbackobject (const octave_value& val);

  void set_commandwindowsize (const octave_value& val)
  {
    if (m_commandwindowsize.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_currentfigure (const octave_value& val);

  void set_fixedwidthfontname (const octave_value& val)
  {
    if (m_fixedwidthfontname.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_monitorpositions (const octave_value& val)
  {
    if (m_monitorpositions.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_pointerlocation (const octave_value& val)
  {
    if (m_pointerlocation.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_pointerwindow (const octave_value& val)
  {
    if (m_pointerwindow.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_screendepth (const octave_value& val)
  {
    if (m_screendepth.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_screenpixelsperinch (const octave_value& val)
  {
    if (m_screenpixelsperinch.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_screensize (const octave_value& val)
  {
    if (m_screensize.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_showhiddenhandles (const octave_value& val)
  {
    if (m_showhiddenhandles.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_units (const octave_value& val)
  {
    if (m_units.set (val, true))
      {
        update_units ();
        mark_modified ();
      }
  }

  void update_units (void);

  };

private:

  properties m_properties;

protected:

  root_figure (void)
    : m_properties (0, graphics_handle ()), m_default_properties (),
      m_factory_properties (init_factory_properties ())
  { }

public:

  ~root_figure (void) = default;

  root_figure (const root_figure&) = delete;

  root_figure& operator = (const root_figure&) = delete;

  void mark_modified (void) { }

  void override_defaults (base_graphics_object& obj)
  {
    // Now override with our defaults.  If the default_properties
    // list includes the properties for all defaults (line,
    // surface, etc.) then we don't have to know the type of OBJ
    // here, we just call its set function and let it decide which
    // properties from the list to use.
    obj.set_from_list (m_default_properties);
  }

  void set (const caseless_str& name, const octave_value& value)
  {
    if (name.compare ("default", 7))
      // strip "default", pass rest to function that will
      // parse the remainder and add the element to the
      // default_properties map.
      m_default_properties.set (name.substr (7), value);
    else
      m_properties.set (name, value);
  }

  octave_value get (const caseless_str& name) const
  {
    octave_value retval;

    if (name.compare ("default", 7))
      return get_default (name.substr (7));
    else if (name.compare ("factory", 7))
      return get_factory_default (name.substr (7));
    else
      retval = m_properties.get (name);

    return retval;
  }

  octave_value get_default (const caseless_str& name) const
  {
    octave_value retval = m_default_properties.lookup (name);

    if (retval.is_undefined ())
      {
        // no default property found, use factory default
        retval = m_factory_properties.lookup (name);

        if (retval.is_undefined ())
          error ("get: invalid default property '%s'", name.c_str ());
      }

    return retval;
  }

  octave_value get_factory_default (const caseless_str& name) const
  {
    octave_value retval = m_factory_properties.lookup (name);

    if (retval.is_undefined ())
      error ("get: invalid factory default property '%s'", name.c_str ());

    return retval;
  }

  octave_value get_defaults (void) const
  {
    return m_default_properties.as_struct ("default");
  }

  property_list get_defaults_list (void) const
  {
    return m_default_properties;
  }

  octave_value get_factory_defaults (void) const
  {
    return m_factory_properties.as_struct ("factory");
  }

  property_list get_factory_defaults_list (void) const
  {
    return m_factory_properties;
  }

  base_properties& get_properties (void) { return m_properties; }

  const base_properties& get_properties (void) const { return m_properties; }

  bool valid_object (void) const { return true; }

  OCTINTERP_API void reset_default_properties (void);

  bool has_readonly_property (const caseless_str& pname) const
  {
    bool retval = m_properties.has_readonly_property (pname);
    if (! retval)
      retval = base_properties::has_readonly_property (pname);
    return retval;
  }

private:

  property_list m_default_properties;

  property_list m_factory_properties;

  static OCTINTERP_API property_list::plist_map_type
  init_factory_properties (void);
};

// ---------------------------------------------------------------------

class OCTINTERP_API figure : public base_graphics_object
{
public:

  class OCTINTERP_API properties : public base_properties
  {
  public:
    void init_integerhandle (const octave_value& val)
    {
      m_integerhandle = val;
    }

    OCTINTERP_API void
    remove_child (const graphics_handle& h, bool from_root = false);

    OCTINTERP_API void set_visible (const octave_value& val);

    OCTINTERP_API octave::graphics_toolkit get_toolkit (void) const;

    OCTINTERP_API void set_toolkit (const octave::graphics_toolkit& b);

    OCTINTERP_API void set___graphics_toolkit__ (const octave_value& val);

    OCTINTERP_API void adopt (const graphics_handle& h);

    OCTINTERP_API void set_position (const octave_value& val,
                                     bool do_notify_toolkit = true);

    OCTINTERP_API void set_outerposition (const octave_value& val,
                                          bool do_notify_toolkit = true);

    OCTINTERP_API Matrix bbox2position (const Matrix& bbox) const;

    OCTINTERP_API Matrix
    get_boundingbox (bool internal = false,
                     const Matrix& parent_pix_size = Matrix ()) const;

    OCTINTERP_API void
    set_boundingbox (const Matrix& bb, bool internal = false,
                     bool do_notify_toolkit = true);

    OCTINTERP_API Matrix map_from_boundingbox (double x, double y) const;

    OCTINTERP_API Matrix map_to_boundingbox (double x, double y) const;

    OCTINTERP_API void update_units (const caseless_str& old_units);

    OCTINTERP_API void update_paperunits (const caseless_str& old_paperunits);

    OCTINTERP_API std::string get_title (void) const;

    // See the genprops.awk script for an explanation of the
    // properties declarations.
    // Programming note: Keep property list sorted if new ones are added.

public:
  properties (const graphics_handle& mh, const graphics_handle& p);

  ~properties (void) { }

  void set (const caseless_str& pname, const octave_value& val);

  octave_value get (bool all = false) const;

  octave_value get (const caseless_str& pname) const;

  octave_value get (const std::string& pname) const
  {
    return get (caseless_str (pname));
  }

  octave_value get (const char *pname) const
  {
    return get (caseless_str (pname));
  }

  property get_property (const caseless_str& pname);

  std::string graphics_object_name (void) const { return s_go_name; }

  static property_list::pval_map_type factory_defaults (void);

private:
  static std::string s_go_name;

public:


  static std::set<std::string> core_property_names (void);

  static std::set<std::string> readonly_property_names (void);

  static bool has_core_property (const caseless_str& pname);

  static bool has_readonly_property (const caseless_str& pname);

  std::set<std::string> all_property_names (void) const;

  bool has_property (const caseless_str& pname) const;

private:

  array_property m_alphamap;
  callback_property m_buttondownfcn;
  callback_property m_closerequestfcn;
  color_property m_color;
  array_property m_colormap;
  handle_property m_currentaxes;
  string_property m_currentcharacter;
  handle_property m_currentobject;
  array_property m_currentpoint;
  bool_property m_dockcontrols;
  string_property m_filename;
  bool_property m_graphicssmoothing;
  bool_property m_integerhandle;
  bool_property m_inverthardcopy;
  callback_property m_keypressfcn;
  callback_property m_keyreleasefcn;
  radio_property m_menubar;
  string_property m_name;
  array_property m_number;
  radio_property m_nextplot;
  bool_property m_numbertitle;
  array_property m_outerposition;
  radio_property m_paperorientation;
  array_property m_paperposition;
  radio_property m_paperpositionmode;
  array_property m_papersize;
  radio_property m_papertype;
  radio_property m_paperunits;
  radio_property m_pointer;
  array_property m_pointershapecdata;
  array_property m_pointershapehotspot;
  array_property m_position;
  radio_property m_renderer;
  radio_property m_renderermode;
  bool_property m_resize;
  callback_property m_resizefcn;
  radio_property m_selectiontype;
  callback_property m_sizechangedfcn;
  radio_property m_toolbar;
  radio_property m_units;
  callback_property m_windowbuttondownfcn;
  callback_property m_windowbuttonmotionfcn;
  callback_property m_windowbuttonupfcn;
  callback_property m_windowkeypressfcn;
  callback_property m_windowkeyreleasefcn;
  callback_property m_windowscrollwheelfcn;
  radio_property m_windowstyle;
  radio_property m_pickableparts;
  mutable string_property m___gl_extensions__;
  mutable string_property m___gl_renderer__;
  mutable string_property m___gl_vendor__;
  mutable string_property m___gl_version__;
  bool_property m___gl_window__;
  string_property m___graphics_toolkit__;
  any_property m___guidata__;
  radio_property m___mouse_mode__;
  bool_property m___printing__;
  any_property m___pan_mode__;
  any_property m___plot_stream__;
  any_property m___rotate_mode__;
  any_property m___zoom_mode__;
  double_property m___device_pixel_ratio__;

public:

  enum
  {
    ID_ALPHAMAP = 2000,
    ID_BUTTONDOWNFCN = 2001,
    ID_CLOSEREQUESTFCN = 2002,
    ID_COLOR = 2003,
    ID_COLORMAP = 2004,
    ID_CURRENTAXES = 2005,
    ID_CURRENTCHARACTER = 2006,
    ID_CURRENTOBJECT = 2007,
    ID_CURRENTPOINT = 2008,
    ID_DOCKCONTROLS = 2009,
    ID_FILENAME = 2010,
    ID_GRAPHICSSMOOTHING = 2011,
    ID_INTEGERHANDLE = 2012,
    ID_INVERTHARDCOPY = 2013,
    ID_KEYPRESSFCN = 2014,
    ID_KEYRELEASEFCN = 2015,
    ID_MENUBAR = 2016,
    ID_NAME = 2017,
    ID_NUMBER = 2018,
    ID_NEXTPLOT = 2019,
    ID_NUMBERTITLE = 2020,
    ID_OUTERPOSITION = 2021,
    ID_PAPERORIENTATION = 2022,
    ID_PAPERPOSITION = 2023,
    ID_PAPERPOSITIONMODE = 2024,
    ID_PAPERSIZE = 2025,
    ID_PAPERTYPE = 2026,
    ID_PAPERUNITS = 2027,
    ID_POINTER = 2028,
    ID_POINTERSHAPECDATA = 2029,
    ID_POINTERSHAPEHOTSPOT = 2030,
    ID_POSITION = 2031,
    ID_RENDERER = 2032,
    ID_RENDERERMODE = 2033,
    ID_RESIZE = 2034,
    ID_RESIZEFCN = 2035,
    ID_SELECTIONTYPE = 2036,
    ID_SIZECHANGEDFCN = 2037,
    ID_TOOLBAR = 2038,
    ID_UNITS = 2039,
    ID_WINDOWBUTTONDOWNFCN = 2040,
    ID_WINDOWBUTTONMOTIONFCN = 2041,
    ID_WINDOWBUTTONUPFCN = 2042,
    ID_WINDOWKEYPRESSFCN = 2043,
    ID_WINDOWKEYRELEASEFCN = 2044,
    ID_WINDOWSCROLLWHEELFCN = 2045,
    ID_WINDOWSTYLE = 2046,
    ID_PICKABLEPARTS = 2047,
    ID___GL_EXTENSIONS__ = 2048,
    ID___GL_RENDERER__ = 2049,
    ID___GL_VENDOR__ = 2050,
    ID___GL_VERSION__ = 2051,
    ID___GL_WINDOW__ = 2052,
    ID___GRAPHICS_TOOLKIT__ = 2053,
    ID___GUIDATA__ = 2054,
    ID___MOUSE_MODE__ = 2055,
    ID___PRINTING__ = 2056,
    ID___PAN_MODE__ = 2057,
    ID___PLOT_STREAM__ = 2058,
    ID___ROTATE_MODE__ = 2059,
    ID___ZOOM_MODE__ = 2060,
    ID___DEVICE_PIXEL_RATIO__ = 2061
  };

  octave_value get_alphamap (void) const { return m_alphamap.get (); }

  void execute_buttondownfcn (const octave_value& new_data = octave_value ()) const { m_buttondownfcn.execute (new_data); }
  octave_value get_buttondownfcn (void) const { return m_buttondownfcn.get (); }

  void execute_closerequestfcn (const octave_value& new_data = octave_value ()) const { m_closerequestfcn.execute (new_data); }
  octave_value get_closerequestfcn (void) const { return m_closerequestfcn.get (); }

  bool color_is_rgb (void) const { return m_color.is_rgb (); }
  bool color_is (const std::string& v) const { return m_color.is (v); }
  Matrix get_color_rgb (void) const { return (m_color.is_rgb () ? m_color.rgb () : Matrix ()); }
  octave_value get_color (void) const { return m_color.get (); }

  octave_value get_colormap (void) const { return m_colormap.get (); }

  graphics_handle get_currentaxes (void) const { return m_currentaxes.handle_value (); }

  std::string get_currentcharacter (void) const { return m_currentcharacter.string_value (); }

  graphics_handle get_currentobject (void) const { return m_currentobject.handle_value (); }

  octave_value get_currentpoint (void) const { return m_currentpoint.get (); }

  bool is_dockcontrols (void) const { return m_dockcontrols.is_on (); }
  std::string get_dockcontrols (void) const { return m_dockcontrols.current_value (); }

  std::string get_filename (void) const { return m_filename.string_value (); }

  bool is_graphicssmoothing (void) const { return m_graphicssmoothing.is_on (); }
  std::string get_graphicssmoothing (void) const { return m_graphicssmoothing.current_value (); }

  bool is_integerhandle (void) const { return m_integerhandle.is_on (); }
  std::string get_integerhandle (void) const { return m_integerhandle.current_value (); }

  bool is_inverthardcopy (void) const { return m_inverthardcopy.is_on (); }
  std::string get_inverthardcopy (void) const { return m_inverthardcopy.current_value (); }

  void execute_keypressfcn (const octave_value& new_data = octave_value ()) const { m_keypressfcn.execute (new_data); }
  octave_value get_keypressfcn (void) const { return m_keypressfcn.get (); }

  void execute_keyreleasefcn (const octave_value& new_data = octave_value ()) const { m_keyreleasefcn.execute (new_data); }
  octave_value get_keyreleasefcn (void) const { return m_keyreleasefcn.get (); }

  bool menubar_is (const std::string& v) const { return m_menubar.is (v); }
  std::string get_menubar (void) const { return m_menubar.current_value (); }

  std::string get_name (void) const { return m_name.string_value (); }

  octave_value get_number (void) const;

  bool nextplot_is (const std::string& v) const { return m_nextplot.is (v); }
  std::string get_nextplot (void) const { return m_nextplot.current_value (); }

  bool is_numbertitle (void) const { return m_numbertitle.is_on (); }
  std::string get_numbertitle (void) const { return m_numbertitle.current_value (); }

  octave_value get_outerposition (void) const { return m_outerposition.get (); }

  bool paperorientation_is (const std::string& v) const { return m_paperorientation.is (v); }
  std::string get_paperorientation (void) const { return m_paperorientation.current_value (); }

  octave_value get_paperposition (void) const { return m_paperposition.get (); }

  bool paperpositionmode_is (const std::string& v) const { return m_paperpositionmode.is (v); }
  std::string get_paperpositionmode (void) const { return m_paperpositionmode.current_value (); }

  octave_value get_papersize (void) const { return m_papersize.get (); }

  bool papertype_is (const std::string& v) const { return m_papertype.is (v); }
  std::string get_papertype (void) const { return m_papertype.current_value (); }

  bool paperunits_is (const std::string& v) const { return m_paperunits.is (v); }
  std::string get_paperunits (void) const { return m_paperunits.current_value (); }

  bool pointer_is (const std::string& v) const { return m_pointer.is (v); }
  std::string get_pointer (void) const { return m_pointer.current_value (); }

  octave_value get_pointershapecdata (void) const { return m_pointershapecdata.get (); }

  octave_value get_pointershapehotspot (void) const { return m_pointershapehotspot.get (); }

  octave_value get_position (void) const { return m_position.get (); }

  bool renderer_is (const std::string& v) const { return m_renderer.is (v); }
  std::string get_renderer (void) const { return m_renderer.current_value (); }

  bool renderermode_is (const std::string& v) const { return m_renderermode.is (v); }
  std::string get_renderermode (void) const { return m_renderermode.current_value (); }

  bool is_resize (void) const { return m_resize.is_on (); }
  std::string get_resize (void) const { return m_resize.current_value (); }

  void execute_resizefcn (const octave_value& new_data = octave_value ()) const { m_resizefcn.execute (new_data); }
  octave_value get_resizefcn (void) const { return m_resizefcn.get (); }

  bool selectiontype_is (const std::string& v) const { return m_selectiontype.is (v); }
  std::string get_selectiontype (void) const { return m_selectiontype.current_value (); }

  void execute_sizechangedfcn (const octave_value& new_data = octave_value ()) const { m_sizechangedfcn.execute (new_data); }
  octave_value get_sizechangedfcn (void) const { return m_sizechangedfcn.get (); }

  bool toolbar_is (const std::string& v) const { return m_toolbar.is (v); }
  std::string get_toolbar (void) const { return m_toolbar.current_value (); }

  bool units_is (const std::string& v) const { return m_units.is (v); }
  std::string get_units (void) const { return m_units.current_value (); }

  void execute_windowbuttondownfcn (const octave_value& new_data = octave_value ()) const { m_windowbuttondownfcn.execute (new_data); }
  octave_value get_windowbuttondownfcn (void) const { return m_windowbuttondownfcn.get (); }

  void execute_windowbuttonmotionfcn (const octave_value& new_data = octave_value ()) const { m_windowbuttonmotionfcn.execute (new_data); }
  octave_value get_windowbuttonmotionfcn (void) const { return m_windowbuttonmotionfcn.get (); }

  void execute_windowbuttonupfcn (const octave_value& new_data = octave_value ()) const { m_windowbuttonupfcn.execute (new_data); }
  octave_value get_windowbuttonupfcn (void) const { return m_windowbuttonupfcn.get (); }

  void execute_windowkeypressfcn (const octave_value& new_data = octave_value ()) const { m_windowkeypressfcn.execute (new_data); }
  octave_value get_windowkeypressfcn (void) const { return m_windowkeypressfcn.get (); }

  void execute_windowkeyreleasefcn (const octave_value& new_data = octave_value ()) const { m_windowkeyreleasefcn.execute (new_data); }
  octave_value get_windowkeyreleasefcn (void) const { return m_windowkeyreleasefcn.get (); }

  void execute_windowscrollwheelfcn (const octave_value& new_data = octave_value ()) const { m_windowscrollwheelfcn.execute (new_data); }
  octave_value get_windowscrollwheelfcn (void) const { return m_windowscrollwheelfcn.get (); }

  bool windowstyle_is (const std::string& v) const { return m_windowstyle.is (v); }
  std::string get_windowstyle (void) const { return m_windowstyle.current_value (); }

  bool pickableparts_is (const std::string& v) const { return m_pickableparts.is (v); }
  std::string get_pickableparts (void) const { return m_pickableparts.current_value (); }

  std::string get___gl_extensions__ (void) const { return m___gl_extensions__.string_value (); }

  std::string get___gl_renderer__ (void) const { return m___gl_renderer__.string_value (); }

  std::string get___gl_vendor__ (void) const { return m___gl_vendor__.string_value (); }

  std::string get___gl_version__ (void) const { return m___gl_version__.string_value (); }

  bool is___gl_window__ (void) const { return m___gl_window__.is_on (); }
  std::string get___gl_window__ (void) const { return m___gl_window__.current_value (); }

  std::string get___graphics_toolkit__ (void) const { return m___graphics_toolkit__.string_value (); }

  octave_value get___guidata__ (void) const { return m___guidata__.get (); }

  bool __mouse_mode___is (const std::string& v) const { return m___mouse_mode__.is (v); }
  std::string get___mouse_mode__ (void) const { return m___mouse_mode__.current_value (); }

  bool is___printing__ (void) const { return m___printing__.is_on (); }
  std::string get___printing__ (void) const { return m___printing__.current_value (); }

  octave_value get___pan_mode__ (void) const { return m___pan_mode__.get (); }

  octave_value get___plot_stream__ (void) const { return m___plot_stream__.get (); }

  octave_value get___rotate_mode__ (void) const { return m___rotate_mode__.get (); }

  octave_value get___zoom_mode__ (void) const { return m___zoom_mode__.get (); }

  double get___device_pixel_ratio__ (void) const { return m___device_pixel_ratio__.double_value (); }


  void set_alphamap (const octave_value& val)
  {
    if (m_alphamap.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_buttondownfcn (const octave_value& val)
  {
    if (m_buttondownfcn.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_closerequestfcn (const octave_value& val)
  {
    if (m_closerequestfcn.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_color (const octave_value& val)
  {
    if (m_color.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_colormap (const octave_value& val)
  {
    if (m_colormap.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_currentaxes (const octave_value& val);

  void set_currentcharacter (const octave_value& val)
  {
    if (m_currentcharacter.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_currentobject (const octave_value& val)
  {
    if (m_currentobject.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_currentpoint (const octave_value& val)
  {
    if (m_currentpoint.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_dockcontrols (const octave_value& val)
  {
    if (m_dockcontrols.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_filename (const octave_value& val)
  {
    if (m_filename.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_graphicssmoothing (const octave_value& val)
  {
    if (m_graphicssmoothing.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_integerhandle (const octave_value& val);

  void set_inverthardcopy (const octave_value& val)
  {
    if (m_inverthardcopy.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_keypressfcn (const octave_value& val)
  {
    if (m_keypressfcn.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_keyreleasefcn (const octave_value& val)
  {
    if (m_keyreleasefcn.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_menubar (const octave_value& val)
  {
    if (m_menubar.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_name (const octave_value& val)
  {
    if (m_name.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_number (const octave_value& val)
  {
    if (m_number.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_nextplot (const octave_value& val)
  {
    if (m_nextplot.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_numbertitle (const octave_value& val)
  {
    if (m_numbertitle.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_paperorientation (const octave_value& val)
  {
    if (m_paperorientation.set (val, true))
      {
        update_paperorientation ();
        mark_modified ();
      }
  }

  void update_paperorientation (void);

  void set_paperposition (const octave_value& val)
  {
    if (m_paperposition.set (val, false))
      {
        set_paperpositionmode ("manual");
        m_paperposition.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
    else
      set_paperpositionmode ("manual");
  }

  void set_paperpositionmode (const octave_value& val)
  {
    if (m_paperpositionmode.set (val, true))
      {
        update_paperpositionmode ();
        mark_modified ();
      }
  }

  void set_papersize (const octave_value& val)
  {
    if (m_papersize.set (val, true))
      {
        update_papersize ();
        mark_modified ();
      }
  }

  void update_papersize (void);

  void set_papertype (const octave_value& val);

  void update_papertype (void);

  void set_paperunits (const octave_value& val);

  void set_pointer (const octave_value& val)
  {
    if (m_pointer.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_pointershapecdata (const octave_value& val)
  {
    if (m_pointershapecdata.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_pointershapehotspot (const octave_value& val)
  {
    if (m_pointershapehotspot.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_renderer (const octave_value& val)
  {
    if (m_renderer.set (val, false))
      {
        set_renderermode ("manual");
        m_renderer.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
    else
      set_renderermode ("manual");
  }

  void set_renderermode (const octave_value& val)
  {
    if (m_renderermode.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_resize (const octave_value& val)
  {
    if (m_resize.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_resizefcn (const octave_value& val)
  {
    if (m_resizefcn.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_selectiontype (const octave_value& val)
  {
    if (m_selectiontype.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_sizechangedfcn (const octave_value& val)
  {
    if (m_sizechangedfcn.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_toolbar (const octave_value& val)
  {
    if (m_toolbar.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_units (const octave_value& val);

  void set_windowbuttondownfcn (const octave_value& val)
  {
    if (m_windowbuttondownfcn.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_windowbuttonmotionfcn (const octave_value& val)
  {
    if (m_windowbuttonmotionfcn.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_windowbuttonupfcn (const octave_value& val)
  {
    if (m_windowbuttonupfcn.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_windowkeypressfcn (const octave_value& val)
  {
    if (m_windowkeypressfcn.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_windowkeyreleasefcn (const octave_value& val)
  {
    if (m_windowkeyreleasefcn.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_windowscrollwheelfcn (const octave_value& val)
  {
    if (m_windowscrollwheelfcn.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_windowstyle (const octave_value& val)
  {
    if (m_windowstyle.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_pickableparts (const octave_value& val)
  {
    if (m_pickableparts.set (val, true))
      {
        mark_modified ();
      }
  }

  void set___gl_extensions__ (const octave_value& val) const
  {
    if (m___gl_extensions__.set (val, true))
      {
      }
  }

  void set___gl_renderer__ (const octave_value& val) const
  {
    if (m___gl_renderer__.set (val, true))
      {
      }
  }

  void set___gl_vendor__ (const octave_value& val) const
  {
    if (m___gl_vendor__.set (val, true))
      {
      }
  }

  void set___gl_version__ (const octave_value& val) const
  {
    if (m___gl_version__.set (val, true))
      {
      }
  }

  void set___gl_window__ (const octave_value& val)
  {
    if (m___gl_window__.set (val, true))
      {
        mark_modified ();
      }
  }

  void set___guidata__ (const octave_value& val)
  {
    if (m___guidata__.set (val, true))
      {
        mark_modified ();
      }
  }

  void set___mouse_mode__ (const octave_value& val);

  void set___printing__ (const octave_value& val)
  {
    if (m___printing__.set (val, true))
      {
        mark_modified ();
      }
  }

  void set___pan_mode__ (const octave_value& val)
  {
    if (m___pan_mode__.set (val, true))
      {
        mark_modified ();
      }
  }

  void set___plot_stream__ (const octave_value& val)
  {
    if (m___plot_stream__.set (val, true))
      {
        mark_modified ();
      }
  }

  void set___rotate_mode__ (const octave_value& val)
  {
    if (m___rotate_mode__.set (val, true))
      {
        mark_modified ();
      }
  }

  void set___zoom_mode__ (const octave_value& val)
  {
    if (m___zoom_mode__.set (val, true))
      {
        mark_modified ();
      }
  }

  void set___device_pixel_ratio__ (const octave_value& val)
  {
    if (m___device_pixel_ratio__.set (val, true))
      {
        update___device_pixel_ratio__ ();
        mark_modified ();
      }
  }

  void update___device_pixel_ratio__ (void);


  protected:
    void init (void)
    {
      m_alphamap.add_constraint (dim_vector (-1, 1));
      m_alphamap.add_constraint (dim_vector (1, -1));
      m_colormap.add_constraint (dim_vector (-1, 3));
      m_colormap.add_constraint (dim_vector (0, 0));
      m_outerposition.add_constraint (dim_vector (1, 4));
      m_outerposition.add_constraint (FINITE);
      m_paperposition.add_constraint (dim_vector (1, 4));
      m_paperposition.add_constraint (FINITE);
      m_papersize.add_constraint (dim_vector (1, 2));
      m_papersize.add_constraint (FINITE);
      m_pointershapecdata.add_constraint (dim_vector (16, 16));
      m_pointershapecdata.add_constraint (dim_vector (32, 32));
      m_pointershapehotspot.add_constraint (dim_vector (1, 2));
      m_position.add_constraint (dim_vector (1, 4));
      m_position.add_constraint (FINITE);

      init_toolkit ();
    }

  private:
    OCTINTERP_API Matrix get_auto_paperposition (void);

    void update_paperpositionmode (void)
    {
      if (m_paperpositionmode.is ("auto"))
        m_paperposition.set (get_auto_paperposition ());
    }

    OCTINTERP_API void update_handlevisibility (void);

    OCTINTERP_API void init_toolkit (void);

    octave::graphics_toolkit m_toolkit;
  };

private:
  properties m_properties;

public:
  figure (const graphics_handle& mh, const graphics_handle& p)
    : base_graphics_object (), m_properties (mh, p), m_default_properties ()
  { }

  ~figure (void) = default;

  void override_defaults (base_graphics_object& obj)
  {
    // Allow parent (root object) to override first (properties knows how
    // to find the parent object).
    m_properties.override_defaults (obj);

    // Now override with our defaults.  If the default_properties
    // list includes the properties for all defaults (line,
    // surface, etc.) then we don't have to know the type of OBJ
    // here, we just call its set function and let it decide which
    // properties from the list to use.
    obj.set_from_list (m_default_properties);
  }

  void set (const caseless_str& name, const octave_value& value)
  {
    if (name.compare ("default", 7))
      // strip "default", pass rest to function that will
      // parse the remainder and add the element to the
      // default_properties map.
      m_default_properties.set (name.substr (7), value);
    else
      m_properties.set (name, value);
  }

  octave_value get (const caseless_str& name) const
  {
    octave_value retval;

    if (name.compare ("default", 7))
      retval = get_default (name.substr (7));
    else
      retval = m_properties.get (name);

    return retval;
  }

  OCTINTERP_API octave_value get_default (const caseless_str& name) const;

  octave_value get_defaults (void) const
  {
    return m_default_properties.as_struct ("default");
  }

  property_list get_defaults_list (void) const
  {
    return m_default_properties;
  }

  base_properties& get_properties (void) { return m_properties; }

  const base_properties& get_properties (void) const { return m_properties; }

  bool valid_object (void) const { return true; }

  OCTINTERP_API void reset_default_properties (void);

  bool has_readonly_property (const caseless_str& pname) const
  {
    bool retval = m_properties.has_readonly_property (pname);
    if (! retval)
      retval = base_properties::has_readonly_property (pname);
    return retval;
  }

private:
  property_list m_default_properties;
};

// ---------------------------------------------------------------------

class OCTINTERP_API graphics_xform
{
public:

  graphics_xform (void)
    : m_xform (xform_eye ()), m_xform_inv (xform_eye ()),
      m_sx ("linear"), m_sy ("linear"), m_sz ("linear"),  m_zlim (1, 2, 0.0)
  {
    m_zlim(1) = 1.0;
  }

  graphics_xform (const Matrix& xm, const Matrix& xim,
                  const scaler& x, const scaler& y, const scaler& z,
                  const Matrix& zl)
    : m_xform (xm), m_xform_inv (xim), m_sx (x), m_sy (y), m_sz (z), m_zlim (zl) { }

  graphics_xform (const graphics_xform& g)
    : m_xform (g.m_xform), m_xform_inv (g.m_xform_inv), m_sx (g.m_sx),
      m_sy (g.m_sy), m_sz (g.m_sz), m_zlim (g.m_zlim) { }

  ~graphics_xform (void) = default;

  graphics_xform& operator = (const graphics_xform& g)
  {
    m_xform = g.m_xform;
    m_xform_inv = g.m_xform_inv;
    m_sx = g.m_sx;
    m_sy = g.m_sy;
    m_sz = g.m_sz;
    m_zlim = g.m_zlim;

    return *this;
  }

  static OCTINTERP_API ColumnVector xform_vector (double x, double y, double z);

  static OCTINTERP_API Matrix xform_eye (void);

  OCTINTERP_API ColumnVector
  transform (double x, double y, double z, bool use_scale = true) const;

  OCTINTERP_API ColumnVector
  untransform (double x, double y, double z, bool use_scale = true) const;

  ColumnVector untransform (double x, double y, bool use_scale = true) const
  { return untransform (x, y, (m_zlim(0)+m_zlim(1))/2, use_scale); }

  Matrix xscale (const Matrix& m) const { return m_sx.scale (m); }
  Matrix yscale (const Matrix& m) const { return m_sy.scale (m); }
  Matrix zscale (const Matrix& m) const { return m_sz.scale (m); }

  Matrix scale (const Matrix& m) const
  {
    bool has_z = (m.columns () > 2);

    if (m_sx.is_linear () && m_sy.is_linear ()
        && (! has_z || m_sz.is_linear ()))
      return m;

    Matrix retval (m.dims ());

    int r = m.rows ();

    for (int i = 0; i < r; i++)
      {
        retval(i,0) = m_sx.scale (m(i,0));
        retval(i,1) = m_sy.scale (m(i,1));
        if (has_z)
          retval(i,2) = m_sz.scale (m(i,2));
      }

    return retval;
  }

private:
  Matrix m_xform;
  Matrix m_xform_inv;
  scaler m_sx, m_sy, m_sz;
  Matrix m_zlim;
};

enum
{
  AXE_ANY_DIR   = 0,
  AXE_DEPTH_DIR = 1,
  AXE_HORZ_DIR  = 2,
  AXE_VERT_DIR  = 3
};

class OCTINTERP_API axes : public base_graphics_object
{
public:

  class OCTINTERP_API properties : public base_properties
  {
  public:

    OCTINTERP_API void
    set_defaults (base_graphics_object& obj, const std::string& mode);

    OCTINTERP_API void
    remove_child (const graphics_handle& h, bool from_root = false);

    OCTINTERP_API void adopt (const graphics_handle& h);

    const scaler& get_x_scaler (void) const { return m_sx; }
    const scaler& get_y_scaler (void) const { return m_sy; }
    const scaler& get_z_scaler (void) const { return m_sz; }

    OCTINTERP_API Matrix
    get_boundingbox (bool internal = false,
                     const Matrix& parent_pix_size = Matrix ()) const;
    OCTINTERP_API Matrix
    get_extent (bool with_text = false,
                bool only_text_height=false) const;

    OCTINTERP_API double
    get___fontsize_points__ (double box_pix_height = 0) const;

    void update_boundingbox (void)
    {
      if (units_is ("normalized"))
        {
          sync_positions ();
          base_properties::update_boundingbox ();
        }
    }

    OCTINTERP_API void update_camera (void);
    OCTINTERP_API void update_axes_layout (void);
    OCTINTERP_API void update_aspectratios (void);
    void update_transform (void)
    {
      update_aspectratios ();
      update_camera ();
      update_axes_layout ();
    }

    OCTINTERP_API void sync_positions (void);

    // Redirect calls to "activepositionproperty" to "positionconstraint".

    std::string get_activepositionproperty (void) const
    {
      std::string cur_val;

      if (m_positionconstraint.is ("innerposition"))
        cur_val = "position";
      else
        cur_val = "outerposition";

      return cur_val;
    }

    void set_activepositionproperty (const octave_value& val)
    {
      // call set method to validate the input
      m_activepositionproperty.set (val);

      if (val.char_matrix_value ().row_as_string (0) == "position")
        set_positionconstraint ("innerposition");
      else
        set_positionconstraint (val);
    }

    // Redirect calls to "innerposition" to "position".

    octave_value get_innerposition (void) const
    {
      return get_position ();
    }

    void set_innerposition (const octave_value& val)
    {
      set_position (val);
    }

    OCTINTERP_API void update_autopos (const std::string& elem_type);
    OCTINTERP_API void update_xlabel_position (void);
    OCTINTERP_API void update_ylabel_position (void);
    OCTINTERP_API void update_zlabel_position (void);
    OCTINTERP_API void update_title_position (void);

    graphics_xform get_transform (void) const
    { return graphics_xform (m_x_render, m_x_render_inv, m_sx, m_sy, m_sz, m_x_zlim); }

    Matrix get_transform_matrix (void) const { return m_x_render; }
    Matrix get_inverse_transform_matrix (void) const { return m_x_render_inv; }
    Matrix get_opengl_matrix_1 (void) const { return m_x_gl_mat1; }
    Matrix get_opengl_matrix_2 (void) const { return m_x_gl_mat2; }
    Matrix get_transform_zlim (void) const { return m_x_zlim; }

    int get_xstate (void) const { return m_xstate; }
    int get_ystate (void) const { return m_ystate; }
    int get_zstate (void) const { return m_zstate; }
    double get_xPlane (void) const { return m_xPlane; }
    double get_xPlaneN (void) const { return m_xPlaneN; }
    double get_yPlane (void) const { return m_yPlane; }
    double get_yPlaneN (void) const { return m_yPlaneN; }
    double get_zPlane (void) const { return m_zPlane; }
    double get_zPlaneN (void) const { return m_zPlaneN; }
    double get_xpTick (void) const { return m_xpTick; }
    double get_xpTickN (void) const { return m_xpTickN; }
    double get_ypTick (void) const { return m_ypTick; }
    double get_ypTickN (void) const { return m_ypTickN; }
    double get_zpTick (void) const { return m_zpTick; }
    double get_zpTickN (void) const { return m_zpTickN; }
    double get_x_min (void) const { return std::min (m_xPlane, m_xPlaneN); }
    double get_x_max (void) const { return std::max (m_xPlane, m_xPlaneN); }
    double get_y_min (void) const { return std::min (m_yPlane, m_yPlaneN); }
    double get_y_max (void) const { return std::max (m_yPlane, m_yPlaneN); }
    double get_z_min (void) const { return std::min (m_zPlane, m_zPlaneN); }
    double get_z_max (void) const { return std::max (m_zPlane, m_zPlaneN); }
    double get_fx (void) const { return m_fx; }
    double get_fy (void) const { return m_fy; }
    double get_fz (void) const { return m_fz; }
    double get_xticklen (void) const { return m_xticklen; }
    double get_yticklen (void) const { return m_yticklen; }
    double get_zticklen (void) const { return m_zticklen; }
    double get_xtickoffset (void) const { return m_xtickoffset; }
    double get_ytickoffset (void) const { return m_ytickoffset; }
    double get_ztickoffset (void) const { return m_ztickoffset; }
    bool get_x2Dtop (void) const { return m_x2Dtop; }
    bool get_y2Dright (void) const { return m_y2Dright; }
    bool get_layer2Dtop (void) const { return m_layer2Dtop; }
    bool get_is2D (bool include_kids = false) const
    { return (include_kids ? (m_is2D && ! m_has3Dkids) : m_is2D); }
    void set_has3Dkids (bool val) { m_has3Dkids = val; }
    bool get_xySym (void) const { return m_xySym; }
    bool get_xyzSym (void) const { return m_xyzSym; }
    bool get_zSign (void) const { return m_zSign; }
    bool get_nearhoriz (void) const { return m_nearhoriz; }

    ColumnVector pixel2coord (double px, double py) const
    { return get_transform ().untransform (px, py, (m_x_zlim(0)+m_x_zlim(1))/2); }

    ColumnVector coord2pixel (double x, double y, double z) const
    { return get_transform ().transform (x, y, z); }

    OCTINTERP_API void
    zoom_about_point (const std::string& mode, double x, double y,
                      double factor, bool push_to_zoom_stack = true);
    OCTINTERP_API void
    zoom (const std::string& mode, double factor,
          bool push_to_zoom_stack = true);
    OCTINTERP_API void
    zoom (const std::string& mode, const Matrix& xl, const Matrix& yl,
          bool push_to_zoom_stack = true);

    OCTINTERP_API void
    translate_view (const std::string& mode,
                    double x0, double x1, double y0, double y1,
                    bool push_to_zoom_stack = true);

    OCTINTERP_API void
    pan (const std::string& mode, double factor,
         bool push_to_zoom_stack = true);

    OCTINTERP_API void
    rotate3d (double x0, double x1, double y0, double y1,
              bool push_to_zoom_stack = true);

    OCTINTERP_API void
    rotate_view (double delta_az, double delta_el,
                 bool push_to_zoom_stack = true);

    OCTINTERP_API void unzoom (void);
    OCTINTERP_API void update_handlevisibility (void);
    OCTINTERP_API void push_zoom_stack (void);
    OCTINTERP_API void clear_zoom_stack (bool do_unzoom = true);

    OCTINTERP_API void update_units (const caseless_str& old_units);

    OCTINTERP_API void update_font (std::string prop = "");

    OCTINTERP_API void update_fontunits (const caseless_str& old_fontunits);

    void increase_num_lights (void) { m_num_lights++; }
    void decrease_num_lights (void) { m_num_lights--; }
    unsigned int get_num_lights (void) const { return m_num_lights; }

  private:

    scaler m_sx = scaler ();
    scaler m_sy = scaler ();
    scaler m_sz = scaler ();

    Matrix m_x_render = Matrix ();
    Matrix m_x_render_inv = Matrix ();
    Matrix m_x_gl_mat1 = Matrix ();
    Matrix m_x_gl_mat2 = Matrix ();
    Matrix m_x_zlim = Matrix ();

    std::list<octave_value> m_zoom_stack = std::list<octave_value> ();

    // Axes layout data
    int m_xstate = 0;
    int m_ystate = 0;
    int m_zstate = 0;

    double m_xPlane = 0.0;
    double m_yPlane = 0.0;
    double m_zPlane = 0.0;

    double m_xPlaneN = 0.0;
    double m_yPlaneN = 0.0;
    double m_zPlaneN = 0.0;

    double m_xpTick = 0.0;
    double m_ypTick = 0.0;
    double m_zpTick = 0.0;

    double m_xpTickN = 0.0;
    double m_ypTickN = 0.0;
    double m_zpTickN = 0.0;

    double m_fx = 0.0;
    double m_fy = 0.0;
    double m_fz = 0.0;

    double m_xticklen = 0.0;
    double m_yticklen = 0.0;
    double m_zticklen = 0.0;

    double m_xtickoffset = 0.0;
    double m_ytickoffset = 0.0;
    double m_ztickoffset = 0.0;

    bool m_x2Dtop = false;
    bool m_y2Dright = false;
    bool m_layer2Dtop = false;
    bool m_is2D = false;
    bool m_has3Dkids = false;
    bool m_xySym = false;
    bool m_xyzSym = false;
    bool m_zSign = false;
    bool m_nearhoriz = false;

    unsigned int m_num_lights = 0;

    // Text renderer, used for calculation of text (tick labels) size
    octave::text_renderer m_txt_renderer;

    OCTINTERP_API void
    set_text_child (handle_property& h, const std::string& who,
                    const octave_value& v);

    OCTINTERP_API void
    delete_text_child (handle_property& h, bool from_root = false);

    // See the genprops.awk script for an explanation of the
    // properties declarations.
    // Programming note: Keep property list sorted if new ones are added.

public:
  properties (const graphics_handle& mh, const graphics_handle& p);

  ~properties (void) { }

  void set (const caseless_str& pname, const octave_value& val);

  octave_value get (bool all = false) const;

  octave_value get (const caseless_str& pname) const;

  octave_value get (const std::string& pname) const
  {
    return get (caseless_str (pname));
  }

  octave_value get (const char *pname) const
  {
    return get (caseless_str (pname));
  }

  property get_property (const caseless_str& pname);

  std::string graphics_object_name (void) const { return s_go_name; }

  static property_list::pval_map_type factory_defaults (void);

private:
  static std::string s_go_name;

public:


  static std::set<std::string> core_property_names (void);

  static std::set<std::string> readonly_property_names (void);

  static bool has_core_property (const caseless_str& pname);

  static bool has_readonly_property (const caseless_str& pname);

  std::set<std::string> all_property_names (void) const;

  bool has_property (const caseless_str& pname) const;

private:

  radio_property m_activepositionproperty;
  row_vector_property m_alim;
  radio_property m_alimmode;
  array_property m_alphamap;
  radio_property m_alphascale;
  color_property m_ambientlightcolor;
  bool_property m_box;
  radio_property m_boxstyle;
  row_vector_property m_cameraposition;
  radio_property m_camerapositionmode;
  row_vector_property m_cameratarget;
  radio_property m_cameratargetmode;
  row_vector_property m_cameraupvector;
  radio_property m_cameraupvectormode;
  double_property m_cameraviewangle;
  radio_property m_cameraviewanglemode;
  row_vector_property m_clim;
  radio_property m_climmode;
  radio_property m_clippingstyle;
  color_property m_color;
  array_property m_colormap;
  array_property m_colororder;
  double_property m_colororderindex;
  radio_property m_colorscale;
  array_property m_currentpoint;
  row_vector_property m_dataaspectratio;
  radio_property m_dataaspectratiomode;
  radio_property m_fontangle;
  string_property m_fontname;
  double_property m_fontsize;
  radio_property m_fontsizemode;
  bool_property m_fontsmoothing;
  radio_property m_fontunits;
  radio_property m_fontweight;
  double_property m_gridalpha;
  radio_property m_gridalphamode;
  color_property m_gridcolor;
  radio_property m_gridcolormode;
  radio_property m_gridlinestyle;
  array_property m_innerposition;
  any_property m_interactions;
  double_property m_labelfontsizemultiplier;
  radio_property m_layer;
  handle_property m_layout;
  handle_property m_legend;
  any_property m_linestyleorder;
  double_property m_linestyleorderindex;
  double_property m_linewidth;
  double_property m_minorgridalpha;
  radio_property m_minorgridalphamode;
  color_property m_minorgridcolor;
  radio_property m_minorgridcolormode;
  radio_property m_minorgridlinestyle;
  radio_property m_nextplot;
  double_property m_nextseriesindex;
  array_property m_outerposition;
  row_vector_property m_plotboxaspectratio;
  radio_property m_plotboxaspectratiomode;
  array_property m_position;
  radio_property m_positionconstraint;
  radio_property m_projection;
  radio_property m_sortmethod;
  radio_property m_tickdir;
  radio_property m_tickdirmode;
  radio_property m_ticklabelinterpreter;
  array_property m_ticklength;
  array_property m_tightinset;
  handle_property m_title;
  double_property m_titlefontsizemultiplier;
  radio_property m_titlefontweight;
  handle_property m_toolbar;
  radio_property m_units;
  array_property m_view;
  handle_property m_xaxis;
  radio_property m_xaxislocation;
  color_property m_xcolor;
  radio_property m_xcolormode;
  radio_property m_xdir;
  bool_property m_xgrid;
  handle_property m_xlabel;
  row_vector_property m_xlim;
  radio_property m_xlimmode;
  bool_property m_xminorgrid;
  bool_property m_xminortick;
  radio_property m_xscale;
  row_vector_property m_xtick;
  any_property m_xticklabel;
  radio_property m_xticklabelmode;
  double_property m_xticklabelrotation;
  radio_property m_xtickmode;
  handle_property m_yaxis;
  radio_property m_yaxislocation;
  color_property m_ycolor;
  radio_property m_ycolormode;
  radio_property m_ydir;
  bool_property m_ygrid;
  handle_property m_ylabel;
  row_vector_property m_ylim;
  radio_property m_ylimmode;
  bool_property m_yminorgrid;
  bool_property m_yminortick;
  radio_property m_yscale;
  row_vector_property m_ytick;
  any_property m_yticklabel;
  radio_property m_yticklabelmode;
  double_property m_yticklabelrotation;
  radio_property m_ytickmode;
  handle_property m_zaxis;
  color_property m_zcolor;
  radio_property m_zcolormode;
  radio_property m_zdir;
  bool_property m_zgrid;
  handle_property m_zlabel;
  row_vector_property m_zlim;
  radio_property m_zlimmode;
  bool_property m_zminorgrid;
  bool_property m_zminortick;
  radio_property m_zscale;
  row_vector_property m_ztick;
  any_property m_zticklabel;
  radio_property m_zticklabelmode;
  double_property m_zticklabelrotation;
  radio_property m_ztickmode;
  array_property m___colormap__;
  double_property m_mousewheelzoom;
  radio_property m___autopos_tag__;
  array_property m_looseinset;
  row_vector_property m_xminortickvalues;
  row_vector_property m_yminortickvalues;
  row_vector_property m_zminortickvalues;
  double_property m___fontsize_points__;

public:

  enum
  {
    ID_ACTIVEPOSITIONPROPERTY = 3000,
    ID_ALIM = 3001,
    ID_ALIMMODE = 3002,
    ID_ALPHAMAP = 3003,
    ID_ALPHASCALE = 3004,
    ID_AMBIENTLIGHTCOLOR = 3005,
    ID_BOX = 3006,
    ID_BOXSTYLE = 3007,
    ID_CAMERAPOSITION = 3008,
    ID_CAMERAPOSITIONMODE = 3009,
    ID_CAMERATARGET = 3010,
    ID_CAMERATARGETMODE = 3011,
    ID_CAMERAUPVECTOR = 3012,
    ID_CAMERAUPVECTORMODE = 3013,
    ID_CAMERAVIEWANGLE = 3014,
    ID_CAMERAVIEWANGLEMODE = 3015,
    ID_CLIM = 3016,
    ID_CLIMMODE = 3017,
    ID_CLIPPINGSTYLE = 3018,
    ID_COLOR = 3019,
    ID_COLORMAP = 3020,
    ID_COLORORDER = 3021,
    ID_COLORORDERINDEX = 3022,
    ID_COLORSCALE = 3023,
    ID_CURRENTPOINT = 3024,
    ID_DATAASPECTRATIO = 3025,
    ID_DATAASPECTRATIOMODE = 3026,
    ID_FONTANGLE = 3027,
    ID_FONTNAME = 3028,
    ID_FONTSIZE = 3029,
    ID_FONTSIZEMODE = 3030,
    ID_FONTSMOOTHING = 3031,
    ID_FONTUNITS = 3032,
    ID_FONTWEIGHT = 3033,
    ID_GRIDALPHA = 3034,
    ID_GRIDALPHAMODE = 3035,
    ID_GRIDCOLOR = 3036,
    ID_GRIDCOLORMODE = 3037,
    ID_GRIDLINESTYLE = 3038,
    ID_INNERPOSITION = 3039,
    ID_INTERACTIONS = 3040,
    ID_LABELFONTSIZEMULTIPLIER = 3041,
    ID_LAYER = 3042,
    ID_LAYOUT = 3043,
    ID_LEGEND = 3044,
    ID_LINESTYLEORDER = 3045,
    ID_LINESTYLEORDERINDEX = 3046,
    ID_LINEWIDTH = 3047,
    ID_MINORGRIDALPHA = 3048,
    ID_MINORGRIDALPHAMODE = 3049,
    ID_MINORGRIDCOLOR = 3050,
    ID_MINORGRIDCOLORMODE = 3051,
    ID_MINORGRIDLINESTYLE = 3052,
    ID_NEXTPLOT = 3053,
    ID_NEXTSERIESINDEX = 3054,
    ID_OUTERPOSITION = 3055,
    ID_PLOTBOXASPECTRATIO = 3056,
    ID_PLOTBOXASPECTRATIOMODE = 3057,
    ID_POSITION = 3058,
    ID_POSITIONCONSTRAINT = 3059,
    ID_PROJECTION = 3060,
    ID_SORTMETHOD = 3061,
    ID_TICKDIR = 3062,
    ID_TICKDIRMODE = 3063,
    ID_TICKLABELINTERPRETER = 3064,
    ID_TICKLENGTH = 3065,
    ID_TIGHTINSET = 3066,
    ID_TITLE = 3067,
    ID_TITLEFONTSIZEMULTIPLIER = 3068,
    ID_TITLEFONTWEIGHT = 3069,
    ID_TOOLBAR = 3070,
    ID_UNITS = 3071,
    ID_VIEW = 3072,
    ID_XAXIS = 3073,
    ID_XAXISLOCATION = 3074,
    ID_XCOLOR = 3075,
    ID_XCOLORMODE = 3076,
    ID_XDIR = 3077,
    ID_XGRID = 3078,
    ID_XLABEL = 3079,
    ID_XLIM = 3080,
    ID_XLIMMODE = 3081,
    ID_XMINORGRID = 3082,
    ID_XMINORTICK = 3083,
    ID_XSCALE = 3084,
    ID_XTICK = 3085,
    ID_XTICKLABEL = 3086,
    ID_XTICKLABELMODE = 3087,
    ID_XTICKLABELROTATION = 3088,
    ID_XTICKMODE = 3089,
    ID_YAXIS = 3090,
    ID_YAXISLOCATION = 3091,
    ID_YCOLOR = 3092,
    ID_YCOLORMODE = 3093,
    ID_YDIR = 3094,
    ID_YGRID = 3095,
    ID_YLABEL = 3096,
    ID_YLIM = 3097,
    ID_YLIMMODE = 3098,
    ID_YMINORGRID = 3099,
    ID_YMINORTICK = 3100,
    ID_YSCALE = 3101,
    ID_YTICK = 3102,
    ID_YTICKLABEL = 3103,
    ID_YTICKLABELMODE = 3104,
    ID_YTICKLABELROTATION = 3105,
    ID_YTICKMODE = 3106,
    ID_ZAXIS = 3107,
    ID_ZCOLOR = 3108,
    ID_ZCOLORMODE = 3109,
    ID_ZDIR = 3110,
    ID_ZGRID = 3111,
    ID_ZLABEL = 3112,
    ID_ZLIM = 3113,
    ID_ZLIMMODE = 3114,
    ID_ZMINORGRID = 3115,
    ID_ZMINORTICK = 3116,
    ID_ZSCALE = 3117,
    ID_ZTICK = 3118,
    ID_ZTICKLABEL = 3119,
    ID_ZTICKLABELMODE = 3120,
    ID_ZTICKLABELROTATION = 3121,
    ID_ZTICKMODE = 3122,
    ID___COLORMAP__ = 3123,
    ID_MOUSEWHEELZOOM = 3124,
    ID___AUTOPOS_TAG__ = 3125,
    ID_LOOSEINSET = 3126,
    ID_XMINORTICKVALUES = 3127,
    ID_YMINORTICKVALUES = 3128,
    ID_ZMINORTICKVALUES = 3129,
    ID___FONTSIZE_POINTS__ = 3130
  };

  octave_value get_alim (void) const { return m_alim.get (); }

  bool alimmode_is (const std::string& v) const { return m_alimmode.is (v); }
  std::string get_alimmode (void) const { return m_alimmode.current_value (); }

  octave_value get_alphamap (void) const { return m_alphamap.get (); }

  bool alphascale_is (const std::string& v) const { return m_alphascale.is (v); }
  std::string get_alphascale (void) const { return m_alphascale.current_value (); }

  bool ambientlightcolor_is_rgb (void) const { return m_ambientlightcolor.is_rgb (); }
  bool ambientlightcolor_is (const std::string& v) const { return m_ambientlightcolor.is (v); }
  Matrix get_ambientlightcolor_rgb (void) const { return (m_ambientlightcolor.is_rgb () ? m_ambientlightcolor.rgb () : Matrix ()); }
  octave_value get_ambientlightcolor (void) const { return m_ambientlightcolor.get (); }

  bool is_box (void) const { return m_box.is_on (); }
  std::string get_box (void) const { return m_box.current_value (); }

  bool boxstyle_is (const std::string& v) const { return m_boxstyle.is (v); }
  std::string get_boxstyle (void) const { return m_boxstyle.current_value (); }

  octave_value get_cameraposition (void) const { return m_cameraposition.get (); }

  bool camerapositionmode_is (const std::string& v) const { return m_camerapositionmode.is (v); }
  std::string get_camerapositionmode (void) const { return m_camerapositionmode.current_value (); }

  octave_value get_cameratarget (void) const { return m_cameratarget.get (); }

  bool cameratargetmode_is (const std::string& v) const { return m_cameratargetmode.is (v); }
  std::string get_cameratargetmode (void) const { return m_cameratargetmode.current_value (); }

  octave_value get_cameraupvector (void) const { return m_cameraupvector.get (); }

  bool cameraupvectormode_is (const std::string& v) const { return m_cameraupvectormode.is (v); }
  std::string get_cameraupvectormode (void) const { return m_cameraupvectormode.current_value (); }

  double get_cameraviewangle (void) const { return m_cameraviewangle.double_value (); }

  bool cameraviewanglemode_is (const std::string& v) const { return m_cameraviewanglemode.is (v); }
  std::string get_cameraviewanglemode (void) const { return m_cameraviewanglemode.current_value (); }

  octave_value get_clim (void) const { return m_clim.get (); }

  bool climmode_is (const std::string& v) const { return m_climmode.is (v); }
  std::string get_climmode (void) const { return m_climmode.current_value (); }

  bool clippingstyle_is (const std::string& v) const { return m_clippingstyle.is (v); }
  std::string get_clippingstyle (void) const { return m_clippingstyle.current_value (); }

  bool color_is_rgb (void) const { return m_color.is_rgb (); }
  bool color_is (const std::string& v) const { return m_color.is (v); }
  Matrix get_color_rgb (void) const { return (m_color.is_rgb () ? m_color.rgb () : Matrix ()); }
  octave_value get_color (void) const { return m_color.get (); }

  octave_value get_colororder (void) const { return m_colororder.get (); }

  double get_colororderindex (void) const { return m_colororderindex.double_value (); }

  bool colorscale_is (const std::string& v) const { return m_colorscale.is (v); }
  std::string get_colorscale (void) const { return m_colorscale.current_value (); }

  octave_value get_currentpoint (void) const { return m_currentpoint.get (); }

  octave_value get_dataaspectratio (void) const { return m_dataaspectratio.get (); }

  bool dataaspectratiomode_is (const std::string& v) const { return m_dataaspectratiomode.is (v); }
  std::string get_dataaspectratiomode (void) const { return m_dataaspectratiomode.current_value (); }

  bool fontangle_is (const std::string& v) const { return m_fontangle.is (v); }
  std::string get_fontangle (void) const { return m_fontangle.current_value (); }

  std::string get_fontname (void) const { return m_fontname.string_value (); }

  double get_fontsize (void) const { return m_fontsize.double_value (); }

  bool fontsizemode_is (const std::string& v) const { return m_fontsizemode.is (v); }
  std::string get_fontsizemode (void) const { return m_fontsizemode.current_value (); }

  bool is_fontsmoothing (void) const { return m_fontsmoothing.is_on (); }
  std::string get_fontsmoothing (void) const { return m_fontsmoothing.current_value (); }

  bool fontunits_is (const std::string& v) const { return m_fontunits.is (v); }
  std::string get_fontunits (void) const { return m_fontunits.current_value (); }

  bool fontweight_is (const std::string& v) const { return m_fontweight.is (v); }
  std::string get_fontweight (void) const { return m_fontweight.current_value (); }

  double get_gridalpha (void) const { return m_gridalpha.double_value (); }

  bool gridalphamode_is (const std::string& v) const { return m_gridalphamode.is (v); }
  std::string get_gridalphamode (void) const { return m_gridalphamode.current_value (); }

  bool gridcolor_is_rgb (void) const { return m_gridcolor.is_rgb (); }
  bool gridcolor_is (const std::string& v) const { return m_gridcolor.is (v); }
  Matrix get_gridcolor_rgb (void) const { return (m_gridcolor.is_rgb () ? m_gridcolor.rgb () : Matrix ()); }
  octave_value get_gridcolor (void) const { return m_gridcolor.get (); }

  bool gridcolormode_is (const std::string& v) const { return m_gridcolormode.is (v); }
  std::string get_gridcolormode (void) const { return m_gridcolormode.current_value (); }

  bool gridlinestyle_is (const std::string& v) const { return m_gridlinestyle.is (v); }
  std::string get_gridlinestyle (void) const { return m_gridlinestyle.current_value (); }

  octave_value get_interactions (void) const { return m_interactions.get (); }

  double get_labelfontsizemultiplier (void) const { return m_labelfontsizemultiplier.double_value (); }

  bool layer_is (const std::string& v) const { return m_layer.is (v); }
  std::string get_layer (void) const { return m_layer.current_value (); }

  graphics_handle get_layout (void) const { return m_layout.handle_value (); }

  graphics_handle get_legend (void) const { return m_legend.handle_value (); }

  octave_value get_linestyleorder (void) const { return m_linestyleorder.get (); }

  double get_linestyleorderindex (void) const { return m_linestyleorderindex.double_value (); }

  double get_linewidth (void) const { return m_linewidth.double_value (); }

  double get_minorgridalpha (void) const { return m_minorgridalpha.double_value (); }

  bool minorgridalphamode_is (const std::string& v) const { return m_minorgridalphamode.is (v); }
  std::string get_minorgridalphamode (void) const { return m_minorgridalphamode.current_value (); }

  bool minorgridcolor_is_rgb (void) const { return m_minorgridcolor.is_rgb (); }
  bool minorgridcolor_is (const std::string& v) const { return m_minorgridcolor.is (v); }
  Matrix get_minorgridcolor_rgb (void) const { return (m_minorgridcolor.is_rgb () ? m_minorgridcolor.rgb () : Matrix ()); }
  octave_value get_minorgridcolor (void) const { return m_minorgridcolor.get (); }

  bool minorgridcolormode_is (const std::string& v) const { return m_minorgridcolormode.is (v); }
  std::string get_minorgridcolormode (void) const { return m_minorgridcolormode.current_value (); }

  bool minorgridlinestyle_is (const std::string& v) const { return m_minorgridlinestyle.is (v); }
  std::string get_minorgridlinestyle (void) const { return m_minorgridlinestyle.current_value (); }

  bool nextplot_is (const std::string& v) const { return m_nextplot.is (v); }
  std::string get_nextplot (void) const { return m_nextplot.current_value (); }

  double get_nextseriesindex (void) const { return m_nextseriesindex.double_value (); }

  octave_value get_outerposition (void) const { return m_outerposition.get (); }

  octave_value get_plotboxaspectratio (void) const { return m_plotboxaspectratio.get (); }

  bool plotboxaspectratiomode_is (const std::string& v) const { return m_plotboxaspectratiomode.is (v); }
  std::string get_plotboxaspectratiomode (void) const { return m_plotboxaspectratiomode.current_value (); }

  octave_value get_position (void) const { return m_position.get (); }

  bool positionconstraint_is (const std::string& v) const { return m_positionconstraint.is (v); }
  std::string get_positionconstraint (void) const { return m_positionconstraint.current_value (); }

  bool projection_is (const std::string& v) const { return m_projection.is (v); }
  std::string get_projection (void) const { return m_projection.current_value (); }

  bool sortmethod_is (const std::string& v) const { return m_sortmethod.is (v); }
  std::string get_sortmethod (void) const { return m_sortmethod.current_value (); }

  bool tickdir_is (const std::string& v) const { return m_tickdir.is (v); }
  std::string get_tickdir (void) const { return m_tickdir.current_value (); }

  bool tickdirmode_is (const std::string& v) const { return m_tickdirmode.is (v); }
  std::string get_tickdirmode (void) const { return m_tickdirmode.current_value (); }

  bool ticklabelinterpreter_is (const std::string& v) const { return m_ticklabelinterpreter.is (v); }
  std::string get_ticklabelinterpreter (void) const { return m_ticklabelinterpreter.current_value (); }

  octave_value get_ticklength (void) const { return m_ticklength.get (); }

  octave_value get_tightinset (void) const { return m_tightinset.get (); }

  graphics_handle get_title (void) const { return m_title.handle_value (); }

  double get_titlefontsizemultiplier (void) const { return m_titlefontsizemultiplier.double_value (); }

  bool titlefontweight_is (const std::string& v) const { return m_titlefontweight.is (v); }
  std::string get_titlefontweight (void) const { return m_titlefontweight.current_value (); }

  graphics_handle get_toolbar (void) const { return m_toolbar.handle_value (); }

  bool units_is (const std::string& v) const { return m_units.is (v); }
  std::string get_units (void) const { return m_units.current_value (); }

  octave_value get_view (void) const { return m_view.get (); }

  graphics_handle get_xaxis (void) const { return m_xaxis.handle_value (); }

  bool xaxislocation_is (const std::string& v) const { return m_xaxislocation.is (v); }
  std::string get_xaxislocation (void) const { return m_xaxislocation.current_value (); }

  bool xcolor_is_rgb (void) const { return m_xcolor.is_rgb (); }
  bool xcolor_is (const std::string& v) const { return m_xcolor.is (v); }
  Matrix get_xcolor_rgb (void) const { return (m_xcolor.is_rgb () ? m_xcolor.rgb () : Matrix ()); }
  octave_value get_xcolor (void) const { return m_xcolor.get (); }

  bool xcolormode_is (const std::string& v) const { return m_xcolormode.is (v); }
  std::string get_xcolormode (void) const { return m_xcolormode.current_value (); }

  bool xdir_is (const std::string& v) const { return m_xdir.is (v); }
  std::string get_xdir (void) const { return m_xdir.current_value (); }

  bool is_xgrid (void) const { return m_xgrid.is_on (); }
  std::string get_xgrid (void) const { return m_xgrid.current_value (); }

  graphics_handle get_xlabel (void) const { return m_xlabel.handle_value (); }

  octave_value get_xlim (void) const { return m_xlim.get (); }

  bool xlimmode_is (const std::string& v) const { return m_xlimmode.is (v); }
  std::string get_xlimmode (void) const { return m_xlimmode.current_value (); }

  bool is_xminorgrid (void) const { return m_xminorgrid.is_on (); }
  std::string get_xminorgrid (void) const { return m_xminorgrid.current_value (); }

  bool is_xminortick (void) const { return m_xminortick.is_on (); }
  std::string get_xminortick (void) const { return m_xminortick.current_value (); }

  bool xscale_is (const std::string& v) const { return m_xscale.is (v); }
  std::string get_xscale (void) const { return m_xscale.current_value (); }

  octave_value get_xtick (void) const { return m_xtick.get (); }

  octave_value get_xticklabel (void) const { return m_xticklabel.get (); }

  bool xticklabelmode_is (const std::string& v) const { return m_xticklabelmode.is (v); }
  std::string get_xticklabelmode (void) const { return m_xticklabelmode.current_value (); }

  double get_xticklabelrotation (void) const { return m_xticklabelrotation.double_value (); }

  bool xtickmode_is (const std::string& v) const { return m_xtickmode.is (v); }
  std::string get_xtickmode (void) const { return m_xtickmode.current_value (); }

  graphics_handle get_yaxis (void) const { return m_yaxis.handle_value (); }

  bool yaxislocation_is (const std::string& v) const { return m_yaxislocation.is (v); }
  std::string get_yaxislocation (void) const { return m_yaxislocation.current_value (); }

  bool ycolor_is_rgb (void) const { return m_ycolor.is_rgb (); }
  bool ycolor_is (const std::string& v) const { return m_ycolor.is (v); }
  Matrix get_ycolor_rgb (void) const { return (m_ycolor.is_rgb () ? m_ycolor.rgb () : Matrix ()); }
  octave_value get_ycolor (void) const { return m_ycolor.get (); }

  bool ycolormode_is (const std::string& v) const { return m_ycolormode.is (v); }
  std::string get_ycolormode (void) const { return m_ycolormode.current_value (); }

  bool ydir_is (const std::string& v) const { return m_ydir.is (v); }
  std::string get_ydir (void) const { return m_ydir.current_value (); }

  bool is_ygrid (void) const { return m_ygrid.is_on (); }
  std::string get_ygrid (void) const { return m_ygrid.current_value (); }

  graphics_handle get_ylabel (void) const { return m_ylabel.handle_value (); }

  octave_value get_ylim (void) const { return m_ylim.get (); }

  bool ylimmode_is (const std::string& v) const { return m_ylimmode.is (v); }
  std::string get_ylimmode (void) const { return m_ylimmode.current_value (); }

  bool is_yminorgrid (void) const { return m_yminorgrid.is_on (); }
  std::string get_yminorgrid (void) const { return m_yminorgrid.current_value (); }

  bool is_yminortick (void) const { return m_yminortick.is_on (); }
  std::string get_yminortick (void) const { return m_yminortick.current_value (); }

  bool yscale_is (const std::string& v) const { return m_yscale.is (v); }
  std::string get_yscale (void) const { return m_yscale.current_value (); }

  octave_value get_ytick (void) const { return m_ytick.get (); }

  octave_value get_yticklabel (void) const { return m_yticklabel.get (); }

  bool yticklabelmode_is (const std::string& v) const { return m_yticklabelmode.is (v); }
  std::string get_yticklabelmode (void) const { return m_yticklabelmode.current_value (); }

  double get_yticklabelrotation (void) const { return m_yticklabelrotation.double_value (); }

  bool ytickmode_is (const std::string& v) const { return m_ytickmode.is (v); }
  std::string get_ytickmode (void) const { return m_ytickmode.current_value (); }

  graphics_handle get_zaxis (void) const { return m_zaxis.handle_value (); }

  bool zcolor_is_rgb (void) const { return m_zcolor.is_rgb (); }
  bool zcolor_is (const std::string& v) const { return m_zcolor.is (v); }
  Matrix get_zcolor_rgb (void) const { return (m_zcolor.is_rgb () ? m_zcolor.rgb () : Matrix ()); }
  octave_value get_zcolor (void) const { return m_zcolor.get (); }

  bool zcolormode_is (const std::string& v) const { return m_zcolormode.is (v); }
  std::string get_zcolormode (void) const { return m_zcolormode.current_value (); }

  bool zdir_is (const std::string& v) const { return m_zdir.is (v); }
  std::string get_zdir (void) const { return m_zdir.current_value (); }

  bool is_zgrid (void) const { return m_zgrid.is_on (); }
  std::string get_zgrid (void) const { return m_zgrid.current_value (); }

  graphics_handle get_zlabel (void) const { return m_zlabel.handle_value (); }

  octave_value get_zlim (void) const { return m_zlim.get (); }

  bool zlimmode_is (const std::string& v) const { return m_zlimmode.is (v); }
  std::string get_zlimmode (void) const { return m_zlimmode.current_value (); }

  bool is_zminorgrid (void) const { return m_zminorgrid.is_on (); }
  std::string get_zminorgrid (void) const { return m_zminorgrid.current_value (); }

  bool is_zminortick (void) const { return m_zminortick.is_on (); }
  std::string get_zminortick (void) const { return m_zminortick.current_value (); }

  bool zscale_is (const std::string& v) const { return m_zscale.is (v); }
  std::string get_zscale (void) const { return m_zscale.current_value (); }

  octave_value get_ztick (void) const { return m_ztick.get (); }

  octave_value get_zticklabel (void) const { return m_zticklabel.get (); }

  bool zticklabelmode_is (const std::string& v) const { return m_zticklabelmode.is (v); }
  std::string get_zticklabelmode (void) const { return m_zticklabelmode.current_value (); }

  double get_zticklabelrotation (void) const { return m_zticklabelrotation.double_value (); }

  bool ztickmode_is (const std::string& v) const { return m_ztickmode.is (v); }
  std::string get_ztickmode (void) const { return m_ztickmode.current_value (); }

  octave_value get___colormap__ (void) const { return m___colormap__.get (); }

  double get_mousewheelzoom (void) const { return m_mousewheelzoom.double_value (); }

  bool __autopos_tag___is (const std::string& v) const { return m___autopos_tag__.is (v); }
  std::string get___autopos_tag__ (void) const { return m___autopos_tag__.current_value (); }

  octave_value get_looseinset (void) const { return m_looseinset.get (); }

  octave_value get_xminortickvalues (void) const { return m_xminortickvalues.get (); }

  octave_value get_yminortickvalues (void) const { return m_yminortickvalues.get (); }

  octave_value get_zminortickvalues (void) const { return m_zminortickvalues.get (); }


  void set_alim (const octave_value& val)
  {
    if (m_alim.set (val, false))
      {
        set_alimmode ("manual");
        m_alim.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
    else
      set_alimmode ("manual");
  }

  void set_alimmode (const octave_value& val)
  {
    if (m_alimmode.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_alphamap (const octave_value& val)
  {
    if (m_alphamap.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_alphascale (const octave_value& val)
  {
    if (m_alphascale.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_ambientlightcolor (const octave_value& val)
  {
    if (m_ambientlightcolor.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_box (const octave_value& val)
  {
    if (m_box.set (val, true))
      {
        update_box ();
        mark_modified ();
      }
  }

  void set_boxstyle (const octave_value& val)
  {
    if (m_boxstyle.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_cameraposition (const octave_value& val)
  {
    if (m_cameraposition.set (val, false))
      {
        set_camerapositionmode ("manual");
        update_cameraposition ();
        m_cameraposition.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
    else
      set_camerapositionmode ("manual");
  }

  void set_camerapositionmode (const octave_value& val)
  {
    if (m_camerapositionmode.set (val, true))
      {
        update_camerapositionmode ();
        mark_modified ();
      }
  }

  void set_cameratarget (const octave_value& val)
  {
    if (m_cameratarget.set (val, false))
      {
        set_cameratargetmode ("manual");
        update_cameratarget ();
        m_cameratarget.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
    else
      set_cameratargetmode ("manual");
  }

  void set_cameratargetmode (const octave_value& val)
  {
    if (m_cameratargetmode.set (val, true))
      {
        update_cameratargetmode ();
        mark_modified ();
      }
  }

  void set_cameraupvector (const octave_value& val)
  {
    if (m_cameraupvector.set (val, false))
      {
        set_cameraupvectormode ("manual");
        update_cameraupvector ();
        m_cameraupvector.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
    else
      set_cameraupvectormode ("manual");
  }

  void set_cameraupvectormode (const octave_value& val)
  {
    if (m_cameraupvectormode.set (val, true))
      {
        update_cameraupvectormode ();
        mark_modified ();
      }
  }

  void set_cameraviewangle (const octave_value& val)
  {
    if (m_cameraviewangle.set (val, false))
      {
        set_cameraviewanglemode ("manual");
        update_cameraviewangle ();
        m_cameraviewangle.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
    else
      set_cameraviewanglemode ("manual");
  }

  void set_cameraviewanglemode (const octave_value& val)
  {
    if (m_cameraviewanglemode.set (val, true))
      {
        update_cameraviewanglemode ();
        mark_modified ();
      }
  }

  void set_clim (const octave_value& val)
  {
    if (m_clim.set (val, false))
      {
        set_climmode ("manual");
        m_clim.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
    else
      set_climmode ("manual");
  }

  void set_climmode (const octave_value& val)
  {
    if (m_climmode.set (val, false))
      {
        update_axis_limits ("climmode");
        m_climmode.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
  }

  void set_clippingstyle (const octave_value& val)
  {
    if (m_clippingstyle.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_color (const octave_value& val)
  {
    if (m_color.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_colororder (const octave_value& val)
  {
    if (m_colororder.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_colororderindex (const octave_value& val)
  {
    if (m_colororderindex.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_colorscale (const octave_value& val)
  {
    if (m_colorscale.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_currentpoint (const octave_value& val)
  {
    if (m_currentpoint.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_dataaspectratio (const octave_value& val)
  {
    if (m_dataaspectratio.set (val, false))
      {
        set_dataaspectratiomode ("manual");
        update_dataaspectratio ();
        m_dataaspectratio.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
    else
      set_dataaspectratiomode ("manual");
  }

  void set_dataaspectratiomode (const octave_value& val)
  {
    if (m_dataaspectratiomode.set (val, true))
      {
        update_dataaspectratiomode ();
        mark_modified ();
      }
  }

  void set_fontangle (const octave_value& val)
  {
    if (m_fontangle.set (val, true))
      {
        update_fontangle ();
        mark_modified ();
      }
  }

  void set_fontname (const octave_value& val)
  {
    if (m_fontname.set (val, true))
      {
        update_fontname ();
        mark_modified ();
      }
  }

  void set_fontsize (const octave_value& val)
  {
    if (m_fontsize.set (val, false))
      {
        set_fontsizemode ("manual");
        update_fontsize ();
        m_fontsize.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
    else
      set_fontsizemode ("manual");
  }

  void set_fontsizemode (const octave_value& val)
  {
    if (m_fontsizemode.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_fontsmoothing (const octave_value& val)
  {
    if (m_fontsmoothing.set (val, true))
      {
        update_fontsmoothing ();
        mark_modified ();
      }
  }

  void set_fontunits (const octave_value& val);

  void update_fontunits (void);

  void set_fontweight (const octave_value& val)
  {
    if (m_fontweight.set (val, true))
      {
        update_fontweight ();
        mark_modified ();
      }
  }

  void set_gridalpha (const octave_value& val)
  {
    if (m_gridalpha.set (val, false))
      {
        set_gridalphamode ("manual");
        m_gridalpha.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
    else
      set_gridalphamode ("manual");
  }

  void set_gridalphamode (const octave_value& val)
  {
    if (m_gridalphamode.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_gridcolor (const octave_value& val)
  {
    if (m_gridcolor.set (val, false))
      {
        set_gridcolormode ("manual");
        m_gridcolor.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
    else
      set_gridcolormode ("manual");
  }

  void set_gridcolormode (const octave_value& val)
  {
    if (m_gridcolormode.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_gridlinestyle (const octave_value& val)
  {
    if (m_gridlinestyle.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_interactions (const octave_value& val)
  {
    if (m_interactions.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_labelfontsizemultiplier (const octave_value& val)
  {
    if (m_labelfontsizemultiplier.set (val, true))
      {
        update_labelfontsizemultiplier ();
        mark_modified ();
      }
  }

  void set_layer (const octave_value& val)
  {
    if (m_layer.set (val, true))
      {
        update_layer ();
        mark_modified ();
      }
  }

  void set_layout (const octave_value& val)
  {
    if (m_layout.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_legend (const octave_value& val)
  {
    if (m_legend.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_linestyleorder (const octave_value& val);

  void set_linestyleorderindex (const octave_value& val)
  {
    if (m_linestyleorderindex.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_linewidth (const octave_value& val)
  {
    if (m_linewidth.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_minorgridalpha (const octave_value& val)
  {
    if (m_minorgridalpha.set (val, false))
      {
        set_minorgridalphamode ("manual");
        m_minorgridalpha.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
    else
      set_minorgridalphamode ("manual");
  }

  void set_minorgridalphamode (const octave_value& val)
  {
    if (m_minorgridalphamode.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_minorgridcolor (const octave_value& val)
  {
    if (m_minorgridcolor.set (val, false))
      {
        set_minorgridcolormode ("manual");
        m_minorgridcolor.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
    else
      set_minorgridcolormode ("manual");
  }

  void set_minorgridcolormode (const octave_value& val)
  {
    if (m_minorgridcolormode.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_minorgridlinestyle (const octave_value& val)
  {
    if (m_minorgridlinestyle.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_nextplot (const octave_value& val)
  {
    if (m_nextplot.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_nextseriesindex (const octave_value& val)
  {
    if (m_nextseriesindex.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_outerposition (const octave_value& val)
  {
    if (m_outerposition.set (val, true))
      {
        update_outerposition ();
        mark_modified ();
      }
  }

  void set_plotboxaspectratio (const octave_value& val)
  {
    if (m_plotboxaspectratio.set (val, false))
      {
        set_plotboxaspectratiomode ("manual");
        update_plotboxaspectratio ();
        m_plotboxaspectratio.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
    else
      set_plotboxaspectratiomode ("manual");
  }

  void set_plotboxaspectratiomode (const octave_value& val)
  {
    if (m_plotboxaspectratiomode.set (val, true))
      {
        update_plotboxaspectratiomode ();
        mark_modified ();
      }
  }

  void set_position (const octave_value& val)
  {
    if (m_position.set (val, true))
      {
        update_position ();
        mark_modified ();
      }
  }

  void set_positionconstraint (const octave_value& val)
  {
    if (m_positionconstraint.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_projection (const octave_value& val)
  {
    if (m_projection.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_sortmethod (const octave_value& val)
  {
    if (m_sortmethod.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_tickdir (const octave_value& val)
  {
    if (m_tickdir.set (val, false))
      {
        set_tickdirmode ("manual");
        update_tickdir ();
        m_tickdir.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
    else
      set_tickdirmode ("manual");
  }

  void set_tickdirmode (const octave_value& val)
  {
    if (m_tickdirmode.set (val, true))
      {
        update_tickdirmode ();
        mark_modified ();
      }
  }

  void set_ticklabelinterpreter (const octave_value& val)
  {
    if (m_ticklabelinterpreter.set (val, true))
      {
        update_ticklabelinterpreter ();
        mark_modified ();
      }
  }

  void set_ticklength (const octave_value& val)
  {
    if (m_ticklength.set (val, true))
      {
        update_ticklength ();
        mark_modified ();
      }
  }

  void set_tightinset (const octave_value& val)
  {
    if (m_tightinset.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_title (const octave_value& val);

  void set_titlefontsizemultiplier (const octave_value& val)
  {
    if (m_titlefontsizemultiplier.set (val, true))
      {
        update_titlefontsizemultiplier ();
        mark_modified ();
      }
  }

  void set_titlefontweight (const octave_value& val)
  {
    if (m_titlefontweight.set (val, true))
      {
        update_titlefontweight ();
        mark_modified ();
      }
  }

  void set_toolbar (const octave_value& val)
  {
    if (m_toolbar.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_units (const octave_value& val);

  void update_units (void);

  void set_view (const octave_value& val)
  {
    if (m_view.set (val, true))
      {
        update_view ();
        mark_modified ();
      }
  }

  void set_xaxis (const octave_value& val)
  {
    if (m_xaxis.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_xaxislocation (const octave_value& val)
  {
    if (m_xaxislocation.set (val, true))
      {
        update_xaxislocation ();
        mark_modified ();
      }
  }

  void set_xcolor (const octave_value& val)
  {
    if (m_xcolor.set (val, false))
      {
        set_xcolormode ("manual");
        update_xcolor ();
        m_xcolor.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
    else
      set_xcolormode ("manual");
  }

  void set_xcolormode (const octave_value& val)
  {
    if (m_xcolormode.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_xdir (const octave_value& val)
  {
    if (m_xdir.set (val, true))
      {
        update_xdir ();
        mark_modified ();
      }
  }

  void set_xgrid (const octave_value& val)
  {
    if (m_xgrid.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_xlabel (const octave_value& val);

  void set_xlim (const octave_value& val)
  {
    if (m_xlim.set (val, false))
      {
        set_xlimmode ("manual");
        update_xlim ();
        m_xlim.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
    else
      set_xlimmode ("manual");
  }

  void set_xlimmode (const octave_value& val)
  {
    if (m_xlimmode.set (val, false))
      {
        update_axis_limits ("xlimmode");
        m_xlimmode.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
  }

  void set_xminorgrid (const octave_value& val)
  {
    if (m_xminorgrid.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_xminortick (const octave_value& val)
  {
    if (m_xminortick.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_xscale (const octave_value& val)
  {
    if (m_xscale.set (val, false))
      {
        update_xscale ();
        update_axis_limits ("xscale");
        m_xscale.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
  }

  void set_xtick (const octave_value& val)
  {
    if (m_xtick.set (val, false))
      {
        set_xtickmode ("manual");
        update_xtick ();
        m_xtick.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
    else
      set_xtickmode ("manual");
  }

  void set_xticklabel (const octave_value& val);

  void set_xticklabelmode (const octave_value& val)
  {
    if (m_xticklabelmode.set (val, true))
      {
        update_xticklabelmode ();
        mark_modified ();
      }
  }

  void set_xticklabelrotation (const octave_value& val)
  {
    if (m_xticklabelrotation.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_xtickmode (const octave_value& val)
  {
    if (m_xtickmode.set (val, true))
      {
        update_xtickmode ();
        mark_modified ();
      }
  }

  void set_yaxis (const octave_value& val)
  {
    if (m_yaxis.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_yaxislocation (const octave_value& val)
  {
    if (m_yaxislocation.set (val, true))
      {
        update_yaxislocation ();
        mark_modified ();
      }
  }

  void set_ycolor (const octave_value& val)
  {
    if (m_ycolor.set (val, false))
      {
        set_ycolormode ("manual");
        update_ycolor ();
        m_ycolor.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
    else
      set_ycolormode ("manual");
  }

  void set_ycolormode (const octave_value& val)
  {
    if (m_ycolormode.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_ydir (const octave_value& val)
  {
    if (m_ydir.set (val, true))
      {
        update_ydir ();
        mark_modified ();
      }
  }

  void set_ygrid (const octave_value& val)
  {
    if (m_ygrid.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_ylabel (const octave_value& val);

  void set_ylim (const octave_value& val)
  {
    if (m_ylim.set (val, false))
      {
        set_ylimmode ("manual");
        update_ylim ();
        m_ylim.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
    else
      set_ylimmode ("manual");
  }

  void set_ylimmode (const octave_value& val)
  {
    if (m_ylimmode.set (val, false))
      {
        update_axis_limits ("ylimmode");
        m_ylimmode.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
  }

  void set_yminorgrid (const octave_value& val)
  {
    if (m_yminorgrid.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_yminortick (const octave_value& val)
  {
    if (m_yminortick.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_yscale (const octave_value& val)
  {
    if (m_yscale.set (val, false))
      {
        update_yscale ();
        update_axis_limits ("yscale");
        m_yscale.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
  }

  void set_ytick (const octave_value& val)
  {
    if (m_ytick.set (val, false))
      {
        set_ytickmode ("manual");
        update_ytick ();
        m_ytick.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
    else
      set_ytickmode ("manual");
  }

  void set_yticklabel (const octave_value& val);

  void set_yticklabelmode (const octave_value& val)
  {
    if (m_yticklabelmode.set (val, true))
      {
        update_yticklabelmode ();
        mark_modified ();
      }
  }

  void set_yticklabelrotation (const octave_value& val)
  {
    if (m_yticklabelrotation.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_ytickmode (const octave_value& val)
  {
    if (m_ytickmode.set (val, true))
      {
        update_ytickmode ();
        mark_modified ();
      }
  }

  void set_zaxis (const octave_value& val)
  {
    if (m_zaxis.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_zcolor (const octave_value& val)
  {
    if (m_zcolor.set (val, false))
      {
        set_zcolormode ("manual");
        update_zcolor ();
        m_zcolor.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
    else
      set_zcolormode ("manual");
  }

  void set_zcolormode (const octave_value& val)
  {
    if (m_zcolormode.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_zdir (const octave_value& val)
  {
    if (m_zdir.set (val, true))
      {
        update_zdir ();
        mark_modified ();
      }
  }

  void set_zgrid (const octave_value& val)
  {
    if (m_zgrid.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_zlabel (const octave_value& val);

  void set_zlim (const octave_value& val)
  {
    if (m_zlim.set (val, false))
      {
        set_zlimmode ("manual");
        update_zlim ();
        m_zlim.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
    else
      set_zlimmode ("manual");
  }

  void set_zlimmode (const octave_value& val)
  {
    if (m_zlimmode.set (val, false))
      {
        update_axis_limits ("zlimmode");
        m_zlimmode.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
  }

  void set_zminorgrid (const octave_value& val)
  {
    if (m_zminorgrid.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_zminortick (const octave_value& val)
  {
    if (m_zminortick.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_zscale (const octave_value& val)
  {
    if (m_zscale.set (val, false))
      {
        update_zscale ();
        update_axis_limits ("zscale");
        m_zscale.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
  }

  void set_ztick (const octave_value& val)
  {
    if (m_ztick.set (val, false))
      {
        set_ztickmode ("manual");
        update_ztick ();
        m_ztick.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
    else
      set_ztickmode ("manual");
  }

  void set_zticklabel (const octave_value& val);

  void set_zticklabelmode (const octave_value& val)
  {
    if (m_zticklabelmode.set (val, true))
      {
        update_zticklabelmode ();
        mark_modified ();
      }
  }

  void set_zticklabelrotation (const octave_value& val)
  {
    if (m_zticklabelrotation.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_ztickmode (const octave_value& val)
  {
    if (m_ztickmode.set (val, true))
      {
        update_ztickmode ();
        mark_modified ();
      }
  }

  void set___colormap__ (const octave_value& val)
  {
    if (m___colormap__.set (val, true))
      {
        update___colormap__ ();
        mark_modified ();
      }
  }

  void set_mousewheelzoom (const octave_value& val)
  {
    if (m_mousewheelzoom.set (val, true))
      {
        mark_modified ();
      }
  }

  void set___autopos_tag__ (const octave_value& val)
  {
    if (m___autopos_tag__.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_looseinset (const octave_value& val)
  {
    if (m_looseinset.set (val, true))
      {
        update_looseinset ();
        mark_modified ();
      }
  }

  void set_xminortickvalues (const octave_value& val)
  {
    if (m_xminortickvalues.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_yminortickvalues (const octave_value& val)
  {
    if (m_yminortickvalues.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_zminortickvalues (const octave_value& val)
  {
    if (m_zminortickvalues.set (val, true))
      {
        mark_modified ();
      }
  }

  void set___fontsize_points__ (const octave_value& val)
  {
    if (m___fontsize_points__.set (val, true))
      {
        mark_modified ();
      }
  }


  protected:
    OCTINTERP_API void init (void);

  private:

    std::string
    get_scale (const std::string& scale, const Matrix& lims)
    {
      std::string retval = scale;

      if (scale == "log" && lims.numel () > 1 && lims(0) < 0 && lims(1) < 0)
        retval = "neglog";

      return retval;
    }

    void update_xscale (void)
    {
      m_sx = get_scale (get_xscale (), m_xlim.get ().matrix_value ());
    }

    void update_yscale (void)
    {
      m_sy = get_scale (get_yscale (), m_ylim.get ().matrix_value ());
    }

    void update_zscale (void)
    {
      m_sz = get_scale (get_zscale (), m_zlim.get ().matrix_value ());
    }

    OCTINTERP_API void
    update_label_color (handle_property label, color_property col);
    void update_xcolor (void)
    { update_label_color (m_xlabel, m_xcolor); }

    void update_ycolor (void)
    { update_label_color (m_ylabel, m_ycolor); }

    void update_zcolor (void)
    { update_label_color (m_zlabel, m_zcolor); }

    void update_view (void) { sync_positions (); }

    void update_cameraposition (void) { update_transform (); }
    void update_cameratarget (void) { update_transform (); }
    void update_cameraupvector (void) { update_transform (); }
    void update_cameraviewangle (void) { update_transform (); }

    void update_camerapositionmode (void)
    {
      if (camerapositionmode_is ("auto"))
        update_cameraposition ();
    }
    void update_cameratargetmode (void)
    {
      if (cameratargetmode_is ("auto"))
        update_cameratarget ();
    }
    void update_cameraupvectormode (void)
    {
      if (cameraupvectormode_is ("auto"))
        update_cameraupvector ();
    }
    void update_cameraviewanglemode (void)
    {
      if (cameraviewanglemode_is ("auto"))
        update_cameraviewangle ();
    }

    void update_dataaspectratio (void) { sync_positions (); }
    void update_dataaspectratiomode (void) { sync_positions (); }
    void update_plotboxaspectratio (void) { sync_positions (); }
    void update_plotboxaspectratiomode (void) { sync_positions (); }

    void update_layer (void) { update_axes_layout (); }
    void update_box (void)
    {
      if (m_xticklabelmode.is ("auto"))
        calc_ticklabels (m_xtick, m_xticklabel, m_xscale.is ("log"),
                         xaxislocation_is ("origin"),
                         m_yscale.is ("log") ? 2 :
                           (yaxislocation_is ("origin") ? 0 :
                             (yaxislocation_is ("left") ? -1 : 1)),
                         m_xlim);
      if (m_yticklabelmode.is ("auto"))
        calc_ticklabels (m_ytick, m_yticklabel, m_yscale.is ("log"),
                         yaxislocation_is ("origin"),
                         m_xscale.is ("log") ? 2 :
                           (xaxislocation_is ("origin") ? 0 :
                             (xaxislocation_is ("bottom") ? -1 : 1)),
                         m_ylim);
    }
    void update_yaxislocation (void)
    {
      sync_positions ();
      update_axes_layout ();
      if (m_xticklabelmode.is ("auto"))
        calc_ticklabels (m_xtick, m_xticklabel, m_xscale.is ("log"),
                         xaxislocation_is ("origin"),
                         m_yscale.is ("log") ? 2 :
                           (yaxislocation_is ("origin") ? 0 :
                             (yaxislocation_is ("left") ? -1 : 1)),
                         m_xlim);
      if (m_yticklabelmode.is ("auto"))
        calc_ticklabels (m_ytick, m_yticklabel, m_yscale.is ("log"),
                         yaxislocation_is ("origin"),
                         m_xscale.is ("log") ? 2 :
                           (xaxislocation_is ("origin") ? 0 :
                             (xaxislocation_is ("bottom") ? -1 : 1)),
                         m_ylim);
      update_ylabel_position ();
    }
    void update_xaxislocation (void)
    {
      sync_positions ();
      update_axes_layout ();
      if (m_xticklabelmode.is ("auto"))
        calc_ticklabels (m_xtick, m_xticklabel, m_xscale.is ("log"),
                         xaxislocation_is ("origin"),
                         m_yscale.is ("log") ? 2 :
                           (yaxislocation_is ("origin") ? 0 :
                             (yaxislocation_is ("left") ? -1 : 1)),
                         m_xlim);
      if (m_yticklabelmode.is ("auto"))
        calc_ticklabels (m_ytick, m_yticklabel, m_yscale.is ("log"),
                         yaxislocation_is ("origin"),
                         m_xscale.is ("log") ? 2 :
                           (xaxislocation_is ("origin") ? 0 :
                             (xaxislocation_is ("bottom") ? -1 : 1)),
                         m_ylim);
      update_xlabel_position ();
    }

    void update_xdir (void) { update_camera (); update_axes_layout (); }
    void update_ydir (void) { update_camera (); update_axes_layout (); }
    void update_zdir (void) { update_camera (); update_axes_layout (); }

    void update_ticklength (void);
    void update_tickdir (void) { update_ticklength (); }
    void update_tickdirmode (void) { update_ticklength (); }

    void update_ticklabelinterpreter (void)
    {
      update_xtick (false);
      update_ytick (false);
      update_ztick (true);
    }

    void update_xtick (bool sync_pos = true)
    {
      calc_ticks_and_lims (m_xlim, m_xtick, m_xminortickvalues,
                           m_xlimmode.is ("auto"), m_xtickmode.is ("auto"),
                           m_xscale.is ("log"));
      if (m_xticklabelmode.is ("auto"))
        calc_ticklabels (m_xtick, m_xticklabel, m_xscale.is ("log"),
                         xaxislocation_is ("origin"),
                         m_yscale.is ("log") ? 2 :
                           (yaxislocation_is ("origin") ? 0 :
                             (yaxislocation_is ("left") ? -1 : 1)),
                         m_xlim);

      if (sync_pos)
        sync_positions ();
    }
    void update_ytick (bool sync_pos = true)
    {
      calc_ticks_and_lims (m_ylim, m_ytick, m_yminortickvalues,
                           m_ylimmode.is ("auto"), m_ytickmode.is ("auto"),
                           m_yscale.is ("log"));
      if (m_yticklabelmode.is ("auto"))
        calc_ticklabels (m_ytick, m_yticklabel, m_yscale.is ("log"),
                         yaxislocation_is ("origin"),
                         m_xscale.is ("log") ? 2 :
                           (xaxislocation_is ("origin") ? 0 :
                             (xaxislocation_is ("bottom") ? -1 : 1)),
                         m_ylim);

      if (sync_pos)
        sync_positions ();
    }
    void update_ztick (bool sync_pos = true)
    {
      calc_ticks_and_lims (m_zlim, m_ztick, m_zminortickvalues,
                           m_zlimmode.is ("auto"), m_ztickmode.is ("auto"),
                           m_zscale.is ("log"));
      if (m_zticklabelmode.is ("auto"))
        calc_ticklabels (m_ztick, m_zticklabel, m_zscale.is ("log"), false,
                         2, m_zlim);

      if (sync_pos)
        sync_positions ();
    }

    void update_xtickmode (void)
    {
      if (m_xtickmode.is ("auto"))
        update_xtick ();
    }
    void update_ytickmode (void)
    {
      if (m_ytickmode.is ("auto"))
        update_ytick ();
    }
    void update_ztickmode (void)
    {
      if (m_ztickmode.is ("auto"))
        update_ztick ();
    }

    void update_xticklabelmode (void)
    {
      if (m_xticklabelmode.is ("auto"))
        calc_ticklabels (m_xtick, m_xticklabel, m_xscale.is ("log"),
                         xaxislocation_is ("origin"),
                         m_yscale.is ("log") ? 2 :
                           (yaxislocation_is ("origin") ? 0 :
                             (yaxislocation_is ("left") ? -1 : 1)),
                         m_xlim);
    }
    void update_yticklabelmode (void)
    {
      if (m_yticklabelmode.is ("auto"))
        calc_ticklabels (m_ytick, m_yticklabel, m_yscale.is ("log"),
                         yaxislocation_is ("origin"),
                         m_xscale.is ("log") ? 2 :
                           (xaxislocation_is ("origin") ? 0 :
                             (xaxislocation_is ("bottom") ? -1 : 1)),
                         m_ylim);
    }
    void update_zticklabelmode (void)
    {
      if (m_zticklabelmode.is ("auto"))
        calc_ticklabels (m_ztick, m_zticklabel, m_zscale.is ("log"), false, 2, m_zlim);
    }

    void update_fontname (void)
    {
      update_font ("fontname");
      sync_positions ();
    }
    void update_fontsize (void)
    {
      update_font ("fontsize");
      sync_positions ();
    }
    void update_fontsmoothing (void)
    {
      update_font ("fontsmoothing");
    }
    void update_fontangle (void)
    {
      update_font ("fontangle");
      sync_positions ();
    }
    void update_fontweight (void)
    {
      update_font ("fontweight");
      sync_positions ();
    }

    void update_titlefontsizemultiplier (void)
    {
      // update_font handles title and axis labels
      update_font ("fontsize");
      sync_positions ();
    }

    void update_labelfontsizemultiplier (void)
    {
      update_font ("fontsize");
      sync_positions ();
    }

    void update_titlefontweight (void)
    {
      // update_font handles title and axis labels
      update_font ("fontweight");
      sync_positions ();
    }

    OCTINTERP_API void update_outerposition (void);
    OCTINTERP_API void update_position (void);
    OCTINTERP_API void update_looseinset (void);

    OCTINTERP_API double calc_tick_sep (double minval, double maxval);
    OCTINTERP_API void
    calc_ticks_and_lims (array_property& lims, array_property& ticks,
                         array_property& mticks, bool limmode_is_auto,
                         bool tickmode_is_auto, bool is_logscale);
    OCTINTERP_API void
    calc_ticklabels (const array_property& ticks, any_property& labels,
                     bool is_logscale, const bool is_origin,
                     const int other_axislocation,
                     const array_property& axis_lims);
    OCTINTERP_API Matrix
    get_ticklabel_extents (const Matrix& ticks,
                           const string_vector& ticklabels,
                           const Matrix& limits);

    void fix_limits (array_property& lims)
    {
      if (lims.get ().isempty ())
        return;

      Matrix l = lims.get ().matrix_value ();
      if (l(0) > l(1))
        {
          l(0) = 0;
          l(1) = 1;
          lims = l;
        }
      else if (l(0) == l(1))
        {
          l(0) -= 0.5;
          l(1) += 0.5;
          lims = l;
        }
    }

    OCTINTERP_API Matrix calc_tightbox (const Matrix& init_pos);

    void set_colormap (const octave_value& val)
    {
      set___colormap__ (val);
    }

    void update___colormap__ (void)
    {
      m_colormap.run_listeners (GCB_POSTSET);
    }

    OCTINTERP_API octave_value get_colormap (void) const;

  public:
    OCTINTERP_API Matrix
    get_axis_limits (double xmin, double xmax,
                     double min_pos, double max_neg,
                     const bool logscale);

    OCTINTERP_API void
    check_axis_limits (Matrix& limits, const Matrix kids,
                       const bool logscale, char& update_type);

    void update_xlim ()
    {
      update_axis_limits ("xlim");

      calc_ticks_and_lims (m_xlim, m_xtick, m_xminortickvalues,
                           m_xlimmode.is ("auto"), m_xtickmode.is ("auto"),
                           m_xscale.is ("log"));
      if (m_xticklabelmode.is ("auto"))
        calc_ticklabels (m_xtick, m_xticklabel, m_xscale.is ("log"),
                         m_xaxislocation.is ("origin"),
                         m_yscale.is ("log") ? 2 :
                           (yaxislocation_is ("origin") ? 0 :
                             (yaxislocation_is ("left") ? -1 : 1)),
                         m_xlim);

      fix_limits (m_xlim);

      update_xscale ();

      update_axes_layout ();
    }

    void update_ylim (void)
    {
      update_axis_limits ("ylim");

      calc_ticks_and_lims (m_ylim, m_ytick, m_yminortickvalues,
                           m_ylimmode.is ("auto"), m_ytickmode.is ("auto"),
                           m_yscale.is ("log"));
      if (m_yticklabelmode.is ("auto"))
        calc_ticklabels (m_ytick, m_yticklabel, m_yscale.is ("log"),
                         yaxislocation_is ("origin"),
                         m_xscale.is ("log") ? 2 :
                           (xaxislocation_is ("origin") ? 0 :
                             (xaxislocation_is ("bottom") ? -1 : 1)),
                         m_ylim);

      fix_limits (m_ylim);

      update_yscale ();

      update_axes_layout ();
    }

    void update_zlim (void)
    {
      update_axis_limits ("zlim");

      calc_ticks_and_lims (m_zlim, m_ztick, m_zminortickvalues,
                           m_zlimmode.is ("auto"), m_ztickmode.is ("auto"),
                           m_zscale.is ("log"));
      if (m_zticklabelmode.is ("auto"))
        calc_ticklabels (m_ztick, m_zticklabel, m_zscale.is ("log"), false,
                         2, m_zlim);

      fix_limits (m_zlim);

      update_zscale ();

      update_axes_layout ();
    }

    void trigger_normals_calc (void);

  };

private:
  properties m_properties;

public:
  axes (const graphics_handle& mh, const graphics_handle& p)
    : base_graphics_object (), m_properties (mh, p), m_default_properties ()
  {
    m_properties.update_transform ();
  }

  ~axes (void) = default;

  void override_defaults (base_graphics_object& obj)
  {
    // Allow parent (figure) to override first (properties knows how
    // to find the parent object).
    m_properties.override_defaults (obj);

    // Now override with our defaults.  If the default_properties
    // list includes the properties for all defaults (line,
    // surface, etc.) then we don't have to know the type of OBJ
    // here, we just call its set function and let it decide which
    // properties from the list to use.
    obj.set_from_list (m_default_properties);
  }

  void set (const caseless_str& name, const octave_value& value)
  {
    if (name.compare ("default", 7))
      // strip "default", pass rest to function that will
      // parse the remainder and add the element to the
      // default_properties map.
      m_default_properties.set (name.substr (7), value);
    else
      m_properties.set (name, value);
  }

  void set_defaults (const std::string& mode)
  {
    m_properties.set_defaults (*this, mode);
  }

  octave_value get (const caseless_str& name) const
  {
    octave_value retval;

    // FIXME: finish this.
    if (name.compare ("default", 7))
      retval = get_default (name.substr (7));
    else
      retval = m_properties.get (name);

    return retval;
  }

  OCTINTERP_API octave_value get_default (const caseless_str& name) const;

  octave_value get_defaults (void) const
  {
    return m_default_properties.as_struct ("default");
  }

  property_list get_defaults_list (void) const
  {
    return m_default_properties;
  }

  base_properties& get_properties (void) { return m_properties; }

  const base_properties& get_properties (void) const { return m_properties; }

  OCTINTERP_API void update_axis_limits (const std::string& axis_type);

  OCTINTERP_API void update_axis_limits (const std::string& axis_type,
                                         const graphics_handle& h);

  bool valid_object (void) const { return true; }

  OCTINTERP_API void reset_default_properties (void);

  bool has_readonly_property (const caseless_str& pname) const
  {
    bool retval = m_properties.has_readonly_property (pname);
    if (! retval)
      retval = base_properties::has_readonly_property (pname);
    return retval;
  }

protected:
  OCTINTERP_API void initialize (const graphics_object& go);

private:
  property_list m_default_properties;
};

// ---------------------------------------------------------------------

class OCTINTERP_API line : public base_graphics_object
{
public:

  class OCTINTERP_API properties : public base_properties
  {
  public:

    // See the genprops.awk script for an explanation of the
    // properties declarations.
    // Programming note: Keep property list sorted if new ones are added.

public:
  properties (const graphics_handle& mh, const graphics_handle& p);

  ~properties (void) { }

  void set (const caseless_str& pname, const octave_value& val);

  octave_value get (bool all = false) const;

  octave_value get (const caseless_str& pname) const;

  octave_value get (const std::string& pname) const
  {
    return get (caseless_str (pname));
  }

  octave_value get (const char *pname) const
  {
    return get (caseless_str (pname));
  }

  property get_property (const caseless_str& pname);

  std::string graphics_object_name (void) const { return s_go_name; }

  static property_list::pval_map_type factory_defaults (void);

private:
  static std::string s_go_name;

public:


  static std::set<std::string> core_property_names (void);

  static std::set<std::string> readonly_property_names (void);

  static bool has_core_property (const caseless_str& pname);

  static bool has_readonly_property (const caseless_str& pname);

  std::set<std::string> all_property_names (void) const;

  bool has_property (const caseless_str& pname) const;

private:

  color_property m_color;
  string_property m_displayname;
  radio_property m_linejoin;
  radio_property m_linestyle;
  double_property m_linewidth;
  radio_property m_marker;
  color_property m_markeredgecolor;
  color_property m_markerfacecolor;
  double_property m_markersize;
  row_vector_property m_xdata;
  string_property m_xdatasource;
  row_vector_property m_ydata;
  string_property m_ydatasource;
  row_vector_property m_zdata;
  string_property m_zdatasource;
  row_vector_property m_xlim;
  row_vector_property m_ylim;
  row_vector_property m_zlim;
  bool_property m_xliminclude;
  bool_property m_yliminclude;
  bool_property m_zliminclude;

public:

  enum
  {
    ID_COLOR = 4000,
    ID_DISPLAYNAME = 4001,
    ID_LINEJOIN = 4002,
    ID_LINESTYLE = 4003,
    ID_LINEWIDTH = 4004,
    ID_MARKER = 4005,
    ID_MARKEREDGECOLOR = 4006,
    ID_MARKERFACECOLOR = 4007,
    ID_MARKERSIZE = 4008,
    ID_XDATA = 4009,
    ID_XDATASOURCE = 4010,
    ID_YDATA = 4011,
    ID_YDATASOURCE = 4012,
    ID_ZDATA = 4013,
    ID_ZDATASOURCE = 4014,
    ID_XLIM = 4015,
    ID_YLIM = 4016,
    ID_ZLIM = 4017,
    ID_XLIMINCLUDE = 4018,
    ID_YLIMINCLUDE = 4019,
    ID_ZLIMINCLUDE = 4020
  };

  bool color_is_rgb (void) const { return m_color.is_rgb (); }
  bool color_is (const std::string& v) const { return m_color.is (v); }
  Matrix get_color_rgb (void) const { return (m_color.is_rgb () ? m_color.rgb () : Matrix ()); }
  octave_value get_color (void) const { return m_color.get (); }

  std::string get_displayname (void) const { return m_displayname.string_value (); }

  bool linejoin_is (const std::string& v) const { return m_linejoin.is (v); }
  std::string get_linejoin (void) const { return m_linejoin.current_value (); }

  bool linestyle_is (const std::string& v) const { return m_linestyle.is (v); }
  std::string get_linestyle (void) const { return m_linestyle.current_value (); }

  double get_linewidth (void) const { return m_linewidth.double_value (); }

  bool marker_is (const std::string& v) const { return m_marker.is (v); }
  std::string get_marker (void) const { return m_marker.current_value (); }

  bool markeredgecolor_is_rgb (void) const { return m_markeredgecolor.is_rgb (); }
  bool markeredgecolor_is (const std::string& v) const { return m_markeredgecolor.is (v); }
  Matrix get_markeredgecolor_rgb (void) const { return (m_markeredgecolor.is_rgb () ? m_markeredgecolor.rgb () : Matrix ()); }
  octave_value get_markeredgecolor (void) const { return m_markeredgecolor.get (); }

  bool markerfacecolor_is_rgb (void) const { return m_markerfacecolor.is_rgb (); }
  bool markerfacecolor_is (const std::string& v) const { return m_markerfacecolor.is (v); }
  Matrix get_markerfacecolor_rgb (void) const { return (m_markerfacecolor.is_rgb () ? m_markerfacecolor.rgb () : Matrix ()); }
  octave_value get_markerfacecolor (void) const { return m_markerfacecolor.get (); }

  double get_markersize (void) const { return m_markersize.double_value (); }

  octave_value get_xdata (void) const { return m_xdata.get (); }

  std::string get_xdatasource (void) const { return m_xdatasource.string_value (); }

  octave_value get_ydata (void) const { return m_ydata.get (); }

  std::string get_ydatasource (void) const { return m_ydatasource.string_value (); }

  octave_value get_zdata (void) const { return m_zdata.get (); }

  std::string get_zdatasource (void) const { return m_zdatasource.string_value (); }

  octave_value get_xlim (void) const { return m_xlim.get (); }

  octave_value get_ylim (void) const { return m_ylim.get (); }

  octave_value get_zlim (void) const { return m_zlim.get (); }

  bool is_xliminclude (void) const { return m_xliminclude.is_on (); }
  std::string get_xliminclude (void) const { return m_xliminclude.current_value (); }

  bool is_yliminclude (void) const { return m_yliminclude.is_on (); }
  std::string get_yliminclude (void) const { return m_yliminclude.current_value (); }

  bool is_zliminclude (void) const { return m_zliminclude.is_on (); }
  std::string get_zliminclude (void) const { return m_zliminclude.current_value (); }


  void set_color (const octave_value& val)
  {
    if (m_color.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_displayname (const octave_value& val)
  {
    if (m_displayname.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_linejoin (const octave_value& val)
  {
    if (m_linejoin.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_linestyle (const octave_value& val)
  {
    if (m_linestyle.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_linewidth (const octave_value& val)
  {
    if (m_linewidth.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_marker (const octave_value& val)
  {
    if (m_marker.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_markeredgecolor (const octave_value& val)
  {
    if (m_markeredgecolor.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_markerfacecolor (const octave_value& val)
  {
    if (m_markerfacecolor.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_markersize (const octave_value& val)
  {
    if (m_markersize.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_xdata (const octave_value& val)
  {
    if (m_xdata.set (val, true))
      {
        update_xdata ();
        mark_modified ();
      }
  }

  void set_xdatasource (const octave_value& val)
  {
    if (m_xdatasource.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_ydata (const octave_value& val)
  {
    if (m_ydata.set (val, true))
      {
        update_ydata ();
        mark_modified ();
      }
  }

  void set_ydatasource (const octave_value& val)
  {
    if (m_ydatasource.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_zdata (const octave_value& val)
  {
    if (m_zdata.set (val, true))
      {
        update_zdata ();
        mark_modified ();
      }
  }

  void set_zdatasource (const octave_value& val)
  {
    if (m_zdatasource.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_xlim (const octave_value& val)
  {
    if (m_xlim.set (val, false))
      {
        update_axis_limits ("xlim");
        m_xlim.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
  }

  void set_ylim (const octave_value& val)
  {
    if (m_ylim.set (val, false))
      {
        update_axis_limits ("ylim");
        m_ylim.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
  }

  void set_zlim (const octave_value& val)
  {
    if (m_zlim.set (val, false))
      {
        update_axis_limits ("zlim");
        m_zlim.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
  }

  void set_xliminclude (const octave_value& val)
  {
    if (m_xliminclude.set (val, false))
      {
        update_axis_limits ("xliminclude");
        m_xliminclude.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
  }

  void set_yliminclude (const octave_value& val)
  {
    if (m_yliminclude.set (val, false))
      {
        update_axis_limits ("yliminclude");
        m_yliminclude.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
  }

  void set_zliminclude (const octave_value& val)
  {
    if (m_zliminclude.set (val, false))
      {
        update_axis_limits ("zliminclude");
        m_zliminclude.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
  }


  protected:
    void init (void)
    {
      m_linewidth.add_constraint ("min", 0, false);
      m_markersize.add_constraint ("min", 0, false);
    }

  private:
    OCTINTERP_API Matrix compute_xlim (void) const;
    OCTINTERP_API Matrix compute_ylim (void) const;

    void update_xdata (void) { set_xlim (compute_xlim ()); }

    void update_ydata (void) { set_ylim (compute_ylim ()); }

    void update_zdata (void) { set_zlim (m_zdata.get_limits ()); }
  };

private:
  properties m_properties;

public:
  line (const graphics_handle& mh, const graphics_handle& p)
    : base_graphics_object (), m_properties (mh, p)
  { }

  ~line (void) = default;

  base_properties& get_properties (void) { return m_properties; }

  const base_properties& get_properties (void) const { return m_properties; }

  bool valid_object (void) const { return true; }

  bool has_readonly_property (const caseless_str& pname) const
  {
    bool retval = m_properties.has_readonly_property (pname);
    if (! retval)
      retval = base_properties::has_readonly_property (pname);
    return retval;
  }
};

// ---------------------------------------------------------------------

class OCTINTERP_API text : public base_graphics_object
{
public:

  class OCTINTERP_API properties : public base_properties
  {
  public:

    OCTINTERP_API double
    get___fontsize_points__ (double box_pix_height = 0) const;

    OCTINTERP_API void update_text_extent (void);

    OCTINTERP_API void update_font (void);

    void set_position (const octave_value& val)
    {
      octave_value new_val (val);

      if (new_val.numel () == 2)
        {
          dim_vector dv (1, 3);

          new_val = new_val.resize (dv, true);
        }

      if (m_position.set (new_val, false))
        {
          set_positionmode ("manual");
          update_position ();
          m_position.run_listeners (GCB_POSTSET);
          mark_modified ();
        }
      else
        set_positionmode ("manual");
    }

    // See the genprops.awk script for an explanation of the
    // properties declarations.
    // Programming note: Keep property list sorted if new ones are added.

public:
  properties (const graphics_handle& mh, const graphics_handle& p);

  ~properties (void) { }

  void set (const caseless_str& pname, const octave_value& val);

  octave_value get (bool all = false) const;

  octave_value get (const caseless_str& pname) const;

  octave_value get (const std::string& pname) const
  {
    return get (caseless_str (pname));
  }

  octave_value get (const char *pname) const
  {
    return get (caseless_str (pname));
  }

  property get_property (const caseless_str& pname);

  std::string graphics_object_name (void) const { return s_go_name; }

  static property_list::pval_map_type factory_defaults (void);

private:
  static std::string s_go_name;

public:


  static std::set<std::string> core_property_names (void);

  static std::set<std::string> readonly_property_names (void);

  static bool has_core_property (const caseless_str& pname);

  static bool has_readonly_property (const caseless_str& pname);

  std::set<std::string> all_property_names (void) const;

  bool has_property (const caseless_str& pname) const;

private:

  color_property m_backgroundcolor;
  color_property m_color;
  color_property m_edgecolor;
  bool_property m_editing;
  array_property m_extent;
  radio_property m_fontangle;
  string_property m_fontname;
  double_property m_fontsize;
  bool_property m_fontsmoothing;
  radio_property m_fontunits;
  radio_property m_fontweight;
  radio_property m_horizontalalignment;
  radio_property m_interpreter;
  radio_property m_linestyle;
  double_property m_linewidth;
  double_property m_margin;
  array_property m_position;
  double_property m_rotation;
  text_label_property m_string;
  radio_property m_units;
  radio_property m_verticalalignment;
  row_vector_property m_xlim;
  row_vector_property m_ylim;
  row_vector_property m_zlim;
  bool_property m_xliminclude;
  bool_property m_yliminclude;
  bool_property m_zliminclude;
  radio_property m_positionmode;
  radio_property m_rotationmode;
  radio_property m_horizontalalignmentmode;
  radio_property m_verticalalignmentmode;
  radio_property m___autopos_tag__;
  double_property m___fontsize_points__;

public:

  enum
  {
    ID_BACKGROUNDCOLOR = 5000,
    ID_COLOR = 5001,
    ID_EDGECOLOR = 5002,
    ID_EDITING = 5003,
    ID_EXTENT = 5004,
    ID_FONTANGLE = 5005,
    ID_FONTNAME = 5006,
    ID_FONTSIZE = 5007,
    ID_FONTSMOOTHING = 5008,
    ID_FONTUNITS = 5009,
    ID_FONTWEIGHT = 5010,
    ID_HORIZONTALALIGNMENT = 5011,
    ID_INTERPRETER = 5012,
    ID_LINESTYLE = 5013,
    ID_LINEWIDTH = 5014,
    ID_MARGIN = 5015,
    ID_POSITION = 5016,
    ID_ROTATION = 5017,
    ID_STRING = 5018,
    ID_UNITS = 5019,
    ID_VERTICALALIGNMENT = 5020,
    ID_XLIM = 5021,
    ID_YLIM = 5022,
    ID_ZLIM = 5023,
    ID_XLIMINCLUDE = 5024,
    ID_YLIMINCLUDE = 5025,
    ID_ZLIMINCLUDE = 5026,
    ID_POSITIONMODE = 5027,
    ID_ROTATIONMODE = 5028,
    ID_HORIZONTALALIGNMENTMODE = 5029,
    ID_VERTICALALIGNMENTMODE = 5030,
    ID___AUTOPOS_TAG__ = 5031,
    ID___FONTSIZE_POINTS__ = 5032
  };

  bool backgroundcolor_is_rgb (void) const { return m_backgroundcolor.is_rgb (); }
  bool backgroundcolor_is (const std::string& v) const { return m_backgroundcolor.is (v); }
  Matrix get_backgroundcolor_rgb (void) const { return (m_backgroundcolor.is_rgb () ? m_backgroundcolor.rgb () : Matrix ()); }
  octave_value get_backgroundcolor (void) const { return m_backgroundcolor.get (); }

  bool color_is_rgb (void) const { return m_color.is_rgb (); }
  bool color_is (const std::string& v) const { return m_color.is (v); }
  Matrix get_color_rgb (void) const { return (m_color.is_rgb () ? m_color.rgb () : Matrix ()); }
  octave_value get_color (void) const { return m_color.get (); }

  bool edgecolor_is_rgb (void) const { return m_edgecolor.is_rgb (); }
  bool edgecolor_is (const std::string& v) const { return m_edgecolor.is (v); }
  Matrix get_edgecolor_rgb (void) const { return (m_edgecolor.is_rgb () ? m_edgecolor.rgb () : Matrix ()); }
  octave_value get_edgecolor (void) const { return m_edgecolor.get (); }

  bool is_editing (void) const { return m_editing.is_on (); }
  std::string get_editing (void) const { return m_editing.current_value (); }

  octave_value get_extent (void) const;

  bool fontangle_is (const std::string& v) const { return m_fontangle.is (v); }
  std::string get_fontangle (void) const { return m_fontangle.current_value (); }

  std::string get_fontname (void) const { return m_fontname.string_value (); }

  double get_fontsize (void) const { return m_fontsize.double_value (); }

  bool is_fontsmoothing (void) const { return m_fontsmoothing.is_on (); }
  std::string get_fontsmoothing (void) const { return m_fontsmoothing.current_value (); }

  bool fontunits_is (const std::string& v) const { return m_fontunits.is (v); }
  std::string get_fontunits (void) const { return m_fontunits.current_value (); }

  bool fontweight_is (const std::string& v) const { return m_fontweight.is (v); }
  std::string get_fontweight (void) const { return m_fontweight.current_value (); }

  bool horizontalalignment_is (const std::string& v) const { return m_horizontalalignment.is (v); }
  std::string get_horizontalalignment (void) const { return m_horizontalalignment.current_value (); }

  bool interpreter_is (const std::string& v) const { return m_interpreter.is (v); }
  std::string get_interpreter (void) const { return m_interpreter.current_value (); }

  bool linestyle_is (const std::string& v) const { return m_linestyle.is (v); }
  std::string get_linestyle (void) const { return m_linestyle.current_value (); }

  double get_linewidth (void) const { return m_linewidth.double_value (); }

  double get_margin (void) const { return m_margin.double_value (); }

  octave_value get_position (void) const { return m_position.get (); }

  double get_rotation (void) const { return m_rotation.double_value (); }

  octave_value get_string (void) const { return m_string.get (); }

  bool units_is (const std::string& v) const { return m_units.is (v); }
  std::string get_units (void) const { return m_units.current_value (); }

  bool verticalalignment_is (const std::string& v) const { return m_verticalalignment.is (v); }
  std::string get_verticalalignment (void) const { return m_verticalalignment.current_value (); }

  octave_value get_xlim (void) const { return m_xlim.get (); }

  octave_value get_ylim (void) const { return m_ylim.get (); }

  octave_value get_zlim (void) const { return m_zlim.get (); }

  bool is_xliminclude (void) const { return m_xliminclude.is_on (); }
  std::string get_xliminclude (void) const { return m_xliminclude.current_value (); }

  bool is_yliminclude (void) const { return m_yliminclude.is_on (); }
  std::string get_yliminclude (void) const { return m_yliminclude.current_value (); }

  bool is_zliminclude (void) const { return m_zliminclude.is_on (); }
  std::string get_zliminclude (void) const { return m_zliminclude.current_value (); }

  bool positionmode_is (const std::string& v) const { return m_positionmode.is (v); }
  std::string get_positionmode (void) const { return m_positionmode.current_value (); }

  bool rotationmode_is (const std::string& v) const { return m_rotationmode.is (v); }
  std::string get_rotationmode (void) const { return m_rotationmode.current_value (); }

  bool horizontalalignmentmode_is (const std::string& v) const { return m_horizontalalignmentmode.is (v); }
  std::string get_horizontalalignmentmode (void) const { return m_horizontalalignmentmode.current_value (); }

  bool verticalalignmentmode_is (const std::string& v) const { return m_verticalalignmentmode.is (v); }
  std::string get_verticalalignmentmode (void) const { return m_verticalalignmentmode.current_value (); }

  bool __autopos_tag___is (const std::string& v) const { return m___autopos_tag__.is (v); }
  std::string get___autopos_tag__ (void) const { return m___autopos_tag__.current_value (); }


  void set_backgroundcolor (const octave_value& val)
  {
    if (m_backgroundcolor.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_color (const octave_value& val)
  {
    if (m_color.set (val, true))
      {
        update_color ();
        mark_modified ();
      }
  }

  void set_edgecolor (const octave_value& val)
  {
    if (m_edgecolor.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_editing (const octave_value& val)
  {
    if (m_editing.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_extent (const octave_value& val)
  {
    if (m_extent.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_fontangle (const octave_value& val)
  {
    if (m_fontangle.set (val, true))
      {
        update_fontangle ();
        mark_modified ();
      }
  }

  void set_fontname (const octave_value& val)
  {
    if (m_fontname.set (val, true))
      {
        update_fontname ();
        mark_modified ();
      }
  }

  void set_fontsize (const octave_value& val)
  {
    if (m_fontsize.set (val, true))
      {
        update_fontsize ();
        mark_modified ();
      }
  }

  void set_fontsmoothing (const octave_value& val)
  {
    if (m_fontsmoothing.set (val, true))
      {
        update_fontsmoothing ();
        mark_modified ();
      }
  }

  void set_fontunits (const octave_value& val);

  void update_fontunits (void);

  void set_fontweight (const octave_value& val)
  {
    if (m_fontweight.set (val, true))
      {
        update_fontweight ();
        mark_modified ();
      }
  }

  void set_horizontalalignment (const octave_value& val)
  {
    if (m_horizontalalignment.set (val, false))
      {
        set_horizontalalignmentmode ("manual");
        update_horizontalalignment ();
        m_horizontalalignment.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
    else
      set_horizontalalignmentmode ("manual");
  }

  void set_interpreter (const octave_value& val)
  {
    if (m_interpreter.set (val, true))
      {
        update_interpreter ();
        mark_modified ();
      }
  }

  void set_linestyle (const octave_value& val)
  {
    if (m_linestyle.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_linewidth (const octave_value& val)
  {
    if (m_linewidth.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_margin (const octave_value& val)
  {
    if (m_margin.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_rotation (const octave_value& val)
  {
    if (m_rotation.set (val, false))
      {
        set_rotationmode ("manual");
        update_rotation ();
        m_rotation.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
    else
      set_rotationmode ("manual");
  }

  void set_string (const octave_value& val)
  {
    if (m_string.set (val, true))
      {
        update_string ();
        mark_modified ();
      }
  }

  void set_units (const octave_value& val)
  {
    if (m_units.set (val, true))
      {
        update_units ();
        mark_modified ();
      }
  }

  void set_verticalalignment (const octave_value& val)
  {
    if (m_verticalalignment.set (val, false))
      {
        set_verticalalignmentmode ("manual");
        update_verticalalignment ();
        m_verticalalignment.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
    else
      set_verticalalignmentmode ("manual");
  }

  void set_xlim (const octave_value& val)
  {
    if (m_xlim.set (val, false))
      {
        update_axis_limits ("xlim");
        m_xlim.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
  }

  void set_ylim (const octave_value& val)
  {
    if (m_ylim.set (val, false))
      {
        update_axis_limits ("ylim");
        m_ylim.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
  }

  void set_zlim (const octave_value& val)
  {
    if (m_zlim.set (val, false))
      {
        update_axis_limits ("zlim");
        m_zlim.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
  }

  void set_xliminclude (const octave_value& val)
  {
    if (m_xliminclude.set (val, false))
      {
        update_axis_limits ("xliminclude");
        m_xliminclude.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
  }

  void set_yliminclude (const octave_value& val)
  {
    if (m_yliminclude.set (val, false))
      {
        update_axis_limits ("yliminclude");
        m_yliminclude.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
  }

  void set_zliminclude (const octave_value& val)
  {
    if (m_zliminclude.set (val, false))
      {
        update_axis_limits ("zliminclude");
        m_zliminclude.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
  }

  void set_positionmode (const octave_value& val)
  {
    if (m_positionmode.set (val, true))
      {
        update_positionmode ();
        mark_modified ();
      }
  }

  void set_rotationmode (const octave_value& val)
  {
    if (m_rotationmode.set (val, true))
      {
        update_rotationmode ();
        mark_modified ();
      }
  }

  void set_horizontalalignmentmode (const octave_value& val)
  {
    if (m_horizontalalignmentmode.set (val, true))
      {
        update_horizontalalignmentmode ();
        mark_modified ();
      }
  }

  void set_verticalalignmentmode (const octave_value& val)
  {
    if (m_verticalalignmentmode.set (val, true))
      {
        update_verticalalignmentmode ();
        mark_modified ();
      }
  }

  void set___autopos_tag__ (const octave_value& val)
  {
    if (m___autopos_tag__.set (val, true))
      {
        mark_modified ();
      }
  }

  void set___fontsize_points__ (const octave_value& val)
  {
    if (m___fontsize_points__.set (val, true))
      {
        mark_modified ();
      }
  }


    OCTINTERP_API Matrix get_data_position (void) const;
    OCTINTERP_API Matrix get_extent_matrix (bool rotated = false) const;
    const uint8NDArray& get_pixels (void) const { return m_pixels; }

    // Text renderer, used for calculation of text size
    octave::text_renderer m_txt_renderer;

  protected:
    void init (void)
    {
      m_position.add_constraint (dim_vector (1, 3));
      m_fontsize.add_constraint ("min", 0.0, false);
      m_linewidth.add_constraint ("min", 0.0, false);
      m_margin.add_constraint ("min", 0.0, false);
      m_cached_units = get_units ();
      update_font ();
    }

  private:
    void update_position (void)
    {
      Matrix pos = get_data_position ();
      Matrix lim;

      lim = Matrix (1, 4, pos(0));
      lim(2) = (lim(2) <= 0 ? octave::numeric_limits<double>::Inf () : lim(2));
      lim(3) = (lim(3) >= 0 ? -octave::numeric_limits<double>::Inf () : lim(3));
      set_xlim (lim);

      lim = Matrix (1, 4, pos(1));
      lim(2) = (lim(2) <= 0 ? octave::numeric_limits<double>::Inf () : lim(2));
      lim(3) = (lim(3) >= 0 ? -octave::numeric_limits<double>::Inf () : lim(3));
      set_ylim (lim);

      if (pos.numel () == 3)
        {
          lim = Matrix (1, 4, pos(2));
          lim(2) = (lim(2) <= 0 ? octave::numeric_limits<double>::Inf ()
                                : lim(2));
          lim(3) = (lim(3) >= 0 ? -octave::numeric_limits<double>::Inf ()
                                : lim(3));
          set_zliminclude ("on");
          set_zlim (lim);
        }
      else
        set_zliminclude ("off");
    }

    OCTINTERP_API void request_autopos (void);
    void update_positionmode (void) { request_autopos (); }
    void update_rotationmode (void) { request_autopos (); }
    void update_horizontalalignmentmode (void) { request_autopos (); }
    void update_verticalalignmentmode (void) { request_autopos (); }

    void update_string (void) { request_autopos (); update_text_extent (); }
    void update_rotation (void) { update_text_extent (); }
    void update_fontname (void) { update_font (); update_text_extent (); }
    void update_fontsize (void) { update_font (); update_text_extent (); }
    void update_fontsmoothing (void) { update_font (); update_text_extent (); }

    void update_color (void)
    {
      if (! m_color.is ("none"))
        {
          update_font ();
          update_text_extent ();
        }
    }

    void update_fontangle (void)
    {
      update_font ();
      update_text_extent ();
    }
    void update_fontweight (void) { update_font (); update_text_extent (); }

    void update_interpreter (void) { update_text_extent (); }
    void update_horizontalalignment (void) { update_text_extent (); }
    void update_verticalalignment (void) { update_text_extent (); }

    OCTINTERP_API void update_units (void);
    OCTINTERP_API void update_fontunits (const caseless_str& old_fontunits);

  private:
    std::string m_cached_units;
    uint8NDArray m_pixels;
  };

private:
  properties m_properties;

public:
  text (const graphics_handle& mh, const graphics_handle& p)
    : base_graphics_object (), m_properties (mh, p)
  {
    m_properties.set_clipping ("off");
  }

  ~text (void) = default;

  base_properties& get_properties (void) { return m_properties; }

  const base_properties& get_properties (void) const { return m_properties; }

  bool valid_object (void) const { return true; }

  bool has_readonly_property (const caseless_str& pname) const
  {
    bool retval = m_properties.has_readonly_property (pname);
    if (! retval)
      retval = base_properties::has_readonly_property (pname);
    return retval;
  }
};

// ---------------------------------------------------------------------

class OCTINTERP_API image : public base_graphics_object
{
public:

  class OCTINTERP_API properties : public base_properties
  {
  public:

    bool is_aliminclude (void) const
    { return (m_aliminclude.is_on () && m_alphadatamapping.is ("scaled")); }
    std::string get_aliminclude (void) const
    { return m_aliminclude.current_value (); }

    bool is_climinclude (void) const
    { return (m_climinclude.is_on () && m_cdatamapping.is ("scaled")); }
    std::string get_climinclude (void) const
    { return m_climinclude.current_value (); }

    OCTINTERP_API octave_value get_color_data (void) const;

    void initialize_data (void) { update_cdata (); }

    // See the genprops.awk script for an explanation of the
    // properties declarations.
    // Programming note: Keep property list sorted if new ones are added.

public:
  properties (const graphics_handle& mh, const graphics_handle& p);

  ~properties (void) { }

  void set (const caseless_str& pname, const octave_value& val);

  octave_value get (bool all = false) const;

  octave_value get (const caseless_str& pname) const;

  octave_value get (const std::string& pname) const
  {
    return get (caseless_str (pname));
  }

  octave_value get (const char *pname) const
  {
    return get (caseless_str (pname));
  }

  property get_property (const caseless_str& pname);

  std::string graphics_object_name (void) const { return s_go_name; }

  static property_list::pval_map_type factory_defaults (void);

private:
  static std::string s_go_name;

public:


  static std::set<std::string> core_property_names (void);

  static std::set<std::string> readonly_property_names (void);

  static bool has_core_property (const caseless_str& pname);

  static bool has_readonly_property (const caseless_str& pname);

  std::set<std::string> all_property_names (void) const;

  bool has_property (const caseless_str& pname) const;

private:

  array_property m_alphadata;
  radio_property m_alphadatamapping;
  array_property m_cdata;
  radio_property m_cdatamapping;
  row_vector_property m_xdata;
  row_vector_property m_ydata;
  row_vector_property m_alim;
  row_vector_property m_clim;
  row_vector_property m_xlim;
  row_vector_property m_ylim;
  bool_property m_aliminclude;
  bool_property m_climinclude;
  bool_property m_xliminclude;
  bool_property m_yliminclude;
  radio_property m_xdatamode;
  radio_property m_ydatamode;

public:

  enum
  {
    ID_ALPHADATA = 6000,
    ID_ALPHADATAMAPPING = 6001,
    ID_CDATA = 6002,
    ID_CDATAMAPPING = 6003,
    ID_XDATA = 6004,
    ID_YDATA = 6005,
    ID_ALIM = 6006,
    ID_CLIM = 6007,
    ID_XLIM = 6008,
    ID_YLIM = 6009,
    ID_ALIMINCLUDE = 6010,
    ID_CLIMINCLUDE = 6011,
    ID_XLIMINCLUDE = 6012,
    ID_YLIMINCLUDE = 6013,
    ID_XDATAMODE = 6014,
    ID_YDATAMODE = 6015
  };

  octave_value get_alphadata (void) const { return m_alphadata.get (); }

  bool alphadatamapping_is (const std::string& v) const { return m_alphadatamapping.is (v); }
  std::string get_alphadatamapping (void) const { return m_alphadatamapping.current_value (); }

  octave_value get_cdata (void) const { return m_cdata.get (); }

  bool cdatamapping_is (const std::string& v) const { return m_cdatamapping.is (v); }
  std::string get_cdatamapping (void) const { return m_cdatamapping.current_value (); }

  octave_value get_xdata (void) const { return m_xdata.get (); }

  octave_value get_ydata (void) const { return m_ydata.get (); }

  octave_value get_alim (void) const { return m_alim.get (); }

  octave_value get_clim (void) const { return m_clim.get (); }

  octave_value get_xlim (void) const { return m_xlim.get (); }

  octave_value get_ylim (void) const { return m_ylim.get (); }

  bool is_xliminclude (void) const { return m_xliminclude.is_on (); }
  std::string get_xliminclude (void) const { return m_xliminclude.current_value (); }

  bool is_yliminclude (void) const { return m_yliminclude.is_on (); }
  std::string get_yliminclude (void) const { return m_yliminclude.current_value (); }

  bool xdatamode_is (const std::string& v) const { return m_xdatamode.is (v); }
  std::string get_xdatamode (void) const { return m_xdatamode.current_value (); }

  bool ydatamode_is (const std::string& v) const { return m_ydatamode.is (v); }
  std::string get_ydatamode (void) const { return m_ydatamode.current_value (); }


  void set_alphadata (const octave_value& val)
  {
    if (m_alphadata.set (val, true))
      {
        update_alphadata ();
        mark_modified ();
      }
  }

  void set_alphadatamapping (const octave_value& val)
  {
    if (m_alphadatamapping.set (val, false))
      {
        update_axis_limits ("alphadatamapping");
        m_alphadatamapping.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
  }

  void set_cdata (const octave_value& val)
  {
    if (m_cdata.set (val, true))
      {
        update_cdata ();
        mark_modified ();
      }
  }

  void set_cdatamapping (const octave_value& val)
  {
    if (m_cdatamapping.set (val, false))
      {
        update_axis_limits ("cdatamapping");
        m_cdatamapping.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
  }

  void set_xdata (const octave_value& val)
  {
    if (m_xdata.set (val, false))
      {
        set_xdatamode ("manual");
        update_xdata ();
        m_xdata.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
    else
      set_xdatamode ("manual");
  }

  void set_ydata (const octave_value& val)
  {
    if (m_ydata.set (val, false))
      {
        set_ydatamode ("manual");
        update_ydata ();
        m_ydata.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
    else
      set_ydatamode ("manual");
  }

  void set_alim (const octave_value& val)
  {
    if (m_alim.set (val, false))
      {
        update_axis_limits ("alim");
        m_alim.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
  }

  void set_clim (const octave_value& val)
  {
    if (m_clim.set (val, false))
      {
        update_axis_limits ("clim");
        m_clim.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
  }

  void set_xlim (const octave_value& val)
  {
    if (m_xlim.set (val, false))
      {
        update_axis_limits ("xlim");
        m_xlim.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
  }

  void set_ylim (const octave_value& val)
  {
    if (m_ylim.set (val, false))
      {
        update_axis_limits ("ylim");
        m_ylim.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
  }

  void set_aliminclude (const octave_value& val)
  {
    if (m_aliminclude.set (val, false))
      {
        update_axis_limits ("aliminclude");
        m_aliminclude.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
  }

  void set_climinclude (const octave_value& val)
  {
    if (m_climinclude.set (val, false))
      {
        update_axis_limits ("climinclude");
        m_climinclude.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
  }

  void set_xliminclude (const octave_value& val)
  {
    if (m_xliminclude.set (val, false))
      {
        update_axis_limits ("xliminclude");
        m_xliminclude.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
  }

  void set_yliminclude (const octave_value& val)
  {
    if (m_yliminclude.set (val, false))
      {
        update_axis_limits ("yliminclude");
        m_yliminclude.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
  }

  void set_xdatamode (const octave_value& val)
  {
    if (m_xdatamode.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_ydatamode (const octave_value& val)
  {
    if (m_ydatamode.set (val, true))
      {
        mark_modified ();
      }
  }


  protected:
    void init (void)
    {
      m_xdata.add_constraint (2);
      m_xdata.add_constraint (dim_vector (0, 0));
      m_ydata.add_constraint (2);
      m_ydata.add_constraint (dim_vector (0, 0));
      m_cdata.add_constraint ("double");
      m_cdata.add_constraint ("single");
      m_cdata.add_constraint ("logical");
      m_cdata.add_constraint ("int8");
      m_cdata.add_constraint ("int16");
      m_cdata.add_constraint ("int32");
      m_cdata.add_constraint ("int64");
      m_cdata.add_constraint ("uint8");
      m_cdata.add_constraint ("uint16");
      m_cdata.add_constraint ("uint32");
      m_cdata.add_constraint ("uint64");
      m_cdata.add_constraint ("real");
      m_cdata.add_constraint (dim_vector (-1, -1));
      m_cdata.add_constraint (dim_vector (-1, -1, 3));
      m_alphadata.add_constraint ("double");
      m_alphadata.add_constraint ("uint8");
      m_alphadata.add_constraint (dim_vector (-1, -1));
    }

  private:
    void update_alphadata (void)
    {
      if (alphadatamapping_is ("scaled"))
        set_alim (m_alphadata.get_limits ());
      else
        m_alim = m_alphadata.get_limits ();
    }

    void update_cdata (void)
    {
      if (cdatamapping_is ("scaled"))
        set_clim (m_cdata.get_limits ());
      else
        m_clim = m_cdata.get_limits ();

      if (m_xdatamode.is ("auto"))
        update_xdata ();

      if (m_ydatamode.is ("auto"))
        update_ydata ();
    }

    void update_xdata (void)
    {
      if (m_xdata.get ().isempty ())
        set_xdatamode ("auto");

      if (m_xdatamode.is ("auto"))
        {
          set_xdata (get_auto_xdata ());
          set_xdatamode ("auto");
        }

      Matrix limits = m_xdata.get_limits ();
      float dp = pixel_xsize ();

      limits(0) = limits(0) - dp;
      limits(1) = limits(1) + dp;
      set_xlim (limits);
    }

    void update_ydata (void)
    {
      if (m_ydata.get ().isempty ())
        set_ydatamode ("auto");

      if (m_ydatamode.is ("auto"))
        {
          set_ydata (get_auto_ydata ());
          set_ydatamode ("auto");
        }

      Matrix limits = m_ydata.get_limits ();
      float dp = pixel_ysize ();

      limits(0) = limits(0) - dp;
      limits(1) = limits(1) + dp;
      set_ylim (limits);
    }

    Matrix get_auto_xdata (void)
    {
      dim_vector dv = get_cdata ().dims ();
      Matrix data;
      if (dv(1) > 0.)
        {
          data = Matrix (1, 2, 1);
          data(1) = dv(1);
        }
      return data;
    }

    Matrix get_auto_ydata (void)
    {
      dim_vector dv = get_cdata ().dims ();
      Matrix data;
      if (dv(0) > 0.)
        {
          data = Matrix (1, 2, 1);
          data(1) = dv(0);
        }
      return data;
    }

    float pixel_size (octave_idx_type dim, const Matrix limits)
    {
      octave_idx_type l = dim - 1;
      float dp;

      if (l > 0 && limits(0) != limits(1))
        dp = (limits(1) - limits(0))/(2*l);
      else
        {
          if (limits(1) == limits(2))
            dp = 0.5;
          else
            dp = (limits(1) - limits(0))/2;
        }
      return dp;
    }

  public:
    float pixel_xsize (void)
    {
      return pixel_size ((get_cdata ().dims ())(1), m_xdata.get_limits ());
    }

    float pixel_ysize (void)
    {
      return pixel_size ((get_cdata ().dims ())(0), m_ydata.get_limits ());
    }
  };

private:
  properties m_properties;

public:
  image (const graphics_handle& mh, const graphics_handle& p)
    : base_graphics_object (), m_properties (mh, p)
  {
    m_properties.initialize_data ();
  }

  ~image (void) = default;

  base_properties& get_properties (void) { return m_properties; }

  const base_properties& get_properties (void) const { return m_properties; }

  bool valid_object (void) const { return true; }

  bool has_readonly_property (const caseless_str& pname) const
  {
    bool retval = m_properties.has_readonly_property (pname);
    if (! retval)
      retval = base_properties::has_readonly_property (pname);
    return retval;
  }
};

// ---------------------------------------------------------------------

class OCTINTERP_API light : public base_graphics_object
{
public:

  class OCTINTERP_API properties : public base_properties
  {
    // See the genprops.awk script for an explanation of the
    // properties declarations.
    // Programming note: Keep property list sorted if new ones are added.

public:
  properties (const graphics_handle& mh, const graphics_handle& p);

  ~properties (void) { }

  void set (const caseless_str& pname, const octave_value& val);

  octave_value get (bool all = false) const;

  octave_value get (const caseless_str& pname) const;

  octave_value get (const std::string& pname) const
  {
    return get (caseless_str (pname));
  }

  octave_value get (const char *pname) const
  {
    return get (caseless_str (pname));
  }

  property get_property (const caseless_str& pname);

  std::string graphics_object_name (void) const { return s_go_name; }

  static property_list::pval_map_type factory_defaults (void);

private:
  static std::string s_go_name;

public:


  static std::set<std::string> core_property_names (void);

  static std::set<std::string> readonly_property_names (void);

  static bool has_core_property (const caseless_str& pname);

  static bool has_readonly_property (const caseless_str& pname);

  std::set<std::string> all_property_names (void) const;

  bool has_property (const caseless_str& pname) const;

private:

  color_property m_color;
  array_property m_position;
  radio_property m_style;

public:

  enum
  {
    ID_COLOR = 7000,
    ID_POSITION = 7001,
    ID_STYLE = 7002
  };

  bool color_is_rgb (void) const { return m_color.is_rgb (); }
  bool color_is (const std::string& v) const { return m_color.is (v); }
  Matrix get_color_rgb (void) const { return (m_color.is_rgb () ? m_color.rgb () : Matrix ()); }
  octave_value get_color (void) const { return m_color.get (); }

  octave_value get_position (void) const { return m_position.get (); }

  bool style_is (const std::string& v) const { return m_style.is (v); }
  std::string get_style (void) const { return m_style.current_value (); }


  void set_color (const octave_value& val)
  {
    if (m_color.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_position (const octave_value& val)
  {
    if (m_position.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_style (const octave_value& val)
  {
    if (m_style.set (val, true))
      {
        mark_modified ();
      }
  }


  protected:
    void init (void)
    {
      m_position.add_constraint (dim_vector (1, 3));
    }

  private:
    OCTINTERP_API void update_visible (void);
  };

private:
  properties m_properties;

public:
  light (const graphics_handle& mh, const graphics_handle& p)
    : base_graphics_object (), m_properties (mh, p)
  { }

  ~light (void) = default;

  base_properties& get_properties (void) { return m_properties; }

  const base_properties& get_properties (void) const { return m_properties; }

  bool valid_object (void) const { return true; }

  bool has_readonly_property (const caseless_str& pname) const
  {
    bool retval = m_properties.has_readonly_property (pname);
    if (! retval)
      retval = base_properties::has_readonly_property (pname);
    return retval;
  }

protected:
  OCTINTERP_API void initialize (const graphics_object& go);
};

// ---------------------------------------------------------------------

class OCTINTERP_API patch : public base_graphics_object
{
public:

  class OCTINTERP_API properties : public base_properties
  {
  public:

    octave_value get_color_data (void) const;

    // Matlab allows incoherent data to be stored into patch properties.
    // The patch should then be ignored by the renderer.
    bool has_bad_data (std::string& msg) const
    {
      msg = m_bad_data_msg;
      return ! msg.empty ();
    }

    bool is_aliminclude (void) const
    { return (m_aliminclude.is_on () && m_alphadatamapping.is ("scaled")); }
    std::string get_aliminclude (void) const
    { return m_aliminclude.current_value (); }

    bool is_climinclude (void) const
    { return (m_climinclude.is_on () && m_cdatamapping.is ("scaled")); }
    std::string get_climinclude (void) const
    { return m_climinclude.current_value (); }

    OCTINTERP_API bool get_do_lighting (void) const;

    std::vector<std::vector<octave_idx_type>> m_coplanar_last_idx;

    // See the genprops.awk script for an explanation of the
    // properties declarations.
    // Programming note: Keep property list sorted if new ones are added.

public:
  properties (const graphics_handle& mh, const graphics_handle& p);

  ~properties (void) { }

  void set (const caseless_str& pname, const octave_value& val);

  octave_value get (bool all = false) const;

  octave_value get (const caseless_str& pname) const;

  octave_value get (const std::string& pname) const
  {
    return get (caseless_str (pname));
  }

  octave_value get (const char *pname) const
  {
    return get (caseless_str (pname));
  }

  property get_property (const caseless_str& pname);

  std::string graphics_object_name (void) const { return s_go_name; }

  static property_list::pval_map_type factory_defaults (void);

private:
  static std::string s_go_name;

public:


  static std::set<std::string> core_property_names (void);

  static std::set<std::string> readonly_property_names (void);

  static bool has_core_property (const caseless_str& pname);

  static bool has_readonly_property (const caseless_str& pname);

  std::set<std::string> all_property_names (void) const;

  bool has_property (const caseless_str& pname) const;

private:

  radio_property m_alphadatamapping;
  double_property m_ambientstrength;
  radio_property m_backfacelighting;
  array_property m_cdata;
  radio_property m_cdatamapping;
  double_property m_diffusestrength;
  string_property m_displayname;
  double_radio_property m_edgealpha;
  color_property m_edgecolor;
  radio_property m_edgelighting;
  double_radio_property m_facealpha;
  color_property m_facecolor;
  radio_property m_facelighting;
  array_property m_facenormals;
  radio_property m_facenormalsmode;
  array_property m_faces;
  array_property m_facevertexalphadata;
  array_property m_facevertexcdata;
  radio_property m_linestyle;
  double_property m_linewidth;
  radio_property m_marker;
  color_property m_markeredgecolor;
  color_property m_markerfacecolor;
  double_property m_markersize;
  double_property m_specularcolorreflectance;
  double_property m_specularexponent;
  double_property m_specularstrength;
  array_property m_vertexnormals;
  radio_property m_vertexnormalsmode;
  array_property m_vertices;
  array_property m_xdata;
  array_property m_ydata;
  array_property m_zdata;
  row_vector_property m_alim;
  row_vector_property m_clim;
  row_vector_property m_xlim;
  row_vector_property m_ylim;
  row_vector_property m_zlim;
  bool_property m_aliminclude;
  bool_property m_climinclude;
  bool_property m_xliminclude;
  bool_property m_yliminclude;
  bool_property m_zliminclude;

public:

  enum
  {
    ID_ALPHADATAMAPPING = 8000,
    ID_AMBIENTSTRENGTH = 8001,
    ID_BACKFACELIGHTING = 8002,
    ID_CDATA = 8003,
    ID_CDATAMAPPING = 8004,
    ID_DIFFUSESTRENGTH = 8005,
    ID_DISPLAYNAME = 8006,
    ID_EDGEALPHA = 8007,
    ID_EDGECOLOR = 8008,
    ID_EDGELIGHTING = 8009,
    ID_FACEALPHA = 8010,
    ID_FACECOLOR = 8011,
    ID_FACELIGHTING = 8012,
    ID_FACENORMALS = 8013,
    ID_FACENORMALSMODE = 8014,
    ID_FACES = 8015,
    ID_FACEVERTEXALPHADATA = 8016,
    ID_FACEVERTEXCDATA = 8017,
    ID_LINESTYLE = 8018,
    ID_LINEWIDTH = 8019,
    ID_MARKER = 8020,
    ID_MARKEREDGECOLOR = 8021,
    ID_MARKERFACECOLOR = 8022,
    ID_MARKERSIZE = 8023,
    ID_SPECULARCOLORREFLECTANCE = 8024,
    ID_SPECULAREXPONENT = 8025,
    ID_SPECULARSTRENGTH = 8026,
    ID_VERTEXNORMALS = 8027,
    ID_VERTEXNORMALSMODE = 8028,
    ID_VERTICES = 8029,
    ID_XDATA = 8030,
    ID_YDATA = 8031,
    ID_ZDATA = 8032,
    ID_ALIM = 8033,
    ID_CLIM = 8034,
    ID_XLIM = 8035,
    ID_YLIM = 8036,
    ID_ZLIM = 8037,
    ID_ALIMINCLUDE = 8038,
    ID_CLIMINCLUDE = 8039,
    ID_XLIMINCLUDE = 8040,
    ID_YLIMINCLUDE = 8041,
    ID_ZLIMINCLUDE = 8042
  };

  bool alphadatamapping_is (const std::string& v) const { return m_alphadatamapping.is (v); }
  std::string get_alphadatamapping (void) const { return m_alphadatamapping.current_value (); }

  double get_ambientstrength (void) const { return m_ambientstrength.double_value (); }

  bool backfacelighting_is (const std::string& v) const { return m_backfacelighting.is (v); }
  std::string get_backfacelighting (void) const { return m_backfacelighting.current_value (); }

  octave_value get_cdata (void) const { return m_cdata.get (); }

  bool cdatamapping_is (const std::string& v) const { return m_cdatamapping.is (v); }
  std::string get_cdatamapping (void) const { return m_cdatamapping.current_value (); }

  double get_diffusestrength (void) const { return m_diffusestrength.double_value (); }

  std::string get_displayname (void) const { return m_displayname.string_value (); }

  bool edgealpha_is_double (void) const { return m_edgealpha.is_double (); }
  bool edgealpha_is (const std::string& v) const { return m_edgealpha.is (v); }
  double get_edgealpha_double (void) const { return (m_edgealpha.is_double () ? m_edgealpha.double_value () : 0); }
  octave_value get_edgealpha (void) const { return m_edgealpha.get (); }

  bool edgecolor_is_rgb (void) const { return m_edgecolor.is_rgb (); }
  bool edgecolor_is (const std::string& v) const { return m_edgecolor.is (v); }
  Matrix get_edgecolor_rgb (void) const { return (m_edgecolor.is_rgb () ? m_edgecolor.rgb () : Matrix ()); }
  octave_value get_edgecolor (void) const { return m_edgecolor.get (); }

  bool edgelighting_is (const std::string& v) const { return m_edgelighting.is (v); }
  std::string get_edgelighting (void) const { return m_edgelighting.current_value (); }

  bool facealpha_is_double (void) const { return m_facealpha.is_double (); }
  bool facealpha_is (const std::string& v) const { return m_facealpha.is (v); }
  double get_facealpha_double (void) const { return (m_facealpha.is_double () ? m_facealpha.double_value () : 0); }
  octave_value get_facealpha (void) const { return m_facealpha.get (); }

  bool facecolor_is_rgb (void) const { return m_facecolor.is_rgb (); }
  bool facecolor_is (const std::string& v) const { return m_facecolor.is (v); }
  Matrix get_facecolor_rgb (void) const { return (m_facecolor.is_rgb () ? m_facecolor.rgb () : Matrix ()); }
  octave_value get_facecolor (void) const { return m_facecolor.get (); }

  bool facelighting_is (const std::string& v) const { return m_facelighting.is (v); }
  std::string get_facelighting (void) const { return m_facelighting.current_value (); }

  octave_value get_facenormals (void) const { return m_facenormals.get (); }

  bool facenormalsmode_is (const std::string& v) const { return m_facenormalsmode.is (v); }
  std::string get_facenormalsmode (void) const { return m_facenormalsmode.current_value (); }

  octave_value get_faces (void) const { return m_faces.get (); }

  octave_value get_facevertexalphadata (void) const { return m_facevertexalphadata.get (); }

  octave_value get_facevertexcdata (void) const { return m_facevertexcdata.get (); }

  bool linestyle_is (const std::string& v) const { return m_linestyle.is (v); }
  std::string get_linestyle (void) const { return m_linestyle.current_value (); }

  double get_linewidth (void) const { return m_linewidth.double_value (); }

  bool marker_is (const std::string& v) const { return m_marker.is (v); }
  std::string get_marker (void) const { return m_marker.current_value (); }

  bool markeredgecolor_is_rgb (void) const { return m_markeredgecolor.is_rgb (); }
  bool markeredgecolor_is (const std::string& v) const { return m_markeredgecolor.is (v); }
  Matrix get_markeredgecolor_rgb (void) const { return (m_markeredgecolor.is_rgb () ? m_markeredgecolor.rgb () : Matrix ()); }
  octave_value get_markeredgecolor (void) const { return m_markeredgecolor.get (); }

  bool markerfacecolor_is_rgb (void) const { return m_markerfacecolor.is_rgb (); }
  bool markerfacecolor_is (const std::string& v) const { return m_markerfacecolor.is (v); }
  Matrix get_markerfacecolor_rgb (void) const { return (m_markerfacecolor.is_rgb () ? m_markerfacecolor.rgb () : Matrix ()); }
  octave_value get_markerfacecolor (void) const { return m_markerfacecolor.get (); }

  double get_markersize (void) const { return m_markersize.double_value (); }

  double get_specularcolorreflectance (void) const { return m_specularcolorreflectance.double_value (); }

  double get_specularexponent (void) const { return m_specularexponent.double_value (); }

  double get_specularstrength (void) const { return m_specularstrength.double_value (); }

  octave_value get_vertexnormals (void) const { return m_vertexnormals.get (); }

  bool vertexnormalsmode_is (const std::string& v) const { return m_vertexnormalsmode.is (v); }
  std::string get_vertexnormalsmode (void) const { return m_vertexnormalsmode.current_value (); }

  octave_value get_vertices (void) const { return m_vertices.get (); }

  octave_value get_xdata (void) const { return m_xdata.get (); }

  octave_value get_ydata (void) const { return m_ydata.get (); }

  octave_value get_zdata (void) const { return m_zdata.get (); }

  octave_value get_alim (void) const { return m_alim.get (); }

  octave_value get_clim (void) const { return m_clim.get (); }

  octave_value get_xlim (void) const { return m_xlim.get (); }

  octave_value get_ylim (void) const { return m_ylim.get (); }

  octave_value get_zlim (void) const { return m_zlim.get (); }

  bool is_xliminclude (void) const { return m_xliminclude.is_on (); }
  std::string get_xliminclude (void) const { return m_xliminclude.current_value (); }

  bool is_yliminclude (void) const { return m_yliminclude.is_on (); }
  std::string get_yliminclude (void) const { return m_yliminclude.current_value (); }

  bool is_zliminclude (void) const { return m_zliminclude.is_on (); }
  std::string get_zliminclude (void) const { return m_zliminclude.current_value (); }


  void set_alphadatamapping (const octave_value& val)
  {
    if (m_alphadatamapping.set (val, false))
      {
        update_axis_limits ("alphadatamapping");
        m_alphadatamapping.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
  }

  void set_ambientstrength (const octave_value& val)
  {
    if (m_ambientstrength.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_backfacelighting (const octave_value& val)
  {
    if (m_backfacelighting.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_cdata (const octave_value& val)
  {
    if (m_cdata.set (val, true))
      {
        update_cdata ();
        mark_modified ();
      }
  }

  void set_cdatamapping (const octave_value& val)
  {
    if (m_cdatamapping.set (val, false))
      {
        update_axis_limits ("cdatamapping");
        m_cdatamapping.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
  }

  void set_diffusestrength (const octave_value& val)
  {
    if (m_diffusestrength.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_displayname (const octave_value& val)
  {
    if (m_displayname.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_edgealpha (const octave_value& val)
  {
    if (m_edgealpha.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_edgecolor (const octave_value& val)
  {
    if (m_edgecolor.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_edgelighting (const octave_value& val)
  {
    if (m_edgelighting.set (val, true))
      {
        update_edgelighting ();
        mark_modified ();
      }
  }

  void set_facealpha (const octave_value& val)
  {
    if (m_facealpha.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_facecolor (const octave_value& val)
  {
    if (m_facecolor.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_facelighting (const octave_value& val)
  {
    if (m_facelighting.set (val, true))
      {
        update_facelighting ();
        mark_modified ();
      }
  }

  void set_facenormals (const octave_value& val)
  {
    if (m_facenormals.set (val, false))
      {
        set_facenormalsmode ("manual");
        m_facenormals.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
    else
      set_facenormalsmode ("manual");
  }

  void set_facenormalsmode (const octave_value& val)
  {
    if (m_facenormalsmode.set (val, true))
      {
        update_facenormalsmode ();
        mark_modified ();
      }
  }

  void set_faces (const octave_value& val)
  {
    if (m_faces.set (val, true))
      {
        update_faces ();
        mark_modified ();
      }
  }

  void set_facevertexalphadata (const octave_value& val)
  {
    if (m_facevertexalphadata.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_facevertexcdata (const octave_value& val)
  {
    if (m_facevertexcdata.set (val, true))
      {
        update_facevertexcdata ();
        mark_modified ();
      }
  }

  void set_linestyle (const octave_value& val)
  {
    if (m_linestyle.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_linewidth (const octave_value& val)
  {
    if (m_linewidth.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_marker (const octave_value& val)
  {
    if (m_marker.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_markeredgecolor (const octave_value& val)
  {
    if (m_markeredgecolor.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_markerfacecolor (const octave_value& val)
  {
    if (m_markerfacecolor.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_markersize (const octave_value& val)
  {
    if (m_markersize.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_specularcolorreflectance (const octave_value& val)
  {
    if (m_specularcolorreflectance.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_specularexponent (const octave_value& val)
  {
    if (m_specularexponent.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_specularstrength (const octave_value& val)
  {
    if (m_specularstrength.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_vertexnormals (const octave_value& val)
  {
    if (m_vertexnormals.set (val, false))
      {
        set_vertexnormalsmode ("manual");
        m_vertexnormals.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
    else
      set_vertexnormalsmode ("manual");
  }

  void set_vertexnormalsmode (const octave_value& val)
  {
    if (m_vertexnormalsmode.set (val, true))
      {
        update_vertexnormalsmode ();
        mark_modified ();
      }
  }

  void set_vertices (const octave_value& val)
  {
    if (m_vertices.set (val, true))
      {
        update_vertices ();
        mark_modified ();
      }
  }

  void set_xdata (const octave_value& val)
  {
    if (m_xdata.set (val, true))
      {
        update_xdata ();
        mark_modified ();
      }
  }

  void set_ydata (const octave_value& val)
  {
    if (m_ydata.set (val, true))
      {
        update_ydata ();
        mark_modified ();
      }
  }

  void set_zdata (const octave_value& val)
  {
    if (m_zdata.set (val, true))
      {
        update_zdata ();
        mark_modified ();
      }
  }

  void set_alim (const octave_value& val)
  {
    if (m_alim.set (val, false))
      {
        update_axis_limits ("alim");
        m_alim.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
  }

  void set_clim (const octave_value& val)
  {
    if (m_clim.set (val, false))
      {
        update_axis_limits ("clim");
        m_clim.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
  }

  void set_xlim (const octave_value& val)
  {
    if (m_xlim.set (val, false))
      {
        update_axis_limits ("xlim");
        m_xlim.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
  }

  void set_ylim (const octave_value& val)
  {
    if (m_ylim.set (val, false))
      {
        update_axis_limits ("ylim");
        m_ylim.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
  }

  void set_zlim (const octave_value& val)
  {
    if (m_zlim.set (val, false))
      {
        update_axis_limits ("zlim");
        m_zlim.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
  }

  void set_aliminclude (const octave_value& val)
  {
    if (m_aliminclude.set (val, false))
      {
        update_axis_limits ("aliminclude");
        m_aliminclude.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
  }

  void set_climinclude (const octave_value& val)
  {
    if (m_climinclude.set (val, false))
      {
        update_axis_limits ("climinclude");
        m_climinclude.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
  }

  void set_xliminclude (const octave_value& val)
  {
    if (m_xliminclude.set (val, false))
      {
        update_axis_limits ("xliminclude");
        m_xliminclude.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
  }

  void set_yliminclude (const octave_value& val)
  {
    if (m_yliminclude.set (val, false))
      {
        update_axis_limits ("yliminclude");
        m_yliminclude.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
  }

  void set_zliminclude (const octave_value& val)
  {
    if (m_zliminclude.set (val, false))
      {
        update_axis_limits ("zliminclude");
        m_zliminclude.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
  }


  protected:
    void init (void)
    {
      m_xdata.add_constraint (dim_vector (-1, -1));
      m_ydata.add_constraint (dim_vector (-1, -1));
      m_zdata.add_constraint (dim_vector (-1, -1));
      m_faces.add_constraint (dim_vector (-1, -1));
      m_vertices.add_constraint (dim_vector (-1, 2));
      m_vertices.add_constraint (dim_vector (-1, 3));
      m_cdata.add_constraint ("double");
      m_cdata.add_constraint ("single");
      m_cdata.add_constraint ("logical");
      m_cdata.add_constraint ("int8");
      m_cdata.add_constraint ("int16");
      m_cdata.add_constraint ("int32");
      m_cdata.add_constraint ("int64");
      m_cdata.add_constraint ("uint8");
      m_cdata.add_constraint ("uint16");
      m_cdata.add_constraint ("uint32");
      m_cdata.add_constraint ("uint64");
      m_cdata.add_constraint ("real");
      m_cdata.add_constraint (dim_vector (-1, -1));
      m_cdata.add_constraint (dim_vector (-1, -1, 3));
      m_facevertexcdata.add_constraint (dim_vector (-1, 1));
      m_facevertexcdata.add_constraint (dim_vector (-1, 3));
      m_facevertexcdata.add_constraint (dim_vector (0, 0));
      m_facevertexalphadata.add_constraint (dim_vector (-1, 1));
      m_facevertexalphadata.add_constraint (dim_vector (0, 0));
      m_facenormals.add_constraint (dim_vector (-1, 3));
      m_facenormals.add_constraint (dim_vector (0, 0));
      m_vertexnormals.add_constraint (dim_vector (-1, 3));
      m_vertexnormals.add_constraint (dim_vector (0, 0));

      m_ambientstrength.add_constraint ("min", 0.0, true);
      m_ambientstrength.add_constraint ("max", 1.0, true);
      m_diffusestrength.add_constraint ("min", 0.0, true);
      m_diffusestrength.add_constraint ("max", 1.0, true);
      m_linewidth.add_constraint ("min", 0.0, false);
      m_markersize.add_constraint ("min", 0.0, false);
      m_specularcolorreflectance.add_constraint ("min", 0.0, true);
      m_specularcolorreflectance.add_constraint ("max", 1.0, true);
      m_specularexponent.add_constraint ("min", 0.0, false);
      m_specularstrength.add_constraint ("min", 0.0, true);
      m_specularstrength.add_constraint ("max", 1.0, true);
    }

  public:
    void update_normals (bool reset, bool force = false)
    {
      update_face_normals (reset, force);
      update_vertex_normals (reset, force);
    }


  private:
    std::string m_bad_data_msg;

    void update_faces (void) { update_data ();}

    void update_vertices (void) { update_data ();}

    void update_facevertexcdata (void) { update_data ();}

    OCTINTERP_API void update_fvc (void);

    void update_xdata (void)
    {
      if (get_xdata ().isempty ())
        {
          // For compatibility with matlab behavior,
          // if x/ydata are set empty, silently empty other *data and
          // faces properties while vertices remain unchanged.
          set_ydata (Matrix ());
          set_zdata (Matrix ());
          set_cdata (Matrix ());
          set_faces (Matrix ());
        }
      else
        {
          update_fvc ();
          update_normals (true);
        }

      set_xlim (m_xdata.get_limits ());
    }

    void update_ydata (void)
    {
      if (get_ydata ().isempty ())
        {
          set_xdata (Matrix ());
          set_zdata (Matrix ());
          set_cdata (Matrix ());
          set_faces (Matrix ());
        }
      else
        {
          update_fvc ();
          update_normals (true);
        }

      set_ylim (m_ydata.get_limits ());
    }

    void update_zdata (void)
    {
      update_fvc ();
      update_normals (true);
      set_zlim (m_zdata.get_limits ());
    }

    void update_cdata (void)
    {
      update_fvc ();
      update_normals (false);

      if (cdatamapping_is ("scaled"))
        set_clim (m_cdata.get_limits ());
      else
        m_clim = m_cdata.get_limits ();
    }

    OCTINTERP_API void update_data (void);

    OCTINTERP_API void calc_face_normals (Matrix& normals);
    OCTINTERP_API void update_face_normals (bool reset, bool force = false);
    OCTINTERP_API void update_vertex_normals (bool reset, bool force = false);

    void update_edgelighting (void)
    {
      update_normals (false);
    }

    void update_facelighting (void)
    {
      update_normals (false);
    }

    void update_facenormalsmode (void)
    {
      update_face_normals (false);
    }

    void update_vertexnormalsmode (void)
    {
      update_vertex_normals (false);
    }

    void update_visible (void)
    {
      if (is_visible ())
        update_normals (false);
    }
  };

private:
  properties m_properties;
  property_list m_default_properties;

public:
  patch (const graphics_handle& mh, const graphics_handle& p)
    : base_graphics_object (), m_properties (mh, p)
  { }

  ~patch (void) = default;

  base_properties& get_properties (void) { return m_properties; }

  const base_properties& get_properties (void) const { return m_properties; }

  bool valid_object (void) const { return true; }

  bool has_readonly_property (const caseless_str& pname) const
  {
    bool retval = m_properties.has_readonly_property (pname);
    if (! retval)
      retval = base_properties::has_readonly_property (pname);
    return retval;
  }

  OCTINTERP_API void reset_default_properties (void);

protected:
  OCTINTERP_API void initialize (const graphics_object& go);

};

// ---------------------------------------------------------------------

class OCTINTERP_API scatter : public base_graphics_object
{
public:

  class OCTINTERP_API properties : public base_properties
  {
  public:

    OCTINTERP_API octave_value get_color_data (void) const;

    // Matlab allows incoherent data to be stored in scatter properties.
    // The scatter object should then be ignored by the renderer.
    bool has_bad_data (std::string& msg) const
    {
      msg = m_bad_data_msg;
      return ! msg.empty ();
    }

    bool is_aliminclude (void) const
    { return m_aliminclude.is_on (); }
    std::string get_aliminclude (void) const
    { return m_aliminclude.current_value (); }

    bool is_climinclude (void) const
    { return m_climinclude.is_on (); }
    std::string get_climinclude (void) const
    { return m_climinclude.current_value (); }

    // See the genprops.awk script for an explanation of the
    // properties declarations.
    // Programming note: Keep property list sorted if new ones are added.

public:
  properties (const graphics_handle& mh, const graphics_handle& p);

  ~properties (void) { }

  void set (const caseless_str& pname, const octave_value& val);

  octave_value get (bool all = false) const;

  octave_value get (const caseless_str& pname) const;

  octave_value get (const std::string& pname) const
  {
    return get (caseless_str (pname));
  }

  octave_value get (const char *pname) const
  {
    return get (caseless_str (pname));
  }

  property get_property (const caseless_str& pname);

  std::string graphics_object_name (void) const { return s_go_name; }

  static property_list::pval_map_type factory_defaults (void);

private:
  static std::string s_go_name;

public:


  static std::set<std::string> core_property_names (void);

  static std::set<std::string> readonly_property_names (void);

  static bool has_core_property (const caseless_str& pname);

  static bool has_readonly_property (const caseless_str& pname);

  std::set<std::string> all_property_names (void) const;

  bool has_property (const caseless_str& pname) const;

private:

  array_property m_annotation;
  array_property m_cdata;
  radio_property m_cdatamode;
  string_property m_cdatasource;
  array_property m_datatiptemplate;
  string_property m_displayname;
  array_property m_latitudedata;
  string_property m_latitudedatasource;
  double_property m_linewidth;
  array_property m_longitudedata;
  string_property m_longitudedatasource;
  radio_property m_marker;
  double_property m_markeredgealpha;
  color_property m_markeredgecolor;
  double_property m_markerfacealpha;
  color_property m_markerfacecolor;
  array_property m_rdata;
  string_property m_rdatasource;
  array_property m_seriesindex;
  array_property m_sizedata;
  string_property m_sizedatasource;
  array_property m_thetadata;
  string_property m_thetadatasource;
  array_property m_xdata;
  string_property m_xdatasource;
  array_property m_ydata;
  string_property m_ydatasource;
  array_property m_zdata;
  string_property m_zdatasource;
  row_vector_property m_alim;
  row_vector_property m_clim;
  row_vector_property m_xlim;
  row_vector_property m_ylim;
  row_vector_property m_zlim;
  bool_property m_aliminclude;
  bool_property m_climinclude;
  bool_property m_xliminclude;
  bool_property m_yliminclude;
  bool_property m_zliminclude;

public:

  enum
  {
    ID_ANNOTATION = 9000,
    ID_CDATA = 9001,
    ID_CDATAMODE = 9002,
    ID_CDATASOURCE = 9003,
    ID_DATATIPTEMPLATE = 9004,
    ID_DISPLAYNAME = 9005,
    ID_LATITUDEDATA = 9006,
    ID_LATITUDEDATASOURCE = 9007,
    ID_LINEWIDTH = 9008,
    ID_LONGITUDEDATA = 9009,
    ID_LONGITUDEDATASOURCE = 9010,
    ID_MARKER = 9011,
    ID_MARKEREDGEALPHA = 9012,
    ID_MARKEREDGECOLOR = 9013,
    ID_MARKERFACEALPHA = 9014,
    ID_MARKERFACECOLOR = 9015,
    ID_RDATA = 9016,
    ID_RDATASOURCE = 9017,
    ID_SERIESINDEX = 9018,
    ID_SIZEDATA = 9019,
    ID_SIZEDATASOURCE = 9020,
    ID_THETADATA = 9021,
    ID_THETADATASOURCE = 9022,
    ID_XDATA = 9023,
    ID_XDATASOURCE = 9024,
    ID_YDATA = 9025,
    ID_YDATASOURCE = 9026,
    ID_ZDATA = 9027,
    ID_ZDATASOURCE = 9028,
    ID_ALIM = 9029,
    ID_CLIM = 9030,
    ID_XLIM = 9031,
    ID_YLIM = 9032,
    ID_ZLIM = 9033,
    ID_ALIMINCLUDE = 9034,
    ID_CLIMINCLUDE = 9035,
    ID_XLIMINCLUDE = 9036,
    ID_YLIMINCLUDE = 9037,
    ID_ZLIMINCLUDE = 9038
  };

  octave_value get_annotation (void) const { return m_annotation.get (); }

  octave_value get_cdata (void) const { return m_cdata.get (); }

  bool cdatamode_is (const std::string& v) const { return m_cdatamode.is (v); }
  std::string get_cdatamode (void) const { return m_cdatamode.current_value (); }

  std::string get_cdatasource (void) const { return m_cdatasource.string_value (); }

  octave_value get_datatiptemplate (void) const { return m_datatiptemplate.get (); }

  std::string get_displayname (void) const { return m_displayname.string_value (); }

  octave_value get_latitudedata (void) const { return m_latitudedata.get (); }

  std::string get_latitudedatasource (void) const { return m_latitudedatasource.string_value (); }

  double get_linewidth (void) const { return m_linewidth.double_value (); }

  octave_value get_longitudedata (void) const { return m_longitudedata.get (); }

  std::string get_longitudedatasource (void) const { return m_longitudedatasource.string_value (); }

  bool marker_is (const std::string& v) const { return m_marker.is (v); }
  std::string get_marker (void) const { return m_marker.current_value (); }

  double get_markeredgealpha (void) const { return m_markeredgealpha.double_value (); }

  bool markeredgecolor_is_rgb (void) const { return m_markeredgecolor.is_rgb (); }
  bool markeredgecolor_is (const std::string& v) const { return m_markeredgecolor.is (v); }
  Matrix get_markeredgecolor_rgb (void) const { return (m_markeredgecolor.is_rgb () ? m_markeredgecolor.rgb () : Matrix ()); }
  octave_value get_markeredgecolor (void) const { return m_markeredgecolor.get (); }

  double get_markerfacealpha (void) const { return m_markerfacealpha.double_value (); }

  bool markerfacecolor_is_rgb (void) const { return m_markerfacecolor.is_rgb (); }
  bool markerfacecolor_is (const std::string& v) const { return m_markerfacecolor.is (v); }
  Matrix get_markerfacecolor_rgb (void) const { return (m_markerfacecolor.is_rgb () ? m_markerfacecolor.rgb () : Matrix ()); }
  octave_value get_markerfacecolor (void) const { return m_markerfacecolor.get (); }

  octave_value get_rdata (void) const { return m_rdata.get (); }

  std::string get_rdatasource (void) const { return m_rdatasource.string_value (); }

  octave_value get_seriesindex (void) const { return m_seriesindex.get (); }

  octave_value get_sizedata (void) const { return m_sizedata.get (); }

  std::string get_sizedatasource (void) const { return m_sizedatasource.string_value (); }

  octave_value get_thetadata (void) const { return m_thetadata.get (); }

  std::string get_thetadatasource (void) const { return m_thetadatasource.string_value (); }

  octave_value get_xdata (void) const { return m_xdata.get (); }

  std::string get_xdatasource (void) const { return m_xdatasource.string_value (); }

  octave_value get_ydata (void) const { return m_ydata.get (); }

  std::string get_ydatasource (void) const { return m_ydatasource.string_value (); }

  octave_value get_zdata (void) const { return m_zdata.get (); }

  std::string get_zdatasource (void) const { return m_zdatasource.string_value (); }

  octave_value get_alim (void) const { return m_alim.get (); }

  octave_value get_clim (void) const { return m_clim.get (); }

  octave_value get_xlim (void) const { return m_xlim.get (); }

  octave_value get_ylim (void) const { return m_ylim.get (); }

  octave_value get_zlim (void) const { return m_zlim.get (); }

  bool is_xliminclude (void) const { return m_xliminclude.is_on (); }
  std::string get_xliminclude (void) const { return m_xliminclude.current_value (); }

  bool is_yliminclude (void) const { return m_yliminclude.is_on (); }
  std::string get_yliminclude (void) const { return m_yliminclude.current_value (); }

  bool is_zliminclude (void) const { return m_zliminclude.is_on (); }
  std::string get_zliminclude (void) const { return m_zliminclude.current_value (); }


  void set_annotation (const octave_value& val)
  {
    if (m_annotation.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_cdata (const octave_value& val)
  {
    if (m_cdata.set (val, false))
      {
        set_cdatamode ("manual");
        update_cdata ();
        m_cdata.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
    else
      set_cdatamode ("manual");
  }

  void set_cdatamode (const octave_value& val)
  {
    if (m_cdatamode.set (val, true))
      {
        update_cdatamode ();
        mark_modified ();
      }
  }

  void set_cdatasource (const octave_value& val)
  {
    if (m_cdatasource.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_datatiptemplate (const octave_value& val)
  {
    if (m_datatiptemplate.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_displayname (const octave_value& val)
  {
    if (m_displayname.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_latitudedata (const octave_value& val)
  {
    if (m_latitudedata.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_latitudedatasource (const octave_value& val)
  {
    if (m_latitudedatasource.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_linewidth (const octave_value& val)
  {
    if (m_linewidth.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_longitudedata (const octave_value& val)
  {
    if (m_longitudedata.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_longitudedatasource (const octave_value& val)
  {
    if (m_longitudedatasource.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_marker (const octave_value& val)
  {
    if (m_marker.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_markeredgealpha (const octave_value& val)
  {
    if (m_markeredgealpha.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_markeredgecolor (const octave_value& val)
  {
    if (m_markeredgecolor.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_markerfacealpha (const octave_value& val)
  {
    if (m_markerfacealpha.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_markerfacecolor (const octave_value& val)
  {
    if (m_markerfacecolor.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_rdata (const octave_value& val)
  {
    if (m_rdata.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_rdatasource (const octave_value& val)
  {
    if (m_rdatasource.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_seriesindex (const octave_value& val)
  {
    if (m_seriesindex.set (val, true))
      {
        update_seriesindex ();
        mark_modified ();
      }
  }

  void set_sizedata (const octave_value& val)
  {
    if (m_sizedata.set (val, true))
      {
        update_sizedata ();
        mark_modified ();
      }
  }

  void set_sizedatasource (const octave_value& val)
  {
    if (m_sizedatasource.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_thetadata (const octave_value& val)
  {
    if (m_thetadata.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_thetadatasource (const octave_value& val)
  {
    if (m_thetadatasource.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_xdata (const octave_value& val)
  {
    if (m_xdata.set (val, true))
      {
        update_xdata ();
        mark_modified ();
      }
  }

  void set_xdatasource (const octave_value& val)
  {
    if (m_xdatasource.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_ydata (const octave_value& val)
  {
    if (m_ydata.set (val, true))
      {
        update_ydata ();
        mark_modified ();
      }
  }

  void set_ydatasource (const octave_value& val)
  {
    if (m_ydatasource.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_zdata (const octave_value& val)
  {
    if (m_zdata.set (val, true))
      {
        update_zdata ();
        mark_modified ();
      }
  }

  void set_zdatasource (const octave_value& val)
  {
    if (m_zdatasource.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_alim (const octave_value& val)
  {
    if (m_alim.set (val, false))
      {
        update_axis_limits ("alim");
        m_alim.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
  }

  void set_clim (const octave_value& val)
  {
    if (m_clim.set (val, false))
      {
        update_axis_limits ("clim");
        m_clim.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
  }

  void set_xlim (const octave_value& val)
  {
    if (m_xlim.set (val, false))
      {
        update_axis_limits ("xlim");
        m_xlim.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
  }

  void set_ylim (const octave_value& val)
  {
    if (m_ylim.set (val, false))
      {
        update_axis_limits ("ylim");
        m_ylim.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
  }

  void set_zlim (const octave_value& val)
  {
    if (m_zlim.set (val, false))
      {
        update_axis_limits ("zlim");
        m_zlim.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
  }

  void set_aliminclude (const octave_value& val)
  {
    if (m_aliminclude.set (val, false))
      {
        update_axis_limits ("aliminclude");
        m_aliminclude.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
  }

  void set_climinclude (const octave_value& val)
  {
    if (m_climinclude.set (val, false))
      {
        update_axis_limits ("climinclude");
        m_climinclude.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
  }

  void set_xliminclude (const octave_value& val)
  {
    if (m_xliminclude.set (val, false))
      {
        update_axis_limits ("xliminclude");
        m_xliminclude.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
  }

  void set_yliminclude (const octave_value& val)
  {
    if (m_yliminclude.set (val, false))
      {
        update_axis_limits ("yliminclude");
        m_yliminclude.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
  }

  void set_zliminclude (const octave_value& val)
  {
    if (m_zliminclude.set (val, false))
      {
        update_axis_limits ("zliminclude");
        m_zliminclude.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
  }


  protected:
    void init (void)
    {
      m_xdata.add_constraint (dim_vector (-1, 1));
      m_xdata.add_constraint (dim_vector (1, -1));
      m_xdata.add_constraint (dim_vector (-1, 0));
      m_xdata.add_constraint (dim_vector (0, -1));
      m_ydata.add_constraint (dim_vector (-1, 1));
      m_ydata.add_constraint (dim_vector (1, -1));
      m_ydata.add_constraint (dim_vector (-1, 0));
      m_ydata.add_constraint (dim_vector (0, -1));
      m_zdata.add_constraint (dim_vector (-1, 1));
      m_zdata.add_constraint (dim_vector (1, -1));
      m_zdata.add_constraint (dim_vector (-1, 0));
      m_zdata.add_constraint (dim_vector (0, -1));
      m_sizedata.add_constraint ("min", 0.0, false);
      m_sizedata.add_constraint (dim_vector (-1, 1));
      m_sizedata.add_constraint (dim_vector (1, -1));
      m_sizedata.add_constraint (dim_vector (-1, 0));
      m_sizedata.add_constraint (dim_vector (0, -1));
      m_cdata.add_constraint ("double");
      m_cdata.add_constraint ("single");
      m_cdata.add_constraint ("logical");
      m_cdata.add_constraint ("int8");
      m_cdata.add_constraint ("int16");
      m_cdata.add_constraint ("int32");
      m_cdata.add_constraint ("int64");
      m_cdata.add_constraint ("uint8");
      m_cdata.add_constraint ("uint16");
      m_cdata.add_constraint ("uint32");
      m_cdata.add_constraint ("uint64");
      m_cdata.add_constraint ("real");
      m_cdata.add_constraint (dim_vector (-1, 1));
      m_cdata.add_constraint (dim_vector (-1, 3));
      m_cdata.add_constraint (dim_vector (-1, 0));
      m_cdata.add_constraint (dim_vector (0, -1));

      m_linewidth.add_constraint ("min", 0.0, false);
      m_seriesindex.add_constraint (dim_vector (1, 1));
      m_seriesindex.add_constraint (dim_vector (-1, 0));
      m_seriesindex.add_constraint (dim_vector (0, -1));
    }

  public:
    OCTINTERP_API void update_color (void);

  private:
    std::string m_bad_data_msg;

    void update_xdata (void)
    {
      if (get_xdata ().isempty ())
        {
          // For compatibility with Matlab behavior,
          // if x/ydata are set empty, silently empty other *data properties.
          set_ydata (Matrix ());
          set_zdata (Matrix ());
          bool cdatamode_auto = m_cdatamode.is ("auto");
          set_cdata (Matrix ());
          if (cdatamode_auto)
            set_cdatamode ("auto");
        }

      set_xlim (m_xdata.get_limits ());

      update_data ();
    }

    void update_ydata (void)
    {
      if (get_ydata ().isempty ())
        {
          set_xdata (Matrix ());
          set_zdata (Matrix ());
          bool cdatamode_auto = m_cdatamode.is ("auto");
          set_cdata (Matrix ());
          if (cdatamode_auto)
            set_cdatamode ("auto");
        }

      set_ylim (m_ydata.get_limits ());

      update_data ();
    }

    void update_zdata (void)
    {
      set_zlim (m_zdata.get_limits ());

      update_data ();
    }

    void update_sizedata (void)
    {
      update_data ();
    }

    void update_cdata (void)
    {
      if (get_cdata ().matrix_value ().rows () == 1)
        set_clim (m_cdata.get_limits ());
      else
        m_clim = m_cdata.get_limits ();

      update_data ();
    }

    void update_cdatamode (void)
    {
      if (m_cdatamode.is ("auto"))
        update_color ();
    }

    void update_seriesindex (void)
    {
      if (m_cdatamode.is ("auto"))
        update_color ();
    }

    void update_data (void);

  };

private:
  properties m_properties;
  property_list m_default_properties;

public:
  scatter (const graphics_handle& mh, const graphics_handle& p)
    : base_graphics_object (), m_properties (mh, p)
  {
    // FIXME: seriesindex should increment by one each time a new scatter
    // object is added to the axes.
  }

  ~scatter (void) = default;

  base_properties& get_properties (void) { return m_properties; }

  const base_properties& get_properties (void) const { return m_properties; }

  bool valid_object (void) const { return true; }

  bool has_readonly_property (const caseless_str& pname) const
  {
    bool retval = m_properties.has_readonly_property (pname);
    if (! retval)
      retval = base_properties::has_readonly_property (pname);
    return retval;
  }

protected:
  OCTINTERP_API void initialize (const graphics_object& go);

};

// ---------------------------------------------------------------------

class OCTINTERP_API surface : public base_graphics_object
{
public:

  class OCTINTERP_API properties : public base_properties
  {
  public:

    octave_value get_color_data (void) const;

    bool is_aliminclude (void) const
    { return (m_aliminclude.is_on () && m_alphadatamapping.is ("scaled")); }
    std::string get_aliminclude (void) const
    { return m_aliminclude.current_value (); }

    bool is_climinclude (void) const
    { return (m_climinclude.is_on () && m_cdatamapping.is ("scaled")); }
    std::string get_climinclude (void) const
    { return m_climinclude.current_value (); }

    OCTINTERP_API bool get_do_lighting (void) const;

    // See the genprops.awk script for an explanation of the
    // properties declarations.
    // Programming note: Keep property list sorted if new ones are added.

public:
  properties (const graphics_handle& mh, const graphics_handle& p);

  ~properties (void) { }

  void set (const caseless_str& pname, const octave_value& val);

  octave_value get (bool all = false) const;

  octave_value get (const caseless_str& pname) const;

  octave_value get (const std::string& pname) const
  {
    return get (caseless_str (pname));
  }

  octave_value get (const char *pname) const
  {
    return get (caseless_str (pname));
  }

  property get_property (const caseless_str& pname);

  std::string graphics_object_name (void) const { return s_go_name; }

  static property_list::pval_map_type factory_defaults (void);

private:
  static std::string s_go_name;

public:


  static std::set<std::string> core_property_names (void);

  static std::set<std::string> readonly_property_names (void);

  static bool has_core_property (const caseless_str& pname);

  static bool has_readonly_property (const caseless_str& pname);

  std::set<std::string> all_property_names (void) const;

  bool has_property (const caseless_str& pname) const;

private:

  array_property m_alphadata;
  radio_property m_alphadatamapping;
  double_property m_ambientstrength;
  radio_property m_backfacelighting;
  array_property m_cdata;
  radio_property m_cdatamapping;
  string_property m_cdatasource;
  double_property m_diffusestrength;
  string_property m_displayname;
  double_radio_property m_edgealpha;
  color_property m_edgecolor;
  radio_property m_edgelighting;
  double_radio_property m_facealpha;
  color_property m_facecolor;
  radio_property m_facelighting;
  array_property m_facenormals;
  radio_property m_facenormalsmode;
  radio_property m_linestyle;
  double_property m_linewidth;
  radio_property m_marker;
  color_property m_markeredgecolor;
  color_property m_markerfacecolor;
  double_property m_markersize;
  radio_property m_meshstyle;
  double_property m_specularcolorreflectance;
  double_property m_specularexponent;
  double_property m_specularstrength;
  array_property m_vertexnormals;
  radio_property m_vertexnormalsmode;
  array_property m_xdata;
  string_property m_xdatasource;
  array_property m_ydata;
  string_property m_ydatasource;
  array_property m_zdata;
  string_property m_zdatasource;
  row_vector_property m_alim;
  row_vector_property m_clim;
  row_vector_property m_xlim;
  row_vector_property m_ylim;
  row_vector_property m_zlim;
  bool_property m_aliminclude;
  bool_property m_climinclude;
  bool_property m_xliminclude;
  bool_property m_yliminclude;
  bool_property m_zliminclude;

public:

  enum
  {
    ID_ALPHADATA = 10000,
    ID_ALPHADATAMAPPING = 10001,
    ID_AMBIENTSTRENGTH = 10002,
    ID_BACKFACELIGHTING = 10003,
    ID_CDATA = 10004,
    ID_CDATAMAPPING = 10005,
    ID_CDATASOURCE = 10006,
    ID_DIFFUSESTRENGTH = 10007,
    ID_DISPLAYNAME = 10008,
    ID_EDGEALPHA = 10009,
    ID_EDGECOLOR = 10010,
    ID_EDGELIGHTING = 10011,
    ID_FACEALPHA = 10012,
    ID_FACECOLOR = 10013,
    ID_FACELIGHTING = 10014,
    ID_FACENORMALS = 10015,
    ID_FACENORMALSMODE = 10016,
    ID_LINESTYLE = 10017,
    ID_LINEWIDTH = 10018,
    ID_MARKER = 10019,
    ID_MARKEREDGECOLOR = 10020,
    ID_MARKERFACECOLOR = 10021,
    ID_MARKERSIZE = 10022,
    ID_MESHSTYLE = 10023,
    ID_SPECULARCOLORREFLECTANCE = 10024,
    ID_SPECULAREXPONENT = 10025,
    ID_SPECULARSTRENGTH = 10026,
    ID_VERTEXNORMALS = 10027,
    ID_VERTEXNORMALSMODE = 10028,
    ID_XDATA = 10029,
    ID_XDATASOURCE = 10030,
    ID_YDATA = 10031,
    ID_YDATASOURCE = 10032,
    ID_ZDATA = 10033,
    ID_ZDATASOURCE = 10034,
    ID_ALIM = 10035,
    ID_CLIM = 10036,
    ID_XLIM = 10037,
    ID_YLIM = 10038,
    ID_ZLIM = 10039,
    ID_ALIMINCLUDE = 10040,
    ID_CLIMINCLUDE = 10041,
    ID_XLIMINCLUDE = 10042,
    ID_YLIMINCLUDE = 10043,
    ID_ZLIMINCLUDE = 10044
  };

  octave_value get_alphadata (void) const { return m_alphadata.get (); }

  bool alphadatamapping_is (const std::string& v) const { return m_alphadatamapping.is (v); }
  std::string get_alphadatamapping (void) const { return m_alphadatamapping.current_value (); }

  double get_ambientstrength (void) const { return m_ambientstrength.double_value (); }

  bool backfacelighting_is (const std::string& v) const { return m_backfacelighting.is (v); }
  std::string get_backfacelighting (void) const { return m_backfacelighting.current_value (); }

  octave_value get_cdata (void) const { return m_cdata.get (); }

  bool cdatamapping_is (const std::string& v) const { return m_cdatamapping.is (v); }
  std::string get_cdatamapping (void) const { return m_cdatamapping.current_value (); }

  std::string get_cdatasource (void) const { return m_cdatasource.string_value (); }

  double get_diffusestrength (void) const { return m_diffusestrength.double_value (); }

  std::string get_displayname (void) const { return m_displayname.string_value (); }

  bool edgealpha_is_double (void) const { return m_edgealpha.is_double (); }
  bool edgealpha_is (const std::string& v) const { return m_edgealpha.is (v); }
  double get_edgealpha_double (void) const { return (m_edgealpha.is_double () ? m_edgealpha.double_value () : 0); }
  octave_value get_edgealpha (void) const { return m_edgealpha.get (); }

  bool edgecolor_is_rgb (void) const { return m_edgecolor.is_rgb (); }
  bool edgecolor_is (const std::string& v) const { return m_edgecolor.is (v); }
  Matrix get_edgecolor_rgb (void) const { return (m_edgecolor.is_rgb () ? m_edgecolor.rgb () : Matrix ()); }
  octave_value get_edgecolor (void) const { return m_edgecolor.get (); }

  bool edgelighting_is (const std::string& v) const { return m_edgelighting.is (v); }
  std::string get_edgelighting (void) const { return m_edgelighting.current_value (); }

  bool facealpha_is_double (void) const { return m_facealpha.is_double (); }
  bool facealpha_is (const std::string& v) const { return m_facealpha.is (v); }
  double get_facealpha_double (void) const { return (m_facealpha.is_double () ? m_facealpha.double_value () : 0); }
  octave_value get_facealpha (void) const { return m_facealpha.get (); }

  bool facecolor_is_rgb (void) const { return m_facecolor.is_rgb (); }
  bool facecolor_is (const std::string& v) const { return m_facecolor.is (v); }
  Matrix get_facecolor_rgb (void) const { return (m_facecolor.is_rgb () ? m_facecolor.rgb () : Matrix ()); }
  octave_value get_facecolor (void) const { return m_facecolor.get (); }

  bool facelighting_is (const std::string& v) const { return m_facelighting.is (v); }
  std::string get_facelighting (void) const { return m_facelighting.current_value (); }

  octave_value get_facenormals (void) const { return m_facenormals.get (); }

  bool facenormalsmode_is (const std::string& v) const { return m_facenormalsmode.is (v); }
  std::string get_facenormalsmode (void) const { return m_facenormalsmode.current_value (); }

  bool linestyle_is (const std::string& v) const { return m_linestyle.is (v); }
  std::string get_linestyle (void) const { return m_linestyle.current_value (); }

  double get_linewidth (void) const { return m_linewidth.double_value (); }

  bool marker_is (const std::string& v) const { return m_marker.is (v); }
  std::string get_marker (void) const { return m_marker.current_value (); }

  bool markeredgecolor_is_rgb (void) const { return m_markeredgecolor.is_rgb (); }
  bool markeredgecolor_is (const std::string& v) const { return m_markeredgecolor.is (v); }
  Matrix get_markeredgecolor_rgb (void) const { return (m_markeredgecolor.is_rgb () ? m_markeredgecolor.rgb () : Matrix ()); }
  octave_value get_markeredgecolor (void) const { return m_markeredgecolor.get (); }

  bool markerfacecolor_is_rgb (void) const { return m_markerfacecolor.is_rgb (); }
  bool markerfacecolor_is (const std::string& v) const { return m_markerfacecolor.is (v); }
  Matrix get_markerfacecolor_rgb (void) const { return (m_markerfacecolor.is_rgb () ? m_markerfacecolor.rgb () : Matrix ()); }
  octave_value get_markerfacecolor (void) const { return m_markerfacecolor.get (); }

  double get_markersize (void) const { return m_markersize.double_value (); }

  bool meshstyle_is (const std::string& v) const { return m_meshstyle.is (v); }
  std::string get_meshstyle (void) const { return m_meshstyle.current_value (); }

  double get_specularcolorreflectance (void) const { return m_specularcolorreflectance.double_value (); }

  double get_specularexponent (void) const { return m_specularexponent.double_value (); }

  double get_specularstrength (void) const { return m_specularstrength.double_value (); }

  octave_value get_vertexnormals (void) const { return m_vertexnormals.get (); }

  bool vertexnormalsmode_is (const std::string& v) const { return m_vertexnormalsmode.is (v); }
  std::string get_vertexnormalsmode (void) const { return m_vertexnormalsmode.current_value (); }

  octave_value get_xdata (void) const { return m_xdata.get (); }

  std::string get_xdatasource (void) const { return m_xdatasource.string_value (); }

  octave_value get_ydata (void) const { return m_ydata.get (); }

  std::string get_ydatasource (void) const { return m_ydatasource.string_value (); }

  octave_value get_zdata (void) const { return m_zdata.get (); }

  std::string get_zdatasource (void) const { return m_zdatasource.string_value (); }

  octave_value get_alim (void) const { return m_alim.get (); }

  octave_value get_clim (void) const { return m_clim.get (); }

  octave_value get_xlim (void) const { return m_xlim.get (); }

  octave_value get_ylim (void) const { return m_ylim.get (); }

  octave_value get_zlim (void) const { return m_zlim.get (); }

  bool is_xliminclude (void) const { return m_xliminclude.is_on (); }
  std::string get_xliminclude (void) const { return m_xliminclude.current_value (); }

  bool is_yliminclude (void) const { return m_yliminclude.is_on (); }
  std::string get_yliminclude (void) const { return m_yliminclude.current_value (); }

  bool is_zliminclude (void) const { return m_zliminclude.is_on (); }
  std::string get_zliminclude (void) const { return m_zliminclude.current_value (); }


  void set_alphadata (const octave_value& val)
  {
    if (m_alphadata.set (val, true))
      {
        update_alphadata ();
        mark_modified ();
      }
  }

  void set_alphadatamapping (const octave_value& val)
  {
    if (m_alphadatamapping.set (val, false))
      {
        update_axis_limits ("alphadatamapping");
        m_alphadatamapping.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
  }

  void set_ambientstrength (const octave_value& val)
  {
    if (m_ambientstrength.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_backfacelighting (const octave_value& val)
  {
    if (m_backfacelighting.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_cdata (const octave_value& val)
  {
    if (m_cdata.set (val, true))
      {
        update_cdata ();
        mark_modified ();
      }
  }

  void set_cdatamapping (const octave_value& val)
  {
    if (m_cdatamapping.set (val, false))
      {
        update_axis_limits ("cdatamapping");
        m_cdatamapping.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
  }

  void set_cdatasource (const octave_value& val)
  {
    if (m_cdatasource.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_diffusestrength (const octave_value& val)
  {
    if (m_diffusestrength.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_displayname (const octave_value& val)
  {
    if (m_displayname.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_edgealpha (const octave_value& val)
  {
    if (m_edgealpha.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_edgecolor (const octave_value& val)
  {
    if (m_edgecolor.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_edgelighting (const octave_value& val)
  {
    if (m_edgelighting.set (val, true))
      {
        update_edgelighting ();
        mark_modified ();
      }
  }

  void set_facealpha (const octave_value& val)
  {
    if (m_facealpha.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_facecolor (const octave_value& val)
  {
    if (m_facecolor.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_facelighting (const octave_value& val)
  {
    if (m_facelighting.set (val, true))
      {
        update_facelighting ();
        mark_modified ();
      }
  }

  void set_facenormals (const octave_value& val)
  {
    if (m_facenormals.set (val, false))
      {
        set_facenormalsmode ("manual");
        m_facenormals.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
    else
      set_facenormalsmode ("manual");
  }

  void set_facenormalsmode (const octave_value& val)
  {
    if (m_facenormalsmode.set (val, true))
      {
        update_facenormalsmode ();
        mark_modified ();
      }
  }

  void set_linestyle (const octave_value& val)
  {
    if (m_linestyle.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_linewidth (const octave_value& val)
  {
    if (m_linewidth.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_marker (const octave_value& val)
  {
    if (m_marker.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_markeredgecolor (const octave_value& val)
  {
    if (m_markeredgecolor.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_markerfacecolor (const octave_value& val)
  {
    if (m_markerfacecolor.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_markersize (const octave_value& val)
  {
    if (m_markersize.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_meshstyle (const octave_value& val)
  {
    if (m_meshstyle.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_specularcolorreflectance (const octave_value& val)
  {
    if (m_specularcolorreflectance.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_specularexponent (const octave_value& val)
  {
    if (m_specularexponent.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_specularstrength (const octave_value& val)
  {
    if (m_specularstrength.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_vertexnormals (const octave_value& val)
  {
    if (m_vertexnormals.set (val, false))
      {
        set_vertexnormalsmode ("manual");
        m_vertexnormals.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
    else
      set_vertexnormalsmode ("manual");
  }

  void set_vertexnormalsmode (const octave_value& val)
  {
    if (m_vertexnormalsmode.set (val, true))
      {
        update_vertexnormalsmode ();
        mark_modified ();
      }
  }

  void set_xdata (const octave_value& val)
  {
    if (m_xdata.set (val, true))
      {
        update_xdata ();
        mark_modified ();
      }
  }

  void set_xdatasource (const octave_value& val)
  {
    if (m_xdatasource.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_ydata (const octave_value& val)
  {
    if (m_ydata.set (val, true))
      {
        update_ydata ();
        mark_modified ();
      }
  }

  void set_ydatasource (const octave_value& val)
  {
    if (m_ydatasource.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_zdata (const octave_value& val)
  {
    if (m_zdata.set (val, true))
      {
        update_zdata ();
        mark_modified ();
      }
  }

  void set_zdatasource (const octave_value& val)
  {
    if (m_zdatasource.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_alim (const octave_value& val)
  {
    if (m_alim.set (val, false))
      {
        update_axis_limits ("alim");
        m_alim.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
  }

  void set_clim (const octave_value& val)
  {
    if (m_clim.set (val, false))
      {
        update_axis_limits ("clim");
        m_clim.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
  }

  void set_xlim (const octave_value& val)
  {
    if (m_xlim.set (val, false))
      {
        update_axis_limits ("xlim");
        m_xlim.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
  }

  void set_ylim (const octave_value& val)
  {
    if (m_ylim.set (val, false))
      {
        update_axis_limits ("ylim");
        m_ylim.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
  }

  void set_zlim (const octave_value& val)
  {
    if (m_zlim.set (val, false))
      {
        update_axis_limits ("zlim");
        m_zlim.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
  }

  void set_aliminclude (const octave_value& val)
  {
    if (m_aliminclude.set (val, false))
      {
        update_axis_limits ("aliminclude");
        m_aliminclude.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
  }

  void set_climinclude (const octave_value& val)
  {
    if (m_climinclude.set (val, false))
      {
        update_axis_limits ("climinclude");
        m_climinclude.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
  }

  void set_xliminclude (const octave_value& val)
  {
    if (m_xliminclude.set (val, false))
      {
        update_axis_limits ("xliminclude");
        m_xliminclude.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
  }

  void set_yliminclude (const octave_value& val)
  {
    if (m_yliminclude.set (val, false))
      {
        update_axis_limits ("yliminclude");
        m_yliminclude.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
  }

  void set_zliminclude (const octave_value& val)
  {
    if (m_zliminclude.set (val, false))
      {
        update_axis_limits ("zliminclude");
        m_zliminclude.run_listeners (GCB_POSTSET);
        mark_modified ();
      }
  }


  protected:
    void init (void)
    {
      m_xdata.add_constraint (dim_vector (-1, -1));
      m_ydata.add_constraint (dim_vector (-1, -1));
      m_zdata.add_constraint (dim_vector (-1, -1));
      m_cdata.add_constraint ("double");
      m_cdata.add_constraint ("single");
      m_cdata.add_constraint ("logical");
      m_cdata.add_constraint ("int8");
      m_cdata.add_constraint ("int16");
      m_cdata.add_constraint ("int32");
      m_cdata.add_constraint ("int64");
      m_cdata.add_constraint ("uint8");
      m_cdata.add_constraint ("uint16");
      m_cdata.add_constraint ("uint32");
      m_cdata.add_constraint ("uint64");
      m_cdata.add_constraint ("real");
      m_cdata.add_constraint (dim_vector (-1, -1));
      m_cdata.add_constraint (dim_vector (-1, -1, 3));
      m_alphadata.add_constraint ("double");
      m_alphadata.add_constraint ("uint8");
      m_alphadata.add_constraint (dim_vector (-1, -1));
      m_facenormals.add_constraint (dim_vector (-1, -1, 3));
      m_facenormals.add_constraint (dim_vector (0, 0));
      m_vertexnormals.add_constraint (dim_vector (-1, -1, 3));
      m_vertexnormals.add_constraint (dim_vector (0, 0));

      m_ambientstrength.add_constraint ("min", 0.0, true);
      m_ambientstrength.add_constraint ("max", 1.0, true);
      m_diffusestrength.add_constraint ("min", 0.0, true);
      m_diffusestrength.add_constraint ("max", 1.0, true);
      m_linewidth.add_constraint ("min", 0.0, false);
      m_markersize.add_constraint ("min", 0.0, false);
      m_specularcolorreflectance.add_constraint ("min", 0.0, true);
      m_specularcolorreflectance.add_constraint ("max", 1.0, true);
      m_specularexponent.add_constraint ("min", 0.0, false);
      m_specularstrength.add_constraint ("min", 0.0, true);
      m_specularstrength.add_constraint ("max", 1.0, true);
    }

  public:
    void update_normals (bool reset, bool force = false)
    {
      update_face_normals (reset, force);
      update_vertex_normals (reset, force);
    }


  private:
    void update_alphadata (void)
    {
      if (alphadatamapping_is ("scaled"))
        set_alim (m_alphadata.get_limits ());
      else
        m_alim = m_alphadata.get_limits ();
    }

    void update_cdata (void)
    {
      if (cdatamapping_is ("scaled"))
        set_clim (m_cdata.get_limits ());
      else
        m_clim = m_cdata.get_limits ();
    }

    void update_xdata (void)
    {
      update_normals (true);
      set_xlim (m_xdata.get_limits ());
    }

    void update_ydata (void)
    {
      update_normals (true);
      set_ylim (m_ydata.get_limits ());
    }

    void update_zdata (void)
    {
      update_normals (true);
      set_zlim (m_zdata.get_limits ());
    }

    OCTINTERP_API void update_face_normals (bool reset, bool force = false);
    OCTINTERP_API void update_vertex_normals (bool reset, bool force = false);

    void update_facenormalsmode (void)
    { update_face_normals (false); }

    void update_vertexnormalsmode (void)
    { update_vertex_normals (false); }

    void update_edgelighting (void)
    { update_normals (false); }

    void update_facelighting (void)
    { update_normals (false); }

    void update_visible (void)
    {
      if (is_visible ())
        update_normals (false);
    }

  };

private:
  properties m_properties;

public:
  surface (const graphics_handle& mh, const graphics_handle& p)
    : base_graphics_object (), m_properties (mh, p)
  { }

  ~surface (void) = default;

  base_properties& get_properties (void) { return m_properties; }

  const base_properties& get_properties (void) const { return m_properties; }

  bool valid_object (void) const { return true; }

  bool has_readonly_property (const caseless_str& pname) const
  {
    bool retval = m_properties.has_readonly_property (pname);
    if (! retval)
      retval = base_properties::has_readonly_property (pname);
    return retval;
  }
};

// ---------------------------------------------------------------------

class OCTINTERP_API hggroup : public base_graphics_object
{
public:

  class OCTINTERP_API properties : public base_properties
  {
  public:

    OCTINTERP_API void
    remove_child (const graphics_handle& h, bool from_root = false);

    OCTINTERP_API void adopt (const graphics_handle& h);

    // See the genprops.awk script for an explanation of the
    // properties declarations.
    // Programming note: Keep property list sorted if new ones are added.

public:
  properties (const graphics_handle& mh, const graphics_handle& p);

  ~properties (void) { }

  void set (const caseless_str& pname, const octave_value& val);

  octave_value get (bool all = false) const;

  octave_value get (const caseless_str& pname) const;

  octave_value get (const std::string& pname) const
  {
    return get (caseless_str (pname));
  }

  octave_value get (const char *pname) const
  {
    return get (caseless_str (pname));
  }

  property get_property (const caseless_str& pname);

  std::string graphics_object_name (void) const { return s_go_name; }

  static property_list::pval_map_type factory_defaults (void);

private:
  static std::string s_go_name;

public:


  static std::set<std::string> core_property_names (void);

  static std::set<std::string> readonly_property_names (void);

  static bool has_core_property (const caseless_str& pname);

  static bool has_readonly_property (const caseless_str& pname);

  std::set<std::string> all_property_names (void) const;

  bool has_property (const caseless_str& pname) const;

private:

  string_property m_displayname;
  row_vector_property m_alim;
  row_vector_property m_clim;
  row_vector_property m_xlim;
  row_vector_property m_ylim;
  row_vector_property m_zlim;
  bool_property m_aliminclude;
  bool_property m_climinclude;
  bool_property m_xliminclude;
  bool_property m_yliminclude;
  bool_property m_zliminclude;

public:

  enum
  {
    ID_DISPLAYNAME = 11000,
    ID_ALIM = 11001,
    ID_CLIM = 11002,
    ID_XLIM = 11003,
    ID_YLIM = 11004,
    ID_ZLIM = 11005,
    ID_ALIMINCLUDE = 11006,
    ID_CLIMINCLUDE = 11007,
    ID_XLIMINCLUDE = 11008,
    ID_YLIMINCLUDE = 11009,
    ID_ZLIMINCLUDE = 11010
  };

  std::string get_displayname (void) const { return m_displayname.string_value (); }

  octave_value get_alim (void) const { return m_alim.get (); }

  octave_value get_clim (void) const { return m_clim.get (); }

  octave_value get_xlim (void) const { return m_xlim.get (); }

  octave_value get_ylim (void) const { return m_ylim.get (); }

  octave_value get_zlim (void) const { return m_zlim.get (); }

  bool is_aliminclude (void) const { return m_aliminclude.is_on (); }
  std::string get_aliminclude (void) const { return m_aliminclude.current_value (); }

  bool is_climinclude (void) const { return m_climinclude.is_on (); }
  std::string get_climinclude (void) const { return m_climinclude.current_value (); }

  bool is_xliminclude (void) const { return m_xliminclude.is_on (); }
  std::string get_xliminclude (void) const { return m_xliminclude.current_value (); }

  bool is_yliminclude (void) const { return m_yliminclude.is_on (); }
  std::string get_yliminclude (void) const { return m_yliminclude.current_value (); }

  bool is_zliminclude (void) const { return m_zliminclude.is_on (); }
  std::string get_zliminclude (void) const { return m_zliminclude.current_value (); }


  void set_displayname (const octave_value& val)
  {
    if (m_displayname.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_alim (const octave_value& val)
  {
    if (m_alim.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_clim (const octave_value& val)
  {
    if (m_clim.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_xlim (const octave_value& val)
  {
    if (m_xlim.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_ylim (const octave_value& val)
  {
    if (m_ylim.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_zlim (const octave_value& val)
  {
    if (m_zlim.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_aliminclude (const octave_value& val)
  {
    if (m_aliminclude.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_climinclude (const octave_value& val)
  {
    if (m_climinclude.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_xliminclude (const octave_value& val)
  {
    if (m_xliminclude.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_yliminclude (const octave_value& val)
  {
    if (m_yliminclude.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_zliminclude (const octave_value& val)
  {
    if (m_zliminclude.set (val, true))
      {
        mark_modified ();
      }
  }


  private:
    OCTINTERP_API void update_limits (void) const;

    OCTINTERP_API void update_limits (const graphics_handle& h) const;

  protected:
    void init (void)
    { }

  };

private:
  properties m_properties;

public:
  hggroup (const graphics_handle& mh, const graphics_handle& p)
    : base_graphics_object (), m_properties (mh, p)
  { }

  ~hggroup (void) = default;

  base_properties& get_properties (void) { return m_properties; }

  const base_properties& get_properties (void) const { return m_properties; }

  bool valid_object (void) const { return true; }

  OCTINTERP_API void update_axis_limits (const std::string& axis_type);

  OCTINTERP_API void update_axis_limits (const std::string& axis_type,
                                         const graphics_handle& h);

  bool has_readonly_property (const caseless_str& pname) const
  {
    bool retval = m_properties.has_readonly_property (pname);
    if (! retval)
      retval = base_properties::has_readonly_property (pname);
    return retval;
  }

};

// ---------------------------------------------------------------------

class OCTINTERP_API uimenu : public base_graphics_object
{
public:

  class OCTINTERP_API properties : public base_properties
  {
  public:

    void remove_child (const graphics_handle& h, bool from_root = false)
    {
      base_properties::remove_child (h, from_root);
    }

    void adopt (const graphics_handle& h)
    {
      base_properties::adopt (h);
    }

    // See the genprops.awk script for an explanation of the
    // properties declarations.
    // Programming note: Keep property list sorted if new ones are added.

public:
  properties (const graphics_handle& mh, const graphics_handle& p);

  ~properties (void) { }

  void set (const caseless_str& pname, const octave_value& val);

  octave_value get (bool all = false) const;

  octave_value get (const caseless_str& pname) const;

  octave_value get (const std::string& pname) const
  {
    return get (caseless_str (pname));
  }

  octave_value get (const char *pname) const
  {
    return get (caseless_str (pname));
  }

  property get_property (const caseless_str& pname);

  std::string graphics_object_name (void) const { return s_go_name; }

  static property_list::pval_map_type factory_defaults (void);

private:
  static std::string s_go_name;

public:


  static std::set<std::string> core_property_names (void);

  static std::set<std::string> readonly_property_names (void);

  static bool has_core_property (const caseless_str& pname);

  static bool has_readonly_property (const caseless_str& pname);

  std::set<std::string> all_property_names (void) const;

  bool has_property (const caseless_str& pname) const;

private:

  string_property m_accelerator;
  callback_property m_callback;
  bool_property m_checked;
  bool_property m_enable;
  color_property m_foregroundcolor;
  string_property m_label;
  double_property m_position;
  bool_property m_separator;
  string_property m_text;
  string_property m___fltk_label__;
  any_property m___object__;

public:

  enum
  {
    ID_ACCELERATOR = 12000,
    ID_CALLBACK = 12001,
    ID_CHECKED = 12002,
    ID_ENABLE = 12003,
    ID_FOREGROUNDCOLOR = 12004,
    ID_LABEL = 12005,
    ID_POSITION = 12006,
    ID_SEPARATOR = 12007,
    ID_TEXT = 12008,
    ID___FLTK_LABEL__ = 12009,
    ID___OBJECT__ = 12010
  };

  std::string get_accelerator (void) const { return m_accelerator.string_value (); }

  void execute_callback (const octave_value& new_data = octave_value ()) const { m_callback.execute (new_data); }
  octave_value get_callback (void) const { return m_callback.get (); }

  bool is_checked (void) const { return m_checked.is_on (); }
  std::string get_checked (void) const { return m_checked.current_value (); }

  bool is_enable (void) const { return m_enable.is_on (); }
  std::string get_enable (void) const { return m_enable.current_value (); }

  bool foregroundcolor_is_rgb (void) const { return m_foregroundcolor.is_rgb (); }
  bool foregroundcolor_is (const std::string& v) const { return m_foregroundcolor.is (v); }
  Matrix get_foregroundcolor_rgb (void) const { return (m_foregroundcolor.is_rgb () ? m_foregroundcolor.rgb () : Matrix ()); }
  octave_value get_foregroundcolor (void) const { return m_foregroundcolor.get (); }

  double get_position (void) const { return m_position.double_value (); }

  bool is_separator (void) const { return m_separator.is_on (); }
  std::string get_separator (void) const { return m_separator.current_value (); }

  std::string get_text (void) const { return m_text.string_value (); }

  std::string get___fltk_label__ (void) const { return m___fltk_label__.string_value (); }

  octave_value get___object__ (void) const { return m___object__.get (); }


  void set_accelerator (const octave_value& val)
  {
    if (m_accelerator.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_callback (const octave_value& val)
  {
    if (m_callback.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_checked (const octave_value& val)
  {
    if (m_checked.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_enable (const octave_value& val)
  {
    if (m_enable.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_foregroundcolor (const octave_value& val)
  {
    if (m_foregroundcolor.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_position (const octave_value& val)
  {
    if (m_position.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_separator (const octave_value& val)
  {
    if (m_separator.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_text (const octave_value& val)
  {
    if (m_text.set (val, true))
      {
        mark_modified ();
      }
  }

  void set___fltk_label__ (const octave_value& val)
  {
    if (m___fltk_label__.set (val, true))
      {
        mark_modified ();
      }
  }

  void set___object__ (const octave_value& val)
  {
    if (m___object__.set (val, true))
      {
        mark_modified ();
      }
  }


    // Redirect calls from "Label" to "Text".
    std::string get_label (void) const
    {
      return get_text ();
    }

    void set_label (const octave_value& val)
    {
      set_text (val);
    }

  protected:
    void init (void)
    {
      m_position.add_constraint ("min", 0, true);
    }
  };

private:
  properties m_properties;

public:
  uimenu (const graphics_handle& mh, const graphics_handle& p)
    : base_graphics_object (), m_properties (mh, p)
  { }

  ~uimenu (void) = default;

  base_properties& get_properties (void) { return m_properties; }

  const base_properties& get_properties (void) const { return m_properties; }

  bool valid_object (void) const { return true; }

  bool has_readonly_property (const caseless_str& pname) const
  {
    bool retval = m_properties.has_readonly_property (pname);
    if (! retval)
      retval = base_properties::has_readonly_property (pname);
    return retval;
  }

};

// ---------------------------------------------------------------------

// FIXME: This class has been renamed to "contextmenu" in Matlab R2020a.
class OCTINTERP_API uicontextmenu : public base_graphics_object
{
public:

  class OCTINTERP_API properties : public base_properties
  {
  public:

    void add_dependent_obj (graphics_handle gh)
    { m_dependent_obj_list.push_back (gh); }

    // FIXME: the list may contain duplicates.
    //        Should we return only unique elements?
    const std::list<graphics_handle> get_dependent_obj_list (void)
    { return m_dependent_obj_list; }

    // See the genprops.awk script for an explanation of the
    // properties declarations.
    // Programming note: Keep property list sorted if new ones are added.

public:
  properties (const graphics_handle& mh, const graphics_handle& p);

  ~properties (void) { }

  void set (const caseless_str& pname, const octave_value& val);

  octave_value get (bool all = false) const;

  octave_value get (const caseless_str& pname) const;

  octave_value get (const std::string& pname) const
  {
    return get (caseless_str (pname));
  }

  octave_value get (const char *pname) const
  {
    return get (caseless_str (pname));
  }

  property get_property (const caseless_str& pname);

  std::string graphics_object_name (void) const { return s_go_name; }

  static property_list::pval_map_type factory_defaults (void);

private:
  static std::string s_go_name;

public:


  static std::set<std::string> core_property_names (void);

  static std::set<std::string> readonly_property_names (void);

  static bool has_core_property (const caseless_str& pname);

  static bool has_readonly_property (const caseless_str& pname);

  std::set<std::string> all_property_names (void) const;

  bool has_property (const caseless_str& pname) const;

private:

  callback_property m_callback;
  array_property m_position;
  any_property m___object__;

public:

  enum
  {
    ID_CALLBACK = 13000,
    ID_POSITION = 13001,
    ID___OBJECT__ = 13002
  };

  void execute_callback (const octave_value& new_data = octave_value ()) const { m_callback.execute (new_data); }
  octave_value get_callback (void) const { return m_callback.get (); }

  octave_value get_position (void) const { return m_position.get (); }

  octave_value get___object__ (void) const { return m___object__.get (); }


  void set_callback (const octave_value& val)
  {
    if (m_callback.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_position (const octave_value& val)
  {
    if (m_position.set (val, true))
      {
        mark_modified ();
      }
  }

  void set___object__ (const octave_value& val)
  {
    if (m___object__.set (val, true))
      {
        mark_modified ();
      }
  }


  protected:
    void init (void)
    {
      m_position.add_constraint (dim_vector (1, 2));
      m_position.add_constraint (dim_vector (2, 1));
      m_visible.set (octave_value (false));
    }

  private:
    // List of objects that might depend on this uicontextmenu object
    std::list<graphics_handle> m_dependent_obj_list;

    OCTINTERP_API void update_beingdeleted (void);

  };

private:
  properties m_properties;

public:
  uicontextmenu (const graphics_handle& mh, const graphics_handle& p)
    : base_graphics_object (), m_properties (mh, p)
  { }

  ~uicontextmenu (void) = default;

  base_properties& get_properties (void) { return m_properties; }

  const base_properties& get_properties (void) const { return m_properties; }

  bool valid_object (void) const { return true; }

  bool has_readonly_property (const caseless_str& pname) const
  {
    bool retval = m_properties.has_readonly_property (pname);
    if (! retval)
      retval = base_properties::has_readonly_property (pname);
    return retval;
  }

};

// ---------------------------------------------------------------------

class OCTINTERP_API uicontrol : public base_graphics_object
{
public:

  class OCTINTERP_API properties : public base_properties
  {
  public:

    OCTINTERP_API Matrix
    get_boundingbox (bool internal = false,
                     const Matrix& parent_pix_size = Matrix ()) const;

    OCTINTERP_API double
    get___fontsize_points__ (double box_pix_height = 0) const;

    // See the genprops.awk script for an explanation of the
    // properties declarations.
    // Programming note: Keep property list sorted if new ones are added.

public:
  properties (const graphics_handle& mh, const graphics_handle& p);

  ~properties (void) { }

  void set (const caseless_str& pname, const octave_value& val);

  octave_value get (bool all = false) const;

  octave_value get (const caseless_str& pname) const;

  octave_value get (const std::string& pname) const
  {
    return get (caseless_str (pname));
  }

  octave_value get (const char *pname) const
  {
    return get (caseless_str (pname));
  }

  property get_property (const caseless_str& pname);

  std::string graphics_object_name (void) const { return s_go_name; }

  static property_list::pval_map_type factory_defaults (void);

private:
  static std::string s_go_name;

public:


  static std::set<std::string> core_property_names (void);

  static std::set<std::string> readonly_property_names (void);

  static bool has_core_property (const caseless_str& pname);

  static bool has_readonly_property (const caseless_str& pname);

  std::set<std::string> all_property_names (void) const;

  bool has_property (const caseless_str& pname) const;

private:

  color_property m_backgroundcolor;
  callback_property m_callback;
  array_property m_cdata;
  bool_property m_clipping;
  radio_property m_enable;
  array_property m_extent;
  radio_property m_fontangle;
  string_property m_fontname;
  double_property m_fontsize;
  radio_property m_fontunits;
  radio_property m_fontweight;
  color_property m_foregroundcolor;
  radio_property m_horizontalalignment;
  callback_property m_keypressfcn;
  double_property m_listboxtop;
  double_property m_max;
  double_property m_min;
  array_property m_position;
  array_property m_sliderstep;
  string_array_property m_string;
  radio_property m_style;
  string_property m_tooltipstring;
  radio_property m_units;
  row_vector_property m_value;
  radio_property m_verticalalignment;
  bool_property m___focus__;
  any_property m___object__;

public:

  enum
  {
    ID_BACKGROUNDCOLOR = 14000,
    ID_CALLBACK = 14001,
    ID_CDATA = 14002,
    ID_CLIPPING = 14003,
    ID_ENABLE = 14004,
    ID_EXTENT = 14005,
    ID_FONTANGLE = 14006,
    ID_FONTNAME = 14007,
    ID_FONTSIZE = 14008,
    ID_FONTUNITS = 14009,
    ID_FONTWEIGHT = 14010,
    ID_FOREGROUNDCOLOR = 14011,
    ID_HORIZONTALALIGNMENT = 14012,
    ID_KEYPRESSFCN = 14013,
    ID_LISTBOXTOP = 14014,
    ID_MAX = 14015,
    ID_MIN = 14016,
    ID_POSITION = 14017,
    ID_SLIDERSTEP = 14018,
    ID_STRING = 14019,
    ID_STYLE = 14020,
    ID_TOOLTIPSTRING = 14021,
    ID_UNITS = 14022,
    ID_VALUE = 14023,
    ID_VERTICALALIGNMENT = 14024,
    ID___FOCUS__ = 14025,
    ID___OBJECT__ = 14026
  };

  bool backgroundcolor_is_rgb (void) const { return m_backgroundcolor.is_rgb (); }
  bool backgroundcolor_is (const std::string& v) const { return m_backgroundcolor.is (v); }
  Matrix get_backgroundcolor_rgb (void) const { return (m_backgroundcolor.is_rgb () ? m_backgroundcolor.rgb () : Matrix ()); }
  octave_value get_backgroundcolor (void) const { return m_backgroundcolor.get (); }

  void execute_callback (const octave_value& new_data = octave_value ()) const { m_callback.execute (new_data); }
  octave_value get_callback (void) const { return m_callback.get (); }

  octave_value get_cdata (void) const { return m_cdata.get (); }

  bool is_clipping (void) const { return m_clipping.is_on (); }
  std::string get_clipping (void) const { return m_clipping.current_value (); }

  bool enable_is (const std::string& v) const { return m_enable.is (v); }
  std::string get_enable (void) const { return m_enable.current_value (); }

  octave_value get_extent (void) const;

  bool fontangle_is (const std::string& v) const { return m_fontangle.is (v); }
  std::string get_fontangle (void) const { return m_fontangle.current_value (); }

  std::string get_fontname (void) const { return m_fontname.string_value (); }

  double get_fontsize (void) const { return m_fontsize.double_value (); }

  bool fontunits_is (const std::string& v) const { return m_fontunits.is (v); }
  std::string get_fontunits (void) const { return m_fontunits.current_value (); }

  bool fontweight_is (const std::string& v) const { return m_fontweight.is (v); }
  std::string get_fontweight (void) const { return m_fontweight.current_value (); }

  bool foregroundcolor_is_rgb (void) const { return m_foregroundcolor.is_rgb (); }
  bool foregroundcolor_is (const std::string& v) const { return m_foregroundcolor.is (v); }
  Matrix get_foregroundcolor_rgb (void) const { return (m_foregroundcolor.is_rgb () ? m_foregroundcolor.rgb () : Matrix ()); }
  octave_value get_foregroundcolor (void) const { return m_foregroundcolor.get (); }

  bool horizontalalignment_is (const std::string& v) const { return m_horizontalalignment.is (v); }
  std::string get_horizontalalignment (void) const { return m_horizontalalignment.current_value (); }

  void execute_keypressfcn (const octave_value& new_data = octave_value ()) const { m_keypressfcn.execute (new_data); }
  octave_value get_keypressfcn (void) const { return m_keypressfcn.get (); }

  double get_listboxtop (void) const { return m_listboxtop.double_value (); }

  double get_max (void) const { return m_max.double_value (); }

  double get_min (void) const { return m_min.double_value (); }

  octave_value get_position (void) const { return m_position.get (); }

  octave_value get_sliderstep (void) const { return m_sliderstep.get (); }

  std::string get_string_string (void) const { return m_string.string_value (); }
  string_vector get_string_vector (void) const { return m_string.string_vector_value (); }
  octave_value get_string (void) const { return m_string.get (); }

  bool style_is (const std::string& v) const { return m_style.is (v); }
  std::string get_style (void) const { return m_style.current_value (); }

  std::string get_tooltipstring (void) const { return m_tooltipstring.string_value (); }

  bool units_is (const std::string& v) const { return m_units.is (v); }
  std::string get_units (void) const { return m_units.current_value (); }

  octave_value get_value (void) const { return m_value.get (); }

  bool verticalalignment_is (const std::string& v) const { return m_verticalalignment.is (v); }
  std::string get_verticalalignment (void) const { return m_verticalalignment.current_value (); }

  bool is___focus__ (void) const { return m___focus__.is_on (); }
  std::string get___focus__ (void) const { return m___focus__.current_value (); }

  octave_value get___object__ (void) const { return m___object__.get (); }


  void set_backgroundcolor (const octave_value& val)
  {
    if (m_backgroundcolor.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_callback (const octave_value& val)
  {
    if (m_callback.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_cdata (const octave_value& val)
  {
    if (m_cdata.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_clipping (const octave_value& val)
  {
    if (m_clipping.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_enable (const octave_value& val)
  {
    if (m_enable.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_extent (const octave_value& val)
  {
    if (m_extent.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_fontangle (const octave_value& val)
  {
    if (m_fontangle.set (val, true))
      {
        update_fontangle ();
        mark_modified ();
      }
  }

  void set_fontname (const octave_value& val)
  {
    if (m_fontname.set (val, true))
      {
        update_fontname ();
        mark_modified ();
      }
  }

  void set_fontsize (const octave_value& val)
  {
    if (m_fontsize.set (val, true))
      {
        update_fontsize ();
        mark_modified ();
      }
  }

  void set_fontunits (const octave_value& val);

  void set_fontweight (const octave_value& val)
  {
    if (m_fontweight.set (val, true))
      {
        update_fontweight ();
        mark_modified ();
      }
  }

  void set_foregroundcolor (const octave_value& val)
  {
    if (m_foregroundcolor.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_horizontalalignment (const octave_value& val)
  {
    if (m_horizontalalignment.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_keypressfcn (const octave_value& val)
  {
    if (m_keypressfcn.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_listboxtop (const octave_value& val)
  {
    if (m_listboxtop.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_max (const octave_value& val)
  {
    if (m_max.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_min (const octave_value& val)
  {
    if (m_min.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_position (const octave_value& val)
  {
    if (m_position.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_sliderstep (const octave_value& val)
  {
    if (m_sliderstep.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_string (const octave_value& val)
  {
    if (m_string.set (val, true))
      {
        update_string ();
        mark_modified ();
      }
  }

  void set_style (const octave_value& val);

  void set_tooltipstring (const octave_value& val)
  {
    if (m_tooltipstring.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_units (const octave_value& val)
  {
    if (m_units.set (val, true))
      {
        update_units ();
        mark_modified ();
      }
  }

  void set_value (const octave_value& val)
  {
    if (m_value.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_verticalalignment (const octave_value& val)
  {
    if (m_verticalalignment.set (val, true))
      {
        mark_modified ();
      }
  }

  void set___focus__ (const octave_value& val)
  {
    if (m___focus__.set (val, true))
      {
        mark_modified ();
      }
  }

  void set___object__ (const octave_value& val)
  {
    if (m___object__.set (val, true))
      {
        mark_modified ();
      }
  }


  private:
    std::string m_cached_units;

  protected:
    void init (void)
    {
      m_cdata.add_constraint ("double");
      m_cdata.add_constraint ("single");
      m_cdata.add_constraint ("uint8");
      m_cdata.add_constraint (dim_vector (-1, -1, 3));
      m_cdata.add_constraint (dim_vector (0, 0));
      m_position.add_constraint (dim_vector (1, 4));
      m_sliderstep.add_constraint (dim_vector (1, 2));
      m_fontsize.add_constraint ("min", 0.0, false);
      m_cached_units = get_units ();
    }

    OCTINTERP_API void update_text_extent (void);

    void update_string (void) { update_text_extent (); }
    void update_fontname (void) { update_text_extent (); }
    void update_fontsize (void) { update_text_extent (); }
    void update_fontangle (void)
    {
      update_text_extent ();
    }
    void update_fontweight (void) { update_text_extent (); }

    OCTINTERP_API void update_fontunits (const caseless_str& old_units);

    OCTINTERP_API void update_units (void);

  };

private:
  properties m_properties;

public:
  uicontrol (const graphics_handle& mh, const graphics_handle& p)
    : base_graphics_object (), m_properties (mh, p)
  { }

  ~uicontrol (void) = default;

  base_properties& get_properties (void) { return m_properties; }

  const base_properties& get_properties (void) const { return m_properties; }

  bool valid_object (void) const { return true; }

  bool has_readonly_property (const caseless_str& pname) const
  {
    bool retval = m_properties.has_readonly_property (pname);
    if (! retval)
      retval = base_properties::has_readonly_property (pname);
    return retval;
  }
};

// ---------------------------------------------------------------------

class OCTINTERP_API uibuttongroup : public base_graphics_object
{
public:

  class OCTINTERP_API properties : public base_properties
  {
  public:

    OCTINTERP_API void
    remove_child (const graphics_handle& h, bool from_root = false);

    OCTINTERP_API void adopt (const graphics_handle& h);

    OCTINTERP_API Matrix
    get_boundingbox (bool internal = false,
                     const Matrix& parent_pix_size = Matrix ()) const;

    OCTINTERP_API double
    get___fontsize_points__ (double box_pix_height = 0) const;

    // See the genprops.awk script for an explanation of the
    // properties declarations.
    // Programming note: Keep property list sorted if new ones are added.

public:
  properties (const graphics_handle& mh, const graphics_handle& p);

  ~properties (void) { }

  void set (const caseless_str& pname, const octave_value& val);

  octave_value get (bool all = false) const;

  octave_value get (const caseless_str& pname) const;

  octave_value get (const std::string& pname) const
  {
    return get (caseless_str (pname));
  }

  octave_value get (const char *pname) const
  {
    return get (caseless_str (pname));
  }

  property get_property (const caseless_str& pname);

  std::string graphics_object_name (void) const { return s_go_name; }

  static property_list::pval_map_type factory_defaults (void);

private:
  static std::string s_go_name;

public:


  static std::set<std::string> core_property_names (void);

  static std::set<std::string> readonly_property_names (void);

  static bool has_core_property (const caseless_str& pname);

  static bool has_readonly_property (const caseless_str& pname);

  std::set<std::string> all_property_names (void) const;

  bool has_property (const caseless_str& pname) const;

private:

  color_property m_backgroundcolor;
  radio_property m_bordertype;
  double_property m_borderwidth;
  bool_property m_clipping;
  radio_property m_fontangle;
  string_property m_fontname;
  double_property m_fontsize;
  radio_property m_fontunits;
  radio_property m_fontweight;
  color_property m_foregroundcolor;
  color_property m_highlightcolor;
  array_property m_position;
  callback_property m_resizefcn;
  handle_property m_selectedobject;
  callback_property m_selectionchangedfcn;
  color_property m_shadowcolor;
  callback_property m_sizechangedfcn;
  radio_property m_units;
  string_property m_title;
  radio_property m_titleposition;
  any_property m___object__;

public:

  enum
  {
    ID_BACKGROUNDCOLOR = 15000,
    ID_BORDERTYPE = 15001,
    ID_BORDERWIDTH = 15002,
    ID_CLIPPING = 15003,
    ID_FONTANGLE = 15004,
    ID_FONTNAME = 15005,
    ID_FONTSIZE = 15006,
    ID_FONTUNITS = 15007,
    ID_FONTWEIGHT = 15008,
    ID_FOREGROUNDCOLOR = 15009,
    ID_HIGHLIGHTCOLOR = 15010,
    ID_POSITION = 15011,
    ID_RESIZEFCN = 15012,
    ID_SELECTEDOBJECT = 15013,
    ID_SELECTIONCHANGEDFCN = 15014,
    ID_SHADOWCOLOR = 15015,
    ID_SIZECHANGEDFCN = 15016,
    ID_UNITS = 15017,
    ID_TITLE = 15018,
    ID_TITLEPOSITION = 15019,
    ID___OBJECT__ = 15020
  };

  bool backgroundcolor_is_rgb (void) const { return m_backgroundcolor.is_rgb (); }
  bool backgroundcolor_is (const std::string& v) const { return m_backgroundcolor.is (v); }
  Matrix get_backgroundcolor_rgb (void) const { return (m_backgroundcolor.is_rgb () ? m_backgroundcolor.rgb () : Matrix ()); }
  octave_value get_backgroundcolor (void) const { return m_backgroundcolor.get (); }

  bool bordertype_is (const std::string& v) const { return m_bordertype.is (v); }
  std::string get_bordertype (void) const { return m_bordertype.current_value (); }

  double get_borderwidth (void) const { return m_borderwidth.double_value (); }

  bool is_clipping (void) const { return m_clipping.is_on (); }
  std::string get_clipping (void) const { return m_clipping.current_value (); }

  bool fontangle_is (const std::string& v) const { return m_fontangle.is (v); }
  std::string get_fontangle (void) const { return m_fontangle.current_value (); }

  std::string get_fontname (void) const { return m_fontname.string_value (); }

  double get_fontsize (void) const { return m_fontsize.double_value (); }

  bool fontunits_is (const std::string& v) const { return m_fontunits.is (v); }
  std::string get_fontunits (void) const { return m_fontunits.current_value (); }

  bool fontweight_is (const std::string& v) const { return m_fontweight.is (v); }
  std::string get_fontweight (void) const { return m_fontweight.current_value (); }

  bool foregroundcolor_is_rgb (void) const { return m_foregroundcolor.is_rgb (); }
  bool foregroundcolor_is (const std::string& v) const { return m_foregroundcolor.is (v); }
  Matrix get_foregroundcolor_rgb (void) const { return (m_foregroundcolor.is_rgb () ? m_foregroundcolor.rgb () : Matrix ()); }
  octave_value get_foregroundcolor (void) const { return m_foregroundcolor.get (); }

  bool highlightcolor_is_rgb (void) const { return m_highlightcolor.is_rgb (); }
  bool highlightcolor_is (const std::string& v) const { return m_highlightcolor.is (v); }
  Matrix get_highlightcolor_rgb (void) const { return (m_highlightcolor.is_rgb () ? m_highlightcolor.rgb () : Matrix ()); }
  octave_value get_highlightcolor (void) const { return m_highlightcolor.get (); }

  octave_value get_position (void) const { return m_position.get (); }

  void execute_resizefcn (const octave_value& new_data = octave_value ()) const { m_resizefcn.execute (new_data); }
  octave_value get_resizefcn (void) const { return m_resizefcn.get (); }

  graphics_handle get_selectedobject (void) const { return m_selectedobject.handle_value (); }

  void execute_selectionchangedfcn (const octave_value& new_data = octave_value ()) const { m_selectionchangedfcn.execute (new_data); }
  octave_value get_selectionchangedfcn (void) const { return m_selectionchangedfcn.get (); }

  bool shadowcolor_is_rgb (void) const { return m_shadowcolor.is_rgb (); }
  bool shadowcolor_is (const std::string& v) const { return m_shadowcolor.is (v); }
  Matrix get_shadowcolor_rgb (void) const { return (m_shadowcolor.is_rgb () ? m_shadowcolor.rgb () : Matrix ()); }
  octave_value get_shadowcolor (void) const { return m_shadowcolor.get (); }

  void execute_sizechangedfcn (const octave_value& new_data = octave_value ()) const { m_sizechangedfcn.execute (new_data); }
  octave_value get_sizechangedfcn (void) const { return m_sizechangedfcn.get (); }

  bool units_is (const std::string& v) const { return m_units.is (v); }
  std::string get_units (void) const { return m_units.current_value (); }

  std::string get_title (void) const { return m_title.string_value (); }

  bool titleposition_is (const std::string& v) const { return m_titleposition.is (v); }
  std::string get_titleposition (void) const { return m_titleposition.current_value (); }

  octave_value get___object__ (void) const { return m___object__.get (); }


  void set_backgroundcolor (const octave_value& val)
  {
    if (m_backgroundcolor.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_bordertype (const octave_value& val)
  {
    if (m_bordertype.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_borderwidth (const octave_value& val)
  {
    if (m_borderwidth.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_clipping (const octave_value& val)
  {
    if (m_clipping.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_fontangle (const octave_value& val)
  {
    if (m_fontangle.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_fontname (const octave_value& val)
  {
    if (m_fontname.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_fontsize (const octave_value& val)
  {
    if (m_fontsize.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_fontunits (const octave_value& val);

  void set_fontweight (const octave_value& val)
  {
    if (m_fontweight.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_foregroundcolor (const octave_value& val)
  {
    if (m_foregroundcolor.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_highlightcolor (const octave_value& val)
  {
    if (m_highlightcolor.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_position (const octave_value& val);

  void set_resizefcn (const octave_value& val)
  {
    if (m_resizefcn.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_selectedobject (const octave_value& val);

  void set_selectionchangedfcn (const octave_value& val)
  {
    if (m_selectionchangedfcn.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_shadowcolor (const octave_value& val)
  {
    if (m_shadowcolor.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_sizechangedfcn (const octave_value& val)
  {
    if (m_sizechangedfcn.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_units (const octave_value& val);

  void set_title (const octave_value& val)
  {
    if (m_title.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_titleposition (const octave_value& val)
  {
    if (m_titleposition.set (val, true))
      {
        mark_modified ();
      }
  }

  void set___object__ (const octave_value& val)
  {
    if (m___object__.set (val, true))
      {
        mark_modified ();
      }
  }


  protected:
    void init (void)
    {
      m_position.add_constraint (dim_vector (1, 4));
      m_borderwidth.add_constraint ("min", 0.0, true);
      m_fontsize.add_constraint ("min", 0.0, false);
    }

    // void update_text_extent (void);
    // void update_string (void) { update_text_extent (); }
    // void update_fontname (void) { update_text_extent (); }
    // void update_fontsize (void) { update_text_extent (); }
    // void update_fontangle (void) { update_text_extent (); }
    // void update_fontweight (void) { update_fontweight (); }

    OCTINTERP_API void update_units (const caseless_str& old_units);
    OCTINTERP_API void update_fontunits (const caseless_str& old_units);

  };

private:
  properties m_properties;

public:
  uibuttongroup (const graphics_handle& mh, const graphics_handle& p)
    : base_graphics_object (), m_properties (mh, p)
  { }

  ~uibuttongroup (void) = default;

  base_properties& get_properties (void) { return m_properties; }

  const base_properties& get_properties (void) const { return m_properties; }

  bool valid_object (void) const { return true; }

  bool has_readonly_property (const caseless_str& pname) const
  {
    bool retval = m_properties.has_readonly_property (pname);
    if (! retval)
      retval = base_properties::has_readonly_property (pname);
    return retval;
  }

};

// ---------------------------------------------------------------------

class OCTINTERP_API uipanel : public base_graphics_object
{
public:

  class OCTINTERP_API properties : public base_properties
  {
  public:

    OCTINTERP_API Matrix
    get_boundingbox (bool internal = false,
                     const Matrix& parent_pix_size = Matrix ()) const;

    OCTINTERP_API double
    get___fontsize_points__ (double box_pix_height = 0) const;

    // See the genprops.awk script for an explanation of the
    // properties declarations.
    // Programming note: Keep property list sorted if new ones are added.

public:
  properties (const graphics_handle& mh, const graphics_handle& p);

  ~properties (void) { }

  void set (const caseless_str& pname, const octave_value& val);

  octave_value get (bool all = false) const;

  octave_value get (const caseless_str& pname) const;

  octave_value get (const std::string& pname) const
  {
    return get (caseless_str (pname));
  }

  octave_value get (const char *pname) const
  {
    return get (caseless_str (pname));
  }

  property get_property (const caseless_str& pname);

  std::string graphics_object_name (void) const { return s_go_name; }

  static property_list::pval_map_type factory_defaults (void);

private:
  static std::string s_go_name;

public:


  static std::set<std::string> core_property_names (void);

  static std::set<std::string> readonly_property_names (void);

  static bool has_core_property (const caseless_str& pname);

  static bool has_readonly_property (const caseless_str& pname);

  std::set<std::string> all_property_names (void) const;

  bool has_property (const caseless_str& pname) const;

private:

  color_property m_backgroundcolor;
  radio_property m_bordertype;
  double_property m_borderwidth;
  radio_property m_fontangle;
  string_property m_fontname;
  double_property m_fontsize;
  radio_property m_fontunits;
  radio_property m_fontweight;
  color_property m_foregroundcolor;
  color_property m_highlightcolor;
  array_property m_position;
  callback_property m_resizefcn;
  color_property m_shadowcolor;
  callback_property m_sizechangedfcn;
  string_property m_title;
  radio_property m_titleposition;
  radio_property m_units;
  any_property m___object__;

public:

  enum
  {
    ID_BACKGROUNDCOLOR = 16000,
    ID_BORDERTYPE = 16001,
    ID_BORDERWIDTH = 16002,
    ID_FONTANGLE = 16003,
    ID_FONTNAME = 16004,
    ID_FONTSIZE = 16005,
    ID_FONTUNITS = 16006,
    ID_FONTWEIGHT = 16007,
    ID_FOREGROUNDCOLOR = 16008,
    ID_HIGHLIGHTCOLOR = 16009,
    ID_POSITION = 16010,
    ID_RESIZEFCN = 16011,
    ID_SHADOWCOLOR = 16012,
    ID_SIZECHANGEDFCN = 16013,
    ID_TITLE = 16014,
    ID_TITLEPOSITION = 16015,
    ID_UNITS = 16016,
    ID___OBJECT__ = 16017
  };

  bool backgroundcolor_is_rgb (void) const { return m_backgroundcolor.is_rgb (); }
  bool backgroundcolor_is (const std::string& v) const { return m_backgroundcolor.is (v); }
  Matrix get_backgroundcolor_rgb (void) const { return (m_backgroundcolor.is_rgb () ? m_backgroundcolor.rgb () : Matrix ()); }
  octave_value get_backgroundcolor (void) const { return m_backgroundcolor.get (); }

  bool bordertype_is (const std::string& v) const { return m_bordertype.is (v); }
  std::string get_bordertype (void) const { return m_bordertype.current_value (); }

  double get_borderwidth (void) const { return m_borderwidth.double_value (); }

  bool fontangle_is (const std::string& v) const { return m_fontangle.is (v); }
  std::string get_fontangle (void) const { return m_fontangle.current_value (); }

  std::string get_fontname (void) const { return m_fontname.string_value (); }

  double get_fontsize (void) const { return m_fontsize.double_value (); }

  bool fontunits_is (const std::string& v) const { return m_fontunits.is (v); }
  std::string get_fontunits (void) const { return m_fontunits.current_value (); }

  bool fontweight_is (const std::string& v) const { return m_fontweight.is (v); }
  std::string get_fontweight (void) const { return m_fontweight.current_value (); }

  bool foregroundcolor_is_rgb (void) const { return m_foregroundcolor.is_rgb (); }
  bool foregroundcolor_is (const std::string& v) const { return m_foregroundcolor.is (v); }
  Matrix get_foregroundcolor_rgb (void) const { return (m_foregroundcolor.is_rgb () ? m_foregroundcolor.rgb () : Matrix ()); }
  octave_value get_foregroundcolor (void) const { return m_foregroundcolor.get (); }

  bool highlightcolor_is_rgb (void) const { return m_highlightcolor.is_rgb (); }
  bool highlightcolor_is (const std::string& v) const { return m_highlightcolor.is (v); }
  Matrix get_highlightcolor_rgb (void) const { return (m_highlightcolor.is_rgb () ? m_highlightcolor.rgb () : Matrix ()); }
  octave_value get_highlightcolor (void) const { return m_highlightcolor.get (); }

  octave_value get_position (void) const { return m_position.get (); }

  void execute_resizefcn (const octave_value& new_data = octave_value ()) const { m_resizefcn.execute (new_data); }
  octave_value get_resizefcn (void) const { return m_resizefcn.get (); }

  bool shadowcolor_is_rgb (void) const { return m_shadowcolor.is_rgb (); }
  bool shadowcolor_is (const std::string& v) const { return m_shadowcolor.is (v); }
  Matrix get_shadowcolor_rgb (void) const { return (m_shadowcolor.is_rgb () ? m_shadowcolor.rgb () : Matrix ()); }
  octave_value get_shadowcolor (void) const { return m_shadowcolor.get (); }

  void execute_sizechangedfcn (const octave_value& new_data = octave_value ()) const { m_sizechangedfcn.execute (new_data); }
  octave_value get_sizechangedfcn (void) const { return m_sizechangedfcn.get (); }

  std::string get_title (void) const { return m_title.string_value (); }

  bool titleposition_is (const std::string& v) const { return m_titleposition.is (v); }
  std::string get_titleposition (void) const { return m_titleposition.current_value (); }

  bool units_is (const std::string& v) const { return m_units.is (v); }
  std::string get_units (void) const { return m_units.current_value (); }

  octave_value get___object__ (void) const { return m___object__.get (); }


  void set_backgroundcolor (const octave_value& val)
  {
    if (m_backgroundcolor.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_bordertype (const octave_value& val)
  {
    if (m_bordertype.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_borderwidth (const octave_value& val)
  {
    if (m_borderwidth.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_fontangle (const octave_value& val)
  {
    if (m_fontangle.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_fontname (const octave_value& val)
  {
    if (m_fontname.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_fontsize (const octave_value& val)
  {
    if (m_fontsize.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_fontunits (const octave_value& val);

  void set_fontweight (const octave_value& val)
  {
    if (m_fontweight.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_foregroundcolor (const octave_value& val)
  {
    if (m_foregroundcolor.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_highlightcolor (const octave_value& val)
  {
    if (m_highlightcolor.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_position (const octave_value& val);

  void set_resizefcn (const octave_value& val)
  {
    if (m_resizefcn.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_shadowcolor (const octave_value& val)
  {
    if (m_shadowcolor.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_sizechangedfcn (const octave_value& val)
  {
    if (m_sizechangedfcn.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_title (const octave_value& val)
  {
    if (m_title.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_titleposition (const octave_value& val)
  {
    if (m_titleposition.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_units (const octave_value& val);

  void set___object__ (const octave_value& val)
  {
    if (m___object__.set (val, true))
      {
        mark_modified ();
      }
  }


  protected:
    void init (void)
    {
      m_borderwidth.add_constraint ("min", 0.0, true);
      m_fontsize.add_constraint ("min", 0.0, false);
      m_position.add_constraint (dim_vector (1, 4));
    }

    OCTINTERP_API void update_units (const caseless_str& old_units);
    OCTINTERP_API void update_fontunits (const caseless_str& old_units);

  };

private:
  properties m_properties;

public:
  uipanel (const graphics_handle& mh, const graphics_handle& p)
    : base_graphics_object (), m_properties (mh, p)
  { }

  ~uipanel (void) = default;

  base_properties& get_properties (void) { return m_properties; }

  const base_properties& get_properties (void) const { return m_properties; }

  bool valid_object (void) const { return true; }

  bool has_readonly_property (const caseless_str& pname) const
  {
    bool retval = m_properties.has_readonly_property (pname);
    if (! retval)
      retval = base_properties::has_readonly_property (pname);
    return retval;
  }
};

// ---------------------------------------------------------------------

class OCTINTERP_API uitable : public base_graphics_object
{
public:

  class OCTINTERP_API properties : public base_properties
  {
  public:

    OCTINTERP_API Matrix
    get_boundingbox (bool internal = false,
                     const Matrix& parent_pix_size = Matrix ()) const;

    OCTINTERP_API double
    get___fontsize_points__ (double box_pix_height = 0) const;

    OCTINTERP_API double
    get_fontsize_pixels (double box_pix_height = 0) const;

    // See the genprops.awk script for an explanation of the
    // properties declarations.
    // Programming note: Keep property list sorted if new ones are added.

    // FIXME: keypressfcn, keyreleasefcn, rearrangeablecolumns properties
    //        seem to have been removed from Matlab.

public:
  properties (const graphics_handle& mh, const graphics_handle& p);

  ~properties (void) { }

  void set (const caseless_str& pname, const octave_value& val);

  octave_value get (bool all = false) const;

  octave_value get (const caseless_str& pname) const;

  octave_value get (const std::string& pname) const
  {
    return get (caseless_str (pname));
  }

  octave_value get (const char *pname) const
  {
    return get (caseless_str (pname));
  }

  property get_property (const caseless_str& pname);

  std::string graphics_object_name (void) const { return s_go_name; }

  static property_list::pval_map_type factory_defaults (void);

private:
  static std::string s_go_name;

public:


  static std::set<std::string> core_property_names (void);

  static std::set<std::string> readonly_property_names (void);

  static bool has_core_property (const caseless_str& pname);

  static bool has_readonly_property (const caseless_str& pname);

  std::set<std::string> all_property_names (void) const;

  bool has_property (const caseless_str& pname) const;

private:

  any_property m___object__;
  array_property m_backgroundcolor;
  callback_property m_celleditcallback;
  callback_property m_cellselectioncallback;
  row_vector_property m_columneditable;
  any_property m_columnformat;
  any_property m_columnname;
  any_property m_columnwidth;
  any_property m_data;
  bool_property m_enable;
  array_property m_extent;
  radio_property m_fontangle;
  string_property m_fontname;
  double_property m_fontsize;
  radio_property m_fontunits;
  radio_property m_fontweight;
  color_property m_foregroundcolor;
  callback_property m_keypressfcn;
  callback_property m_keyreleasefcn;
  array_property m_position;
  bool_property m_rearrangeablecolumns;
  any_property m_rowname;
  bool_property m_rowstriping;
  string_property m_tooltipstring;
  radio_property m_units;

public:

  enum
  {
    ID___OBJECT__ = 17000,
    ID_BACKGROUNDCOLOR = 17001,
    ID_CELLEDITCALLBACK = 17002,
    ID_CELLSELECTIONCALLBACK = 17003,
    ID_COLUMNEDITABLE = 17004,
    ID_COLUMNFORMAT = 17005,
    ID_COLUMNNAME = 17006,
    ID_COLUMNWIDTH = 17007,
    ID_DATA = 17008,
    ID_ENABLE = 17009,
    ID_EXTENT = 17010,
    ID_FONTANGLE = 17011,
    ID_FONTNAME = 17012,
    ID_FONTSIZE = 17013,
    ID_FONTUNITS = 17014,
    ID_FONTWEIGHT = 17015,
    ID_FOREGROUNDCOLOR = 17016,
    ID_KEYPRESSFCN = 17017,
    ID_KEYRELEASEFCN = 17018,
    ID_POSITION = 17019,
    ID_REARRANGEABLECOLUMNS = 17020,
    ID_ROWNAME = 17021,
    ID_ROWSTRIPING = 17022,
    ID_TOOLTIPSTRING = 17023,
    ID_UNITS = 17024
  };

  octave_value get___object__ (void) const { return m___object__.get (); }

  octave_value get_backgroundcolor (void) const { return m_backgroundcolor.get (); }

  void execute_celleditcallback (const octave_value& new_data = octave_value ()) const { m_celleditcallback.execute (new_data); }
  octave_value get_celleditcallback (void) const { return m_celleditcallback.get (); }

  void execute_cellselectioncallback (const octave_value& new_data = octave_value ()) const { m_cellselectioncallback.execute (new_data); }
  octave_value get_cellselectioncallback (void) const { return m_cellselectioncallback.get (); }

  octave_value get_columneditable (void) const { return m_columneditable.get (); }

  octave_value get_columnformat (void) const { return m_columnformat.get (); }

  octave_value get_columnname (void) const { return m_columnname.get (); }

  octave_value get_columnwidth (void) const { return m_columnwidth.get (); }

  octave_value get_data (void) const { return m_data.get (); }

  bool is_enable (void) const { return m_enable.is_on (); }
  std::string get_enable (void) const { return m_enable.current_value (); }

  octave_value get_extent (void) const;

  bool fontangle_is (const std::string& v) const { return m_fontangle.is (v); }
  std::string get_fontangle (void) const { return m_fontangle.current_value (); }

  std::string get_fontname (void) const { return m_fontname.string_value (); }

  double get_fontsize (void) const { return m_fontsize.double_value (); }

  bool fontunits_is (const std::string& v) const { return m_fontunits.is (v); }
  std::string get_fontunits (void) const { return m_fontunits.current_value (); }

  bool fontweight_is (const std::string& v) const { return m_fontweight.is (v); }
  std::string get_fontweight (void) const { return m_fontweight.current_value (); }

  bool foregroundcolor_is_rgb (void) const { return m_foregroundcolor.is_rgb (); }
  bool foregroundcolor_is (const std::string& v) const { return m_foregroundcolor.is (v); }
  Matrix get_foregroundcolor_rgb (void) const { return (m_foregroundcolor.is_rgb () ? m_foregroundcolor.rgb () : Matrix ()); }
  octave_value get_foregroundcolor (void) const { return m_foregroundcolor.get (); }

  void execute_keypressfcn (const octave_value& new_data = octave_value ()) const { m_keypressfcn.execute (new_data); }
  octave_value get_keypressfcn (void) const { return m_keypressfcn.get (); }

  void execute_keyreleasefcn (const octave_value& new_data = octave_value ()) const { m_keyreleasefcn.execute (new_data); }
  octave_value get_keyreleasefcn (void) const { return m_keyreleasefcn.get (); }

  octave_value get_position (void) const { return m_position.get (); }

  bool is_rearrangeablecolumns (void) const { return m_rearrangeablecolumns.is_on (); }
  std::string get_rearrangeablecolumns (void) const { return m_rearrangeablecolumns.current_value (); }

  octave_value get_rowname (void) const { return m_rowname.get (); }

  bool is_rowstriping (void) const { return m_rowstriping.is_on (); }
  std::string get_rowstriping (void) const { return m_rowstriping.current_value (); }

  std::string get_tooltipstring (void) const { return m_tooltipstring.string_value (); }

  bool units_is (const std::string& v) const { return m_units.is (v); }
  std::string get_units (void) const { return m_units.current_value (); }


  void set___object__ (const octave_value& val)
  {
    if (m___object__.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_backgroundcolor (const octave_value& val)
  {
    if (m_backgroundcolor.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_celleditcallback (const octave_value& val)
  {
    if (m_celleditcallback.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_cellselectioncallback (const octave_value& val)
  {
    if (m_cellselectioncallback.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_columneditable (const octave_value& val)
  {
    if (m_columneditable.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_columnformat (const octave_value& val);

  void set_columnname (const octave_value& val)
  {
    if (m_columnname.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_columnwidth (const octave_value& val);

  void set_data (const octave_value& val)
  {
    if (m_data.set (val, true))
      {
        update_data ();
        mark_modified ();
      }
  }

  void set_enable (const octave_value& val)
  {
    if (m_enable.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_extent (const octave_value& val)
  {
    if (m_extent.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_fontangle (const octave_value& val)
  {
    if (m_fontangle.set (val, true))
      {
        update_fontangle ();
        mark_modified ();
      }
  }

  void set_fontname (const octave_value& val)
  {
    if (m_fontname.set (val, true))
      {
        update_fontname ();
        mark_modified ();
      }
  }

  void set_fontsize (const octave_value& val)
  {
    if (m_fontsize.set (val, true))
      {
        update_fontsize ();
        mark_modified ();
      }
  }

  void set_fontunits (const octave_value& val);

  void set_fontweight (const octave_value& val)
  {
    if (m_fontweight.set (val, true))
      {
        update_fontweight ();
        mark_modified ();
      }
  }

  void set_foregroundcolor (const octave_value& val)
  {
    if (m_foregroundcolor.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_keypressfcn (const octave_value& val)
  {
    if (m_keypressfcn.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_keyreleasefcn (const octave_value& val)
  {
    if (m_keyreleasefcn.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_position (const octave_value& val)
  {
    if (m_position.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_rearrangeablecolumns (const octave_value& val)
  {
    if (m_rearrangeablecolumns.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_rowname (const octave_value& val)
  {
    if (m_rowname.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_rowstriping (const octave_value& val)
  {
    if (m_rowstriping.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_tooltipstring (const octave_value& val)
  {
    if (m_tooltipstring.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_units (const octave_value& val);


    OCTINTERP_API Matrix get_extent_matrix (void) const;

    OCTINTERP_API Matrix get_backgroundcolor_rgb (void);

    OCTINTERP_API Matrix get_alternatebackgroundcolor_rgb (void);

  protected:
    void init (void)
    {
      m_position.add_constraint (dim_vector (1, 4));
      m_extent.add_constraint (dim_vector (1, 4));
      m_backgroundcolor.add_constraint ("double");
      m_backgroundcolor.add_constraint (dim_vector (-1, 3));
      m_columneditable.add_constraint ("logical");
    }

    OCTINTERP_API void update_units (const caseless_str& old_units);
    OCTINTERP_API void update_fontunits (const caseless_str& old_units);
    void update_table_extent (void) { };
    void update_data (void) { update_table_extent (); }
    void update_fontname (void) { update_table_extent (); }
    void update_fontsize (void) { update_table_extent (); }
    void update_fontangle (void)
    {
      update_table_extent ();
    }
    void update_fontweight (void) { update_table_extent (); }
  };

private:
  properties m_properties;

public:
  uitable (const graphics_handle& mh, const graphics_handle& p)
    : base_graphics_object (), m_properties (mh, p)
  { }

  ~uitable (void) { }

  base_properties& get_properties (void) { return m_properties; }

  const base_properties& get_properties (void) const { return m_properties; }

  bool valid_object (void) const { return true; }

  bool has_readonly_property (const caseless_str& pname) const
  {
    bool retval = m_properties.has_readonly_property (pname);
    if (! retval)
      retval = base_properties::has_readonly_property (pname);
    return retval;
  }
};

// ---------------------------------------------------------------------

class OCTINTERP_API uitoolbar : public base_graphics_object
{
public:

  class OCTINTERP_API properties : public base_properties
  {
  public:

    // See the genprops.awk script for an explanation of the
    // properties declarations.
    // Programming note: Keep property list sorted if new ones are added.

public:
  properties (const graphics_handle& mh, const graphics_handle& p);

  ~properties (void) { }

  void set (const caseless_str& pname, const octave_value& val);

  octave_value get (bool all = false) const;

  octave_value get (const caseless_str& pname) const;

  octave_value get (const std::string& pname) const
  {
    return get (caseless_str (pname));
  }

  octave_value get (const char *pname) const
  {
    return get (caseless_str (pname));
  }

  property get_property (const caseless_str& pname);

  std::string graphics_object_name (void) const { return s_go_name; }

  static property_list::pval_map_type factory_defaults (void);

private:
  static std::string s_go_name;

public:


  static std::set<std::string> core_property_names (void);

  static std::set<std::string> readonly_property_names (void);

  static bool has_core_property (const caseless_str& pname);

  static bool has_readonly_property (const caseless_str& pname);

  std::set<std::string> all_property_names (void) const;

  bool has_property (const caseless_str& pname) const;

private:

  any_property m___object__;

public:

  enum
  {
    ID___OBJECT__ = 18000
  };

  octave_value get___object__ (void) const { return m___object__.get (); }


  void set___object__ (const octave_value& val)
  {
    if (m___object__.set (val, true))
      {
        mark_modified ();
      }
  }


  protected:
    void init (void)
    { }
  };

private:
  properties m_properties;

public:
  uitoolbar (const graphics_handle& mh, const graphics_handle& p)
    : base_graphics_object (), m_properties (mh, p), m_default_properties ()
  { }

  ~uitoolbar (void) = default;

  void override_defaults (base_graphics_object& obj)
  {
    // Allow parent (figure) to override first (properties knows how
    // to find the parent object).
    m_properties.override_defaults (obj);

    // Now override with our defaults.  If the default_properties
    // list includes the properties for all defaults (line,
    // surface, etc.) then we don't have to know the type of OBJ
    // here, we just call its set function and let it decide which
    // properties from the list to use.
    obj.set_from_list (m_default_properties);
  }

  void set (const caseless_str& name, const octave_value& value)
  {
    if (name.compare ("default", 7))
      // strip "default", pass rest to function that will
      // parse the remainder and add the element to the
      // default_properties map.
      m_default_properties.set (name.substr (7), value);
    else
      m_properties.set (name, value);
  }

  octave_value get (const caseless_str& name) const
  {
    octave_value retval;

    if (name.compare ("default", 7))
      retval = get_default (name.substr (7));
    else
      retval = m_properties.get (name);

    return retval;
  }

  OCTINTERP_API octave_value get_default (const caseless_str& name) const;

  octave_value get_defaults (void) const
  {
    return m_default_properties.as_struct ("default");
  }

  property_list get_defaults_list (void) const
  {
    return m_default_properties;
  }

  base_properties& get_properties (void) { return m_properties; }

  const base_properties& get_properties (void) const { return m_properties; }

  bool valid_object (void) const { return true; }

  OCTINTERP_API void reset_default_properties (void);

  bool has_readonly_property (const caseless_str& pname) const
  {
    bool retval = m_properties.has_readonly_property (pname);
    if (! retval)
      retval = base_properties::has_readonly_property (pname);
    return retval;
  }

private:
  property_list m_default_properties;
};

// ---------------------------------------------------------------------

class OCTINTERP_API uipushtool : public base_graphics_object
{
public:

  class OCTINTERP_API properties : public base_properties
  {
  public:

    // See the genprops.awk script for an explanation of the
    // properties declarations.
    // Programming note: Keep property list sorted if new ones are added.

public:
  properties (const graphics_handle& mh, const graphics_handle& p);

  ~properties (void) { }

  void set (const caseless_str& pname, const octave_value& val);

  octave_value get (bool all = false) const;

  octave_value get (const caseless_str& pname) const;

  octave_value get (const std::string& pname) const
  {
    return get (caseless_str (pname));
  }

  octave_value get (const char *pname) const
  {
    return get (caseless_str (pname));
  }

  property get_property (const caseless_str& pname);

  std::string graphics_object_name (void) const { return s_go_name; }

  static property_list::pval_map_type factory_defaults (void);

private:
  static std::string s_go_name;

public:


  static std::set<std::string> core_property_names (void);

  static std::set<std::string> readonly_property_names (void);

  static bool has_core_property (const caseless_str& pname);

  static bool has_readonly_property (const caseless_str& pname);

  std::set<std::string> all_property_names (void) const;

  bool has_property (const caseless_str& pname) const;

private:

  array_property m_cdata;
  callback_property m_clickedcallback;
  bool_property m_enable;
  bool_property m_separator;
  string_property m_tooltipstring;
  string_property m___named_icon__;
  any_property m___object__;

public:

  enum
  {
    ID_CDATA = 19000,
    ID_CLICKEDCALLBACK = 19001,
    ID_ENABLE = 19002,
    ID_SEPARATOR = 19003,
    ID_TOOLTIPSTRING = 19004,
    ID___NAMED_ICON__ = 19005,
    ID___OBJECT__ = 19006
  };

  octave_value get_cdata (void) const { return m_cdata.get (); }

  void execute_clickedcallback (const octave_value& new_data = octave_value ()) const { m_clickedcallback.execute (new_data); }
  octave_value get_clickedcallback (void) const { return m_clickedcallback.get (); }

  bool is_enable (void) const { return m_enable.is_on (); }
  std::string get_enable (void) const { return m_enable.current_value (); }

  bool is_separator (void) const { return m_separator.is_on (); }
  std::string get_separator (void) const { return m_separator.current_value (); }

  std::string get_tooltipstring (void) const { return m_tooltipstring.string_value (); }

  std::string get___named_icon__ (void) const { return m___named_icon__.string_value (); }

  octave_value get___object__ (void) const { return m___object__.get (); }


  void set_cdata (const octave_value& val)
  {
    if (m_cdata.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_clickedcallback (const octave_value& val)
  {
    if (m_clickedcallback.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_enable (const octave_value& val)
  {
    if (m_enable.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_separator (const octave_value& val)
  {
    if (m_separator.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_tooltipstring (const octave_value& val)
  {
    if (m_tooltipstring.set (val, true))
      {
        mark_modified ();
      }
  }

  void set___named_icon__ (const octave_value& val)
  {
    if (m___named_icon__.set (val, true))
      {
        mark_modified ();
      }
  }

  void set___object__ (const octave_value& val)
  {
    if (m___object__.set (val, true))
      {
        mark_modified ();
      }
  }


  protected:
    void init (void)
    {
      m_cdata.add_constraint ("double");
      m_cdata.add_constraint ("single");
      m_cdata.add_constraint ("uint8");
      m_cdata.add_constraint (dim_vector (-1, -1, 3));
      m_cdata.add_constraint (dim_vector (0, 0));
    }
  };

private:
  properties m_properties;

public:
  uipushtool (const graphics_handle& mh, const graphics_handle& p)
    : base_graphics_object (), m_properties (mh, p)
  { }

  ~uipushtool (void) = default;

  base_properties& get_properties (void) { return m_properties; }

  const base_properties& get_properties (void) const { return m_properties; }

  bool valid_object (void) const { return true; }

  bool has_readonly_property (const caseless_str& pname) const
  {
    bool retval = m_properties.has_readonly_property (pname);
    if (! retval)
      retval = base_properties::has_readonly_property (pname);
    return retval;
  }

};

// ---------------------------------------------------------------------

class OCTINTERP_API uitoggletool : public base_graphics_object
{
public:

  class OCTINTERP_API properties : public base_properties
  {
  public:

    // See the genprops.awk script for an explanation of the
    // properties declarations.
    // Programming note: Keep property list sorted if new ones are added.

public:
  properties (const graphics_handle& mh, const graphics_handle& p);

  ~properties (void) { }

  void set (const caseless_str& pname, const octave_value& val);

  octave_value get (bool all = false) const;

  octave_value get (const caseless_str& pname) const;

  octave_value get (const std::string& pname) const
  {
    return get (caseless_str (pname));
  }

  octave_value get (const char *pname) const
  {
    return get (caseless_str (pname));
  }

  property get_property (const caseless_str& pname);

  std::string graphics_object_name (void) const { return s_go_name; }

  static property_list::pval_map_type factory_defaults (void);

private:
  static std::string s_go_name;

public:


  static std::set<std::string> core_property_names (void);

  static std::set<std::string> readonly_property_names (void);

  static bool has_core_property (const caseless_str& pname);

  static bool has_readonly_property (const caseless_str& pname);

  std::set<std::string> all_property_names (void) const;

  bool has_property (const caseless_str& pname) const;

private:

  array_property m_cdata;
  callback_property m_clickedcallback;
  bool_property m_enable;
  callback_property m_offcallback;
  callback_property m_oncallback;
  bool_property m_separator;
  bool_property m_state;
  string_property m_tooltipstring;
  string_property m___named_icon__;
  any_property m___object__;

public:

  enum
  {
    ID_CDATA = 20000,
    ID_CLICKEDCALLBACK = 20001,
    ID_ENABLE = 20002,
    ID_OFFCALLBACK = 20003,
    ID_ONCALLBACK = 20004,
    ID_SEPARATOR = 20005,
    ID_STATE = 20006,
    ID_TOOLTIPSTRING = 20007,
    ID___NAMED_ICON__ = 20008,
    ID___OBJECT__ = 20009
  };

  octave_value get_cdata (void) const { return m_cdata.get (); }

  void execute_clickedcallback (const octave_value& new_data = octave_value ()) const { m_clickedcallback.execute (new_data); }
  octave_value get_clickedcallback (void) const { return m_clickedcallback.get (); }

  bool is_enable (void) const { return m_enable.is_on (); }
  std::string get_enable (void) const { return m_enable.current_value (); }

  void execute_offcallback (const octave_value& new_data = octave_value ()) const { m_offcallback.execute (new_data); }
  octave_value get_offcallback (void) const { return m_offcallback.get (); }

  void execute_oncallback (const octave_value& new_data = octave_value ()) const { m_oncallback.execute (new_data); }
  octave_value get_oncallback (void) const { return m_oncallback.get (); }

  bool is_separator (void) const { return m_separator.is_on (); }
  std::string get_separator (void) const { return m_separator.current_value (); }

  bool is_state (void) const { return m_state.is_on (); }
  std::string get_state (void) const { return m_state.current_value (); }

  std::string get_tooltipstring (void) const { return m_tooltipstring.string_value (); }

  std::string get___named_icon__ (void) const { return m___named_icon__.string_value (); }

  octave_value get___object__ (void) const { return m___object__.get (); }


  void set_cdata (const octave_value& val)
  {
    if (m_cdata.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_clickedcallback (const octave_value& val)
  {
    if (m_clickedcallback.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_enable (const octave_value& val)
  {
    if (m_enable.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_offcallback (const octave_value& val)
  {
    if (m_offcallback.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_oncallback (const octave_value& val)
  {
    if (m_oncallback.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_separator (const octave_value& val)
  {
    if (m_separator.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_state (const octave_value& val)
  {
    if (m_state.set (val, true))
      {
        mark_modified ();
      }
  }

  void set_tooltipstring (const octave_value& val)
  {
    if (m_tooltipstring.set (val, true))
      {
        mark_modified ();
      }
  }

  void set___named_icon__ (const octave_value& val)
  {
    if (m___named_icon__.set (val, true))
      {
        mark_modified ();
      }
  }

  void set___object__ (const octave_value& val)
  {
    if (m___object__.set (val, true))
      {
        mark_modified ();
      }
  }


  protected:
    void init (void)
    {
      m_cdata.add_constraint ("double");
      m_cdata.add_constraint ("single");
      m_cdata.add_constraint ("uint8");
      m_cdata.add_constraint (dim_vector (-1, -1, 3));
      m_cdata.add_constraint (dim_vector (0, 0));
    }
  };

private:
  properties m_properties;

public:
  uitoggletool (const graphics_handle& mh, const graphics_handle& p)
    : base_graphics_object (), m_properties (mh, p)
  { }

  ~uitoggletool (void) = default;

  base_properties& get_properties (void) { return m_properties; }

  const base_properties& get_properties (void) const { return m_properties; }

  bool valid_object (void) const { return true; }

  bool has_readonly_property (const caseless_str& pname) const
  {
    bool retval = m_properties.has_readonly_property (pname);
    if (! retval)
      retval = base_properties::has_readonly_property (pname);
    return retval;
  }

};

// ---------------------------------------------------------------------

OCTINTERP_API octave_value
get_property_from_handle (double handle, const std::string& property,
                          const std::string& func);
OCTINTERP_API bool
set_property_in_handle (double handle, const std::string& property,
                        const octave_value& arg, const std::string& func);

// ---------------------------------------------------------------------

class graphics_event;

class
OCTINTERP_API
base_graphics_event
{
public:
  enum priority { INTERRUPT, QUEUE, CANCEL };

  friend class graphics_event;

  base_graphics_event (void)
    : m_busyaction (QUEUE)
  { };

  base_graphics_event (int busyaction)
    : m_busyaction (busyaction)
  { };

  virtual ~base_graphics_event (void) = default;

  int get_busyaction (void) { return m_busyaction; };

  virtual void execute (void) = 0;

private:
  int m_busyaction;
};

class
OCTINTERP_API
graphics_event
{
public:

  typedef void (*event_fcn) (void *);

  graphics_event (void) = default;

  graphics_event (base_graphics_event *new_rep) : m_rep (new_rep) { }

  graphics_event (const graphics_event&) = default;

  ~graphics_event (void) = default;

  graphics_event& operator = (const graphics_event&) = default;

  int get_busyaction (void)
  {
    if (ok ())
      return m_rep->get_busyaction ();
    else
      error ("graphics_event::busyaction: invalid graphics_event");
  }

  void execute (void)
  {
    if (ok ())
      m_rep->execute ();
  }

  bool ok (void) const { return (m_rep != nullptr); }

  static OCTINTERP_API graphics_event
  create_callback_event (const graphics_handle& h,
                         const std::string& name,
                         const octave_value& data = Matrix (),
                         int busyaction = base_graphics_event::QUEUE);

  static OCTINTERP_API graphics_event
  create_callback_event (const graphics_handle& h,
                         const octave_value& cb,
                         const octave_value& data = Matrix (),
                         int busyaction = base_graphics_event::QUEUE);

  static OCTINTERP_API graphics_event
  create_mcode_event (const graphics_handle& h, const std::string& cmd,
                      int busyaction);

  static OCTINTERP_API graphics_event
  create_function_event (event_fcn fcn, void *data = nullptr);

  static OCTINTERP_API graphics_event
  create_set_event (const graphics_handle& h, const std::string& name,
                    const octave_value& value, bool notify_toolkit = true,
                    bool redraw_figure = false);
private:

  std::shared_ptr <base_graphics_event> m_rep;
};

class OCTINTERP_API gh_manager
{
public:

  typedef std::pair<uint8NDArray /*pixels*/, std::string /*svg*/> latex_data;

  OCTINTERP_API gh_manager (octave::interpreter& interp);

  // FIXME: eventually eliminate these static functions and access
  // gh_manager object through the interpreter.

  OCTINTERP_API graphics_handle get_handle (bool integer_figure_handle);

  OCTINTERP_API void free (const graphics_handle& h, bool from_root = false);

  OCTINTERP_API void renumber_figure (const graphics_handle& old_gh,
                                      const graphics_handle& new_gh);

  graphics_handle lookup (double val) const
  {
    const_iterator p = (octave::math::isnan (val)
                        ? m_handle_map.end () : m_handle_map.find (val));

    return (p != m_handle_map.end ()) ? p->first : graphics_handle ();
  }

  graphics_handle lookup (const octave_value& val) const
  {
    return (val.is_real_scalar ()
            ? lookup (val.double_value ()) : graphics_handle ());
  }

  graphics_object get_object (double val) const
  {
    return get_object (lookup (val));
  }

  graphics_object get_object (const graphics_handle& h) const
  {
    const_iterator p = (h.ok () ? m_handle_map.find (h) : m_handle_map.end ());

    return (p != m_handle_map.end ()) ? p->second : graphics_object ();
  }

  OCTINTERP_API graphics_handle
  make_graphics_handle (const std::string& go_name,
                        const graphics_handle& p,
                        bool integer_figure_handle = false,
                        bool call_createfcn = true,
                        bool notify_toolkit = true);

  OCTINTERP_API graphics_handle
  make_figure_handle (double val, bool notify_toolkit = true);

  OCTINTERP_API void push_figure (const graphics_handle& h);

  OCTINTERP_API void pop_figure (const graphics_handle& h);

  graphics_handle current_figure (void) const
  {
    graphics_handle retval;

    for (const auto& hfig : m_figure_list)
      {
        if (is_handle_visible (hfig))
          retval = hfig;
      }

    return retval;
  }

  Matrix handle_list (bool show_hidden = false)
  {
    Matrix retval (1, m_handle_map.size ());

    octave_idx_type i = 0;
    for (const auto& h_iter : m_handle_map)
      {
        graphics_handle h = h_iter.first;

        if (show_hidden || is_handle_visible (h))
          retval(i++) = h.value ();
      }

    retval.resize (1, i);

    return retval;
  }

  void lock (void) { m_graphics_lock.lock (); }

  bool try_lock (void) { return m_graphics_lock.try_lock (); }

  void unlock (void) { m_graphics_lock.unlock (); }

  Matrix figure_handle_list (bool show_hidden = false)
  {
    Matrix retval (1, m_figure_list.size ());

    octave_idx_type i = 0;
    for (const auto& hfig : m_figure_list)
      {
        if (show_hidden || is_handle_visible (hfig))
          retval(i++) = hfig.value ();
      }

    retval.resize (1, i);

    return retval;
  }

  OCTINTERP_API void
  execute_listener (const graphics_handle& h, const octave_value& l);

  void execute_callback (const graphics_handle& h,
                         const std::string& name,
                         const octave_value& data = Matrix ())
  {
    octave_value cb;

    if (true)
      {
        octave::autolock guard (graphics_lock ());

        graphics_object go = get_object (h);

        if (go.valid_object ())
          cb = go.get (name);
      }

    execute_callback (h, cb, data);
  }

  OCTINTERP_API void
  execute_callback (const graphics_handle& h, const octave_value& cb,
                    const octave_value& data = Matrix ());

  OCTINTERP_API void
  post_callback (const graphics_handle& h, const std::string& name,
                 const octave_value& data = Matrix ());

  OCTINTERP_API void
  post_function (graphics_event::event_fcn fcn, void *fcn_data = nullptr);

  OCTINTERP_API void
  post_set (const graphics_handle& h, const std::string& name,
            const octave_value& value, bool notify_toolkit = true,
            bool redraw_figure = false);

  OCTINTERP_API int process_events (bool force = false);

  OCTINTERP_API void enable_event_processing (bool enable = true);

  bool is_handle_visible (const graphics_handle& h) const
  {
    bool retval = false;

    graphics_object go = get_object (h);

    if (go.valid_object ())
      retval = go.is_handle_visible ();

    return retval;
  }

  OCTINTERP_API void close_all_figures (void);

  OCTINTERP_API void restore_gcbo (void);

  OCTINTERP_API void post_event (const graphics_event& e);

  octave::mutex graphics_lock (void)
  {
    return m_graphics_lock;
  }

  latex_data get_latex_data (const std::string& key) const
  {
    latex_data retval;

    const auto it = m_latex_cache.find (key);

    if (it != m_latex_cache.end ())
      retval = it->second;

    return retval;
  }

  void set_latex_data (const std::string& key, latex_data val)
  {
    // Limit the number of cache entries to 500
    if (m_latex_keys.size () >= 500)
      {
        auto it = m_latex_cache.find (m_latex_keys.front ());

        if (it != m_latex_cache.end ())
          m_latex_cache.erase (it);

        m_latex_keys.pop_front ();
      }

    m_latex_cache[key] = val;
    m_latex_keys.push_back (key);
  }

private:

  typedef std::map<graphics_handle, graphics_object>::iterator iterator;
  typedef std::map<graphics_handle, graphics_object>::const_iterator
    const_iterator;

  typedef std::set<graphics_handle>::iterator free_list_iterator;
  typedef std::set<graphics_handle>::const_iterator const_free_list_iterator;

  typedef std::list<graphics_handle>::iterator figure_list_iterator;
  typedef std::list<graphics_handle>::const_iterator const_figure_list_iterator;

  octave::interpreter& m_interpreter;

  // A map of handles to graphics objects.
  std::map<graphics_handle, graphics_object> m_handle_map;

  // The available graphics handles.
  std::set<graphics_handle> m_handle_free_list;

  // The next handle available if m_handle_free_list is empty.
  double m_next_handle;

  // The allocated figure handles.  Top of the stack is most recently
  // created.
  std::list<graphics_handle> m_figure_list;

  // The lock for accessing the graphics sytsem.
  octave::mutex m_graphics_lock;

  // The list of events queued by graphics toolkits.
  std::list<graphics_event> m_event_queue;

  // The stack of callback objects.
  std::list<graphics_object> m_callback_objects;

  // A flag telling whether event processing must be constantly on.
  int m_event_processing;

  // Cache of already parsed latex strings. Store a separate list of keys
  // to allow for erasing oldest entries if cache size becomes too large.
  std::unordered_map<std::string, latex_data> m_latex_cache;
  std::list<std::string> m_latex_keys;
};

OCTINTERP_API void
get_children_limits (double& min_val, double& max_val,
                     double& min_pos, double& max_neg,
                     const Matrix& kids, char limit_type);

OCTINTERP_API int calc_dimensions (const graphics_object& gh);

// This function is NOT equivalent to the scripting language function gcf.
OCTINTERP_API graphics_handle gcf (void);

// This function is NOT equivalent to the scripting language function gca.
OCTINTERP_API graphics_handle gca (void);

OCTINTERP_API void close_all_figures (void);

OCTAVE_NAMESPACE_END

#if defined (OCTAVE_PROVIDE_DEPRECATED_SYMBOLS)

OCTAVE_DEPRECATED (7, "use 'octave::base_scaler' instead")
typedef octave::base_scaler base_scaler;

OCTAVE_DEPRECATED (7, "use 'octave::lin_scaler' instead")
typedef octave::lin_scaler lin_scaler;

OCTAVE_DEPRECATED (7, "use 'octave::log_scaler' instead")
typedef octave::log_scaler log_scaler;

OCTAVE_DEPRECATED (7, "use 'octave::neg_log_scaler' instead")
typedef octave::neg_log_scaler neg_log_scaler;

OCTAVE_DEPRECATED (7, "use 'octave::scaler' instead")
typedef octave::scaler scaler;

OCTAVE_DEPRECATED (7, "use 'octave::base_property' instead")
typedef octave::base_property base_property;

OCTAVE_DEPRECATED (7, "use 'octave::string_property' instead")
typedef octave::string_property string_property;

OCTAVE_DEPRECATED (7, "use 'octave::string_array_property' instead")
typedef octave::string_array_property string_array_property;

OCTAVE_DEPRECATED (7, "use 'octave::text_label_property' instead")
typedef octave::text_label_property text_label_property;

OCTAVE_DEPRECATED (7, "use 'octave::radio_values' instead")
typedef octave::radio_values radio_values;

OCTAVE_DEPRECATED (7, "use 'octave::radio_property' instead")
typedef octave::radio_property radio_property;

OCTAVE_DEPRECATED (7, "use 'octave::color_values' instead")
typedef octave::color_values color_values;

OCTAVE_DEPRECATED (7, "use 'octave::color_property' instead")
typedef octave::color_property color_property;

OCTAVE_DEPRECATED (7, "use 'octave::double_property' instead")
typedef octave::double_property double_property;

OCTAVE_DEPRECATED (7, "use 'octave::double_radio_property' instead")
typedef octave::double_radio_property double_radio_property;

OCTAVE_DEPRECATED (7, "use 'octave::array_property' instead")
typedef octave::array_property array_property;

OCTAVE_DEPRECATED (7, "use 'octave::row_vector_property' instead")
typedef octave::row_vector_property row_vector_property;

OCTAVE_DEPRECATED (7, "use 'octave::bool_property' instead")
typedef octave::bool_property bool_property;

OCTAVE_DEPRECATED (7, "use 'octave::handle_property' instead")
typedef octave::handle_property handle_property;

OCTAVE_DEPRECATED (7, "use 'octave::any_property' instead")
typedef octave::any_property any_property;

OCTAVE_DEPRECATED (7, "use 'octave::children_property' instead")
typedef octave::children_property children_property;

OCTAVE_DEPRECATED (7, "use 'octave::callback_property' instead")
typedef octave::callback_property callback_property;

OCTAVE_DEPRECATED (7, "use 'octave::property' instead")
typedef octave::property property;

OCTAVE_DEPRECATED (7, "use 'octave::pval_vector' instead")
typedef octave::pval_vector pval_vector;

OCTAVE_DEPRECATED (7, "use 'octave::property_list' instead")
typedef octave::property_list property_list;

OCTAVE_DEPRECATED (7, "use 'octave::base_properties' instead")
typedef octave::base_properties base_properties;

OCTAVE_DEPRECATED (7, "use 'octave::base_graphics_object' instead")
typedef octave::base_graphics_object base_graphics_object;

OCTAVE_DEPRECATED (7, "use 'octave::graphics_object' instead")
typedef octave::graphics_object graphics_object;

OCTAVE_DEPRECATED (7, "use 'octave::root_figure' instead")
typedef octave::root_figure root_figure;

OCTAVE_DEPRECATED (7, "use 'octave::figure' instead")
typedef octave::figure figure;

OCTAVE_DEPRECATED (7, "use 'octave::graphics_xform' instead")
typedef octave::graphics_xform graphics_xform;

OCTAVE_DEPRECATED (7, "use 'octave::axes' instead")
typedef octave::axes axes;

OCTAVE_DEPRECATED (7, "use 'octave::line' instead")
typedef octave::line line;

OCTAVE_DEPRECATED (7, "use 'octave::text' instead")
typedef octave::text text;

OCTAVE_DEPRECATED (7, "use 'octave::image' instead")
typedef octave::image image;

OCTAVE_DEPRECATED (7, "use 'octave::light' instead")
typedef octave::light light;

OCTAVE_DEPRECATED (7, "use 'octave::patch' instead")
typedef octave::patch patch;

OCTAVE_DEPRECATED (7, "use 'octave::scatter' instead")
typedef octave::scatter scatter;

OCTAVE_DEPRECATED (7, "use 'octave::surface' instead")
typedef octave::surface surface;

OCTAVE_DEPRECATED (7, "use 'octave::hggroup' instead")
typedef octave::hggroup hggroup;

OCTAVE_DEPRECATED (7, "use 'octave::uimenu' instead")
typedef octave::uimenu uimenu;

OCTAVE_DEPRECATED (7, "use 'octave::uicontextmenu' instead")
typedef octave::uicontextmenu uicontextmenu;

OCTAVE_DEPRECATED (7, "use 'octave::uicontrol' instead")
typedef octave::uicontrol uicontrol;

OCTAVE_DEPRECATED (7, "use 'octave::uibuttongroup' instead")
typedef octave::uibuttongroup uibuttongroup;

OCTAVE_DEPRECATED (7, "use 'octave::uipanel' instead")
typedef octave::uipanel uipanel;

OCTAVE_DEPRECATED (7, "use 'octave::uitable' instead")
typedef octave::uitable uitable;

OCTAVE_DEPRECATED (7, "use 'octave::uitoolbar' instead")
typedef octave::uitoolbar uitoolbar;

OCTAVE_DEPRECATED (7, "use 'octave::uipushtool' instead")
typedef octave::uipushtool uipushtool;

OCTAVE_DEPRECATED (7, "use 'octave::uitoggletool' instead")
typedef octave::uitoggletool uitoggletool;

OCTAVE_DEPRECATED (7, "use 'octave::base_graphics_event' instead")
typedef octave::base_graphics_event base_graphics_event;

OCTAVE_DEPRECATED (7, "use 'octave::graphics_event' instead")
typedef octave::graphics_event graphics_event;

OCTAVE_DEPRECATED (7, "use 'octave::gh_manager' instead")
typedef octave::gh_manager gh_manager;

#endif

#endif
