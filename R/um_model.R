
#' A function to retrieve the anomalies using rds.
#' @export um_model
#' @param clean_log_data A dataset of logs aggregated by publications and per days already cleaned by um_clean
#' @param knots The number of knots fitted to the knots. By default 3. A larger value may better fit log data with a long/complicated history, at the expense of being to overfitted to anomalous episode.
#' @param min_observations The minimal number of observations to derive the model. By default 6 with 3 knots.
#' @param min_anomaly_ratio The threshold of anomaly rate (by default 5 but can be any number between 0 and 100)
#' @examples
#'  um_model(clean_log_data, knots = 3, min_observations = 7, min_anomaly_ratio = 5)
um_model <- function(clean_log_data, knots = 3, min_observations = 7, min_anomaly_ratio = 5) {
  library(dplyr)

  #We create a model for each publication in log_data.
  anomaly_prediction_models = clean_log_data %>%
    group_by(document) %>%
    filter(n()>=min_observations) %>% #We have to store at least a number of observations equal to min_observations.
    do(model_rcs = um_rcs_group(.$time_sequency, .$count_log, knots), count_log = .$count_log, time_sequency = .$time_sequency, date = .$time_variable)

  #We extract the anomaly rate using ad_rcs_anomalies.
  anomaly_prediction <- anomaly_prediction_models %>%
    do(document = .$document, predictions = um_rcs_anomalies(.$model_rcs, .$count_log, .$time_sequency, knots)) %>%
    tidyr::unnest(document) %>%
    tidyr::unnest(predictions) %>%
    ungroup()

  #We keep only the upper bounded anomalies and applies a min value of anomaly rate to not be overcrowded with secondary events.
  anomaly_prediction <- anomaly_prediction %>%
    filter(count_log>upr) %>%
    filter(anomaly_ratio > min_anomaly_ratio)

  anomaly_prediction <- anomaly_prediction %>%
    inner_join(clean_log_data %>% select(document, time_variable, time_sequency), by=c("document", "time_sequency")) %>%
    select(-fit, -lwr, -upr)

  return(anomaly_prediction)
}
