function(input, output, session) {

  library(tm)
  library(wordcloud)
  library(memoise)
  
  # Define a reactive expression for the document term matrix
  terms <- reactive({
    input$update
      withProgress({
        setProgress(message = "Processing corpus...")
        print(input$selection)
        getTermMatrix(input$selection)
      })
  })

  # Make the wordcloud drawing predictable during a session
  wordcloud_rep <- repeatable(wordcloud)

  output$plot <- renderPlot({
    v <- terms()
    wordcloud_rep(names(v), v, scale=c(4,0.5),
                  min.freq = input$freq, max.words=input$max,
                  colors=brewer.pal(8, "Dark2"))
  })

# Using "memoise" to automatically cache the results
getTermMatrix <- memoise(function(book) {
  
  upload.path <- substr(book$datapath,1,nchar(book$datapath)-1)
  myCorpus <- Corpus(DirSource(upload.path), readerControl = list(language = "eng"))
  
  
  #   myCorpus = Corpus(VectorSource(text))
  myCorpus = tm_map(myCorpus, tolower)
  myCorpus = tm_map(myCorpus, removePunctuation)
  myCorpus = tm_map(myCorpus, removeNumbers)
  myCorpus = tm_map(myCorpus, removeWords,
                    c(stopwords("SMART"), "thy", "thou", "thee", "the", "and", "but"))
  
  myDTM = TermDocumentMatrix(myCorpus,
                             control = list(minWordLength = 1))
  
  m = as.matrix(myDTM)
  
  sort(rowSums(m), decreasing = TRUE)
})

}
