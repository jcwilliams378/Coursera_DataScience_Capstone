library(RSQLite)
library(tm)
library(magrittr)
library(stringr)

#change this for your final project directory where you will store data locally
setwd("~/Documents/Data Science Courses/Coursera/Data Science Specialization (JHU)/10 Capstone Project/")

db <- dbConnect(SQLite(), dbname="~/Documents/Data Science Courses/Coursera/Data Science Specialization (JHU)/10 Capstone Project/final/en_US/en_final.sqlite")

source("~/Documents/Data Science Courses/Coursera/Data Science Specialization (JHU)/Coursera_DataScience_Capstone/scripts/predict_word.R")

pct <- 0.003
results <- data.frame()
result_row <- 1

for (ng in 2:5){
  t <- read.csv(paste("./final/en_US/test_set/t",ng,"_test_set.csv", sep = ""))
  
  for(sample_id in 1:nrow(t)){
    
    start_prediction_time <- proc.time()
    pred <- predict_word(as.character(t[sample_id,"partial_phrase"]), db, num_final_predictions = 1, max_gram = ng)
    end_prediction_time <- proc.time()
    retrival_time <- end_prediction_time - start_prediction_time
    elapse_retrival_time <- round(1e3*retrival_time[3][[1]],0)
    
    
      
    if(is.data.frame(pred)){
      pred_word <- pred$Predicted_Word[[1]]
      if(is.na(pred_word)){pred_word <- "No Word Predicted!"}
      if(pred_word == as.character(t[sample_id,"actual_word"])){
        results[result_row,"Result"] <- 1
      }
      else{
        results[result_row,"Result"] <- 0
      }
    }
    else{
      results[result_row,"Result"] <- 0
      pred_word <- "No Word Predicted!"
    }
    results[result_row,"partial_phrase"] <- as.character(t[sample_id,"partial_phrase"])
    results[result_row,"predicted_word"] <- pred_word
    results[result_row,"actual_word"] <- as.character(t[sample_id,"actual_word"])
    results[result_row,"ng"] <- ng
    results[result_row,"pred_time_ms"] <- elapse_retrival_time
    results[result_row,"pct_data"] <- pct
  
    result_row = result_row + 1  
  }
  
}

write.csv(results, file = paste("./final/en_US/accuracy results/accuracy_results_modeltrain_",pct,"pct.csv", sep = ""))

dbDisconnect(db)
