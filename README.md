### IPMIView (java) App wrapper for MacOS**
 
Download the latest IPMIView software from SuperMicro:

[https://ftp.supermicro.com/wftp/utility/IPMIView/Linux/](https://ftp.supermicro.com/wftp/utility/IPMIView/Linux/)

```
git clone https://github.com/TheCase/IPMIView.app
cd IPMIView.app
mkdir -p Resources/IPMIView
tar -zxvf ~/Downloads/IPMIView*.tar.gz --strip=1 -C ./Resources/IPMIView/.
cd ..
cp -R IPMIView.app ~/Applications
```


### Troublueshooting

If you have Java issues loading the app, please verify that you can run the app from the command line (and outside the jursdiction of this supplied wrapper).

```
cd ~/Applications/IPMIView.app/Resources/IPMIView/
java -jar IPMIView20.jar
```

If you have issues with IMPIView loading correctly with this method, please contact SuperMicro support. The problem is related to the app and your computer setup, not the wrapper.
