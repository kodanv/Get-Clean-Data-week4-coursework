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
## This single column needs be split into 561 columns as a tidy data requires all variables 
## to be stored in a separate columns. Also, please note that the measurement are separated 
## by one or more spaces. Looks like it is just one space in between if an extra character is 
## used for "-" sign in negative measurements 

x_train[1,1]


## Reading "features.txt" file that contain names for all 561 types of measurements. 
## These data will be used in renaming variables/columns.
## Removing "-" and "()" from the names. Otherwise "mutate" function is getting "confused" with "mean()"
## as a part of its arguments

features<-read.table(".\\UCI HAR Dataset\\features.txt")
features[,2]<-gsub("-","_", features[,2])
features[,2]<-gsub("\\(","", features[,2])
features[,2]<-gsub("\\)","", features[,2])

## Let's take a look at "features" data frame

head(features)


## We see that actual measurement labels are stored in the second column.
## The first column is just the sequence numbers
## Splitting measurements into 561 columns and naming column names 
## in accrodance with the second column of "features"" data frame.
## Expression "\\s{1,} below denotes exactly one or more "space" separation pattern

x_train<-colsplit( x_train$V1,"\\s{1,}", features[,2])


## confirming the dimensions of the x_train set: 7352 x 561

dim(x_train)


## Now reading subject id for all 7,352 training measurements
## Naming the variable(column): "subject_ID"
## And confirming dimensions: 7352 x 1.
## Confirming the content

subject_train<-read.table(".UCI HAR Dataset\\train\\subject_train.txt", col.names = "subject_ID", strip.white=TRUE)
dim(subject_train)
head(subject_train)

## Reading activity type for all 7,352 training measurement and confirming dimensions and content
## Naming the variable(column): "activity"

y_train<-read.table(".UCI HAR Dataset\\train\\y_train.txt", col.names = "activity", strip.white=TRUE)
dim(y_train)
head(y_train)


## Since we will be joining two data measurement types (Train and Test) in a single table,
## we do not want to loose track of which measurement belongs to the Train set and which to the Test.
## Let's create another variable called set_type that takes two calues: "train" and "test"
## For now we assign 7352 values of "train" by repetition.

type1<-data.frame(rep("train",7352))
colnames(type1)<-"set_type"


## Let's combine all four data frames we created in the single "tidy_train" data set.
## STarting with subject_id first, then activity (y_train), set_type ("train") and finally the 561 
## measurement data frame.
## Let's also confirm dimensions ( 7352 x 561+3) and the column order
## This order more appropriately matches the later grouping by Subject ID and the activity type


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

## Now we need to make a decision what mean and std measurements average over 
## and to include in our tidy data set.
## Even though Frequency measurements performed in the different domain than 
## those of the acceleration measurements, they may provide additional insight into individual
## movement and activity characteristics of various subjects (the individual participants). 
## We may benefit later from keeping that data.


## At this initial stage, we need to be carefull with discarding and "over-averaging" the data.
## And as we know, for every purpose there is its own tidy data set. 
## The possible annalysis could include:
## From the given measurements is it possible to predict an activity type of a subject ( waliking, 
## sitting, laying ...). Another interesting question: by researching individual moving characterictis,
## can we distinguish between the individuals, and tell which person is moving.
## To sum, depending on the research question, we may benefit from some measurements, including those 
## in the frequency domain. 

## We average all measurements that include "std" and "mean" keywords and by grouping by subject_id 
## and activity type.

## Selecting column names with the keywords "std" and "mean".
tidy_m_std<-tidy_both[ , grepl( "std|[Mm]ean|activity|subject_ID|set_type" , names( tidy_both ) ) ]


## Groupng by subject_id and activity, then averaging.
tidy_final<-tidy_m_std %>% group_by(subject_ID, activity, set_type) %>% summarise_each(funs(mean))


## At the end we added XYZ scalar variables aggregated from X, Y, Z columns for TBodyACC_mean and TBodyACC_std.
## We need yet to explore if there is a benefit of such aggregation. Hence, we are not removing the original 
## X, Y, Z measurements at this stage.

tidy_final<-mutate(tidy_final, tBodyAcc_mean_XYZ = (tBodyAcc_mean_X^2 + tBodyAcc_mean_Y^2+tBodyAcc_mean_Z^2)*0.5)
tidy_final<-mutate(tidy_final, tBodyAcc_std_XYZ = (tBodyAcc_std_X^2 + tBodyAcc_std_Y^2+tBodyAcc_std_Z^2)*0.5)

