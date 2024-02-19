## Make links, then generate MD's
# Part 1: generate links:
allFiles <- list.files(path = "../datalib/")
print(allFiles)
myFileLinks <- list()
for (thisFile in allFiles) {
  
  
  subFiles <- list.files(path = paste0("../datalib/", thisFile))
  
  if (paste0(thisFile, ".jasp") %in% subFiles) {
    
    noSpaceFileName <- gsub(x = thisFile, pattern =" ", replacement = "%20")
    underscoreFileName <- gsub(x = thisFile, pattern =" ", replacement = "_")
    
    jaspLink <- "[.jasp](https://github.com/jasp-stats/jasp-data-library/raw/main/FILENAMEHERE/FILENAMEHERE.jasp)"
    
    htmlLink <- "[.html](https://htmlpreview.github.io/?https://github.com/jasp-stats/jasp-data-library/blob/main/FILENAMEHERE/FILENAMEUNDERSCOREHERE.html)"
    
    csvLink <- "[.csv](https://raw.githubusercontent.com/jasp-stats/jasp-data-library/main/FILENAMEHERE/FILENAMEHERE.csv)"
    
    myFileLinks[[thisFile]] <- list(jaspLink = gsub(x = jaspLink, pattern = "FILENAMEHERE", replacement = noSpaceFileName),
                                    htmlLink = gsub(x = gsub(x = htmlLink, pattern = "FILENAMEHERE", replacement = noSpaceFileName), 
                                                    pattern = "FILENAMEUNDERSCOREHERE", replacement = underscoreFileName),
                                    csvLink = gsub(x = csvLink, pattern = "FILENAMEHERE", replacement = noSpaceFileName))
    
  } else if (thisFile == "Sesame" || thisFile == "Distributions") {
    
    noSpaceFileName <- gsub(x = thisFile, pattern =" ", replacement = "%20")
    underscoreFileName <- gsub(x = thisFile, pattern =" ", replacement = "_")
    
    jaspLink <- "[.jasp](https://github.com/jasp-stats/jasp-data-library/raw/main/FILENAMEHERE/FILENAMEHERE.jasp)"
    csvLink <- "[.csv](https://raw.githubusercontent.com/jasp-stats/jasp-data-library/main/FILENAMEHERE/FILENAMEHERE.csv)"
    htmlLink <- "[.html](https://htmlpreview.github.io/?https://github.com/jasp-stats/jasp-data-library/blob/main/FILENAMEHERE/FILENAMEUNDERSCOREHERE.html)"
    
    allJaspLinks <- allHtmlLinks <- list()
    
    for (thisSubFile in subFiles[grepl(subFiles, pattern = ".jasp")]) {
      thisSubFileNoExt <- gsub(x  = thisSubFile, pattern = ".jasp", replacement = "")
      noSpaceSubFileName <- gsub(x = thisSubFileNoExt, pattern =" ", replacement = "%20")
      underscoreSubFileName <- gsub(x = thisSubFileNoExt, pattern =" ", replacement = "_")
      
      myFileLinks[[thisSubFileNoExt]] <- list(jaspLink = gsub(x = jaspLink, pattern = "FILENAMEHERE", replacement = noSpaceSubFileName),
                                              htmlLink = gsub(x = gsub(x = htmlLink, pattern = "FILENAMEHERE", replacement = noSpaceSubFileName), 
                                                              pattern = "FILENAMEUNDERSCOREHERE", replacement = underscoreSubFileName),
                                              csvLink = gsub(x = csvLink, pattern = "FILENAMEHERE", replacement = noSpaceFileName))
    }
  }
}

analysisNames <- list.files("../jasp-desktop/Resources/Data Sets/Data Library/")
# Extract numbers from the beginning of each string
numbers <- as.numeric(gsub("^([0-9]+).*", "\\1", analysisNames))
# Sort the vector based on the extracted numbers
analysisNames <- analysisNames[order(numbers)]
analysisList <- list()
for (thisAnalysis in analysisNames) {
  
  subFiles <- list.files(path = paste0("../jasp-desktop/Resources/Data Sets/Data Library/", thisAnalysis))
  
  thisAnalysisData <- subFiles[grepl(x = subFiles, pattern = ".jasp")]
  thisAnalysisData <- gsub(x = thisAnalysisData, pattern = ".jasp", replacement = "")
  
  analysisList[[thisAnalysis]] <- list()
  
  for (thisData in thisAnalysisData) {
    
    analysisList[[thisAnalysis]][[thisData]] <- myFileLinks[[thisData]]
    
  }
}


