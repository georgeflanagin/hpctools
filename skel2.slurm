#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=2gb
#SBATCH -t 20
#SBATCH --mail-type=ALL
#SBATCH --mail-user=gflanagi@richmond.edu
#SBATCH -p small
#SBATCH -o %j.out
#SBATCH -e %j.err
srun hostname
srun echo ${SLURM_JOBID}
 
