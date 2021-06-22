# Projet Technique: Prédiction du prix des logements sur Airbnb
Airbnb est une plate forme en ligne pour la location de maisons et d'appartements à court terme. Il vous permet, par exemple, de louer  votre logement pendant une semaine pendant votre absence. L'un des défis auxquels sont confrontés les hôtes Airbnb est de déterminer le prix de location optimal par nuit.  il n'existe pas de méthodes faciles d'accès pour déterminer le meilleur prix pour louer un espace.  Notre objectif va donc consister à predire le prix des listings de Airbnb dans la région du Québec en nous basant sur l'historique des annonces disponibles.

# Data
Les données  proviennent du [Inside Airbnb](http://insideairbnb.com/get-the-data.html) qui est un site qui scrape les données de Airbnb. Les données ont été scrapées sur une période allant du 11 avril 2021 au 13 avril 2021. La base de données contient des informations sur toutes les annonces Airbnb du Québec qui étaient en ligne sur le site pendant cette période. On compte 2289 annonces dans la base de données et plus de 70 variables. Les variables peuvent être regroupées en plusieurs catégories dont: les données géospatiales(exemple de la latitude et la longitude), les données sur les logements dont le nombre de lits, le nombre douche etc. ; des informations  sur les commentaires des clients, des informations sur les annonceurs et les annonces  etc.

# Data cleaning and exploration
Certaines  variables  ont été retirées du jeu de données à l'exemple des variables de textes libres comme  la description des annonces, les commentaires des clients et  les informations relatives aux annonceurs. Pour inclure ces données, il aurait fallu faire un traitement du langage naturel(NLP); ce qui aurait augmenté la complexité des modèles à produire par la suite. De plus, les colonnes  qui contiennent une seule catégorie, ou un nombre élévé de valeurs manquantes(plus de 30%)  ont été supprimées. Les variables contenant moins de 30% de valeurs manquantes ont été  quant à eux imputées.

Une section complète  sur le nettage des données  explique comment et pourquoi certaines variables ont été retirées (voir fichier [Cleaning exploration.R dans github](https://github.com/Romanicarchil/Projet-Airbnb/blob/main/Cleaning%20exploration.R)).

# Exploration des données via Power Bi 
Le rapport PowerBi (voir fichier [dashboard.pbix](https://github.com/Romanicarchil/Projet-Airbnb) dans github) permet une exploration partielle des données.  Le rapport de visualisation contient deux pages. La premiere represente une visualisation des annonces selon la position géographique et suivant le score des logements.  Les données de la page sont dynamiques et peuvent être filtrées par les variables suivantes:  la zone géographique, le type d'appartement, le score  et le prix du logement. On peut constater par ce visuel qu'une grande partie des annonces Airbnb sont centrées sur certaines zones à l'exemple des points voisinant les plaines d'Abraham; ce qui  pourrait s'expliquer par l'énorme attrait de ces zones pour les touristes, en particulier pendant la periode estivale. 

![maps des donnees](https://raw.githubusercontent.com/Romanicarchil/Projet-Airbnb/main/projectImage/Screenshot%20from%202021-06-21%2014-57-07.png)

La deuxième page du rapport PowerBI permet une analyse bivariée entre chaque variable explicative et le prix du logement. La page est dotée d'un filtre qui permet de sélectioner la variable en question. La figure suivante est illustration qui montre l'effect du type du logement(logement privé) sur le prix.

![analyse bivariee entre le prix et variable chambre_privee](https://github.com/Romanicarchil/Projet-Airbnb/blob/main/projectImage/analyse%20bivariees.PNG)

## Analyse des corrélations
L'analyse des corrélations révèle que certaines variables du jeu de données  sont très correllées(corrélation supérieur à 90%). Ces variables ont été retirer du jeu de donnees pour éviter de biaiser les resultats lors de la modélisation. la matrice des correlations a également révélé que les variables les plus corréllées au prix des logements sont: Le nombre de chambres, le type de chambre et le fait que la chambre soit disponible sur un long terme(30 jours). Les figures ci-dessous représentent les correlations entre les varibles explicatives et le prix des logements. En bleu, les corrélations positives et en rouges, les corrélations negatives.
![correlation positive](https://github.com/Romanicarchil/Projet-Airbnb/blob/main/projectImage/Screenshot%20from%202021-06-21%2021-21-37.png)
![correlation negative](https://github.com/Romanicarchil/Projet-Airbnb/blob/main/projectImage/Screenshot%20from%202021-06-21%2021-22-32.png)

## Les variables géospatiales
Les logements ont été regroupés en 10 classes suivant leurs données géospatiales(latitude et longitude). Un modèle Kmeans( avec k=10) a été utilisé à cet effet.
Les variables de latitude et longitude ont donc été supprimées du jeu de données et remplacées  par les classes obtenues du modèle Kmeans(voir figure ci-dessous pour les classes). 
![regroupement des logements suivants leur latitude et longitudes](https://github.com/Romanicarchil/Projet-Airbnb/blob/main/projectImage/regroupement_points.png)

# Modélisation
Les données ont été partitionnées en deux. 70% pour les données d'entrainement et 30% pour les données tests. 4 modèles sont considérés dont: le KNN, la régréssion linéaire multiple, les forêts aléatoires et le boosted tree. 
Le modele KNN depend d'un parametre K à optimiser. La validation croisée appliquée sur les donnees d'entrainement  permet de choisir le paramètre k=2 comme minimisant l'erreur de prediction. 
![validation croisee knn](https://github.com/Romanicarchil/Projet-Airbnb/blob/main/projectImage/knn%20validation%20croisee.png).


 La validation croisée sur les données d'entrainement est également utilisée sur les autres modèles dans le but de mesurer leur capacite predictive.  La figure ci-dessous, représente la comparaison des érreurs des modèles  obtenues par validation croisée sur le jeu d'entrainement. 
 De ce graphique, il en ressort que le modèle Knn pourrait avoir la meilleur capacité prédive. Pour confirmer ce résultat, les modèles sont utilisés sur les données tests afin de déterminer leur performance(voir tableau ci-dessous). Il en ressort lque les deux meilleurs modèles sont: les forêts aléatoires et le boosted tree. Le modèle  utilisant les forêts aléatoires bien qu'ayant le meilleur R carré, possède une grande variance et donc n'est pas stable contrairement au modèle xgboost. eu egard de cela, le meilleur modèle qui fait le meilleur compromis entre biais et variance est donc le modèle xgboost.
  
![validation croisee comparaison erreur](https://github.com/Romanicarchil/Projet-Airbnb/blob/main/projectImage/Erreur%20du%20modeles%20validation%20croisees.png)


|         | Regression       | Knn               | Random Forest     | Xgboost           |
| ------- | ---------------- | ----------------- | ----------------- | ----------------- |
| RMSE    | 6.97030431630759 | 11.2822424264459  | 40.1011655296402  | 17.0360396232529  |
| Rsquare | 0.35376124836272 | 0.211975815069908 | 0.553420898527612 | 0.547956229887314 |



# Prediction 
Si on croise les valeurs des prix logements predits  obtenus par les modeles XGBoost et random forêts  avec  les prix réels on obtient les figures suivantes. 
![comparaison entre le prix predit et le prix actuel avec xgboost](https://github.com/Romanicarchil/Projet-Airbnb/blob/main/projectImage/cross%20with%20xgboost.png)

![comparaison entre le prix predit et le prix actuel avec random forest](https://github.com/Romanicarchil/Projet-Airbnb/blob/main/projectImage/cross%20actual%20predicted%20with%20random%20forest.png)

# Conclusion
Si nous devons choisir un modèle pour prédire le prix des logement,  ce serait le modele  XGBoost. Il est assez stable, moins couteux et prédit environ 54% de la variation de prix. Ce qui signifie que nous avons encore 46 % inexpliquée. Un ensemble de variables différentes qui ne sont pas incluses pourraient expliquer le reste de la variance.
Par exemple, les commodites accessible près du logement peuvent influencer la decision des clients.  Il peut être important d'être à proximité de certaines zones touristiques. Mais aussi, savoir que vous aurez une épicerie ou un supermarché à une  distance de marche peut être un plus. De nombreux locataires apprécient le fait qu'on puisse préparer ces propres repas.

On pourrait aussi realiser une analyse des sentiments sur les commentaires des clients. Puis faire la moyenne des scores obtenues par logement et les ajouter comme variables dans le jeu de données. De la même manière, on pourrait prendre en compte  la description des annonces dans les modèles. 





