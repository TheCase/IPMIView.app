#!/bin/bash
set -
if [ "" = "${JAVA_HOME}" ] ; then
  JAVA_HOME=/usr
fi

BASE_URL="https://www.supermicro.com/en/support/resources"
INFO_URL="${BASE_URL}/downloadcenter/smsdownload\?category\=IPMI"
API_URL="https://www.supermicro.com/support/resources/getfile.php?SoftwareItemID=DLID&type=serversoftwarefile"

if which curl >/dev/null; then
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
  ACTUAL_CHECKSUM=$(md5 -r "${LOCAL_DOWNLOAD_LOCATION}"/${DOWNLOAD_FILENAME} | cut -d' ' -f1 | tr -d "[:space:]" | tr '[:upper:]' '[:lower:]')
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

echo "Extracting contents of downloaded IPMIView archive..."
if [[ -d Contents/Resources/IPMIView ]]; then
  rm -rf Contents/Resources/IPMIView
fi
mkdir -p Contents/Resources/IPMIView/Contents/Home/bin
tar -zxf "${LOCAL_DOWNLOAD_LOCATION}"/IPMIView*.tar* --strip=1 -C ./Contents/Resources/IPMIView/. ||
  { echo "Something went wrong, check download of IPMIView archive" && exit 1; }

echo "Linking 'java' and 'jre'..."
ln -s "${JAVA_HOME}/bin/java" Contents/Resources/IPMIView/Contents/Home/bin/java
rm -rf Contents/Resources/IPMIView/jre/*
pushd Contents/Resources/IPMIView/jre/ >/dev/null &&
  ln -s ../Contents . &&
  popd >/dev/null || exit

echo "Copying IPMIView.app over to ~/Applications directory..."
pushd .. >/dev/null &&
  rsync -ar --exclude=.git --exclude=Contents/Resources/IPMIView/jre IPMIView.app ~/Applications &&
  popd >/dev/null || exit

echo "Completed."
echo
echo "You can now open ~/Applications/IPMIView.app"
