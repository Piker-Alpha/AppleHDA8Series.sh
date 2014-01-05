#!/bin/sh

#
# Script (AppleHDA8Series.sh) to create AppleHDA892.kext (example)
#
# Version 0.3 - Copyright (c) 2013-2014 by Pike R. Alpha
#
# Updates:
#			- Made kext name a bit more flexible (Pike R. Alpha, January 2014)
#
# Contributors:
#
# Usage (version 0.2 - version 0.3):
#
#           - ./AppleHDA8Series.sh [target directory]
#
#           - ./AppleHDA8Series.sh /System/Library/Extensions
#
# Usage (version 0.4 and greater):
#
#           - ./AppleHDA8Series.sh [target directory] [target version]
#
#           - ./AppleHDA8Series.sh /System/Library/Extensions 892
#

gScriptVersion=0.3

#
# Get user id
#
let gID=$(id -u)

gSourceDirectory="/Users/$(whoami)/Desktop"

#
# Get current working directory.
#
gTargetDirectory="$(pwd)"

#
# This is part of the name of the target kext.
#
gKextID="892"

#
# Initialise variable with Info.plist filename.
#
gInfoPlist="${gTargetDirectory}/AppleHDA${gKextID}.kext/Contents/Info.plist"

#
# Default 'CodecID' (will be initialsed by function _initCodecID.
#
# Note: Make sure to replace this with your CodecID!
#
let gCodecID=283904146

#
# Default 'layout-id' (will be initialsed by function _initLayoutID.
#
# Note: This will be replaced with the 'layout-id' from your ioreg!
#
let gLayoutID=892

#
# Default 'ConfigData' to be injected by function _createInfoPlist.
#
# Note: Make sure to replace this with your own data!
#
gConfigData="IUccECFHHUAhRx4RIUcfASFXHCAhVx0QIVceASFXHwEhZxzwIWcdACFnHgAhZx9AIXcc8CF3HQAhdx4AIXcfQCGHHEAhhx2QIYceoSGHH5AhlxxQIZcdkCGXHoEhlx8CIaccYCGnHTAhpx6BIacfASG3HHAhtx1AIbceISG3HwIh5xyQIecdYSHnHksh5x8BIfcc8CH3HQAh9x4AIfcfQCEXHPAhFx0AIRceACEXH0A="

#
# Initialise variable with the Extensions directory.
#
gExtensionsDirectory="/System/Library/Extensions"

#
# Output styling.
#
STYLE_RESET="ESC[[0m"
STYLE_BOLD="^[[1m"
STYLE_UNDERLINED="^[[4m"

#
# This is the target directory structure that we want to create:
#
# AppleHDA892.kext/Contents
# AppleHDA892.kext/Contents/Info.plist
# AppleHDA892.kext/Contents/_CodeSignature
# AppleHDA892.kext/Contents/_CodeSignature/CodeResources
# AppleHDA892.kext/Contents/PlugIns
# AppleHDA892.kext/Contents/PlugIns/AppleHDALoader.kext
# AppleHDA892.kext/Contents/PlugIns/AppleHDALoader.kext/Contents
# AppleHDA892.kext/Contents/PlugIns/AppleHDALoader.kext/Contents/Info.plist
# AppleHDA892.kext/Contents/PlugIns/AppleHDALoader.kext/Contents/MacOS
# AppleHDA892.kext/Contents/PlugIns/AppleHDALoader.kext/Contents/MacOS/AppleHDA
# AppleHDA892.kext/Contents/PlugIns/AppleHDALoader.kext/Contents/Resources
# AppleHDA892.kext/Contents/PlugIns/AppleHDALoader.kext/Contents/Resources/layout3.xml.zlib (example)
# AppleHDA892.kext/Contents/PlugIns/AppleHDALoader.kext/Contents/Resources/Platforms.xml.zlib


#
#--------------------------------------------------------------------------------
#

function _showHeader()
{
  printf "AppleHDA8Series.sh v${gScriptVersion} Copyright (c) 2013-$(date "+%Y") by Pike R. Alpha\n"
  echo '----------------------------------------------------------------'
}


#
#--------------------------------------------------------------------------------
#

function _initLayoutID()
{
  #
  # -r = Show subtrees rooted by objects that match the specified criteria (-p and -k)
  # -w = Clipping (none, unlimited line width)
  # -p = Traverse the registry plane 'IODeviceTree'
  # -n = Show properties if there is an object with the name 'efi'
  # -k = Show properties with the key 'device-properties'

  local layoutID=$(ioreg -r -w 0 -p IODeviceTree -n HDEF -k layout-id | grep layout-id | sed -e 's/["layoutid" ,<>|=-]//g')
  let gLayoutID="0x${layoutID:6:2}${layoutID:4:2}${layoutID:2:2}${layoutID:0:2}"
}


