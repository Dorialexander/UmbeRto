
#' A function to retrieve the anomalies using rds.
#' @export um_clean
#' @param log_data A dataset of logs aggregated by publications and per days.
#' @param document The exact name of the document column.
#' @param time_variable The exact name of the date of records column.
#' @param count_log The exact name of the aggregated logs column.
#' @examples
#'  um_clean(log_data, document, time_variable, count_log)
um_clean <- function(log_data, document, time_variable, count_log) {
  library(dplyr)
  #Lazy non-standard approach
  document_col = rlang::quo_name(rlang::enquo(document))
  time_variable_col = rlang::quo_name(rlang::enquo(time_variable))
  count_log_col = rlang::quo_name(rlang::enquo(count_log))

  log_data = log_data %>% rename("document" := !!document_col, "time_variable" :=  !!time_variable_col, "count_log" := !!count_log_col)

  #We locate the first time publication were registered in the logs.
  min_time_sequence = log_data %>%
    group_by(document) %>%
    summarise(start_time = min(time_variable)) %>%
    ungroup()

  #We get the complete set of dates recorded regardless of the publications.
  #(Perhaps switch to min/max date value.)
  all_time_sequence = log_data %>% group_by(time_variable) %>% summarise()

  #We extend the days set to have all the possible combinations of days and publications
  complete_set = min_time_sequence %>%
    mutate(joining = "j") %>%
    inner_join(all_time_sequence %>% mutate(joining = "j"), by=c("joining"))

  #We merge back on the detailed anomalies data in log_data
  complete_set = complete_set %>%
    select(-joining) %>%
    left_join(log_data %>% select(document, time_variable, count_log), by=c("document", "time_variable"))

  #We put the unknown days at 0
  complete_set = complete_set %>%
    filter(start_time <= time_variable) %>%
    mutate(count_log = ifelse(is.na(count_log), 0, count_log))

  #We create the diff_days values using the first day of the publication.
  complete_set = complete_set %>% ungroup() %>% mutate(time_sequency = as.numeric(time_variable-start_time))

  return(complete_set)
}
