##declaration of libraries to be used

library(reshape2)
library(dplyr)
library(magrittr)

## First step is to read Training Data files

## reading "X_train.txt" file
x_train <- read.table(".\\UCI HAR Dataset\\train\\X_train.txt", sep="\t", strip.white=TRUE)

## Confirming dimensions of x_train measurments data frame: 7352 x 1

dim(x_train)


## Viewing element of the column. It contains 561 measurments as a single element.

x_train[1,1]


## Reading "features.txt" file that contain names for all 561 types of measurements. 
## These data will be used in renaming variables/columns.
## Removing "-" and "()" from the names. 

features<-read.table(".\\UCI HAR Dataset\\features.txt")
features[,2]<-gsub("-","_", features[,2])
features[,2]<-gsub("\\(","", features[,2])
features[,2]<-gsub("\\)","", features[,2])
head(features)

## Let's take a look at "features" data frame

head(features)



## Splitting measurements into 561 columns and naming column names 
## in accrodance with the second column of "features"" data frame.

x_train<-colsplit( x_train$V1,"\\s{1,}", features[,2])


## confirming the dimensions of the x_train set: 7352 x 561

dim(x_train)


## Reading subject id for all 7,352 training measurements
## Confirming dimensions: 7352 x 1.
## Confirming the content

subject_train<-read.table(".\\UCI HAR Dataset\\train\\subject_train.txt", col.names = "subject_ID", strip.white=TRUE)
dim(subject_train)
head(subject_train)

## Reading activity type for all 7,352 training measurement and confirming dimensions and content
## Naming the variable(column): "activity"

y_train<-read.table(".\\UCI HAR Dataset\\train\\y_train.txt", col.names = "activity", strip.white=TRUE)
dim(y_train)
head(y_train)


## Creating another variable called set_type that takes two calues: "train" and "test"
## For now we assign 7352 values of "train" by repetition.

type1<-data.frame(rep("train",7352))
colnames(type1)<-"set_type"


## Combining all four data frames we created in the single "tidy_train" data set.

tidy_train<-cbind(subject_train,y_train, type1, x_train)
dim(tidy_train)
head(tidy_train)


## No will do same with the test set
## Confirming the dimemsions, content, column names and ordering after each reading and modification
## According to the provided description of the set, the dimensions of the test data set: 2947 x 561 

x_test<-read.table(".\\UCI HAR Dataset\\test\\X_test.txt", sep="\t", strip.white=TRUE)
dim(x_test)
head(x_test)


## Splitting into 561 columns
x_test<-colsplit( x_test$V1,"\\s{1,}", features[,2])
dim(x_test)
head(x_test)


## Reading subject id of the "test" set
subject_test<-read.table(".\\UCI HAR Dataset\\test\\subject_test.txt", col.names = "subject_ID", strip.white=TRUE)
dim(subject_test)
head(subject_test)

## Reading activity type file
y_test<-read.table(".\\UCI HAR Dataset\\test\\y_test.txt", col.names = "activity", strip.white=TRUE)

## Creating 2947 repetitions of "test" value to separate from "training measurements" 
## after merging two sets

type2<-data.frame(rep("test",2947))
colnames(type2)<-"set_type"

## Binding "test" data set in the same column order as merging of "train" set was done.
tidy_test<-cbind(subject_test,y_test, type2, x_test)

## Merging both sets into single "tidy_both"" data frame
tidy_both<-rbind(tidy_test, tidy_train)

## The contetnt acitivity variable is numerical. 
## For tidy data we would prefer self-explanatory values like WALK, SIT, LAY e.t.c.
## The original names look a little to long.Let's shorten them a bit

tidy_both$activity<-gsub("^1", "walk", tidy_both$activity)
tidy_both$activity<-gsub("^2", "walk_up", tidy_both$activity)
tidy_both$activity<-gsub("^3", "walk_down", tidy_both$activity)
tidy_both$activity<-gsub("^4", "sit", tidy_both$activity)
tidy_both$activity<-gsub("^5", "stand", tidy_both$activity)
tidy_both$activity<-gsub("^6", "lay", tidy_both$activity)

## Selecting column names with the keywords "std" and "mean".
tidy_m_std<-tidy_both[ , grepl( "std|[Mm]ean|activity|subject_ID|set_type" , names( tidy_both ) ) ]

## Groupng by subject_id and activity, then averaging.
tidy_final<-tidy_m_std %>% group_by(subject_ID, activity, set_type) %>% summarise_each(funs(mean))

## adding XYZ scalar aggregated variables from X, Y, Z columns for TBodyACC_mean and TBodyACC_std
tidy_final<-mutate(tidy_final, tBodyAcc_mean_XYZ = (tBodyAcc_mean_X^2 + tBodyAcc_mean_Y^2+tBodyAcc_mean_Z^2)*0.5)
tidy_final<-mutate(tidy_final, tBodyAcc_std_XYZ = (tBodyAcc_std_X^2 + tBodyAcc_std_Y^2+tBodyAcc_std_Z^2)*0.5)
## Writing tidy_final file into txt file
write.table(tidy_final, ".\\UCI HAR Dataset\\tidy_final.txt")
