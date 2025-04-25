Name_dossier="./C"
note=0
output_csv="result.csv"

initialize_csv() {
    if [ ! -f "$output_csv" ]; then
        touch "$output_csv"
    fi
}

lancer_correction() {
    local folder="$1"

    if [ ! -d "$folder" ]; then
        echo "Le dossier '$folder' n'existe pas ou est inaccessible."
        return
    fi

    initialize_csv

    if [ -f "$folder/Makefile" ]; then
        process_student "$folder"
    else
        for student_folder in "$folder"/*; do
            if [ -d "$student_folder" ]; then
                process_student "$student_folder"
            fi
        done
    fi
}

process_student() {
    local student_folder="$1"
    local student_name="Unknown"
    local student_first_name="Unknown"

    if [ -f "$student_folder/readme.txt" ]; then
        echo "Found readme.txt at: $student_folder/readme.txt"
        echo "Content: $(cat "$student_folder/readme.txt")"
        student_name=$(head -n 1 "$student_folder/readme.txt" | awk '{print $1}')
        student_first_name=$(head -n 1 "$student_folder/readme.txt" | awk '{print $2}')
        echo "Extracted name: $student_name, first name: $student_first_name"
    else
        echo "Warning: readme.txt not found in $student_folder"
    fi

    note=0

    cd "$student_folder" || return
    if [ -f "Makefile" ]; then
        check_compilation
        check_header
        check_make_clean
    else
        echo "Makefile manquant pour $student_name $student_first_name"
    fi
    cd - > /dev/null || return

    echo "$student_name/$student_first_name/$note" >> "$output_csv"
}

check_header() {
    if [ ! -f "header.h" ]; then
        note=$((note - 2))
        echo "Fichier header.h manquant."
    fi
}

check_compilation() {
    make > /dev/null 2>&1
    if [ -f "factorielle" ]; then
        echo "Compilation réussie."
        note=$((note + 2))
        check_signature
        check_ligne
        check_execution
        check_no_argument_message
        check_negative_argument_message
        check_indentation
    else
        echo "La compilation a échoué."
    fi
}

check_execution() {
    execution_1() {
        result=$(./factorielle 5 2>&1)
        echo "Output for input 5: $result"
        if [ "$result" -eq 120 ]; then
            note=$((note + 5))
        else
            echo "Résultat incorrect pour input 5"
        fi
    }

    execution_2() {
        result=$(./factorielle 0 2>&1)
        echo "Output for input 0: $result"
        if [ "$result" -eq 1 ]; then
            note=$((note + 3))
        else
            echo "Résultat incorrect pour input 0"
        fi
    }

    execution_1
    execution_2
}

check_signature() {
    if grep -Eq "int +factorielle *\( *int +number *\)" main.c; then
        note=$((note + 2))
    else
        echo "Signature de la fonction incorrecte."
    fi
}

check_ligne() {
    if grep -Eq '.{81,}' main.c; then
        note=$((note - 2))
        echo "Lignes trop longues dans main.c."
    fi

    if grep -Eq '.{81,}' header.h; then
        note=$((note - 2))
        echo "Lignes trop longues dans header.h."
    fi
}

# chat
# CHECK INDENTATION DEBUG VERSION
check_indentation() {
    echo "Checking indentation..."
    if grep -q -E "^[ ]{1}[^ ]|^[ ]{3}[^ ]" main.c; then
        note=$((note - 2))
        echo "DEDUCTION: Mauvaise indentation dans main.c."
    fi

    echo "Checking brace placement..."
    if grep -q -E "[a-zA-Z0-9)}] *{" main.c; then
        note=$((note - 2))
        echo "DEDUCTION: Les accolades ne sont pas sur une ligne séparée dans main.c."
        # Show examples of problematic lines
        grep -n -E "[a-zA-Z0-9)}] *{" main.c
    fi
}
# WORKING CHECK INDENTATION
# check_indentation() {
#     if grep -q -E "^[ ]{1}[^ ]|^[ ]{3}[^ ]" main.c; then
#         note=$((note - 2))
#         echo "Mauvaise indentation dans main.c."
#     fi

#     if grep -q -E "[a-zA-Z0-9)}] *{" main.c; then
#         note=$((note - 2))
#         echo "Les accolades ne sont pas sur une ligne séparée dans main.c."
#     fi
# }

check_make_clean() {
    make clean > /dev/null 2>&1
    if [ -f "factorielle" ]; then
        note=$((note - 2))
        echo "La règle make clean ne fonctionne pas."
    fi
}

# CHECK NO ARGUMENT MESSAGE DEBUG VERSION
check_no_argument_message() {
    echo "Checking no argument message..."
    original_result=$(./factorielle 2>&1)
    result=$(echo "$original_result" | tr -d '\n')
    echo "Got: '$original_result'"
    echo "After stripping newline: '$result'"
    echo "Expected: 'Erreur: Mauvais nombre de parametres'"
    
    if [ "$result" = "Erreur: Mauvais nombre de parametres" ]; then
        note=$((note + 4))
        echo "SUCCESS: Message for no argument is correct."
    else
        echo "FAILURE: Message incorrect pour aucun argument fourni."
    fi
}
# check_no_argument_message() {
#     # Strip the newline from the result
#     result=$(./factorielle 2>&1 | tr -d '\n')
#     if [ "$result" = "Erreur: Mauvais nombre de parametres" ]; then
#         note=$((note + 4))
#     else
#         echo "Message incorrect pour aucun argument fourni."
#         echo "Got: '$result'"
#     fi
# }

check_negative_argument_message() {
    # Strip the newline from the result
    result=$(./factorielle -5 2>&1 | tr -d '\n')
    if [ "$result" = "Erreur: nombre negatif" ]; then
        note=$((note + 4))
    else
        echo "Message incorrect pour un argument négatif."
        echo "Got: '$result'"
    fi
}

if [ $# -eq 1 ]; then
    lancer_correction "$1"
else
    echo "Usage: $0 <dossier>"
fi