### Extra information for the books
bookTitles <- c("Field - Discovering Statistics",
                "Moore, McCabe, & Craig - Introduction to the Practice of Statistics")

bookDatasets <- list('Field - Discovering Statistics' = c("Fear of Statistics",
                                                          "Invisibility Cloak",
                                                          "Alcohol Attitudes",
                                                          "Beer Goggles",
                                                          "Bush Tucker Food",
                                                          "Looks or Personality",
                                                          "Viagra",
                                                          "Album Sales",
                                                          "Exam Anxiety",
                                                          "The Biggest Liar",
                                                          "Dancing Cats",
                                                          "Dancing Cats and Dogs"),
                     'Moore, McCabe, & Craig - Introduction to the Practice of Statistics' = c("Directed Reading Activities",
                                                                                               "Moon and Aggression",
                                                                                               "Weight Gain",
                                                                                               "Facebook Friends",
                                                                                               "Heart Rate",
                                                                                               "Response to Eye Color",
                                                                                               "College Success",
                                                                                               "Fidgeting and Fat Gain",
                                                                                               "Physical Activity and BMI",
                                                                                               "Health Habits")
)





# Part 2: generate md files for each chapter
# Used for matching the book links:
unlistedAnalysisList <- unlist(analysisList, recursive = F)
unlistedDataNamesList <- unlist(lapply(analysisList, names))

for (i in seq_along(analysisList)) {
  chapterList <- analysisList[[i]]
  chapterTitle <- names(analysisList)[i]
  file_name <- paste0("myChapters/chapter_", i, ".md")
  # Remove numbers before a period using regular expressions
  chapterTitle <- gsub("\\d+\\.", "", chapterTitle)
  
  cat(paste("#", chapterTitle, "\n\n"), file = file_name)
  
  
  allDataNames <- names(chapterList)
  
  
  for (thisDataName in allDataNames) {
    cat(paste("\n\n##", thisDataName, "\n"), file = file_name, append = TRUE)
    # chapter_content <- chapterList[[thisDataName]][[1]]
    # cat(chapter_content, file = file_name, append = TRUE)
    item_list <- chapterList[[thisDataName]]
    
    cat("|  |  |  |\n", file = file_name, append = TRUE)
    cat("|---|---|---|\n", file = file_name, append = TRUE)
    
    # for (item in item_list) {
    # bullet_point <- paste0(" ", paste(item, collapse = " "))
    # bullet_list <- paste(bullet_list, paste("|", item, "|"), sep = " ")
    result <- paste("|", paste(item_list, collapse = " | "), "|", sep = "")
    
    cat(result, file = file_name, append = TRUE)
    
  }
  
  if (chapterTitle == "Books") {
    
    for (thisBook in bookTitles) {
      
      cat(paste("\n\n##", thisBook, "\n"), file = file_name, append = TRUE)
      
      allDataNames <- bookDatasets[[thisBook]]
      
      matchedBookDataList <- unlistedAnalysisList[match(allDataNames, unlistedDataNamesList)]
      
      for (thisDataName in names(matchedBookDataList)) {
        
        cat(paste("\n\n###", sub(".*\\.", "", thisDataName), "\n"), file = file_name, append = TRUE)
        # chapter_content <- chapterList[[thisDataName]][[1]]
        # cat(chapter_content, file = file_name, append = TRUE)
        cat("|  |  |  |\n", file = file_name, append = TRUE)
        cat("|---|---|---|\n", file = file_name, append = TRUE)
        
        item_list <- matchedBookDataList[[thisDataName]]
        
        # bullet_list <- ""
        # for (item in item_list) {
        #   bullet_point <- paste0(" ", paste(item, collapse = " "))
        #   bullet_list <- paste(bullet_list, paste("|", item, "|"), sep = " ")
        # }
        result <- paste("|", paste(item_list, collapse = " | "), "|", sep = "")
        cat(result, file = file_name, append = TRUE)
        
      }
    }
  }
  
}
