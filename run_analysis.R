#Load required libraries
library(dplyr)

#Read test data to workspace
Subject_Test <- read.table("./test/subject_test.txt")
x_Test <- read.table("./test/X_test.txt")
y_Test <- read.table("./test/y_test.txt")

#Read training data to workspace
Subject_Train <- read.table("./train/subject_train.txt")
x_Train <- read.table("./train/X_train.txt")
y_Train <- read.table("./train/y_train.txt")

#Read activity labels and features to workspace
Activity_labels <- read.table("activity_labels.txt")
Features <- read.table("features.txt")

#Combine test and training sets
x_Total <- rbind(x_Test, x_Train)

#Rename all variables with Features data
names(x_Total) <- Features$V2 

#Combine subjects and activities to total (test and training) datasets
names(Subject_Test) <- "Subject" #rename column name in Subject_Test
names(Subject_Train) <- "Subject" #rename column name in Subject_Train
x_Total <- cbind(x_Total, rbind(Subject_Test, Subject_Train)) #Add subjects to x_Total as new column
names(y_Test) <- "ActivityNo" #rename column name in y_Test
names(y_Train) <- "ActivityNo" #rename column name in y_Train
x_Total <- cbind(x_Total, rbind(y_Test, y_Train)) #Add activities to x_Total as new column
x_Total <- merge(x_Total, Activity_labels, by.x = "ActivityNo", by.y = "V1") #add  descriptive activity names in x_Total

#Extract measurements relating to mean and standard deviation 
measures <- grep("mean()", names(x_Total)) #finds all measures with "mean()" in column name
measures <- c(measures, grep("std()", names(x_Total))) #finds all measures with "std()" in column name
remove <- grep("meanFreq", names(x_Total)) #finds all measures with "meanFreq" in column name
measures <- measures[! measures %in% remove] #removes measures with "meanFreq" in name
measures <- sort(measures) #sorts measures in ascending order
measures <- c(measures, 563, 564) #adds subject and activitylabel columns to measures to keep in final extract 
x_Extract <- x_Total[, measures] #creates x_Extract, selecting only "mean" and "std" variables and subject and ActivityLabel
x_Extract <- rename(x_Extract, ActivityLabel = V2) #rename V2 to "ActivityLabel

# make feature names more readble
names(x_Extract) <- gsub("Acc", "-Acceleration", names(x_Extract))
names(x_Extract) <- gsub("Mag", "-Magnitude", names(x_Extract))

#Creates a second, independent tidy data set with the average of each variable for each activity and each subject.
x_Summary <- x_Extract %>% 
        group_by(ActivityLabel, Subject) %>%
        summarise_each(funs(mean))
write.table(x_Summary, file = "x_Summary.txt", row.names = FALSE)
