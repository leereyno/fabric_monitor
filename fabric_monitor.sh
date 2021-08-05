#!/bin/bash

# Lee Reynolds <Lee.Reynolds@asu.edu>
# ASU Research Computing

set -u # Define variables before use

source $(dirname $0)/credentials.source

# These come from credentials.source
#MyUSER=
#MyPASS=
#MyHOST=
MyDB="fabric_monitor"          # Database to use
MYSQL="$(which mysql)"          # Path to mysql
                                                                                
MyConn="$MYSQL -u $MyUSER -h $MyHOST -p$MyPASS -D $MyDB -Be" 

DEBUGGER=false

############################
# Get host information
############################

NOW=$(date +%s)

UUID=$(cat /sys/class/dmi/id/product_uuid)
FULLHOSTNAME=$(hostname)

# This will generate results on ubuntu and centos 7.x and above
# Centos 6.x will show up as unknown
if [ -e /etc/os-release ] ; then
	OSFLAVOR="$(grep '^ID=' /etc/os-release | awk -F'=' '{ print $2 }' | sed -e 's/"//g')"
	OSVERSION="$(grep '^VERSION_ID' /etc/os-release | awk -F'=' '{ print $2 }' | sed -e 's/"//g')"
else
	OSFLAVOR="unknown"
	OSVERSION="unknown"
fi

# If we're running centos then get the exact version number
if [ -e /etc/centos-release ] ; then

	if [ $OSFLAVOR = "unknown" ] ; then
		OSFLAVOR="centos"
	fi

	CENTOSVERSION=$(grep -o [[:digit:]]\.[[:digit:]]*\.[[:digit:]]* /etc/centos-release)

	if [ "$OSVERSION" = "unknown" ] ; then
		OSVERSION="$CENTOSVERSION"
	fi

else
	CENTOSVERSION="0"
fi

KERNEL="$(uname -r)"
VENDOR="$(cat /sys/devices/virtual/dmi/id/sys_vendor)"
MODEL="$(cat /sys/devices/virtual/dmi/id/product_name)"
SERIAL="$(cat /sys/devices/virtual/dmi/id/product_serial)"
BIOSDATE="$(cat /sys/devices/virtual/dmi/id/bios_date)"
BIOSVEND="$(cat /sys/devices/virtual/dmi/id/bios_vendor)"
BIOSVER="$(cat /sys/devices/virtual/dmi/id/bios_version)"

# If there is no infiniband directory, then this system has neither IB nor OPA
if [ ! -d /sys/class/infiniband ] ; then
	INFINIBAND="0"
	OMNIPATH="0"
else
	# There is an infiniband directory, so we need to do extra work

	# hfi1_0 cards are always omnipath
	if [ -e /sys/class/infiniband/hfi1_0 ] ; then
		OMNIPATH="1"
        OPAVERSION="$(opaconfig -V)"
	else
		OMNIPATH="0"
        OPAVERSION="0"
	fi

	# Assume we do not have infiniband
	INFINIBAND="0"

    # Search through all of the non omnipath ports and see if any are
    # Infiniband ports
	for module in $(/bin/ls -1 /sys/class/infiniband/ | grep -v hfi1 ) ; do
        for port in $(/bin/ls -1 /sys/class/infiniband/$module/ports/ ) ; do
            if [ -e /sys/class/infiniband/$module/ports/$port/link_layer ] ; then
                if [ "$(cat /sys/class/infiniband/$module/ports/$port/link_layer)" = "InfiniBand" ] ; then
                    INFINIBAND="1"
                fi
            fi
        done
	done
fi

if [ $DEBUGGER = true ] ; then
	echo $UUID
	echo $FULLHOSTNAME
	echo $OSFLAVOR
	echo $OSVERSION
	echo $CENTOSVERSION
	echo $KERNEL
	echo $VENDOR
	echo $MODEL
	echo $SERIAL
	echo $BIOSDATE
	echo $BIOSVEND
	echo $BIOSVER
	echo $INFINIBAND
	echo $OMNIPATH
    echo $OPAVERSION
	echo $NOW
fi

HOSTQUERY="replace into hosts values
	(\"$UUID\",
	\"$FULLHOSTNAME\",
	\"$OSFLAVOR\",
	\"$OSVERSION\",
	\"$CENTOSVERSION\",
	\"$KERNEL\",
	\"$VENDOR\",
	\"$MODEL\",
	\"$SERIAL\",
	\"$BIOSDATE\",
	\"$BIOSVEND\",
	\"$BIOSVER\",
	\"$INFINIBAND\",
	\"$OMNIPATH\",
    \"$OPAVERSION\",
	\"$NOW\")"

if [ $DEBUGGER = true ] ; then
	echo $HOSTQUERY
	$MyConn "$HOSTQUERY" 
else
	$MyConn "$HOSTQUERY" &> /dev/null
fi

###################################
# Get device and port information
###################################

# No possible IB ports?  We're done
if [ ! -d /sys/class/infiniband ] ; then
	exit 0
fi

cd /sys/class/infiniband

DEVICEROOT=$(pwd)

for DEVICE in $(/bin/ls -1) ; do

	cd $DEVICE

	BOARD_ID=$(cat board_id)

	if [ -e fw_ver ] ; then
		FW_VER="$(cat fw_ver)"
	else
		FW_VER="0"
	fi

	if [ -e hca_type ] ; then
		HCA_TYPE="$(cat hca_type)"
	else
		HCA_TYPE="0"
	fi

	DEVICEQUERY="replace into devices values
	(\"$UUID\",
	\"$DEVICE\",
	\"$BOARD_ID\",
	\"$FW_VER\",
	\"$HCA_TYPE\",
	\"$NOW\")"

	if [ $DEBUGGER = true ] ; then
		echo $DEVICEQUERY
		$MyConn "$DEVICEQUERY" 
	else
		$MyConn "$DEVICEQUERY" &> /dev/null
	fi

	########################
	## Get port Information
	########################

	cd ports

	PORTROOT=$(pwd)

	for PORT in $(/bin/ls -1) ; do

		cd $PORT

		LID="$(cat lid)"

		if [ "$DEVICE" = "hfi1_0" ] ; then
			LINK_LAYER="OmniPath"
		else
			LINK_LAYER="$(cat link_layer)"
		fi

		PHYS_STATE="$(cat phys_state)"
		RATE="$(cat rate)"
		SM_LID="$(cat sm_lid)"
		STATE="$(cat state)"
		
		
		PORTQUERY="replace into ports values
		(\"$UUID\",
		\"$DEVICE\",
		\"$PORT\",
		\"$LID\",
		\"$LINK_LAYER\",
		\"$PHYS_STATE\",
		\"$RATE\",
		\"$SM_LID\",
		\"$STATE\",
		\"$NOW\")"

		if [ $DEBUGGER = true ] ; then
			echo $PORTQUERY
			$MyConn "$PORTQUERY" 
		else
			$MyConn "$PORTQUERY" &> /dev/null
		fi

		cd $PORTROOT

	done

	cd $DEVICEROOT
	
done

