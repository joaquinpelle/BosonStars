#!/bin/bash -l

### Standard output and error:
#SBATCH -o std/out.%j
#SBATCH -e std/err.%j

### Initial working directory:
#SBATCH -D ./

### Job Name:
#SBATCH -J bosonstar

#SBATCH --partition=short

### Number of nodes and MPI tasks per node:
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=64
#
#SBATCH --mail-type=ALL
#SBATCH --mail-user=jpelle@mi.unc.edu.ar
#
# Wall clock Limit:
#SBATCH --time=1:00:00

##################################

export JULIA_NUM_THREADS=64
export SLURM_HINT=multithread 

julia main.jl
