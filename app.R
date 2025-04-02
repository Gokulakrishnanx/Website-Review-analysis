library(shiny)
library(shinydashboard)
library(tidytext)
library(dplyr)
library(ggplot2)
library(wordcloud2)
library(sentimentr)
library(DT)
library(plotly)
library(tidyr)
library(fmsb)
library(heatmaply)
library(ggridges)
library(viridis)

# UI Definition
ui <- dashboardPage(
    dashboardHeader(title = "MacBook Review Analysis"),
    dashboardSidebar(
        sidebarMenu(
            menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
            menuItem("Advanced Analytics", tabName = "advanced", icon = icon("chart-line")),
            menuItem("Additional Insights", tabName = "insights", icon = icon("chart-bar")),
            menuItem("Data", tabName = "data", icon = icon("database"))
        )
    ),
    dashboardBody(
        tags$head(
            tags$style(HTML("
                .content-wrapper, .right-side {
                    background-color: #f8f9fa;
                }
                .box {
                    border-radius: 15px;
                    box-shadow: 0 4px 6px rgba(0,0,0,0.1);
                }
            "))
        ),
        tabItems(
            # Dashboard Tab
            tabItem(
                tabName = "dashboard",
                fluidRow(
                    box(
                        title = "Input Reviews",
                        status = "primary",
                        solidHeader = TRUE,
                        width = 12,
                        textAreaInput("reviewInput", 
                                    "Paste MacBook reviews here:", 
                                    rows = 5,
                                    width = "100%"),
                        actionButton("analyzeBtn", "Analyze Reviews", 
                                   class = "btn-primary")
                    )
                ),
                fluidRow(
                    box(
                        title = "Sentiment Analysis",
                        status = "info",
                        solidHeader = TRUE,
                        width = 6,
                        plotOutput("sentimentPlot")
                    ),
                    box(
                        title = "Word Cloud",
                        status = "info",
                        solidHeader = TRUE,
                        width = 6,
                        wordcloud2Output("wordCloud")
                    )
                ),
                fluidRow(
                    box(
                        title = "Top Features",
                        status = "success",
                        solidHeader = TRUE,
                        width = 12,
                        DTOutput("featureTable")
                    )
                )
            ),
            
            # Advanced Analytics Tab
            tabItem(
                tabName = "advanced",
                fluidRow(
                    box(
                        title = "Sentiment Time Series",
                        status = "primary",
                        solidHeader = TRUE,
                        width = 6,
                        plotlyOutput("sentimentTimeSeries")
                    ),
                    box(
                        title = "Feature Correlation Matrix",
                        status = "primary",
                        solidHeader = TRUE,
                        width = 6,
                        plotOutput("correlationMatrix")
                    )
                ),
                fluidRow(
                    box(
                        title = "Feature Distribution",
                        status = "warning",
                        solidHeader = TRUE,
                        width = 6,
                        plotOutput("featureDistribution")
                    ),
                    box(
                        title = "Sentiment vs. Review Length",
                        status = "warning",
                        solidHeader = TRUE,
                        width = 6,
                        plotOutput("sentimentLength")
                    )
                )
            ),
            
            # Additional Insights Tab
            tabItem(
                tabName = "insights",
                fluidRow(
                    box(
                        title = "Feature Heatmap",
                        status = "danger",
                        solidHeader = TRUE,
                        width = 6,
                        plotlyOutput("featureHeatmap")
                    ),
                    box(
                        title = "Feature Radar Chart",
                        status = "danger",
                        solidHeader = TRUE,
                        width = 6,
                        plotOutput("radarChart")
                    )
                ),
                fluidRow(
                    box(
                        title = "Sentiment Distribution by Feature",
                        status = "success",
                        solidHeader = TRUE,
                        width = 6,
                        plotOutput("sentimentRidges")
                    ),
                    box(
                        title = "Word Frequency Trends",
                        status = "success",
                        solidHeader = TRUE,
                        width = 6,
                        plotOutput("wordFrequencyTrends")
                    )
                )
            ),
            
            # Data Tab
            tabItem(
                tabName = "data",
                box(
                    title = "Raw Data",
                    width = 12,
                    DTOutput("rawData")
                )
            )
        )
    )
)

# Server Logic
server <- function(input, output, session) {
    
    # Reactive value to store the analysis results
    reviews_data <- reactiveVal(NULL)
    
    # Analyze button observer
    observeEvent(input$analyzeBtn, {
        req(input$reviewInput)
        
        # Split reviews into sentences
        reviews <- data.frame(
            text = unlist(strsplit(input$reviewInput, "\\. |\\.|\\n")),
            timestamp = Sys.time() - (1:length(unlist(strsplit(input$reviewInput, "\\. |\\.|\\n")))) * 60,
            stringsAsFactors = FALSE
        ) %>%
        filter(text != "")
        
        # Store the data
        reviews_data(reviews)
        
        # Perform sentiment analysis
        sentiment_scores <- sentiment(reviews$text)
        
        # Update plots and tables
        updateAnalysis(sentiment_scores, reviews)
    })
    
    # Function to update all analyses
    updateAnalysis <- function(sentiment_scores, reviews) {
        # Sentiment Plot
        output$sentimentPlot <- renderPlot({
            sentiment_summary <- data.frame(
                sentiment = ifelse(sentiment_scores$sentiment > 0, "Positive",
                                 ifelse(sentiment_scores$sentiment < 0, "Negative", "Neutral"))
            ) %>%
            count(sentiment)
            
            ggplot(sentiment_summary, aes(x = "", y = n, fill = sentiment)) +
                geom_bar(stat = "identity", width = 1) +
                coord_polar("y") +
                scale_fill_manual(values = c("Negative" = "#F44336",
                                           "Neutral" = "#FFC107",
                                           "Positive" = "#4CAF50")) +
                theme_minimal() +
                theme(axis.title = element_blank())
        })
        
        # Word Cloud
        output$wordCloud <- renderWordcloud2({
            words <- reviews %>%
                unnest_tokens(word, text) %>%
                anti_join(stop_words) %>%
                count(word, sort = TRUE) %>%
                filter(n > 1)
            
            wordcloud2(words)
        })
        
        # Feature Table
        output$featureTable <- renderDT({
            features <- c("performance", "battery life", "display", "keyboard",
                        "price", "design", "portability", "software")
            
            feature_counts <- sapply(features, function(feature) {
                sum(grepl(feature, tolower(reviews$text)))
            })
            
            data.frame(
                Feature = tools::toTitleCase(names(feature_counts)),
                Mentions = feature_counts
            ) %>%
            arrange(desc(Mentions)) %>%
            datatable(options = list(pageLength = 5))
        })
        
        # Sentiment Time Series
        output$sentimentTimeSeries <- renderPlotly({
            sentiment_time <- data.frame(
                timestamp = reviews$timestamp,
                sentiment = sentiment_scores$sentiment
            )
            
            plot_ly(sentiment_time, x = ~timestamp, y = ~sentiment, type = "scatter", mode = "lines+markers") %>%
                layout(title = "Sentiment Over Time",
                       xaxis = list(title = "Time"),
                       yaxis = list(title = "Sentiment Score"))
        })
        
        # Feature Distribution
        output$featureDistribution <- renderPlot({
            features <- c("performance", "battery life", "display", "keyboard",
                        "price", "design", "portability", "software")
            
            feature_matrix <- sapply(features, function(feature) {
                as.numeric(grepl(feature, tolower(reviews$text)))
            })
            
            feature_data <- as.data.frame(feature_matrix) %>%
                gather(key = "feature", value = "present")
            
            ggplot(feature_data, aes(x = feature, fill = factor(present))) +
                geom_bar() +
                theme_minimal() +
                theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
                scale_fill_manual(values = c("#E0E0E0", "#2196F3"),
                                labels = c("Not Mentioned", "Mentioned")) +
                labs(fill = "Status", x = "Feature", y = "Count")
        })
        
        # Sentiment vs Review Length
        output$sentimentLength <- renderPlot({
            review_data <- data.frame(
                length = nchar(reviews$text),
                sentiment = sentiment_scores$sentiment
            )
            
            ggplot(review_data, aes(x = length, y = sentiment)) +
                geom_point(alpha = 0.6, color = "#2196F3") +
                geom_smooth(method = "loess", color = "#F44336") +
                theme_minimal() +
                labs(x = "Review Length (characters)", y = "Sentiment Score")
        })
        
        # Raw Data Table
        output$rawData <- renderDT({
            reviews %>%
                mutate(Sentiment = sentiment_scores$sentiment) %>%
                datatable(options = list(pageLength = 10))
        })
        
        # Feature Heatmap
        output$featureHeatmap <- renderPlotly({
            features <- c("performance", "battery life", "display", "keyboard",
                        "price", "design", "portability", "software")
            
            feature_matrix <- sapply(features, function(feature) {
                as.numeric(grepl(feature, tolower(reviews$text)))
            })
            
            colnames(feature_matrix) <- tools::toTitleCase(features)
            
            heatmaply(feature_matrix,
                     colors = viridis(n=256),
                     show_dendrogram = TRUE,
                     dendrogram = "both",
                     scale = "none",
                     main = "Feature Co-occurrence Heatmap")
        })
        
        # Radar Chart
        output$radarChart <- renderPlot({
            features <- c("performance", "battery life", "display", "keyboard",
                        "price", "design", "portability", "software")
            
            feature_counts <- sapply(features, function(feature) {
                sum(grepl(feature, tolower(reviews$text)))
            })
            
            # Create radar chart data
            radar_data <- data.frame(
                Feature = tools::toTitleCase(features),
                Count = feature_counts
            )
            
            # Normalize counts for radar chart
            max_count <- max(radar_data$Count)
            radar_data$Count <- radar_data$Count / max_count * 100
            
            # Create radar chart
            radarchart(data.frame(
                rbind(rep(100, 8), rep(0, 8), radar_data$Count)
            ),
            axistype = 1,
            pcol = "#2196F3",
            pfcol = scales::alpha("#2196F3", 0.5),
            plwd = 2,
            cglcol = "grey",
            cglty = 1,
            axislabcol = "grey",
            vlcex = 0.8,
            title = "Feature Distribution Radar Chart")
        })
        
        # Sentiment Distribution by Feature (Ridges Plot)
        output$sentimentRidges <- renderPlot({
            features <- c("performance", "battery life", "display", "keyboard",
                        "price", "design", "portability", "software")
            
            # Create feature-sentiment data
            feature_sentiment <- data.frame()
            for (feature in features) {
                feature_present <- grepl(feature, tolower(reviews$text))
                if (sum(feature_present) > 0) {
                    feature_sentiment <- rbind(feature_sentiment,
                                             data.frame(
                                                 Feature = tools::toTitleCase(feature),
                                                 Sentiment = sentiment_scores$sentiment[feature_present]
                                             ))
                }
            }
            
            ggplot(feature_sentiment, aes(x = Sentiment, y = Feature, fill = Feature)) +
                geom_density_ridges(alpha = 0.7) +
                theme_minimal() +
                scale_fill_viridis(discrete = TRUE) +
                labs(title = "Sentiment Distribution by Feature")
        })
        
        # Word Frequency Trends
        output$wordFrequencyTrends <- renderPlot({
            # Get top words
            words <- reviews %>%
                unnest_tokens(word, text) %>%
                anti_join(stop_words) %>%
                count(word, sort = TRUE) %>%
                filter(n > 1) %>%
                head(10)
            
            # Create time-based word frequency data
            word_freq <- reviews %>%
                unnest_tokens(word, text) %>%
                anti_join(stop_words) %>%
                filter(word %in% words$word) %>%
                count(timestamp, word) %>%
                complete(timestamp, word, fill = list(n = 0))
            
            ggplot(word_freq, aes(x = timestamp, y = n, color = word)) +
                geom_line() +
                geom_point() +
                theme_minimal() +
                scale_color_viridis(discrete = TRUE) +
                labs(title = "Top Word Frequency Trends",
                     x = "Time",
                     y = "Frequency")
        })
        
        # Correlation Matrix
        output$correlationMatrix <- renderPlot({
            features <- c("performance", "battery life", "display", "keyboard",
                        "price", "design", "portability", "software")
            
            feature_matrix <- sapply(features, function(feature) {
                as.numeric(grepl(feature, tolower(reviews$text)))
            })
            
            correlation_matrix <- cor(feature_matrix)
            
            corrplot::corrplot(correlation_matrix, method = "color",
                             type = "upper", order = "hclust",
                             addCoef.col = "black", tl.col = "black",
                             tl.srt = 45, diag = FALSE)
        })
    }
}

# Run the app
shinyApp(ui = ui, server = server) 