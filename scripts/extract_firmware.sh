#!/usr/bin/env bash

echo -e "Extracting Firmware."
cd "$(pwd)/Downloads"
sudo 7z x firmware.zip && sudo rm -rf firmware.zip && sudo rm -rf *.txt && for file in *.md5; do sudo mv -- "$file" "${file%.md5}"; done

echo -e "Extracting tar files."
for file in *.tar; do
    sudo tar -xvf "$file"
done
sudo find . -type f ! -name 'super.img.lz4' ! -name 'optics.img.lz4' ! -name 'prism.img.lz4' ! -name 'boot.img.lz4' -delete
sudo rm -rf *.tar
sudo rm -rf meta-data

echo -e "Extracting lz4 files."
for file in *.lz4; do
    sudo lz4 -d "$file" "${file%.lz4}"
done
sudo rm -rf *.lz4

echo -e "Converting all images to raw img."
for file in *.img; do
    if [ "$file" != "boot.img" ]; then
        sudo simg2img "$file" "${file%.img}.img.raw"
    else
        echo "Skipping boot.img"
    fi
done

sudo find . -type f -name '*.img' ! -name 'boot.img' -delete
for file in *.raw; do
    sudo mv -- "$file" "${file%.raw}"
done

echo -e "Check and extract all partitions from super.img."
if [ -f "super.img" ]; then
    echo "super.img found. Extracting partitions..."
    lpunpack super.img
    rm -rf super.img
else
    echo "super.img not found. Skipping..."
fi

echo -e "Compressing all images to xz format."
for i in *.img; do
    7z a -mx9 "${i%.*}.img.xz" "$i" && rm "$i"
done
