#---------------------------------------------
#     Counter Function for Parallel Jobs
#---------------------------------------------

find.counter = function(folder="temp/",
                        file="counter.RData",
                        reset=F,increment=T) {
  #Reset Deletes Counter if T
  #Increment dictates whether value is changed.
  #Folder determines location.
  #File determines filename.
  
  #Check Folder Existence. 
  if (!dir.exists(folder)) dir.create(folder)
  #Set full path of file
  counter_path = paste0(basename(folder),"/",file)
  
  #If it exists, find it, delete/add as necessary.
  if (file.exists(counter_path)) {
    if (reset) {
      file.remove(counter_path)
      message("Counter Deleted")
      return(invisible(NULL))
    } else {
      load(counter_path)
      if (increment) counter = counter + 1
    }
  } else { #Otherwise, make a new counter. 
    message("New Counter Created")
    counter = 1
  }
  #Save and return the counter.
  save(counter,file=counter_path)
  counter                     
}
