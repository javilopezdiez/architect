#!/bin/bash

# Function to display debug information
debug_info() {
    echo "Debug Information:"
    echo "FILE: $FILE"
    echo "BEFORE: $BEFORE"
    echo "CODE_FILE: $CODE_FILE"
    echo "FN: $FN"
    echo "CODE_FILE content:"
    cat "$CODE_FILE"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --file)
            FILE="$2"
            shift 2
            ;;
        --before)
            BEFORE="$2"
            shift 2
            ;;
        --codefile)
            CODE_FILE="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Check if all required arguments are provided
if [ -z "$FILE" ] || ([ -n "$BEFORE" ] && [ -z "$CODE_FILE" ]); then
    echo "Usage: $0 --file FILE [--before BEFORE --codefile CODE_FILE]"
    exit 1
fi

# Check if the file exists
if [ ! -f "$FILE" ]; then
    echo "File '$FILE' not found"
    exit 1
fi

# Print debug information
# debug_info
# echo ""

if [ -n "$BEFORE" ]; then
    # Check if the code file exists
    if [ ! -f "$CODE_FILE" ]; then
        echo "Code file '$CODE_FILE' not found"
        exit 1
    fi

    # Check if the code is already present
    if grep -Fxq "$(cat "$CODE_FILE")" "$FILE"; then
        echo "Code already present in ${FILE}"
        exit 0
    fi

    # Insert the code before the specified line
    sudo sed -i "/${BEFORE}/r ${CODE_FILE}" "$FILE"
    echo "Code inserted successfully before line '${BEFORE}' in ${FILE}"
else
    # Extract function name from the code file
    FN=$(grep -oP "(?<=def\s)\w+" "$CODE_FILE")

    # Check if the function exists in the file
    if ! grep -q "def $FN(" "$FILE"; then
        echo "Function '$FN' not found in '$FILE'"
        exit 1
    fi

    # Replace function definition with code from the code file
    awk -v fn="$FN" -v codefile="$CODE_FILE" '{
        if ($0 ~ "def " fn "\\(") {
            system("cat " codefile)
            insert_done = 1
            next
        }
        if (insert_done && $0 ~ "^def ") {
            insert_done = 0
        }
        if (!insert_done) {
            print
        }
    }' "$FILE" > "$FILE.tmp" && mv "$FILE.tmp" "$FILE"

    echo "Code replaced successfully in $FILE"
fi
