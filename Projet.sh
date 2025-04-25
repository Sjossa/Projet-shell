#!/bin/bash

# Définition du dossier et de la note initiale
Name_dossier="./C"
note=0

# Fonction de correction principale
lancer_correction() {
    if [ ! -d "$Name_dossier" ]; then
        echo "Le dossier '$Name_dossier' n'existe pas ou est inaccessible."
        return
    fi

    cd "$Name_dossier" || exit

    if [ ! -f "Makefile" ]; then
        return
    fi

    check_compilation
    echo "Note finale : $note/20"
}

# Vérification de la compilation
check_compilation() {
    make > /dev/null 2>&1
    if [ -f "factorielle" ]; then
        note=$((note + 2))

        check_signature
        check_ligne
        check_execution
        check_no_argument_message
        check_negative_argument_message
        check_indentation
    else
        echo "❌ La compilation a échoué."
        return
    fi
}

# Vérification de l'exécution du programme
check_execution() {
    execution_1() {
        result=$(./factorielle 5)
        if [ "$result" -eq 120 ]; then
            note=$((note + 5))
        else
            echo "❌ Résultat incorrect pour input 5"
        fi
    }

    execution_2() {
        result=$(./factorielle 0)
        if [ "$result" -eq 1 ]; then
            note=$((note + 3))
        else
            echo "❌ Résultat incorrect pour input 0"
        fi
    }

    execution_1
    execution_2
}

# Vérification de la signature de la fonction
check_signature() {
    if grep -Eq "int +factorielle *\( *int +number *\)" main.c; then
        note=$((note + 2))
    else
        echo "❌ Signature de la fonction incorrecte."
    fi
}

# Vérification des lignes trop longues
check_ligne() {
    if grep -Eq '.{81,}' main.c; then
        note=$((note - 2))
        echo "❌ Lignes trop longues dans main.c."
    fi

    if grep -Eq '.{81,}' header.h; then
        note=$((note - 2))
        echo "❌ Lignes trop longues dans header.h."
    fi
}

# Vérification des indentations
check_indentation() {
    if [ -f "main.c" ]; then
        # Vérifier l'indentation (doit être un multiple de 2 espaces)
        if grep -q -E "^[ ]{2,}[^ ]" main.c; then
            note=$((note - 2))
            echo "❌ Mauvaise indentation dans main.c."
        fi

        # Vérifier que les accolades sont sur leur propre ligne
        if grep -q -E "[^ \t{][ \t]*{" main.c; then
            note=$((note - 2))
            echo "❌ Les accolades ne sont pas sur une ligne séparée dans main.c."
        fi
    fi
}

# Vérification du message d'erreur pour aucun argument
check_no_argument_message() {
    result=$(./factorielle 2>&1)
    if [ "$result" = "Erreur: Mauvais nombre de parametres" ]; then
        note=$((note + 4))
    else
        echo "❌ Message incorrect pour aucun argument fourni."
    fi
}

# Vérification du message d'erreur pour un argument négatif
check_negative_argument_message() {
    result=$(./factorielle -5 2>&1)
    if [ "$result" = "Erreur: nombre negatif" ]; then
        note=$((note + 4))
    else
        echo "❌ Message incorrect pour un argument négatif."
    fi
}

# Lancer la correction
lancer_correction
