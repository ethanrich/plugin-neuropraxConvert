## Copyright (C) 2016-2019 Olaf Till <i7tiol@t-online.de>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {} anon_varargin_saved ()
## Checks if anonymous functions with 'varargin' are saved correctly.
##
## Bug #45972, should be fixed in Octaves stable branch from 5.1
## on. Returns true if saved correctly, false otherwise.
##
## @end deftypefn

function ret = anon_varargin_saved ()

  ## different results are only possible with a newly started Octave
  mlock ();

  persistent res = [];

  persistent min_parallel_version = "3.0.4";

  persistent fname = "anon_varargin_saved";

  if (isempty (res))

    if (! exist ("__parallel_package_version__", "file") ||
        compare_versions (__parallel_package_version__ (),
                          min_parallel_version, "<"))
      error ("%s: this test requires the 'parallel' package of at least version %s to be loaded",
             fname, min_parallel_version);
    endif

    f = @ (x, y, varargin) x + y + varargin{1};

    if (([fid, msg] = tmpfile ()) == -1)
      error ("%s: could not open temporary file");
    endif
  
    unwind_protect

      fsave (fid, f);

      if (fseek (fid, 0, SEEK_SET) == -1)
        error ("%s: could not rewind temporary file");
      endif

      tp = fload (fid);

      try

        assert (f (1, 2, 3), tp (1, 2, 3));

        res = true;

      catch

        res = false;

      end_try_catch

    unwind_protect_cleanup

      fclose (fid);

    end_unwind_protect

  endif

  ret = res;

endfunction
