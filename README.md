# IPMIView (java) App wrapper for MacOS

## Quick Start

```bash
cd ~
git clone https://github.com/TheCase/IPMIView.app
cd IPMIView.app
bash script.sh
```

You should now have an application icon in your home directory's Applications (aka `~/Applications`) folder.

For some versions of macOS, you may also need to add a security exception for `java`; see [Using the KVM Console](#using-the-kvm-console) for details.

## Details

Running the commands in the [Quick Start](#quick-start) section above will automatically:

1) Clone this repository
2) Run the containing `script.sh`
    1) Download the needed files from SuperMicro's website
    2) Verify the downloaded files
    3) Extract and make the needed modifications to run on macOS
    4) Install the application to `~/Applications/IPMIView.app`

### Download Information

The script in this repo downloads files from SuperMicro's website located at: https://www.supermicro.com/wdl/utility/IPMIView/Linux/

### Using the KVM Console

You need to add an `Input Monitoring` exception for `java` in the `Security & Privacy -> Privacy` Tab in `System Preferences`:

- Open `System Preferences`
- Click on `Security & Privacy`
- Click the `Privacy` tab
- Scroll down to `Input Monitoring` (you may need to click the lock in the lower left and enter your password to add a new item)
- Click the plus `+` symbol
- In the top of the new window, select `Macintosh HD` in the pulldown `Library -> Java -> JavaVirtualMachines -> jdk<version>.jdk -> bin -> Contents -> Home -> bin`
- Double click on `java`
- Make sure the box next to `java` is now checked and close the window

When you attempt to launch the console, you may be presented with a message that says the developer is not verified. DO NOT click "Move to Trash" - this will delete the files necessary to run the graphical console. Once you get this message:

- Open `System Preferences` -> `Security & Privacy` -> `General` Tab and click `Allow Anyway` next to the message about the jnlilib that was blocked.
- At this point you can try the `Launch KVM Console` button. You should be presented with another dialog about developer verification. Click the `Open` button.
- This will trigger another denial window for the sharedLibs jnlilib. Repeat the approval process for this next jnlilib in the `Security Preference` Pane.
- After performing these two approvals, the console should open.

## Troubleshooting

If you have Java issues loading the app, please verify that you can run the app from the command line (and outside the jursdiction of this supplied wrapper).

```bash
cd ~/Applications/IPMIView.app/Contents/Resources/IPMIView/
java -jar IPMIView20.jar
```

If you have issues with IMPIView loading correctly with this method, please contact SuperMicro support. The problem is related to the app and your computer setup, not the wrapper.

## KVM Color Issues on X9 Boards
The KVM console may display incorrect colors on older X9 series boards. This is a known issue with newer versions of IPMIView [1,2,3] and looks something like this:

<img width="30%" alt="Screenshot 2024-10-18 at 14 24 21" src="https://github.com/user-attachments/assets/58c6b4a3-a71b-40d4-b561-027e2c6ec33d">

**Note:** This fix can potentially break some features like Virtual Media or compatibility with newer boards [2,4] so it's advised to avoid doing this unless you can live without those or you're sure you don't experience those issues. 

Perform the following steps *after IPMIView has been installed in the Applications folder*:
1. Download `https://<BMC_IP>/libmac_x86_64__V1.0.5.jar.pack.gz` where `<BMC_IP>` should be replaced with the specific IP of your server's BMC. The exact version may depend on your BMC firmware version (e.g. V1.0.5 was found on IPMI firmware 3.36). 
2. Unpack the downloaded file with `unpack200`, e.g. `unpack200 libmac_x86_64__V1.0.5.jar.pack.gz libmac.jar`
3. Extract the files using `jar xf libmac.jar` which will create 
`libiKVM64.jnilib`, `libSharedLibrary64.jnilib`, and a folder called `META-INF`. The folder can be safely disregarded.
4. Move both `jnilib` files to `Contents/Resources/IPMIView` within `IPMIView.app`, overwriting existing files. Right-click the app, and click "Show Contents" to navigate to the inner directories. This should be done to the app in `~/Applications` after already running `script.sh`.
5. Re-launch IPMIView, open the KVM Console, and the colors should be fixed.

The same boot screen after the fix: 

<img width="30%" alt="Screenshot 2024-10-18 at 14 58 29" src="https://github.com/user-attachments/assets/bb62c58d-0386-4cb8-b755-e6f1c84deef1">

[1] [https://forums.servethehome.com/index.php?threads/ipmi-viewer-kvm-console-color-issue.27138/](https://forums.servethehome.com/index.php?threads/ipmi-viewer-kvm-console-color-issue.27138/)

[2] [https://old.reddit.com/r/simonheros/comments/mysmqe/fix_x9dr_supermicro_ipmi_colors_broken_glitched/](https://old.reddit.com/r/simonheros/comments/mysmqe/fix_x9dr_supermicro_ipmi_colors_broken_glitched/)

[3] [https://www.supermicro.com/support/faqs/faq.cfm?faq=32333](https://www.supermicro.com/support/faqs/faq.cfm?faq=32333)

[4] [https://tech.arantius.com/dont-fix-the-colors-in-supermicro-ipmiview](https://tech.arantius.com/dont-fix-the-colors-in-supermicro-ipmiview)
