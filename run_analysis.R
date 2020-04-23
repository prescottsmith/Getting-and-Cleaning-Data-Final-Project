library(tidyverse)
# setting the working directory for importing files
setwd("~/Documents/Coding/R/Johns Hopkins Coursera/C3 - Getting and Cleaning Data/Final Project/Getting and Cleaning Data - Course Project/Data")


# importing relevant data
testlabels <- read.delim("y_test.txt", header = FALSE)
testdata <- read.delim("X_test.txt", header = FALSE, stringsAsFactors = FALSE)
trainlabels <- read.delim("y_train.txt", header = FALSE)
traindata <- read.delim("X_train.txt", header = FALSE, stringsAsFactors = FALSE)
subject_test <- read.delim("subject_test.txt", header = FALSE)
subject_train <- read.delim("subject_train.txt", header = FALSE)
features <- read.delim("features.txt", stringsAsFactors = FALSE, header = FALSE)


# merging the test and training data
mergedlabels <- rbind(trainlabels, testlabels)
mergeddata <- rbind(traindata, testdata)
mergedsubjects <- rbind(subject_train, subject_test)


# naming the labels and subjects columns for later merging
colnames(mergedsubjects) <- "Subject"
colnames(mergedlabels) <- "Activity"


# converting the features list into a vector to be used as column names
featuresvector <- unlist(features[,1])


# preparing the set data to be parsed into columns by making the separation 
# between values uniform across each row
mergeddata[c(1:10299),] <- sub("^[ ]|^[ ][ ]", "", x = mergeddata[c(1:10299),])
mergeddata[c(1:10299),] <- gsub("  ", " ", x = mergeddata[c(1:10299),])



# separating data set values into different columns
ParsedData <- separate(mergeddata, V1, into = featuresvector, sep = " ")


# making data columns numeric
ParsedData[,c(1:561)] <- sapply(ParsedData[,c(1:561)], as.numeric)


# selecting just the mean and std columns
ParsedData <- ParsedData[ , grepl("[m][e][a][n]|[s][t][d]" , names(ParsedData) ) ]


# merging the subject and activity labels with the parsed data
finaldf <- cbind (mergedsubjects, mergedlabels, ParsedData)


# setting subject and activity as factors, and assigning activity factor labels
finaldf$Subject <- as.factor(finaldf$Subject)
finaldf$Activity <- factor(finaldf$Activity, labels = c("WALKING", "WALKING UPSTAIRS","WALKING DOWNSTAIRS", "SITTING", "STANDING", "LAYING"))


# cleaning up column names
colnames(finaldf) <- gsub("^[0-9]|^[0-9][0-9]|^[0-9][0-9][0-9]", "", x = colnames(finaldf))
colnames(finaldf) <- gsub("^[ ]", "", x = colnames(finaldf))
colnames(finaldf) <- gsub("[(][)]", "", x = colnames(finaldf))
colnames(finaldf) <- gsub("[-][X$]", " (X-axis)", x = colnames(finaldf))
colnames(finaldf) <- gsub("[-][Y$]", " (Y-axis)", x = colnames(finaldf))
colnames(finaldf) <- gsub("[-][Z$]", " (Z-axis)", x = colnames(finaldf))
colnames(finaldf) <- gsub("[m][e][a][n][F]", "MEAN f", x = colnames(finaldf))
colnames(finaldf) <- gsub("[m][e][a][n]", "MEAN", x = colnames(finaldf))
colnames(finaldf) <- gsub("[s][t][d]", "STD", x = colnames(finaldf))
colnames(finaldf) <- sub("[-]", " - ", x = colnames(finaldf))
colnames(finaldf) <- sub("^[t]", "time", x = colnames(finaldf))
colnames(finaldf) <- sub("^[f]", "frequency", x = colnames(finaldf))



# creating independant dataset of activity averages for each variable

ActivityAverages <- finaldf%>%
        group_by(Subject, Activity)%>%
        summarize_all(mean)


write.table(ActivityAverages, file = "tidydataset.txt", row.names = FALSE)



