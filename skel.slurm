#!/bin/bash

###
# Note: slurm cannot see environment or shell variables. You
# must type in the values you need. You can use them in the 
# `sbatch` line you type in because slurm has not started running
# just yet.
###

#SBATCH --time=0:01:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
# #SBATCH --mem=2gb
#SBATCH --mail-type=ALL
#SBATCH --mail-user=gflanagi@richmond.edu
#SBATCH --account=
#SBATCH --partition=

#SBATCH -o output-%j.out
#SBATCH -e errors-%j.err

# Environment setup

NAME=

DATADIR=

SCRATCH=/scratch/gflanagi

# Always a good idea to wipe anything from memory where it
# is allocated.
module purge

# Scratch setup; make sure it is there

mkdir -p $SCRATCH
# Copy data to scratch

# Run your job

# Copy output from scratch to local
 
# cleanup

rm -rf $SCRATCH
