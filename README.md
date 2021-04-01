**ARCHIVED**.  I no longer have systems that require this tool.  If you would like to take over management of this project, let me know and I can transfer ownership.

### IPMIView (java) App wrapper for MacOS**

Download the latest IPMIView software from SuperMicro (to your home directories "Downloads" folder, aka `~/Downloads`:

[https://ftp.supermicro.com/wftp/utility/IPMIView/Linux/](https://ftp.supermicro.com/wftp/utility/IPMIView/Linux/)

Download the code and execute the script to unarchive the linux package and create the Application Bundle:
```bash
cd ~
git clone https://github.com/TheCase/IPMIView.app
cd IPMIView.app
sh script.sh
```

You should now have an application icon in your home directory's Applications (aka `~/Applications`) folder.

#### Using the KVM Console

You need to add an `Input Monitoring` exception for `java` in the `Security & Privacy` -\> `Privacy` Tab in `System Preferences`:

- Open `System Preferences`
- Click on `Security & Privacy`
- Click the `Privacy` button/tab
- Scroll down to `Input Monitoring`
(you may need to click the lock in the lower left and enter your password to add a new item)
- Click the plus `+` symbol
- In the top of the new window, select MacintoshHD in the pulldown
Library -> Java -> JavaVirtualMachines -> jdk\<version\>.jdk -> bin -> Contents -> Home -> bin
- Double click on `java`
- Make sure the box next to `java` is now checked and close the window

When you attempt to launch the console, you may be presented with a message that says the developer is not verified.  DO NOT click "Move to Trash" - this will  delete the files necessary to run the graphical console.  Once you get this message:

- Open `System Preferences` -> `Security & Privacy` -> `General` Tab and click `Allow Anyway` next to the message about the jnlilib that was blocked.
- At this point you can try the `Launch KVM Console` button. You should be presented with another dialog about developer verification. Click the `Open` button.
- This will trigger another denial window for the sharedLibs jnlilib. Repeat the approval process for this next jnlilib in the `Security Preference` Pane.
- After performing these two approvals, the console should open.


### Troubleshooting

If you have Java issues loading the app, please verify that you can run the app from the command line (and outside the jursdiction of this supplied wrapper).

```bash
cd ~/Applications/IPMIView.app/Contents/Resources/IPMIView/
java -jar IPMIView20.jar
```

If you have issues with IMPIView loading correctly with this method, please contact SuperMicro support. The problem is related to the app and your computer setup, not the wrapper.
