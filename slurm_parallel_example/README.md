# Parallel Example for Slurm

This directory demonstrates parallelizing R code across and within jobs on slurm (as setup on Booth's Mercury cluster). The demo runs tests of the CLT for a regression. 

## Quick Description of actual process
Base code run parallelizes the script "test-parallel.R" across slurm jobs, while that script also (politely) parallelizes within each job using only resources provided by the scheduler (/requested by you).
The file "recombine-test.R" then takes all the outputs, combines them, saves them to "output.RData", and graphs the outcomes. Along the way it deletes the files storing those outputs and the log files. 


## PRE-RUN CHECKLIST
1. make sure directory temp/log/ exists
2. check working directory locations that are set in
  1. recombine-test.R
  2. test-parallel.R
3. For single test/example runs, change "test.run" in test-parallel.R to TRUE. Then run only that file.
4. Details in slurm.sh should be changed to accomodate time, memory, or other needs. (e.g. faculty vs phd, time limits, etc.)
5. After running test-parallel as often as needed, run recombine-test once. 

## RUNTIME BASH CODE
### To run 50 times
sbatch --array=1-50 slurm.sh test-parallel.R

### To put logs elsewhere (requires temp/ directory):
sbatch -o "temp/slurm-%j.out" slurm.sh test-parallel.R

### To put logs elsewhere and run 50 times: (requires directory temp/log)
sbatch --array=1-50 -o "temp/log/slurm-%A_%a.out" slurm.sh test-parallel.R

### On completion of all prior code (or inside R/Rstudio etc):
sbatch -o "temp/log/slurm-%j.out" slurm.sh recombine-test.R


## FILE Descriptions
### Initial Files
- counter.R: simple file with a function for a counter which (tries fairly successfully to prevent) overwriting outputs for different slurm jobs
- README.md: this file.
- recombine-test.R: code taking outputs of all jobs (stored in temp folder), and summarizing/plotting it.
- slurm.sh: Basic configuration details for the scheduler (number of cores, email on completion, account permissions, etc)
- test-parallel.R: code running simulations looking at convergence to normal distribution
- /temp/: (mostly) empty directory for temporary files
  - /temp/log/: (mostly) empty directory for log files
      - /temp/log/folder_init: empty file opening two directories on github.

### Generated files
- /temp/counter.RData: an RData file holding the value of the counter tracking save names.
- /temp/dfs[INT].RData: numbered files saving output from one slurm job
- /temp/log/slurm-[INT]_[INT].out: log files holding logs from a slurm array process.
- /output.RData: final output data.


