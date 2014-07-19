#!/bin/bash

#
# Script (AppleHDA8Series.sh) to create AppleHDA892.kext (example)
#
# Version 3.1 - Copyright (c) 2013-2014 by Pike R. Alpha (PikeRAlpha@yahoo.com)
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
#			- New/more flexible script arguments added (Pike R. Alpha, January 2014)
#			- Optional (-b AppleHDA) bin-patching added (Pike R. Alpha, January 2014)
#			- Error in gSupportedCodecs for ALC 898 fixed, thanks to Toleda  (Pike R. Alpha, January 2014)
#			- Copying kext to /S*/L*/Extensions failed due to a missing flag (-r), thanks to Toleda  (Pike R. Alpha, January 2014)
#			- Confirmation for layout-id showed the wrong layout-id, thanks to Toleda  (Pike R. Alpha, January 2014)
#			- Made errors and warning messages stand out more (Pike R. Alpha, January 2014)
#			- AppleHDAController bin-patching added (Pike R. Alpha, January 2014)
#			- _DEBUG_DUMP renamed to _DEBUG_PRINT (Pike R. Alpha, January 2014)
#			- Search pattern checks moved from main to _initBinPatchPattern (Pike R. Alpha, January 2014)
#			- Default pattern for AppleHDAController bin-patching added (Pike R. Alpha, January 2014)
#			- Update gInfoPlist after (auto)selection of ALC model (Pike R. Alpha, January 2014)
#			- Creating AppleHDA898.kext failed due to a silly typo 899->898 (Pike R. Alpha, January 2014)
#			- Stop showing the warning for a missing Info-NN.plist (Pike R. Alpha, January 2014)
#			- Fixed an issue where 00 bytes were stripped off of ConfigData (Pike R. Alpha, January 2014)
#			- We now export the ConfigData and no longer use base64 to convert data (Pike R. Alpha, January 2014)
#			- Added a default pattern for -b AppleHDAController (Pike R. Alpha, January 2014)
#			- The -h argument now shows the supported ALC's (Pike R. Alpha, January 2014)
#			- Using a less restrictive filter for -d target directory (Pike R. Alpha, Februari 2014)
#			- Changed download host from raw.github.com to raw.githubusercontent.com (Pike R. Alpha, June 2014)
#			- OS version detection improved for Yosemite (Pike R. Alpha, June 2014)
#			- Changed CFBundleShortVersionString injection for Yosemite (Pike R. Alpha, June 2014)
#			- Changed CFBundleVersion injection for Yosemite (Pike R. Alpha, June 2014)
#			- Typo in URL fixed (Pike R. Alpha, June 2014)
#			- Automatic binary patching of AppleHDAController added (Pike R. Alpha, July 2014)
#			- Always use ${gKextName} instead of hard coded 'AppleHDA892' (Pike R. Alpha, July 2014)
#			- Changed two variable names/now using the right var names (Pike R. Alpha, July 2014)
#			- Added a forgotten cp instruction for the patched binary file (Pike R. Alpha, July 2014)
#			- Stop re-downloading the archive from Toleda's Github repository (Pike R. Alpha, July 2014)
#			- Added support for (new style) hdacd.plist (Pike R. Alpha, July 2014)
#
# TODO:
#			- Add a way to restore the untouched/vanilla AppleHDA.kext
#
# Contributors:
#			- Thanks to 'Toleda' for providing a great Github repository and all his testing.
#			- Thanks to 'philip_petev' for his tip to use PlistBuddy.
#
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
# Usage (version 1.5):
#
#           - ./AppleHDA8Series.sh [hald]
#
# Examples:
#           - ./AppleHDA8Series.sh
#           - ./AppleHDA8Series.sh -a 892 
#           - ./AppleHDA8Series.sh -a 892 -l 3
#           - ./AppleHDA8Series.sh -a 892 -l 3 -d /System/Library/Extensions
#
# Usage (version 1.6 and 1.7):
#
#           - ./AppleHDA8Series.sh [halbd]
#
# Examples:
#           - ./AppleHDA8Series.sh
#           - ./AppleHDA8Series.sh -a 892
#           - ./AppleHDA8Series.sh -a 892 -l 3
#           - ./AppleHDA8Series.sh -a 892 -l 3 -d /System/Library/Extensions
#           - ./AppleHDA8Series.sh -b AppleHDA
#
# Usage (version 1.8):
#
#           - ./AppleHDA8Series.sh [halbd]
#
# Examples:
#           - ./AppleHDA8Series.sh
#           - ./AppleHDA8Series.sh -a 892
#           - ./AppleHDA8Series.sh -a 892 -l 3
#           - ./AppleHDA8Series.sh -a 892 -l 3 -d /System/Library/Extensions
#           - ./AppleHDA8Series.sh -b AppleHDA (uses built-in patch pattern)
#           - ./AppleHDA8Series.sh -b AppleHDA:\x8b\x19\xd4\x11,\x92\x08\xec\x10
#
# Usage (version 1.9 and greater):
#
#           - ./AppleHDA8Series.sh [halbd]
#
# Examples:
#           - ./AppleHDA8Series.sh
#           - ./AppleHDA8Series.sh -a 892
#           - ./AppleHDA8Series.sh -a 892 -l 3
#           - ./AppleHDA8Series.sh -a 892 -l 3 -d /System/Library/Extensions
#           - ./AppleHDA8Series.sh -b AppleHDA (uses built-in patch pattern)
#           - ./AppleHDA8Series.sh -b AppleHDA:\x8b\x19\xd4\x11,\x92\x08\xec\x10
#           - ./AppleHDA8Series.sh -b AppleHDA -b AppleHDAController
#           - ./AppleHDA8Series.sh -b AppleHDA:\x8b\x19\xd4\x11,\x92\x08\xec\x10 -b AppleHDAController:\x0c\x0c\x00\x00\x75\x61\xeb\x30,\x0c\x0c\x00\x00\x75\x61\xeb\x0e
#
# Usage (version 2.4 and greater):
#
# Example:
#           - ./AppleHDA8Series.sh -b AppleHDA:\x85\x08\xec\x10,\x85\x08\xec\x10
#
# Note: This is a special condition to get the AppleHDA binary copied without actually patching it.
#

