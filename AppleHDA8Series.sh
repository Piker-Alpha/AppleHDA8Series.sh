#!/bin/sh

#
# Script (AppleHDA8Series.sh) to create AppleHDA892.kext (example)
#
# Version 1.1 - Copyright (c) 2013-2014 by Pike R. Alpha
#
# Updates:
#			- Made kext name a bit more flexible (Pike R. Alpha, January 2014)
#			- Ask for confirmation and replace target kext when permitted (Pike R. Alpha, January 2014)
#			- Ask if the default or active layout-id should be used (Pike R. Alpha, January 2014)
#			- Changed 'gKextID' to 'gKextName' to let us select a target name (Pike R. Alpha, January 2014)
#			- Format of extracted ConfigData fixed (Pike R. Alpha, January 2014)
#
# TODO:
#			- Add a target argument for 'layout-id'.
#			- Match the version of OS X with Info-NN.plist
#			- Add a way to restore the untouched/vanilla AppleHDA.kext
#
# Contributors:
#			- Thanks to 'Toleda' for providing a great Github repository.
#			- Thanks to 'philip_petev' for his tip to use PlistBuddy.
#
# Usage (version 0.2 - version 0.5):
#
#           - ./AppleHDA8Series.sh [target directory]
#
#           - ./AppleHDA8Series.sh /System/Library/Extensions
#
# Usage (version 1.0 and greater):
#
#           - ./AppleHDA8Series.sh [target directory] [layout-id]
#
#           or:
#
#           - ./AppleHDA8Series.sh  [layout-id] [target directory]
#
# Examples:
#           - ./AppleHDA8Series.sh
#           - ./AppleHDA8Series.sh 892 /System/Library/Extensions
#           - ./AppleHDA8Series.sh /System/Library/Extensions 892
#

gScriptVersion=1.1

#
# Setting the debug mode (default off).
#
let DEBUG=1

#
# Get user id
#
let gID=$(id -u)

#
# Change this so that it points to the directory with the .zlib files.
#
gSourceDirectory="/Users/$(whoami)/Desktop"

#
# Get the current working directory.
#
gTargetDirectory="$(pwd)"

#
# This is the name of the target kext, but without the extension (.kext)
#
# Note: Will be changed in function _initLayoutID to match the target codec.
#
gKextName="AppleHDA892"

#
# Note: Will be changed in function _initLayoutID to match the target codec.
#
gKextID=892

#
# Initialise variable with Info.plist filename.
#
gInfoPlist="${gTargetDirectory}/${gKextName}.kext/Contents/Info.plist"

#
# This is the default 'CodecID'.
#
# Note: Will be changed in function _initLayoutID to match the target codec.
#
let gCodecID=283904146

#
# This is the default 'layout-id'
#
# Note: Will be changed in function _initLayoutID to match the target codec.
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
# List with supported Realtek codecs.
#
gSupportedCodecs=(
283904133,0x10EC0885,885
283904135,0x10EC0887,887
283904136,0x10EC0888,888
283904137,0x10EC0898,889
283904146,0x10EC0892,892
283904152,0x10EC0898,898
283906384,0x10EC1150,1150
)

#
# The default download link to Toleda's Githib repository.
#
gDownloadLink="https://raw.github.com/toleda/audio_ALC892/master/892.zip"

#
# Output styling.
#
STYLE_RESET="[0m"
STYLE_BOLD="[1m"
STYLE_UNDERLINED="[4m"

#
# This is the target directory structure that we want to create (example):
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
# AppleHDA892.kext/Contents/PlugIns/AppleHDALoader.kext/Contents/Resources/layout3.xml.zlib
# AppleHDA892.kext/Contents/PlugIns/AppleHDALoader.kext/Contents/Resources/Platforms.xml.zlib


#
#--------------------------------------------------------------------------------
#

function _showHeader()
{
  printf "AppleHDA8Series.sh v${gScriptVersion} Copyright (c) 2013-$(date "+%Y") by Pike R. Alpha\n"
  printf "                    patched XML files by Toleda and contributors\n"
  echo '----------------------------------------------------------------'
}


#
#--------------------------------------------------------------------------------
#

