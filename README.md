# UmbeRto
UmbeRto is a small package to perform anomaly detection on large scale logs collection. It is named after Umberto Eco.

The package uses a robust polynomial model (Restricted cubic spline) from RMS to predict the structural trends of logs for each document. It then derives an *anomaly ratio* based on the discrepancy between the predicted value and the actual value (sigma value).  

UmbeRto can be installed using 

```
devtools::install_github("Dorialexander/UmbeRto")
```

As a demonstration you can load the sample dataset "log_data". It contains the aggregated logs at the day-level of 200 articles from Open Edition from January 1st, 2017.

```{r}
library(tidyverse)
library(UmbeRto)

data("log_data")
log_data
```

The dataset records three variable: an alias of the documents (Document n°1, Document n°2, etc.), the day of the recording in a date format and the number of unique visitors.

## Cleaning the log corpus

The function **um_clean** transform any set of logs aggregated by documents and by a time variable into a dataset that can be used by **um_model**. The function uses non-standard evaluation, so any column name can be used as an input.

```
#all the possibilities are ok so long as they match existing relevant column in the dataset.
cleaned_anomalies = um_clean(complete_anomalies, name, current_date, count_visitor)
cleaned_anomalies = um_clean(complete_anomalies, document, current_hour, count_visits)
cleaned_anomalies = um_clean(complete_anomalies, article, day, visits)
```

**um_clean** outputs a normalized dataset that can be used by um_model. You may notice that the name of the column at the output remains identical regardless of the naming scheme at the input. Besides, the time variable has been supplemented with a standardized time sequency that starts at the first apparition of the document in the logs.

UmbeRto has been developed for day-level values but should normally perform with other time units.

UmbeRto works usually better with unique visitors since multiple visits from the same visitor can be wrongly accounted as a sudden "surge" in traffic.

## Modeling the anomalies

The function um_model takes a dataset normalized by um_clean to identify the anomalous event for each time series associated to the document. The underlying RCS model can be customized by adding more "knots", that is more precision to the model at the expense of added complexity and more risks of overfitting and missing anomalous events. It is also possible to change the min number of observations necessary to integrate a time sequence into the model.

```
um_model(log_data, knots = 3, min_observations = 7, min_anomaly_ratio = 5)
```

**um_model** will generate a database of anomalous events with their estimated anomalous rate (from 0-100). By default, all anomalous event with a rate inferior to 5 are removed but this value can be changed using min_anomaly_ratio. To get the most extreme anomalous events, you can simply reorder the dataset using arrange.

```{r}
anomalies %>% arrange(-anomaly_ratio)
```

UmbeRto is compatible with the pipe writing system of the tidyverse. It's possible to chain the cleaning and modeling operations:

```{r}
anomalies = log_data %>%
  um_clean(document, time_variable, count_log) %>%
  um_model(knots = 3, min_observations = 7, min_anomaly_ratio = 5)

anomalies
```
