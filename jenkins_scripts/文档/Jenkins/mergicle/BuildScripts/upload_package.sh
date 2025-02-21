#!/bin/sh

platform=$1
url=$2

if [ $platform == 'android' ]
then
    echo "android platform"
elif [ $platform  == 'ios' ]
then
    echo "ios plaform"
else
    echo "platfrom无效"
    exit 1
fi


echo '上传路径'$url
files=$(ls ./Build/{*.apk,*.obb,*.ipa})

for file in $files
do
    echo '开始上传:'$file
    curl -T $file $url
done
echo '上传完成'
