note=0
NOTE_MINIMAL=0
NOTE_MAX=20
output_csv="result.csv"

initialize_csv() {
    if [ ! -f "$output_csv" ]; then
        echo "Nom,Prenom,Note" > "$output_csv"
    fi
}

adjust_note() {
    if [ "$note" -lt "$NOTE_MINIMAL" ]; then
        note=$NOTE_MINIMAL
    elif [ "$note" -gt "$NOTE_MAX" ]; then
        note=$NOTE_MAX
    fi
}

lancer_correction() {
    local folder="${1:-.}"

    if [ ! -d "$folder" ]; then
        echo "Le dossier $folder n'existe pas."
        return 1
    fi

    initialize_csv

    if [ -f "$folder/Makefile" ]; then
        process_student "$folder"
    else
        echo "Aucun Makefile trouvÃ© dans $folder"
    fi
}

process_student() {
    local student_folder="$1"
    local student_name="Unknown"
    local student_first_name="Unknown"

    if [ -f "$student_folder/readme.txt" ]; then
        read -r student_name student_first_name < "$student_folder/readme.txt"
    fi

    note=0

    if [ -f "$student_folder/Makefile" ]; then
        check_compilation "$student_folder"
        check_header "$student_folder"
        check_make_clean "$student_folder"
    fi

    adjust_note
    echo "'$student_name','$student_first_name',$note" >> "$output_csv"
}

check_header() {
    local student_folder="$1"

    if [ ! -f "$student_folder/header.h" ]; then
        note=$((note - 2))
        adjust_note
    fi
}

check_compilation() {
    local student_folder="$1"

    make -C "$student_folder" > /dev/null 2>&1

    if [ -f "$student_folder/factorielle" ]; then
        note=$((note + 2))
        adjust_note
        check_signature "$student_folder"
        check_ligne "$student_folder"
        check_execution "$student_folder"
        check_no_argument_message "$student_folder"
        check_negative_argument_message "$student_folder"
        check_indentation "$student_folder"
    else
        note=$((note - 5))
        adjust_note
    fi
}

check_execution() {
    local student_folder="$1"

    result=$(./"$student_folder"/factorielle 5 2>/dev/null)
    if [ "$result" -eq 120 ] 2>/dev/null; then
        note=$((note + 5))
        adjust_note
    fi

    result=$(./"$student_folder"/factorielle 0 2>/dev/null)
    if [ "$result" -eq 1 ] 2>/dev/null; then
        note=$((note + 3))
        adjust_note
    fi
}

check_signature() {
    local student_folder="$1"

    if grep -Eq "int +factorielle *\( *int +number *\)" "$student_folder/main.c"; then
        note=$((note + 2))
        adjust_note
    fi
}

check_ligne() {
    local student_folder="$1"

    if grep -qE '.{81,}' "$student_folder/main.c"; then
        note=$((note - 2))
        adjust_note
    fi

    if grep -qE '.{81,}' "$student_folder/header.h"; then
        note=$((note - 2))
        adjust_note
    fi
}

check_indentation() {
    local student_folder="$1"

    if grep -qE "^[ ]{1}[^ ]|^[ ]{3}[^ ]" "$student_folder/main.c"; then
        note=$((note - 2))
        adjust_note
    fi

    if grep -qE "[a-zA-Z0-9)}] *{" "$student_folder/main.c"; then
        note=$((note - 2))
        adjust_note
    fi
}

check_make_clean() {
    local student_folder="$1"

    make -C "$student_folder" clean > /dev/null 2>&1

    if [ -f "$student_folder/factorielle" ]; then
        note=$((note - 2))
        adjust_note
    fi
}

check_no_argument_message() {
    local student_folder="$1"

    original_result=$(./"$student_folder"/factorielle 2>&1 | tr -d '\n')
    if [ "$original_result" = "Erreur: Mauvais nombre de parametres" ]; then
        note=$((note + 4))
        adjust_note
    fi
}

check_negative_argument_message() {
    local student_folder="$1"

    result=$(./"$student_folder"/factorielle -5 2>&1 | tr -d '\n')
    if [ "$result" = "Erreur: nombre negatif" ]; then
        note=$((note + 4))
        adjust_note
    fi
}

lancer_correction "$1"
message.txt
4 Ko
