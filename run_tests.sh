#!/bin/bash

#-----------------------------------------------------------------------------#
# Get local IP address if not given as arg
#-----------------------------------------------------------------------------#

if [[ "$#" < 1 ]]; then
    LOCAL_IP=$(ifconfig | grep -A 1 eth0 | grep inet | awk '{print $2}')
else
    LOCAL_IP=$1
fi

#-----------------------------------------------------------------------------#
# Establish ssh keypair for container use
#-----------------------------------------------------------------------------#

cd .ssh

if [ ! -f id_rsa ]; then
    ssh-keygen -N "" -f id_rsa
    mv id_rsa.pub authorized_keys
    chmod 600 *
fi

#-----------------------------------------------------------------------------#
# Configure SSH communication
#-----------------------------------------------------------------------------#

# Want seamless communication without prompts
printf "Host *\n    StrictHostKeyChecking no" > config

# Anticipated container names
CTNR_A=mpich_petsc_test_host-a_1
CTNR_B=mpich_petsc_test_host-b_1

# Get host names for config file
HOST_A=$(docker exec -ti $CTNR_A /bin/bash -c 'echo $HOSTNAME' | tr -d '[:space:]')
HOST_B=$(docker exec -ti $CTNR_B /bin/bash -c 'echo $HOSTNAME' | tr -d '[:space:]')

# Append to ssh config file
printf "
Host $HOST_A
    Port 2122
    HostName $LOCAL_IP
Host $HOST_B
    Port 2123
    HostName $LOCAL_IP
" >> config

# Set machine file
printf "$HOST_A:2\n$HOST_B:2" > mf.txt

#-----------------------------------------------------------------------------#
# Build and test MPICH example program
#-----------------------------------------------------------------------------#

EXEC_PFX="docker exec -ti -u dev $CTNR_A"

printf "\nRunning MPICH sample program...\n"
$EXEC_PFX mpic++ mpich_test.cpp -o mpich_test.exe
$EXEC_PFX mpiexec -n 4 -f /home/dev/.ssh/mf.txt /home/dev/data/mpich_test.exe

#-----------------------------------------------------------------------------#
# Build and test PETSc example program
#-----------------------------------------------------------------------------#

printf "\nRunning PETSc sample program...\n"
$EXEC_PFX mpic++ petsc_test.cpp -lpetsc -o petsc_test.exe
$EXEC_PFX mpiexec -n 4 -f /home/dev/.ssh/mf.txt /home/dev/data/petsc_test.exe