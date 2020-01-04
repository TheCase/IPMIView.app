#!/bin/sh
set -
mkdir -p Resources/IPMIView/Contents/Home/bin
tar -zxvf ~/Downloads/IPMIView*.tar.gz --strip=1 -C ./Resources/IPMIView/.
cd Resources/IPMIView/Contents/Home/bin
ln -s /usr/bin/java
cd ../../../../../..
rsync -arv --exclude=.git --exclude=Resources/IPMIView/jre IPMIView.app ~/Applications 
