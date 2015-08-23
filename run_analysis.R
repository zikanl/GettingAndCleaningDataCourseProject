# The following R libraries are required to run this script
library(downloader)
library(data.table)

# This function loads and processes dataset of given type (train or test)
load.dataset <- function(type, selected.features, activity.labels){
  
  path <- paste(type, '/', sep = '')
  feature.vectors.file <- paste(path, 'X_', type, '.txt', sep = '')
  activity.labels.file <- paste(path, 'y_', type, '.txt', sep = '')
  subject.ids.file <- paste(path, 'subject_', type, '.txt', sep= '')
  
  # Load data files
  feature.vectors.data <- read.table(feature.vectors.file)[,selected.features$id]
  activity.labels.data <- read.table(activity.labels.file)[,1]
  subject.ids.data <- read.table(subject.ids.file)[,1]
  
  # Name variables 
  names(feature.vectors.data) <- selected.features$label
  feature.vectors.data$label <- factor(activity.labels.data, levels=activity.labels$id, labels=activity.labels$label)
  feature.vectors.data$subject <- factor(subject.ids.data)
  
  # Return processed dataset
  feature.vectors.data
}

# The main script starts here

#Important: Set working directory to the local directory
#setwd("~/KnitrProject")

#Set URL from which data is downloaded
dataURL <- 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'

#Set local filename of the downloaded data
filename <- "dataset.zip"

## Download and unzip the dataset to the local directory
## This script downloads data only if the local copy of zipped data does not exist
## It also unzippes data only if directory with previously unzipped data does not exist
if (!file.exists(filename)){
  download(dataURL,filename)
}
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename)
}

setwd('UCI HAR Dataset/')

# Load id->feature label data
feature.vector.labels.data <- read.table('features.txt', col.names = c('id','label'))

# Select only the measurements on the mean and standard deviation for each measurement.
# Features we want to select have -mean() or -std() as a part of the name.
selected.features <- subset(feature.vector.labels.data, grepl('-(mean|std)\\(', feature.vector.labels.data$label))

# Load id->activity label data
activity.labels <- read.table('activity_labels.txt', col.names = c('id', 'label'))

# Read and process train data sets
train.df <- load.dataset('train', selected.features, activity.labels)
# Read and process test data sets
test.df <- load.dataset('test', selected.features, activity.labels)

# Merge train and test sets
merged.df <- rbind(train.df, test.df)

# Convert to data.table for making it easier and faster to calculate mean for activity and subject groups.
merged.dt <- data.table(merged.df)

# Calculate the average of each variable for each activity and each subject. 
tidy.dt <- merged.dt[, lapply(.SD, mean), by=list(label,subject)]

# Tidy variable names
tidy.dt.names <- names(tidy.dt)
tidy.dt.names <- gsub('-mean', 'Mean', tidy.dt.names)
tidy.dt.names <- gsub('-std', 'Std', tidy.dt.names)
tidy.dt.names <- gsub('[()-]', '', tidy.dt.names)
tidy.dt.names <- gsub('BodyBody', 'Body', tidy.dt.names)
setnames(tidy.dt, tidy.dt.names)

#Write the cleaned data to a file named tidy.txt
setwd('..')
write.table(tidy.dt, "tidy.txt", row.names = FALSE, quote = FALSE)
