#!/bin/bash

echo "Please run this script as sudo if executed with the 'install' or 'build' param"

fn_run () {
	pacmd unload-module module-bluetooth-policy
	pacmd unload-module module-jack-sink
	pacmd unload-module module-jack-source
	pacmd unload-module module-loopback

	pacmd load-module module-jack-sink sink_name="jack_OSAppRecord"
	pacmd load-module module-jack-sink sink_name="jack_BTDevRecord"
	pacmd load-module module-jack-source source_name="jack_OSAppCapture"
	pacmd load-module module-jack-source source_name="jack_BTDevCapture"

	pacmd list-sources | grep jack
	pacmd list-sinks | grep jack

	pacmd load-module module-bluetooth-policy custom_loopback_sink="jack_BTDevRecord" custom_loopback_source="jack_BTDevCapture"
}

fn_build () {
	pulseaudio -k
	sudo apt remove pulseaudio pulseaudio-utils
	make clean
	./bootstrap.sh
	make -j 5
	sudo make install
}

if [ "$1" == "install" ]; then
	git clone https://github.com/rgon/pulseaudio
	cd pulseaudio
	# software-properties-gtk # enable "Source Code"
	sudo apt -y build-dep pulseaudio

	fn_build
elif [ "$1" == "build" ]; then
	fn_build
else # run
	pacmd describe-module module-bluetooth-policy
	fn_run
fi

# sudo mv /usr/lib/pulse-13.0/modules/module-bluetooth-policy.so /usr/lib/pulse-13.0/modules/module-bluetooth-policy.so.bak
