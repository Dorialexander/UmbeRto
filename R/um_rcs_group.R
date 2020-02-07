
#' A function to apply an RCS model to log data.
#' @export um_rcs_group
#' @param count_log A vector of number of visitor per day.
#' @param time_sequency A vector containing the list of day since the start of the recording.
#' @param knots The number of knots fitted to the knots. By default 3. A larger value may better fit log data with a long/complicated history, at the expense of being to overfitted to anomalous episode.
#' @return The results of the SVM model.
#' um_rcs_group(time_sequency, count_log, knots=3)
um_rcs_group <- function(time_sequency, count_log, knots=3) {

  library(dplyr)
  #Putting the time_sequency and count_log data vectors in a data frame.
  appd = tibble(time_sequency, count_log)

  #Fitting the model
  fit = lm(count_log ~ rms::rcs(time_sequency, knots), data=appd)

  return(fit)
}
