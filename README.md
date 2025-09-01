# Flutter-project

## Groupe 

- Thomas L.
- David W.
- Antoine H.

## Utiliser le projet

1. Cloner le repository
```bash
git clone https://github.com/Orden14/Flutter-project.git
```

2. Lancer le projet (requiers une installation complête de Flutter)
```bash
flutter run
```

## Variables d'environement

La variable `ENV` du fichier [.env](./.env) peut être modifiée pour avoir des résultats différents : 
- si `ENV=dev` : une fausse base de données temporaire est utilisée (et la page de login est désactivée)
- si `ENV=prod` : la base de données de production (firebase) est utilisée
