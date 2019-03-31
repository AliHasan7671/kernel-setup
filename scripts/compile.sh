#!/bin/bash

export TERM=xterm

source ~/private/.credentials

cd ../jarvis

ROOT_PATH=$PWD

# Colorize and add text parameters
red=$(tput setaf 1)             #  red
grn=$(tput setaf 2)             #  green
blu=$(tput setaf 4)             #  blue
txtbld=$(tput bold)             #  bold
bldgrn=${txtbld}$(tput setaf 1) #  bold red
bldgrn=${txtbld}$(tput setaf 2) #  bold green
bldblu=${txtbld}$(tput setaf 4) #  bold blue
txtrst=$(tput sgr0)             #  reset


# Start tracking time

echo -e ${bldblu}
echo -e "---------------------------------------"
echo -e "SCRIPT STARTING AT $(date +%D\ %r)"
echo -e "---------------------------------------"
echo -e ${txtrst}

START=$(date +%s)

#TG message function

if [ "$GROUP" == "yes" ]
then
export CHAT_ID="-1001191430908 $CHAT_ID";
else
export CHAT_ID="348414952 $CHAT_ID";
fi

function message()
{
for f in $CHAT_ID
do
bash ~/send_message.sh $f $@
done
}

# Environment
export KBUILD_BUILD_USER=AliHasan7671
export KBUILD_BUILD_HOST=Mark50
TOOLCHAIN=~/kernel/toolchains/gcc-4.9/bin/aarch64-linux-android-
export CROSS_COMPILE="${CCACHE} ${TOOLCHAIN}"
export ARCH=arm64

# Run it
echo "Running ${THIS_WILL_BE_RUN}"
eval ${THIS_WILL_BE_RUN}

message "Starting kernel compilation at $(date +%Y%m%d) for ${DEVICE}. %0A[Progress URL]($BUILD_URL)."
message "${PRE_MESSAGE}";

# Clean out folder

if [ "$NOCLEAN" == "yes" ]
then
  echo -e "${bldblu} Removing existing images. ${txtrst}"
  rm out/arch/arm64/boot/Image.gz-dtb
  rm out/arch/arm64/boot/Image.gz
  rm out/arch/arm64/boot/Image

  else
  echo -e "${bldblu} Cleaning up the OUT folder. ${txtrst}"
  rm -rf out
fi

# Setup ccache

if [ "$NOCCACHE" == "yes" ]
then
  export USE_CCACHE=0

  else
  export USE_CCACHE=1
fi

# Start compilation

echo -e "${bldblu} Starting compilation... ${txtrst}"
    make clean O=out/

    make mrproper O=out/

    make mido_defconfig O=out/

    make -j16 O=out

# If the compilation was successful

if [ `ls "out/arch/arm64/boot/Image.gz-dtb" 2>/dev/null | wc -l` != "0" ]
then
   BUILD_RESULT="Compilation successful"
   message "Compilation successful, uploading now!";

    rm ../zipit/*gz-dtb
    rm ../zipit/*.zip
    cp out/arch/arm64/boot/Image.gz-dtb ../zipit
    cd ../zipit
    zip -r9 "JARVIS-mido-$(date +"%Y%m%d"-"%H%M").zip" *

   FINALZIP="$(ls JARVIS-mido-2019*.zip)"
   size=$(du -sh $FINALZIP | awk '{print $1}')
   md5=$(md5sum $FINALZIP | awk '{print $1}' )

   echo -e "${bldblu} Uploading ${txtrst}"
   gdriveid=$(gdrive upload --parent 1H5llxFqCYVbda8uDB0sgNTZj1cVzVv5j ${FINALZIP} | tail -1 | awk '{print $2}')

   echo -e "${bldblu}Mirroring ${txtrst}"
   sudo rm /var/www/mirror1.ialihasan.com/JARVIS*.zip
   sudo cp $FINALZIP /var/www/mirror1.ialihasan.com/
#   scp -i ~/keys/sf $FINALZIP alihasan7671@web.sourceforge.net:/home/frs/project/mido-test-builds
#   curl -u "$ncuser1:$ncpass1" --upload-file $FINALZIP ftp://198.54.114.241:21

   message @AliHasan7671 compilation completed %0AMD5sum - "$md5" %0ASize - "$size" %0A"[Gdrive link](https://drive.google.com/uc?id=$gdriveid) %0A[Mirror1 link](https://mirror1.ialihasan.com/$FINALZIP)"
   message "${POST_MESSAGE}";

# If compilation failed
else
   BUILD_RESULT="Compilation failed"
   message " Kernel compilation failed, @AliHasan7671";
   exit 1
fi

# Back to root path
cd $ROOT_PATH

# Stop tracking time
END=$(date +%s)
echo -e ${bldblu}
echo -e "-------------------------------------"
echo -e "SCRIPT ENDING AT $(date +%D\ %r)"
echo -e ""
echo -e "${BUILD_RESULT}!"
echo -e "TIME: $(echo $((${END}-${START})) | awk '{print int($1/60)" MINUTES AND "int($1%60)" SECONDS"}')"
echo -e "-------------------------------------"
echo -e ${txtrst}
