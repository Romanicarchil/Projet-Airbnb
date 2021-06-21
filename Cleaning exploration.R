#libraries
library(ggplot2)
library(caret)
library(doParallel)
library(mice)
library(magrittr)
library(zoo)

working_directory="/home/romanic/Documents/promutuel project"
path_data_detailed=paste0(working_directory,"/detailed_data")
path_data_summary=paste0(working_directory,"/summary_data")


  
setwd(working_directory)
  
#lire les donnees contenant les informations detaillees
listing=read.csv2( paste0(path_data_detailed,"/listings.csv")  ,sep=",",dec = ".",na.strings = "N/A")
review=read.csv2(paste0(path_data_detailed,"/reviews.csv") ,sep=",",dec = ".",na.strings = "N/A")


#lire les donnees contenant les informations resumees
listing2=read.csv2( paste0(path_data_summary,"/listings.csv")  ,sep=",",dec = ".",na.strings = "N/A")
review2=read.csv2(paste0(path_data_summary,"/reviews.csv") ,sep=",",dec = ".",na.strings = "N/A")
calendar=read.csv2( paste0(path_data_summary,"/calendar.csv")  ,sep=",",dec = ".",na.strings = "N/A")
  



#------------------------------------------------------------------------------------#
#                         Data cleaning qnd exploration                              #
#------------------------------------------------------------------------------------#
dim(listing)  # nous avons 2289 listing et 74 variables 


#nous creons certaines variables necessaires 
listing$host_seniority=  as.Date(as.character(listing$last_scraped))-as.Date(as.character(listing$host_since))  # creation d'une variable qui mesure l'anciennte de l'hote en nombre de jour
listing$host_seniority=as.numeric(listing$host_seniority)

# creation des variables relatives aux salles de bains(une variable private_bath et une autre shared_bath, une autre pour le nombre de salle de bain number_bath)
listing$private_bath=0 ; listing$shared_bath=0 ; listing$number_bath=0
listing$private_bath[grep("private bath" , listing$bathrooms_text)]=1
listing$shared_bath[grep("shared bath" , listing$bathrooms_text)]=1
listing$number_bath=as.numeric(sapply(strsplit(as.character(listing$bathrooms_text ),split=" "),"[[",1) )


# nous retirons les variables de textes completement distintes  et les variables statiques
variable_to_remove=c("id", "listing_url" , "scrape_id"  , "last_scraped", "name",  "description", "neighborhood_overview" , "picture_url", "host_location",
                     "host_about"  , "host_thumbnail_url"  ,"host_neighbourhood",  "host_verifications"  , "neighbourhood" , "neighbourhood_group_cleansed",    "bathrooms" ,"amenities",  
                     "calendar_updated"  ,  "has_availability", "calendar_last_scraped"  ,"first_review"  ,"last_review" ,"license"   ,"host_picture_url","host_url","host_name","host_since","host_id","bathrooms_text","bedrooms"
                     
)

listing=listing[,!(names(listing) %in% variable_to_remove)]

# conversion   du format des variables
listing$host_response_rate =as.numeric(gsub("%","", listing$host_response_rate ))
listing$host_acceptance_rate =as.numeric(gsub("%","", listing$host_acceptance_rate ))
listing$host_is_superhost=ifelse(listing$host_is_superhost=="t",1,0)
listing$host_has_profile_pic =ifelse(listing$host_has_profile_pic =="t",1,0)
listing$host_identity_verified =ifelse(listing$host_identity_verified =="t",1,0)
listing$instant_bookable  =ifelse(listing$instant_bookable  =="t",1,0)
listing$price=as.numeric(gsub('\\$',"",as.character(listing$price)))

calendar$price=as.numeric(gsub('\\$',"",as.character(calendar$price)))
calendar$date=as.Date(calendar$date)
calendar$month= format(as.Date(calendar$date), "%Y-%m")


# Verifier et retirer les variable independantes tres correllees 
listing_num=unlist(lapply(listing, is.numeric)) %>%  listing[,.]#liste des variables numeriques
matrix_cor=cor(listing_num, use = "complete.obs")
seuil=.9
correlation_variable_dataframe=data.frame(variables=names(listing_num),correlation_variable_list=NA)  # liste des variables correllees a 90%
correlation_variable_list=c() # liste des variables a retirer paceque tres correlees avec une autre

