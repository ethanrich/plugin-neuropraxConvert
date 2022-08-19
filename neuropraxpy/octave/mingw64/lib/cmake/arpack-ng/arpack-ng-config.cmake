# Config file for the arpack-ng package.
#
# To use arpack from CMake, use ARPACK::ARPACK target:
#   find_package(arpack-ng)
#   add_executable(main main.f)
#   target_include_directories(main PRIVATE ARPACK::ARPACK)
#   target_link_libraries(main ARPACK::ARPACK)
#
# To use parpack from CMake, use PARPACK::PARPACK target:
#   find_package(arpack-ng)
#   add_executable(main main.f)
#   target_link_libraries(main PARPACK::PARPACK)

# Create local variables.
set(prefix "/scratch/build/mxe-octave-w64/release/usr/x86_64-w64-mingw32")
set(exec_prefix "${prefix}")
set(libdir "${exec_prefix}/lib")
set(includedir "${prefix}/include")

# Create arpack targets.
add_library(ARPACK::ARPACK INTERFACE IMPORTED)
set_target_properties(ARPACK::ARPACK PROPERTIES INTERFACE_INCLUDE_DIRECTORIES "${includedir}/arpack")
set_target_properties(ARPACK::ARPACK PROPERTIES INTERFACE_LINK_LIBRARIES      "arpack")
add_library(PARPACK::PARPACK INTERFACE IMPORTED)
set_target_properties(PARPACK::PARPACK PROPERTIES INTERFACE_LINK_LIBRARIES    "parpack")
