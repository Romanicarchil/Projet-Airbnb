library(FNN)
library(glmnet)
library(randomForest)
library(MASS)
library(xgboost)
working_directory="/home/romanic/Documents/promutuel project"
setwd(working_directory)

#lire les donnees avec les informations detaillees
data=read.csv2( "data_cleaning.csv"  ,sep=",",dec = ".",na.strings = "NA")
set.seed(15)
n=dim(data)[1]
index_t= sample(n, n*0.3, replace = F)
data_train= data[-(index_t),]
data_test=data[index_t,]
        
my.valid.knn = function( dat, k, ntest ){
  #-----------------------------------------------------------------------------------------------------------------------------------#
  #Cette fonction retourne l'erreur obtenu avec un modele KNN sur un jeu de donnees test de taille ntest choisi aleatoirement dans dat
  #  
  # input: 
  #     dat: un jeux de donnees contenant les variables independantes et la variable a predire price
  #     k: parametre du modele knn representant le nombre de plus proche voisin
  #     ntest: nombre des donnees test a choisir aleatoirement de test 
  #------------------------------------------------------------------------------------------------------------------------------------#
    require(FNN)
    n = dim(dat)[1]
    index_test = sample(n, ntest, replace = F)
    dat_test = dat[index_test,]
    dat_entrai = dat[-(index_test),]
    m <- which(names(dat_entrai)=="price")
    out =knn.reg( dat_entrai[,-m], dat_test[,-m],dat_entrai[,m], k)
    erreur_test = sum( out$pred - dat_test[,m] )^2 / ntest
    return(erreur_test)
}



#regression linear multiple
my.valid.lm = function( dat, ntest ){
  #-----------------------------------------------------------------------------------------------------------------------------------#
  #Cette fonction retourne l'erreur obtenu avec un modele de regression lineaire sur un jeu de donnees test de taille ntest choisi aleatoirement dans dat
  #  
  # input: 
  #     dat: un jeux de donnees contenant les variables independantes et la variable a predire price
  #     ntest: nombre des donnees test a choisir aleatoirement de test 
  #------------------------------------------------------------------------------------------------------------------------------------#
n = dim(dat)[1]
index_test = sample(n, ntest, replace = F)
dat_test = dat[index_test,]
dat_entrai = dat[-(index_test),]
m <- which(names(dat_entrai)=="price")
out=lm(price~.,data=dat_entrai)
lm.pred = predict.lm(out,dat_test[,-m])
erreur.lm = sum(lm.pred-dat_test$price)^2/ntest 
return(erreur.lm) 
}


# random Forest
my.valid.rf= function( dat, ntest ){
  #-----------------------------------------------------------------------------------------------------------------------------------#
  #Cette fonction retourne l'erreur obtenu avec un modele de forest aleatoire sur un jeu de donnees test de taille ntest choisi aleatoirement dans dat
  #  
  # input: 
  #     dat: un jeux de donnees contenant les variables independantes et la variable a predire price
  #     ntest: nombre des donnees test a choisir aleatoirement de test 
  #------------------------------------------------------------------------------------------------------------------------------------#
n = dim(dat)[1]
index_test = sample(n, ntest, replace = F)
dat_test = dat[index_test,]
dat_entrai = dat[-(index_test),]
m <- which(names(dat_entrai)=="price")
rf.fit=randomForest(price~.,data=dat_entrai)
rf.pred = predict(rf.fit,dat_test[,-m])
erreur.rf= sum(rf.pred-dat_test$price)^2/ntest 
return(erreur.rf) 
}


# boosting
my.valid.xgb= function( dat, ntest ){
  #-----------------------------------------------------------------------------------------------------------------------------------#
  #Cette fonction retourne l'erreur obtenu avec un modele du boosting sur un jeu de donnees test de taille ntest choisi aleatoirement dans dat
  #  
  # input: 
  #     dat: un jeux de donnees contenant les variables independantes et la variable a predire price
  #     ntest: nombre des donnees test a choisir aleatoirement de test 
  #------------------------------------------------------------------------------------------------------------------------------------#
  n = dim(dat)[1]
  index_test = sample(n, ntest, replace = F)
  dat_test = dat[index_test,]
  dat_entrai = dat[-(index_test),]
  m <- which(names(dat_entrai)=="price")
  
  xgb.fit <- train(
    price ~., data = dat_entrai, method = "xgbTree",
    trControl = trainControl("cv", number = 10)
  )
  pred_boost=xgb.fit %>% predict(dat_test[,-m])
  
  erreur.xgb= sum(pred_boost-dat_test$price)^2/ntest 
  return(erreur.xgb) 
}


# recherche du meilleur k pour knn par validation croisee
N=6
group = vector("list",N)
for(i in 1:N){
  group[[i]] = replicate( 10, my.valid.knn(dat=data_train, k =i,ntest=600))
}

par(mar = c(2, 2, 2, 2))
par(oma=c(3,3,3,3))
boxplot(group,col="gray",main="Erreur du modele knn en fonction du parametre k")

mean(group[[3]])


erreur.lm = replicate( 100, my.valid.lm(dat=data_train,ntest=600))
boxplot(erreur.lm,main="erreur regression multiple",col="gray")
mean(erreur.lm)

erreur_xgb= replicate( 15, my.valid.xgb(dat=data_train,ntest=600))
boxplot(erreur_xgb,main="erreur xgboost",col="gray")
mean(erreur_xgb)

erreur_rf= replicate( 15, my.valid.rf(dat=data_train,ntest=600))
boxplot(erreur_rf,main="erreur random forest",col="gray")
mean(erreur_rf)


group_ = vector("list",4)
group_[[1]] =group[[2]]
group_[[2]] = erreur.lm
group_[[3]]= erreur_xgb
group_[[4]]=erreur_rf
names(group_)=c("knn","regression","xgboost","randomForest")
boxplot(group_,col="gray",main="comparaison des erreurs des modèles")

# Le meilleur modele est xgboost 
xgb.fit <- train(
  price ~., data = data_train, method = "xgbTree",
  trControl = trainControl("cv", number = 10)
)
pred_boost=xgb.fit %>% predict(data_test[,-m])

cross_real_predict_data=data.frame(predicted_price=pred_boost, actual_price=data_test$price)

p <- ggplot(cross_real_predict_data, aes(x=predicted_price, y=actual_price))  + geom_point()
p

model=lm(predicted_price~.,data=cross_real_predict_data)
summary(model)

