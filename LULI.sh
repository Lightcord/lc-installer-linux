#!/bin/sh
# Lightcord unified Linux installer by https://github.com/GermanBread
# POSIX compliance by https://github.com/pryme-svg

#
#	CHANGE STUFF HERE
#

# If set to anything other than "false" this will allow you to modify the Lightcord installation even if it was
if [ -z $BYPASS_PACKAGEMANAGER ]; then
    BYPASS_PACKAGEMANAGER='false'
fi

# Make sure to trim the trailing forward-slash (/)
if [ -z $GLOBAL_INSTALL_DIR ]; then
    GLOBAL_INSTALL_DIR='/opt'
fi
if [ -z $LOCAL_INSTALL_DIR ]; then
    LOCAL_INSTALL_DIR="$HOME/.lightcord"
fi

#
#	DON'T TOUCH BELOW HERE
#

# URL for downloads
ICON='https://raw.githubusercontent.com/Lightcord/Lightcord/master/discord.png'
LC_APPIMAGE='https://lightcord.org/api/gh/releases/Lightcord/Lightcord/dev/lightcord-linux-x86_64.AppImage'
LC='https://lightcord.org/api/v1/gh/releases/Lightcord/Lightcord/dev/lightcord-linux-x64.zip'
# Fallback URL
ALT_LC_APPIMAGE='https://github.com/Lightcord/Lightcord/releases/latest/download/Lightcord-linux-x86_64.AppImage'
ALT_LC='https://github.com/Lightcord/Lightcord/releases/latest/download/lightcord-linux-x64.zip'

# Some helper funtions
Download() {
	wget --progress=dot -O $1 $2 2>&1 | grep --line-buffered "%" | \
		sed -u -e "s,\.,,g" | stdbuf -o0 awk '{print substr($2, 1, length($2)-1)}'  | while read r; do ProgressBar $r; done
}
ProgressBar() {
	_progress=$(((${1}*100/100*100)/100))
	_done=$((($_progress*4)/10))
	_left=$((40-$_done))
	# Build progressbar string lengths
	_done=$(printf "%${_done}s" ' ' | tr ' ' "#")
	_left=$(printf "%${_left}s" ' ' | tr ' ' "-")
	if [ $_progress = 100 ]; then _left=""; fi # dumb $(()) quirks

	tput setaf 2
	printf "\r[${_done}${_left}] ${_progress}%% "
	if [ $_progress = 100 ]; then printf "\n"; fi
	tput setaf sgr0
	#printf "\rProgress : [${_done// /#}${_left// /-}] ${_progress}%%"
}
Info() {
    tput setaf 8
    tput bold
    printf "==> "
    tput setaf 15
    printf "$1\n"
    tput sgr0
}
SubInfo() {
    tput setaf 8
    printf "> "
    printf "$1\n"
    tput sgr0
}
Warning() {
    tput setaf 3
    tput bold
    printf "==> "
    tput setaf 11
    printf "$1\n"
    tput sgr0
}
Error() {
    tput setaf 1
    tput bold
    printf "==> "
    tput setaf 9
    printf "$1\n"
    tput sgr0
}

if [ "$TERM" = dumb ]; then
    exit 0
fi

if [ $(id -u) -eq 0 ]; then
    Error "Don't run this script as root"
    exit 0
fi

# Bedrock Linux warning
if [ -d /bedrock ]; then
    Info "Bedrock Linux detected. Here be dragons..."
    SubInfo "This script is executed in the$(tput bold && tput setaf 15) $(brl which | tr -d '\n') stratum$(tput sgr0 && tput setaf 8). Mention this when filing a bug report!"
fi

# Check if unzip is installed
if [ ! -e /bin/unzip ]; then
    Warning "Unzip does not seem to be installed!\n\tThis script depends on this package.\n\tInstall unzip and restart this script."
    Info "Press enter if you believe that this is a false-positive."
    read -r REPLY
fi

