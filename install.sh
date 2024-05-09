#!/bin/bash

# HyprV4 By SolDoesTech - https://www.youtube.com/@SolDoesTech
# License..? - You may copy, edit and ditribute this script any way you like, enjoy! :)

# The follwoing will attempt to install all needed packages to run Hyprland
# This is a quick and dirty script there are some error checking
# IMPORTANT - This script is meant to run on a clean fresh Arch install on physical hardware

# Script modifed by Khyernet

# Define the software that would be inbstalled 
#Need some prep work
prep_stage=(
    qt5-wayland 
    qt5ct
    qt6-wayland 
    qt6ct
    qt5-svg
    qt5-quickcontrols2
    qt5-graphicaleffects
    gtk3 
    polkit-gnome 
    pipewire 
    pipewire-pulse
    wireplumber 
    jq 
    wl-clipboard 
    cliphist 
    python-requests 
    pacman-contrib
)

#software for nvidia GPU only
nvidia_stage=(
    linux-headers 
    nvidia-dkms 
    nvidia-settings 
    libva 
    libva-nvidia-driver-git
)

dev_stage=(
    rustup
    rust-src
    gcc
    nodejs
    npm
    pnpm
    python-pip
    neovim
    python-neovim
)

#the main packages
install_stage=(
    kitty 
    fastfetch
    dunst
    waybar
    swww-git
    swaylock-effects 
    wofi 
    wlogout 
    xdg-desktop-portal-hyprland 
    swappy 
    grim 
    slurp 
    thunar 
    vivaldi
    mpv
    pamixer 
    pavucontrol 
    brightnessctl 
    bluez 
    bluez-utils 
    blueman 
    network-manager-applet 
    gvfs 
    thunar-archive-plugin 
    starship 
    papirus-icon-theme 
    ttf-jetbrains-mono-nerd 
    noto-fonts-emoji 
    lxappearance 
    qgnomeplatform-qt5
    qgnomeplatform-qt6
    xfce4-settings
    nwg-look-bin
    sddm
    curl
    wget
    tree-sitter
)

qol_stage=(
    fish
    bat
    ripgrep
    fzf
    fd
    zoxide
    thefuck
    exa
    setcolors-git
    mkinitcpio-colors-git
    tcobalt
)

# set some colors
CNT="[\e[1;36mNOTE\e[0m]"
COK="[\e[1;32mOK\e[0m]"
CER="[\e[1;31mERROR\e[0m]"
CAT="[\e[1;37mATTENTION\e[0m]"
CWR="[\e[1;35mWARNING\e[0m]"
CAC="[\e[1;33mACTION\e[0m]"
INSTLOG="install.log"

######
# functions go here

# function that would show a progress bar to the user
show_progress() {
    while ps | grep $1 &> /dev/null;
    do
        echo -n "."
        sleep 1
    done
    echo -en "Done!\n"
    sleep 0.5
}

# function that will test for a package and if not found it will attempt to install it
install_software() {
    # First lets see if the package is there
    if paru -Q $1 &>> /dev/null ; then
        echo -e "$COK - $1 is already installed."
    else
        # no package found so installing
        echo -en "$CNT - Now installing $1 ."
        paru -S --noconfirm $1 &>> $INSTLOG &
        show_progress $!
        # test to make sure package installed
        if paru -Q $1 &>> /dev/null ; then
            echo -e "\e[1A\e[K$COK - $1 was installed."
        else
            # if this is hit then a package is missing, exit to review log
            echo -e "\e[1A\e[K$CER - $1 install had failed, please check the install.log"
            exit
        fi
    fi
}

# clear the screen
clear

# set some expectations for the user
echo -e "$CNT - You are about to execute a script that would attempt to setup Hyprland.
Please note that Hyprland is still in Beta."
sleep 1
echo -e "$CNT - This script was originally made by SolDoesTech. I (Khyernet) have modified it to fit my own dotfiles."
sleep 1

# attempt to discover if this is a VM or not
echo -e "$CNT - Checking for Physical or VM..."
ISVM=$(hostnamectl | grep Chassis)
echo -e "Using $ISVM"
if [[ $ISVM == *"vm"* ]]; then
    echo -e "$CWR - Please note that VMs are not fully supported and if you try to run this on a Virtual Machine there is a high chance this will fail."
    sleep 1
fi

# let the user know that we will use sudo
echo -e "$CNT - This script will run some commands that require sudo. You will be prompted to enter your password.
If you are worried about entering your password then you may want to review the content of the script."
sleep 1

