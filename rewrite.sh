# Lightcord unified Linux installer by https://github.com/GermanBread
# POSIX compliance by https://github.com/pryme-svg (does not apply to rewrite ...yet)

#                                ___           ___                       ___           ___           ___          _____    
#                  ___          /  /\         /__/\          ___        /  /\         /  /\         /  /\        /  /::\   
#                 /  /\        /  /:/_        \  \:\        /  /\      /  /:/        /  /::\       /  /::\      /  /:/\:\  
#  ___     ___   /  /:/       /  /:/ /\        \__\:\      /  /:/     /  /:/        /  /:/\:\     /  /:/\:\    /  /:/  \:\ 
# /__/\   /  /\ /__/::\      /  /:/_/::\   ___ /  /::\    /  /:/     /  /:/  ___   /  /:/  \:\   /  /:/~/:/   /__/:/ \__\:|
# \  \:\ /  /:/ \__\/\:\__  /__/:/__\/\:\ /__/\  /:/\:\  /  /::\    /__/:/  /  /\ /__/:/ \__\:\ /__/:/ /:/___ \  \:\ /  /:/
#  \  \:\  /:/     \  \:\/\ \  \:\ /~~/:/ \  \:\/:/__\/ /__/:/\:\   \  \:\ /  /:/ \  \:\ /  /:/ \  \:\/:::::/  \  \:\  /:/ 
#   \  \:\/:/       \__\::/  \  \:\  /:/   \  \::/      \__\/  \:\   \  \:\  /:/   \  \:\  /:/   \  \::/~~~~    \  \:\/:/  
#    \  \::/        /__/:/    \  \:\/:/     \  \:\           \  \:\   \  \:\/:/     \  \:\/:/     \  \:\         \  \::/   
#     \__\/         \__\/      \  \::/       \  \:\           \__\/    \  \::/       \  \::/       \  \:\         \__\/    
#                               \__\/         \__\/                     \__\/         \__\/         \__\/                  

#
#	DO NOT CHANGE
#

# URL for downloads
LC='https://github.com/Lightcord/Lightcord/releases/latest/download/lightcord-linux-x64.zip'
ICON='https://raw.githubusercontent.com/Lightcord/Lightcord/master/discord.png'
DESKTOP='https://raw.githubusercontent.com/Lightcord/Lightcord/master/Lightcord.desktop'
APPIMAGE='https://github.com/Lightcord/Lightcord/releases/latest/download/Lightcord-linux-x86_64.AppImage'

Step() {
    tput setaf 8
    tput bold
    printf "==> "
    tput setaf 15
    printf "$*\n"
    tput sgr0
}
Info() {
    tput setaf 6
    printf " --> "
    printf "$*\n"
    tput sgr0
}
Warning() {
    tput setaf 3
    tput bold
    printf " ->> "
    tput setaf 11
    printf "$*\n"
    tput sgr0
}
Error() {
    tput setaf 1
    tput bold
    printf " =>> "
    tput setaf 9
    printf "$*\n"
    tput sgr0
}
ListHeader() {
    tput smul
    (CheckForProgram lolcat) && \
        printf "$1\n" | lolcat -S -5 -F .2 || \
            printf "$1\n"
    tput sgr0
}
ListItem() {
    (CheckForProgram lolcat) && \
        printf "[$1]" | lolcat -S $1 -F .2 || \
            printf "[$1]"
    printf " $2\n"
}

LogoSplash() {
cat << "logo_end"
    __    ____________  __________________  ____  ____ 
   / /   /  _/ ____/ / / /_  __/ ____/ __ \/ __ \/ __ \
  / /    / // / __/ /_/ / / / / /   / / / / /_/ / / / /
 / /____/ // /_/ / __  / / / / /___/ /_/ / _, _/ /_/ / 
/_____/___/\____/_/ /_/ /_/  \____/\____/_/ |_/_____/  

                Linux installer

logo_end
}
CreditSplash() {
    printf "    "
    tput smul
    printf "Written with"
    tput sgr0
    tput setaf 1
    tput bold
    tput blink
    printf " <3 "
    tput sgr0
    tput smul
    printf "by "
    tput bold
    printf "pryme-svg"
    tput sgr0
    tput smul
    printf " and "
    tput bold
    printf "GermanBread"
    tput sgr0
    printf "\n\n"
}