#
#--------------------------------------------------------------------------------
#

function _initCodecID()
{
  echo "Not Yet Implemented\n"
}


#
#--------------------------------------------------------------------------------
#

function _creatInfoPlist()
{
  echo '<?xml version=\"1.0\" encoding=\"UTF-8\"?>'                                                                   > $gInfoPlist
  echo '<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">'  >> $gInfoPlist
  echo '<plist version=\"1.0\">'                                                                                     >> $gInfoPlist
  echo '<dict>'                                                                                                      >> $gInfoPlist
  echo '	<key>BuildMachineOSBuild</key>'                                                                          >> $gInfoPlist
  echo '	<string>13C32</string>'                                                                                  >> $gInfoPlist
  echo '	<key>CFBundleDevelopmentRegion</key>'                                                                    >> $gInfoPlist
  echo '	<string>English</string>'                                                                                >> $gInfoPlist
  echo '	<key>CFBundleGetInfoString</key>'                                                                        >> $gInfoPlist
  echo '	<string>AppleHDA'$gKextID' 1.0.1a10, Copyright © 2003-2014 Pike R. Alpha. All rights reserved.</string>' >> $gInfoPlist
  echo '	<key>CFBundleIdentifier</key>'                                                                           >> $gInfoPlist
  echo '	<string>com.apple.driver.AppleHDA'$gKextID'</string>'                                                    >> $gInfoPlist
  echo '	<key>CFBundleInfoDictionaryVersion</key>'                                                                >> $gInfoPlist
  echo '	<string>6.0</string>'                                                                                    >> $gInfoPlist
  echo '	<key>CFBundleName</key>'                                                                                 >> $gInfoPlist
  echo '	<string>Realtek '$gKextID' Configuation Driver</string>'                                                 >> $gInfoPlist
  echo '	<key>CFBundlePackageType</key>'                                                                          >> $gInfoPlist
  echo '	<string>KEXT</string>'                                                                                   >> $gInfoPlist
  echo '	<key>CFBundleShortVersionString</key>'                                                                   >> $gInfoPlist
  echo '	<string>1.0.1</string>'                                                                                  >> $gInfoPlist
  echo '	<key>CFBundleSignature</key>'                                                                            >> $gInfoPlist
  echo '	<string>????</string>'                                                                                   >> $gInfoPlist
  echo '	<key>CFBundleVersion</key>'                                                                              >> $gInfoPlist
  echo '	<string>1.0.1a10</string>'                                                                               >> $gInfoPlist
  echo '	<key>IOKitPersonalities</key>'                                                                           >> $gInfoPlist
  echo '	<dict>'                                                                                                  >> $gInfoPlist
  echo '		<key>HDA Hardware Config Resource</key>'                                                             >> $gInfoPlist
  echo '		<dict>'                                                                                              >> $gInfoPlist
  echo '			<key>CFBundleIdentifier</key>'                                                                   >> $gInfoPlist
  echo '			<string>com.apple.driver.AppleHDAHardwareConfigDriver</string>'                                  >> $gInfoPlist
  echo '			<key>HDAConfigDefault</key>'                                                                     >> $gInfoPlist
  echo '			<array>'                                                                                         >> $gInfoPlist
  echo '				<dict>'                                                                                      >> $gInfoPlist
  echo '					<key>CodecID</key>'                                                                      >> $gInfoPlist
  echo '					<integer>'$gCodecID'</integer>'                                                          >> $gInfoPlist
  echo '					<key>ConfigData</key>'                                                                   >> $gInfoPlist
  echo '					<data>'$gConfigData'</data>'                                                             >> $gInfoPlist
  echo '					<key>FuncGroup</key>'                                                                    >> $gInfoPlist
  echo '					<integer>1</integer>'                                                                    >> $gInfoPlist
  echo '					<key>LayoutID</key>'                                                                     >> $gInfoPlist
  echo '					<integer>'$gLayoutID'</integer>'                                                         >> $gInfoPlist
  echo '				</dict>'                                                                                     >> $gInfoPlist
  echo '			</array>'                                                                                        >> $gInfoPlist
  echo '			<key>IOClass</key>'                                                                              >> $gInfoPlist
  echo '			<string>AppleHDAHardwareConfigDriver</string>'                                                   >> $gInfoPlist
  echo '			<key>IOMatchCategory</key>'                                                                      >> $gInfoPlist
  echo '			<string>AppleHDAHardwareConfigDriver</string>'                                                   >> $gInfoPlist
  echo '			<key>IOProviderClass</key>'                                                                      >> $gInfoPlist
  echo '			<string>AppleHDAHardwareConfigDriverLoader</string>'                                             >> $gInfoPlist
  echo '		</dict>'                                                                                             >> $gInfoPlist
  echo '	</dict>'                                                                                                 >> $gInfoPlist
  echo '	<key>OSBundleRequired</key>'                                                                             >> $gInfoPlist
  echo '	<string>Root</string>'                                                                                   >> $gInfoPlist
  echo '</dict>'                                                                                                     >> $gInfoPlist
  echo '</plist>'                                                                                                    >> $gInfoPlist
}

