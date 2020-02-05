
#' A function to retrieve the anomalies using rds.
#'
#' @param log_data A dataset of logs aggregated by publications and per days.
#' @param segment_size The standard size of a continuous segment of text. Remaining segments within a document will be discarded. If set to 0 (default), documents will be used as the main units.
#' @param knots The number of knots fitted to the knots. By default 3. A larger value may better fit log data with a long/complicated history, at the expense of being to overfitted to anomalous episode.
#' @param min_observations The minimal number of observations to derive the model. By default 6 with 3 knots.
#' @param min_sigma_ratio The threshold of anomaly rate (by default 5 but can be any number between 0 and 100)
#' @examples
#'  tds_clean(text_count, segment_size = 90, min_doc_count = 4, max_word_set = 3000)
ad_model <- function(log_data, knots = 3, min_observations = 6, min_sigma_ratio = 5) {
  #We create a model for each publication in log_data.
  url_prediction_models = log_data %>%
    group_by(name) %>%
    filter(n()>6) %>% #We have to store at least 6 observations.
    do(model_rcs = ad_rcs_group(.$diff_days, .$count_visitor, knots), count_visitor = .$count_visitor, diff_days = .$diff_days, date = .$server_time)

  #We extract the anomaly rate using ad_rcs_anomalies.
  url_prediction <- url_prediction_models %>%
    do(name = .$name, predictions = ad_rcs_anomalies(.$model_rcs, .$count_visitor, .$diff_days, knots)) %>%
    unnest(name) %>%
    unnest(predictions) %>%
    ungroup()

  #We keep only the upper bounded anomalies and applies a min value of anomaly rate to not be overcrowded with secondary events.
  url_prediction <- url_prediction %>%
    filter(count_visitor>upr) %>%
    filter(fit_sigma_ratio > min_sigma_ratio)

  url_prediction <- url_prediction %>%
    inner_join(log_data %>% select(name, server_time, diff_days), by=c("name", "diff_days")) %>%
    select(-fit, -lwr, -upr)

  return(url_prediction)
}
