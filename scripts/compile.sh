#!/bin/bash

export TERM=xterm

source ~/scripts/envstuff

cd ../jarvis

ROOT_PATH=$PWD

# Start tracking time

echo -e "---------------------------------------"
echo -e "SCRIPT STARTING AT $(date +%D\ %r)"
echo -e "---------------------------------------"
START=$(date +%s)

#TG message function

if [ -z "$CHAT_ID" ]; then
export CHAT_ID="348414952 $CHAT_ID";
fi

function message()
{
for f in $CHAT_ID
do
curl -s "https://api.telegram.org/bot${BOT_API}/sendmessage" --data "text=${*}&chat_id=$CHAT_ID&parse_mode=Markdown" > /dev/null
done
}

# Environment
export KBUILD_BUILD_USER=AliHasan7671
export KBUILD_BUILD_HOST=Mark85
TOOLCHAIN=~/kernel/toolchains/gcc-4.9/bin/aarch64-linux-android-
export CROSS_COMPILE="${CCACHE} ${TOOLCHAIN}"
export ARCH=arm64

# Run it
echo "Running ${RUN}"
eval ${RUN}

message "Starting kernel compilation at $(date +%Y%m%d) for mido. %0A[Progress URL]($BUILD_URL)."

# Clean out folder

if [ "$NOCLEAN" == "yes" ]
then
  echo -e " Removing existing images. "
  rm out/arch/arm64/boot/Image.gz-dtb
  rm out/arch/arm64/boot/Image.gz
  rm out/arch/arm64/boot/Image

  else
  echo -e " Cleaning up the OUT folder. "
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

echo -e " Starting compilation.... "
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

   echo -e " Uploading! "
   gdriveid=$(gdrive upload --parent 1mdLiLw3Pv3cbIeRqTw9vgxfMlxCWMP-4 ${FINALZIP} | tail -1 | awk '{print $2}')

   echo -e " Mirroring! "
   rm ~/mirror/JARVIS*.zip
   cp $FINALZIP ~/mirror/
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
echo -e "-------------------------------------"
echo -e "SCRIPT ENDING AT $(date +%D\ %r)"
echo -e ""
echo -e "${BUILD_RESULT}!"
echo -e "TIME: $(echo $((${END}-${START})) | awk '{print int($1/60)" MINUTES AND "int($1%60)" SECONDS"}')"
echo -e "-------------------------------------"
