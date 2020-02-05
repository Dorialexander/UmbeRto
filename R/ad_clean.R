
#' A function to retrieve the anomalies using rds.
#'
#' @param log_data A dataset of logs aggregated by publications and per days.
#' @examples
#'  ad_clean(log_data)
ad_clean <- function(log_data, document, recorded_date, logs) {

  #Lazy non-standard approach
  document_col = quo_name(enquo(document))
  recorded_date_col = quo_name(enquo(recorded_date))
  logs_col = quo_name(enquo(logs))

  log_data = log_data %>% rename("name" := !!document_col, "server_time" :=  !!recorded_date_col, "count_visitor" := !!logs_col)

  #We locate the first time publication were registered in the logs.
  days_set = log_data %>%
    group_by(name) %>%
    summarise(start_time = min(server_time)) %>%
    ungroup()

  #We get the complete set of dates recorded regardless of the publications.
  #(Perhaps switch to min/max date value.)
  date_set = log_data %>% group_by(server_time) %>% summarise()

  #We extend the days set to have all the possible combinations of days and publications
  complete_set = days_set %>%
    mutate(joining = "j") %>%
    inner_join(date_set %>% mutate(joining = "j"), by=c("joining"))

  #We merge back on the detailed anomalies data in log_data
  complete_set = complete_set %>%
    select(-joining) %>%
    left_join(log_data %>% select(name, server_time, count_visitor, count_visit), by=c("name", "server_time"))

  #We put the unknown days at 0
  complete_set = complete_set %>%
    filter(start_time <= server_time) %>%
    mutate(count_visitor = ifelse(is.na(count_visitor), 0, count_visitor)) %>%
    mutate(count_visit = ifelse(is.na(count_visit), 0, count_visit))

  #We create the diff_days values using the first day of the publication.
  complete_set = complete_set %>% ungroup() %>% mutate(diff_days = as.numeric(server_time-start_time))

  return(complete_set)
}
