#!/bin/bash

set -e

usage() {
    echo "Usage:"
    echo "  $0 encrypt <directory>"
    echo "  $0 decrypt <directory>"
    exit 1
}

if [ "$#" -ne 2 ]; then
    usage
fi

MODE="$1"
TARGET_DIR="$2"

if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: '$TARGET_DIR' is not a directory."
    exit 1
fi


encrypt_dir() {
    read -s -p "Enter encryption password: " PASSPHRASE
    echo
    read -s -p "Confirm password: " CONFIRM
    echo

    if [ "$PASSPHRASE" != "$CONFIRM" ]; then
        echo "Passwords do not match."
        exit 1
    fi

    find "$TARGET_DIR" -type f | while read -r FILE; do
        if [[ "$FILE" == *.gpg ]]; then
            echo "Refusing to encrypt already encrypted file: $FILE"
            continue
        fi

        if [ -f "${FILE}.gpg" ]; then
            echo "Encrypted version already exists for: $FILE"
            continue
        fi

        echo "Encrypting: $FILE"
        gpg --batch -c --passphrase "$PASSPHRASE" \
            --output "${FILE}.gpg" "$FILE"

        if [ $? -eq 0 ]; then
            rm -f "$FILE"
        fi
    done

    echo "Encryption complete."
}


decrypt_dir() {
    read -s -p "Enter decryption password: " PASSPHRASE
    echo

    GPG_FILES=$(find "$TARGET_DIR" -type f -name "*.gpg")

    if [ -z "$GPG_FILES" ]; then
        echo "Error: No encrypted (.gpg) files found to decrypt."
        exit 1
    fi

    BASE_DECRYPT_DIR="decrypted"
    mkdir -p "$BASE_DECRYPT_DIR"

    echo "$GPG_FILES" | while read -r FILE; do
        REL_PATH="${FILE#$TARGET_DIR/}"
        OUTPUT_FILE="$BASE_DECRYPT_DIR/${REL_PATH%.gpg}"

        mkdir -p "$(dirname "$OUTPUT_FILE")"

        if [ -f "$OUTPUT_FILE" ]; then
            echo "Refusing to overwrite existing file: $OUTPUT_FILE"
            continue
        fi

        echo "Decrypting: $FILE"
        gpg --batch -d --passphrase "$PASSPHRASE" \
            --output "$OUTPUT_FILE" "$FILE"

        if [ $? -ne 0 ]; then
            echo "Failed to decrypt: $FILE"
            rm -f "$OUTPUT_FILE"
        fi
    done

    echo "Decryption complete."
}


case "$MODE" in
    encrypt)
        encrypt_dir
        ;;
    decrypt)
        decrypt_dir
        ;;
    *)
        usage
        ;;
esac
