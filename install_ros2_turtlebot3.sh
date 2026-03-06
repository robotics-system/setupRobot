#!/bin/bash
# Installationsskript för ROS 2 Jazzy och TurtleBot3 Burger på Ubuntu Server 24.04.4 (Raspberry Pi)
# Följer den officiella manualen (https://emanual.robotis.com/docs/en/platform/turtlebot3/sbc_setup/) för kommandorad
# Kör kommandot: 
#   chmod +x install_ros2_turtlebot3.sh
#   ./install_ros2_turtlebot3.sh

set -e

echo "=========================================================="
echo " Börjar installationen av ROS 2 Jazzy och TurtleBot3 (SBC)..."
echo "=========================================================="

echo "[1/4] Uppdaterar systemet och installerar nödvändiga verktyg..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y software-properties-common curl locales build-essential git colcon tmux vim wget

echo "[2/4] Lägger till ROS 2 apt-repository och installerar baspaketen (ros-base)..."
sudo locale-gen en_US en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8

sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null

sudo apt update
sudo apt install -y ros-jazzy-ros-base python3-argcomplete python3-colcon-common-extensions python3-vcstool

echo "[3/4] Hämtar källkod och installerar TurtleBot3-paket på en arbetsyta..."
# Enligt manualen: Bygg TurtleBot3-paket från källkod i ~/turtlebot3_ws
mkdir -p ~/turtlebot3_ws/src
cd ~/turtlebot3_ws/src

# Klona de nödvändiga repo:sen. (Vi kollar ut "jazzy"-branchen eller motsvarande om det finns, just nu brukar jazzy-devel vara rätt)
git clone -b jazzy-devel https://github.com/ROBOTIS-GIT/turtlebot3.git || git clone -b ros2 https://github.com/ROBOTIS-GIT/turtlebot3.git
git clone -b jazzy-devel https://github.com/ROBOTIS-GIT/turtlebot3_msgs.git || git clone -b ros2 https://github.com/ROBOTIS-GIT/turtlebot3_msgs.git
git clone -b jazzy-devel https://github.com/ROBOTIS-GIT/turtlebot3_simulations.git || git clone -b ros2 https://github.com/ROBOTIS-GIT/turtlebot3_simulations.git

cd ~/turtlebot3_ws
# Installera beroenden via rosdep (mycket viktigt enligt manualen)
sudo apt install -y python3-rosdep
sudo rosdep init || echo "rosdep är redan initierad"
rosdep update
rosdep install -i --from-path src --rosdistro jazzy -y

# Bygger arbetsytan (som oftast inkluderar lds driver, dynamixel etc)
source /opt/ros/jazzy/setup.bash
colcon build --symlink-install --parallel-workers 2

echo "[4/4] Konfigurerar OpenCR Udev-regler och Miljövariabler i ~/.bashrc..."
# Udev-regler från e-manual
wget -qO- https://raw.githubusercontent.com/ROBOTIS-GIT/turtlebot3/master/turtlebot3_bringup/scripts/create_udev_rules | sudo bash || echo "Kunde inte ladda ner udev-regler automatiskt."

if ! grep -q "source /opt/ros/jazzy/setup.bash" ~/.bashrc; then
    echo "source /opt/ros/jazzy/setup.bash" >> ~/.bashrc
fi

if ! grep -q "source ~/turtlebot3_ws/install/setup.bash" ~/.bashrc; then
    echo "source ~/turtlebot3_ws/install/setup.bash" >> ~/.bashrc
fi

if ! grep -q "export TURTLEBOT3_MODEL=burger" ~/.bashrc; then
    echo "export TURTLEBOT3_MODEL=burger" >> ~/.bashrc
fi

if ! grep -q "export ROS_DOMAIN_ID" ~/.bashrc; then
    # Ändra detta nummer (t.ex. 30) så att det stämmer överens med datorernas DOMAIN_ID
    echo "export ROS_DOMAIN_ID=30" >> ~/.bashrc
fi

if ! grep -q "export LDS_MODEL=LDS-02" ~/.bashrc; then
    # De flesta nya Burger-modeller använder LDS-02. Ändra till LDS-01 om din sensor är äldre.
    echo "export LDS_MODEL=LDS-02" >> ~/.bashrc 
fi

echo "=========================================================="
echo " Installationen är klar!"
echo " För att ändringarna ska ta effekt, kör: source ~/.bashrc"
echo " (Ett tips är att ändra ROS_DOMAIN_ID i ~/.bashrc så den matchar det id ni valt för routern/kursen)"
echo "=========================================================="
