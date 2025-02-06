#!/bin/bash

WDIR=$(pwd)
rm -rf "$WDIR/Downloads"
mkdir -p "$WDIR/Downloads"

MODEL=$1
CSC=$2

# Read MODEL and CSC from arguments.
if [ ${#MODEL} -ne 8 ] || [ ${#CSC} -ne 3 ]; then
    echo "Error: MODEL must be exactly 8 characters and CSC must be exactly 3 characters.\nLike bash module.sh SM-A225F BKD"
    exit 1
fi

# Read IMEIs from imei.txt for the given MODEL
IMEI_LIST=$(grep "^${MODEL}=" $(pwd)/scripts/imei.txt | cut -d '=' -f2 | tr -d '"' | tr ',' ' ')

if [ -z "$IMEI_LIST" ]; then
    echo "No IMEI found for model $MODEL in imei.txt"
    exit 1
fi

echo -e "Fetching Latest Firmware...\n"

VERSION=""
for IMEI in $IMEI_LIST; do
    echo -e "Trying IMEI: ${IMEI}\n"
    if VERSION=$(python3 -m samloader -m "${MODEL}" -r "${CSC}" -i "${IMEI}" checkupdate 2>/dev/null); then
        echo -e "Update found: ${VERSION}\n"
        break
    else
        echo -e "Failed to fetch firmware version with IMEI: ${IMEI}\n"
    fi
done

if [ -z "$VERSION" ]; then
    echo -e "No valid IMEI found to fetch firmware version.\n"
    exit 1
fi

echo -e "Attempting to Download...\n"

if [ -d "$WDIR/Downloads" ]; then
    rm -rf "$WDIR/Downloads"
fi

mkdir -p "$WDIR/Downloads"

if ! python3 -m samloader -m "${MODEL}" -r "${CSC}" -i "${IMEI}" download -v "${VERSION}" -O "$WDIR/Downloads"; then
    echo -e "\nSomething Strange Happened"
    echo -e "\nDid you enter the correct IMEI for your device model..? 👀\n"
    exit 1
fi

echo -e "\nDecrypting...\n\n"
FILE="$(ls $WDIR/Downloads/*.enc*)"
if ! python3 -m samloader -m "${MODEL}" -r "${CSC}" -i "${IMEI}" decrypt -v "${VERSION}" -i "$FILE" -o "$WDIR/Downloads/firmware.zip"; then
    echo -e "\nSomething Strange Happened\n"
    exit 1
fi

rm "${FILE}"
