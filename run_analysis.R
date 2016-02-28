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

# Check if file has been unzipped. If not, unzips file.
if (!file.exists("UCI HAR Dataset")) {
  unzip(file)
}
  
# Load activity labels info 
activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt")
activity_labels[,2] <- as.character(activity_labels[,2])

# Load features info
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# Identifies mean and standard deviation info
mean_sd <- grep (".*mean.*| .*std.*", features[,2])
mean_sd.names <- features[mean_sd,2]
mean_sd.names = gsub('-mean', 'Mean', mean_sd.names)
mean_sd.names = gsub('-std', 'Std', mean_sd.names)
mean_sd.names <- gsub('[-()]', '', mean_sd.names)

# Load the datasets
train <- read.table("UCI HAR Dataset/train/X_train.txt")[mean_sd]
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[mean_sd]
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

# merge datasets and add labels
allData <- rbind(train, test)
colnames(allData) <- c("subject", "activity", mean_sd.names)

# turn activities & subjects into factors
allData$activity <- factor(allData$activity, levels = activity_labels[,1], labels = activity_labels[,2])
allData$subject <- as.factor(allData$subject)

allData.melted <- melt(allData, id = c("subject", "activity"))
allData.mean <- dcast(allData.melted, subject + activity ~ variable, mean)

write.table(allData.mean, "tidy.txt", row.names = FALSE, quote = FALSE)
