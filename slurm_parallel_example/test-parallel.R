#---------------------------------------------
#         Basic Parallel Example
#---------------------------------------------
#Intro details 
#########MUST CHECK###########
setwd("~/misc/slurm/better-par/") 
test.run = F #Set to true when running manually

#Packages
library(parallel)
library(tidyverse)

#A simple iterator function for saving
source("counter.R")

#---------------------------------------------
#              Simulation Details
#---------------------------------------------
#We are examining the CLT for regressions.
#We will simulate simple linear regressions with 
#many sample sizes. Then we will evaluate 
#coefficient estimates

# Setting the true coefficient
beta = 2

# Function which will take a sample size, simulate data,
# run a regression, and return the estimated coefficients
regsim = function(n) {
  x = rnorm(n)
  y = rnorm(n) + beta*x
  mod = lm(y~x)
  coef(mod)
}

# Vector of sample sizes we wish to test
sample.sizes = 2^(0:5)*100

#Building a vector with each sample size 
#repeated many times, to lapply over.
nreps = lapply(sample.sizes,rep,times=4000)
nreps = unlist(nreps) #converting to vector


#---------------------------------------------
#              Parallel Details
#---------------------------------------------
# If running manually, sets number of cores using the
# builtin function detectCores().
# If running on grid, will automatically detect the 
# assigned number of cores.
if (test.run) {
  ncores = max(detectCores()-2,1)
  } else {
  ncores = as.numeric(Sys.getenv("SLURM_JOB_CPUS_PER_NODE"))
}
print(ncores)
if (ncores == 1) warning("There is no point in parallelizing, only 1 core is available.")


#Make a cluster
cl = makeCluster(ncores)

#Send the function (and any needed data) to the cluster.
#   Broadly, functions in packages which were already 
#   loaded when you made the cluster will be available
#   on the cluster nodes. But anything you've created will
#   not be. The exception is the vector you lapply over.
clusterExport(cl,c("regsim","beta"))

# Run the code:
# Using the cluster, lapply the function to the vector nreps
output = parLapplyLB(cl,nreps,regsim)
# parLapply is the standard function here, but parLapplyLB
# is useful when some of the parallel iterations may take
# much different amounts of time. For instance here -- where
# sample sizes vary widely. There is some fixed cost
# to allowing that optimization though.

#Kill the cluster. 
stopCluster(cl)

# Simplify the output from a list to a matrix
out = sapply(output,function(x)x)
# transpose and combine with nreps
df = cbind(nreps,t(out))
# convert to tibble
df = as_tibble(df)

# Get Oracle Standard Errors for slope and intercept
dfs = df %>% group_by(nreps) %>% summarize(sdx = mean((x-beta)^2), sdi = mean(`(Intercept)`^2))

#round & print
print(round(dfs,4))

#Saving
# This could be done by running just find.counter, 
# filename, and save lines.
# 
# However, it may create race conditions between cores. 
# The repeat loop, random sleep timer, and existence check
# alleviate, but don't solve, this issue. 
repeat {
  counter = find.counter()
  filename = paste0("temp/dfs",counter,".RData")
  Sys.sleep(runif(1))
  if (!file.exists(filename)) {
    save(dfs,file=filename)
    break
  }
}
