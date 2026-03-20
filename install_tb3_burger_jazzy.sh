#!/bin/bash
# Avbryt vid fel
set -e

echo "--- STARTAR KOMPLETT INSTALLATION: TB3 BURGER (ROS 2 JAZZY) ---"

# 1. Uppdatera och installera verktyg
sudo apt update && sudo apt upgrade -y
sudo apt install -y software-properties-common curl wget git

# 2. FIX: Tvinga rätt versioner för Ubuntu 24.04 (Noble)
# Detta löser "unmet dependencies" för lz4, zstd, zlib och bz2
echo "--- Åtgärdar versionskonflikter för bibliotek ---"
sudo apt install -y \
  liblz4-1=1.9.4-1build1 \
  libzstd1=1.5.5+dfsg2-2build1 \
  zlib1g=1:1.3.dfsg-3.1ubuntu2 \
  libbz2-1.0=1.0.8-5.1 \
  --allow-downgrades

# Lås versionerna tillfälligt så att ROS-installationen inte kraschar
sudo apt-mark hold liblz4-1 libzstd1 zlib1g libbz2-1.0

# 3. Konfigurera ROS 2 Jazzy Repo
echo "--- Lägger till ROS 2 Jazzy Repository ---"
sudo add-apt-repository universe -y
sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null

# 4. Installera ROS 2, TB3-paket, Bringup och Teleop
sudo apt update
echo "--- Installerar ROS 2 Jazzy och TurtleBot3-paket ---"
sudo apt install -y \
  ros-jazzy-ros-base \
  python3-colcon-common-extensions \
  ros-jazzy-turtlebot3-msgs \
  ros-jazzy-turtlebot3 \
  ros-jazzy-turtlebot3-bringup \
  ros-jazzy-turtlebot3-teleop \
  ros-jazzy-dynamixel-sdk \
  ros-jazzy-hls-lfcd-lds-driver

# 5. Konfigurera OpenCR USB (udev-regler)
echo "--- Konfigurerar USB-regler för OpenCR ---"
if [ ! -f /etc/udev/rules.d/99-opencr-interface.rules ]; then
    wget https://raw.githubusercontent.com/ROBOTIS-GIT/OpenCR/master/99-opencr-interface.rules
    sudo cp 99-opencr-interface.rules /etc/udev/rules.d/
    sudo udevadm control --reload-rules
    sudo udevadm trigger
    rm 99-opencr-interface.rules
fi

# 6. Sätt miljövariabler i .bashrc
echo "--- Uppdaterar miljövariabler i .bashrc ---"
grep -qxF 'source /opt/ros/jazzy/setup.bash' ~/.bashrc || echo 'source /opt/ros/jazzy/setup.bash' >> ~/.bashrc
grep -qxF 'export TURTLEBOT3_MODEL=burger' ~/.bashrc || echo 'export TURTLEBOT3_MODEL=burger' >> ~/.bashrc
grep -qxF 'export LDS_MODEL=LDS-01' ~/.bashrc || echo 'export LDS_MODEL=LDS-01' >> ~/.bashrc

# 7. Släpp låset på biblioteken
sudo apt-mark unhold liblz4-1 libzstd1 zlib1g libbz2-1.0

echo "-------------------------------------------------------"
echo "INSTALLATION KLAR!"
echo "1. Kör: source ~/.bashrc"
echo "2. Flasha OpenCR (om ej gjort): ./flash_opencr_burger.sh"
echo "3. Testa roboten: ./test_tb3.sh"
echo "-------------------------------------------------------"
