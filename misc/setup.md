# Setup rpi for spikey
## On the rpi
make user spikey:spikey
activate ssh
set wlan location
add wlan
## Add ssh key
ssh-copy-id spikey@192.168.55.135
ssh spikey@192.168.55.135
## Installing flutter pi on the rpi
sudo apt-get update \
sudo apt-get upgrade \
sudo apt install git cmake libgl1-mesa-dev  libgles2-mesa-dev libegl1-mesa-dev libdrm-dev libgbm-dev ttf-mscorefonts-installer fontconfig libsystemd-dev libinput-dev libudev-dev  libxkbcommon-dev \
sudo fc-cache \
git clone --recursive https://github.com/ardera/flutter-pi \
cd flutter-pi \
mkdir build && cd build \
cmake .. \
make -j`nproc`  \
sudo make install \

git clone --depth 1 https://github.com/ardera/flutter-engine-binaries-for-arm.git engine-binaries \
cd engine-binaries \
sudo ./install.sh \
Crtl-D 

## build and copy app
flutter build linux --release --target-platform=linux-arm64 \
scp -r ./build/flutter_assets/ spikey@192.168.55.135:/home/spikey/app

## running the app
sudo /usr/local/bin/flutter-pi ~/app

## copy the config
scp -r ./configs/test.json spikey@192.168.55.135:/home/spikey/configs/


## Enable PWM
sudo nano /boot/firmware/config.txt \
dtoverlay=pwm-2chan \
pwm pins are 18 and 19
