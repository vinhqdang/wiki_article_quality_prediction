# Introduction

This directory contains my implementation to use Probabilistic Neural Network (PNN) to predict the quality of Wikipedia articles.

# Data

Data is provided by Wikimedia Foundation.

## English Wikipedia (enwiki)

The data set of English Wikipedia contains ~ 30 000 articles which are rated (Stub, Start, C, B, GA, FA). Each article is parsed and calculated 24 features.

The list of models can be found [here](https://github.com/wiki-ai/wikiclass/blob/master/wikiclass/feature_lists/enwiki.py)

# Implementation

Our implementation is built based on the code presented in [1].

## Running

You need to install [R](https://www.r-project.org/) and optional [RStudio](https://www.rstudio.com/).

We set the seed number to 2015 for reproducibility. You can change to another value.

```r
setwd ("path to PNN.R")
source ("PNN.R")

# at first time, you will need to install several packages if you did not install them before
# the script will do it automatically for you

# run everything from beginning
# it will take a while

# By default, the 5-folds cross validation will be performed. You can change the parameter *nfolds* as you wish.

# For English Wikipedia
# default
classifyWithPNN (language = "en", nfolds = 5)

# For French Wikipedia
classifyWithPNN (language = "fr", nfolds = 5)
```
## Compare with other classifying approaches

### Classification with [2]

We provided a function to re-run the implementation of [2]. The function works only with English dataset.

```r
warckne2015 ()
```

### Classification with ORES approach

We provided a function to re-run [ORES](https://blog.wikimedia.org/2015/11/30/artificial-intelligence-x-ray-specs) approach of Wikimedia Foundation.

```r
classifyWithORES (language = "en", nfolds = 5)
classifyWithORES (language = "fr", nfolds = 5)
```

### Classification with Multinomial Logistic Regression

```r
classifyWithMultinominalLogisticRegression (language = "en", nfolds = 5)
classifyWithMultinominalLogisticRegression (language = "fr", nfolds = 5)
```

### Classification with kNN

```r
classifyWithKNN (language = "en")
classifyWithKNN (language = "fr")
```


### Classification with CART

```r
classifyWithCART (language = "en", nfolds = 5)
classifyWithCART (language = "fr", nfolds = 5)
```


### Classification with SVM

```r
classifyWithSVM(language = "en", nfolds = 5)
classifyWithSVM(language = "fr", nfolds = 5)
```

# References

[1] Nigel Lewis (2015), *Build Your Own Neural Network Today!: With step by step instructions showing you how to build them faster than you imagined possible using R*, Create Space publisher. [Amazon](http://www.amazon.com/Build-Your-Neural-Network-Today/dp/1519101236/ref=sr_1_1?ie=UTF8&qid=1451808556&sr=8-1&keywords=build+your+own+neural+network+todays)

[2] Warncke-Wang, M., Ayukaev, V.R., Hecht, B. and Terveen, L.G., 2015, February. The Success and Failure of Quality Improvement Projects in Peer Production Communities. In Proceedings of the 18th ACM Conference on Computer Supported Cooperative Work & Social Computing (pp. 743-756). ACM.