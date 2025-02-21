#!/bin/sh

#unity程序的路径#
UNITY_PATH=/Applications/Unity/Hub/Editor/2021.3.35f1/Unity.app/Contents/MacOS/Unity

#游戏程序的路径#
PROJECT_PATH=./MergeTown

rm -rf $PROJECT_PATH/Assets/XLua/Gen
#生成APK#
echo "==============开始导出xcode项目=============="
buildVersion=$1
versionUploadURL=$2
echo bunder version:$buildVersion

$UNITY_PATH -projectPath $PROJECT_PATH \
-buildTarget ios \
-executeMethod MergeTownAppPacker.IOSCommandLineBuild \
-logfile - \
-batchMode -quit     \
-release -obb -buildNumber $buildVersion

echo "==============导出XCode项目完毕=============="

#定义ipa相关变量
xcodeWorkspacePath=./Mergical_IOS/Mergical/Unity-iPhone.xcworkspace
target=Unity-iPhone
packgeName=Mergical-Release-$(date "+%Y-%m-%d-%H-%M")
outputArchivePath=/Users/meraki/Xcarchives/${packgeName}.xcarchive
outputIPAPath=./Build
exportOptionsFilePath=./BuildScripts/ExportOptions.plist

echo "==============开始上传versions.csv文件=============="
app_version=`grep bundleVersion: ./MergeTown/ProjectSettings/ProjectSettings.asset | sed "s/bundleVersion: //g" |  sed "s/ //g" `
bundle_info_file="./MergeTown/Assets/StreamingAssets/assets/versions.csv"

curl -T ${bundle_info_file}  ${versionUploadURL}/assetbundle/${app_version}/versions.csv --ftp-create-dirs

echo "==============versions.csv文件上传完成=============="


echo "===============清理xcode项目================="
xcodebuild clean -workspace ${xcodeWorkspacePath} -scheme ${target} -configuration Release

echo "===============开始编译xcode项目================="
xcodebuild archive -workspace ${xcodeWorkspacePath} -scheme ${target} -configuration Release \
-archivePath ${outputArchivePath} 

echo "===============开始导出ipa================="
xcodebuild -exportArchive -archivePath ${outputArchivePath} \
-exportPath ${outputIPAPath} -exportOptionsPlist ${exportOptionsFilePath}

#重命名ipa
ipa_name=$(find ./Build/*.ipa |head -n 1)
mv ${ipa_name} ./Build/${packgeName}.ipa

echo "===============编译xcode项目完成================="