set.seed(2016)


# install missing package if required
list.of.packages <- c("pnn", "pROC","caret","e1071","fmsb", "nnet", "class", "rpart","h2o")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

# Load required packages
library (pROC)
library (fmsb)

# for cross - validation
# input: a data frame
# output: ID for n - folds

n_folds_create = function (df, nfolds = 5) {
  sample(1:nfolds,nrow(df),replace=TRUE)
}

# build a model by using pnn package
buildModel = function (train_frame, sigma = 0.5)
{
  y = train_frame[,ncol(train_frame)]
  train_frame[,ncol(train_frame)] = NULL
  train_frame = scale(train_frame)
  train_frame[is.na(train_frame)] <- 0
  train_frame = cbind (as.factor(y), train_frame)
  library(pnn)
  fit = pnn::smooth(pnn::learn(data.frame(y, train_frame)), sigma = sigma)
  fit
}

# use a model to predict the test value
performModel = function (model, test_frame) {
  y = test_frame[,ncol(test_frame)]
  test_frame[,ncol(test_frame)] = NULL
  test_frame = scale(test_frame)
  test_frame[is.na(test_frame)] <- 0
  test_frame = cbind (as.factor(y), test_frame)
  
  nbTest = nrow (test_frame)
  pred = c()
  actual = c()
  
  print (paste("There are", nbTest, "items in test set"))
  for (i in 1:nbTest) {
    print (paste("Element",i))
    cur_pred = guess (model, as.matrix (test_frame[i,]))
    if (!is.atomic(cur_pred)) {
      pred = c(pred, cur_pred$category)
      actual = c(actual, as.character(y[i]))
    } else {
      pred = c(pred,  sample (1:6,1))
      actual = c(actual, as.character(y[i]))
    }
  }
  list (actual, pred)
}

# run everything from beginning
classifyWithPNN = function (language = "en", nfolds = 5)
{
  data_file = "../data/article_quality/enwiki.features_wp10.30k.tsv"
  if (language == "en") {
    data_file = "../data/article_quality/enwiki.features_wp10.30k.tsv"
  }
  else if (language == "fr") {
    data_file = "../data/article_quality/frwiki.features_wp10.9k.tsv"
  }
  else {
    stop ("Language not supported.")
  }
  print ("Loading data")
  data = read.table(data_file)
  
  # Performing cross validation
  id = n_folds_create (df = data, nfolds = nfolds)
  
  actual = c()
  pred = c()
  
  for (i in 1:nfolds) {
    print (paste ("Fold", i))
    test_data = data [id == i,]
    train_data = data [id != i,]
    print ("Building model")
    model = buildModel (train_frame = train_data)
    print ("Perform the model")
    model_performance = performModel (model = model, test_frame = test_data)
    actual = c(actual, model_performance[[1]])
    pred = c(pred, model_performance[[2]])
  }
  
  # Building confusion matrix 
  if (language == "en") {
    print ("AUC: ")
    
    print (multiclass.roc(as.ordered(actual), as.ordered(pred)))
    
    print ("----")
    
    actual = factor(actual, levels = c("stub", "start","c","b","ga","fa"))
    pred = factor(pred, levels = c("stub", "start","c","b","ga","fa"))
    t = table (actual, pred)
    
    print (t)
    
    print (paste("Accuracy =", sum(diag(t))/sum(t)))
    
    print (paste("Kappa"))
    
    print (Kappa.test(t))
  }
  else if (language == "fr") {
    print ("AUC: ")
    
    print (multiclass.roc(as.ordered(actual), as.ordered(pred)))
    
    print ("----")
    
    actual = factor(actual, levels = c("e", "bd","b","a","ba","adq"))
    pred = factor(pred, levels = c("e", "bd","b","a","ba","adq"))
    t = table (actual, pred)
    
    print (t)
    
    print (paste("Accuracy =", sum(diag(t))/sum(t)))
    
    print (paste("Kappa"))
    
    print (Kappa.test(t))
  }
}

