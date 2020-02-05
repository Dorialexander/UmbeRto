
#' A function to retrieve the anomalous ratio using the contrast with the predicted value in the rcs model.
#'
#' @param fit An rcs model already fitted to the aggregated logs.
#' @param count_visitor A vector of number of visitor per day.
#' @param diff_days A vector containing the list of day since the start of the recording.
#' @param knots The number of knots fitted to the knots
#' @return A vector of confidence interval in regards to the model.
#' @examples
#'  tds_model(text_count, classification_matrix = FALSE, prob_state = TRUE, min_label = 70, max_label = 150, cost_variable = 0)
ad_rcs_anomalies <- function(fit, count_visitor, diff_days, knots){

  #We create a dataframe for each logs per publication
  appd <- data_frame(diff_days, count_visitor)

  #We define the knots value depending on the total number of knots and the diff_days vector.
  knot_defined <- Hmisc::rcspline.eval(appd$diff_days, nk=knots)

  #We fit the model and retrieve the sigma values.
  fit_sigma_ratio <- augment(fit)$.sigma

  #We take the mean of the sigma values.
  sigma_mean <- mean(fit_sigma_ratio)

  #We define a sigma ratio using the sigma mean.
  #Concretely a publication with a high variability of visits between days will be penalized
  #Conversely, unusual episodes will stand out for publications with a very smooth curve
  fit_sigma_ratio <- (abs(sigma_mean-fit_sigma_ratio)/sigma_mean)*100

  #We deduce the confidence level.
  fit_confidence <- data.frame(appd, predict(fit, interval="prediction"), fit_sigma_ratio)

  return(fit_confidence)
}
