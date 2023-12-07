allFiles <- list.files(path = "~/GitHubStuff/JASP_Modules/jasp-data-library//")

myFileLinks <- list()
for (thisFile in allFiles) {
  
  
  subFiles <- list.files(path = paste0("~/GitHubStuff/JASP_Modules/jasp-data-library/", thisFile))
  
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


analysisNames <- list.files("~/GitHubStuff/jasp-desktop/Resources/Data Sets/Data Library/")
# Extract numbers from the beginning of each string
numbers <- as.numeric(gsub("^([0-9]+).*", "\\1", analysisNames))
# Sort the vector based on the extracted numbers
analysisNames <- analysisNames[order(numbers)]
analysisList <- list()
for (thisAnalysis in analysisNames) {
  
  subFiles <- list.files(path = paste0("~/GitHubStuff/jasp-desktop/Resources/Data Sets/Data Library/", thisAnalysis))
  
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

