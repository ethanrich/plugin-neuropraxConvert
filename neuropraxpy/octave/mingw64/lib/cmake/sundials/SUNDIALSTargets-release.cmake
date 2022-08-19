#----------------------------------------------------------------
# Generated CMake target import file for configuration "Release".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "SUNDIALS::generic_shared" for configuration "Release"
set_property(TARGET SUNDIALS::generic_shared APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(SUNDIALS::generic_shared PROPERTIES
  IMPORTED_IMPLIB_RELEASE "${_IMPORT_PREFIX}/lib/libsundials_generic.dll.a"
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/libsundials_generic.dll"
  )

list(APPEND _IMPORT_CHECK_TARGETS SUNDIALS::generic_shared )
list(APPEND _IMPORT_CHECK_FILES_FOR_SUNDIALS::generic_shared "${_IMPORT_PREFIX}/lib/libsundials_generic.dll.a" "${_IMPORT_PREFIX}/lib/libsundials_generic.dll" )

# Import target "SUNDIALS::nvecserial_shared" for configuration "Release"
set_property(TARGET SUNDIALS::nvecserial_shared APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(SUNDIALS::nvecserial_shared PROPERTIES
  IMPORTED_IMPLIB_RELEASE "${_IMPORT_PREFIX}/lib/libsundials_nvecserial.dll.a"
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/libsundials_nvecserial.dll"
  )

list(APPEND _IMPORT_CHECK_TARGETS SUNDIALS::nvecserial_shared )
list(APPEND _IMPORT_CHECK_FILES_FOR_SUNDIALS::nvecserial_shared "${_IMPORT_PREFIX}/lib/libsundials_nvecserial.dll.a" "${_IMPORT_PREFIX}/lib/libsundials_nvecserial.dll" )

# Import target "SUNDIALS::nvecmanyvector_shared" for configuration "Release"
set_property(TARGET SUNDIALS::nvecmanyvector_shared APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(SUNDIALS::nvecmanyvector_shared PROPERTIES
  IMPORTED_IMPLIB_RELEASE "${_IMPORT_PREFIX}/lib/libsundials_nvecmanyvector.dll.a"
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/libsundials_nvecmanyvector.dll"
  )

list(APPEND _IMPORT_CHECK_TARGETS SUNDIALS::nvecmanyvector_shared )
list(APPEND _IMPORT_CHECK_FILES_FOR_SUNDIALS::nvecmanyvector_shared "${_IMPORT_PREFIX}/lib/libsundials_nvecmanyvector.dll.a" "${_IMPORT_PREFIX}/lib/libsundials_nvecmanyvector.dll" )

# Import target "SUNDIALS::sunmatrixband_shared" for configuration "Release"
set_property(TARGET SUNDIALS::sunmatrixband_shared APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(SUNDIALS::sunmatrixband_shared PROPERTIES
  IMPORTED_IMPLIB_RELEASE "${_IMPORT_PREFIX}/lib/libsundials_sunmatrixband.dll.a"
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/libsundials_sunmatrixband.dll"
  )

list(APPEND _IMPORT_CHECK_TARGETS SUNDIALS::sunmatrixband_shared )
list(APPEND _IMPORT_CHECK_FILES_FOR_SUNDIALS::sunmatrixband_shared "${_IMPORT_PREFIX}/lib/libsundials_sunmatrixband.dll.a" "${_IMPORT_PREFIX}/lib/libsundials_sunmatrixband.dll" )

# Import target "SUNDIALS::sunmatrixdense_shared" for configuration "Release"
set_property(TARGET SUNDIALS::sunmatrixdense_shared APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(SUNDIALS::sunmatrixdense_shared PROPERTIES
  IMPORTED_IMPLIB_RELEASE "${_IMPORT_PREFIX}/lib/libsundials_sunmatrixdense.dll.a"
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/libsundials_sunmatrixdense.dll"
  )

list(APPEND _IMPORT_CHECK_TARGETS SUNDIALS::sunmatrixdense_shared )
list(APPEND _IMPORT_CHECK_FILES_FOR_SUNDIALS::sunmatrixdense_shared "${_IMPORT_PREFIX}/lib/libsundials_sunmatrixdense.dll.a" "${_IMPORT_PREFIX}/lib/libsundials_sunmatrixdense.dll" )

# Import target "SUNDIALS::sunmatrixsparse_shared" for configuration "Release"
set_property(TARGET SUNDIALS::sunmatrixsparse_shared APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(SUNDIALS::sunmatrixsparse_shared PROPERTIES
  IMPORTED_IMPLIB_RELEASE "${_IMPORT_PREFIX}/lib/libsundials_sunmatrixsparse.dll.a"
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/libsundials_sunmatrixsparse.dll"
  )

list(APPEND _IMPORT_CHECK_TARGETS SUNDIALS::sunmatrixsparse_shared )
list(APPEND _IMPORT_CHECK_FILES_FOR_SUNDIALS::sunmatrixsparse_shared "${_IMPORT_PREFIX}/lib/libsundials_sunmatrixsparse.dll.a" "${_IMPORT_PREFIX}/lib/libsundials_sunmatrixsparse.dll" )

# Import target "SUNDIALS::sunlinsolband_shared" for configuration "Release"
set_property(TARGET SUNDIALS::sunlinsolband_shared APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(SUNDIALS::sunlinsolband_shared PROPERTIES
  IMPORTED_IMPLIB_RELEASE "${_IMPORT_PREFIX}/lib/libsundials_sunlinsolband.dll.a"
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/libsundials_sunlinsolband.dll"
  )

list(APPEND _IMPORT_CHECK_TARGETS SUNDIALS::sunlinsolband_shared )
list(APPEND _IMPORT_CHECK_FILES_FOR_SUNDIALS::sunlinsolband_shared "${_IMPORT_PREFIX}/lib/libsundials_sunlinsolband.dll.a" "${_IMPORT_PREFIX}/lib/libsundials_sunlinsolband.dll" )

# Import target "SUNDIALS::sunlinsoldense_shared" for configuration "Release"
set_property(TARGET SUNDIALS::sunlinsoldense_shared APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(SUNDIALS::sunlinsoldense_shared PROPERTIES
  IMPORTED_IMPLIB_RELEASE "${_IMPORT_PREFIX}/lib/libsundials_sunlinsoldense.dll.a"
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/libsundials_sunlinsoldense.dll"
  )

list(APPEND _IMPORT_CHECK_TARGETS SUNDIALS::sunlinsoldense_shared )
list(APPEND _IMPORT_CHECK_FILES_FOR_SUNDIALS::sunlinsoldense_shared "${_IMPORT_PREFIX}/lib/libsundials_sunlinsoldense.dll.a" "${_IMPORT_PREFIX}/lib/libsundials_sunlinsoldense.dll" )

# Import target "SUNDIALS::sunlinsolpcg_shared" for configuration "Release"
set_property(TARGET SUNDIALS::sunlinsolpcg_shared APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(SUNDIALS::sunlinsolpcg_shared PROPERTIES
  IMPORTED_IMPLIB_RELEASE "${_IMPORT_PREFIX}/lib/libsundials_sunlinsolpcg.dll.a"
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/libsundials_sunlinsolpcg.dll"
  )

list(APPEND _IMPORT_CHECK_TARGETS SUNDIALS::sunlinsolpcg_shared )
list(APPEND _IMPORT_CHECK_FILES_FOR_SUNDIALS::sunlinsolpcg_shared "${_IMPORT_PREFIX}/lib/libsundials_sunlinsolpcg.dll.a" "${_IMPORT_PREFIX}/lib/libsundials_sunlinsolpcg.dll" )

# Import target "SUNDIALS::sunlinsolspbcgs_shared" for configuration "Release"
set_property(TARGET SUNDIALS::sunlinsolspbcgs_shared APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(SUNDIALS::sunlinsolspbcgs_shared PROPERTIES
  IMPORTED_IMPLIB_RELEASE "${_IMPORT_PREFIX}/lib/libsundials_sunlinsolspbcgs.dll.a"
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/libsundials_sunlinsolspbcgs.dll"
  )

list(APPEND _IMPORT_CHECK_TARGETS SUNDIALS::sunlinsolspbcgs_shared )
list(APPEND _IMPORT_CHECK_FILES_FOR_SUNDIALS::sunlinsolspbcgs_shared "${_IMPORT_PREFIX}/lib/libsundials_sunlinsolspbcgs.dll.a" "${_IMPORT_PREFIX}/lib/libsundials_sunlinsolspbcgs.dll" )

# Import target "SUNDIALS::sunlinsolspfgmr_shared" for configuration "Release"
set_property(TARGET SUNDIALS::sunlinsolspfgmr_shared APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(SUNDIALS::sunlinsolspfgmr_shared PROPERTIES
  IMPORTED_IMPLIB_RELEASE "${_IMPORT_PREFIX}/lib/libsundials_sunlinsolspfgmr.dll.a"
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/libsundials_sunlinsolspfgmr.dll"
  )

list(APPEND _IMPORT_CHECK_TARGETS SUNDIALS::sunlinsolspfgmr_shared )
list(APPEND _IMPORT_CHECK_FILES_FOR_SUNDIALS::sunlinsolspfgmr_shared "${_IMPORT_PREFIX}/lib/libsundials_sunlinsolspfgmr.dll.a" "${_IMPORT_PREFIX}/lib/libsundials_sunlinsolspfgmr.dll" )

# Import target "SUNDIALS::sunlinsolspgmr_shared" for configuration "Release"
set_property(TARGET SUNDIALS::sunlinsolspgmr_shared APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(SUNDIALS::sunlinsolspgmr_shared PROPERTIES
  IMPORTED_IMPLIB_RELEASE "${_IMPORT_PREFIX}/lib/libsundials_sunlinsolspgmr.dll.a"
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/libsundials_sunlinsolspgmr.dll"
  )

list(APPEND _IMPORT_CHECK_TARGETS SUNDIALS::sunlinsolspgmr_shared )
list(APPEND _IMPORT_CHECK_FILES_FOR_SUNDIALS::sunlinsolspgmr_shared "${_IMPORT_PREFIX}/lib/libsundials_sunlinsolspgmr.dll.a" "${_IMPORT_PREFIX}/lib/libsundials_sunlinsolspgmr.dll" )

# Import target "SUNDIALS::sunlinsolsptfqmr_shared" for configuration "Release"
set_property(TARGET SUNDIALS::sunlinsolsptfqmr_shared APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(SUNDIALS::sunlinsolsptfqmr_shared PROPERTIES
  IMPORTED_IMPLIB_RELEASE "${_IMPORT_PREFIX}/lib/libsundials_sunlinsolsptfqmr.dll.a"
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/libsundials_sunlinsolsptfqmr.dll"
  )

list(APPEND _IMPORT_CHECK_TARGETS SUNDIALS::sunlinsolsptfqmr_shared )
list(APPEND _IMPORT_CHECK_FILES_FOR_SUNDIALS::sunlinsolsptfqmr_shared "${_IMPORT_PREFIX}/lib/libsundials_sunlinsolsptfqmr.dll.a" "${_IMPORT_PREFIX}/lib/libsundials_sunlinsolsptfqmr.dll" )

# Import target "SUNDIALS::sunlinsolklu_shared" for configuration "Release"
set_property(TARGET SUNDIALS::sunlinsolklu_shared APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(SUNDIALS::sunlinsolklu_shared PROPERTIES
  IMPORTED_IMPLIB_RELEASE "${_IMPORT_PREFIX}/lib/libsundials_sunlinsolklu.dll.a"
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/libsundials_sunlinsolklu.dll"
  )

list(APPEND _IMPORT_CHECK_TARGETS SUNDIALS::sunlinsolklu_shared )
list(APPEND _IMPORT_CHECK_FILES_FOR_SUNDIALS::sunlinsolklu_shared "${_IMPORT_PREFIX}/lib/libsundials_sunlinsolklu.dll.a" "${_IMPORT_PREFIX}/lib/libsundials_sunlinsolklu.dll" )

# Import target "SUNDIALS::sunnonlinsolnewton_shared" for configuration "Release"
set_property(TARGET SUNDIALS::sunnonlinsolnewton_shared APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(SUNDIALS::sunnonlinsolnewton_shared PROPERTIES
  IMPORTED_IMPLIB_RELEASE "${_IMPORT_PREFIX}/lib/libsundials_sunnonlinsolnewton.dll.a"
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/libsundials_sunnonlinsolnewton.dll"
  )

list(APPEND _IMPORT_CHECK_TARGETS SUNDIALS::sunnonlinsolnewton_shared )
list(APPEND _IMPORT_CHECK_FILES_FOR_SUNDIALS::sunnonlinsolnewton_shared "${_IMPORT_PREFIX}/lib/libsundials_sunnonlinsolnewton.dll.a" "${_IMPORT_PREFIX}/lib/libsundials_sunnonlinsolnewton.dll" )

# Import target "SUNDIALS::sunnonlinsolfixedpoint_shared" for configuration "Release"
set_property(TARGET SUNDIALS::sunnonlinsolfixedpoint_shared APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(SUNDIALS::sunnonlinsolfixedpoint_shared PROPERTIES
  IMPORTED_IMPLIB_RELEASE "${_IMPORT_PREFIX}/lib/libsundials_sunnonlinsolfixedpoint.dll.a"
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/libsundials_sunnonlinsolfixedpoint.dll"
  )

list(APPEND _IMPORT_CHECK_TARGETS SUNDIALS::sunnonlinsolfixedpoint_shared )
list(APPEND _IMPORT_CHECK_FILES_FOR_SUNDIALS::sunnonlinsolfixedpoint_shared "${_IMPORT_PREFIX}/lib/libsundials_sunnonlinsolfixedpoint.dll.a" "${_IMPORT_PREFIX}/lib/libsundials_sunnonlinsolfixedpoint.dll" )

# Import target "SUNDIALS::ida_shared" for configuration "Release"
set_property(TARGET SUNDIALS::ida_shared APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(SUNDIALS::ida_shared PROPERTIES
  IMPORTED_IMPLIB_RELEASE "${_IMPORT_PREFIX}/lib/libsundials_ida.dll.a"
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/libsundials_ida.dll"
  )

list(APPEND _IMPORT_CHECK_TARGETS SUNDIALS::ida_shared )
list(APPEND _IMPORT_CHECK_FILES_FOR_SUNDIALS::ida_shared "${_IMPORT_PREFIX}/lib/libsundials_ida.dll.a" "${_IMPORT_PREFIX}/lib/libsundials_ida.dll" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
