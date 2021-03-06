### LOGIN ###
username: odroid
password: odroid

### REMOVE UNNECESSARY PROGRAMS ###
sudo apt-get update
sudo apt-get remove --purge libreoffice* plank simple-scan shotwell imagemagick* pidgin hexchat thunderbird brasero kodi rhythmbox xzoom gnome-orca onboard atril mate-utils seahorse tilda
sudo apt-get purge firefox
sudo rm -rf ~/.mozilla/firefox ~/.macromedia ~/.adobe /etc/firefox /usr/lib/firefox /usr/lib/firefox-addons
sudo apt-get clean
sudo apt-get autoremove

### INSTALL EXTRAS ###
sudo apt-get update
sudo apt-get dist-upgrade
sudo apt-get install build-essential checkinstall cmake cmake-curses-gui pkg-config gparted guvcview lightdm-gtk-greeter-settings

### CONFIGURE DESKTOP ENVIRONMENT ###
1. Set up welcome screen (system -> administration menu)
2. Resize partition to 7168 MB with gparted
3. Combine panels
4. Set background to solid color
5. Remove logout application launch bar (lower right corner)
6. Set taskbar icons (caja, mate terminal, chromium)
7. Disable screensaver
8. Run ODROID Utility

### INSTALL OPENCV DEPENDENCIES ###
sudo apt-get install build-essential checkinstall cmake pkg-config yasm libtiff5-dev libjpeg-dev libjasper-dev libavcodec-dev libavformat-dev libswscale-dev libdc1394-22-dev libxine2-dev libgstreamer0.10-dev libgstreamer-plugins-base0.10-dev libv4l-dev python-dev python-numpy libqt4-dev libgtk2.0-dev libavcodec-dev libavformat-dev libswscale-dev libtbb2 libtbb-dev ffmpeg

### GET OPENCV SOURCE ###
cd ~
wget https://github.com/Itseez/opencv/archive/2.4.12.1.zip
unzip 2.4.12.1.zip
rm 2.4.12.1.zip
cd opencv-2.4.12.1

### BUILD AND INSTALL OPENCV ###
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_INSTALL_PREFIX=/usr/local -DWITH_OPENGL=ON -DWITH_V4L=ON -DWITH_TBB=ON -DBUILD_TBB=ON -DENABLE_VFPV3=ON -DENABLE_NEON=ON ..
make -j4
sudo make install
 
### GET ODROID-DEVELOPMENT EXAMPLES ###
cd ~
git clone https://github.com/cmcmurrough/odroid-development.git
 
### INSTALL AND PATCH OPENCL HEADERS ###
sudo apt-get install opencl-headers
sudo rm /usr/include/CL/cl.hpp
sudo cp odroid-development/misc/cl.hpp /usr/include/CL
 
### BUILD AND INSTALL LIBFREENECT2 ###
cd ~
sudo apt-get install build-essential libturbojpeg libjpeg-turbo8-dev libtool autoconf libudev-dev cmake mesa-common-dev freeglut3-dev libxrandr-dev doxygen libxi-dev automake opencl-headers libglfw3-dev
git clone https://github.com/cmcmurrough/libfreenect2.git
cd libfreenect2/depends
sudo sh install_libusb.sh
cd ../examples/protonect
mkdir build
cd build
cmake -DENABLE_OPENGL=OFF ..
make -j4
sudo make install
sudo cp ~/libfreenect2/rules/90-kinect2.rules /etc/udev/rules.d/
./../bin/Protonect
 
### INSTALL OPENNI (https://github.com/cmcmurrough/OpenNI2) ###
cd ~
sudo apt-get install -y g++ python libusb-1.0-0-dev libudev-dev openjdk-6-jdk freeglut3-dev doxygen graphviz
git clone https://github.com/cmcmurrough/OpenNI2
cd OpenNI2
PLATFORM=Arm make
cd Packaging && python ReleaseVersion.py Arm
mv Final/OpenNI-Linux-Arm-2.2.tar.bz2 ~
cd ~
tar -xvf OpenNI-Linux-Arm-2.2.tar.bz2
rm -rf OpenNI2
rm OpenNI-Linux-Arm-2.2.tar.bz2
cd OpenNI-Linux-Arm-2.2
sudo sh install.sh

### BUILD AND INSTALL LIBFREENECT ###
cd ~
sudo apt-get install libxmu-dev libxi-dev libusb-dev
git clone http://github.com/cmcmurrough/libfreenect
cd libfreenect
mkdir build
cd build
cmake .. -DBUILD_OPENNI2_DRIVER=ON
make -j4
Repository=~/OpenNI-Linux-Arm-2.2/Redist/OpenNI2/Drivers/
cp -L lib/OpenNI2-FreenectDriver/libFreenectDriver.so ${Repository}
sudo cp ~/libfreenect/platform/linux/udev/51-kinect.rules /etc/udev/rules.d

### CREATE TEMPORARY SWAP FILE ###
dd if=/dev/zero of=~/.swapfile bs=1024 count=1M
mkswap ~/.swapfile
sudo swapon ~/.swapfile
swapon -s

### INSTALL PCL DEPENDENCIES ###
sudo apt-get install freeglut3-dev libboost-all-dev libeigen3-dev libflann-dev libvtk5-dev libusb-1.0-0-dev libqhull-dev

### GET PCL SOURCE (RELEASE 1.7.2) ###
cd ~
git clone https://github.com/PointCloudLibrary/pcl pcl-1.7.2
cd pcl-1.7.2

### BUILD AND INSTALL PCL ###
mkdir build
cd build
cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local ..
make
sudo make install

### DELETE TEMPORARY SWAP FILE ###
swapoff ~/.swapfile
sudo rm ~/.swapfile

### BUILD AND INSTALL ROS BAREBONES (http://wiki.ros.org/jade/Installation/Source)###
sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
sudo apt-key adv --keyserver hkp://pool.sks-keyservers.net --recv-key 0xB01FA116
sudo apt-get update

sudo apt-get install python-rosdep python-rosinstall-generator python-wstool python-rosinstall build-essential
sudo rosdep init
rosdep update

mkdir ~/ros_catkin_ws
cd ~/ros_catkin_ws
rosinstall_generator ros_comm --rosdistro jade --deps --wet-only --tar > jade-ros_comm-wet.rosinstall
wstool init -j8 src jade-ros_comm-wet.rosinstall

sudo rosdep init
rosdep update
sudo rosdep install --from-paths src --ignore-src --rosdistro jade -y
./src/catkin/bin/catkin_make_isolated --install -DCMAKE_BUILD_TYPE=Release -j4
sudo rm -R ~/.ros/
echo "source ~/ros_catkin_ws/install_isolated/setup.bash" >> ~/.bashrc
echo "export LC_ALL=C" >> ~/.bashrc
source ~/.bashrc

### INSTALL ARDUINO IDE ###
sudo apt-get update && sudo apt-get install arduino arduino-core