#rerun the algorithm of Warncke on
# Warncke-Wang, M., Ayukaev, V.R., Hecht, B. and Terveen, L.G., 2015, February. 
# The Success and Failure of Quality Improvement Projects in Peer Production Communities. 
# In Proceedings of the 18th ACM Conference on Computer Supported Cooperative Work & Social Computing (pp. 743-756). ACM.
warckne2015 = function ()
{
  data_file = "../data/article_quality/enwiki.features_wp10.30k.tsv"
  data = read.table(data_file)
  
  library(h2o)
  h2o.init()
  rf = h2o.randomForest(y=25,x=c(2,15,9,5,6,1,4,8,7,11,13),training_frame = as.h2o(data), nfolds = 5, ntrees = 501)
  print(rf)
  h2o.shutdown(prompt = FALSE)
}

# classify with ORES service
# https://blog.wikimedia.org/2015/11/30/artificial-intelligence-x-ray-specs
classifyWithORES = function (language = "en", nfolds = 5)
{
  data_file = "../data/article_quality/enwiki.features_wp10.30k.tsv"
  if (language == "en") {
    data_file = "../data/article_quality/enwiki.features_wp10.30k.tsv"
  }
  else if (language == "fr") {
    data_file = "../data/article_quality/frwiki.features_wp10.9k.tsv"
  }
  else {
    stop ("Language not supported.")
  }
  print ("Loading data")
  data = read.table(data_file)
  
  library(h2o)
  h2o.init()
  if (language == "en") {
    rf = h2o.randomForest(y=25,x=1:24,training_frame = as.h2o(data), nfolds = 5, ntrees = 501)
    print(rf)
  }
  else if (language == "fr") {
    rf = h2o.randomForest(y=26,x=1:25,training_frame = as.h2o(data), nfolds = 5, ntrees = 501)
    print(rf)
  }
  h2o.shutdown(prompt = FALSE)
}

# return the accuracy when classify with kNN
classifyWithKNN = function (language = "en", k = 101)
{
  data_file = "../data/article_quality/enwiki.features_wp10.30k.tsv"
  if (language == "en") {
    data_file = "../data/article_quality/enwiki.features_wp10.30k.tsv"
  }
  else if (language == "fr") {
    data_file = "../data/article_quality/frwiki.features_wp10.9k.tsv"
  }
  else {
    stop ("Language not supported.")
  }
  print ("Loading data")
  data = read.table(data_file)
  
  library(class)
  library (pROC)
  
  
  if (language == "en") {
    knn.cv = knn.cv(train = data[,1:24], cl = data$V25, k = 101)
    
    t = table (data$V25, knn.cv)
    
    print (paste("Accuracy =",sum (diag(t))/sum(t)))
    print (multiclass.roc(as.ordered(data$V3), as.ordered(knn.cv)))
    print (Kappa.test(t))
  }
  else if (language == "fr") {
    knn.cv = knn.cv(train = data[,1:25], cl = data$V26, k = 101)
    
    t = table (data$V26, knn.cv)
    
    print (paste("Accuracy =",sum (diag(t))/sum(t)))
    print (multiclass.roc(as.ordered(data$V3), as.ordered(knn.cv)))
    print (Kappa.test(t))
  }
}


# perform classification with multinomial logistic regression
classifyWithMultinominalLogisticRegression = function (language = "en", nfolds = 5) {
  data_file = "../data/article_quality/enwiki.features_wp10.30k.tsv"
  if (language == "en") {
    data_file = "../data/article_quality/enwiki.features_wp10.30k.tsv"
  }
  else if (language == "fr") {
    data_file = "../data/article_quality/frwiki.features_wp10.9k.tsv"
  }
  else {
    stop ("Language not supported.")
  }
  print ("Loading data")
  data = read.table(data_file)
  
  library(caret)
  library (nnet)
  library (pROC)
  tc <- trainControl("cv",nfolds)
  
  if (language == "en") {
    train.multinom = train(V25 ~ V1 + V2 + V3 + V4 + V5 + V6+ V7 + V8 + V9 + V10 + 
                             V11 + V12 + V14 + V15 + V16 + V17+ V18 + V19 + V20 + V21 + V22 + V23 + V24,
                            data = data, method="multinom",trControl=tc)
    
    print (train.multinom)
    
    p.multinom = predict(train.multinom, newdata = data)
    
#     print ("AUC = ")
#     print (multiclass.roc(as.ordered(data$V3), as.ordered(p.multinom)))
  }
  else if (language == "fr") {
    train.multinom = train(V26 ~ V1 + V2 + V3 + V4 + V5 + V6+ V7 + V8 + V9 + V10 + 
                             V11 + V12 + V14 + V15 + V16 + V17+ V18 + V19 + V20 + V21 + V22 + V23 + V24 + V25,
                           data = data, method="multinom",trControl=tc)
    
    print (train.multinom)
    
    p.multinom = predict(train.multinom, newdata = data)
    
#     print ("AUC = ")
#     print (multiclass.roc(as.ordered(data$V3), as.ordered(p.multinom)))
  }
}

