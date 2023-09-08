#!/bin/bash

cd $SRC_DIR/src
make clean

if [[ "$CONDA_BUILD_CROSS_COMPILATION" == "1" ]]; then
  # This is only used by open-mpi's mpicc
  # ignored in other cases
  export OMPI_CC=$CC
  export OMPI_CXX=$CXX
  export OMPI_FC=$FC
  export OPAL_PREFIX=$PREFIX
  
  export CFLAGS="$CFLAGS -fno-lto -Wl,-fno-lto"
  export CPPFLAGS="$CPPFLAGS -fno-lto -Wl,-fno-lto"
fi

# OSX specific: do not link against librt
if ! [ -z "$OSX_ARCH" ]
then
    sed -i 's/^\s*LDLIBS\s*=\s*-lrt\s*$/LDLIBS = /' makefile
fi

make USE_MKL=0 USE_SCALAPACK=1 USE_FFTW=1

echo "Installing sparc into $PREFIX/bin"
cp $SRC_DIR/lib/sparc $PREFIX/bin

echo "Moving sparc psp into $PREFIX/share/sparc/psps"
mkdir -p $PREFIX/share/sparc/psps
cp $SRC_DIR/psps/* $PREFIX/share/sparc/psps/
mkdir -p $PREFIX/doc/sparc
cp -r $SRC_DIR/doc/ $PREFIX/doc/sparc/
echo "Finish compiling sparc!"

# Copy activate and deactivate scripts
mkdir -p $PREFIX/etc/conda/activate.d/
mkdir -p $PREFIX/etc/conda/deactivate.d/
cp $RECIPE_DIR/activate.sh $PREFIX/etc/conda/activate.d/activate-sparc.sh
cp $RECIPE_DIR/deactivate.sh $PREFIX/etc/conda/deactivate.d/deactivate-sparc.sh
echo "Finish setting up activate / deactivate scripts"
