# This script is designed to load in the data from the text files required
setup <- function(pct, training_pct = 0.7){
  
  #change this for your final project directory where you will store data locally
  setwd("~/Documents/Data Science Courses/Coursera/Data Science Specialization (JHU)/10 Capstone Project/") 
  
  #download and store the data locally
  if (!file.exists("./final")) {
          data_url <- "https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip"
          download.file(data_url, destfile = "../swiftkey.zip")
          unzip("../swiftkey.zip")
  }
  
  set.seed(378)
  
  # create subset of the data and save to separate text file
  
  sample_text <- function(input_fname, output_fname, percent){
          conn.in <- file(input_fname)
          conn.out <- file(output_fname, 'w')
          
          #read lines in
          data_in <- readLines(conn.in) 
          
          # filter out lines being retained
          sample_out <- data_in[sample(1:length(data_in), length(data_in) * percent, replace=FALSE)]
          
          #write out the number of lines in the sample dataset
          writeLines(sample_out, conn.out)  
          
          #close connections
          close(conn.in)
          close(conn.out)
  }
  
  # create subsamples
  data_sets <- c("./en_US.blogs.txt",
                 "./en_US.news.txt",
                "./en_US.twitter.txt")
  
  setwd("./final/en_US/")
  
  file_blogs_size_MB <- file.info(data_sets[1])$size/2^20
  file_news_size_MB <- file.info(data_sets[2])$size/2^20
  file_twitter_size_MB <- file.info(data_sets[3])$size/2^20
  
  blog_sample_fname <- paste("blog_sample.",pct,".txt",sep = "")
  news_sample_fname <- paste("news_sample.",pct,".txt",sep = "")
  twitter_sample_fname <- paste("twitter_sample.",pct,".txt",sep = "")
  
  if (!file.exists(paste("./",blog_sample_fname,sep = ""))) {
          blog_sample <- sample_text(data_sets[1], blog_sample_fname, pct)
  }
  
  if (!file.exists(paste("./",news_sample_fname,sep = ""))) {
          news_sample <- sample_text(data_sets[2], news_sample_fname, pct)
  }
  
  if (!file.exists(paste("./",twitter_sample_fname,sep = ""))) {
          twitter_sample <- sample_text(data_sets[3], twitter_sample_fname, pct)
  }
  
  # generate the samples for trainging and testing datsasets
  sample_text <- function(subset_fname,output_fnames, training_pct){
          conn.in <- file(paste("./", subset_fname,sep = ""))
          data <- readLines(conn.in)
          close(conn.in)
          
          #sample data
          train <- data[sample(1:length(data), length(data) * (1-training_pct), replace=FALSE)]
          test <- data[sample(1:length(data), length(data) * (training_pct), replace=FALSE)]
          
          length(train)/length(data)
          
          conn.out_train <- file(output_fnames[1], 'w')
          conn.out_test <- file(output_fnames[2], 'w')
          
          writeLines(test, conn.out_train)
          writeLines(train, conn.out_test)
          
          close(conn.out_train)
          close(conn.out_test)
  }
  
  blog_train_test_sample_fnames <- c(paste("train.", blog_sample_fname,sep = ""),
                                          paste("test.", blog_sample_fname,sep = ""))
  news_train_test_sample_fnames <- c(paste("train.", news_sample_fname,sep = ""),
                                     paste("test.", news_sample_fname,sep = ""))
  twitter_train_test_sample_fnames <- c(paste("train.", twitter_sample_fname,sep = ""),
                                     paste("test.", twitter_sample_fname,sep = ""))
  
  # Create train & test sets
  if (!file.exists(paste("./",blog_train_test_sample_fnames[1],sep = ""))) {
          sample_text(blog_sample_fname, blog_train_test_sample_fnames,training_pct = training_pct)
  }
  if (!file.exists(paste("./", news_train_test_sample_fnames[1],sep = ""))) {
          sample_text(news_sample_fname, news_train_test_sample_fnames,training_pct = training_pct)
  }
  if (!file.exists(paste("./", twitter_train_test_sample_fnames[1],sep = ""))) {
          sample_text(twitter_sample_fname, twitter_train_test_sample_fnames,training_pct = training_pct)
  }
  
  ## Import training sets. Combine into one
  if (!file.exists("./combined.training_set.txt")) {
          blog.train <- readLines(paste("./",blog_train_test_sample_fnames[1], sep = ""))
          news.train <- readLines(paste("./",news_train_test_sample_fnames[1], sep = ""))
          twitter.train <- readLines(paste("./",twitter_train_test_sample_fnames[1], sep = ""))
          combined.train <- c(blog.train, news.train, twitter.train)
          rm(blog.train); rm(news.train); rm(twitter.train)
          writeLines(combined.train, "./combined.training_set.txt")
  }
  
  ## Import test sets. Combine into one
  if (!file.exists("./combined.test_set.txt")) {
    blog.test <- readLines(paste("./",blog_train_test_sample_fnames[2], sep = ""))
    news.test <- readLines(paste("./",news_train_test_sample_fnames[2], sep = ""))
    twitter.test <- readLines(paste("./",twitter_train_test_sample_fnames[2], sep = ""))
    combined.test <- c(blog.test, news.test, twitter.test)
    rm(blog.test); rm(news.test); rm(twitter.test)
    writeLines(combined.test, "./combined.test_set.txt")
  }
  
  
}