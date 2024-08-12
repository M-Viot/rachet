#!/bin/bash

# Définition des couleurs
GREEN=$(tput -Txterm setaf 2)
YELLOW=$(tput -Txterm setaf 3)
RESET=$(tput -Txterm sgr0)

# Vérification de la présence du fichier .env
if [ -f ./.env ]; then
    # Importation des variables d'environnement
    set -o allexport
    source ./.env
    set +o allexport
fi

# Affichage de l'aide
function help() {
    echo ""
    echo "Utilisation : "
    echo "  ${YELLOW}bash${RESET} ${GREEN}<command>${RESET}"
    echo ""
    echo "Commandes : "
    awk '/^[a-zA-Z\-\_0-9]+:/ {
            helpMessage = match(lastLine, /^## (.*)/);
            if (helpMessage) {
                helpCommand = substr($1, 0, index($1, ":")-1);
                helpMessage = substr(lastLine, RSTART + 3, RLENGTH);
                printf "  ${YELLOW}%-$(TARGET_MAX_CHAR_NUM)s${RESET} ${GREEN}%s${RESET}\n", helpCommand, helpMessage;
            }
        }
        { lastLine = $0 }' $0
}

# Démarrage des containers
function start() {
    docker compose up -d
}

# Démarrage du npm watch
function npm-dev() {
    docker compose up -d
    docker compose exec php bash -c "npm run watch"
}

# Lancement du npm build
function npm-build() {
    docker compose up -d
    docker compose exec php bash -c "npm run build"
}

# Arrêt des containers
function stop() {
    docker compose down
}

# Nettoyage complet de Docker
function prune() {
    docker compose down
    docker system prune -a
}

# Accès au container php
function php() {
    docker compose exec php bash
}

# Accès au container database
function db() {
    docker compose exec database bash
}

# Création des tables
function db-create() {
    docker compose exec php bash -c "cd bin && php console d:d:c"
}

# Sauvegarde de la base de données
function db-dump() {
    docker compose exec database /usr/bin/mysqldump -u root --password=password $(APP_REF) > backup.sql
}

# Restauration de la base de données
function db-restore() {
    docker compose exec -T database /usr/bin/mysql -u root --password=password $(APP_REF) < backup.sql
}

# Migration de la base de données
function db-migrate() {
    docker compose exec php bash -c "cd bin && php console d:m:m"
}

# Lancement des fixtures
function db-fixtures() {
    docker compose exec php bash -c "cd bin && php console d:f:l"
}

# Initialisation d'un projet npm
function npm-init() {
    docker compose exec php bash -c "npm install"
    docker compose exec php bash -c "npm run build"
}

# Installation de composer
function composer-install() {
    docker compose exec php bash -c "composer install"
}

# Récupération du nom de la fonction à appeler
COMMAND=$1

# Appel de la fonction correspondante
$COMMAND
