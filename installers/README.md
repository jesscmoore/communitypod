<!-- markdownlint-disable MD013 -->

# communitypod Installers

Flutter supports multiple platform targets. Flutter based apps can run
native on Android, iOS, Linux, MacOS, and Windows, as well as directly
in a browser from the web. Flutter functionality is essentially
identical across all platforms so the experience across different
platforms will be very similar.

Visit the
[CHANGELOG](https://github.com/anusii/communitypod/blob/dev/CHANGELOG.md)
for the latest updates.

Run the app online: [**web**](https://communitypod.solidcommunity.au).

Download the latest version:
**GNU/Linux**
[deb](https://solidcommunity.au/installers/communitypod_amd64.deb) or
[zip](https://solidcommunity.au/installers/communitypod-linux.zip);
**Android**
[apk](https://solidcommunity.au/installers/communitypod.apk);
**macOS**
[dmg](https://solidcommunity.au/installers/communitypod-macos-unsigned.dmg);
**Windows**
[zip](https://solidcommunity.au/installers/communitypod-windows.zip) or
[inno](https://solidcommunity.au/installers/communitypod-windows-inno.exe).

## Prerequisite

There are no specific prerequisites for installing and running
communitypod.

## Android

You can side load the latest version of the app by downloading the
[installer](https://solidcommunity.au/installers/communitypod.apk) through
your Android device's browser. This will download the app to your
Android device. Then visit the Downloads folder where you can click on
the `communitypod.apk` file. Your browser will ask if you are okay with
installing the app locally.

## Linux

### Deb Install for Debian/Ubuntu

Download and install the deb package:

```bash
wget https://solidcommunity.au/installers/communitypod_amd64.dev -O communitypod_amd64.deb
sudo dpkg --install communitypod_amd64.deb
```

### Zip Install

Download [communitypod-linux.zip](https://solidcommunity.au/installers/communitypod-linux.zip)

To try it out:

```bash
wget https://solidcommunity.au/installers/communitypod-linux.zip -O communitypod-linux.zip
unzip communitypod-linux.zip -d communitypod
./communitypod/communitypod
```

To install for the local user and to make it known to GNOME and KDE,
with a desktop icon for their desktop, begin by downloading the **zip** and
installing that into a local folder:

```bash
unzip communitypod-linux.zip -d ${HOME}/.local/share/communitypod
```

Then set up your local installation (only required once):

```bash
ln -s ${HOME}/.local/share/communitypod/communitypod ${HOME}/.local/bin/
wget https://raw.githubusercontent.com/anusii/communitypod/dev/installers/app.desktop -O ${HOME}/.local/share/applications/communitypod.desktop
sed -i "s/USER/$(whoami)/g" ${HOME}/.local/share/applications/communitypod.desktop
mkdir -p ${HOME}/.local/share/icons/hicolor/256x256/apps/
wget https://github.com/anusii/communitypod/raw/dev/installers/app.png -O ${HOME}/.local/share/icons/hicolor/256x256/apps/communitypod.png
```

To install for any user on the computer:

```bash
sudo unzip communitypod-linux.zip -d /opt/communitypod
sudo ln -s /opt/communitypod/communitypod /usr/local/bin/
wget https://raw.githubusercontent.com/anusii/communitypod/dev/installers/app.desktop -O ${HOME}/usr/local/share/applications/communitypod.desktop
wget https://github.com/anusii/communitypod/raw/dev/installers/app.png -O ${HOME}/use/local/share/icons/communitypod.png
```

Once installed you can run the app from the GNOME desktop through
Alt-F2 and type `communitypod` then Enter.

## MacOS

The zip file
[communitypod-macos-unsigned.zip](https://solidcommunity.au/installers/communitypod-macos-unsigned.zip)
can be installed on MacOS. Download the file and open it on your
Mac. Then, holding the Control key click on the app icon to display a
menu. Choose `Open`. Then accept the warning to then run the app. The
app should then run without the warning next time.

## Web -- No Installation Required

No installer is required for a browser based experience of
communitypod. Simply visit
[https://communitypod.solidcommunity.au](https://communitypod.solidcommunity.au).

Also, your Web browser will provide an option in its menus to install
the app locally, which can add an icon to your home screen to start
the web-based app directly.

## Windows Installer

Download and run the self extracting archive
[communitypod-windows-inno.exe](https://solidcommunity.au/installers/communitypod-windows-inno.exe)
to self install the app on Windows.
