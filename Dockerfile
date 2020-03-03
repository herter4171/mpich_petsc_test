FROM ubuntu:18.04

WORKDIR /opt

#-----------------------------------------------------------------------------#
# Install apt packages
#-----------------------------------------------------------------------------#

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y ; \
apt-get install -y \
    build-essential \
    gfortran \
    tcl \
    git \
    curl \
    python \
    cmake \
    openssh-server \
    vim \
    bison \
    flex \
    m4 \
    freeglut3 \
    doxygen \
    libblas-dev \
    liblapack-dev \
    libx11-dev \
    libnuma-dev \
    libcurl4-gnutls-dev \
    zlib1g-dev \
    libhwloc-dev \
    libxml2-dev \
    libpng-dev \
    pkg-config \
    liblzma-dev ; \
rm -rf /var/lib/apt/lists/*

#-----------------------------------------------------------------------------#
# Install mpich-3.3 to system path
#-----------------------------------------------------------------------------#
RUN curl -L -O http://www.mpich.org/static/downloads/3.3/mpich-3.3.tar.gz ; \
tar -xf mpich-3.3* ; \
cd mpich-3.3 && mkdir gcc-build && cd gcc-build ; \
# Configure build env
../configure --prefix=/usr/local \
--enable-shared \
--enable-sharedlibs=gcc \
--enable-fast=O2 \
--enable-debuginfo \
--enable-totalview \
--enable-two-level-namespace \
CC=gcc \
CXX=g++ \
FC=gfortran \
F77=gfortran \
F90='' \
CFLAGS='' \
CXXFLAGS='' \
FFLAGS='' \
FCFLAGS='' \
F90FLAGS='' \
F77FLAGS='' ; \
# Build and install
make -j $(nproc) ; \
make install ; \
# Cleanup
cd ../../ ; rm -rf mpich-3.3*

ENV CC=mpicc \
CXX=mpicxx

#-----------------------------------------------------------------------------#
# Install PETSc to system path
#-----------------------------------------------------------------------------#

RUN git clone https://gitlab.com/petsc/petsc.git ; \
cd petsc ; \
git checkout 5ea3abfa7fe8791a5f316416921daa28f47703d9 ; \
./configure --prefix=/usr/local \
      --download-hypre=1 \
      --with-debugging=no \
      --with-shared-libraries=1 \
      --download-fblaslapack=1 \
      --download-metis=1 \
      --download-ptscotch=1 \
      --download-parmetis=1 \
      --download-superlu_dist=1 \
      --download-mumps=1 \
      --download-scalapack=1 \
      --download-slepc=git://https://gitlab.com/slepc/slepc.git \
      --download-slepc-commit= 59ff81b \
      --with-mpi=1 \
      --with-cxx-dialect=C++11 \
      --with-fortran-bindings=0 \
      --with-sowing=0 ; \
make all -j $(nproc) ; \
make install

#-----------------------------------------------------------------------------#
# Add SSH capability for non-root user dev
#-----------------------------------------------------------------------------#

COPY ssh_setup.sh .
RUN /bin/bash ssh_setup.sh