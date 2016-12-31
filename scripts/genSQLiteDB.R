options(gsubfn.engine = "R")
library(sqldf)
library(data.table)

genSQLiteDB <- function(db){
  setwd("~/Documents/Data Science Courses/Coursera/Data Science Specialization (JHU)/10 Capstone Project/final/en_US/")
  
  max_ngram = 5
  
  db <- dbConnect(SQLite(), dbname="en_final.sqlite")
  
  dbSendQuery(conn=db,
              "CREATE TABLE NGram
              (pre TEXT,
              word TEXT,
              freq INTEGER,
              n INTEGER)")  # ROWID automatically created with SQLite dialect
  
  dbListTables(db)              # The tables in the database
  dbListFields(db, "Ngram")    # The columns in a table
  x <- dbReadTable(db, "Ngram")     # The data in a tabledbCommit(db)
  
  #import the training data
  n2 <- fread("./train_ng_2.csv")
  n3 <- fread("./train_ng_3.csv")
  n4 <- fread("./train_ng_4.csv")
  n5 <- fread("./train_ng_5.csv")
  
  processGram <- function(dt) {
    # Add to n-gram data.table pre (before word) and cur (word itself)
    dt[, c("pre", "cur"):=list(unlist(strsplit(word, "[ ]+?[a-z]+$")), 
                               unlist(strsplit(word, "^([a-z]+[ ])+"))[2]),
       by=word]
  }
  
  bulk_insert <- function(sql, key_counts)
  {
    dbBegin(db)
    dbGetPreparedQuery(db, sql, bind.data = key_counts)
    dbCommit(db)
  }
  
  # Insert into SQLite database
  insert_SQL_data <- function(ng_data, ng){
    sql_in <- paste("INSERT INTO NGram VALUES ($pre, $cur, $freq,", ng,")",sep = "")
    bulk_insert(sql_in, ng_data)
  }
  
  for (i in 2:max_ngram){
    processGram(eval(parse(text = paste("n",i,sep = ""))))
    n_data <- eval(parse(text = paste("n",i,sep = "")))
    insert_SQL_data(n_data, ng = i)
    print(i)
  }
  
  dbDisconnect(db)
}