# give the user an option to exit out
read -rep $'[\e[1;33mACTION\e[0m] - Would you like to continue with the install (y,n) ' CONTINST
if [[ $CONTINST == "Y" || $CONTINST == "y" ]]; then
    echo -e "$CNT - Setup starting..."
    sudo touch /tmp/hypr.tmp
else
    echo -e "$CNT - This script will now exit, no changes were made to your system."
    exit
fi

# find the Nvidia GPU
if lspci -k | grep -A 2 -E "(VGA|3D)" | grep -iq nvidia; then
    ISNVIDIA=true
else
    ISNVIDIA=false
fi

### Disable wifi powersave mode ###
read -rep $'[\e[1;33mACTION\e[0m] - Would you like to disable WiFi powersave? (y,n) ' WIFI
if [[ $WIFI == "Y" || $WIFI == "y" ]]; then
    LOC="/etc/NetworkManager/conf.d/wifi-powersave.conf"
    echo -e "$CNT - The following file has been created $LOC.\n"
    echo -e "[connection]\nwifi.powersave = 2" | sudo tee -a $LOC &>> $INSTLOG
    echo -en "$CNT - Restarting NetworkManager service, Please wait."
    sudo systemctl restart NetworkManager &>> $INSTLOG
    
    #wait for services to restore (looking at you DNS)
    for i in {1..6} 
    do
        echo -n "."
        sleep 1
    done
    echo -en "Done!\n"
    sleep 1
    echo -e "\e[1A\e[K$COK - NetworkManager restart completed."
fi

#### Check for package manager ####
if [ ! -f /sbin/paru ]; then  
    echo -en "$CNT - Configuering paru."
    git clone https://aur.archlinux.org/paru.git &>> $INSTLOG
    cd paru
    makepkg -si --noconfirm &>> ../$INSTLOG &
    show_progress $!
    if [ -f /sbin/paru ]; then
        echo -e "\e[1A\e[K$COK - paru configured"
        cd ..
        
        # update the paru database
        echo -en "$CNT - Updating paru."
        paru -Suy --noconfirm &>> $INSTLOG &
        show_progress $!
        echo -e "\e[1A\e[K$COK - paru updated."
    else
        # if this is hit then a package is missing, exit to review log
        echo -e "\e[1A\e[K$CER - paru install failed, please check the install.log"
        exit
    fi
fi

### Install all of the above pacakges ####
# Prep Stage - Bunch of needed items
echo -e "$CNT - Prep Stage - Installing needed components, this may take a while..."
for SOFTWR in ${prep_stage[@]}; do
    install_software $SOFTWR 
done

# Setup Nvidia if it was found
if [[ "$ISNVIDIA" == true ]]; then
    echo -e "$CNT - Nvidia GPU support setup stage, this may take a while..."
    for SOFTWR in ${nvidia_stage[@]}; do
        install_software $SOFTWR
    done

    # update config
    sudo sed -i 's/MODULES=()/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
    sudo mkinitcpio --config /etc/mkinitcpio.conf --generate /boot/initramfs-custom.img
    echo -e "options nvidia-drm modeset=1\noptions nvidia NVreg_PreserveVideoMemoryAllocations=1" | sudo tee -a /etc/modprobe.d/nvidia.conf &>> $INSTLOG
    sudo systemctl enable nvidia-suspend 2>> /dev/null
    sudo systemctl enable nvidia-hibernate 2>> /dev/null
    sudo systemctl enable nvidia-resume 2>> /dev/null
fi

# Install the correct hyprland version
echo -e "$CNT - Installing Hyprland, this may take a while..."   
install_software hyprland-git

echo -e "$CNT - Installing software development tools..."   
for SOFTWR in ${dev_stage[@]}; do
    install_software $SOFTWR 
done
echo -e "$CNT - Setting up the default rust toolchain..."   
rustup default stable &>> $INSTLOG

# Stage 1 - main components
echo -e "$CNT - Installing main components, this may take a while..."
for SOFTWR in ${install_stage[@]}; do
    install_software $SOFTWR 
done

echo -e "$CNT - Installing quality-of-life applications, we are almost finished..."
for SOFTWR in ${qol_stage[@]}; do
    install_software $SOFTWR 
done

# Start the bluetooth service
echo -e "$CNT - Starting the Bluetooth Service..."
sudo systemctl enable --now bluetooth.service &>> $INSTLOG

