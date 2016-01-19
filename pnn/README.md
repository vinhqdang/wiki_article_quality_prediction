# Introduction

This directory contains my implementation to use Probabilistic Neural Network (PNN) to predict the quality of Wikipedia articles.

# Data

Data is provided by Wikimedia Foundation.

## English Wikipedia (enwiki)

The data set of English Wikipedia contains ~ 30 000 articles which are rated (Stub, Start, C, B, GA, FA). Each article is parsed and calculated 24 features.

The list of models can be found [here](https://github.com/wiki-ai/wikiclass/blob/master/wikiclass/feature_lists/enwiki.py)

# Implementation

Our implementation is built based on the implementation presented at [1].

## Running

You need to install [R](https://www.r-project.org/) and optional [RStudio](https://www.rstudio.com/)

```r
setwd ("path to PNN.R")
source ("PNN.R")

# at first time, you will need to install package pnn
# the script will do it automatically for you

# run everything from beginning
# it will take a while

# For English Wikipedia
# default
runAll (language = "en")

# For French Wikipedia
runAll (language = "fr")
```

## Results 

### enwiki (2016 - 01 - 03)

```
        pred
actual  stub start   c   b  ga  fa
  stub   925    48   0   0   1   0
  start   47   919   1   1  35   4
  c        0     2 878  61   0  29
  b        0     0  73 896   1   7
  ga       0    13   4   1 883  66
  fa       1     2  26   3  21 941
"Accuracy = 0.924095771777891"
```

### frwiki (2016 - 01 - 14)

```
        pred
actual   e  bd   b   a  ba adq
   e   280  22   0   0   1   0
   bd   26 276   1   1   8   0
   b     3   3 280   3  16  13
   a     0   0   4 270   0  20
   ba    0   2   6   0 279   1
   adq   0   0   3   4   2 267
[1] "Accuracy = 0.922389726409827"
```

## Misc

### Comparison with [2]

We provided a function to re-run the implementation of [2]

```r
# You should have the package randomForest installed already
warckne2015 ()
```

You should achieve the accuracy around 58%.

# References

[1] Nigel Lewis (2015), *Build Your Own Neural Network Today!: With step by step instructions showing you how to build them faster than you imagined possible using R*, Create Space publisher. [Amazon](http://www.amazon.com/Build-Your-Neural-Network-Today/dp/1519101236/ref=sr_1_1?ie=UTF8&qid=1451808556&sr=8-1&keywords=build+your+own+neural+network+todays)

[2] Warncke-Wang, M., Ayukaev, V.R., Hecht, B. and Terveen, L.G., 2015, February. The Success and Failure of Quality Improvement Projects in Peer Production Communities. In Proceedings of the 18th ACM Conference on Computer Supported Cooperative Work & Social Computing (pp. 743-756). ACM.