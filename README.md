# getting-and-cleaning-data-course-project
The script follow 7 major steps in order to get to the final requested data set in step 5:
1) Importing the txt files in the train folder as data frames and giving them descriptive variable names.
2) combining all the train folder datasets into one big dataset.
3) Importing the txt files in the test folder as data frames and giving them descriptive variable names.
4) combining all the test folder datasets into one big dataset.
5) combining both the train and the test datasets into one whole dataset using an outer join.
6) selecting columns that only have mean or std measurement.
7) creating a second, independent tidy data set with the average of each variable (mean or std variable) grouped by activity label and subject ID.
