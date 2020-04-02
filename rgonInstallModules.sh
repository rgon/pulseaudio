#!/bin/bash

echo "Please run this script as sudo if executed with the 'install' or 'build' param"

fn_run () {
	pulseaudio --start
#	sleep .5
#	echo "Step 1"
	# pacmd describe-module module-bluetooth-policy
	pacmd unload-module module-bluetooth-policy &
	pacmd unload-module module-jack-sink &
	pacmd unload-module module-jack-source &
	pacmd unload-module module-loopback &

#	echo "Step 2"
	pacmd load-module module-jack-sink sink_name="jack_OSAppRecord"
	pacmd load-module module-jack-sink sink_name="jack_BTDevRecord" client_name="BTPlayback"
	pacmd load-module module-jack-source source_name="jack_OSAppCapture"
	pacmd load-module module-jack-source source_name="jack_BTDevCapture" client_name="BTRecord"

#	sleep 1
#	echo "Step 3"
	pacmd update-sink-proplist "jack_BTDevRecord" device.description="jack_BTDevRecord"
	pacmd update-source-proplist "jack_BTDevCapture" device.description="jack_BTDevCapture"

#	sleep .5
#	echo "Step 4"
	pacmd set-source-volume "jack_BTDevCapture" 0x10000
	pacmd set-sink-volume "jack_BTDevRecord" 0x10000

#	echo "Step 5"
	SINKID="$(pacmd list-sink-inputs | grep index | cut -d : -f2 | tr -d " ")"
	if [ "$SINKID" != "" ]; then
		pacmd set-sink-input-volume "$SINKID" 0x10000
	fi

#	echo "Step 5"
	pacmd list-sources | grep jack
	pacmd list-sinks | grep jack

#	echo "Step 6"
	pacmd load-module module-bluetooth-policy custom_loopback_sink="jack_BTDevRecord" custom_loopback_source="jack_BTDevCapture"

# pacmd load-module module-loopback source="bluez_source.04_D1_3A_6C_F0_E9.a2dp_source" sink=jack_BTDevRecord
}

fn_stop () {
	pulseaudio -k
}
fn_build () {
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
	fn_stop

	fn_build
elif [ "$1" == "build" ]; then
	fn_stop

	fn_build
elif [ "$1" == "stop" ]; then
	fn_stop
else # run
	fn_stop

	fn_run
fi

# sudo mv /usr/lib/pulse-13.0/modules/module-bluetooth-policy.so /usr/lib/pulse-13.0/modules/module-bluetooth-policy.so.bak
