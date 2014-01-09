#!/bin/sh

#
# Script (AppleHDA8Series.sh) to create AppleHDA892.kext (example)
#
# Version 1.4 - Copyright (c) 2013-2014 by Pike R. Alpha
#
# Updates:
#			- Made kext name a bit more flexible (Pike R. Alpha, January 2014)
#			- Ask for confirmation and replace target kext when permitted (Pike R. Alpha, January 2014)
#			- Ask if the default or active layout-id should be used (Pike R. Alpha, January 2014)
#			- Changed 'gKextID' to 'gKextName' to let us select a target name (Pike R. Alpha, January 2014)
#			- Format of extracted ConfigData fixed (Pike R. Alpha, January 2014)
#			- Now also asks if the kext should be copied to /S*/L*/Extensions (Pike R. Alpha, January 2014)
#			- Now also asks if you want to reboot (Pike R. Alpha, January 2014)
#			- Run kextutil to check the target kext (Pike R. Alpha, January 2014)
#			- Show available Info-NN.plist after the download/unzipping (Pike R. Alpha, January 2014)
#			- Read/matches the version of OS X with Info-NN.plist (Pike R. Alpha, January 2014)
#			- Errors in gSupportedCodecs fixed, thanks to Toleda (Pike R. Alpha, January 2014)
#			- gSupportedCodecs expanded with layout-id's (Pike R. Alpha, January 2014)
#			- Function _initLayoutID improved (Pike R. Alpha, January 2014)
#			- Function _selectLayoutID added (Pike R. Alpha, January 2014)
#
# TODO:
#			- Add a target argument for 'layout-id'.
#			- Add support for more flexible arguments like:
#             -l = target layout-id
#             -d = target directory
#             -a = target Realtek ALCnnn
#
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

gScriptVersion=1.4

#
# Setting the debug mode (default off).
#
let DEBUG=0

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
283904133,0x10EC0885,885,1
283904135,0x10EC0887,887,1.2.3
283904136,0x10EC0888,888,1.2.3
283904137,0x10EC0889,889,1.2.3
283904146,0x10EC0892,892,1.2.3
283904152,0x10EC0898,898,1.2.3
283904256,0x10EC0900,1150,1.2
)

#
# The default download link to Toleda's Githib repository.
#
gDownloadLink="https://raw.github.com/toleda/audio_ALC892/master/892.zip"

#
# The version info of the running system i.e. '10.9.2'
#
gProductVersion="$(sw_vers -productVersion)"

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
  fi
}



#
#--------------------------------------------------------------------------------
#

function _selectLayoutID()
{
  let index=0
  echo "\nThe available layout-id's for the ALC ${gKextID} are:\n"

  for layout in ${gSupportedLayoutIDs[@]}
  do
    let index++
    echo "[${index}] layout-id: ${layout}"
  done

  echo ''

  read -p "Please choose the desired layout-id (1/${index})? " selection
  case "$selection" in
    [1-${index}])
      echo "\nNow using layout-id: ${selection}"
      let gLayoutID=$selection
      ;;

    *) echo 'Error: Invalid selection!'
      _initLayoutID $1
      ;;
  esac
}


#
#--------------------------------------------------------------------------------
#

