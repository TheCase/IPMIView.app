#!/bin/sh
set -
mkdir -p Contents/Resources/IPMIView/Contents/Home/bin
tar -zxvf ~/Downloads/IPMIView*.tar.gz --strip=1 -C ./Contents/Resources/IPMIView/.
ln -s /usr/bin/java Contents/Resources/IPMIView/Contents/Home/bin/java
cd ..
rsync -arv --exclude=.git --exclude=Contents/Resources/IPMIView/jre IPMIView.app ~/Applications
