#!/bin/bash

# Nom du dossier contenant le proje
Name_dossier="./C"

# Vérifier si le dossier existe
if [ -d "$Name_dossier" ]; then
    # Changer de répertoire vers le dossier du projet
    (
        cd "$Name_dossier"
        if [ -f "Makefile" ]; then
            echo "Compilation en cours..."
            make all
            if [ -f "factorielle" ]; then
                echo "Compilation réussie, exécutable 'factorielle' créé."
            else
                echo "Erreur : L'exécutable 'factorielle' n'a pas été créé."
            fi
        else
            echo "Le Makefile n'est pas présent dans le dossier."
        fi
    )
else
    echo "Le dossier '$Name_dossier' n'existe pas ou n'est pas accessible."
fi