function _initLayoutID()
{
  #
  # Are we being called with a target 'layout-id'?
  #
  if [[ $# -eq 1 ]];
    then
      #
      # Yes. Use that (assuming that it is correct/supported).
      #
      let gLayoutID=$1
      echo "Notice: layout-id override detected, now using: ${gLayoutID}"
    else
      #
      # We're not being called with a layout-id, get it from the running configuration.
      #
      # -r = Show subtrees rooted by objects that match the specified criteria (-p and -k)
      # -w = Clipping (none, unlimited line width)
      # -p = Traverse the registry plane 'IODeviceTree'
      # -n = Show properties if there is an object with the name 'HDEF'
      #
      local ioregHDEFData=$(ioreg -rw 0 -p IODeviceTree -n HDEF)
      #
      # Check for Device (HDEF) in the ioregHDEFData.
      #
      if [[ $(echo $ioregHDEFData | grep -o "HDEF@1B") == "HDEF@1B" ]];
        then
          _DEBUG_DUMP "ACPI Device (HDEF) {} found"
          #
          # Get layout-id from ioreg data.
          local layoutID=$(echo $ioregHDEFData | grep layout-id | sed -e 's/.*<//' -e 's/>//')
          #
          # Check value of layout-id (might still be empty).
          #
          if [[ $layoutID == "" ]];
            then
              #
              # Show list with supported layout-id's and let user select one.
              #
              _selectLayoutID
            else
              #
              # Reverse bytes.
              #
              let layoutID="0x${layoutID:6:2}${layoutID:4:2}${layoutID:2:2}${layoutID:0:2}"
              #
              # Is this a different layout-id than the default one?
              #
              if [[ $layoutID -ne $gLayoutID ]];
                then
                  #
                  # Yes. Ask if we should use this layout-id.
                  #
                  question="Do you want to use [${gLayoutID}] as the layout-id (y/n)? "

                  read -p "$question" choice
                  case "$choice" in
                    y|Y)
                      echo "Notice: Now using layout-id: ${gLayoutID}"
                      ;;

                    *) #
                       # Show list with supported layout-id's and let user select one.
                       #
                       _selectLayoutID
                       ;;
                  esac
              fi
          fi
        else
          echo 'Error: ACPI Device (HDEF) {} NOT found!'
          echo '       ACPI tables appear to be broken and require patching!'
          echo 'Aborting ...'
          exit 1
      fi
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
           local data=(${gSupportedCodecs[ ($selection - 1) ]})
           #
           # Updating global variables.
           #
           gKextName="AppleHDA${data[2]}"
           gCodecID=${data[0]}
           gKextID=${data[2]}
           gDownloadLink="https://raw.github.com/toleda/audio_ALC${data[2]}/master/${data[2]}.zip"
           #
           # Change delimiter.
           #
           IFS="."
           #
           # Split data into supported layout-id's.
           #
           gSupportedLayoutIDs=(${data[3]})
           #
           # Restore the default delimiter.
           #
           IFS=$ifs
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
  let stat=0
  #
  # Local function definition
  #
  function __searchForConfigData()
  {
    let index=0
    local sourceFile=$1

    while [ $index -lt 20 ];
    do
      local commandString="Print :IOKitPersonalities:HDA\ Hardware\ Config\ Resource:HDAConfigDefault:${index}:"
      local codecID=$(/usr/libexec/PlistBuddy -c "${commandString}CodecID" $sourceFile 2>&1)
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

              gExtractedConfigData=$(/usr/libexec/PlistBuddy -c "${commandString}ConfigData" $sourceFile)
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
  echo "Looking in ${gExtensionsDirectory}/AppleHDA.kext for the ConfigData"
  __searchForConfigData "${gExtensionsDirectory}/AppleHDA.kext/Contents/PlugIns/AppleHDAHardwareConfigDriver.kext/Contents/Info.plist"

  if (($? == 0));
    then
      #
      # But when that fails, then we look for the data in FakeSMC.kext
      #
      echo "Looking in ${gExtensionsDirectory}/FakeSMC.kext for the ConfigData"
      __searchForConfigData "${gExtensionsDirectory}/FakeSMC.kext/Contents/Info.plist"
      #
      # Check status for success.
      #
      if (($? == 0));
        then
          #
          # Oops. Failure. Download the files from Toleda's Github repository :-)
          #
          echo "Error: ConfigData NOT found!\nDownloading ${gDownloadLink} ...\n"
          sudo curl -o "/tmp/ALC${gKextID}.zip" $gDownloadLink
          #
          # Unzip the downloaded file.
          #
          echo ''
          _DEBUG_DUMP 'Download Done'
          printf 'Unzipping '
          unzip -u "/tmp/ALC${gKextID}.zip" -d "/tmp/"
          #
          # We <em>should</em> now have the Info.plist so let's do another search for the ConfigData,
          # but first convert 'gProductVersion' to something that Toleda is using (example: 10.9.2 -> 92)
          #
          local plistID=99 # $(gProductVersion | sed 's/[10\./]//g')
          #
          # Start by checking if the file exists.
          #
          if [[ ! -e "/tmp/${gKextID}/Info-${plistID}.plist" ]];
            then
              _DEBUG_DUMP "Warning: Info-${plistID}.plist not found!"
              #
              # No. File does not exist. Create list with available plist files.
              #
              plistNames=($(ls /tmp/${gKextID}/Info-??.plist | tr "\n" " "))
              #
              # Get number of plist files.
              #
              local numberOfPlistFiles=${#plistNames[@]}
              #
              #
              #
              if [[ numberOfPlistFiles -gt 0 ]];
                then
                  let index=0
                  echo "\nThe available Info.plist files for the ALC ${gKextID} are:\n"

                  for plistName in ${plistNames[@]}
                  do
                    let index++
                     echo "[${index}] ${plistName}"
                  done

                  echo ''
                  read -p "Please choose the matching Info.plist (1/${index}) " selection
                  case "$selection" in
                    [1-${index}])
                       echo "\nLooking in: ${plistNames[${selection} - 1]} for the ConfigData"
                       __searchForConfigData "${plistNames[${selection} - 1]}"
                       ;;

                    *) echo 'Error: Invalid selection!'
                       return 0
                       ;;
                  esac
              fi
            else
              echo "Looking in /tmp/${gKextID}/Info-${plistID}.plist for the ConfigData"
              __searchForConfigData "/tmp/${gKextID}/Info-${plistID}.plist"
          fi

          if (($? == 1));
            then
              let stat=1
              gSourceDirectory="/tmp/${gKextID}"
          fi
        else
          let stat=1
          gSourceDirectory="${gExtensionsDirectory}/AppleHDA.kext/Contents/Resources"
      fi
    else
      let stat=1
      gSourceDirectory="${gExtensionsDirectory}/AppleHDA.kext/Contents/Resources"
  fi
  #
  # Inform user about the progress.
  #
  if [[ $stat -eq 1 ]];
    then
      echo  "ConfigData for Realtek ALC ${gKextID} found!"
      #
      # \c stops it from adding a trailing new line character (-n is not available in sh).
      #
      echo '------------------------------------------------------------'
      gConfigData=$(echo "$gExtractedConfigData\c" | base64)
      echo $gConfigData
      echo '------------------------------------------------------------'
      return 1
    else
      echo "Error: ConfigData for Realtek ALC ${gKextID} with layout-id:${gLayoutID} was NOT found!"
  fi

  return 0
}


