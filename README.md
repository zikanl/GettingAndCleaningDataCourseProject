# Getting And Cleaning Data Course Project

### Summary

The script `run_analysis.R` is run from the local directory (which should be set in the script itself). The script also defines a name for the local copy of the zipped file (dataset.zip), and checks whether the zipped file has already been downoladed. When data is already unzipped and directory with the dataset is available as `UCI HAR Dataset` subdirectory of the current directory, the script simply continues execution. 

## High level overview of the processing steps

1. Download and unzip the archived dataset.
2. Feature vector label data is loaded from `features.txt`
3. Using regex with grepl, subset of label data for selecting desired data coluns is created. 
4. Activity labels are loaded from `features.txt`
5. Activity labels (id->label) and selected features (id->label) are passed as parameters to `load.dataset()` function which loads the training or test dataset, based on the type value passed as a parameter. In essence this function executes the following steps:
     1. Paths to data files are created based on type parameter
     2. Data files are loaded. Feature vector data is filtered using ids of the selected features.
     3. Activity and subject id data are loaded
     4. Feature vector data is renamed using the names of selected features
     5. Activies and subjects are given labels using factor levels of activity and subject id data.
     6. Finally, processed dataset is returned.
6. (The previous processing is repeated to both training and test datasets.)
7. Training and test datasets are merged using `rbind()` and converted to `data.table` to make it easier to do groupwise operations in the following step 
8. Mean is calculated for all variables for each activity and subject
9. Variable names are loaded to separate vector and  tidied to follow the convention. New names are applied to the dataset
10. Tidy dataset is written to disk.
