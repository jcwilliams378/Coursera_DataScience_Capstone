#change this for your final project directory where you will store data locally
setwd("~/Documents/Data Science Courses/Coursera/Data Science Specialization (JHU)/10 Capstone Project/")

min_freq <- 3 # min number of times the phrase must appear to be included in analysis

for (ng in 2:5){
#read in the cleaned test data
  t <- read.csv(paste("./final/en_US/test_ng_",ng,".csv", sep = ""))
  
  #clear out all frequencies of 1 (rare)
  t_filt <- t[!(t$freq %in% c(1:min_freq)),]
  
  #convert the word column to char
  t_filt$word <- as.character(t_filt$word)
  
  #split out last word from sentence
  split <- strsplit(t_filt$word, " (?=[^ ]+$)", perl=TRUE)
  t_split <- data.frame(matrix(unlist(split), ncol=2, byrow=TRUE),t_filt$freq)
  names(t_split) <- c("partial_phrase","actual_word","freqency")
    
  # Keep only the first row for each duplicate of the partial phrase; this row will have the
  # largest value of occurances for the expected word "actual word"
  t_split <- t_split[!duplicated(t_split$partial_phrase),]
  
  write.csv(x = t_split, file = paste("./final/en_US/test_set/t",ng,"_test_set.csv",sep = ""))
}
