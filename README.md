# Projet Technique: Prédiction du prix des listings sur Airbnb
Airbnb est une place de marché Internet pour la location de maisons et d'appartements à court terme. Il vous permet, par exemple, de louer  votre logement pendant une semaine pendant votre absence. L'un des défis auxquels sont confrontés les hôtes Airbnb est de déterminer le prix de location optimal par nuit.  il n'existe pas de méthodes faciles d'accès pour déterminer le meilleur prix pour louer un espace.  Notre objectif va donc consister à predire le prix des listings de Airbnb dans la région du Québec en nous basant sur l'historique des listing disponibles.

# Data
Pour ce projet, les donnees  provient du [Inside Airbnb](http://insideairbnb.com/get-the-data.html) qui est un site qui scrape données de Airbnb. Les donnees ont été scrapées sur la période allant du 11 avril 2021 au 13 avril 2021 sur les annonces de  la ville du Québec. Il contient des informations sur toutes les annonces Airbnb du Québec qui étaient en ligne sur le site sur cette période date soit un total de 2289 listings. la base de données contenant les données détaillées comporte plus de 70 variables. Nous avons des informations géospatiales sur les données dont la latitude et longitude; des informations sur le logement dont le type, le nombre de lits, le nombre de douche, le type de douche(privée ou partagée); des informations  sur les revues des clients, des informations sur l'annonceur et sur l'annonce etc.

# Data cleaning and exploration
Parmis la liste des variables contenues dans la base de donnees, j'ai decidé d'en retirer certaines dont les  variables de texte libre comme  la description des annonces et les revues;  les informations relatives sur l'annonceur. Pour inclure ces données, j'aurais dû faire un traitement du langage naturel(NLP); ce qui aurait augmenté la complexité des modèles à produire par la suite.  Ces variables ont donc été abandonnées. De plus, les colonnes ne contenaient qu'une seule catégorie, ou un nombre élévé de valeurs manquantes9(plus de 30%)  ont été supprimées. Les variables contenant moins de 30% de valeurs manquantes ont été imputées.

Une section complète  sur le nettage des données  explique comment et pourquoi certaines variables ont été retirées (voir fichier Cleaning exploration.R dans github).