# 0 = OK
CheckForProgram() {
    command -v $* >/dev/null
    return $?
}
# 0 = OK
CheckForLibrary() {
    (whereis -b "$1" | grep .so) >/dev/null
    return $?
}
# 0 = OK
Confirmation() {
    tput bold
    printf "$1 [Y/n] "
    tput sgr0
    
    read _choice
    [[ $_choice = [nN] ]] && return 1 || return 0
    unset _choice
}
Download() {
	wget -qq -O $1 $2
}
EscapePath() {
    echo $* | sed 's/\//\\\//g'
}

[ "$TERM" = "dumb" ] && exit 0

[ $(id -u) -eq 0 ] \
 && Error "Do not run this script as root" && exit 1

(CheckForProgram wget) || \
    Warning '"wget" seems to not be installed, the script might not function properly without it'
(CheckForProgram unzip) || \
    Warning '"unzip" seems to not be installed, the script might not function properly without it'

CheckForLibrary libnspr4.so
_status=$?
CheckForLibrary libnss3.so
_status=$(($status+$?))
if [ $_status -ne 0 ]; then
    Warning "Some required libraries seem to not be installed!\n\tMake sure that both 'libnspr4.so' and 'libnss3.so' are present in '/lib'"
    (CheckForProgram pacman) && \
        Info "$(tput setaf 12 && tput bold)Arch Linux or Arch-based$(tput sgr0 && tput setaf 15)\n\tsudo pacman -S nss nspr"
    (CheckForProgram apt) && \
        Info "$(tput setaf 13 && tput bold)Debian or Debian-based$(tput sgr0 && tput setaf 15)\n\tsudo apt install libnspr4 libnss3"
fi
unset _status

[ -d /etc/nixos ] && \
    Warning "NixOS is not supported. Things might break"

(CheckForProgram lolcat) && \
    LogoSplash | lolcat -S -5 -F .2 || \
        LogoSplash
CreditSplash

tput civis

ListHeader "Select scope"
ListItem 1 "Global"
ListItem 2 "Local"
while ! [[ $_scope = [12] ]]; do
    tput sc
    read -n 1 _scope
    tput rc
done
echo

ListHeader "Select mode"
ListItem 1 "Install"
ListItem 2 "Install (AppImage)"
ListItem 3 "Update"
ListItem 4 "Uninstall"
while ! [[ $_mode = [1234] ]]; do
    tput sc
    read -n 1 _mode
    tput rc
done
echo

Step "The following will be done:"
case $_scope in
    1)
        Info "Manage system-wide installation"
    ;;
    2)
        Info "Manage user installation"
    ;;
esac
case $_mode in
    1)
        Info "Install Lightcord"
    ;;
    2)
        Info "Install Lightcord AppImage"
    ;;
    3)
        Info "Update Lightcord"
    ;;
    4)
        Info "Uninstall Lightcord"
    ;;
esac

tput cnorm

(Confirmation "Continue?") || \
    exit 1

tput civis

