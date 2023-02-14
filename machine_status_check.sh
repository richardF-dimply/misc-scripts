#!/bin/bash

# by richard fortune
# 14th of Feb 2023

# This script will grab all useful information on a macOS system 

# Output will be written to a .txt file on the Desktop of the logged-in user

###### WARNING #####
#IMPORTANT NOTE:  

# variables

currentDate=$(date "+%d%m%Y_%H%M")
#echo "Run on: "+$currentDate

currentFullDate=$(date)
echo "Run on: "+$currentFullDate

loggedInUser=$(scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print $3 }' )
echo "Logged in user: " $loggedInUser

serial=$(system_profiler SPHardwareDataType | awk '/Serial/ {print $4}')
echo "Serial Number: " $serial

computerName=$(scutil --get ComputerName)
echo "Computer Name: "$computerName

osVer=$(sw_vers -productVersion)
echo "OS Version: "$osVer

build=$(sw_vers -buildVersion)
echo "OS Build: "$build

fdeSetupStatus=`/usr/bin/fdesetup status`
echo "FileVault Status: " "$fdeSetupStatus"

fmmToken=$(/usr/sbin/nvram -x -p | /usr/bin/grep "fmm-mobileme-token-FMM")

if [ -z "$fmmToken" ]; then
    /bin/echo "Warning: Find my Mac Disabled!"
else
    /bin/echo "Find My Mac Status: Enabled"
fi

global_state=$(/usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate)
blockall_state=$(/usr/libexec/ApplicationFirewall/socketfilterfw --getblockall)
allowsigned_state=$(/usr/libexec/ApplicationFirewall/socketfilterfw --getallowsigned)
stealth_mode=$(/usr/libexec/ApplicationFirewall/socketfilterfw --getstealthmode)
logging_mode=$(/usr/libexec/ApplicationFirewall/socketfilterfw --getloggingmode)

global_st="Off"
blockall_st="Off"
builtin_app_st="Off"
downloaded_app_st="Off"
stealth_st="Off"
logging_st="Off"

# Determine whether Application Firewall is on
if [[ "$global_state" =~ "enabled" ]]; then
    global_st="On"
fi

# Determine whether "Block all incoming connections" is on
if [[ "$blockall_state" =~ "enabled" ]]; then
    blockall_st="On"
fi

# Determine whether built-in signed applications will
# automatically received incoming connections
if [[ "$allowsigned_state" =~ "built-in.*ENABLED" ]]; then
    builtin_app_st="On"
fi

# Determine whether downloaded signed applications will
# automatically received incoming connections
if [[ "$allowsigned_state" =~ "downloaded.*ENABLED" ]]; then
    downloaded_app_st="On"
fi
# Determine whether Stealth mode is on
if [[ "$stealth_mode" =~ "enabled" ]]; then
    stealth_st="On"
fi

# Determine whether logging mode is on
if [[ "$logging_mode" =~ "on" ]]; then
    logging_st="On"
fi


echo "App Firewall: $global_st
Block All: $blockall_st
Built-In Signed App: $builtin_app_st
Downloaded Signed App: $downloaded_app_st
Stealth Mode: $stealth_st
Logging: $logging_st"