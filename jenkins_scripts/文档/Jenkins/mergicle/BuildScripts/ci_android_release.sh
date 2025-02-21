#!/bin/sh

#unity程序的路径#
UNITY_PATH=/Applications/Unity/Hub/Editor/2021.3.35f1/Unity.app/Contents/MacOS/Unity

#项目的路径#
#GAME_PROJECT_PATH=/var/lib/jenkins/workspace/Mergical-Unity3D
#GAME_PROJECT_PATH=/Users/fotoable/Program/Git_Android/mergical-unity3d

#游戏程序的路径#
PROJECT_PATH=./MergeTown

rm -rf $PROJECT_PATH/Assets/XLua/Gen
#生成APK#
echo "==============开始导出APK=============="
buildVersion=$1
versionUploadURL=$2 
echo $buildVersion

$UNITY_PATH -projectPath $PROJECT_PATH \
-buildTarget android \
-executeMethod MergeTownAppPacker.AndroidCommandLineBuild \
-logfile - \
-batchMode -quit     \
-release -obb -buildNumber $buildVersion

echo "==============导出APK完毕=============="

echo "==============开始上传versions.csv文件=============="
app_version=`grep bundleVersion: ./MergeTown/ProjectSettings/ProjectSettings.asset | sed "s/bundleVersion: //g" |  sed "s/ //g" `
bundle_info_file="./MergeTown/Assets/StreamingAssets/assets/versions.csv"

curl -T ${bundle_info_file}  ${versionUploadURL}/assetbundle/${app_version}/versions.csv --ftp-create-dirs

echo "==============versions.csv文件上传完成=============="