gScriptVersion=3.1

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
283904153,0x10EC0899,898,1.2.3
283904256,0x10EC0900,1150,1.2
)

#
# The default download link to Toleda's Githib repository.
#
gDownloadLink="https://raw.githubusercontent.com/toleda/audio_ALC892/master/892.zip"

#
# The version info of the running system i.e. '10.9.2'
#
gProductVersion="$(sw_vers -productVersion)"

#
# These will be initialised later on, when required.
#
gAppleHDAPatchPattern=""
gAppleHDAControllerPatchPattern=""

#
# Hex dump file for AppleHDAController patching.
#
gHexDumpFile="/tmp/AppleHDAController.txt"

#
# Change this to 0 if you don't want additional styling (bold/underlined).
#
let gExtraStyling=1

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
# Additional files with AppleHDAController bin-patching:
#
# AppleHDA892.kext/Contents/PlugIns/AppleHDAController.kext
# AppleHDA892.kext/Contents/PlugIns/AppleHDAController.kext/Contents
# AppleHDA892.kext/Contents/PlugIns/AppleHDAController.kext/Contents/Info.plist
# AppleHDA892.kext/Contents/PlugIns/AppleHDAController.kext/Contents/MacOS
# AppleHDA892.kext/Contents/PlugIns/AppleHDAController.kext/Contents/MacOS/AppleHDAController

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

function _DEBUG_PRINT()
{
  if [[ $DEBUG -eq 1 ]];
    then
      printf "$1"
  fi
}


#
#--------------------------------------------------------------------------------
#

function _PRINT_NOTE()
{
  if [[ $gExtraStyling -eq 1 ]];
    then
      printf "${STYLE_BOLD}Note:${STYLE_RESET} $1"
    else
      printf "Note: $1"
  fi
}


#
#--------------------------------------------------------------------------------
#

function _PRINT_WARNING()
{
  if [[ $gExtraStyling -eq 1 ]];
    then
      printf "${STYLE_BOLD}Warning:${STYLE_RESET} $1"
    else
      printf "Warning: $1"
  fi
}

#
#--------------------------------------------------------------------------------
#

function _PRINT_ERROR()
{
  if [[ $gExtraStyling -eq 1 ]];
    then
      printf "${STYLE_BOLD}Error:${STYLE_RESET} $1"
    else
      printf "Error: $1"
  fi
}


#
#--------------------------------------------------------------------------------
#
function _ABORT()
{
  if [[ $gExtraStyling -eq 1 ]];
    then
      printf "Aborting ...\n${STYLE_BOLD}Done.${STYLE_RESET}\n\n"
    else
      printf "Aborting ...\nDone.\n\n"
  fi

  exit 1
}


#
#--------------------------------------------------------------------------------
#

function _selectLayoutID()
{
  let index=0
  printf "\nThe available layout-id's for the ALC ${gKextID} are:\n\n"

  for layout in ${gSupportedLayoutIDs[@]}
  do
    let index++
    echo "[${index}] layout-id: ${layout}"
  done

  echo ''

  read -p "Please choose the desired layout-id (1/${index})? " selection
  case "$selection" in
    [1-${index}])
      echo "Now using layout-id: ${selection}"
      let gLayoutID=$selection
      ;;

    *) _PRINT_ERROR "Invalid selection!\n"
      _initLayoutID $1
      ;;
  esac
}


#
#--------------------------------------------------------------------------------
#

function _checkHDEFProperties()
{
  if [[ ! -e /tmp/HDEF.txt ]];
    then
      #
      # -r = Show subtrees rooted by objects that match the specified criteria (-p and -k)
      # -w = Clipping (none, unlimited line width)
      # -p = Traverse the registry plane 'IODeviceTree'
      # -n = Show properties if there is an object with the name 'HDEF'
      #
      ioreg -rw 0 -p IODeviceTree -n HDEF > /tmp/HDEF.txt
  fi

  if [[ $(cat /tmp/HDEF.txt | grep -o "MaximumBootBeepVolume") == "MaximumBootBeepVolume" ]];
    then
      _DEBUG_PRINT "MaximumBootBeepVolume property found\n"
    else
      _PRINT_WARNING "'MaximumBootBeepVolume' property NOT found (will show a Sound assertion in: system.log)\n"
  fi

  if [[ $(cat /tmp/HDEF.txt | grep -o "PinConfigurations") == "PinConfigurations" ]];
    then
      _DEBUG_PRINT "PinConfigurations property found\n"
    else
      _PRINT_ERROR "'PinConfigurations property NOT found (may result in unexpected behaviour)!\n"
  fi
}


#
#--------------------------------------------------------------------------------
#

