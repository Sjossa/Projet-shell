
Name_dossier="./C"
note=0

check_compilation() {
    make > /dev/null 2>&1
    if [ -f "factorielle" ]; then
        note=$((note + 2))

        check_signature
        check_ligne
        check_execution
    else
        return
    fi
}

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

check_signature() {
    if grep -Eq "int +factorielle *\( *int +number *\)" main.c; then
        note=$((note + 2))

    fi
}

check_ligne() {
    if grep -Eq '.{81,}' main.c; then
        note=$((note - 2))
    fi

    if grep -Eq '.{81,}' header.h; then
        note=$((note - 2))
    fi
}
lancer_correction() {
    if [ ! -d "$Name_dossier" ]; then
        echo "❌ Le dossier '$Name_dossier' n'existe pas ou est inaccessible."
        return
    fi

    cd "$Name_dossier" || exit

    if [ ! -f "Makefile" ]; then
        return
    fi

    check_compilation
}

lancer_correction
echo "Note finale : $note/20"
