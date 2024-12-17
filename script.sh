#!/bin/bash
set -
if [ "" = "${JAVA_HOME}" ] ; then
  JAVA_HOME=/usr
fi

BASE_URL="https://www.supermicro.com/en/support/resources"
INFO_URL="${BASE_URL}/downloadcenter/smsdownload\?category\=IPMI"
API_URL="https://www.supermicro.com/support/resources/getfile.php?SoftwareItemID=DLID&type=serversoftwarefile"

if which curl >/dev/null; then
  echo "Detecting current SuperMicro software versions..."
  # this area is subject to problems if SuperMicro changes their page format
  DL_ID=$(curl -s ${INFO_URL} | grep "data-sms-name=\"Linux\".*sms_radio_buttons_IPMIView" | cut -d"'" -f4)
  DL_URL=$(echo $API_URL | sed "s/DLID/${DL_ID}/")
  DOWNLOAD_URL=$(curl -s -i ${DL_URL} | grep 'location' | awk -F': ' '{print $2}' | tr -d '[:space:]')
  CHECKSUM_URL=$(dirname "${DOWNLOAD_URL}")/CheckSum.txt
  DOWNLOAD_FILENAME=$(basename "${DOWNLOAD_URL}")
  if [ -z ${DOWNLOAD_FILENAME} ]; then
    echo "[WARNING!] Problem parsing latest version..."
    echo "Falling back to last known version."
    echo "Please file an issue at https://github.com/TheCase/IPMIView.app/issues regarding latest version discovery."
    DOWNLOAD_FILENAME="IPMIView_2.21.1_build.230720_bundleJRE_Linux_x64.tar.gz"
  fi

  LOCAL_DOWNLOAD_LOCATION="./SM_download"
 
  # if LOCAL_DOWNLOAD_LOCATION doesn't exist, create it
  if [ ! -d "${LOCAL_DOWNLOAD_LOCATION}" ]; then
    mkdir -p ${LOCAL_DOWNLOAD_LOCATION}
  fi 

  echo "Downloading CheckSum.txt [${CHECKSUM_URL}]"
  if [ -f "${LOCAL_DOWNLOAD_LOCATION}/CheckSum.txt" ]; then
    read -p "Checksum file exists. Overwrite existing file? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      echo ok, skipping download...
      echo
      SKIP=1 
    fi
  fi
  if [ -z $SKIP ]; then
    curl --progress-bar -o ${LOCAL_DOWNLOAD_LOCATION}/CheckSum.txt ${CHECKSUM_URL}
  fi
  unset SKIP

  echo "Downloading latest version of IPMIView [${DOWNLOAD_URL}]"
  if [ -f "${LOCAL_DOWNLOAD_LOCATION}/${DOWNLOAD_FILENAME}" ]; then
    read -p "Application file exists. Overwrite existing file? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      echo ok, skipping download...
      echo
      SKIP=1 
    fi
  fi 
  if [ -z $SKIP ]; then
    curl --progress-bar -o ${LOCAL_DOWNLOAD_LOCATION}/${DOWNLOAD_FILENAME} ${DOWNLOAD_URL}
  fi

  # Check MD5
  EXPECTED_CHECKSUM=$(\grep -A3 "tar.gz" "${LOCAL_DOWNLOAD_LOCATION}/CheckSum.txt" | grep MD5 | cut -d':' -f2 | tr -d "[:space:]" | tr '[:upper:]' '[:lower:]')
  ACTUAL_CHECKSUM=$(md5sum "${LOCAL_DOWNLOAD_LOCATION}"/${DOWNLOAD_FILENAME} | cut -d' ' -f1 | tr -d "[:space:]" | tr '[:upper:]' '[:lower:]')
  if ! diff <(echo "${EXPECTED_CHECKSUM}") <(echo "${ACTUAL_CHECKSUM}"); then
    echo "Checksum is not as expected; download may be corrupted."
    echo "Expected: [${EXPECTED_CHECKSUM}]"
    echo "Actual:   [${ACTUAL_CHECKSUM}]"
    echo "Exiting."
    exit 1
  fi

else
  echo "WARNING: 'curl' command not found."
  echo
  echo "Please visit ${DOWNLOAD_URL} to download the latest version of IPMIView and copy the archive into $(pwd)/${LOCAL_DOWNLOAD_LOCATION}/"
  echo
  # shellcheck disable=SC2034,SC2162
  echo "Press [Enter] to continue" && read answer
fi

echo "Using Java from $JAVA_HOME"
arch=$( arch )
if [ "$arch" = "x86_64" ] ; then
  echo "Okay, using x86-64 platform."
elif [ "$arch" = "arm64" -o "$arch" = "aarch64" ] ; then
  echo "Using aarm64 platform. Checking Java version..."

  if [ -x "$JAVA_HOME/bin/javac" ] ; then
    if [ ! -f PropertyPrint.class ] ; then
      "$JAVA_HOME/bin/javac" -target 1.8 PropertyPrint.java
    fi
  else
    echo "Cannot determine Java architecture because you do not have a JDK installed."

    exit 1
  fi

  jarch=$( $JAVA_HOME/bin/java -classpath . PropertyPrint os.arch )

  if [ "x86_64" != "$jarch" ] ; then
    echo "*"
    echo "* This application bundle requires on x86-64 Java Runtime Environment (JRE/JDK)"
    echo "*"
    echo "* Java platform is $jarch for JAVA_HOME=$JAVA_HOME. Set JAVA_HOME to an x86-64 JRE and run this script again."
    echo "*"

    if arch -x86_64 /usr/bin/true 2> /dev/null; then
      echo "Rosetta 2 appears to be installed, so you will already be able to run the x86-64 JRE/JDK."
    else
      echo "You may also need to install Rosetta 2 to run an x86-64 Java Runtime Environment."
    fi

    echo
    echo "IPMIView.app was not built. Please read the messages above."

    exit 1
  else
    echo "Java platform is $jarch for JAVA_HOME=$JAVA_HOME"
  fi
else
  echo "Unsupported platform: $arch"
  exit 1
fi

echo "Building IPMIView.app..."
if [ -f IPMIView.app/Contents/Resources/IPMIView/IPMIView.properties ] ; then
  echo "Saving configuration properties IPMIView.app/Contents/Resources/IPMIView/IPMIView.properties"
  cp -a IPMIView.app/Contents/Resources/IPMIView/IPMIView.properties ./IPMIView.properties.tmp ||
    { echo "Failed to save IPMIView.properties. Exiting."; exit 1; }
fi
rm -rf IPMIView.app
mkdir IPMIView.app
cp -a README.md Contents IPMIView.app/
mkdir -p IPMIView.app/Contents/Resources/IPMIView/Contents/Home/bin
tar -zxf "${LOCAL_DOWNLOAD_LOCATION}"/IPMIView*.tar* --strip=1 --exclude='*/jre/*' -C IPMIView.app/Contents/Resources/IPMIView/. ||
  { echo "Something went wrong, check download of IPMIView archive" && exit 1; }
ln -s "${JAVA_HOME}/bin/java" IPMIView.app/Contents/Resources/IPMIView/Contents/Home/bin/java
if [ -f IPMIView.properties.tmp ] ; then
  echo "Restoring IPMIView.app/Contents/Resources/IPMIView/IPMIView.properties"
  cp -a IPMIView.properties.tmp IPMIView.app/Contents/Resources/IPMIView/IPMIView.properties ||
    { echo "Failed to restore IPMIView.properties. Exiting."; exit 1; }

  rm IPMIView.properties.tmp
fi

echo "Completed."
echo
echo "You can now open ./IPMIView.app or copy it into ~/Applications"