function _checkPatchPatterns()
{
  local targetBinary=$1
  local commandString=$2
  #
  # Strip AppleHDA:/AppleHDAController: and get all characters after the vertical bar.
  #
  local searchPattern=$(echo $commandString | sed -e 's/AppleHDA.*://' -e 's/|.*$//g')
  #
  # Get all characters in front of the vertical bar.
  #
  local replacePattern=$(echo $commandString | sed -e 's/.*|//g')

  #
  # Check length of search/replace patterns. Are they of the same length?
  #
  if [[ ${#searchPattern} == ${#replacePattern} ]];
    then
      #
      # Yes, so do we have a target binary (should be there)?
      #
      if [[ -e "$targetBinary" ]];
        then
          local targetBinaryName=$(echo $targetBinary | sed 's/.*\/MacOS\///')
          _DEBUG_PRINT "targetBinaryName: $targetBinaryName\n"

          #
          # Yes. Check the given search pattern.
          #
          /usr/bin/grep "$searchPattern" "$targetBinary" > /dev/null

          #
          # Check return status.
          #
          if [[ $? == 0 ]];
            then
              #
              # Ok. Check the given replace pattern (must match).
              #
              /usr/bin/grep "$replacePattern" "$targetBinary" > /dev/null

              #
              # Check return status.
              #
              if [[ $? == 0 ]];
                then
                  #
                  # Are the search and replace patterns the same?
                  #
                  if [[ "$searchPattern" == "$replacePattern" ]];
                    then
                      #
                      # Special condition to get AppleHDA copied later on.
                      #
                      _PRINT_WARNING "Search and replace patterns are the same!\n"
                      return 2
                    else
                      _PRINT_WARNING "Search and replace patterns found in ${targetBinaryName}!\n"
                      printf "         ${targetBinaryName} may already have been patched!\n"
                  fi
                else
                  printf "Search pattern found in ${targetBinaryName}, replace pattern NOT found (Ok).\n"
                  return 0
              fi
            else
              #
              #
              #
              _PRINT_ERROR "Search pattern is NOT found in ${targetBinaryName}! "
              _ABORT
          fi
      fi
    else
      #
      # No. Not the same length.
      #
      _PRINT_ERROR "Length of Search/Replace patterns is different! "
      _ABORT
  fi

  return 1
}


#
#--------------------------------------------------------------------------------
#

function _checkKernelFlags()
{
  printf "Checking boot arguments ... "

  local data=$(awk '/<key>Kernel Flags<\/key>.*/,/<\/string>/' /Library/Preferences/SystemConfiguration/com.apple.Boot.plist)
  #
  # Example:
  #
  # <key>Kernel Flags</key>
  # <string>-f -no-zp kext-dev-mode=1</string>
  #
  local kernelFlags=$(echo $data | egrep -o '(<string>.*</string>)' | sed -e 's/<\/*string>//g')
  #
  # Example:
  #
  # -f -no-zp kext-dev-mode=1
  #
  #
  # Check to see if 'kext-dev-mode=1' is set?
  #
  if [[ "$kernelFlags" =~ "kext-dev-mode=1" ]];
    then
      printf "Argument 'kext-dev-mode=1' found (OK)\n"
    else
      _PRINT_WARNING "Argument 'kext-dev-mode=1' not found (${gKextName}.kext won't load)!\n"
  fi

  #
  # TODO: Add check for EFI/Clover/config.plist
  #
}


#
#--------------------------------------------------------------------------------
#

function _patchAppleHDAController()
{
  appleHDAController="${gExtensionsDirectory}/AppleHDA.kext/Contents/PlugIns/AppleHDAController.kext/Contents/MacOS/AppleHDAController"

  #
  # Cleanups.
  #
  if [[ -f /tmp/AppleHDAController ]];
    then
      rm /tmp/AppleHDAController
  fi

  if [[ -f /tmp/AppleHDAController.txt ]];
    then
      rm /tmp/AppleHDAController.txt
  fi

  #
  # Dump AppleHDAController in postscript hexdump style to /tmp/AppleHDAController.txt
  #
  /usr/bin/xxd -ps "${appleHDAController}" | tr -d '\n' > $gHexDumpFile

  _DEBUG_PRINT 'Step 1, '
  #
  # Search pattern for: __ZN18AppleHDAController17gfxMatchedHandlerEPvP9IOServiceP10IONotifier
  #
  gMatchData=$(egrep -o '3d0c0a0000[0-9a-f]{4}3d0c0d00' $gHexDumpFile)

  if [[ $gMatchData ]];
    then
      _DEBUG_PRINT 'patching: __ZN18AppleHDAController17gfxMatchedHandlerEPvP9IOServiceP10IONotifier ...\n'
      #
      # Example:
      #
      # 0123456789 123456789 1
      # 3d0c0a0000740e3d0c0d00 -> 3d0c0c0000740e3d0c0d00
      #      ^                         ^
      #      a                 ->      c
      #
      /usr/bin/perl -pi -e "s|${gMatchData}|${gMatchData:0:5}c${gMatchData:6:16}|" $gHexDumpFile
    else
      _PRINT_WARNING "no match found for: __ZN18AppleHDAController17gfxMatchedHandlerEPvP9IOServiceP10IONotifier\n"
  fi

  _DEBUG_PRINT 'Step 2, '
  #
  # Search pattern for: __ZN18AppleHDAController19edidIsValidForAudioEP6OSDatai
  #
  gMatchData=$(egrep -o '3d0c0a0000[0-9a-f]{12}3d0c0d00' $gHexDumpFile)

  if [[ $gMatchData ]];
    then
      _DEBUG_PRINT 'patching: __ZN18AppleHDAController19edidIsValidForAudioEP6OSDatai ...\n'
      #
      # Example:
      #
      # 0123456789 123456789 123456789
      # 3d0c0a00000f84830100003d0c0d00 -> 3d0c0c00000f84830100003d0c0d00
      #      ^                                 ^
      #      a                         ->      c
      #
      /usr/bin/perl -pi -e "s|${gMatchData}|${gMatchData:0:5}c${gMatchData:6:24}|" $gHexDumpFile
    else
      _DEBUG_PRINT "no match found for: __ZN18AppleHDAController19edidIsValidForAudioEP6OSDatai (normal for OS X 10.8)\n"
  fi

  _DEBUG_PRINT 'Step 3, '
  #
  # Search pattern for: __ZN18AppleHDAController18setupHostInterfaceEv
  #
  gMatchData=$(egrep -o '3d0c0a0000[0-9a-f]{28}3d0c0c00[0-9a-f]{14}' "${gHexDumpFile}")

  if [[ $gMatchData ]];
    then
      _DEBUG_PRINT 'patching: __ZN18AppleHDAController18setupHostInterfaceEv ...\n'
      #
      # Example:
      #
      # 0123456789 123456789 123456789 123456789 123456789 123456789
      #           123456789 123456789 123456789 12345678
      # 3d0c0a0000745ee9180100003d0b0d00007f103d0c0c00000f8496000000 -> 3d0c0a0000745ee9180100003d0b0d00007f103d0c0c0000744b90909090 (DP1)
      # 3d0c0a0000745ee9320100003d0b0d00007f103d0c0c00000f8520010000 -> 3d0c0a0000745ee9320100003d0b0d00007f103d0c0c0000747590909090 (DP2)
      #             ^^                                  ^^^^^^^^^^^^
      #                                                 74XX90909090 (10.10)
      #                                                   ^^
      #                                                 744b90909090
      #
      let jmpSource=(0x${gMatchData:12:2})
      #
      # Calculating offset: 0x5e - (38 (characters) / 2 = 19 (0x13 bytes)) = 0x4b
      #
      let jmpTarget=$jmpSource-19

      newTarget=$(echo "ibase=10;obase=16; ${jmpTarget}" | bc | tr '[:upper:]' '[:lower:]')

      _DEBUG_PRINT "${jmpSource}\n"
      _DEBUG_PRINT "${jmpTarget}\n"
      _DEBUG_PRINT "${newTarget}\n"

      if [ "${gMatchData:48:2}" == "0f" ];
        then
          /usr/bin/perl -pi -e "s|${gMatchData}|${gMatchData:0:48}74${newTarget}90909090|" $gHexDumpFile
        else
          /usr/bin/perl -pi -e "s|${gMatchData}|${gMatchData:0:50}${newTarget}${gMatchData:52:8}|" $gHexDumpFile
      fi
    else
      _PRINT_ERROR "no match found for: __ZN18AppleHDAController18setupHostInterfaceEv\n"
  fi

  #
  # Convert hex data to binary file
  #
  /usr/bin/xxd -r -p $gHexDumpFile /tmp/AppleHDAController

  if [[ $DEBUG -eq 1 ]];
    then
      #
        # Show changed bytes
        #
        printf "\nPatched bytes:\n-------------------------\n"
        /usr/bin/cmp -l "${appleHDAController}" /tmp/AppleHDAController
        echo -e "-------------------------"
  fi
}


#
#--------------------------------------------------------------------------------
#

function _initBinPatchPattern()
{
  local commandString=$(echo $1 | sed -e 's/,/|/g' -e 's/x/\\x/g')
  #
  # Initialise search and replace patterns for AppleHDA/AppleHDAController
  #
  local patternString=$(echo $commandString | sed 's/AppleHDA.*://')
  #
  # Should we init a bin-patch pattern for the AppleHDA binary?
  #
  if [[ ${commandString:0:18} == "AppleHDAController" ]];
    then
      #
      # Yes. Are we called with: -b AppleHDAController:search_data,replace_data?
      #
      if [[ ${commandString:18:1} == ":" ]];
        then
          #
          # Check for illegal characters in patterns.
          #
          if [[ $patternString =~ ^[0-9a-fA-F|\\x]+$ ]];
            then
              #
              # Yes. check the given pattern.
              #
              _checkPatchPatterns "${gExtensionsDirectory}/AppleHDA.kext/Contents/PlugIns/AppleHDAController.kext/Contents/MacOS/AppleHDAController" $commandString

              if [[ $? -eq 0 ]];
                then
                  gAppleHDAControllerPatchPattern=$patternString
                else
                  gAppleHDAControllerPatchPattern=""
                  _PRINT_WARNING "AppleHDAController will NOT be copied/patched!\n\n"
                  printf "         ${STYLE_BOLD}Tip:${STYLE_RESET} Do you want AppleHDAController to get copied?\n"
                  printf "              - Use a search pattern that matches the AppleHDAController binary.\n"
                  printf "              - Use your search pattern also as replace pattern.\n"
                  read -p "Do you want to continue or abort (c/a)? " choice
                  case "$choice" in
                    a|A) _ABORT
                         ;;

                      *) echo ""
                         ;;
                  esac
              fi
            else
              _PRINT_ERROR "Illegal character(s) detected in pattern! "
              _ABORT
          fi
        else
          # gAppleHDAControllerPatchPattern="\x0c\x0c\x00\x00\x75\x61\xeb\x30|\x0c\x0c\x00\x00\x75\x61\xeb\x0e"
          gAppleHDAControllerPatchPattern="Automatic"
      fi
    #
    # Or should we init a bin-patch pattern for the AppleHDA binary?
    #
    elif [[ ${commandString:0:8} == "AppleHDA" ]];
      then
        #
        # Yes. Are we called with: -b AppleHDA:search_data,replace_data?
        #
        if [[ ${commandString:8:1} == ":" ]];
          then
            #
            # Check for illegal characters in patterns.
            #
            if [[ $patternString =~ ^[0-9a-fA-F|\\x]+$ ]];
              then
                #
                # Yes. check the given pattern.
                #
                _checkPatchPatterns "${gExtensionsDirectory}/AppleHDA.kext/Contents/MacOS/AppleHDA" $commandString
                local stat=$?

                if [[ $stat -eq 0 ]];
                  then
                    echo ''
                    gAppleHDAPatchPattern=$patternString
                  else
                    gAppleHDAPatchPattern=""

                    if [[ $stat -eq 1 ]];
                      then
                        printf "         AppleHDA will NOT be copied and will NOT be patched!\n"
                        printf "\n         ${STYLE_BOLD}Tip:${STYLE_RESET} Do you want AppleHDA to get copied?\n"
                        printf "              - Use a search pattern that matches the AppleHDA binary.\n"
                        printf "              - Use your search pattern also as replace pattern.\n"
                        printf '                Example: -b AppleHDA:\\x85\\x08\\xec\\x10,\\x85\\x08\\xec\\x10\n\n'
                        read -p "Do you want to continue or abort (c/a)? " choice
                        case "$choice" in
                          a|A) _ABORT
                               ;;

                            *) echo ""
                               ;;
                        esac
                      else
                        printf "         AppleHDA will be copied but will NOT be patched!\n\n"
                    fi
                fi
              else
                _PRINT_ERROR "Illegal character(s) detected in pattern! "
                _ABORT
            fi
          else
            #
            #  No. Select default pattern for the AppleHDA executable.
            #
            case "${gTargetALC}" in
              885 ) #
                    # Default off. Use command line arguments to patch the binary
                    #
                    echo "ALC 885 is NOT pre-defined. Please use: ./AppleHDA8Series.sh -a 885 -b AppleHDA:\x8b\x19\xd4\x11,\x85\x08\xec\x10"
                    ;;

              887 ) gAppleHDAPatchPattern="\x8b\x19\xd4\x11|\x87\x08\xec\x10"
                    ;;

              888 ) gAppleHDAPatchPattern="\x8b\x19\xd4\x11|\x88\x08\xec\x10"
                    ;;

              889 ) gAppleHDAPatchPattern="\x8b\x19\xd4\x11|\x89\x08\xec\x10"
                    ;;

              892 ) gAppleHDAPatchPattern="\x8b\x19\xd4\x11|\x92\x08\xec\x10"
                    ;;

              898 ) gAppleHDAPatchPattern="\x8b\x19\xd4\x11|\x99\x08\xec\x10"
                    ;;

              1150) gAppleHDAPatchPattern="\x8b\x19\xd4\x11|\x00\x09\xec\x10"
                    ;;

                 *) #
                    # We get here when -b AppleHDA is used without -a ALC in front of
                    # it and that is not an error, but in that case we want it to
                    # reinitialise the bin-patch data later on. After the ALC is selected.
                    #
                    gAppleHDAPatchPattern="undetermined"
                    _DEBUG_PRINT "'-b AppleHDA' given but '-a ALC NNN' is missing!"
                    ;;
            esac
        fi
    else
      _PRINT_ERROR "-b with unsupported binary target used! "
      _ABORT
  fi
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
      ioreg -rw 0 -p IODeviceTree -n HDEF > /tmp/HDEF.txt
      #
      # Check for Device (HDEF) in the ioregHDEFData.
      #
      if [[ $(cat /tmp/HDEF.txt | grep -o "HDEF@1B") == "HDEF@1B" ]];
        then
          _DEBUG_PRINT "ACPI Device (HDEF) {} found\n"
          #
          # Get layout-id from ioreg data.
          #
          local layoutID=$(cat /tmp/HDEF.txt | grep layout-id | sed -e 's/.*<//' -e 's/>//')
          _DEBUG_PRINT "layoutID: $layoutID\n"
          #
          # Check value of layout-id (might still be empty).
          #
          if [[ $layoutID == "" ]];
            then
              #
              # Show supported layout-id's and let user select one.
              #
              _selectLayoutID
            else
              #
              # Reverse bytes.
              #
              let layoutID="0x${layoutID:6:2}${layoutID:4:2}${layoutID:2:2}${layoutID:0:2}"
              #
              # Ask if we should use this layout-id.
              #
              question="Do you want to use [${layoutID}] as the layout-id (y/n)? "

              read -p "$question" choice
              case "$choice" in
                y|Y) gLayoutID=$layoutID
                     ;;

                  *) #
                     # Show supported layout-id's and let user select one.
                     #
                     _selectLayoutID
                     ;;
              esac
          fi
        else
          _PRINT_ERROR "ACPI Device (HDEF) {} NOT found!\n"
          echo '       ACPI tables appear to be broken and require (manual) patching! '
          _ABORT
      fi
  fi
}


