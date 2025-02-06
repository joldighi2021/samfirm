echo "Updating system packages"
sudo apt update -y

echo "Installing python3"
# Python3 is for samfirm
sudo apt update python3 -y

echo "Installing samloader"
pip3 install git+https://github.com/martinetd/samloader.git
