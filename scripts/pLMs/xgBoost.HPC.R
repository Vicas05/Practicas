#!/usr/bin/env Rscript

library(openxlsx)
library(prospectr)
library(randomForest)
library(xgboost)
library(caret)
library(irr)

args <- commandArgs(trailingOnly=TRUE)

# Final filtered set of features, motifs, etc, with rnames
TB<-read.table(file=args[1],header=TRUE,sep=",",dec=".",row.names=1,check.names=FALSE)
obs<-TB[,"Observations"]
FE<-TB[,-(colnames(FE)%in%"Observations")]
# CALIBRATING and VALIDATION of DATA -------------------------------------------------------------
	## Selecting training and validation data
	# NOTE: ensure we have a only-numerical matrix
	sel<-kenStone(FE,k=2000,metric="euclid",pc=0.99,group=obs)
	## Preparing the different data to use in the modeling function
	dat<-list()
	dat$train<-as.matrix(FE[sel$model,])
	dat$test<-as.matrix(FE[sel$test,])

# Preparing target variable for binary model: Must be binary numerical ---------------------------
	dat$train_obs<-obs[sel$model]
	dat$test_obs<-obs[sel$test]
	pos<-sum(obs==1)
	neg<-sum(obs==0)
	ratio<-neg/pos


# Optimizing hiperparameters for xgboost model ---------------------------------------------------
	## Creating DMatrix
	dat$trainM<-xgb.DMatrix(data=dat$train,label=dat$train_obs)
	dat$testM<-xgb.DMatrix(data=dat$test,label=dat$test_obs)

	### Training parameters
		# Creating trainig grid
		xgbGrid <-  expand.grid(
						max_depth = c(2,5,7,10),
  						min_child_weight = c(1, 5),   # Min number of samples required on each terminal node
  						subsample = c(0.7,1), # Percentage of training samples used for each tree
						colsample_bytree= c(0.6,0.9),# Percentage of variables used for each tree
                        eta = c(1e-3, 1e-2, 1e-1), # Learning rate
                        gamma = c(1e-3, 1e-2, 1e-1, 5, 10), # Regularization parameters
						lambda = c(0.01, 0.1, 1, 10, 100),
						alpha = c(0, 0.001, 0.01, 0.1, 1, 10, 100),
						optntrees = NA, # To store best nr of trees for each combination of values
						minerror = NA, # To store the minimum error by CV
						sensibilidad  = NA, # To store sensibility 
						kappa = NA  # To store kappa value for each iteration		
						  )

		# Iterating along the hpps combinations
		for(i in 1:nrow(xgbGrid)){
		  	fitxgb <- xgb.cv(objective = "binary:logistic", eval_metric = "logloss",  
		                   data = dat$trainM, nrounds = 1000, nthread = 2, 
		                   nfold = 5, verbose = F, early_stopping_rounds = 10, prediction = TRUE,
		                   scale_pos_weight = 1*ratio,
		                   eta = xgbGrid$eta[i],
		                   max_depth = xgbGrid$max_depth[i],
		                   min_child_weight = xgbGrid$min_child_weight[i],
		                   subsample = xgbGrid$subsample[i],         
		                   colsample_bytree = xgbGrid$colsample_bytree[i],
		                   gamma = xgbGrid$gamma[i], 
		                   lambda = xgbGrid$lambda[i], 
		                   alpha = xgbGrid$alpha[i])
		  
			# Getting predictions and kappa with the internal CV from xgboost
			preds <- fitxgb$pred
			pred_labels <- ifelse(preds > 0.5, 1, 0)  # Turning predictions to binary
			# Getting sensibility
			  cm <- table(Real = dat$train_obs, Pred = pred_labels)
			## Checking if all values are binary
			if (all(c("0", "1") %in% rownames(cm)) && all(c("0", "1") %in% colnames(cm))) {
			    sensibility <- cm["1", "1"] / sum(cm["1", ])
			} else {
			   sensibility <- NA
			}
			# Getting kappa
			kappa_value <- kappa2(data.frame(dat$train_obs, pred_labels))$value
			 
			# Storing results
			xgbGrid$optntrees[i] <- fitxgb$best_iteration
			xgbGrid$minerror[i] <- min(em$test_logloss_mean, na.rm = TRUE)
			xgbGrid$sensibilidad[i] <- sensibility
			xgbGrid$kappa[i] <- kappa_value
			  
			print(i)  # Print iteraction	
		}

# Selecting best models -----------------------------------------------------------
	## By minor error
	gridxgb <- xgbGrid[order(xgbGrid$minerror), ]
	besthppsxgb <- xgbGrid[1, ]; besthppsxgb

	message("- Model with best hiperparameters -")
	print(as.matrix(besthppsxgb))

# Training the model -------------------------------------------------------------

	bestmodelxgb <- xgboost(data = dtrain,
		    nrounds = besthppsxgb$optntrees,
		    objective = "binary:logistic",
		    eta = besthppsxgb$eta,
		    max_depth = besthppsxgb$max_depth,
		    min_child_weight = besthppsxgb$min_child_weight,
		    subsample = besthppsxgb$subsample,
		    colsample_bytree = besthppsxgb$colsample_bytree,
		    alpha = besthppsxgb$alpha,
		    lambda = besthppsxgb$lambda,
		    gamma = besthppsxgb$gamma,
		    scale_pos_weight = 1 * ratio,
		    verbose = 0)

# Exporting the model ----------------------------------------------------------
	xgb.save(bestmodelxgb,fname=paste(args[2],".xgBoost.hppsOpt.binary.model",sep=""))
