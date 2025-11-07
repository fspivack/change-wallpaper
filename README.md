# Change Wallpaper

A script to change the wallpaper in a Linux desktop environment by looping through your chosen wallpapers.

The aim of this script is so that you can go to the "next" wallpaper at the click of a button. The original purpose was to toggle between "work" and "non-work" wallpapers, so as to have a different environment for work and leisure.

Supported desktop environments are:
- GNOME
- MATE
- Cinnamon
- Unity
- KDE Plasma
- LXQt
- LXDE
      
It's been tested on all of these, apart from Unity. It's likely also compatible with Unity.

## Usage

### Run the set-up script

You first navigate to the change-wallpaper directory, and run
```bash
./cwp-setup.sh`
```
 This does two things:
1. Creates the config file. It usually puts it in `$HOME/.config/change-wallpaper`, but it'll tell you where it put it.
2. Creates an item in the Application menu.

### Edit your config file

The config file is:
```bash
#!/bin/bash

# WALLPAPERS=(
#     \"$HOME/Pictures/nonwork.jpg\"
#     \"$HOME/Pictures/work.jpg\"
#     \"$HOME/Pictures/third-wp.jpg\"
# )
```

You should uncomment the WALLPAPERS variable (i.e. all lines apart from `#!/bin/bash`), and replace the file paths with the paths to your own wallpaper files.

### Add the launcher to the panel

For one-click usage (so that you can cycle through your  wallpapers with one click), you will want to pin the application to the panel. How to do this depends on your desktop environment. See below for details per desktop environment. In all cases you will have to first find `change-wallpaper` in the applications menu. (Note that you may have to reboot between running `cwp-setup.sh` and being able to find the program in the Applications menu.)

#### GNOME

Right-click `change-wallpaper` and select **"Add to Favourites"**.

#### MATE

Right-click and select **"Add this launcher to panel"**.

#### Cinnamon

Right-click and select **"Add to panel"**.

#### KDE Plasma

Right-click and select **"Add to Panel (Widget)"**.

#### Xfce

Click the `change-wallpaper` item in the menu and drag it to the far left or right hand side of the panel. It will ask you if you want to: **"Create new launcher from 1 desktop file"** (or something similar). You should then click **"Create launcher"**.

If you have trouble "grabbing" the menu item, make sure you're clicking on the icon.

#### LXQt

Similarly, click the `change-wallpaper` item in the menu and drag it to the far left or right hand side of the panel. This should create a launcher with "Quick Launch".

#### LXDE

Similarly again, click the `change-wallpaper` item in the menu and drag it to the far left or right hand side of the panel.

If, every time you click to launch the program, it asks you whether you want to execute it, and you want to switch off this behaviour so that it just takes one click to change wallpaper, you can:

1. Open the File Manager 
2. Go to the menu: **Edit** then **Preferences**
3. In the Preferences window, select the **General** tab
4. Look for the setting: **"Don't ask options on launch executable file"** (or similar).
5. Check this box.

### Removing the program

If you want to remove the program from the applications menu, navigate to the change-wallpaper directory, and run:
```bash
./cwp-remove.sh
```

This will remove the .desktop file, so the program won't appear in Applications, and also remove the directory containing the state file for the program.

If you had pinned it to the panel, it may or may not remove it automatically. If it doesn't, you'll probably want to remove it manually.

You may also want to remove the directory containing the config file. `cwp-remove.sh` should tell you the location of this directory, although it's usually in `$HOME/.config/change-wallpaper`.

## License

This project is licensed under the [MIT License](LICENSE).
