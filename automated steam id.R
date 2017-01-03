rm(list = ls())
# Need these packages/libraries
# install.packages("data.table")
library(data.table)
library(rjson)
library(RCurl)

# loop through creating a list of 100 character ID's starting at the given user ID
i = 1
# updates the file name by 1 each time the code goes through a loop
k = 550

# This loop makes the inner loop run 9 times
  for(i in 1:9) {
    # counter for while loop
    x = 0
    # used as a counter
    count = 0
    # updates the last number in the string using count
    charcount <- "0"
    # updates the tens place digit
    z = 0
    
    # starting user ID to be updated by loop. Starts off as
    # two digits less than actual ID length
    userID <- "76561197960270"
    # updates the hundreds place
    userID <- paste(userID, i, sep="")
    # starts the tens place at 0
    userID <- paste(userID, "0", sep="")
    # creates blank string to be updated later
    tempList <- ""
    # creates the final string to be updated later
    finalList <- userID
    # sets ones place initially to 0 just in the final string
    finalList <- paste(userID, "0", sep="")
    ## make a new blank list
    listID <- list()
    
    # This loop creates a list of 100 strings (user IDs)
    while (x < 101) {
      # updates the counter from 9 back down to 0 so an extra character
      # isnt added. E.g we want to update the previous number by 1
      #  and set the tens place back to 0 not update the ones place to 10.
      if (count == 10) {
        count <- 0
        charcount <- as.character(count)
        userID <- substr(userID, 1, nchar(userID)-1)
        z = z + 1
        zchar <- as.character(z)
        userID <- paste(userID, zchar, sep="")
        newuserID <- paste(userID, charcount, sep="")
      # Else if counter is not 9 then we want to just update the ones
      # place by 1.
      } else {
        charcount <- as.character(count)
        newuserID <- paste(userID, charcount, sep="")
      }
      # Put that string (ID) into the corresponding list position
      listID[x] <- newuserID
      # update loop and counter
      x <- x + 1
      count <- count + 1
    }
    
    # Loops through the list building a large comma-delimited string of IDs
    y <- 0
    for (y in 1:length(listID) - 1) {
      tostring <- toString(listID[y])
      tempList <- paste(tempList, tostring, sep=",")
      y = y + 1
    }
    # Cut off the first two characters of the string. For some reason
    # it started with two commas.
    tempList <- substring(tempList, 2,nchar(tempList))
    # Paste the rest of the string on the final string we made at the top
    finalList <- paste(finalList, tempList, sep="")
    
    # My API key for Steam
    mykey <- "C031B7D1888656F83EFE52287453A1AA"
    # Build a URL that will automatically call the API request
    url_for_request <- paste("api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=",mykey,"&steamids=",finalList,sep="")
    
    # grab the JSON output from the URL above
    plain_json_output<- getURL(url_for_request)
    
    ## Write the JSON output onto a single line
    writeLines(gsub("\n","",plain_json_output), "output.json")
    
    # put the line breaks back into the file to break at the correct spots
    data_prelim <- readLines("output.json") 
    data_prelim2 <- gsub("},", "}\n", data_prelim)
    
    # write to a new file
    writeLines(data_prelim2, "input.json")
    
    data <- readLines("input.json")
    # get number of lines in file
    nof_lines <- length(data)
    # create a new list
    data.list <- list()
    # loop through the JSON file to convert all elements into a 
    # list of lists
    for(j in 1:nof_lines) {
      try(data.list[[j]] <- fromJSON(data[j]), silent = TRUE)
    }
    # create a data frame of the outer list making the inner lists into 
    # correct columns
    df <- rbindlist(data.list, fill = TRUE)
    # write the data frame into a csv file to be used in Tableau
    # or another program
    filename <- "output"
    # k updates the name of the file by assigning a number to it
    filename <- paste(filename, k, ".csv", sep = "")
    write.csv(df, filename)
    k = k + 1
  }
