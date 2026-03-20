#!/bin/bash
set -e

echo "--- Startar installation för TurtleBot3 Burger (Jazzy) ---"

# 1. Grundläggande ROS 2 Jazzy-installation
sudo apt update && sudo apt upgrade -y
sudo apt install software-properties-common curl -y
sudo add-apt-repository universe -y
sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null
sudo apt update
sudo apt install ros-jazzy-ros-base python3-colcon-common-extensions -y

# 2. Installera TurtleBot3-paket och beroenden
sudo apt install ros-jazzy-turtlebot3-msgs -y
sudo apt install ros-jazzy-turtlebot3 -y
sudo apt install ros-jazzy-dynamixel-sdk -y
sudo apt install ros-jazzy-hls-lfcd-lds-driver -y

# 3. OpenCR USB-inställningar (udev-regler)
# Detta gör att din Raspberry Pi känner igen OpenCR-kortet korrekt
echo "--- Konfigurerar USB-regler för OpenCR ---"
wget https://raw.githubusercontent.com/ROBOTIS-GIT/OpenCR/master/99-opencr-interface.rules
sudo cp 99-opencr-interface.rules /etc/udev/rules.d/
sudo udevadm control --reload-rules
sudo udevadm trigger
rm 99-opencr-interface.rules

# 4. Miljövariabler för Burger
echo "source /opt/ros/jazzy/setup.bash" >> ~/.bashrc
echo "export TURTLEBOT3_MODEL=burger" >> ~/.bashrc
echo "export LDS_MODEL=LDS-01" >> ~/.bashrc

echo "--- Klart! Glöm inte att köra: source ~/.bashrc ---"
