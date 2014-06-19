#Getting and Cleaning Data Course Project

# I will use the "sqldf" library to perform some data manipulation:
library("sqldf")

# Set my working directory:
setwd("~/Documents/CURSOS/Getting and Cleaning Data/UCI HAR Dataset")

# Read the activity and column labels data sets: 
activity_labels <- read.table("activity_labels.txt", col.names=c("activity_ID", "activity_name"))
column_labels <- read.table("features.txt", col.names=c("column_ID", "column_name"))

#Get rid of punctuation signs from the column labels:
head(column_labels$column_name)
column_labels$column_name <- gsub("[[:punct:]]","",column_labels$column_name)
head(column_labels$column_name)

# Find all column names wich contains the string "mean" and exclude those which contains "meanFreq":
mean_cols <- grep("mean", column_labels$column_name)
x_meanFreq <- grep("meanFreq", column_labels$column_name)
mean_cols <- setdiff(mean_cols, x_meanFreq)

# Find all column names wich contains the string "std" and union them with the columns which contains mean. Variable "all_cols" is a vector with the column number of the measurements with mean and standard deviation on the original data set:
std_cols <- grep("std", column_labels$column_name)
all_cols <- union(mean_cols, std_cols)
head(all_cols)

# Clean labels for "mean" and "std":
head(column_labels$column_name)
column_labels$column_name <- gsub("mean", "_mean_", column_labels$column_name)
column_labels$column_name <- gsub("std", "_stddev_", column_labels$column_name)
head(column_labels$column_name)

#Read files with training and test data, append appropriate column names for each data set:
activity_test <- read.table("test/y_test.txt", col.names=c("activity_ID"))
dim(activity_test)
measures_test <- read.table("test/x_test.txt", col.names=column_labels$column_name)
dim(measures_test)
subject_test <- read.table("test/subject_test.txt", col.names=c("subject_ID"))
dim(subject_test)
activity_train <- read.table("train/y_train.txt", col.names=c("activity_ID"))
dim(activity_train)
measures_train <- read.table("train/x_train.txt", col.names=column_labels$column_name)
dim(measures_train)
subject_train <- read.table("train/subject_train.txt", col.names=c("subject_ID"))
dim(subject_train)

# Subset the columns of the training and test data in order to extract only the measurements on the mean and standard deviation:
measures_test_sub <- measures_test[,all_cols]
dim(measures_test_sub)
measures_train_sub <- measures_train[,all_cols]
dim(measures_train_sub)

# Append the columns with activity_ID and subject_ID to the training and test data frames:
measures_test_act <- cbind(activity_test, measures_test_sub, subject_test)
dim(measures_test_act)
head(measures_test_act)
measures_train_act <- cbind(activity_train, measures_train_sub, subject_train)
dim(measures_train_act)
head(measures_train_act)

# Merge the training and test data variables into 1 data frame named "all_measures":
all_measures <- rbind(measures_test_act, measures_train_act)
dim(all_measures)

# Perform an SQL join to include labels for each activity_ID. The resulting data frame meets the characteristics of tidy data:
# * Each variable in one column
# * Each different observation in one row
# * A row at the top with variable names
# * Variable names are human readable
tidy_measures <- sqldf("select a.activity_name, m.* from activity_labels as a, all_measures m where a.activity_ID = m.activity_ID")
dim(tidy_measures)
head(tidy_measures[,c(1:5, 65:69)],20)
tail(tidy_measures[,c(1:5, 65:69)],20)

# Build and execute a new SQL SELECT statement to summarize the data by subject_ID and activity name:
measures_avg <- paste(", avg(", names(tidy_measures[3:68]), ")", sep="", collapse=" ")
sqlstmt <- paste("select subject_ID, activity_name", measures_avg, "from tidy_measures group by subject_id, activity_name") 
tidy_measures_avg <- sqldf(sqlstmt)
dim(tidy_measures_avg)
head(tidy_measures_avg[,c(1:5, 65:68)],10)
tail(tidy_measures_avg[,c(1:5, 65:68)],10)
write.csv(tidy_measures_avg, file("tidy_measures_avg.csv"))
 
