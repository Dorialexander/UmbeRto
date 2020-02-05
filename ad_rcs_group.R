
#' A function to apply an RCS model to log data.
#'
#' @param count_visitor A vector of number of visitor per day.
#' @param diff_days A vector containing the list of day since the start of the recording.
#' @param knots The number of knots fitted to the knots. By default 3. A larger value may better fit log data with a long/complicated history, at the expense of being to overfitted to anomalous episode.
#' @return The results of the SVM model.
ad_rcs_group <- function(diff_days, count_visitor, knots=3) {

  appd = data_frame(diff_days, count_visitor)
  fit <- lm(count_visitor ~ rms::rcs(diff_days, knots), data=appd)
  prediction <- predict(fit, newdata = appd)
  return(fit)
}