function _DEBUG_DUMP
{
  if [[ $DEBUG -eq 1 ]];
    then
      echo "$1"
    else
      echo "$1" > /dev/null
  fi
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
  let layoutID="0x${layoutID:6:2}${layoutID:4:2}${layoutID:2:2}${layoutID:0:2}"

  #
  # is this a different layout-id than the default one?
  #
  if [[ layoutID -ne gLayoutID ]]; then
    #
    # Yes. Ask if we should use this layout-id.
    #
    question="Do you want to use [${layoutID}] as the layout-id (y/n)? "

    read -p "$question" choice
    case "$choice" in
      y|Y )
          echo "Now using layout-id: ${layoutID}"
          let gLayoutID=$layoutID
          ;;
    esac
  fi
}


#
#--------------------------------------------------------------------------------
#

function _initCodecID()
{
  echo "The supported Realtek ALC codecs for AppleHDA8Series.sh are:\n"
  #
  # Are we called with a target ALC?
  #
  if [[ $# -eq 1 ]]; then
    #
    # Yes. Set our trigger (makes us check for a target ALC later on).
    #
    let selection=-1
  fi
  #
  # Required for 'retrying...'.
  #
  let index=0
  #
  # Save default (0) delimiter.
  #
  local ifs=$IFS

  for codecData in ${gSupportedCodecs[@]}
  do
    #
    # Change delimiter to a comma character.
    #
    IFS=","
    #
    # And next...
    #
    let index++
    #
    # Splitting data.
    #
    local data=($codecData)
    #
    # Print codec name/info.
    #
    printf "    [${index}] Realtek ALC %4d " ${data[2]}
    printf "(${data[1]} / ${data[0]})\n"
    #
    # Are we called with a target ALC?
    #
    if [[ $selection -eq -1 ]];
      then
        #
        # Yes. Is this our target ALC?
        #
        if [[ $1 == ${data[2]} ]];
          then
            #
            # Yes. Auto-select the one from the list.
            #
            let selection=$index
      fi
    fi
  done
  #
  # Restore the default delimiter.
  #
  IFS=$ifs
  #
  # This extra newline looks a bit nicer.
  #
  printf "\n"

  if [[ $# -eq 1 ]];
    then
      #
      # Show the text with the matching ALC selected.
      #
      echo "Please choose the desired codec for the hardware: $selection"
    else
      #
      # Let the user make a selection.
      #
      read -p "Please choose the desired codec for the hardware: " selection
  fi

  case "$selection" in
    [1-7]) #
           # Change delimiter to a comma character.
           #
           IFS=","
           #
           # Get target codec data.
           #
           local codecData=${gSupportedCodecs[ ($selection - 1) ]}
           #
           # Split the codec data.
           #
           local data=($codecData)
           #
           # Restore the default delimiter.
           #
           IFS=$ifs
           #
           # Updating global variables.
           #
           gKextName="AppleHDA${data[2]}"
           gCodecID=${data[0]}
           gKextID=${data[2]}
           gDownloadLink="https://raw.github.com/toleda/audio_ALC${data[2]}/master/${data[2]}.zip"
           ;;

        *) echo "Invalid selection, retrying ..."
           sleep 1
           clear
           #
           # And try again.
           #
           _initCodecID $1
           ;;
  esac
}


#
#--------------------------------------------------------------------------------
#

function _initConfigData
{
  #
  # Local function definition
  #
  function __searchForConfigData()
  {
	let stat=0
    let index=0
    local sourceFile=$1

    while [ $index -lt 20 ];
    do
      local commandString="Print :IOKitPersonalities:HDA\ Hardware\ Config\ Resource:HDAConfigDefault:${index}:"
      local codecID=$(/usr/libexec/PlistBuddy -c "${commandString}CodecID" $sourceFile)
      let index++

      if [[ $codecID =~ "Does Not Exist" ]];
        then
          _DEBUG_DUMP "Error: '$commandString' Not Found!"
          return 0
        else
          if [[ $codecID -eq $gCodecID ]]; then
            _DEBUG_DUMP "Target CodecID found ..."
            local layoutID=$(/usr/libexec/PlistBuddy -c "${commandString}LayoutID" $sourceFile)

            if [[ $layoutID -eq $gLayoutID ]]; then
              _DEBUG_DUMP "Target LayoutID found ...\nGetting ConfigData ..."

              extractedConfigData=$(/usr/libexec/PlistBuddy -c "${commandString}ConfigData" $sourceFile)
              return 1
            fi
          fi
      fi
    done

    return 0
  }
  #
  # The most common spot to look for ConfigData is of course in AppleHDAHardwareConfigDriver.kext
  #
  echo 'Looking in /System/Library/Extensions/AppleHDA.kext for the ConfigData'
  __searchForConfigData "/System/Library/Extensions/AppleHDA.kext/Contents/PlugIns/AppleHDAHardwareConfigDriver.kext/Contents/Info.plist"

  if (($? == 0));
    then
      #
      # But when that fails, then we look for the data in FakeSMC.kext
      #
      echo 'Looking in /System/Library/Extensions/FakeSMC.kext for the ConfigData'
      __searchForConfigData "/System/Library/Extensions/FakeSMC.kext/Contents/Info.plist"
      #
      # Check status for success.
      #
      if (($? == 0));
        then
          #
          # Oops. Failure. Download the files from Toleda's Github repository :-)
          #
          echo "Error: ConfigData not found\nDownloading ${gDownloadLink} ..."
          sudo curl -o "/tmp/ALC${gKextID}.zip" $gDownloadLink
          #
          # Unzip the downloaded file.
          #
          echo 'Done\nUnzipping /tmp/ALC${gKextID}.zip ...'
          unzip -u "/tmp/ALC${gKextID}.zip" -d "/tmp/"
          echo 'Download done'
          #
          # We should now have the Info.plist so let's do another search for the ConfigData.
          #
          # TODO: We should match the plist with the installed/target version of OS X.
          #
          echo "Looking in /tmp/${gKextID}/Info-91.plist for the ConfigData"
          __searchForConfigData "/tmp/${gKextID}/Info-91.plist"

          if (($? == 1));
            then
              let stat=1
              gSourceDirectory="/tmp/${gKextID}"
          fi
        else
          let stat=1
          gSourceDirectory="/System/Library/Extensions/AppleHDA.kext/Contents/Resources"
      fi
    else
      let stat=1
      gSourceDirectory="/System/Library/Extensions/AppleHDA.kext/Contents/Resources"
  fi
  #
  # Inform user about the progress.
  #
  if [[ $stat -eq 1 ]];
    then
      _DEBUG_DUMP "ConfigData for Realtek ALC ${gKextID} found!"
      #
      # \c stops it from adding a trailing new line character (-n is not available in sh).
      #
      echo '------------------------------------------------------------'
      gConfigData=$(echo "$extractedConfigData\c" | base64)
      echo $gConfigData
      echo '------------------------------------------------------------'

    else
      _DEBUG_DUMP "Error: ConfigData for ALC ${gKextID} NOT found!"
  fi
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
  #
  # Are we fired up with arguments?
  #
  if [ $# -ge 0 ]; then
    #
    # Yes. Is the first argument a numeric value?
    #
    if [[ "$1" =~ ^[0-9]+$ ]];
      then
        #
        # Yes. Make this our target ALC.
        #
        local targetALC=$1
      else
        #
        # No. Is the second argument a numeric value?
        #
        if [[ "$2" =~ ^[0-9]+$ ]]; then
          #
          # Yes. Make this our target ALC.
          #
          local targetALC=$2
        fi
    fi

    _DEBUG_DUMP "AppleHDA8Series.sh was launced with a target ALC${targetALC}\n"
  fi

  _initCodecID $targetALC
  _initLayoutID

  #
  # Is this the first run?
  #
  if [[ -e "${gTargetDirectory}/${gKextName}.kext" ]]; then
    #
    # Yes. Ask if  we should use this layout-id.
    #
    question="${gKextName}.kext already exists. Do you want to overwrite it (y/n)? "

    read -p "$question" choice
    case "$choice" in
      y|Y)
        echo "Removing directory ..."
        rm -r "${gTargetDirectory}/${gKextName}.kext"
        ;;
     esac
  fi

  echo "Creating ${gKextName}.kext in: $gTargetDirectory"

  _initConfigData

  #
  # Make target directory structure.
  #
  mkdir -m 755 -p "${gTargetDirectory}/${gKextName}.kext/Contents/PlugIns/AppleHDALoader.kext/Contents/Resources"

  #
  # Copy the Platforms file from the source directory.
  #
  if [[ -e "${gSourceDirectory}/layout${gLayoutID}.xml.zlib" ]];
    then
      cp "${gSourceDirectory}/Platforms.xml.zlib" "${gTargetDirectory}/${gKextName}.kext/Contents/PlugIns/AppleHDALoader.kext/Contents/Resources/"
    else
      cp "${gSourceDirectory}/Platforms.xml" "${gTargetDirectory}/${gKextName}.kext/Contents/PlugIns/AppleHDALoader.kext/Contents/Resources/"
  fi
  #
  # Copy the layout file from the source directory.
  #
  if [[ -e "${gSourceDirectory}/layout${gLayoutID}.xml.zlib" ]];
    then
       cp "${gSourceDirectory}/layout${gLayoutID}.xml.zlib" "${gTargetDirectory}/${gKextName}.kext/Contents/PlugIns/AppleHDALoader.kext/Contents/Resources/"
     else
       cp "${gSourceDirectory}/layout${gLayoutID}.xml" "${gTargetDirectory}/${gKextName}.kext/Contents/PlugIns/AppleHDALoader.kext/Contents/Resources/"
  fi
  #
  # Add MacOS directory for our symbolic link.
  #
  mkdir "${gTargetDirectory}/${gKextName}.kext/Contents/PlugIns/AppleHDALoader.kext/Contents/MacOS"

  #
  # Create symbolic link to executable.
  #
  ln -fs "${gExtensionsDirectory}/AppleHDA.kext/Contents/MacOS/AppleHDA" "${gTargetDirectory}/${gKextName}.kext/Contents/PlugIns/AppleHDALoader.kext/Contents/MacOS/AppleHDA"

  #
  # Create AppleHDA892.kext/Contents/Info.plist
  #
  _creatInfoPlist

  #
  # Copy AppleHDA.kext/Contents/Info.plist to our AppleHDALoader.kext
  #
  cp "${gExtensionsDirectory}/AppleHDA.kext/Contents/Info.plist" "${gTargetDirectory}/${gKextName}.kext/Contents/PlugIns/AppleHDALoader.kext/Contents/"

  #
  # Copy CodeResources.
  #
  cp -R "${gExtensionsDirectory}/AppleHDA.kext/Contents/PlugIns/DspFuncLib.kext/Contents/_CodeSignature" "${gTargetDirectory}/${gKextName}.kext/Contents/"

  #
  # Replace version info with "9.1.1" in AppleHDALoader.kext
  #
  gTargetFile="${gTargetDirectory}/${gKextName}.kext/Contents/PlugIns/AppleHDALoader.kext/Contents/Info.plist"

  /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString string 9.1.1" "$gTargetFile"
  /usr/libexec/PlistBuddy -c "Set :CFBundleVersion string 9.1.1a10" "$gTargetFile"
  #
  # Fix ownership and permissions.
  #
  echo 'Fixing file permissions ...'
  chmod -R 755 "${gTargetDirectory}/${gKextName}.kext"
  #
  # Ownership of a file may only be altered by a super-user hence the use of sudo here.
  #
  echo 'Fixing file ownership ...'
  sudo chown -R root:wheel "${gTargetDirectory}/${gKextName}.kext"

  #
  # Check target directory.
  #
  if [[ "$gTargetDirectory" == "$gExtensionsDirectory" ]]; then
    #
    # Conditionally touch the Extensions directory.
    #
    echo 'Triggering a kernelcache refresh ...'
    sudo touch "$gExtensionsDirectory"
  fi

  echo 'Done.\n'
}

#==================================== START =====================================

clear

if [[ $gID -ne 0 ]];
  then
    echo "This script ${STYLE_UNDERLINED}must${STYLE_RESET} be run as root!" 1>&2
    #
    # Re-run script with arguments.
    #
    sudo "$0" "$@"
  else
    #
    # We are root. Call main with arguments.
    #
    main "$@"
fi

#================================================================================

exit 0