# Same for wget
if [ ! -e /bin/wget ]; then
    Warning "Wget does not seem to be installed!\n\tThis script depends on this package.\n\tInstall wget and restart this script."
    Info "Press enter if you believe that this is a false-positive."
    read -r REPLY
fi

# Library checks (should prevent issues like https://github.com/Lightcord/Lightcord/issues/240)
if [ ! -e /lib/libnspr4.so ] || [ ! -e /lib/libnss3.so ]; then
    Warning "Some required libraries seem to not be installed!\n\tMake sure that both 'libnspr4.so' and 'libnss3.so' are present in '/lib'"
    if [ -e /bin/pacman ]; then
        SubInfo "$(tput setaf 12 && tput bold)Arch Linux or Arch-based$(tput sgr0 && tput setaf 15) sudo pacman -S nss nspr"
    fi
    if [ -e /bin/apt ]; then
        SubInfo "$(tput setaf 13 && tput bold)Debian or Debian-based$(tput sgr0 && tput setaf 15) sudo apt install libnspr4 libnss3"
    fi
    Info "Press enter if you believe that this is a false-positive."
    read -r REPLY
fi

tput setaf 3
tput bold
cat << "logo_end"
  _    _      _   _                 _
 | |  (_)__ _| |_| |_ __ ___ _ _ __| |
 | |__| / _` | ' \  _/ _/ _ \ '_/ _` |
 |____|_\__, |_||_\__\__\___/_| \__,_|
        |___/
logo_end
tput sgr0

tput setaf 2
printf "  Unified Linux Installer and Updater\n"
tput sgr0

printf "    Written with $(tput setaf 1 && tput bold && tput blink)<3$(tput sgr0) by $(tput bold)pryme-svg$(tput sgr0) and $(tput bold)GermanBread$(tput sgr0)\n\n"

# First, we need to figure out what kind of install the user wants (AppImage or System-wide?)
printf "Please select\n"
printf "1: Install Lightcord for all users\n"
printf "2: Install Lightcord only for you (Appimage install)\n"
printf "\n"

#Repeat only if the user hasn't entered an integer...
while ! echo $method | grep -Eq "^[0-9]";
do
    read -r method;
    # If the entered value was not an integer, prompt the user again
    if ! echo $method | grep -Eq "^[0-9]"; then
        sleep 1
        printf "$(tput setaf 9)Please try again$(tput sgr0)\n"
        printf "1: Install Lightcord for all users\n"
        printf "2: Install Lightcord only for you (Appimage install)\n"
        printf "\n"
    fi
done

if [ "$method" = 1 ]; then
    # Display a small warning for NixOS
    if [ -d "/nix" ]; then
        Warning "Warning: NixOS handles packages differently, you should use the AppImage install method to prevent any breakage of Lightcord.\n\tIf you insist on installing Lightcord globally, continue."
    fi
    
    # If there isn't a indicator file present, refuse to continue
    if { [ -d /opt/lightcord ] || [ -d /opt/Lightcord ]; } && [ ! -e $GLOBAL_INSTALL_DIR/Lightcord/script_check ] && [ $BYPASS_PACKAGEMANAGER = 'false' ]; then
        Error "Lightcord has been installed via a package manager; refusing to continue.\n\tRelaunch the installer with the environment variable BYPASS_PACKAGEMANAGER set to TRUE if you believe that this is a false positive"
        exit 1
    fi

    # Unsure if we're going to keep this. I need to test if NixOS actually wipes /opt
    Warning "Warning:\n\tBlindly running software as root is a massive security issue.\n\tIf you don't fully trust the software you're running DON'T RUN IT AS ROOT.\n\tIf you know exactly what you are doing, continue.\n\tOtherwise restart this script and choose the second option."
    
    Info "Please enter your password to proceed"
    sudo -K
    if [ "$(sudo whoami)" != "root" ]; then
        Error "Authentication failed"
        exit
    fi
    Info "Authentication complete"
