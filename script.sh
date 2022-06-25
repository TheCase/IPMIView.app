#!/bin/bash
set -

DOWNLOAD_URL="https://www.supermicro.com/wdl/utility/IPMIView/Linux/"
LOCAL_DOWNLOAD_LOCATION="./SM_download"

if which wget >/dev/null; then
  echo "Downloading latest version of IPMIView from [${DOWNLOAD_URL}]..."
  wget \
    --timestamping \
    --recursive \
    --level=1 \
    -q \
    --show-progress \
    --directory-prefix="${LOCAL_DOWNLOAD_LOCATION}/" \
    --no-parent \
    --no-directories \
    --reject index.html,index.html.tmp,robots.txt,robots.txt.tmp \
    "${DOWNLOAD_URL}"
  rm "${LOCAL_DOWNLOAD_LOCATION}/"robots.txt*

  # Check MD5
  EXPECTED_MD5=$(\grep MD5 "${LOCAL_DOWNLOAD_LOCATION}/CheckSum.txt" | cut -d':' -f2 | tr -d "[:space:]" | tr '[:upper:]' '[:lower:]')
  ACTUAL_MD5=$(md5sum "${LOCAL_DOWNLOAD_LOCATION}"/IPMIView*.tar* | cut -d' ' -f1 | tr -d "[:space:]" | tr '[:upper:]' '[:lower:]')
  if ! diff <(echo "${EXPECTED_MD5}") <(echo "${ACTUAL_MD5}"); then
    echo "MD5 is not as expected; download corrupted."
    echo "Expected: [${EXPECTED_MD5}]"
    echo "Actual:   [${ACTUAL_MD5}]"
    echo "Exiting."
    exit 1
  fi

  # Check SHA-256
  EXPECTED_SHA256=$(\grep MD5 "${LOCAL_DOWNLOAD_LOCATION}/CheckSum.txt" | cut -d':' -f2 | tr -d "[:space:]" | tr '[:upper:]' '[:lower:]')
  ACTUAL_SHA256=$(md5sum "${LOCAL_DOWNLOAD_LOCATION}"/IPMIView*.tar* | cut -d' ' -f1 | tr -d "[:space:]" | tr '[:upper:]' '[:lower:]')
  if ! diff <(echo "${EXPECTED_SHA256}") <(echo "${ACTUAL_SHA256}"); then
    echo "SHA-256 is not as expected; download corrupted."
    echo "Expected: [${EXPECTED_SHA256}]"
    echo "Actual:   [${ACTUAL_SHA256}]"
    echo "Exiting."
    exit 1
  fi

else
  echo "WARNING: 'wget' CLI not found."
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
ln -s /usr/bin/java Contents/Resources/IPMIView/Contents/Home/bin/java
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