#
#--------------------------------------------------------------------------------
#

function main()
{
  _showHeader
  _initLayoutID

  echo "Creating AppleHDA${gKextID}.kext in: $gTargetDirectory\n"

  #
  # Make target directory structure.
  #
  mkdir -m 755 -p "${gTargetDirectory}/AppleHDA${gKextID}.kext/Contents/PlugIns/AppleHDALoader.kext/Contents/Resources"

  #
  # Copy the Platforms file from the source directory.
  #
  cp "${gSourceDirectory}/Platforms.xml.zlib" "${gTargetDirectory}/AppleHDA${$gKextID}.kext/Contents/PlugIns/AppleHDALoader.kext/Contents/Resources/"

  #
  # Copy the layout file from the source directory.
  #
  cp "${gSourceDirectory}/layout${gLayoutID}.xml.zlib" "${gTargetDirectory}/AppleHDA${$gKextID}.kext/Contents/PlugIns/AppleHDALoader.kext/Contents/Resources/"

  #
  # Add MacOS directory for our symbolic link.
  #
  mkdir "${gTargetDirectory}/AppleHDA${$gKextID}.kext/Contents/PlugIns/AppleHDALoader.kext/Contents/MacOS"

  #
  # Create symbolic link to executable.
  #
  ln -fs "${gExtensionsDirectory}/AppleHDA.kext/Contents/MacOS/AppleHDA" "${gTargetDirectory}/AppleHDA${gKextID}.kext/Contents/PlugIns/AppleHDALoader.kext/Contents/MacOS/AppleHDA"

  #
  # Create AppleHDA892.kext/Contents/Info.plist
  #
  _creatInfoPlist

  #
  # Copy AppleHDA.kext/Contents/Info.plist to our AppleHDALoader.kext
  #
  cp "${gExtensionsDirectory}/AppleHDA.kext/Contents/Info.plist" "${gTargetDirectory}/AppleHDA${$gKextID}.kext/Contents/PlugIns/AppleHDALoader.kext/Contents/"

  #
  # Copy CodeResources.
  #
  cp -R "${gExtensionsDirectory}/AppleHDA.kext/Contents/PlugIns/DspFuncLib.kext/Contents/_CodeSignature" "${gTargetDirectory}/AppleHDA${$gKextID}.kext/Contents/"

  gTargetFile="${gTargetDirectory}/AppleHDA${$gKextID}.kext/Contents/PlugIns/AppleHDALoader.kext/Contents/Info.plist"

  #
  # Replace version info with "9.1.1" in AppleHDALoader.kext
  #
  gCFBundleShortVersionString=$(awk '/<key>CFBundleShortVersionString<\/key>.*/,/<\/string>/' "${gTargetFile}" | egrep -o '(<string>.*</string>)' | sed -e 's/<\/*string>//g')
  new=$(sed "s/$gCFBundleShortVersionString/9.1.1/" "$gTargetFile")
  echo "$new" > "$gTargetFile"

  #
  # Fix ownership and permissions.
  #
  chown -R root:wheel "${gExtensionsDirectory}/AppleHDA.kext"
  chmod -R 755 "${gExtensionsDirectory}/AppleHDA.kext"

  #
  # Check target directory.
  #
  if [[ "$gTargetDirectory" == "$gExtensionsDirectory" ]]; then
    #
    # Conditionally touch the Extensions directory.
    #
    sudo touch "$gExtensionsDirectory"
  fi
}

#==================================== START =====================================

clear

#
# Are we running as root without our salt?
#
if [[ $gID -eq 0 && "$2" == "" ]];
  then
    #
    # Yes. Kill sudo timestamp.
    #
    sudo -k
    #
    # Re-run script (and get the User directory).
    #
    "$0" "$1" $(md5 -q "$0")
  else
    #
    # Are we about to create the kext in the Extensions directory (requiring additional privileges)?
    #
    if [[ "$1" == "$gExtensionsDirectory" || "gTargetDirectory" == "$gExtensionsDirectory" ]];
      then
        #
        # Yes. Ask for password and re-run script as root.
        #
        echo "This script ${STYLE_UNDERLINED}must${STYLE_RESET} be run as root!" 1>&2
        sudo "$0" "$@"
      else
        #
        # No. Call main with target directory.
        #
        main "$1"
    fi
fi

#================================================================================

exit 0
