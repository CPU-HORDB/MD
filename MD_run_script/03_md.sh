#!/bin/bash
#SBATCH -p gpu      
#SBATCH -n 1        
#SBATCH --gres=gpu:1
#SBATCH -J pep  
#SBATCH -o cuda.out 
#SBATCH -e cuda.err 
#SBATCH --constraint rtx2080
module load amber/18

nstlim=100000000
ntw=5000
ntraj=`ls traj_*md*.* | wc -l`
if [ $ntraj -eq 0 ]; then
    symbol=!
else
    symbol=
fi

cat << EOF > md.in
md script
&cntrl
${symbol}irest = 1, ntx = 5,
ntb = 0,igb = 8,
ntpr = $ntw, ntwr = $ntw, ntwx = $ntw,
ntt = 3, gamma_ln = 1.0, 
tempi = 300.0, temp0 = 300.0,
ntf = 2, ntc = 2,
nstlim = $nstlim, dt = 0.002,
cut =999.0,
/
EOF

if [ $ntraj -eq 0 ]; then
    srun --gres=gpu:1 pmemd.cuda -O -i md.in -o md1.out -p pep.top -c heat6.rst -r md1.rst -x traj_md1.nc
else
    let i=ntraj
    let j=ntraj+1
    srun --gres=gpu:1 pmemd.cuda -O -i md.in -o md${j}.out -p pep.top -c md${i}.rst -r md${j}.rst -x traj_md${j}.nc
fi
