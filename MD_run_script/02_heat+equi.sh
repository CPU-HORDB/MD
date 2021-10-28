#!/bin/bash

#SBATCH -p all
#SBATCH -n 24        
#SBATCH -N 1        
#SBATCH --ntasks-per-node=24
#SBATCH -J mpi
#SBATCH -o slurm_mpi.out
#SBATCH -e slurm_mpi.err
module load amber/18


nres=20
for i in `seq 6`
do
  let ti=(i-1)*50
  let to=i*50
  
  if [ $to -eq 300 ]; then
    nstlim=100000
  else
    nstlim=20000
  fi
  
  if [ $i -eq 1 ]; then
    symbol=!
  else
    symbol=
  fi
  
  cat > heat$i.in << eof 
Heating from $ti to $to
&cntrl
${symbol}irest=1,ntx=5,
nstlim=$nstlim,dt=0.001,
ntc=2,ntf=2,
ntt=3,gamma_ln=1,
tempi=$ti,temp0=$to,
ntb=0,igb=8,
ntpr=100,ntwr=100,ntwx=100,
cut=999,ntr=1,restraint_wt=10,
restraintmask=':1-$nres'
/
eof
  let j=i-1
  if [ $i -eq 1 ]; then
    srun --mpi=pmi2 pmemd.MPI -O -i heat$i.in -o heat$i.out -p pep.top -c min.rst -r heat$i.rst -x traj_heat$i.nc  -inf md.info -ref min.rst
  else
    srun --mpi=pmi2 pmemd.MPI -O -i heat$i.in -o heat$i.out -p pep.top -c heat$j.rst -r heat$i.rst -x traj_heat$i.nc  -inf md.info -ref heat$j.rst
  fi
done
