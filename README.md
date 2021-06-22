# Projet Technique: Prédiction du prix des logements sur Airbnb
Airbnb est une place de marché Internet pour la location de maisons et d'appartements à court terme. Il vous permet, par exemple, de louer  votre logement pendant une semaine pendant votre absence. L'un des défis auxquels sont confrontés les hôtes Airbnb est de déterminer le prix de location optimal par nuit.  il n'existe pas de méthodes faciles d'accès pour déterminer le meilleur prix pour louer un espace.  Notre objectif va donc consister à predire le prix des listings de Airbnb dans la région du Québec en nous basant sur l'historique des listing disponibles.

# Data
Pour ce projet, les donnees  proviennent du [Inside Airbnb](http://insideairbnb.com/get-the-data.html) qui est un site qui scrape données de Airbnb. Les donnees ont été scrapées sur la période allant du 11 avril 2021 au 13 avril 2021 sur les annonces de  la ville du Québec. Il contient des informations sur toutes les annonces Airbnb du Québec qui étaient en ligne sur le site sur cette période date soit un total de 2289 listings. la base de données contenant les données détaillées comporte plus de 70 variables. Nous avons des informations géospatiales sur les données dont la latitude et longitude; des informations sur le logement dont le type, le nombre de lits, le nombre de douche, le type de douche(privée ou partagée); des informations  sur les revues des clients, des informations sur l'annonceur et sur l'annonce etc.

# Data cleaning and exploration
Parmis la liste des variables contenues dans la base de donnees, j'ai decidé d'en retirer certaines dont les  variables de texte libre comme  la description des annonces et les revues;  les informations relatives sur l'annonceur. Pour inclure ces données, j'aurais dû faire un traitement du langage naturel(NLP); ce qui aurait augmenté la complexité des modèles à produire par la suite.  Ces variables ont donc été abandonnées. De plus, les colonnes ne contenaient qu'une seule catégorie, ou un nombre élévé de valeurs manquantes9(plus de 30%)  ont été supprimées. Les variables contenant moins de 30% de valeurs manquantes ont été imputées.

Une section complète  sur le nettage des données  explique comment et pourquoi certaines variables ont été retirées (voir fichier Cleaning exploration.R dans github).

# Exploration des données via Power Bi 
Le rapport Power Bi (voir fichier dashboard.pbix dans github) permet de realiser une exploration partielle de nos données.  Le rapport de visualisation contient deux pages. La premiere permet de visualiser les annonces selon leur position géographique et suivant le score des logements.  Les données de la page sont dynamique et peuvent être filtré via les variables qui sont: la zone géographique, le type d'appartement, le score  et le prix du logement. On peut rapidement constate qu'une grande partie des annonces Airbnb sont centrées sur cette zone comme la zone voisinant les plaines d'abraham, ce qui correspond à l'énorme attrait pour les touristes, en particulier pendant la periode estivale. 
![maps des donnees](https://github.com/Romanicarchil/Projet-Airbnb/blob/main/projectImage/Screenshot%20from%202021-06-21%2014-57-07.png)

![maps des donnees](https://raw.githubusercontent.com/Romanicarchil/Projet-Airbnb/main/Screenshot%20from%202021-06-21%2014-57-07.png)


La deuxième page d'une rapport Power BI permet de réaliser un analyse bivariée entre les variables explicatives et le prix de logement. La page est doté d'un filtre qui permet de sélectioner la variable en question. La figure suivante est illustration qui montre l'effect d'une logement avec chambre privée sur le prix.

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


# Prediction 
Si on croise les valeurs des prix logements predits  obtenus par le modele xgboost avec  les prix reels on obtient la figure suivante. 
![comparaison entre le prix predit et le prix actuel](https://github.com/Romanicarchil/Projet-Airbnb/blob/main/projectImage/Predicted%20value%20vs%20actual%20price.png)




