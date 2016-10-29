=======================================================================================================
Week 4 Coursework
Coursera - Getting and Cleaning Dataset

=======================================================================================================
Data Set to clean:
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Human Activity Recognition Using Smartphones Dataset
Version 1.0
Jorge L. Reyes-Ortiz, Davide Anguita, Alessandro Ghio, Luca Oneto.
Smartlab - Non Linear Complex Systems Laboratory
DITEN - Università degli Studi di Genova.
Via Opera Pia 11A, I-16145, Genoa, Italy.
activityrecognition@smartlab.ws
www.smartlab.ws
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


======================================================================================================

==============================Data Sets and Files descriptions========================================

The data set is comprised of several text files with separate subsets for train and test measurements.
The list of the files, the character and dimensions of the data stored in the files are as follows:

----------------------------Files common to both TRAIN and TEST sets:

1) "features.txt" - contains all names for 561 measurements. This data was read into R and used to name 
variables(columns) of both TRAIN and TEST data sets.

-----------------------------Train Set files:
2) "X_train.txt" - actual measurements.  Provides 561 types of time and frequency domain measurements. 
The number of the observations is 7,352. After reading with a read.table, the data frame dimensions were:
7,352 x 1. We used colsplit function to split all 561 measurements into separate 561 columns, as a tidy
data requires store all variables in separate columns.

3) "subject_train.txt"  - id of the subjects (individual study participants) for each of 7,352 "train" 
measurements. The variable was named "subject_id"

4) "y_train.txt" - list of activity type for all 7,352 "train" measurements, originally worded as 
"WALKING", "WALKING_UPSTAIRS", "WALKING_DOWNSTAIRS", "SITTING", "STANDING", "LAYING".
The file has numerical values from 1 to 6. They have been replaced by self-explanatory categorical values 
all in lowercase and shorter than original words: "walk", "walk_up", "walk_down", "sit", "stand" and "lay".
The variable name is "activity"

------------------------------Test Set files:
All three files analogous to "train" set files above. 
The only difference is the number of observations: 2947
5) "X_test.txt" file - measurements

6) "subject_test.txt"  - id of the test participants randomly chosen for the test set.

7) "y_test.txt" - activity types for all "test" measurements

==============================================================================================================

==============================New Variables===================================================================

Besides creating separate columns for subject_id and activity variables, a variable "set_type" was created 
to track if a particular observation belongs to a "train" set or "test" set. The variable "set_type" takes
the two values: "train" and "test".


==============================================================================================================

==============================Merging data sets===============================================================

Both sets have been built separately by merging columns (variables) in the following order:

tidy_train data frame was obtained by combining: (subject_id, activity, set_type, x_train{561 measurement frame})
Dimensions: 7,352 x 564

tidy_test is a merge of (subject_id, activity, set_type, x_test {561 measurement frame} )
Dimensions: 2,947 x 564

Finally, both sets have been merged by rows into tidy_both data frame with dimensions: 10,299 x 564


==============================================================================================================
==============================What mean and std measurements to keep and to average over???===================

Even though Frequency measurements performed in the different domain than those of the time domain measurements
such as acceleration, the frequency domain measurement may provide additional insight into individual movement
and activity characteristics of various subjects (the individual participants).
 
It may be beneficial to keep the frequency measurements. At this initial stage, we need to be careful with 
discarding and "over-averaging" the data. Especially, if there was no clear cut goals have been set up yet. 
As we know, for every purpose there is its own tidy data set. 
The possible analysis and questions to answer could be:

1) From the given measurements is it possible to predict the activity type of a subject ( is he/she walking,
sitting, standing ...). In this case at some we can average over various measurements of the subjects. But,

2) if we are researching individual moving characteristics, and trying to distinguish between the individuals,
and tell which person is moving, sitting, e.t.c. In this case we do not want to aggregate by averaging values
over subject_id.

Depending on the research question, we may benefit from some measurements, including those in the
frequency domain. So, we will keep them in the tidy set for now will try to explore which measurements more
individual to activity types and to the subjects.

At the end we added XYZ scalar variables aggregated from X, Y, Z columns for TBodyACC_mean and TBodyACC_std.
We yet need to explore if there is a benefit of such aggregation. Hence, we are not removing the original X, Y, Z measurements at this stage.
The resulting tidy_final data frame has dimensions of 180 X 91.

"tidy_final" set is saved in "tidy_final.txt" file.

For reading the data, please use read.table:
data<-read.table("tidy_final.txt")


=============================End============================================================================