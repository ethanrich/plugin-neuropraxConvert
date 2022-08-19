#----------------------------------------------------------------
# Generated CMake target import file for configuration "Release".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "Qhull::qhull" for configuration "Release"
set_property(TARGET Qhull::qhull APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(Qhull::qhull PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/bin/qhull.exe"
  )

list(APPEND _IMPORT_CHECK_TARGETS Qhull::qhull )
list(APPEND _IMPORT_CHECK_FILES_FOR_Qhull::qhull "${_IMPORT_PREFIX}/bin/qhull.exe" )

# Import target "Qhull::rbox" for configuration "Release"
set_property(TARGET Qhull::rbox APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(Qhull::rbox PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/bin/rbox.exe"
  )

list(APPEND _IMPORT_CHECK_TARGETS Qhull::rbox )
list(APPEND _IMPORT_CHECK_FILES_FOR_Qhull::rbox "${_IMPORT_PREFIX}/bin/rbox.exe" )

# Import target "Qhull::qconvex" for configuration "Release"
set_property(TARGET Qhull::qconvex APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(Qhull::qconvex PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/bin/qconvex.exe"
  )

list(APPEND _IMPORT_CHECK_TARGETS Qhull::qconvex )
list(APPEND _IMPORT_CHECK_FILES_FOR_Qhull::qconvex "${_IMPORT_PREFIX}/bin/qconvex.exe" )

# Import target "Qhull::qdelaunay" for configuration "Release"
set_property(TARGET Qhull::qdelaunay APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(Qhull::qdelaunay PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/bin/qdelaunay.exe"
  )

list(APPEND _IMPORT_CHECK_TARGETS Qhull::qdelaunay )
list(APPEND _IMPORT_CHECK_FILES_FOR_Qhull::qdelaunay "${_IMPORT_PREFIX}/bin/qdelaunay.exe" )

# Import target "Qhull::qvoronoi" for configuration "Release"
set_property(TARGET Qhull::qvoronoi APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(Qhull::qvoronoi PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/bin/qvoronoi.exe"
  )

list(APPEND _IMPORT_CHECK_TARGETS Qhull::qvoronoi )
list(APPEND _IMPORT_CHECK_FILES_FOR_Qhull::qvoronoi "${_IMPORT_PREFIX}/bin/qvoronoi.exe" )

# Import target "Qhull::qhalf" for configuration "Release"
set_property(TARGET Qhull::qhalf APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(Qhull::qhalf PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/bin/qhalf.exe"
  )

list(APPEND _IMPORT_CHECK_TARGETS Qhull::qhalf )
list(APPEND _IMPORT_CHECK_FILES_FOR_Qhull::qhalf "${_IMPORT_PREFIX}/bin/qhalf.exe" )

# Import target "Qhull::qhull_r" for configuration "Release"
set_property(TARGET Qhull::qhull_r APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(Qhull::qhull_r PROPERTIES
  IMPORTED_IMPLIB_RELEASE "${_IMPORT_PREFIX}/lib/libqhull_r.dll.a"
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/bin/libqhull_r.dll"
  )

list(APPEND _IMPORT_CHECK_TARGETS Qhull::qhull_r )
list(APPEND _IMPORT_CHECK_FILES_FOR_Qhull::qhull_r "${_IMPORT_PREFIX}/lib/libqhull_r.dll.a" "${_IMPORT_PREFIX}/bin/libqhull_r.dll" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
