#set.seed(2015)

if (!require(pnn)) {
  install.packages("pnn")
  library (pnn)
}

# read data file
# data file should contains list of features and quality class (FA, GA ...)
# separate into train and test set
# the separation depends on seed number (in our case it is 2015)
# so it is reproducibility
# splitRatio is the separation split between train and test dataset, default is 80/20
loadData = function (data_file_name = "../data/article_quality/enwiki.features_wp10.30k.tsv", 
                     splitRatio= 0.8) 
{
  all_data = read.table(data_file_name)
  
  library(caTools)
  
  sample = sample.split(all_data$V1, SplitRatio = splitRatio)
  train = subset (all_data, sample==TRUE)
  test = subset (all_data, sample == FALSE)
  
  list(train, test)
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
    }
  }
  list (actual, pred)
}

# run everything from beginning
runAll = function (language = "en")
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
  data = loadData(data_file_name = data_file)
  print ("Building model")
  model = buildModel (train_frame = data[[1]])
  print ("Perform the model")
  model_performance = performModel (model = model, test_frame = data[[2]])
  
  # Building confusion matrix 
  if (language == "en") {
    actual = factor(model_performance[[1]], levels = c("stub", "start","c","b","ga","fa"))
    pred = factor(model_performance[[2]], levels = c("stub", "start","c","b","ga","fa"))
    t = table (actual, pred)
    
    print (t)
    
    print (paste("Accuracy =", sum(diag(t))/sum(t)))
  }
  else if (language == "fr") {
    actual = factor(model_performance[[1]], levels = c("e", "bd","b","a","ba","adq"))
    pred = factor(model_performance[[2]], levels = c("e", "bd","b","a","ba","adq"))
    t = table (actual, pred)
    
    print (t)
    
    print (paste("Accuracy =", sum(diag(t))/sum(t)))
  }
}


#rerun the algorithm of Warncke on
# Warncke-Wang, M., Ayukaev, V.R., Hecht, B. and Terveen, L.G., 2015, February. 
# The Success and Failure of Quality Improvement Projects in Peer Production Communities. 
# In Proceedings of the 18th ACM Conference on Computer Supported Cooperative Work & Social Computing (pp. 743-756). ACM.
warckne2015 = function ()
{
  data_file = "../data/article_quality/enwiki.features_wp10.30k.tsv"
  data = loadData(data_file_name = data_file)
  train = data[[1]]
  test = data[[2]]
  library (randomForest)
  rf = randomForest(V25 ~ V2 + V15 + V9 + V5 + V6 + V1 + V4 + V8 + V7 + V11 + V13, data = train, ntree = 501, nodesize = 8)
  pred_rf = predict(rf, newdata = test)
  t = table (test$V25, pred_rf)
  print (paste ("Accuracy =", sum (diag(t))/sum(t)))
}