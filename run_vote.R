source("condorcetmethods.R")

#read the ballot
ballot <- read.table("ballots.csv", header=TRUE, sep=",")

#calculate pairwise winners
pairs <- PairCount(VoteExtract(ballot))

#look at pairwise results
FullVotes(pairs)
WinRecord(pairs)

#get the final rank
CondorcetRank(ballot)
