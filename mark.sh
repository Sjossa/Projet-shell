note=0
output_csv="result.csv"

initialize_csv() {
    if [ ! -f "$output_csv" ]; then
        touch "$output_csv"
    fi
}

lancer_correction() {
    local folder="${1:-.}"

    if [ ! -d "$folder" ]; then
        echo "Le dossier $folder n'existe pas."
        return
    fi

    initialize_csv

    if [ -f "$folder/Makefile" ]; then
        process_student "$folder"
    fi
}

process_student() {
    local student_folder="$1"
    local student_name="Unknown"
    local student_first_name="Unknown"

    if [ -f "$student_folder/readme.txt" ]; then
        student_name=$(head -n 1 "$student_folder/readme.txt" | awk '{print $1}')
        student_first_name=$(head -n 1 "$student_folder/readme.txt" | awk '{print $2}')
    fi

    note=0

    if [ -f "$student_folder/Makefile" ]; then
        check_compilation "$student_folder"
        check_header "$student_folder"
        check_make_clean "$student_folder"
    fi

    echo "$student_name,$student_first_name,$note" >> "$output_csv"
}

check_header() {
    if [ ! -f "$student_folder/header.h" ]; then
        note=$((note - 2))
    fi
}

check_compilation() {
    make -C "$student_folder" > /dev/null 2>&1
    if [ -f "$student_folder/factorielle" ]; then
        note=$((note + 2))
        check_signature "$student_folder"
        check_ligne "$student_folder"
        check_execution "$student_folder"
        check_no_argument_message "$student_folder"
        check_negative_argument_message "$student_folder"
        check_indentation "$student_folder"
    fi
}

check_execution() {
    execution_1() {
        result=$(./factorielle 5 2>&1)
        if [ "$result" -eq 120 ]; then
            note=$((note + 5))
        fi
    }

    execution_2() {
        result=$(./factorielle 0 2>&1)
        if [ "$result" -eq 1 ]; then
            note=$((note + 3))
        fi
    }

    execution_1
    execution_2
}

check_signature() {
    if grep -Eq "int +factorielle *\( *int +number *\)" "$student_folder/main.c"; then
        note=$((note + 2))
    fi
}

check_ligne() {
    if grep -Eq '.{81,}' "$student_folder/main.c"; then
        note=$((note - 2))
    fi

    if grep -Eq '.{81,}' "$student_folder/header.h"; then
        note=$((note - 2))
    fi
}

check_indentation() {
    if grep -q -E "^[ ]{1}[^ ]|^[ ]{3}[^ ]" "$student_folder/main.c"; then
        note=$((note - 2))
    fi

    if grep -q -E "[a-zA-Z0-9)}] *{" "$student_folder/main.c"; then
        note=$((note - 2))
    fi
}

check_make_clean() {
    make -C "$student_folder" clean > /dev/null 2>&1
    if [ -f "$student_folder/factorielle" ]; then
        note=$((note - 2))
    fi
}

check_no_argument_message() {
    original_result=$(./factorielle 2>&1)
    result=$(echo "$original_result" | tr -d '\n')

    if [ "$result" = "Erreur: Mauvais nombre de parametres" ]; then
        note=$((note + 4))
    fi
}

check_negative_argument_message() {
    result=$(./factorielle -5 2>&1 | tr -d '\n')
    if [ "$result" = "Erreur: nombre negatif" ]; then
        note=$((note + 4))
    fi
}

lancer_correction "$1"