## Writing tidy_final file into txt file
write.table(tidy_final, ".\\UCI HAR Dataset\\tidy_final.txt")


Complete list of Variables:

"1" "subject_ID"
"2" "activity"
"3" "set_type"
"4" "tBodyAcc_mean_X"
"5" "tBodyAcc_mean_Y"
"6" "tBodyAcc_mean_Z"
"7" "tBodyAcc_std_X"
"8" "tBodyAcc_std_Y"
"9" "tBodyAcc_std_Z"
"10" "tGravityAcc_mean_X"
"11" "tGravityAcc_mean_Y"
"12" "tGravityAcc_mean_Z"
"13" "tGravityAcc_std_X"
"14" "tGravityAcc_std_Y"
"15" "tGravityAcc_std_Z"
"16" "tBodyAccJerk_mean_X"
"17" "tBodyAccJerk_mean_Y"
"18" "tBodyAccJerk_mean_Z"
"19" "tBodyAccJerk_std_X"
"20" "tBodyAccJerk_std_Y"
"21" "tBodyAccJerk_std_Z"
"22" "tBodyGyro_mean_X"
"23" "tBodyGyro_mean_Y"
"24" "tBodyGyro_mean_Z"
"25" "tBodyGyro_std_X"
"26" "tBodyGyro_std_Y"
"27" "tBodyGyro_std_Z"
"28" "tBodyGyroJerk_mean_X"
"29" "tBodyGyroJerk_mean_Y"
"30" "tBodyGyroJerk_mean_Z"
"31" "tBodyGyroJerk_std_X"
"32" "tBodyGyroJerk_std_Y"
"33" "tBodyGyroJerk_std_Z"
"34" "tBodyAccMag_mean"
"35" "tBodyAccMag_std"
"36" "tGravityAccMag_mean"
"37" "tGravityAccMag_std"
"38" "tBodyAccJerkMag_mean"
"39" "tBodyAccJerkMag_std"
"40" "tBodyGyroMag_mean"
"41" "tBodyGyroMag_std"
"42" "tBodyGyroJerkMag_mean"
"43" "tBodyGyroJerkMag_std"
"44" "fBodyAcc_mean_X"
"45" "fBodyAcc_mean_Y"
"46" "fBodyAcc_mean_Z"
"47" "fBodyAcc_std_X"
"48" "fBodyAcc_std_Y"
"49" "fBodyAcc_std_Z"
"50" "fBodyAcc_meanFreq_X"
"51" "fBodyAcc_meanFreq_Y"
"52" "fBodyAcc_meanFreq_Z"
"53" "fBodyAccJerk_mean_X"
"54" "fBodyAccJerk_mean_Y"
"55" "fBodyAccJerk_mean_Z"
"56" "fBodyAccJerk_std_X"
"57" "fBodyAccJerk_std_Y"
"58" "fBodyAccJerk_std_Z"
"59" "fBodyAccJerk_meanFreq_X"
"60" "fBodyAccJerk_meanFreq_Y"
"61" "fBodyAccJerk_meanFreq_Z"
"62" "fBodyGyro_mean_X"
"63" "fBodyGyro_mean_Y"
"64" "fBodyGyro_mean_Z"
"65" "fBodyGyro_std_X"
"66" "fBodyGyro_std_Y"
"67" "fBodyGyro_std_Z"
"68" "fBodyGyro_meanFreq_X"
"69" "fBodyGyro_meanFreq_Y"
"70" "fBodyGyro_meanFreq_Z"
"71" "fBodyAccMag_mean"
"72" "fBodyAccMag_std"
"73" "fBodyAccMag_meanFreq"
"74" "fBodyBodyAccJerkMag_mean"
"75" "fBodyBodyAccJerkMag_std"
"76" "fBodyBodyAccJerkMag_meanFreq"
"77" "fBodyBodyGyroMag_mean"
"78" "fBodyBodyGyroMag_std"
"79" "fBodyBodyGyroMag_meanFreq"
"80" "fBodyBodyGyroJerkMag_mean"
"81" "fBodyBodyGyroJerkMag_std"
"82" "fBodyBodyGyroJerkMag_meanFreq"
"83" "angletBodyAccMean,gravity"
"84" "angletBodyAccJerkMean,gravityMean"
"85" "angletBodyGyroMean,gravityMean"
"86" "angletBodyGyroJerkMean,gravityMean"
"87" "angleX,gravityMean"
"88" "angleY,gravityMean"
"89" "angleZ,gravityMean"
"90" "tBodyAcc_mean_XYZ"
"91" "tBodyAcc_std_XYZ"

