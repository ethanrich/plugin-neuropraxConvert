GENCCODE_ASSEMBLY_TYPE=-a gcc-mingw64
SO=dll
SOBJ=dll
A=a
LIBPREFIX=
LIB_EXT_ORDER=70.dll
COMPILE=x86_64-w64-mingw32-gcc -DU_USING_ICU_NAMESPACE=0   -DHAVE_DLOPEN=0 -DU_HAVE_MMAP=0 -DU_HAVE_STRTOD_L=0  -DWINVER=0x0601 -D_WIN32_WINNT=0x0601 -DU_ATTRIBUTE_DEPRECATED= -O2 -std=c11 -Wall -pedantic -Wshadow -Wpointer-arith -Wmissing-prototypes -Wwrite-strings -mthreads  -c
LIBFLAGS=-I/scratch/build/mxe-octave-w64/release/usr/x86_64-w64-mingw32/include -DPIC 
GENLIB=x86_64-w64-mingw32-gcc -O2 -std=c11 -Wall -pedantic -Wshadow -Wpointer-arith -Wmissing-prototypes -Wwrite-strings -mthreads   -shared  -Wl,--enable-auto-import -Wl,--out-implib=./liball.dll.a
LDICUDTFLAGS=
LD_SONAME=
RPATH_FLAGS=
BIR_LDFLAGS=
AR=x86_64-w64-mingw32-ar
ARFLAGS=r
RANLIB=x86_64-w64-mingw32-ranlib
INSTALL_CMD=/bin/install -c
