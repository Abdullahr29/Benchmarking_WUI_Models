#!/bin/bash

#SBATCH --job-name=WRF_ideal_fire
#SBATCH --partition=cpu
#SBATCH --nodes=1
#SBATCH --ntasks=16


mpirun -np 16 ./wrf
