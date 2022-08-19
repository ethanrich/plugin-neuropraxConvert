# defined since 2.8.3
if (CMAKE_VERSION VERSION_LESS 2.8.3)
  get_filename_component (CMAKE_CURRENT_LIST_DIR ${CMAKE_CURRENT_LIST_FILE} PATH)
endif ()

# Allows loading FFTW3 settings from another project
set (FFTW3_CONFIG_FILE "${CMAKE_CURRENT_LIST_FILE}")

set (FFTW3_LIBRARIES fftw3)
set (FFTW3_LIBRARY_DIRS /scratch/build/mxe-octave-w64/release/usr/x86_64-w64-mingw32/lib)
set (FFTW3_INCLUDE_DIRS /scratch/build/mxe-octave-w64/release/usr/x86_64-w64-mingw32/include)

include ("${CMAKE_CURRENT_LIST_DIR}/FFTW3LibraryDepends.cmake")

if (CMAKE_VERSION VERSION_LESS 2.8.3)
  set (CMAKE_CURRENT_LIST_DIR)
endif ()
