# mpich_petsc_test

This repository provides the necessary building blocks to demonstrate what appears to be a container-specific bug in PETSc.  The two demonstrations show that, for two running containers,
* The installation of MPICH-3.3 is valid
* PETSc errors out to a strack trace

## File descriptions
The [Dockerfile](Dockerfile) builds an image in the following sequence.
1. Install apt packages
2. Install MPICH-3.3 to system path
3. Install PETSc to system path
4. Add SSH capability

To add SSH capability, the Dockerfile involes [ssh_setup.sh](ssh_setup.sh), which accomplishes the following.
1. Set port to 2122
2. Ensure host keys populated
3. Establish non-root user `dev`

Last of all is [run_tests.sh](run_tests.sh), which does what follows.
1. Set local IP from input argument or using `ifconfig`
2. Establish a common SSH keypair for the containers
3. Builds an SSH config file for host and port routing
4. Compiles and runs the MPICH example program
5. Compiles and runs the PETSc example program

## General Use
First, launch the containers in a detached state via
```bash
docker-compose up -d
```

Next, invoke [run_tests.sh](run_tests.sh) to build and execute the test programs.
```bash
/bin/bash run_tests.sh
```