# classifying with CART
classifyWithCART = function (language = "en", nfolds = 5)
{
  data_file = "../data/article_quality/enwiki.features_wp10.30k.tsv"
  if (language == "en") {
    data_file = "../data/article_quality/enwiki.features_wp10.30k.tsv"
  }
  else if (language == "fr") {
    data_file = "../data/article_quality/frwiki.features_wp10.9k.tsv"
  }
  else {
    stop ("Language not supported.")
  }
  print ("Loading data")
  data = read.table(data_file)
  
  library(rpart)
  library(pROC)
  library(fmsb)
  
  n_col = ncol(data)
  
  # Performing cross validation
  id = n_folds_create (df = data, nfolds = nfolds)
  
  actual = c()
  pred = c()
  
  for (i in 1:nfolds) {
    print (paste ("Fold", i))
    test = data [id == i,]
    train = data [id != i,]
    if (language == "en") {
      cart_model <- rpart(train$V25 ~ ., data = train, method = "class")
    } 
    else if (language == "fr") {
      cart_model <- rpart(train$V26 ~ ., data = train, method = "class")
    }
    predictR <- predict(cart_model, newdata = test, type = "class")
    actual = c(actual, test[[n_col]])
    pred = c(pred, predictR)
  }
  
  t = table(actual, pred)
#   print ("Confusion matrix")
#   print (table1)
  print (paste("Accuracy of CART is:", sum (diag(t)) / sum (t)))
  print (multiclass.roc(as.ordered(actual), as.ordered( pred)))
  print(Kappa.test(t))
}

classifyWithSVM = function (language = "en", nfolds = 5) {
  data_file = "../data/article_quality/enwiki.features_wp10.30k.tsv"
  if (language == "en") {
    data_file = "../data/article_quality/enwiki.features_wp10.30k.tsv"
  }
  else if (language == "fr") {
    data_file = "../data/article_quality/frwiki.features_wp10.9k.tsv"
  }
  else {
    stop ("Language not supported.")
  }
  print ("Loading data")
  data = read.table(data_file)
  
  library(caret)
  library (e1071)
  library (pROC)
  tc <- trainControl("cv",nfolds)
  
  if (language == "en") {
    train.svm = train(V25 ~ V1 + V2 + V3 + V4 + V5 + V6+ V7 + V8 + V9 + V10 + 
                             V11 + V12 + V14 + V15 + V16 + V17+ V18 + V19 + V20 + V21 + V22 + V23 + V24,
                           data = data, method="svmLinear",trControl=tc)
    
    print (train.svm)
    
    p.svm = predict(train.svm, newdata = data)
    
    #     print ("AUC = ")
    #     print (multiclass.roc(as.ordered(data$V3), as.ordered(p.multinom)))
  }
  else if (language == "fr") {
    train.svm = train(V26 ~ V1 + V2 + V3 + V4 + V5 + V6+ V7 + V8 + V9 + V10 + 
                        V11 + V12 + V14 + V15 + V16 + V17+ V18 + V19 + V20 + V21 + V22 + V23 + V24 + V25,
                      data = data, method="svmLinear",trControl=tc)
    
    print (train.svm)
    
    p.svm = predict(train.svm, newdata = data)
    
    #     print ("AUC = ")
    #     print (multiclass.roc(as.ordered(data$V3), as.ordered(p.multinom)))
  }
  
  t = table(data[[ncol(data)]], p.svm)
  print (sum(diag(t))/sum(t))
  print (multiclass.roc(as.ordered(data[[ncol(data)]]), p.svm))
  print (Kappa.test(t))
}