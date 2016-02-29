# 1. Merge the training and the test sets to create one data set

# Save filename for efficiency and correctness
file <- "dataset.zip"

# Check if file already exists. If not, downloads file.
if (!file.exists(file)) {
  fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(fileUrl,file)
}

# Check if file has been unzipped. If not, unzips file.
if (!file.exists("UCI HAR Dataset")) {
  unzip(file)
}

# Set working directory to new dataset
setwd("./UCI HAR Dataset/")

# Read initial data 
features <- read.table('./features.txt',header=FALSE); 
activityLabels <- read.table('./activity_labels.txt',header=FALSE); 

# Read training data
subjectTrain <- read.table('./train/subject_train.txt',header=FALSE); 
xTrain <- read.table('./train/x_train.txt',header=FALSE); 
yTrain <- read.table('./train/y_train.txt',header=FALSE); 

# Assign column names to the initial and training data
colnames(activityLabels) = c('activityId','activityLabels');
colnames(subjectTrain) = "subjectId";
colnames(xTrain) = features[,2]; 
colnames(yTrain) = "activityId";

# Create final training set by merging yTrain, subjectTrain, and xTrain
trainingData <- cbind(yTrain,subjectTrain,xTrain);

# Read test data
subjectTest <- read.table('./test/subject_test.txt',header=FALSE); 
xTest <- read.table('./test/x_test.txt',header=FALSE);
yTest <- read.table('./test/y_test.txt',header=FALSE); 

# Assign column names to the test data
colnames(subjectTest) = "subjectId";
colnames(xTest) = features[,2]; 
colnames(yTest) = "activityId";


# Create final test set by merging the xTest, yTest and subjectTest data
testData <- cbind(yTest,subjectTest,xTest);


# Combine training and test data to create a final data set
finalData <- rbind(trainingData,testData);

# Create a vector for the column names from the finalData, which will be used
# to select the desired mean() & stddev() columns
colNames <- colnames(finalData); 

# 2. Extract only the measurements on the mean and standard deviation for each measurement

# Create a test that contains TRUE values for the ID, mean() & stddev() columns and FALSE for others
test <- (grepl("activity..",colNames) | grepl("subject..",colNames) | grepl("-mean..",colNames) & !grepl("-meanFreq..",colNames) & !grepl("mean..-",colNames) | grepl("-std..",colNames) & !grepl("-std()..-",colNames));

# Subset finalData table based on the logicalVector to keep only desired columns
finalData <- finalData[test==TRUE];

# 3. Use descriptive activity names to name the activities in the data set

# Merge the finalData set with the acitivityType table to include descriptive activity names
finalData <- merge(finalData,activityLabels,by='activityId',all.x=TRUE);

# Updating the colNames vector to include the new column names after merge
colNames <- colnames(finalData); 

# 4. Appropriately label the data set with descriptive activity names

# Cleaning up the variable names
for (i in 1:length(colNames)) 
{
  colNames[i] <- gsub("\\()","",colNames[i])
  colNames[i] <- gsub("-std$","StdDev",colNames[i])
  colNames[i] <- gsub("-mean","Mean",colNames[i])
  colNames[i] <- gsub("^(t)","time",colNames[i])
  colNames[i] <- gsub("^(f)","freq",colNames[i])
  colNames[i] <- gsub("([Gg]ravity)","Gravity",colNames[i])
  colNames[i] <- gsub("([Bb]ody[Bb]ody|[Bb]ody)","Body",colNames[i])
  colNames[i] <- gsub("[Gg]yro","Gyro",colNames[i])
  colNames[i] <- gsub("AccMag","AccMagnitude",colNames[i])
  colNames[i] <- gsub("([Bb]odyaccjerkmag)","BodyAccJerkMagnitude",colNames[i])
  colNames[i] <- gsub("JerkMag","JerkMagnitude",colNames[i])
  colNames[i] <- gsub("GyroMag","GyroMagnitude",colNames[i])
};

# Reassigning the new descriptive column names to the finalData set
colnames(finalData) = colNames;

# 5. Create a second, independent tidy data set with the average of each variable for each activity and each subject

# Create a new table, finalDataNoActivityLabels without the activityLabels column
finalDataNoActivityLabels <- finalData[,names(finalData) != 'activityLabels'];

# Summarizing the finalDataNoActivityLabels table to include just the mean of each variable for each activity and each subject
tidyData <- aggregate(finalDataNoActivityLabels[,names(finalDataNoActivityLabels) != c('activityId','subjectId')],by=list(activityId=finalDataNoActivityLabels$activityId,subjectId = finalDataNoActivityLabels$subjectId),mean);

# Merging the tidyData with activityLabels to include descriptive activity names
tidyData <- merge(tidyData,activityLabels,by='activityId',all.x=TRUE);

# Export the tidyData set 
write.table(tidyData, './tidyData.txt',row.names=TRUE,sep='\t')
