#!/bin/sh

#将AAB转成APK
#bundletool路径
TOOL_PATH=$1
#abb名称
AAB_NAME=$2

#Build目录
BUILD_DIR=./Build

java -jar $TOOL_PATH build-apks  --bundle=$BUILD_DIR/$AAB_NAME.aab \
--output=$BUILD_DIR/convert.apks \
--ks=./keystore/mergetown.keystore \
--ks-pass=pass:mergetown \
--ks-key-alias=mergetown \
--mode=universal

mv $BUILD_DIR/convert.apks $BUILD_DIR/convert.zip
unzip $BUILD_DIR/convert.zip -d $BUILD_DIR/convert
mv $BUILD_DIR/convert/universal.apk $BUILD_DIR/$AAB_NAME.apk
echo "apk转换完成"