# Getting & cleaning data course project:
library(pacman) # pacman is a library that allows you to call multiple other libraries in one line using the p_load function.
p_load(rio, dplyr, glue) # rio is a package that eases importing files using the import function instead of read.csv and glue is function that allows you to use variables withing strings like the idea of an f-string in the python programming language.

# 1) Importing the txt files in the train folder as data frames and giving them descriptive variable names:
setwd("M:/Computer Science/R_programming/Coursera/Data science specialization by John Hopkins university/Getting & cleaning data course/Course project/UCI HAR Dataset")
activity_labels <- import('activity_labels.txt') %>% 
                    rename(activity_id = 1, activity_label = 2)

# extracting the features as a vector from the text file
features_names <- import('features.txt')[[2]]


y_train <- import('train/y_train.txt') %>% 
            as_tibble %>% 
            rename(activity_id = 1)

x_train <- import('train/X_train.txt') %>% 
            as_tibble
colnames(x_train) <- features_names  # changing the varialbe names in this dataset to the discreptive feature names
unique_x_train_cols <- match(unique(colnames(x_train)), colnames(x_train))
x_train <- select(x_train, all_of(unique_x_train_cols)) # dropping all the duplicated features in x_train

subject_train_id <- import('train/subject_train.txt') %>% 
                    rename(subject_id = 1)

# merging the datasets in the inertial signals folder in the train folder into one big dataset
setwd('train/Inertial Signals')
inertial_signals_files <- list.files()
for (index in 1: (length(inertial_signals_files) - 1)){
    if (index == 1){
        # initializing the cumulative dataset with the first inertial signals dataset
        all_inertial_signals_train_data <- import(inertial_signals_files[index])
        new_variable_names <- paste0(names(all_inertial_signals_train_data), sub('.txt', '' ,  glue('_', {inertial_signals_files[index]})) ) # making more descriptive variable names for the 1st inertial signals dataset
        colnames(all_inertial_signals_train_data) <- new_variable_names
    }
    
    nxt_inertial_signals_data <- import(inertial_signals_files[index + 1])
    new_variable_names <- paste0(names(nxt_inertial_signals_data), sub('.txt', '' ,  glue('_', {inertial_signals_files[index + 1]})) ) # making more descriptive variable names for the other inertial signals datasets
    colnames(nxt_inertial_signals_data) <- new_variable_names

    # # merging all the different intertial signals datasets into one cumulative dataset
    all_inertial_signals_train_data <- bind_cols(all_inertial_signals_train_data, nxt_inertial_signals_data)
    
}

# 2) combining all the train folder datasets into one big dataset:
train_dataset <- subject_train_id %>% 
                 bind_cols(y_train) %>% 
                 left_join(activity_labels, by = 'activity_id') %>% 
                 bind_cols(x_train) %>% 
                 bind_cols(all_inertial_signals_train_data) %>% 
                 as_tibble


# 3) Importing the txt files in the test folder as data frames and giving them descriptive variable names:
setwd("M:/Computer Science/R_programming/Coursera/Data science specialization by John Hopkins university/Getting & cleaning data course/Course project/UCI HAR Dataset")

y_test <- import('test/y_test.txt') %>% 
            as_tibble %>% 
            rename(activity_id = 1)

x_test <- import('test/X_test.txt') %>% 
            as_tibble
colnames(x_test) <- features_names  # changing the varialbe names in this dataset to the discreptive feature names
unique_x_test_cols <- match(unique(colnames(x_test)), colnames(x_test))
x_test <- select(x_test, all_of(unique_x_test_cols)) # dropping all the duplicated features in x_train

subject_test_id <- import('test/subject_test.txt') %>% 
                    rename(subject_id = 1)

# merging the datasets in the inertial signals folder in the test folder into one big dataset
setwd('test/Inertial Signals')
inertial_signals_files <- list.files()
for (index in 1: (length(inertial_signals_files) - 1)){
    if (index == 1){
        # initializing the cumulative dataset with the first inertial signals dataset
        all_inertial_signals_test_data <- import(inertial_signals_files[index])
        new_variable_names <- paste0(names(all_inertial_signals_test_data), sub('.txt', '' ,  glue('_', {inertial_signals_files[index]})) ) # making more descriptive variable names for the 1st inertial signals dataset
        colnames(all_inertial_signals_train_data) <- new_variable_names
    }
    
    nxt_inertial_signals_data <- import(inertial_signals_files[index + 1])
    new_variable_names <- paste0(names(nxt_inertial_signals_data), sub('.txt', '' ,  glue('_', {inertial_signals_files[index + 1]})) ) # making more descriptive variable names for the other inertial signals datasets
    colnames(nxt_inertial_signals_data) <- new_variable_names
    
    # # merging all the different intertial signals datasets into one cumulative dataset
    all_inertial_signals_test_data <- bind_cols(all_inertial_signals_test_data, nxt_inertial_signals_data)
    
}

# 4) combining all the test folder datasets into one big dataset:
test_dataset <- subject_test_id %>% 
    bind_cols(y_test) %>% 
    left_join(activity_labels, by = 'activity_id') %>% 
    bind_cols(x_test) %>% 
    bind_cols(all_inertial_signals_test_data) %>% 
    as_tibble


# 5) combining both the train and the test datasets into one whole dataset using an outer join:
train_test_dataset <- train_dataset %>% 
                      full_join(test_dataset)

# 6) selecting columns that only have mean or std measurement:
 matching_indices <- grep('mean|std', colnames(train_test_dataset))
 mean_std_measurements <- select(train_test_dataset, 1:3, all_of(matching_indices))
 
# 7) creating a second, independent tidy data set with the average of each variable for each activity and each subject:
avg_by_activity_and_subject <- mean_std_measurements %>%
                                group_by(activity_label, subject_id) %>% 
                                summarize(across(everything(), mean))

# giving the variable names a more descriptive name by adding avg to the beginning of each one:                                
colnames(avg_by_activity_and_subject)[-c(1,2,3)] <- paste0('avg_', colnames(avg_by_activity_and_subject)[-c(1,2,3)])
