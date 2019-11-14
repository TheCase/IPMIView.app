**IPMIView (java) App wrapper for MacOS**

Download the latest IPMIView software from SuperMicro:

[git@github.com:TheCase/IPMIView.app.git]()

```
git clone https://github.com/TheCase/IPMIView.app
cd IPMIView.app
mkdir -p Resources/IPMIView
tar -zxvf ~/Downloads/IPMIView*.tar.gz --strip=1 -C ./Resources/IPMIView/.
cd ..
cp -R IPMIView.app ~/Applications
```

