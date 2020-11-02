#!/bin/bash

#-------------------------------------------------------------
#params for slurm

#SBATCH --account=phd
#SBATCH --partition=standard
#SBATCH --mem-per-cpu=2G
#SBATCH --cpus-per-task=8
#SBATCH --time=0-00:30:00  # wall clock limit (d-hh:mm:ss)
#SBATCH --job-name=test-par    # user-defined job name
#SBATCH --mail-user=NULL #xxxx@chicagobooth.edu
#SBATCH --mail-type=END,FAIL   #NONE for no mail. END,FAIL for mail on completion

#---------------------------------------------------------------------------------
# Print some useful variables

echo "Job ID: $SLURM_JOB_ID"
echo "Job User: $SLURM_JOB_USER"
echo "Job Name: $SLURM_JOB_NAME"
echo "Num Cores: $SLURM_JOB_CPUS_PER_NODE"

#---------------------------------------------------------------------------------
# Load necessary modules for the job

# Load the module with the desired version of R
module load R/3.4/3.4.3

# run Rscript
R --no-save --no-restore < $1

