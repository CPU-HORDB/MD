#!/bin/bash

#SBATCH -p all
#SBATCH -n 24        
#SBATCH -N 1        
#SBATCH --ntasks-per-node=24
#SBATCH -J mpi
#SBATCH -o slurm_mpi.out
#SBATCH -e slurm_mpi.err
module load amber/18

srun --mpi=pmi2 pmemd.MPI -O -i min.in -o min.out -p sys.top -c sys.crd -r min.rst -ref sys.crd

