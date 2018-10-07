This repository contains some functions for calculating the results of a voting ballot using the (Condorcet method)[https://en.wikipedia.org/wiki/Condorcet_method]. The original code is taken from [this Rcpp example](http://gallery.rcpp.org/articles/condorcet-voting-with-rcpp/) but the code here does not implement the rcpp Schulze method. 

The basic functions are in `condorcetmethods.R`. To run a new ballot, edit the results in `ballots.csv` and then run the `run_vote.R` script to see the results. NOTE: Be sure to add a final end line return to the CSV file if saving from Excel in order for R to read it in properly.

To simplify the data entry process and to avoid circular ambiguities, it is recommended that this procedure only be used for small numbers of candidates.

## Example

The `ballots.csv` includes fictive data to illustrate the process. Each candidate is listed on a row of the data. Each voter (in this case "FacultyX") is listed on a column. Each voter ranks candidates from 1 to $n$ (where $n$ is the number of canidates) with low numbers indicating preference (i.e. 1 indicates 1st choice). Voters can also give multiple candidates the same number if they have no preference. For example, if a voter had a strong preference for the first and last candidates among a set of four but no preference for the middle two, then they could record their votes as 1,2,2,3. 

Once this data is recorded it can be read into R. The initial pairwise voting tallies can then be calculated with `Paircount`:

```r
pairs <- PairCount(VoteExtract(ballot))
```

The function `VoteExtract` is a convenience function that will re-organize the ballot as a matrix that the other functions know how to use. The pairs object can then extract a full tally list or a condensed winning record for each candidate:

```r
FullVotes(pairs)
```
```
           CandidateA CandidateB CandidateC CandidateD
CandidateA 0-0        7-9        8-7        2-11      
CandidateB 9-7        0-0        8-7        5-12      
CandidateC 7-8        7-8        0-0        6-10      
CandidateD 11-2       12-5       10-6       0-0       
```

```r
WinRecord(pairs)
```
```
           Win Loss Tie
CandidateD   3    0   0
CandidateB   2    1   0
CandidateA   1    2   0
CandidateC   0    3   0
```

These diagnostics can be useful for checking the results. 

A final ranking of candidates from these results can then be calculated by the `CondorcetRank` function. In certain circumstances, there may be circular ambiguities in the ranking. This procedure uses the Shulze method to resolve such ambiguities. 

```r
CondorcetRank(ballot)
```
```
        Name Rank    Method
1 CandidateD    1 Condorcet
2 CandidateB    2 Condorcet
3 CandidateA    3 Condorcet
4 CandidateC    4 Condorcet
```
