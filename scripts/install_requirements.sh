echo "Updating system packages"
apt update -y

echo "Installing python3"
# Python3 is for samfirm
apt install -y python3

echo "Installing samloader"
pip3 install git+https://github.com/martinetd/samloader.git

echo "Installing packages for extract firmware"
sudo apt install -y python3 p7zip-full lz4 android-sdk-libsparse-utils && pip3 install liblp