#
#--------------------------------------------------------------------------------
#

function _initCodecID()
{
  printf "The supported Realtek ALC codecs for AppleHDA8Series.sh are:\n\n"
  #
  # Are we called with a target ALC?
  #
  if [[ $gTargetALC != "" ]];
    then
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
        if [[ $gTargetALC == ${data[2]} ]];
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

  if [[ $gTargetALC != "" ]];
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
           gTargetALC=${data[2]}
           gDownloadLink="https://raw.githubusercontent.com/toleda/audio_ALC${data[2]}/master/${data[2]}.zip"
           gInfoPlist="${gTargetDirectory}/${gKextName}.kext/Contents/Info.plist"
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
           #
           # Do we have a bin-patch string?
           #
           if [[ $gAppleHDAPatchPattern == "undetermined" ]];
             then
               #
               # Yes. Re-init it (we have a new target ALC).
               #
               _initBinPatchPattern "AppleHDA"
             fi
           ;;

        *) echo "Invalid selection, retrying ..."
           sleep 1
           clear
           #
           # And try again.
           #
           _initCodecID
           ;;
  esac
}


#
#--------------------------------------------------------------------------------
#

function _initConfigData()
{
  let stat=0
  #
  # Local function definition
  #
  function __searchForConfigData()
  {
    let index=0
    local sourceFile=$1
    local hdacdStyle=$2
    #
    # First we check if the 'sourceFile' exists
    #
    if [[ -e $sourceFile ]];
      then
        #
        # Initialise PlistBuddy's command string.
        #
        if [[ $hdacdStyle -eq 1 ]];
          then
            local commandString="Print :HDAConfigDefault:"
          else
            local commandString="Print :IOKitPersonalities:HDA\ Hardware\ Config\ Resource:HDAConfigDefault:"
        fi
        #
        # Now loop through the plist and search for the target CodecID.
        #
        while [ $index -lt 20 ];
        do
          local codecID=$(/usr/libexec/PlistBuddy -c "${commandString}$index:CodecID" $sourceFile 2>&1)

          if [[ $codecID =~ "Does Not Exist" ]];
            then
              _DEBUG_PRINT "Error: ${commandString}${index} Not Found!\n"
              return 0
            else
              #
              # Is this the CodecID we are looking for?
              #
              if [[ $codecID -eq $gCodecID ]];
                then
                  _DEBUG_PRINT "Target CodecID found ...\n"
                  local layoutID=$(/usr/libexec/PlistBuddy -c "${commandString}$index:LayoutID" $sourceFile)

                  if [[ $layoutID -eq $gLayoutID ]];
                    then
                      _DEBUG_PRINT "Target LayoutID found ...\nGetting ConfigData ...\n"
                      #
                      # Get the ConfigData and store it in XML format (otherwise we end up with a trailing 0a)
                      #
                      /usr/libexec/PlistBuddy -c "${commandString}$index:ConfigData" $sourceFile -x > "/tmp/ConfigData-ALC${gKextID}.xml"
                      #
                      # Strip XML tags and remove the newline characters.
                      #
                      gConfigData=$(awk '/<data>.*/,/<\/data>/' "/tmp/ConfigData-ALC${gKextID}.xml" | sed -e 's/<\/*data>//' | tr -d '\n')
                      return 1
                  fi
              fi
          fi

          let index++
        done
      else
        _DEBUG_PRINT "Warning: '$sourceFile' Not Found!\n"
    fi

    return 0
  }
  #
  # The most common spot to look for ConfigData is of course in AppleHDAHardwareConfigDriver.kext
  #
  echo "Looking in: ${gExtensionsDirectory}/AppleHDA.kext for ConfigData"
  __searchForConfigData "${gExtensionsDirectory}/AppleHDA.kext/Contents/PlugIns/AppleHDAHardwareConfigDriver.kext/Contents/Info.plist"

  if (($? == 0));
    then
      #
      # But when that fails, then we look for the data in FakeSMC.kext
      #
      echo "Looking in: ${gExtensionsDirectory}/FakeSMC.kext for ConfigData"
      __searchForConfigData "${gExtensionsDirectory}/FakeSMC.kext/Contents/Info.plist"
      #
      # Do we have the ConfigData now?
      #
      if (($? == 0));
        then
          #
          # No we don't. Check for source plists in /tmp/ (files may be there already)
          # but first convert 'gProductVersion' to something that Toleda is using.
          #
          # Examples: 10.9.2 -> 92 / 10.10 -> 10 / 10.10.1 -> 101
          #
          local plistID=$(echo $gProductVersion | sed -e 's/^10\.//' -e 's/\.//')
          #
          # Did we download and unzip the archive already?
          #
          if [[ ! -e "/tmp/${gKextID}/Info-${plistID}.plist" && ! -e "/tmp/hdacd.plist" ]];
            then
            #
            # No. Download the archive from Toleda's Github repository :-)
            #
            _PRINT_ERROR "ConfigData NOT found!\nDownloading ${gDownloadLink} ...\n"
            sudo curl -o "/tmp/ALC${gKextID}.zip" $gDownloadLink
            #
            # Unzip archive.
            #
            echo ''
            _DEBUG_PRINT "Download Done!\n"
            printf "Unzipping "
            unzip -u "/tmp/ALC${gKextID}.zip" -d "/tmp/"
          fi
          #
          # Do we have a new style plist?
          #
          if [[ -e "/tmp/${gKextID}/hdacd.plist" ]];
            then
              #
              # Yes. Search for target CodecID, target LayoutID and ConfigData.
              #
              echo "Looking in: /tmp/${gKextID}/hdacd.plist for ConfigData"
              __searchForConfigData "/tmp/${gKextID}/hdacd.plist" 1
              #
              # Success?
              #
              if (($? == 1));
                then
                  let stat=1
                  gSourceDirectory="/tmp/${gKextID}"
              fi
            else
              #
              # No new style. Check for old style plist in /tmp/892/ (example).
              #
              if [[ ! -e "/tmp/${gKextID}/Info-${plistID}.plist" ]];
                then
                  _DEBUG_PRINT "${STYLE_BOLD}Warning:${STYLE_RESET} Info-${plistID}.plist not found!\n"
                  #
                  # No plist found. Create list with available plist files.
                  #
                  plistNames=($(ls /tmp/${gKextID}/Info-??.plist | tr "\n" " "))
                  #
                  # Get number of plist files.
                  #
                  local numberOfPlistFiles=${#plistNames[@]}
                  #
                  #
                  #
                  if [[ $numberOfPlistFiles -gt 0 ]];
                    then
                      let index=0
                      printf "\nThe available Info.plist files for the ALC ${gKextID} are:\n\n"

                      for plistName in ${plistNames[@]}
                      do
                        let index++
                         echo "[${index}] ${plistName}"
                      done

                      echo ''
                      read -p "Please choose the matching Info.plist (1/${index}) " selection
                      case "$selection" in
                        [1-${index}])
                           printf "\nLooking in: ${plistNames[${selection} - 1]} for ConfigData\n"
                           __searchForConfigData "${plistNames[${selection} - 1]}"
                           ;;

                        *) _PRINT_ERROR "Invalid selection!\n"
                           return 0
                           ;;
                      esac
                  fi
                else
                  echo "Looking in: /tmp/${gKextID}/Info-${plistID}.plist for ConfigData"
                  __searchForConfigData "/tmp/${gKextID}/Info-${plistID}.plist"
              fi

              if (($? == 1));
                then
                  let stat=1
                  gSourceDirectory="/tmp/${gKextID}"
              fi
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
      echo '------------------------------------------------------------'
      echo $gConfigData
      echo '------------------------------------------------------------'
      return 1
    else
      _PRINT_ERROR "ConfigData for Realtek ALC ${gKextID} with layout-id:${gLayoutID} was NOT found!\nTip: Change the layout-id in your DSDT, HDAEnabler.kext or device-properties"
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
  echo '	<string>AppleHDA'$gKextID' v'$gScriptVersion'.0, Copyright © 2013-'$(date "+%Y")' Pike R. Alpha. All rights reserved.</string>' >> $gInfoPlist
  echo '	<key>CFBundleIdentifier</key>'                                                                           >> $gInfoPlist
  echo '	<string>com.PikeRAlpha.driver.AppleHDA'$gKextID'</string>'                                               >> $gInfoPlist
  echo '	<key>CFBundleInfoDictionaryVersion</key>'                                                                >> $gInfoPlist
  echo '	<string>6.0</string>'                                                                                    >> $gInfoPlist
  echo '	<key>CFBundleName</key>'                                                                                 >> $gInfoPlist
  echo '	<string>Realtek '$gKextID' Configuation Driver</string>'                                                 >> $gInfoPlist
  echo '	<key>CFBundlePackageType</key>'                                                                          >> $gInfoPlist
  echo '	<string>KEXT</string>'                                                                                   >> $gInfoPlist
  echo '	<key>CFBundleShortVersionString</key>'                                                                   >> $gInfoPlist
  echo '	<string>'$gScriptVersion'.0</string>'                                                                    >> $gInfoPlist
  echo '	<key>CFBundleSignature</key>'                                                                            >> $gInfoPlist
  echo '	<string>????</string>'                                                                                   >> $gInfoPlist
  echo '	<key>CFBundleVersion</key>'                                                                              >> $gInfoPlist
  echo '	<string>'$gScriptVersion'.0</string>'                                                                    >> $gInfoPlist
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

