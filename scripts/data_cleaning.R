# This script cleans a prepares the data for analysis:

#import the text mining library

library(tm)
library(ggplot2)  
library(data.table)
library(slam)

data_cleaning <- function(){
  
  test_gen = FALSE
  
  #change this for your final project directory where you will store data locally
  setwd("~/Documents/Data Science Courses/Coursera/Data Science Specialization (JHU)/10 Capstone Project/")
  
  import_data <- function(fname){
          
          f_path <- paste("./final/en_US/", fname, sep = "")
          conn.in <- file(f_path)
          data_in <- readLines(conn.in)
          close(conn.in)
          
          print(paste("Number of lines in the",fname ,"dataset: ",length(data_in)))
          print(paste(fname, "info (size [MB]): ", file.info(f_path)$size/1048576))
          
          return(data_in)
  }
  
  import_profanity_data <- function(prof_fname){
    f_path <- paste("./final/en_US/", prof_fname, sep = "")
    conn.in <- file(f_path)
    data_in <- readLines(conn.in)
    close(conn.in)
    
    return(data_in)
  }
  
  # Preprocessing
  
  # In this step, we want to remove numbers, capitialzation, common words, punctuation, and prepare the text for analysis.
  combined.train <- import_data("combined.training_set.txt")
  comb_text <- Corpus(VectorSource(combined.train))
  
  if(test_gen){
    combined.test <- import_data("combined.test_set.txt")
    comb_text_test <- Corpus(VectorSource(combined.test))
  }

  text_cleaning <- function(text){
          # Removing punctuation
          text <- tm_map(text, removePunctuation)  
          print("Removed punctuation")
          
          # Removing numbers
          text <- tm_map(text, removeNumbers)  
          print("Removed numbers")
          
          # Converting to lowercase
          text <- tm_map(text, tolower)  
          print("Removed lowercase")
          
          # Remove profanities:
          profanity_list <- import_profanity_data("en_Profanities.txt")
          text <- tm_map(text, removeWords, profanity_list)
          print("Removed profanities")
          
          # Stripping unnecessary whitespace
          text <- tm_map(text, stripWhitespace)
          print("Removed whitespace")

          #format back to a plaintext document:
          text <- tm_map(text, PlainTextDocument)
          print("format to plain text")
          
          return(text)
  }

  tdm_Ngram <- function(my_corpus, ng){
    mytokTxts <- function(x) unlist(lapply(ngrams(words(x), ng), paste, collapse = " "), use.names = FALSE)
    
    tdm <- TermDocumentMatrix(my_corpus, control = list(tokenize = mytokTxts)) # create tdm from n-grams
    
    return(tdm)
  }
  
  #create a function for generating dataframe of frequent terms
  frequent_terms <- function(tdm, low_freq = 50, num = 10){ # Show this many top frequent terms
    
    if (nrow(tdm) < num){
      num <- nrow(tdm)
    }
    
    FreqTerms <- findFreqTerms(tdm, lowfreq = low_freq)
    v <- sort(row_sums(tdm[FreqTerms,], na.rm = T),decreasing=TRUE)
    d <- data.frame(word = names(v),freq=v)
    
    return(head(d,num))
  }
  
  export_ng <- function(my_corpus, type, ng, num_words = Inf, low_freq = 1, overwrite = FALSE){
    if (!file.exists(paste("./final/en_US/",type,"_ng_",ng,".csv",sep = "")) || overwrite){
      print(paste("Creating ng dataset of value", ng))
      my_tdm <- tdm_Ngram(my_corpus ,ng=ng)
      comb_freq <- frequent_terms(my_tdm, low_freq = low_freq, num = num_words)
      fwrite(comb_freq, paste("./final/en_US/",type,"_ng_",ng,".csv",sep = ""))
      print(sum(comb_freq$freq))
            
            return(comb_freq)
            
    }
  }
  
  comb_text_clean <- text_cleaning(comb_text)
  rm(comb_text)
  
  if(test_gen){
    comb_text_test_clean <- text_cleaning(comb_text_test)
    rm(comb_text_test)
  }

  
for (ng in c(1,2,3,4,5)){
  if(test_gen){
    x <- export_ng(comb_text_test_clean, type = "test", ng = ng, overwrite = TRUE)
  }
  
  x <- export_ng(comb_text_clean, type = "train", ng = ng, overwrite = TRUE)
}

}