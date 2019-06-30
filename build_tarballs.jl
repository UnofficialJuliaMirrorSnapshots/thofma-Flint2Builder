# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "libflint"
version = v"0.0.0-147d31930ac570d3b5e920f164bc65389999f1c3"

# Collection of sources required to build libflint
sources = [
    "https://github.com/wbhart/flint2.git" =>
    "147d31930ac570d3b5e920f164bc65389999f1c3",

]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir
cd flint2/

# If we're compiling for Windows, then disable things
if [[ ${target} == *mingw* ]]; then
    ./configure --prefix=$prefix --disable-static --enable-shared --reentrant --with-gmp=$prefix --with-mpfr=$prefix
else
    ./configure --prefix=$prefix --disable-static --enable-shared --with-gmp=$prefix --with-mpfr=$prefix
fi

make -j${nproc}
make install

"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    Windows(:x86_64),
    MacOS(:x86_64),
    Linux(:x86_64, libc=:glibc)
]

# The products that we will ensure are always built
products(prefix) = [
    LibraryProduct(prefix, "libflint", Symbol("libflint insta\x01\e[A\x01\e[B\e[B"))
]

# Dependencies that must be installed before this package can be built
dependencies = [
    "https://github.com/JuliaMath/GMPBuilder/releases/download/v6.1.2-2/build_GMP.v6.1.2.jl",
    "https://github.com/JuliaMath/MPFRBuilder/releases/download/v4.0.1-3/build_MPFR.v4.0.1.jl"
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)

