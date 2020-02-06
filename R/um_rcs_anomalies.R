
#' A function to retrieve the anomalous ratio using the contrast with the predicted value in the rcs model.
#' The function is preferably used within do or map.
#' @export um_rcs_anomalies
#' @param fit An rcs model already fitted to the aggregated logs.
#' @param count_log A vector of number of aggregated logs
#' @param time_sequency A vector containing a time sequence (usually days) on which the aggregation has been performed.
#' @param knots The number of knots fitted to the knots
#' @return A vector of confidence interval in regards to the model.
#' @examples
#'  um_rcs_anomalies(fit, count_log, time_sequency, knots)
um_rcs_anomalies <- function(fit, count_log, time_sequency, knots = 3){

  #We create a dataframe for each logs per publication
  appd <- data_frame(time_sequency, count_log)

  #We define the knots value depending on the total number of knots and the time_sequency vector.
  knot_defined <- Hmisc::rcspline.eval(appd$time_sequency, nk=knots)

  #We fit the model and retrieve the sigma values.
  anomaly_ratio <- broom::augment(fit)$.sigma

  #We take the mean of the sigma values.
  sigma_mean <- mean(anomaly_ratio)

  #We define a sigma ratio using the sigma mean.
  #Concretely a publication with a high variability of visits between days will be penalized
  #Conversely, unusual episodes will stand out for publications with a very smooth curve
  anomaly_ratio <- (abs(sigma_mean-anomaly_ratio)/sigma_mean)*100

  #We deduce the confidence level.
  #And we remove an annoying error message in predict
  anomaly_confidence <- data.frame(appd, suppressWarnings(predict(fit, interval="prediction")), anomaly_ratio)

  return(anomaly_confidence)
}
