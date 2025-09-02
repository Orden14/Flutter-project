# Flutter-project

## Groupe 

- Thomas L.
- David W.
- Antoine H.

## Projet en production

[https://flutter-project-orden14s-projects.vercel.app/](https://flutter-project-orden14s-projects.vercel.app/)

## Utiliser le projet en local

0. Installer [flutter](https://docs.flutter.dev/install)

```
https://docs.flutter.dev/install
```

1. Cloner le repository

```bash
git clone https://github.com/Orden14/Flutter-project.git
cd Flutter-project
```

2. Installer les dépendences

```bash
flutter pub get
```

3. Lancer le projet

```bash
flutter run
```

## Variables d'environement

La variable `ENV` du fichier [.env](./.env) peut être modifiée pour avoir des résultats différents : 
- si `ENV=prod` : la base de données de production (firebase) est utilisée
- si `ENV=dev` : une fausse base de données temporaire est utilisée (et la page de login est désactivée)
