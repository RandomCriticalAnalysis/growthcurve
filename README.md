growthcurve
===========

growthcurve is an [R](http://r-project.org) package for analyzing
[biological growth](https://en.wikipedia.org/wiki/Bacterial_growth), or
"growth curves". It is designed to integrate into modern workflows,
allowing it to be used in conjunction with other tools.

This package is currently a wrapper for the
[grofit](http://cran.r-project.org/web/packages/grofit/index.html)
package, which is no longer being developed. This is temporary, as I
plan to eventually make growthcurve an independent tool with more
flexibility.

growthcurve is released with a [Contributor Code of
Conduct](CONDUCT.md).  
By participating in this project, you agree to abide by its terms.

Installation
------------

growthcurve is not quite ready to be available on
[CRAN](http://cran.r-project.org), but you can use
[devtools](http://cran.r-project.org/web/packages/devtools/index.html)
to install the current development version:

        if(!require("devtools")) install.packages("devtools")
        devtools::install_github("briandconnelly/growthcurve", build_vignettes=TRUE)

**Note that a lot of changes are being made, so things might not always
work.**

Fitting Growth Curves
---------------------

growthcurve's most important function is `fit_growth`, which fits a
growth curve to the given data. Here, we'll fit a growth curve to one
replicate population from the included `pseudomonas` data set, which has
columns `Time` and `CFUmL`:

    library(dplyr)
    library(growthcurve)

    rep1 <- filter(pseudomonas, Replicate == 1 & Strain == "PAO1")
    myfit <- fit_growth(rep1, Time, CFUmL)

grofit is a bit chatty, so you'll see some messages being printed to the screen.

Even better, we can do this all at once with pipes:

    myfit <- pseudomonas %>%
        filter(Replicate == 1 & Strain == "PAO1") %>%
        fit_growth(Time, CFUmL)

By default, `fit_growth` will try a few [parametric
models](https://en.wikipedia.org/wiki/Parametric_model) and return the
best one according to
[AIC](https://en.wikipedia.org/wiki/Akaike_information_criterion). The
`type` argument can be used to use a specific model type. Here, we'll
use a logistic function:

    library(dplyr)
    library(growthcurve)

    rep1 <- filter(pseudomonas, Replicate == 1 & Strain == "PAO1")
    myfit <- fit_growth(rep1, Time, CFUmL, type = "logistic")

Other options include `gompertz`, `gompertz.exp`, `richards`, and
`spline`. These can also be done directly using `fit_growth_gompertz`,
`fit_gowth_gompertz.exp`, `fit_growth_richards`, and
`fit_growth_spline`. There's also a `fit_growth_parametric`, which finds
the best among the parametric models.

Interpreting Results
--------------------

coming soon!

Visualizing Growth Curves
-------------------------

growthcurve includes tools for visualizing growth curves using either
R's base graphics or
[ggplot2](https://cran.r-project.org/web/packages/ggplot2/index.html).

    plot(myfit, show_raw=TRUE, show_maxrate=TRUE, show_asymptote=FALSE)

![](figures/base_example-1.png)<!-- -->

With ggplot, we can add growth curves to plots using `stat_growthcurve`.

    library(ggplot2)

    pao1data <- filter(pseudomonas, Strain == "PAO1")
    ggplot(data = pao1data, aes(x = Time, y = CFUmL, color = Replicate)) +
        geom_point(shape = 1) +
        stat_growthcurve()

![](figures/ggplot-1.png)<!-- -->


Vignettes
---------

The included vignettes contain more complete examples of how
`growthcurve` can be used:

-   [Fitting a logistic growth curve](vignettes/logistic-growth.Rmd)
-   Comparing growth - coming soon!

Related Links
-------------

-   [grofit](http://cran.r-project.org/web/packages/grofit/index.html)

License
-------

growthcurve is released under the Simplified BSD License.
