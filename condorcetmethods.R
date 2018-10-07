#This function extracts the matrix of votes from the ballot
VoteExtract <- function(BallotMatrix){
    Votes <- as.matrix(BallotMatrix[, -1], mode = "numeric")
    Num_Candidates <- dim(Votes)[1]
    #Votes[is.na(Votes)] <- Num_Candidates + 1 #Treat blanks as one worse than min
    rownames(Votes) <- paste(BallotMatrix[,1])
    return(Votes)
}

#This function performs the pairwise comparison between candidates and results
#in a square matrix representing the number of wins the candidate in row i has
#beaten the candidate in column j.
PairCount <- function(Votes) {
    Num_Candidates <- dim(Votes)[1]
    Pairwise <- matrix(nrow = Num_Candidates, ncol = Num_Candidates)
    for (CurCand in 1:Num_Candidates) {
        CandRank <- as.vector(as.matrix(Votes[CurCand, ]))
        Pref_Cur_Cand <- t(Votes) - CandRank
        for (Pairs in 1:Num_Candidates) {
            Pairwise[CurCand, Pairs] <- sum(Pref_Cur_Cand[, Pairs] > 0, na.rm=T)
        }
    }
    rownames(Pairwise) <- colnames(Pairwise) <- rownames(Votes)
    return(Pairwise)
}

#This function calculates the beatpaths and members of the Schwarz set. A unique
#member is the Schulze Condorcet winner.
Schulze <- function(PairsMatrix){
    size <- dim(PairsMatrix)[1]
    p <- matrix(nrow = size, ncol = size)
    for (i in 1:size) {
        for (j in 1:size){            if (i != j) {
                if (PairsMatrix[i, j] > PairsMatrix[j, i]) {
                    p[i, j] <- PairsMatrix[i, j]
                } else {
                    p[i, j] <- 0
                }
            }
        }
    }
    for (i in 1:size) {
        for (j in 1:size) {
            if (i != j) {
                for (k in 1:size) {
                    if (i != k && j != k) {
                        p[j, k] <- max(p[j, k], min(p[j, i], p[i, k]))
                    }
                }
            }
        }
    }
    diag(p) <- 0
    return(p)
}

#show the numbers of pairwise wins, losses and ties for each candidate, sorted
#by clear winners
WinRecord <- function(pairCount) {
	record <- matrix(0, nrow(pairCount), 3)	
	for(i in 1:nrow(pairCount)) {
		for(j in 1:nrow(pairCount)) {
			if(i!=j) {
				if(pairCount[i,j] > pairCount[j,i]) {
					#win
					record[i,1] <- record[i,1]+1
				} else if(pairCount[i,j] < pairCount[j,i]) {
					#loss
					record[i,2] <- record[i,2]+1
				} else {
					#tie
					record[i,3] <- record[i,3]+1
				}
			}
			
		}
		
	}
	rownames(record) <- rownames(pairCount)
	colnames(record) <- c("Win","Loss","Tie")
	record <- record[order(record[,1], record[,3], decreasing=TRUE),]
	return(record)	
}

#descriptive table of the results from each pairwise test
FullVotes <- function(pairCount) {
	full <- matrix("-", nrow(pairCount), ncol(pairCount))
	for(i in 1:nrow(pairCount)) {
		for(j in 1:nrow(pairCount)) {
			full[i,j] <- paste(pairCount[i,j], "-", pairCount[j,i], sep="")
		}
	}
	rownames(full) <- colnames(full) <- rownames(pairCount)
	print(full, quote=FALSE)
}

#This function performs the ranking, starting with the full ballot, finding a
#pure Condorcet or Schulze winner, removing him or her from the ballot, and
#repeating the process until all candidates are ranked.
CondorcetRank <- function(BallotMatrix)  {
    Num_Candidates <- dim(BallotMatrix)[1]
    Rankings <- matrix(nrow = Num_Candidates, ncol = 3)
    CurrentBallot <- BallotMatrix
    CurrentRank <- 1
    while (CurrentRank <= Num_Candidates) {
        CurrentNames <- as.vector(CurrentBallot[, 1])
        CurrentSize <- length(CurrentNames)
        CurrentVotes <- VoteExtract(CurrentBallot)
        Pairwise <- matrix(nrow = CurrentSize, ncol = CurrentSize)
        Pairwise <- PairCount(CurrentVotes)
        Winner <- vector(length = CurrentSize)
    
        # Check for Condorcet Winner    
    
        for (i in 1:CurrentSize) {
            Winner[i] <- sum(Pairwise[i, ] > Pairwise[, i]) == (CurrentSize - 1)
        }
        if (sum(Winner == TRUE) == 1) { #Condorcet Winner Exists
            CurrentWinner <- which(Winner == TRUE)
            Rankings[CurrentRank, ] <- c(CurrentNames[CurrentWinner], CurrentRank, "Condorcet")
        } else {
      
            # Condorcet Winner does not exist, calculate Schulze beatpaths
      
            Pairwise <- Schulze(Pairwise)
            for (i in 1:CurrentSize) {
                 Winner[i] <- sum(Pairwise[i, ] > Pairwise[, i]) == (CurrentSize - 1)
            }
            if (sum(Winner == TRUE) == 1) { #Schwartz set has unique member
                CurrentWinner <- which(Winner == TRUE) 
                Rankings[CurrentRank, ] <- c(CurrentNames[CurrentWinner], CurrentRank, "Schulze")
            }
        }
        CurrentBallot <- CurrentBallot[-CurrentWinner, ]
        CurrentRank = CurrentRank + 1
    }
    Rankings <- data.frame(Rankings)
    names(Rankings) <- c("Name", "Rank", "Method")
    return(Rankings)
}