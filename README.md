# Course Project
# Getting and Cleaning Data Course


# Description

30 volunteers were divided into two groups: train and test. Each person performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a smartphone.

Tehre are 561-feature vector with time and frequency domain variables.

The script uses R language. It gets a zip file containing a set of analysis for the two groups. The script clean the data by getting only mean and standard deviation metrics among the 561 variables. It also merge the two groups test and train into only one data set.

It generates a final file call final_tidy_data.txt.

For more infornmation about this research, visit the site http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones.

# Script

First we load the library used in this script.

 * library(dplyr)
 * library(data.table)


Get the file and unzip it. The file should be in the working directory.

 * url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
 * download.file(url, destfile="dataset.zip", method="curl")
 * unzip("dataset.zip")


All files used in this script are stored in variables using the full path.
The files X_test.txt and X_train.txt contain the observation data for all 561 variables analyzed.

 * feature.file <- file.path(getwd(),"UCI HAR Dataset", "features.txt")
 * activity.labels.file <- file.path(getwd(),"UCI HAR Dataset", "activity_labels.txt")
 * x_test.file.dir <- file.path(getwd(),"UCI HAR Dataset", "test", "X_test.txt")
 * y_test.file.dir <- file.path(getwd(),"UCI HAR Dataset", "test", "y_test.txt")
 * subject.test.file.dir <- file.path(getwd(),"UCI HAR Dataset", "test", "subject_test.txt")
 * x_train.file.dir <- file.path(getwd(),"UCI HAR Dataset", "train", "X_train.txt")
 * y_train.file.dir <- file.path(getwd(),"UCI HAR Dataset", "train", "y_train.txt")
 * subject.train.file.dir <- file.path(getwd(),"UCI HAR Dataset", "train", "subject_train.txt")


Read each file in a data frame.

 * features.df <- read.table(feature.file, header=FALSE, col.names=c("feature_id","feature_name") )
 * activity.labels.df <- read.table(activity.labels.file, header=FALSE, col.names=c("activity_id","activity_name"))
 * x_test.df <- read.table(x_test.file.dir, header=FALSE, col.names=features.df$feature_name)
 * x_train.df <- read.table(x_train.file.dir, header=FALSE, col.names=features.df$feature_name)
 * subject.test.df <- read.table(subject.test.file.dir, header=FALSE, col.names=c("subject_id"))
 * y_test.df <- read.table(y_test.file.dir, header=FALSE, col.names=c("activity_id"))
 * y_train.df <- read.table(y_train.file.dir, header=FALSE, col.names=c("activity_id"))
 * subject.train.df <- read.table(subject.train.file.dir, header=FALSE, col.names=c("subject_id"))


Merge the data set into only one data frame.

 * x_merged.df <- rbind(x_test.df, x_train.df)
 * y_merged.df <- rbind(y_test.df, y_train.df)
 * subject.df <- rbind(subject.test.df, subject.train.df)


The study used 561 variables. We just need the the variables that contains mean() and std() pattern. So, we have to clean the data set and extracts only the measurements required. the final data frame x_merged.mean.std.df contains only 66 variables.

 * final_features.df <- filter(features.df, grepl("mean\\(\\)",feature_name) | grepl("std\\(\\)",feature_name))
 * x_merged.mean.std.df <- x_merged.df[, final_features.df$feature_name]
 * names(x_merged.mean.std.df) = final_features.df$feature_name


The data set used ontly IDs for the activity. So we have to join the data set against the data frame activity.labels.df to get the descriptions. Once we have it, we can discard the activity_id.

* auxiliar.df <- cbind(y_merged.df, subject.df)
* auxiliar.df <- cbind(x_merged.mean.std.df, auxiliar.df)
* tidy.df <- merge(auxiliar.df, activity.labels.df, by.x="activity_id", by.y="activity_id")
* tidy.df <- select(tidy.df, -(activity_id))


Appropriately labels the data set with descriptive variable names.

 * names(tidy.df) <- gsub("^t", "time", names(tidy.df))
 * names(tidy.df) <- gsub("^f", "frequency", names(tidy.df))
 * names(tidy.df) <- gsub("Acc", "Accelerometer", names(tidy.df))
 * names(tidy.df) <- gsub("Gyro", "Gyroscope", names(tidy.df))
 * names(tidy.df) <- gsub("Mag", "Magnitude", names(tidy.df))
 * names(tidy.df) <- gsub("BodyBody", "Body", names(tidy.df))


Group the data frame by activity and subject and then order the result set by activity and subject.

* clean_table <- data.table(tidy.df)
* tidy_data <- clean_table[, lapply(.SD, mean), by = 'activity_name,subject_id']
* tidy_data <- tidy_data[order(activity_name, subject_id)]


Generate the final file with the result set.

* write.tabl/e(tidy.df, file = "final_tidy_data.txt", row.names = FALSE)