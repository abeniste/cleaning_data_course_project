
# This script assumes that file is located under the working directory

library(dplyr)
library(data.table)


url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, destfile="dataset.zip", method="curl")
unzip("dataset.zip")


#
# Get the full directory of all files needed and store into a variable
#
feature.file <- file.path(getwd(),"UCI HAR Dataset", "features.txt")
activity.labels.file <- file.path(getwd(),"UCI HAR Dataset", "activity_labels.txt")
x_test.file.dir <- file.path(getwd(),"UCI HAR Dataset", "test", "X_test.txt")
y_test.file.dir <- file.path(getwd(),"UCI HAR Dataset", "test", "y_test.txt")
subject.test.file.dir <- file.path(getwd(),"UCI HAR Dataset", "test", "subject_test.txt")
x_train.file.dir <- file.path(getwd(),"UCI HAR Dataset", "train", "X_train.txt")
y_train.file.dir <- file.path(getwd(),"UCI HAR Dataset", "train", "y_train.txt")
subject.train.file.dir <- file.path(getwd(),"UCI HAR Dataset", "train", "subject_train.txt")


#
# Read each file into a data frame adding a correspondent column name
#
features.df <- read.table(feature.file, header=FALSE, col.names=c("feature_id","feature_name") )
activity.labels.df <- read.table(activity.labels.file, header=FALSE, col.names=c("activity_id","activity_name"))
x_test.df <- read.table(x_test.file.dir, header=FALSE, col.names=features.df$feature_name)
x_train.df <- read.table(x_train.file.dir, header=FALSE, col.names=features.df$feature_name)
subject.test.df <- read.table(subject.test.file.dir, header=FALSE, col.names=c("subject_id"))
y_test.df <- read.table(y_test.file.dir, header=FALSE, col.names=c("activity_id"))
y_train.df <- read.table(y_train.file.dir, header=FALSE, col.names=c("activity_id"))
subject.train.df <- read.table(subject.train.file.dir, header=FALSE, col.names=c("subject_id"))

#
# Step1 1
# Merge the data set into only one data frame
#
x_merged.df <- rbind(x_test.df, x_train.df)


#
# Merege the activity y into one data frame
#
y_merged.df <- rbind(y_test.df, y_train.df)


#
# Merge the subject into one data frem
#
subject.df <- rbind(subject.test.df, subject.train.df)


#
# Step2
# Extracts only the measurements on the mean and standard from x_merged.df
#
final_features.df <- filter(features.df, grepl("mean\\(\\)",feature_name) | grepl("std\\(\\)",feature_name))
x_merged.mean.std.df <- x_merged.df[, final_features.df$feature_name]
names(x_merged.mean.std.df) = final_features.df$feature_name

#
# Step3
# Uses descriptive activity names to name the activities in the data set
#

# first add the columns activity with the data set
auxiliar.df <- cbind(y_merged.df, subject.df)
auxiliar.df <- cbind(x_merged.mean.std.df, auxiliar.df)
tidy.df <- merge(auxiliar.df, activity.labels.df, by.x="activity_id", by.y="activity_id")
tidy.df <- select(tidy.df, -(activity_id))


#
# Step4
# Appropriately labels the data set with descriptive variable names
#
names(tidy.df) <- gsub("^t", "time", names(tidy.df))
names(tidy.df) <- gsub("^f", "frequency", names(tidy.df))
names(tidy.df) <- gsub("Acc", "Accelerometer", names(tidy.df))
names(tidy.df) <- gsub("Gyro", "Gyroscope", names(tidy.df))
names(tidy.df) <- gsub("Mag", "Magnitude", names(tidy.df))
names(tidy.df) <- gsub("BodyBody", "Body", names(tidy.df))


#
# Step5
# From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject
#
clean_table <- data.table(tidy.df)
tidy_data <- clean_table[, lapply(.SD, mean), by = 'activity_name,subject_id']
tidy_data <- tidy_data[order(activity_name, subject_id)]

write.table(tidy.df, file = "final_tidy_data.txt", row.name = FALSE)