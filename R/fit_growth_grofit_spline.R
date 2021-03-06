#' Fit Smooth Splines to Growth Data (Using grofit)
#' 
#' \code{fit_growth_grofit_spline} fits a smooth spline to a tidy growth data set
#' using \code{\link[grofit]{gcFitSpline}} from the \pkg{grofit} package.
#' 
#' @inheritParams fit_growth_grofit_parametric
#' @param ... Additional arguments for \code{\link[grofit]{gcFitSpline}}
#'
#' @return A \code{growthcurve} object
#' 
#' @seealso \code{\link{fit_growth_spline}}, growthcurve's native function    
#' for fitting smooth splines to growth data
#' @export
#'
#' @seealso \link{grofit_wrappers}
#' @examples
#' \dontrun{
#' # Fit the data given in columns Time and OD600
#' fit_growth_grofit_spline(mydata, Time, OD600)}
#'
fit_growth_grofit_spline <- function(df, time, data, ...) {
    fit_growth_grofit_spline_(
        df = df,
        time_col = lazyeval::lazy(time),
        data_col = lazyeval::lazy(data),
        ...
    )
}


#' @inheritParams fit_growth_grofit_parametric_
#' @export
#' @rdname fit_growth_grofit_spline
#' @examples
#' \dontrun{
#' # Fit the data given in columns Time and OD600
#' fit_growth_grofit_spline_(df=mydata, time_col = "Time", data_col = "OD600")}
#'
fit_growth_grofit_spline_ <- function(df, time_col, data_col, ...) {
    stop_without_package("grofit")
    
    growth_data <- lazyeval::lazy_eval(data_col, df)
    time_data <- lazyeval::lazy_eval(time_col, df)

    if (any(is.na(time_data))) stop("NAs in time data")
    if (any(is.na(growth_data))) stop("NAs in growth data")

    tryCatch(gres <- grofit::gcFitSpline(time = time_data,
                                         data = growth_data,
                                        ...),
             warning = function(w) stop(w))

    fit_dydt <- diff(gres$fit.data) / diff(gres$fit.time)
    i_max_rate <- which.max(fit_dydt)

    result <- growthcurve(
        type = paste0(c("grofit", "spline"), collapse = "_"),
        model = gres$spline,
        fit = list(
            x = gres$fit.time,
            y = gres$fit.data,
            residuals = stats::residuals(gres$spline)
        ),
        f = function(x = time_data) stats::predict(gres$spline, x)$y,
        parameters = list(
            asymptote = gres$parameters$A,
            max_rate = list(
                time = gres$fit.time[i_max_rate],
                value = gres$fit.data[i_max_rate],
                rate = gres$parameters$mu,
                lambda = gres$parameters$lambda
            ),
            augc = gres$parameters$integral
        ),
        df = df,
        time_col = as.character(time_col)[1],
        data_col = as.character(data_col)[1]
    )
    result$grofit <- gres
    class(result) <- c(class(result), "grofit")
    result
}
