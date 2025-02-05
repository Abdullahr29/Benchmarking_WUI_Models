#!/bin/bash -l

#SBATCH --job-name=test-jlab
#SBATCH --partition=cpu
#SBATCH --ntasks=4
#SBATCH --signal=USR2
#SBATCH --cpus-per-task=1

# get unused socket per https://unix.stackexchange.com/a/132524
readonly IPADDRESS=$(hostname -I | tr ' ' '\n' | grep '10.211.4.')
readonly PORT=$(python -c 'import socket; s=socket.socket(); s.bind(("", 0)); print(s.getsockname()[1]); s.close()')
cat 1>&2 <<END
1. SSH tunnel from your workstation using the following command:

   ssh -NL 8888:${HOSTNAME}:${PORT} ${USER}@hpc.create.kcl.ac.uk

   ssh -m hmac-sha2-512 -NL 8888:${HOSTNAME}:${PORT} ${USER}@hpc.create.kcl.ac.uk

   and point your web browser to http://localhost:8888

When done using the notebook, terminate the job by
issuing the following command on the login node:

      scancel -f ${SLURM_JOB_ID}

END

jupyter-lab --port=${PORT} --ip=${IPADDRESS} --no-browser

printf 'notebook exited' 1>&2
