library(RSQLite)
library(tm)
library(magrittr)
library(stringr)

predict_word <- function(raw, db=db, num_final_predictions = 5, num_top_words = 3,   alpha = 0.4, max_gram = 5) {
  # From Brants et al 2007.
  # Find if n-gram has been seen, if not, multiply by alpha and back off
  # to lower gram model. Alpha unnecessary here, independent backoffs.
  
  max = max_gram-1  # max n-gram - 1
  alpha = alpha
  # process sentence, don't remove stopwords
  sentence <- tolower(raw) %>%
    removePunctuation %>%
    removeNumbers %>%
    stripWhitespace %>%
    str_trim %>%
    strsplit(split=" ") %>%
    unlist
  
  largest_ngram <- min(length(sentence),max)
  
  results <- data.frame()
  prv_len <- 1
  end_row_prv <- 1
  
  for (i in min(length(sentence), max):0) {
    gram <- paste(tail(sentence, i), collapse=" ")
    
    sql <- paste("SELECT word, freq FROM NGram WHERE ", 
                 " pre=='", paste(gram), "'",
                 " AND n==", i + 1, sep="")
    
    res <- dbSendQuery(conn=db, sql)
    predicted <- dbFetch(res, n=-1)
    names(predicted) <- c("Word", "Freq")
    
    total_ct <- sum(predicted$Freq)
    
    #filter out any words previously captured by higher order ngrams:
    predicted <- predicted[!predicted$Word %in% results$Predicted_Word,]
    
    if(nrow(predicted) > 0){
      
      if (nrow(predicted) < num_top_words){ # if the returned words are fewer than the num of top words taken
        end_row <- nrow(predicted)
      }else{
        end_row <- num_top_words
      }
      # print some information about the current prediction results
      # print(paste("ng investigated:", i+1))
      # print(paste("number of results/rows from analysis:", nrow(predicted)))
      # print("Results returned:")
      # print(predicted[1:end_row,])
      
      #gather the current length of the final results frame:
      curr_len <- nrow(results)
      
      #iterate through the number of words found in the current prediction
      for (j in 1:end_row){
      results[curr_len+j,"Predicted_Word"] <- predicted[j,]$Word
      results[curr_len+j,"Freq_raw"] <- predicted[j,]$Freq
      results[curr_len+j, "NGram"] <- i + 1
      results[curr_len+j, "Total_Match_Counts"] = total_ct
      }
      
      
      # if (i != min(length(sentence), max)){
        for (k in 0:nrow(results)){
          results[k,"Score"] = alpha^(largest_ngram-(i+1))*
                                            results[k,]$Freq_raw/results[k,]$Total_Match_Counts
        }
      # }
      end_row_prv <- end_row
      prv_len <- curr_len + 1 
    }     
    
  }
  
  if (nrow(results) != 0){
    results <- results[order(results$Score, decreasing = T),]
    return(head(results, num_final_predictions))
  }else{
    return("No next word found")
  }
  
}
