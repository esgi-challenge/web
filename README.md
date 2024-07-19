# Web

Repository pour le rendu flutter web du challenge IW5 S2

## Setup le projet

Afin de pouvoir lancer le projet en local, vous devez tout d'abord setup les variables d'environnement en copiant le fichier `dotenv.example` et en le renommant `dotenv`.
Il faut ensuite set les variables d'environnement qui ne sont que les points d'accès à l'API, il est donc nécessaire de lancer l'API avant, la doc est disponible à ce [lien](https://github.com/esgi-challenge/backend)

Une fois les variables d'environnement mise, vous devez récupérer les dépendances avec cette commande :
```
flutter pub get
```

ensuite pour lancer en local vous pouvez exécuter :
```
flutter run --dart-define APPLICATION_ID=$GMAP_API_KEY
```
En replaçant la variable $GMAP_API_KEY par une clé d'API Google Maps valide.

## Features :
Groupe :
- Antoine Lorin [AtoLrn](https://github.com/AtoLrn)
- Lucas Campistron [Redeltaz](https://github.com/Redeltaz)
- Izïa Crinier [19946-Dresden-St](https://github/19946-Dresden-St)

Liste des features :
|   |   |
|---|---|
| auth, register | Lucas Campistron |
| campus, intégration Google Map | Lucas Campistron |
| chat temps réel | Lucas Campistron |
| Classes | Lucas Campistron |
| Cours | Lucas Campistron |
| Documents, upload fichiers | Lucas Campistron |
| Informations | Lucas Campistron |
| Notes | Lucas Campistron |
| Filières | Lucas Campistron |
| Profil | Lucas Campistron |
| Projets | Lucas Campistron, Antoine Lorin |
| Emplois du temps | Lucas Campistron, Antoine Lorin |
| École | Lucas Campistron |
| Étudiants | Lucas Campistron |
| Professeurs | Lucas Campistron |
| Fix visuels, intégration | Izïa Crinier |