#
#--------------------------------------------------------------------------------
#

function _creatInfoPlist()
{
  echo '<?xml version="1.0" encoding="UTF-8"?>'                                                                       > $gInfoPlist
  echo '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">'      >> $gInfoPlist
  echo '<plist version="1.0">'                                                                                       >> $gInfoPlist
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

    _DEBUG_DUMP "AppleHDA8Series.sh was launched with a target ALC${targetALC}\n"
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
    read -p "${gKextName}.kext already exists. Do you want to overwrite it (y/n)? " choice
    case "$choice" in
      y|Y)
        _DEBUG_DUMP "Removing directory ..."
        rm -r "${gTargetDirectory}/${gKextName}.kext"
        ;;
     esac
  fi

  _initConfigData
  #
  # Check error status.
  #
  if (( $? == 0 ));
    then
      #
      # Error. ConfigData not found.
      #
      echo 'Aborting ...\n'
      exit 1
  fi

  #
  # Make target directory structure.
  #
  echo "Creating ${gKextName}.kext in: $gTargetDirectory"
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
  #
  # -c = Execute command and exit.
  #
  /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString 9.1.1" "$gTargetFile"
  /usr/libexec/PlistBuddy -c "Set :CFBundleVersion 9.1.1a10" "$gTargetFile"
  #
  # Fix ownership and permissions.
  #
  _DEBUG_DUMP 'Fixing file permissions ...'
  chmod -R 755 "${gTargetDirectory}/${gKextName}.kext"
  #
  # Ownership of a file may only be altered by a super-user hence the use of sudo here.
  #
  _DEBUG_DUMP 'Fixing file ownership ...'
  chown -R root:wheel "${gTargetDirectory}/${gKextName}.kext"

  if [[ "$gTargetDirectory" != "$gExtensionsDirectory" ]];
    then
      _DEBUG_DUMP "Checking kext with kextutil ..."
      #
      # -q = Quiet mode; print no informational or error messages.
      # -t = Perform all possible tests on the specified kexts.
      # -n = Neither load the kext nor send personalities to the kernel.
      # -k = Link against the given kernel_file.
      #
      kextutil -qtnk /mach_kernel "$gTargetDirectory/${gKextName}.kext"

      if (($? == 0));
        then
          echo "${gKextName}.kext appears to be loadable (including linkage for on-disk libraries)."

          read -p "Do you want to copy ${gKextName}.kext to: ${gExtensionsDirectory}? (y/n) " choice
          case "$choice" in
            y|Y ) cp "$gTargetDirectory/${gKextName}.kext" "$gExtensionsDirectory"
                  gTargetDirectory = "$gExtensionsDirectory"
            ;;
          esac
      fi
  fi
  #
  # Check target directory.
  #
  if [[ "$gTargetDirectory" == "$gExtensionsDirectory" ]]; then
    #
    # Conditionally touch the Extensions directory.
    #
    _DEBUG_DUMP 'Triggering a kernelcache refresh ...'
    touch "$gExtensionsDirectory"

    read -p "Do you want to reboot now? (y/n) " choice2
    case "$choice2" in
      y|Y ) reboot now
      ;;
    esac
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
