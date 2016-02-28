# Load packages for use

install.packages ("reshape2")
library(reshape2)

# Save filename for efficiency and correctness
file <- "dataset.zip"

# Check if file already exists. If not, downloads file. 
if (!file.exists(file)) {
  fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(fileUrl,file, method = "curl")
}

#
  
  
  
  
  
  els <- read.table("UCI HAR Dataset/activity_labels.txt")
activity_labels[,2] <- 
