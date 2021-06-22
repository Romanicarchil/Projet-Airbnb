# Projet Technique: Prédiction du prix des logements sur Airbnb
Airbnb est une plate forme en ligne pour la location de maisons et d'appartements à court terme. Il vous permet, par exemple, de louer  votre logement pendant une semaine pendant votre absence. L'un des défis auxquels sont confrontés les hôtes Airbnb est de déterminer le prix de location optimal par nuit.  il n'existe pas de méthodes faciles d'accès pour déterminer le meilleur prix pour louer un espace.  Notre objectif va donc consister à predire le prix des listings de Airbnb dans la région du Québec en nous basant sur l'historique des annonces disponibles.

# Data
Les données  proviennent du [Inside Airbnb](http://insideairbnb.com/get-the-data.html) qui est un site qui scrape les données de Airbnb. Les données ont été scrapées sur une période allant du 11 avril 2021 au 13 avril 2021. La base de données contient des informations sur toutes les annonces Airbnb du Québec qui étaient en ligne sur le site pendant cette période. On compte 2289 annonces dans la base de données et plus de 70 variables. Les variables peuvent être regroupées en plusieurs catégories dont: les données géospatiales(exemple de la latitude et la longitude), les données sur les logements dont le nombre de lits, le nombre douche etc. ; des informations  sur les commentaires des clients, des informations sur les annonceurs et les annonces  etc.

# Data cleaning and exploration
Certaines  variables  ont été retirées du jeu de données à l'exemple des variables de textes libres comme  la description des annonces, les commentaires des clients et  les informations relatives aux annonceurs. Pour inclure ces données, il aurait fallu faire un traitement du langage naturel(NLP); ce qui aurait augmenté la complexité des modèles à produire par la suite. De plus, les colonnes  qui contiennent une seule catégorie, ou un nombre élévé de valeurs manquantes(plus de 30%)  ont été supprimées. Les variables contenant moins de 30% de valeurs manquantes ont été  quant à eux imputées.

Une section complète  sur le nettage des données  explique comment et pourquoi certaines variables ont été retirées (voir fichier [Cleaning exploration.R dans github](https://github.com/Romanicarchil/Projet-Airbnb/blob/main/Cleaning%20exploration.R)).

# Exploration des données via Power Bi 
Le rapport PowerBi (voir fichier [dashboard.pbix](https://github.com/Romanicarchil/Projet-Airbnb) dans github) permet de realiser une exploration partielle de nos données.  Le rapport de visualisation contient deux pages. La premiere permet de visualiser les annonces selon leur position géographique et suivant le score des logements.  Les données de la page sont dynamique et peuvent être filtrées via les variables qui sont: la zone géographique, le type d'appartement, le score  et le prix du logement. On peut rapidement constater qu'une grande partie des annonces Airbnb sont centrées sur certaines zones comme les points voisinant les plaines d'Abraham, ce qui  peut s'expliquer par l'énorme attrait de ces zones pour les touristes, en particulier pendant la periode estivale. 

![maps des donnees](https://raw.githubusercontent.com/Romanicarchil/Projet-Airbnb/main/projectImage/Screenshot%20from%202021-06-21%2014-57-07.png)

La deuxième page d'une rapport PowerBI permet de réaliser une analyse bivariée entre les variables explicatives et le prix du logement. La page est dotée d'un filtre qui permet de sélectioner la variable en question. La figure suivante est illustration qui montre l'effect d'une logement avec chambre privée sur le prix.

![analyse bivariee entre le prix et variable chambre_privee](https://github.com/Romanicarchil/Projet-Airbnb/blob/main/projectImage/analyse%20bivariees.PNG)

## Analyse des correlation
L'analyse des correlations a releve que certaines variables etaient tres correllees. Ces variables ont ete retirer du jeux de donnees pour eviter de biaiser les resultats lors de la modelisation. la matrice des correlation a egalement revelle que les variables les plus correllees au prix des logement sont: Le nombre de chambre, le type de chambre et le fait que la chambre soit disponible sur un long terme(30 jours). Les figures ci-dessous decrit les correlations entre le prix des logements. En bleu, les correlations positives et en rouges, les correlations negatives.
![correlation positive](https://github.com/Romanicarchil/Projet-Airbnb/blob/main/projectImage/Screenshot%20from%202021-06-21%2021-21-37.png)
![correlation negative](https://github.com/Romanicarchil/Projet-Airbnb/blob/main/projectImage/Screenshot%20from%202021-06-21%2021-22-32.png)

## Les variables geospatiales
Les logements ont ete regroupes en 10 classes suivant leur données géospatiales(latitude et longitude). Un modèle Kmeans( avec k=10) a été utilisé à cet effet.
Les variables de latitude et longitude ont donc été supprimées du jeu de données et remplacées  par les classes obtenues du modèle Kmeans(voir ci-dessous). 
![regroupement des logements suivants leur latitude et longitudes](https://github.com/Romanicarchil/Projet-Airbnb/blob/main/projectImage/regroupement_points.png)

# Modelisation
Les données ont été partitionnées en deux. 70% pour les données d'entrainement et 30% pour les données tests. 4 modèles sont considérés dont: le KNN, la régréssion linéaire multiple, les forêts aléatoires et le boosted tree. 
Le modele KNN depend d'un parametre K a optimise. La validation croisee appliquee sur les donnees d'entrainement  permet de choisir le parametre k=2 comme minimisant l'erreur de prediction. 
![validation croisee knn](https://github.com/Romanicarchil/Projet-Airbnb/blob/main/projectImage/knn%20validation%20croisee.png).

Nous utilisons egalement la validation croisee sur les autres modeles avant de mesurer leur capacite predictives. Par la suite,il est juste question de les comparer toutes afin de choisir le meilleur modele. La figure ci-dessous, permet de choisir le KNN  comme celui la qui fait un bon compromis entre le biais et la variance. Mais lorsque tester sur le jeu de donnees test, il n'explique 21% d'information contrairement au modele xgboost qui en explique 51%. 
![validation croisee comparaison erreur](https://github.com/Romanicarchil/Projet-Airbnb/blob/main/projectImage/Erreur%20du%20modeles%20validation%20croisees.png)
|         | Regression       | Knn               | Random Forest     | Xgboost           |
| ------- | ---------------- | ----------------- | ----------------- | ----------------- |
| RMSE    | 6.97030431630759 | 11.2822424264459  | 40.1011655296402  | 17.0360396232529  |
| Rsquare | 0.35376124836272 | 0.211975815069908 | 0.553420898527612 | 0.547956229887314 |



# Prediction 
Si on croise les valeurs des prix logements predits  obtenus par le modele xgboost avec  les prix reels on obtient la figure suivante. 
![comparaison entre le prix predit et le prix actuel avec xgboost](https://github.com/Romanicarchil/Projet-Airbnb/blob/main/projectImage/cross%20with%20xgboost.png)

![comparaison entre le prix predit et le prix actuel avec random forest](https://github.com/Romanicarchil/Projet-Airbnb/blob/main/projectImage/cross%20actual%20predicted%20with%20random%20forest.png)





