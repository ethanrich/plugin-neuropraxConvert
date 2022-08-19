## Copyright (C) 2013-2019 Olaf Till <i7tiol@t-online.de>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} pq_lo_view (@var{connection}, @var{oid}, @var{viewer})
##
## Exports the large object of Oid @var{oid} in the database associated
## with @var{connection} to a temporary file and starts the program
## @var{viewer} in the background with the name of the temporary file as
## argument.
##
## The temporary file will be removed after termination of the viewer.
##
## @end deftypefn

function pq_lo_view (conn, oid, viewer)

  if (nargin () != 3 || ! ischar (viewer) || rows (viewer) != 1)
    print_usage ();
  endif

  if (([opid, omsg] = fork ()) == 0)
    ## outer child

    unwind_protect

      ## access database in outer child, so parent can't return and
      ## perform another database access at the same time

      ## Relying on Octave to delete the tempfile does not work here.
      if (([~, tname, msg] = mkstemp ...
                               (fullfile (P_tmpdir (),
                                          "octave-pq_lo_view-XXXXXX"))
          ) == -1)
        error ("could not make temporary file: %s", msg);
      endif

      ## We don't use try-catch since it doesn't work if interrupted
      ## by a signal. But unwind_protect needs to check this flag.
      vpid = -1;

      unwind_protect

        ## throws an error for errors
        pq_lo_export (conn, oid, tname);

        if (([vpid, vmsg] = fork ()) == 0)
          ## child for viewer

          unwind_protect

            unwind_protect

              if (system (sprintf ("%s %s", viewer, tname)) != 0)
                error ("error in execution of viewer program or viewer terminated by a signal");
              endif

            unwind_protect_cleanup

              unlink (tname);

            end_unwind_protect

          unwind_protect_cleanup

            __pq_internal_exit__ ();

          end_unwind_protect

        elseif (vpid < 0)
          ## fork for viewer went wrong
          error ("error in fork for viewer process: %s", vmsg);
        endif

      unwind_protect_cleanup

        ## If no inner child has been forked, delete tempfile here.
        if (vpid < 0)
          unlink (tname);
        endif

      end_unwind_protect

    unwind_protect_cleanup

      __pq_internal_exit__ ();

    end_unwind_protect

  elseif (opid < 0)
    ## fork for outer child went wrong
    error ("error in fork for outer child: %s", omsg);
  endif

  ## parent  
  waitpid (opid);

endfunction
