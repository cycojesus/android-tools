#!/bin/sh

CWD=$(pwd)
WORKING_DIR=$CWD/FDroid-zip

mkdir -p $WORKING_DIR
if [ -e $WORKING_DIR/fdroidclient ]; then
    ( cd $WORKING_DIR/fdroidclient/
      git pull )
    rm $WORKING_DIR/fdroidclient/F-Droid/bin/FDroid.{apk,signed.zip,zip}
else
    git clone https://gitlab.com/fdroid/fdroidclient.git $WORKING_DIR/fdroidclient
fi

if [ -e $WORKING_DIR/sign ]; then
    ( cd $WORKING_DIR/sign/
      git pull )
else
    git clone https://github.com/appium/sign.git $WORKING_DIR/sign
fi

mkdir -p $WORKING_DIR/fdroidclient/F-Droid/bin
wget -O $WORKING_DIR/fdroidclient/F-Droid/bin/FDroid.apk https://f-droid.org/FDroid.apk

cd $WORKING_DIR/fdroidclient
./F-Droid/tools/build-zip

cd $WORKING_DIR/sign
mvn package

java -jar dist/signapk.jar -w testkey.x509.pem testkey.pk8 $WORKING_DIR/fdroidclient/F-Droid/bin/FDroid.zip $WORKING_DIR/fdroidclient/F-Droid/bin/FDroid.signed.zip

if $(zipdetails $WORKING_DIR/fdroidclient/F-Droid/bin/FDroid.signed.zip | strings | grep -q "signed by SignApk"); then
    cp $WORKING_DIR/fdroidclient/F-Droid/bin/FDroid.signed.zip $CWD
    echo "Success!"
else
    echo "Failed :("
fi
