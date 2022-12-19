#!/bin/bash

GREEN='\033[1;32m'
BLUE='\033[1;34m'
NC='\033[0m' # No Color

# TODO: create separate script, run as sudo, to add function to check for required package dependencies for Yocot and repo; this script should not run as sudo
# TODO: add error checking for commands below (make sure wget completes, etc)

ANG_DIR=angstrom-v2016.12-yocto2.2
MAN_DIR=angstrom-manifest

PATH=~/.bin/:$PATH

echo -e ${GREEN}
echo "*************************************************************"
echo "This script will create an ${ANG_DIR}/${MAN_DIR} directory   "
echo "and build a complete SD Card image for the chameleon96 board."
echo "*************************************************************"

read -n 1 -s -p "Press any key to continue..."
echo -e ${NC}

mkdir $ANG_DIR
cd $ANG_DIR
mkdir $MAN_DIR
cd $MAN_DIR

echo -e ${GREEN}
echo "***************************************************************"
echo "* Cloning Angstrom repo...                                    *"
echo "***************************************************************"
echo -e ${NC}

# Clone Angstrom repo
repo init -u https://github.com/Angstrom-distribution/angstrom-manifest -b angstrom-v2016.12-yocto2.2

echo -e ${GREEN}
echo "***************************************************************"
echo "* Configuring local manifests...                              *"
echo "***************************************************************"
echo -e ${NC}

wget https://raw.githubusercontent.com/mrmoritz01/chameleon96/master/chameleon96_manifest.xml
mkdir -p .repo/local_manifests
mv chameleon96_manifest.xml .repo/local_manifests

#sed -i '/meta-altera/a \ \ \$\{TOPDIR\}\/layers\/meta-chameleon96 \\' .repo/manifests/conf/bblayers.conf
#sed -i '/meta-photography/d' .repo/manifests/conf/bblayers.conf

# symlinks might be created by ./setup-environment; if so, uncomment below
#sed --follow-symlinks -i '/meta-96boards/a \ \ \$\{TOPDIR\}\/layers\/meta-chameleon96 \\' conf/bblayers.conf
#sed --follow-symlinks -i '/meta-photography/d' .repo/manifests/conf/bblayers.conf

echo -e ${GREEN}
echo "***************************************************************"
echo "* Syncing...                                                  *"
echo "***************************************************************"
echo -e ${NC}

repo sync

echo -e ${GREEN}
echo "***************************************************************"
echo "* Setting up environment...                                   *"
echo "***************************************************************"
echo -e ${NC}

chmod +x setup-environment
MACHINE=chameleon96 . ./setup-environment

echo -e ${GREEN}
echo "***************************************************************"
echo "* Updating bblayers.conf...                                   *"
echo "***************************************************************"
echo -e ${NC}

# add custom layer to bblayers.conf
sed --follow-symlinks -i '/meta-96boards/a \ \ \$\{TOPDIR\}\/layers\/meta-chameleon96 \\' conf/bblayers.conf
#sed --follow-symlinks -i '/meta-photography/d' .repo/manifests/conf/bblayers.conf
# disable meta-photography layer - causing gnome-keyring bitbake error
sed --follow-symlinks -i '/meta-photography/d' conf/bblayers.conf

echo -e ${GREEN}
echo "***************************************************************"
echo "* Starting bitbake...                                         *"
echo "***************************************************************"
echo -e ${NC}

bitbake chameleon96-xfce-image