for(var in names(listing_num)){
  if(var %in% correlation_variable_list) next
 matrix_cor_var= matrix_cor[var, colnames(matrix_cor)!=var ]
 correlation_variable_dataframe[var,"correlation_variable_list"]=paste(names(matrix_cor_var)[matrix_cor_var>seuil],collapse=" , ")
 correlation_variable_list=c(correlation_variable_list,names(matrix_cor_var)[matrix_cor_var>seuil]) %>% unique()
}
listing=listing[,!(names(listing) %in% correlation_variable_list)] # retrait des variables tres correlees

# retrait des variables ayant plus de 30% de valeurs manquantes
missing_percent=sapply(listing, function(x) sum(is.na(x)))/dim(listing)[1]
variables_missing_high=names(listing)[missing_percent>0.3]
listing=listing[,!(names(listing) %in% variables_missing_high)] # retrait des variables tres correlees
# imputation des valeurs manquantes
init = mice(listing, maxit=0) 
meth = init$method
predM = init$predictorMatrix

for(var in names(missing_percent)){
  if(missing_percent[var]==0) next
  
  
  if(is.numeric(listing[,var])){
    meth[c(var)]="norm" 
  }
  
  if(is.factor(listing[,var])){
    meth[c(var)]="pmm" 
  }
  
}

set.seed(81)
imputed = mice(listing, method=meth, predictorMatrix=predM, m=5)
completeData_listing<- complete(imputed,2)
missing_percent=sapply(completeData_listing, function(x) sum(is.na(x)))/dim(listing)[1]  # erifier si les valeurs manquantes ont toutes ete imputees

# regrouper les points suivants la latitude et longitude
lat_long_data=completeData_listing[,c("latitude", "longitude")]
set.seed(2)
km.out=kmeans(lat_long_data,10,nstart = 20)
lat_long_data$classe_geographique=as.factor(km.out$cluster)
p1=ggplot(lat_long_data, aes(x=latitude, y=longitude, color=classe_geographique)) +  geom_point()
p1
#  retrait des variables geographiques et ajout de la variable classe au jeu de donnee completeData_listing
completeData_listing$classe_geographique=as.factor(km.out$cluster)
completeData_listing= completeData_listing[,!(names(completeData_listing) %in% c("latitude","longitude"))]


# transformer les variable categorielle en one-hot encoding
dummy <- dummyVars(" ~ .", data=completeData_listing)
completeData_listing_encoding<- data.frame(predict(dummy, newdata = completeData_listing)) 

#write.csv(completeData_listing_encoding,"data_cleaning.csv")
# analyse des correlations avec la variable price
  # analysons la variation du prix par la date 
p <- ggplot(calendar, aes(x=month, y=price)) + geom_boxplot()
p
calendar=calendar[!is.na(calendar$price),]
price_agg <- aggregate(x = calendar$price, 
                      by = list(calendar$month), 
                      FUN = mean)
names(price_agg) =c("date","price_mean")
price_agg$date=as.yearmon(price_agg$date)
p <- ggplot(price_agg, aes(x=date, y=price_mean)) + geom_line(color="grey") + geom_point(shape=21, color="black", fill="#69b3a2", size=6)+theme_ipsum() 
p


# Correlation des variables au prix
par(oma=c(14,14,14,14)) # all sides have 3 lines of space
par(mar=c(1,1,1,1) + 0.1)
matrix_cor_price=cor(completeData_listing_encoding, use = "complete.obs")["price",]  %>% sort()
matrix_cor_price=matrix_cor_price[names(matrix_cor_price)!="price"]
matrix_cor_price_pos=matrix_cor_price[matrix_cor_price>=0]
matrix_cor_price_neg=matrix_cor_price[matrix_cor_price<0]
matrix_cor_price_neg=matrix_cor_price_neg[order(matrix_cor_price_neg,decreasing = T)]
names_pos=names(matrix_cor_price_pos)
names_neg=names(matrix_cor_price_neg)
barplot(matrix_cor_price_pos, horiz=TRUE,names.arg=names_pos,las=1, cex.names=0.8,main="correlations positives des variables par rapport au prix des listings",col = "blue")
barplot(matrix_cor_price_neg, horiz=TRUE,names.arg=names_neg,las=1, cex.names=0.8,main="correlations negative des variables par rapport au prix des listings",col="red")



#variation suivant certaines variables 
p2 <- ggplot(completeData_listing_encoding, aes(x=beds, y=price,group=beds))  + geom_boxplot()
p2

p3 <- ggplot(completeData_listing_encoding, aes(x=property_type.Entire.house, y=price,group=property_type.Entire.house))  + geom_boxplot()
p3





  