function _invalidArgumentError()
{
  _PRINT_ERROR "Invalid argument detected: ${1} "
  _ABORT
}

#
#--------------------------------------------------------------------------------
#

function _getScriptArguments()
{
  #
  # Are we fired up with arguments?
  #
  if [ $# -gt 0 ];
    then
      #
      # Yes. Do we have a single (-help) argument?
      #
      if [[ $# -eq 1 && "$1" =~ "-h" ]];
        then
          if [[ $gExtraStyling -eq 1 ]];
            then
              echo "${STYLE_BOLD}Usage:${STYLE_RESET} ./AppleHDA8Series.sh [-haldb]"
            else
              echo "Usage: ./AppleHDA8Series.sh [-haldb]"
          fi
          echo '       -h print help info'
          echo '       -a target ALC [885/887/888/889/892/898/1150]'
          echo '       -l target layout-id'
          echo '       -d target directory'
          echo '       -b AppleHDA'
          echo '       -b AppleHDA:search,replace'
          echo '       -b AppleHDAController:search,replace'
          echo ''
          exit 0
        else
          #
          # Figure out what arguments are used.
          #
          while [ "$1" ];
          do
            #
            # Is this a valid script argument flag?
            #
            if [[ "${1}" =~ ^[-albdALBD]+$ ]];
              then
                #
                # Yes. Figure out what flag it is.
                #
                case "${1}" in
                  -a) shift

                      if [[ "$1" =~ ^[0-9]+$ ]];
                        then
                          #
                          # Make this our target ALC.
                          #
                          let gTargetALC=$1
                          _DEBUG_PRINT "Setting gTargetALC to     : ${gTargetALC}\n"
                        else
                          _invalidArgumentError "-a $1"
                      fi
                      ;;

                  -l) shift

                      if [[ "$1" =~ ^[0-9]+$ ]];
                        then
                          #
                          # Make this our target LayoutID.
                          #
                          let gTargetLayoutID=$1
                          _DEBUG_PRINT "Setting gTargetLayoutID to: ${gTargetLayoutID}\n"
                        else
                          _invalidArgumentError "-l $1"
                      fi
                      ;;

                  -b) shift

                      if [[ "${1:0:19}" == "AppleHDAController:" ]];
                        then
                          _DEBUG_PRINT "Initialising bin-patch pattern for AppleHDAController\n"
                          _initBinPatchPattern "$1"
                        elif [[ "${1:0:8}" == "AppleHDA" ]];
                          then
                          _DEBUG_PRINT "Initialising bin-patch pattern for AppleHDA\n"
                          _initBinPatchPattern "$1"
                        else
                          _invalidArgumentError "-b $1"
                      fi
                      ;;

                  -d) shift

                      if [[ "$1" =~ ^[0-9a-zA-Z/*?]+$ ]];
                        then
                          #
                          # Make this our target directory.
                          #
                          gTargetDirectory=$(echo "$1" | sed 's/\/$//')
                          _DEBUG_PRINT "Setting gTargetDirectory to: ${gTargetDirectory}\n"
                        else
                          _invalidArgumentError "-d $1"
                      fi
                      ;;
                esac
              else
                _invalidArgumentError "$1"
            fi
            shift;
          done;
      fi
  fi
}


#
#--------------------------------------------------------------------------------
#

function main()
{
  _showHeader
  _getScriptArguments "$@"
  _initCodecID
  _initLayoutID $gTargetLayoutID
  _checkHDEFProperties

  #
  # Is this the first run?
  #
  if [[ -e "${gTargetDirectory}/${gKextName}.kext" ]];
    then
      #
      # Yes. Ask if  we should use this layout-id.
      #
      _PRINT_WARNING "${gKextName}.kext already exists. Do you want to overwrite it (y/n)? "
      read choice
      case "$choice" in
        y|Y) printf "Removing directory ...\n"
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
      _ABORT
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
  # Add MacOS directory for the AppleHDA executable/the symbolic link to the AppleHDA executable.
  #
  mkdir "${gTargetDirectory}/${gKextName}.kext/Contents/PlugIns/AppleHDALoader.kext/Contents/MacOS"

  local sourceFile="${gExtensionsDirectory}/AppleHDA.kext/Contents/MacOS/AppleHDA"
  local targetFile="${gTargetDirectory}/${gKextName}.kext/Contents/PlugIns/AppleHDALoader.kext/Contents/MacOS/AppleHDA"

  #
  # Are we supposed to bin-patch the AppleHDA executable?
  #
  if [[ $gAppleHDAPatchPattern != "" ]];
    then
      #
      # Yes. Copy the AppleHDA executable to AppleHDALoader.kext/Contents/MacOS so that we can bin-patch it.
      #
      echo 'Copying AppleHDA ...'
      cp -p "$sourceFile" "$targetFile"

      if [[ $gAppleHDAPatchPattern != "" ]];
        then
          printf "Bin-patching AppleHDA ..."
          #
          # Call Perl to bin-patch the executable.
          #
          /usr/bin/perl -pi -e 's|'$gAppleHDAPatchPattern'|g' "$targetFile"
          #
          # Get the md5 checksums of the source and target file.
          #
          local md5SourceFile=$(md5 $sourceFile)
          local md5TargetFile=$(md5 $targetFile)
          #
          # Are the md5 checksums the same?
          #
          if [[ $md5SourceFile == $md5TargetFile ]];
            then
              #
              # Yes. Bin-patching failed.
              #
              _PRINT_ERROR " Patching failed!\n"
            else
              #
              # No. Bin-patching went fine.
              #
              printf " Done.\n"
          fi
      fi
    else
      #
      # Create symbolic link to executable.
      #
      echo 'Creating symbolic link to AppleHDA ...'
      ln -fs "$sourceFile" "$targetFile"
  fi

  #
  # Are we supposed to bin-patch the AppleHDAController executable?
  #
  if [[ $gAppleHDAControllerPatchPattern != "" ]];
    then
      #
      # Yes. Initialise variables.
      #
      local sourceFile="${gExtensionsDirectory}/AppleHDA.kext/Contents/PlugIns/AppleHDAController.kext/Contents/MacOS/AppleHDAController"
      local targetPath="${gTargetDirectory}/${gKextName}.kext/Contents/PlugIns/AppleHDAController.kext/Contents/MacOS/"
      local targetFile="${targetPath}AppleHDAController"

      #
      # Make target PlugIns directory structure.
      #
      mkdir -m 755 -p "${targetPath}"

      #
      # Copy the AppleHDAController executable to the target location.
      #
      echo 'Copying AppleHDAController ...'
      cp -p "$sourceFile" "$targetFile"

      printf "Bin-patching AppleHDAController ..."
      #
      # Are we supposed to auto-patch AppleHDAController?
      #
      if [[ $gAppleHDAControllerPatchPattern == "Automatic" ]];
        then
          #
          # Yes.
          #
          _patchAppleHDAController
          #
          # Copy patched binary executable from /tmp/ into target directory.
          #
          cp /tmp/AppleHDAController "$targetPath"
        else
          #
          # No. Call Perl to bin-patch the executable (old style).
          #
          /usr/bin/perl -pi -e 's|'$gAppleHDAControllerPatchPattern'|g' "$targetFile"
      fi

      #
      # Get the md5 checksums of the source and target file.
      #
      local md5SourceFile=$(md5 $sourceFile)
      local md5TargetFile=$(md5 $targetFile)
      #
      # Are the md5 checksums the same?
      #
      if [[ $md5SourceFile == $md5TargetFile ]];
        then
          #
          # Yes. Bin-patching failed.
          #
          _PRINT_ERROR " Patching failed!\n"
        else
          #
          # No. Bin-patching went fine.
          #
          printf " Done.\n"
      fi
      #
      # Re-initialise variables.
      #
      local sourceFile="${gExtensionsDirectory}/AppleHDA.kext/Contents/PlugIns/AppleHDAController.kext/Contents/Info.plist"
      local targetPath="${gTargetDirectory}/${gKextName}.kext/Contents/PlugIns/AppleHDAController.kext/Contents/"
      local targetFile="${targetPath}Info.plist"

      #
      # Copy Info.plist to our target location.
      #
      cp -p "$sourceFile" "$targetPath"

      #
      # Replace version info with "911.${gScriptVersion}" in Info.plist
      #
      # -c = Execute command and exit.
      #
      /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString 911.${gScriptVersion}" "$targetFile"
      /usr/libexec/PlistBuddy -c "Set :CFBundleVersion 911.${gScriptVersion}" "$targetFile"
  fi

  #
  # Create AppleHDA892.kext/Contents/Info.plist
  #
  _creatInfoPlist

  #
  # Copy AppleHDA.kext/Contents/Info.plist to our AppleHDALoader.kext
  #
  cp -p "${gExtensionsDirectory}/AppleHDA.kext/Contents/Info.plist" "${gTargetDirectory}/${gKextName}.kext/Contents/PlugIns/AppleHDALoader.kext/Contents/"

  #
  # Replace version info with "911.${gScriptVersion}" in AppleHDALoader.kext
  #
  targetFile="${gTargetDirectory}/${gKextName}.kext/Contents/PlugIns/AppleHDALoader.kext/Contents/Info.plist"

  #
  # -c = Execute command and exit.
  #
  /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString 911.${gScriptVersion}" "$targetFile"
  /usr/libexec/PlistBuddy -c "Set :CFBundleVersion 911.${gScriptVersion}" "$targetFile"

  #
  # Copy CodeResources.
  #
  cp -R "${gExtensionsDirectory}/AppleHDA.kext/Contents/PlugIns/DspFuncLib.kext/Contents/_CodeSignature" "${gTargetDirectory}/${gKextName}.kext/Contents/"

  #
  # Fix ownership and permissions.
  #
  _DEBUG_PRINT "Fixing file permissions ...\n"
  chmod -R 755 "${gTargetDirectory}/${gKextName}.kext"

  #
  # Ownership of a file may only be altered by a super-user hence the use of sudo here.
  #
  _DEBUG_PRINT "Fixing file ownership ...\n"
  chown -R root:wheel "${gTargetDirectory}/${gKextName}.kext"

  if [[ "${gTargetDirectory}" != "${gExtensionsDirectory}" ]];
    then
      _DEBUG_PRINT "Checking kext with kextutil ...\n"
      #
      # Check for Yosemite (different kernel path).
      #
      if [[ $gProductVersion =~ "10.10" ]];
        then
          #
          # -q = Quiet mode; print no informational or error messages.
          # -t = Perform all possible tests on the specified kexts.
          # -n = Neither load the kext nor send personalities to the kernel.
          # -k = Link against the given kernel_file.
          #
          kextutil -qtnk /System/Library/Kernels/kernel "${gTargetDirectory}/${gKextName}.kext"
        else
          kextutil -qtnk /mach_kernel "${gTargetDirectory}/${gKextName}.kext"
      fi

      if (($? == 0));
        then
          echo "${gKextName}.kext appears to be loadable (including linkage for on-disk libraries)."

          read -p "Do you want to copy ${gKextName}.kext to: ${gExtensionsDirectory}? (y/n) " choice
          case "$choice" in
            y|Y ) cp -r "${gTargetDirectory}/${gKextName}.kext" "${gExtensionsDirectory}"
                  gTargetDirectory="${gExtensionsDirectory}"

                  if [[ $gProductVersion =~ "10.10" ]];
                    then
                      #
                      # Look for 'kext-dev-mode=1' in com.apple.Boot.com
                      #
                      _checkKernelFlags
                  fi
            ;;
          esac
      fi
  fi

  #
  # Check target directory.
  #
  if [[ "${gTargetDirectory}" == "${gExtensionsDirectory}" ]];
    then
      #
      # Conditionally touch the Extensions directory.
      #
      _DEBUG_PRINT "Triggering a kernelcache refresh ...\n"
      touch "${gExtensionsDirectory}"

      read -p "Do you want to reboot now? (y/n) " choice2
      case "$choice2" in
        y|Y ) reboot now
              ;;
      esac
  fi

  if [[ $gExtraStyling -eq 1 ]];
    then
      printf "${STYLE_BOLD}Done.${STYLE_RESET}\n\n"
    else
      printf "Done.\n\n"
  fi
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
