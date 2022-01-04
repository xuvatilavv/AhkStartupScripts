An assortment of AutoHotKey v1.1 scripts.

### Special Notes:
 - As a package, `AhkManager.ahk` is the entry point and intended to be added as
a system startup app. All other apps will start when this starts, and be closed
when it closes. You can add or remove scripts from the manager by editing the
`managedApps` array near the top of that file.

 - Most of these scripts have tray icons disabled, if you want to use any of them
without a manager you'll likely want to remove the line `#NoTrayIcon` near the top.

 - `feature_Typography.ahk` requires a Unicode version of AHK.

 - A few scripts are Windows-specific but may be modified for other platforms.

Additional documentation for each script is provided in its comments.

### License:
The included [license](./LICENSE) applies to anything in this repo that was 
written by me (xuvatilavv). There are multiple parts of these scripts that
were sourced from other authors on the AHK forums. These sections are marked
with attribution in comments and retain their original license.
