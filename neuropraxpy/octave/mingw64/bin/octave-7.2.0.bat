:; # if running from bash, recall using cmd.exe
:; cmd.exe //c "$0" "$@"; exit $?
@echo off
Rem   Find Octave's install directory through cmd.exe variables.
Rem   This batch file should reside in Octaves installation bin dir!
Rem
Rem   This trick finds the location where the batch file resides.
Rem   Note: the result ends with a backslash.
set OCT_HOME=%~dp0\.\..\
set ROOT_PATH=%~dp0\.\..\..\
Rem Convert to 8.3 format so we don't have to worry about spaces.
for %%I in ("%OCT_HOME%") do set OCT_HOME=%%~sI
for %%I in ("%ROOT_PATH%") do set ROOT_PATH=%%~sI

set MSYSTEM=MSYS
set MSYSPATH=%OCT_HOME%
IF EXIST "%ROOT_PATH%mingw64\bin\octave.bat" (
  set MSYSTEM=MINGW64
  set MSYSPATH=%ROOT_PATH%usr\
) ELSE (
  IF EXIST "%ROOT_PATH%mingw32\bin\octave.bat" (
    set MSYSTEM=MINGW64
    set MSYSPATH=%ROOT_PATH%usr\
  )
)
 
Rem   Set up PATH.  Make sure the octave bin dir comes first.

set PATH=%OCT_HOME%qt5\bin;%OCT_HOME%bin;%MSYSPATH%bin;%PATH%

Rem   Set up any environment vars we may need.

set TERM=cygwin
set GNUTERM=wxt
set GS=gs.exe

Rem QT_PLUGIN_PATH must be set to avoid segfault (bug #53419).
IF EXIST "%OCT_HOME%\qt5\bin\" (
  set QT_PLUGIN_PATH=%OCT_HOME%\qt5\plugins
) ELSE (
  set QT_PLUGIN_PATH=%OCT_HOME%\plugins
)

Rem pkgconfig .pc files path
set PKG_CONFIG_PATH=%OCT_HOME%\lib\pkgconfig

IF NOT x%OPENBLAS_NUM_THREADS%==x GOTO openblas_num_threads_set

Rem Set OPENBLAS_NUM_THREADS to number of physical processor cores.
SETLOCAL ENABLEDELAYEDEXPANSION
SET count=1
FOR /F "tokens=* USEBACKQ" %%F IN (`wmic CPU Get NumberOfCores`) DO (
  SET line!count!=%%F
  SET /a count=!count!+1
)
Rem Check that first line contains "NumberOfCores".
IF x%line1%==xNumberOfCores (
  Rem The next line should contain the number of cores.
  SET OPENBLAS_NUM_THREADS=%line2%
)
ENDLOCAL & SET OPENBLAS_NUM_THREADS=%OPENBLAS_NUM_THREADS%

:openblas_num_threads_set

Rem set home if not already set
if "%HOME%"=="" set HOME=%USERPROFILE%
if "%HOME%"=="" set HOME=%HOMEDRIVE%%HOMEPATH%
Rem set HOME to 8.3 format
for %%I in ("%HOME%") do set HOME=%%~sI

Rem   Check for args to determine if GUI (--gui, --force-gui)
Rem   or CLI (--no-gui) should be started.
Rem   If nothing is specified, start the CLI.
set GUI_MODE=0
:checkargs
if -%1-==-- goto args_done

if %1==--gui (
  set GUI_MODE=1
) else (
if %1==--force-gui (
  set GUI_MODE=1
) else (
if %1==--no-gui (
  set GUI_MODE=0
)))

Rem move to next argument and continue processing
shift
goto checkargs

:args_done

Rem   Start Octave (this detaches and immediately returns).
if %GUI_MODE%==1 (
  start octave-gui.exe --gui %*
) else (
  octave-cli.exe %*
)

