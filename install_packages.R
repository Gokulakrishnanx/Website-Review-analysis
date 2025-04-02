# Install required packages
required_packages <- c(
    "shiny",
    "shinydashboard",
    "tidytext",
    "dplyr",
    "ggplot2",
    "wordcloud2",
    "sentimentr",
    "DT",
    "plotly",
    "tidyr",
    "corrplot",
    "fmsb",
    "heatmaply",
    "ggridges",
    "viridis",
    "scales"
)

# Function to install missing packages
install_if_missing <- function(package) {
    if (!require(package, character.only = TRUE)) {
        install.packages(package)
    }
}

# Install all required packages
sapply(required_packages, install_if_missing) 