fi

case $method in
    1)
    #Standard installer
    tput setaf 208
    printf "Please select\n"
    printf "1: Install Lightcord\n"
    printf "2: Uninstall Lightcord\n"
    printf "3: Update Lightcord\n"
    printf "\n"
    tput sgr0

    #Repeat only if the user hasn't entered an integer...
    while ! echo $selection | grep -Eq "^[0-9]";
    do
        read -r selection;
        # If the entered value was not an integer, prompt the user again
        if ! echo $selection | grep -Eq "^[0-9]"; then
            sleep 1;
            tput setaf 9
            printf "Please try again\n";
            tput setaf 208
            printf "1: Install Lightcord\n";
            printf "2: Uninstall Lightcord\n";
            printf "3: Update Lightcord\n"
            printf "\n";
            tput sgr0
        fi
    done

    case $selection in
        1) # Install LC
        Info "Installing Lightcord"
        SubInfo "Preparing"
        rm -rf Lightcord.*;
        rm -rf Lightcord;
        rm -rf lightcord-linux-x64.*;
        SubInfo "Downloading Lightcord"
        Download lightcord-linux-x64.zip $LC;
        if [ ! $? ]; then
            SubInfo "Trying alternate URL"
            Download lightcord-linux-x64.zip $ALT_LC;
        fi
        unzip -qq lightcord-linux-x64.zip -d Lightcord;
        cd Lightcord;
        chmod +x ./lightcord;
        cd ..;
        sudo mv Lightcord/ $GLOBAL_INSTALL_DIR;
        SubInfo "Downloading Lightcord icon"
        Download lightcord.png $ICON;
        sudo mkdir -p /usr/share/pixmaps;
        sudo mv lightcord.png /usr/share/pixmaps;
        SubInfo "Creating Desktop entry"
        printf "[Desktop Entry]\nName=Lightcord\nComment[fr_FR]=Un client Discord simple et personalisable\nComment=A simple - customizable - Discord Client\nExec=$GLOBAL_INSTALL_DIR/Lightcord/lightcord\nIcon=lightcord\nTerminal=false\nType=Application\nCategories=Network;InstantMessaging;P2P;" > Lightcord.desktop
        sudo mv Lightcord.desktop /usr/share/applications/Lightcord.desktop
        sudo chmod +x /usr/share/applications/Lightcord.desktop;
        SubInfo "Cleaning up"
        rm -rf Lightcord.*;
        rm -rf Lightcord;
        rm -rf lightcord-linux-x64.*;
        sudo touch $GLOBAL_INSTALL_DIR/Lightcord/script_check
        ;;

        2) # Uninstall LC
        Info "Uninstalling Lightcord"
        SubInfo "Deleting Lightcord folder"
        sudo rm -r $GLOBAL_INSTALL_DIR/Lightcord;
        SubInfo "Deleting Lightcord icon"
        sudo rm /usr/share/pixmaps/lightcord.png;
        SubInfo "Deleting Desktop entry"
        sudo rm /usr/share/applications/Lightcord.desktop;
        sudo rm -f /home/*/.local/share/applications/Lightcord.desktop;
        ;;

        3) # Update LC
        Info 'Updating Lightcord'
        SubInfo "Preparing"
        rm -rf Lightcord.*;
        rm -rf Lightcord;
        rm -rf lightcord-linux-x64.*;
        SubInfo "Deleting Lightcord"
        sudo rm -r $GLOBAL_INSTALL_DIR/Lightcord;
        SubInfo "Downloading Lightcord"
        Download lightcord-linux-x64.zip $LC;
        if [ ! $? ]; then
            SubInfo "Trying alternate URL"
            Download lightcord-linux-x64.zip $ALT_LC;
        fi
        unzip -qq lightcord-linux-x64.zip -d Lightcord;
        cd Lightcord;
        chmod +x ./lightcord;
        cd ..;
        sudo mv Lightcord/ $GLOBAL_INSTALL_DIR;
        SubInfo "Cleaning up"
        rm -rf Lightcord.*;
        rm -rf Lightcord;
        rm -rf lightcord-linux-x64.*;
        sudo touch $GLOBAL_INSTALL_DIR/Lightcord/script_check
        ;;

        *) # Do nothing
        Error 'Aborting install'
        ;;
    esac
    ;;

    2)
    # Appimage installer
    if [ "$TERM" = dumb ]; then
        exit;
    fi

    tput setaf 208
    printf "Please select\n";
    printf "1: Install Lightcord\n";
    printf "2: Uninstall Lightcord\n";
    printf "3: Update Lightcord\n"
    printf "\n";
    tput sgr0

    while ! echo $selection | grep -Eq "^[0-9]";
    do
        read -r selection;
        # If the entered value was not an integer, prompt the user again
        if ! echo $selection | grep -Eq "^[0-9]"; then
            sleep 1;
            tput setaf 9
            printf "Please try again\n";
            tput setaf 208
            printf "1: Install Lightcord\n";
            printf "2: Uninstall Lightcord\n";
            printf "3: Update Lightcord\n"
            printf "\n";
            tput sgr0
        fi
    done


    case $selection in
        1) # Install LC
        Info 'Installing Lightcord'
        SubInfo "Downloading Lightcord"
        Download lightcord.AppImage $LC_APPIMAGE;
        if [ ! $? ]; then
            SubInfo "Trying alternate URL"
            Download lightcord.AppImage $ALT_LC_APPIMAGE;
        fi
        SubInfo "Downloading Lightcord icon"
        Download lightcord.png $ICON;
        mkdir -p "$LOCAL_INSTALL_DIR";
        mv lightcord.AppImage "$LOCAL_INSTALL_DIR";
        chmod +x "$LOCAL_INSTALL_DIR/lightcord.AppImage";
        mkdir -p ~/.local/share/icons/hicolor/512x512/apps
        mv lightcord.png ~/.local/share/icons/hicolor/512x512/apps;
        SubInfo "Creating local desktop entry"
        printf "[Desktop Entry]\nName=Lightcord\nComment[fr_FR]=Un client Discord simple et personalisable\nComment=A simple - customizable - Discord Client\nExec=$LOCAL_INSTALL_DIR/lightcord.AppImage\nIcon=lightcord\nTerminal=false\nType=Application\nCategories=Network;InstantMessaging;P2P;" >> ~/.local/share/applications/lightcord.desktop;
        SubInfo "Cleaning up"
        ;;

        2) # Uninstall LC
        Info 'Uninstalling Lightcord'
        SubInfo "Deleting Lightcord folder"
        rm -r "$LOCAL_INSTALL_DIR";
        SubInfo "Deleting Lightcord icon"
        rm ~/.local/share/icons/hicolor/512x512/apps/lightcord.png;
        SubInfo "Deleting desktop entry"
        rm ~/.local/share/applications/lightcord.desktop;
        ;;

        3) # Update LC
        Info 'Updating Lightcord'
        SubInfo "Deleting Lightcord"
        rm "$LOCAL_INSTALL_DIR"/lightcord.AppImage;
        SubInfo "Downloading Lightcord"
        Download lightcord.AppImage $LC_APPIMAGE;
        if [ ! $? ]; then
            SubInfo "Trying alternate URL"
            Download lightcord.AppImage $ALT_LC_APPIMAGE;
        fi
        mkdir -p "$LOCAL_INSTALL_DIR";
        mv lightcord.AppImage "$LOCAL_INSTALL_DIR";
        chmod +x "$LOCAL_INSTALL_DIR/lightcord.AppImage";
        SubInfo "Cleaning up"
        ;;

        *)
        Error 'Aborting install'
        ;;
    esac
    ;;

    *)
    Error 'Aborting install'
    ;;
esac

exit
