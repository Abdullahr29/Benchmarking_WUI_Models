#!/bin/bash
# load_elmfire.sh
# This script sets up the environment for running Elmfire

# Step 0: Checks and variable setup
if [ "$0" = "$BASH_SOURCE" ]; then
    echo "Error: This script must be sourced, not executed. Use 'source $0' instead."
    exit 1
fi

SCRIPT_DIR=$(dirname "$(realpath "${BASH_SOURCE[0]}")")
ENV_NAME="elmfire_env"
ENV_FILE="$SCRIPT_DIR/environment.yml"

# Step 1: Load required HPC modules
module load gcc
module load openmpi/4.1.6-gcc-13.2.0-flex-2.6.4-python-3.11.6
module load python

# Step 2: Set environment variables dynamically
export ELMFIRE_SCRATCH_BASE=/scratch_tmp/users/k24109631/elmfire
export ELMFIRE_BASE_DIR="$SCRIPT_DIR/elmfire"
export ELMFIRE_INSTALL_DIR="$ELMFIRE_BASE_DIR/build/linux/bin"
export CLOUDFIRE_SERVER=172.92.17.198
export OMPI_CC=/usr/bin/gcc
export OMPI_CXX=/usr/bin/g++
export OMPI_FC=/usr/bin/gfortran
export PATH=$PATH:$ELMFIRE_INSTALL_DIR:$ELMFIRE_BASE_DIR/cloudfire
export PATH=/usr/bin:$PATH

echo "Environment variables for Elmfire set successfully."

# Step 3: Check active Conda environment
if [ -n "$CONDA_DEFAULT_ENV" ]; then
	if [ "$CONDA_DEFAULT_ENV" == "$ENV_NAME" ]; then
		echo "Conda environment already loaded"
		return 1
	else
		echo "Deactivating current Conda environment: $CONDA_DEFAULT_ENV"
  		conda deactivate
	fi
else
  echo "No active Conda environment to deactivate."
fi

# Step 4: Initialize Conda
if [ -f ~/miniconda3/etc/profile.d/conda.sh ]; then 
	source ~/miniconda3/etc/profile.d/conda.sh
else
  	echo "Conda not found! Please install Miniconda3 in your home directory."
  	return 1
fi

# Step 5: Check if the Elmfire environment exists, and create it if not
if ! conda env list | grep -q "^$ENV_NAME"; then
  	echo "Environment $ENV_NAME does not exist. Creating it now..."
  	conda env create -f $ENV_FILE
else
  	echo "Environment $ENV_NAME already exists."
fi

# Step 6: Activate the Elmfire environment
conda activate $ENV_NAME

# Step 7: Verify Activation and Print Success Message
if [ "$CONDA_DEFAULT_ENV" == "$ENV_NAME" ]; then
  	echo "Elmfire environment loaded and ready!"
else
  	echo "Error: Failed to activate Elmfire environment."
  return 1
fi
