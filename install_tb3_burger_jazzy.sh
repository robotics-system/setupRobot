#!/bin/bash
# Avbryt vid fel
set -e

echo "--- Startar automatiserad installation för TurtleBot3 Burger (Jazzy) ---"

# 1. Uppdatera listor och installera grundläggande verktyg
sudo apt update
sudo apt install -y software-properties-common curl wget

# 2. FIX: Hantera "unmet dependencies" för bibliotek i Ubuntu 24.04
# Vi tvingar installation av de versioner som ROS-paketen kräver
echo "--- Åtgärdar versionskonflikter för bibliotek ---"
sudo apt install -y \
  liblz4-1=1.9.4-1build1 \
  libzstd1=1.5.5+dfsg2-2build1 \
  zlib1g=1:1.3.dfsg-3.1ubuntu2 \
  --allow-downgrades

# Lås dessa versioner tillfälligt för att undvika nya fel under ROS-install
sudo apt-mark hold liblz4-1 libzstd1 zlib1g

# 3. Konfigurera ROS 2 Jazzy Repositories
echo "--- Konfigurerar ROS 2 Jazzy Repository ---"
sudo add-apt-repository universe -y
sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null

# 4. Installera ROS 2 Base och utvecklarverktyg
sudo apt update
sudo apt install -y ros-jazzy-ros-base python3-colcon-common-extensions

# 5. Installera TurtleBot3-paket och drivrutiner
echo "--- Installerar TurtleBot3-specifika paket ---"
sudo apt install -y \
  ros-jazzy-turtlebot3-msgs \
  ros-jazzy-turtlebot3 \
  ros-jazzy-dynamixel-sdk \
  ros-jazzy-hls-lfcd-lds-driver

# 6. Konfigurera OpenCR USB (udev-regler)
echo "--- Konfigurerar USB-regler för OpenCR ---"
if [ ! -f /etc/udev/rules.d/99-opencr-interface.rules ]; then
    wget https://raw.githubusercontent.com/ROBOTIS-GIT/OpenCR/master/99-opencr-interface.rules
    sudo cp 99-opencr-interface.rules /etc/udev/rules.d/
    sudo udevadm control --reload-rules
    sudo udevadm trigger
    rm 99-opencr-interface.rules
fi

# 7. Sätt miljövariabler i .bashrc (om de inte redan finns)
echo "--- Uppdaterar .bashrc ---"
grep -qxF 'source /opt/ros/jazzy/setup.bash' ~/.bashrc || echo 'source /opt/ros/jazzy/setup.bash' >> ~/.bashrc
grep -qxF 'export TURTLEBOT3_MODEL=burger' ~/.bashrc || echo 'export TURTLEBOT3_MODEL=burger' >> ~/.bashrc
grep -qxF 'export LDS_MODEL=LDS-01' ~/.bashrc || echo 'export LDS_MODEL=LDS-01' >> ~/.bashrc

# Släpp låset på biblioteken så systemet kan uppdateras normalt i framtiden
sudo apt-mark unhold liblz4-1 libzstd1 zlib1g

echo "--- INSTALLATION KLAR ---"
echo "Kör 'source ~/.bashrc' för att börja använda ROS 2 Jazzy."
