#!/bin/bash

echo "Setting up ARM & STM32 Environment..."
echo "Making new directory..."
mkdir ~/gcc-arm
echo "Switching to gcc-arm..."
cd ~/gcc-arm

timestamp="4_8-2014q3"
version="4_8-2014q3-20140805-linux"
ext=".tar.bz2"
echo "Get gcc-arm-none-eabi-$version..."
wget https://launchpad.net/gcc-arm-embedded/4.8/4.8-2014-q3-update/+download/gcc-arm-none-eabi-4_8-2014q3-20140805-linux.tar.bz2

echo "Decompressing Files..."
bzip2 -d gcc-arm-none-eabi-${version}${ext}
tar -xvf "gcc-arm-none-eabi-${version}.tar"
mv gcc-arm-none-eabi-${timestamp}/* .
rmdir gcc-arm-none-eabi-${timestamp}
rm gcc-arm-none-eabi-${version}.tar

echo "GCC-ARM Setup complete, Adding to PATH"
echo "export PATH=\$PATH:~/gcc-arm" >> ~/.bashrc
echo "GCC-ARM Setup Complete!"

echo "Downloading STLINKV2 UDEV rules..."
echo "Making temporary git folder: temp_stlinkv2_git..."
mkdir temp_stlinkv2_git
git clone https://github.com/texane/stlink.git temp_stlinkv2_git
echo "Requesting superuser permissions to add UDEV rule..."
sudo mv temp_stlinkv2_git/49-stlinkv2.rules /etc/udev/rules.d/
echo "Reloading UDEV rules"
echo "Cleaning up temporary files and folders..."
rm -r temp_stlinkv2_git
echo "Run 'sudo udevadm control --reload-rules' to load the new rules."
