Getting and Cleaning Data Course Project
========================================

This project utilized a UCI dataset created from experiments determining
sensor readings for different common activities such as walking and
standing. While we were not required to use this dataset for machine
learning as it was created for, our task was to pull existing numbers
from the data and lay them out neatly (tidy). Below is a summary of my
code and the processes I went through to turn the raw data files we were
given into 2 condensed, ***tidy*** datasets.

------------------------------------------------------------------------

### Introduction

Before any work was done in R, I had to look through the raw files
themselves, and the ReadMe included to better understand how the files
we were given interacted with each other. From this I was able to
determine an outline of processes:

-   Pull the *subject* (subject\_), *labels* (y\_), and *set data* (x\_)
    files for both the **test** and **train** folders into R, along with
    the *features.txt* file (this would provide most of the column
    names).
-   Merge the **test** and **train** data frames of the *subject*,
    *labels* and *setdata* files.
-   Separate the *set data* into 561 columns (1 for each ‘feature’), and
    select just the *set data* columns representing ‘mean’ and ‘std’
    information
-   Combine the parsed *set data* data frame with the *subject* and
    *labels* data frames
-   Clean up all the formatting and column names
-   Create a final additional data set which showed the average of the
    mean and standard deviation variables for each activity and subject

There were some additional processes needed which I discovered as I went
through the project, which are also outlined below.

------------------------------------------------------------------------

### Importing the data

In order to read .txt files into R, I used the **read.delim** function.
Initially the function was using the first line of data as header
information, so the argument **header = FALSE** was added. I also used
the argument **stringsAsFactors = FALSE** to make sure I could easily
apply character substitutions/manipulations later on.

> testdata &lt;- read.delim(“X\_test.txt”, header = FALSE,
> stringsAsFactors = FALSE)

------------------------------------------------------------------------

### Merging test and train data

I used the **rbind** function to combine the test and train data frames
for the set data, subject, and activity labels

> mergeddata &lt;- rbind(traindata, testdata)

------------------------------------------------------------------------

### Preparing for parsing and merging

In order to use the features list from the raw data as column names for
the parsed set data, the features list had to be converted into a
vector. For this I used the **unlist** function.

> featuresvector &lt;- unlist(features\[,1\])

I also applied column names to the data frames for subject and activity
labels.

> colnames(mergedlabels) &lt;- “Activity”

To correctly parse the set data out into columns, I needed to make the
spacing consistent between values in each row (in their raw form, there
was a mix of single and double spaces between values). I also needed to
remove the spaces before the first value in each row. For these
processes I used the **sub** and **gsub** functions.

> mergeddata\[c(1:10299),\] &lt;- gsub(" “,” ", x =
> mergeddata\[c(1:10299),\])

------------------------------------------------------------------------

### Parsing the set data

Having fixed the character formatting in the data fram for set data,
parsing it out into separate columns was straight forward by using the
**separate** function. This was especially efficient as I did not need
an extra function to create/assign column names.

> ParsedData &lt;- separate(mergeddata, V1, into = featuresvector, sep =
> " ")

I then needed to select just the columns for *mean* and *standard
deviation* values. For this I used the **grepl** function with the **\[
\]** accessor.

> ParsedData &lt;- ParsedData\[,
> grepl(“\[m\]\[e\]\[a\]\[n\]|\[s\]\[t\]\[d\]” , names(ParsedData))\]’

------------------------------------------------------------------------

### Merging the parsed data with subject and activity labels

I used the **cbind** function to merge the parsed set data with its
corresponding subject and activity labels.

> finaldf &lt;- cbind (mergedsubjects, mergedlabels, ParsedData)

At this point I effectively had my merged and reorganized data frame. I
just needed to clean it up (make it ***tidy***)

------------------------------------------------------------------------

### Cleaning up the data frame

The subject and activity columns needed to be factor variables, with the
activity factors labeled with their corresponding activities. I used the
**as.factor** function to coerce subject to a factor varible, and the
**factor** function to do the same to the activity column, whilst also
apply the labels.

> finaldf$Activity &lt;- factor(finaldf$Activity, labels = c(“WALKING”,
> “WALKING UPSTAIRS”,“WALKING DOWNSTAIRS”, “SITTING”, “STANDING”,
> “LAYING”))

Lastly, I wanted to make the column names for the set data portion to be
more readable for the average person. I applied a number of
transformations using a combination of **sub** and **gsub**.

> colnames(finaldf) &lt;- sub(“^\[t\]”, “time”, x = colnames(finaldf))

------------------------------------------------------------------------

### Creating the final indepedant tidy data set

To complete the last step of the project, I used the {dplyr} package
functions **group\_by** and **summarize\_all** to find the averages of
each variable per subject and activity, and apply them into a new
dataframe.

> ActivityAverages &lt;- finaldf%&gt;% group\_by(Subject,
> Activity)%&gt;% summarize\_all(mean)

I used the **write.table** function to extract this final data frame
into a .txt file format data set.

> write.table(ActivityAverages, file = “tidydataset.txt”, row.names =
> FALSE)

------------------------------------------------------------------------
