#---------------------------------------------
#             Summarizing output
#---------------------------------------------
# 1. find number of data files
# 2. find dimensions of data
# 3. load all data into one array
# 4. take means of the array
# 5. Save this output.
# 6. Transform for plotting
# 7. Plot
# 8. Save plot.
# 9. Clean up all files. (change CLEANUP to FALSE to stop)

# Setup
setwd("~/misc/slurm/better-par")
library(tidyverse)
source("counter.R")
cleanup = T

#Find counter value
counter = find.counter(increment = F)

# Load an example df to get dimensions
load("temp/dfs1.RData")
# Use to initialize array
output = array(NA,dim=c(dim(dfs),counter))

# Save every df to array
for (i in 1:counter) {
  filename = paste0("temp/dfs",i,".RData")
  load(filename)
  output[,,i] = as.matrix(dfs)
}


# simplify array by taking means across simulations
out = apply(output,c(1,2),mean)
# return colnames
colnames(out) = colnames(dfs)

#Convert to better form
out = as_tibble(out)
out = out %>% mutate(sdx = sqrt(sdx),sdi = sqrt(sdi))
# Create columns normalized by sqrt(n), the predicted rate
# of convergence
out = out %>% mutate(sdxn = sqrt(nreps)*sdx, sdin = sqrt(nreps)*sdi)
#Save.
save(out,file="output.RData")

# Graph outcomes
out2 = out %>% mutate(sdxn = sdxn/10, sdin=sdin/10)
out2 = gather(out2,'Var','value','sdx','sdi','sdxn','sdin')
out2 = out2 %>% mutate(Normalized = Var %in% c("sdxn","sdin"))
p  = ggplot(out2,aes(x=nreps,y=value,color = Var,linetype=Normalized))+geom_line()+geom_point()+labs(subtitle="Dashed lines are normalized by Sqrt(n)",x="Sample Size",y="Standard Error")
p

png("output.png",height=400,width=600)
p
dev.off()

#Cleaning up filesystem
if (cleanup) {
  # Remove data files
  for (i in 1:counter) 
    file.remove(paste0("temp/dfs",i,".RData"))
  # Remove counter
  find.counter(reset = T)
  # Remove logs
  if (dir.exists("temp/log/"))
    for (file in list.files("temp/log/")) file.remove(paste0("temp/log/",file))
}


