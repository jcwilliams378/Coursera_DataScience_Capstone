library(DT)
library(shiny)
library(shinythemes)
library(RColorBrewer)
options(warn=-1)
colfunc <- colorRampPalette(c("blue", "lightblue"))

ui <- fluidPage(theme = shinytheme("cerulean"),
  pageWithSidebar(
    
    # Application title
    headerPanel("NLP Coursera Capstone Final Project"),
    
  sidebarPanel(
      strong("Author:"),
      h4("Jeffrey Williams"),
      h6("28 DEC, 2016"),
      h3("Instructions:"),
      p("Enter partial phrase into the text input below and a histogram of words returned will appear to the right with predicted words sorted by the best prediciton score [1]."),
      p("The predictive model parameters can be tuned below to adjust the number of results the predictor will return (per n-gram or total) or the maximum number 'n' of grams that will be evaulated on the partial phrase."),
    textInput("text", "Enter Partial Phrase:", "I love you"),
    verbatimTextOutput("word"),
    verbatimTextOutput("calc_time"),
    sliderInput("max_final_results","Maximum Final Results:", min = 1, max = 100, value = 5),
    sliderInput("max_gram","Maximum N-gram:", min = 2, max = 5, value = 5),
    sliderInput("max_per_gram","Maximum Results Per Gram:", min = 1, max = 20, value = 3),
    h3("Model:"),
    p("The predictive model is created based on the 'stupid backoff' method [1] on a training set using a blend of twitter, news, and blog text corupus that has been cleaned and had profanity removed. The training set represents 0.3% of the total dataset provided by the course and is able to achive accuracy ranging from ~37-44% across n-grams ranging from 2-5 words with an expected prediction time of ~500 ms or less. The accuracy results reported are based on a test data set representing 2-5 n-gram phrases taken from a subset of 2% of the total blended data set provided where phrases occuring less than 4 times in frequency are dropped and the 'actual' expected result is defined as the highest frequency terminal word for the phrases recovered from the n-gram creation."),
    h3("References:"),
    p("[1] Thorsten Brants Ashok C. Popat Peng Xu Franz J. Och Jeffrey Dean, 2007, Large Language Models in Machine Translation, Proceedings of the 2007 Joint Conference on Empirical Methods in Natural Language Processing and Computational Natural Language Learning, pp. 858–867, Prague.")
  ),
  mainPanel(
    plotOutput("results_bar"),
    dataTableOutput("table")
  )
))

source("./predict_word.R")

db <- dbConnect(SQLite(), dbname="./en_final.sqlite_0.003")

server <- function(input, output) {
  result <- reactive({
    start_prediction_time <- proc.time()
    word <- predict_word(input$text,
                         db,
                         num_final_predictions = input$max_final_results,
                         num_top_words = input$max_per_gram,
                         max_gram = input$max_gram)
    end_prediction_time <- proc.time()
    retrival_time <- end_prediction_time - start_prediction_time
    elapse_retrival_time <- retrival_time[3][[1]]
    
    if (!is.data.frame(word)){
      word = data.frame(Predicted_Word = "No Results Returned!", Score = 0)
      print(word)
      print(word$Predicted_Word[1])
      
    }
        
    dataSet <- list(word$Predicted_Word[[1]],round(1e3*elapse_retrival_time,0))
    return(list(dataSet,word))
  })
  
  output$word <- renderText(result()[[1]][[1]])
  output$calc_time <- renderText(paste("Total elapsed calculation Time: ", result()[[1]][[2]], "ms"))
  output$table <-  renderDataTable({result()[[2]]})
  # Fill in the spot we created for a plot
  output$results_bar <- renderPlot({
    # Render a barplot
    x <- result()[[2]]$Score
    names(x) <- result()[[2]]$Predicted_Word
      
    barplot(x, 
            col = colfunc(length(x)),
            main="Predicted Results by Score",
            ylab="Score")
  })
}
shinyApp(ui, server)