# Enable the sddm login manager service
echo -e "$CNT - Enabling the SDDM Service..."
sudo systemctl enable sddm &>> $INSTLOG

# Clean out other portals
echo -e "$CNT - Cleaning out conflicting xdg portals..."
paru -R --noconfirm xdg-desktop-portal-gnome xdg-desktop-portal-gtk &>> $INSTLOG

echo -e "$CNT - Copying theme files..."
sudo cp -r ./.themes/* /usr/share/themes/
sudo cp -r ./.icons/* /usr/share/icons/

echo -en "$CNT - Now installing the needed fonts ."
paru -S --noconfirm ttf-bitstream-vera ttf-croscore ttf-dejavu ttf-droid gnu-free-fonts ttf-ibm-plex ttf-liberation noto-fonts ttf-roboto ttf-ubuntu-font-family ttf-ms-fonts ttf-vista-fonts &>> $INSTLOG
echo -e "\e[1A\e[K$COK - The needed fonts have been installed!"

### Copy Config Files ###
echo -e "$CNT - Copying config files..."

chown -R $USER:$USER .
cp -rf ./.config $HOME/
chmod +x ./.scripts/*
sudo cp -f ./.scripts/* /usr/bin
cp -f ./.bashrc ../
bat cache --build &>> $INSTLOG

sudo ln -s /usr/bin/kitty /usr/bin/xdg-terminal-exec

    # Copy the SDDM theme
echo -e "$CNT - Setting up the login screen."
sudo cp -R .sddm-theme/sdt /usr/share/sddm/themes/
sudo chown -R $USER:$USER /usr/share/sddm/themes/sdt
sudo mkdir /etc/sddm.conf.d
echo -e "[Theme]\nCurrent=sdt" | sudo tee -a /etc/sddm.conf.d/10-theme.conf &>> $INSTLOG
WLDIR=/usr/share/wayland-sessions
if [ -d "$WLDIR" ]; then
echo -e "$COK - $WLDIR found"
else
echo -e "$CWR - $WLDIR NOT found, creating..."
sudo mkdir $WLDIR
fi 

# stage the .desktop file
sudo cp hyprland.desktop /usr/share/wayland-sessions/

echo -e "$CNT - Setting themes..."

# setup the first look and feel as dark
xfconf-query -c xsettings -p /Net/ThemeName -s "Adwaita-dark"
xfconf-query -c xsettings -p /Net/IconThemeName -s "Papirus-Dark"

xfconf-query -c xsettings -p /Net/ThemeName -s "Juno-ocean"
gsettings set org.gnome.desktop.interface gtk-theme "Juno-ocean"

gsettings set org.gnome.desktop.interface font-name 'JetBrainsMono Nerd Font 11'
gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrainsMono Nerd Font 10'

gsettings set org.gnome.desktop.interface cursor-theme 'breeze_cursors'

sudo cp -f ~/.config/hypr/backgrounds/northernlights_mountains.jpg /usr/share/sddm/themes/sdt/wallpaper.jpg

### Script is done ###
echo -e "$CNT - Script had completed!"
sleep 1
echo -e "$CNT - The wallpaper manager 'swww' can't immediately show a wallpaper the first time you log into Hyprland.
When this happens, run swww img {path to any image}, or if you copied my config, run '$HOME/.config/hypr/hypr_theme $HOME/.config/hypr/background/{any image in this folder}'."
echo -e "$CNT - To set the tokyonight tty colorscheme, add the 'colors' hook to /etc/mkinicpio.conf and run mkinitcpio -P"
echo -e "$CNT - To enable the fish shell, replace /bin/bash in the passwd file the the line of your username with /bin/fish"
sleep 2
if [[ "$ISNVIDIA" == true ]]; then 
    echo -e "$CAT - We attempted to set up an NVIDIA GPU.
In order for Hyprland to work properly, you must follow the directions in 'https://github.com/korvahannu/arch-nvidia-drivers-installation-guide' as this script was not able to do some of them. The NVIDIA driver that was automatically installed is 'nvidia-dkms', so you can skip the first and second steps.
After that, reboot and you should be good."
    sleep 5
    exit
else
    read -rep $'[\e[1;33mACTION\e[0m] - Would you like to start Hyprland now? (y,n) ' HYP
    if [[ $HYP == "Y" || $HYP == "y" ]]; then
        exec sudo systemctl start sddm &>> $INSTLOG
    else
        exit
    fi
fi