[[ $_mode = [123] ]] && _operation=1
[[ $_mode = [4] ]] && _operation=2
_downloadcache=$(mktemp -d)
case $_scope in
    1)
        case $_operation in
            1)
                Info "Downloading assets"
                case $_mode in
                    1)
                        Download $_downloadcache/Lightcord.zip $LC
                    ;;
                    2)
                        Download $_downloadcache/Lightcord.AppImage $APPIMAGE
                    ;;
                    3)
                        [ -e /opt/Lightcord/isappimage ] && \
                            Download $_downloadcache/Lightcord.AppImage $APPIMAGE || \
                                Download $_downloadcache/Lightcord.zip $LC
                    ;;
                esac
                Download $_downloadcache/Lightcord.desktop $DESKTOP
                Download $_downloadcache/lightcord.png $ICON
                
                Info "Preparing assets"
                unzip -qq $_downloadcache/Lightcord.zip -d $_downloadcache/Lightcord 2>/dev/null
                mv $_downloadcache/Lightcord/{lightcord,Lightcord} 2>/dev/null
                
                mkdir -p $_downloadcache/Lightcord
                touch $_downloadcache/Lightcord/script
                [ $_mode = 2 ] && \
                    touch $_downloadcache/Lightcord/isappimage
                chmod +x $_downloadcache/Lightcord.AppImage 2>/dev/null
                mv $_downloadcache/Lightcord{.AppImage,/Lightcord} 2>/dev/null

                Step "Privilege elevation required"
                sudo -K
                [ "$(sudo -p "Enter your password here: " id -u)" != "0" ] && \
                    Error "Authentication failed" && exit 1

                Info "Installing assets"
                sudo mkdir -p /{opt/Lightcord,usr/share/{applications,pixmaps}}/
                sudo mv -f $_downloadcache/Lightcord/* /opt/Lightcord/
                sudo mv -f $_downloadcache/Lightcord.desktop /usr/share/applications/
                sudo mv -f $_downloadcache/lightcord.png /usr/share/pixmaps/
            ;;
            2)
                Step "Privilege elevation required"
                sudo -K
                [ "$(sudo -p "Enter your password here: " id -u)" != "0" ] && \
                    Error "Authentication failed" && exit 1
                
                Info "Deleting Lightcord"
                sudo rm -rf /opt/Lightcord/
                sudo rm -f /usr/share/{applications/Lightcord.desktop,pixmaps/lightcord.png}
            ;;
        esac
    ;;

    2)
        case $_operation in
            1)
                Info "Downloading assets"
                case $_mode in
                    1)
                        Download $_downloadcache/Lightcord.zip $LC
                    ;;
                    2)
                        Download $_downloadcache/Lightcord.AppImage $APPIMAGE
                    ;;
                    3)
                        [ -e ~/.Lightcord/isappimage ] && \
                            Download $_downloadcache/Lightcord.AppImage $APPIMAGE || \
                                Download $_downloadcache/Lightcord.zip $LC
                    ;;
                esac
                Download $_downloadcache/Lightcord.desktop $DESKTOP
                Download $_downloadcache/lightcord.png $ICON
                
                Info "Preparing assets"
                unzip -qq $_downloadcache/Lightcord.zip -d $_downloadcache/Lightcord 2>/dev/null
                mv $_downloadcache/Lightcord/{lightcord,Lightcord} 2>/dev/null
                
                mkdir -p $_downloadcache/Lightcord
                touch $_downloadcache/Lightcord/script
                [ $_mode = 2 ] && \
                    touch $_downloadcache/Lightcord/isappimage
                chmod +x $_downloadcache/Lightcord.AppImage 2>/dev/null
                mv $_downloadcache/Lightcord{.AppImage,/Lightcord} 2>/dev/null
                sed -i "s/$(EscapePath /opt/Lightcord/Lightcord)/$(EscapePath ~/.Lightcord/Lightcord)/g" $_downloadcache/Lightcord.desktop

                Info "Installing assets"
                mkdir -p ~/.{Lightcord,local/share/{applications,icons/hicolor/512x512/apps}}/
                mv -f $_downloadcache/Lightcord/* ~/.Lightcord/
                mv -f $_downloadcache/Lightcord.desktop ~/.local/share/applications/
                mv -f $_downloadcache/lightcord.png ~/.local/share/icons/hicolor/512x512/apps/
            ;;
            2)
                Info "Deleting Lightcord"
                rm -rf ~/.Lightcord/
                rm -f ~/.local/share/{applications/Lightcord.desktop,icons/hicolor/512x512/apps/lightcord.png}
            ;;
        esac
    ;;
esac
rm -rf $_downloadcache
unset LC ICON DESKTOP APPIMAGE _downloadcache _operation _mode _scope

tput cnorm