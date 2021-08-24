#!/bin/bash
if [ "$(whoami)" != "root" ] ; then
	echo "Please run as root"
	echo "Quitting ..."
	exit 1
fi

# Check the scipts' folder
SCRIPTS_FOLDER=$1
if [ $# -ne 1 ]; then
	echo "Please type test scripts' folder path"
	echo "Please run as:"
	echo "sudo $0 <test_scripts'_full_path>"
	echo "Quitting ..."
	exit 1
fi
if [ -d "$SCRIPTS_FOLDER" ]; then
	if [ "${SCRIPTS_FOLDER: -1}" != "/" ]; then
		SCRIPTS_FOLDER="$SCRIPTS_FOLDER/"
	fi
	echo "$SCRIPTS_FOLDER folder exists"
	chmod +x csi_*.sh
	chmod +x enable_*.sh
	chmod +x test_digital_*.sh
	chmod +x M.2_Key_B_QualComm.sh
else
	echo "$SCRIPTS_FOLDER folder does not exist"
	echo "Quitting ..."
	exit 1
fi

# Check GtkTerm installed
REQUIRED_PKG="gtkterm"
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG|grep "install ok installed")
echo "Checking for $REQUIRED_PKG: $PKG_OK"
if [ "" = "$PKG_OK" ]; then
	echo ""
	echo "$REQUIRED_PKG not found. Setting it up..."
	sudo apt-get --yes install $REQUIRED_PKG 

	PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG|grep "install ok installed")
	echo ""
	echo "Checking for $REQUIRED_PKG: $PKG_OK"

	if [ "" = "$PKG_OK" ]; then
		echo ""
		echo "$REQUIRED_PKG not installed. Please try again later"
		exit 1
	fi

fi


function test_menu {
	continue_test=true

	while $continue_test; do
		sleep 1
		echo ""
		echo "****************************"
		echo "*** Production Test Menu ***"
		echo "1) Previous Tests"
		echo "2) Disks (M.2 SSD and SD card) Test"
		echo "3) Network Test"
		echo "4) USB Test"
		echo "5) CSI Test"
		echo "6) RS-232 Test"
		echo "7) Digital Out Test"
		echo "8) Digital In-0 Test"
		echo "9) Digital In-1 Test"
		echo "10) RS-422 Test"
		echo "11) RS-485 Write Test"
		echo "12) RS-485 Read Test"
		echo "13) M.2 Key-B Test"
		echo "14) M.2 Key-E Test"
		read -p "Type the test number (or quit) [1/.../q]: " choice
		echo ""

		case $choice in
			1 ) 
				echo "* Check The power button"
				echo "* Set the device in recovery mode, connect recovery USB and check the device in recovery mode with lsusb (0955:7f21)"
				echo "* Reset the device, connect Debug USB and check the serial connection"
				;;
			2 )
				echo "Check M.2 SSD and SD card detected"
				gnome-terminal -- gnome-disks
				;;
			3 )
				echo "(1/2) Ping Test"
				ping -c 5 www.google.com
				echo "(2/2) Network Speed Test"
				ip -br address | grep UP
				# Add parsing command instead of getting network name from user
				read -p "Enter the network name: " net_name
				echo "Check the ethernet connection ($net_name) speed as 1000 Mb/s"
				sudo ethtool $net_name | grep Speed
				;;
			4 )
				echo "Check both USB devices connected to 'Linux Foundation 3.0 root hub'"
				gnome-terminal -- watch -n 1 lsusb
				;;
			5 )
				gnome-terminal -- $SCRIPTS_FOLDER/csi_1_test.sh
				sleep 2
				gnome-terminal -- $SCRIPTS_FOLDER/csi_2_test.sh
				;;
			6 )
				$SCRIPTS_FOLDER/enable_rs232_nano.sh
				sudo gnome-terminal -- gtkterm -p /dev/ttyTHS1 -s 115200
				;;
			7 )
				$SCRIPTS_FOLDER/enable_digital_out_nano.sh
				gnome-terminal -- $SCRIPTS_FOLDER/test_digital_out_multi_nano.sh
				;;
			8 )
				$SCRIPTS_FOLDER/enable_digital_in_nano.sh
				gnome-terminal -- $SCRIPTS_FOLDER/test_digital_in0_nano.sh
				;;
			9 )
				$SCRIPTS_FOLDER/enable_digital_in_nano.sh
				gnome-terminal -- $SCRIPTS_FOLDER/test_digital_in1_nano.sh
				;;
			10 )
				$SCRIPTS_FOLDER/enable_rs422_nano.sh
				sudo gnome-terminal -- gtkterm -p /dev/ttyTHS1 -s 115200
				;;
			11 )
				$SCRIPTS_FOLDER/enable_rs485_nano.sh
				$SCRIPTS_FOLDER/enable_rs485_write_nano.sh
				sudo gnome-terminal -- gtkterm -p /dev/ttyTHS1 -s 115200 -w RS485
				;;
			12 )
				$SCRIPTS_FOLDER/enable_rs485_nano.sh
				$SCRIPTS_FOLDER/enable_rs485_read_nano.sh
				sudo gnome-terminal -- gtkterm -p /dev/ttyTHS1 -s 115200 -w RS485
				;;
			13 )
				$SCRIPTS_FOLDER/M.2_Key_B_QualComm.sh
				sudo gnome-terminal -- watch -n 1 lsusb
				;;
			14 )
				sudo gnome-terminal -- watch -n 1 lspci
				sudo gnome-terminal -- watch -n 1 lsusb
				;;
			[Qq]* )
				echo "Quitting ..."
				exit 1
				;;
			* )
				echo "Wrong choice"
				;;
		esac
	done
}


test_menu
