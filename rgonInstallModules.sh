git clone github.com/rgon/pulseaudio
cd pulseaudio
# software-properties-gtk # enable "Source Code"
sudo apt -y build-dep pulseaudio
./bootstrap.sh
make -j 5
sudo cp src/.libs/module-bluetooth-policy.so /usr/lib/pulse-13.0/modules/module-bluetooth-policy-rgon.so

pulseaudio --dump-modules | grep policy
pactl unload-module module-bluetooth-policy
pactl load-module module-bluetooth-policy-rgon

sudo mv /usr/lib/pulse-13.0/modules/module-bluetooth-policy.so /usr/lib/pulse-13.0/modules/module-bluetooth-policy.so.bak

sudo apt remove pulseaudio-module-bluetooth

sudo apt remove pulseaudio pulseaudio-utils

pacmd describe-module module-bluetooth-policy
pacmd load-module module-jack-sink
pacmd load-module module-bluetooth-policy

make clean
./bootstrap.sh
make -j 5
sudo make install
