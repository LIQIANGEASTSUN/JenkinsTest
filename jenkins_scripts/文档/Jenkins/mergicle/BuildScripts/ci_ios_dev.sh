#!/bin/sh

#unity程序的路径#
UNITY_PATH=/Applications/Unity/Hub/Editor/2021.3.35f1/Unity.app/Contents/MacOS/Unity

#游戏程序的路径#
PROJECT_PATH=./MergeTown

rm -rf $PROJECT_PATH/Assets/XLua/Gen
#生成APK#
echo "==============开始导出xcode项目=============="

$UNITY_PATH -projectPath $PROJECT_PATH \
-buildTarget ios \
-executeMethod MergeTownAppPacker.IOSCommandLineBuild \
-logfile - \
-batchMode -quit \
-GMMode 

# 正式打包方法 ：BuildFormalJenkinsProject
# 测试打包方法 ：BuildTextJenkinsProject
rm -rf ./Build


echo "==============导出XCode项目完毕=============="

#定义ipa相关变量
xcodeWorkspacePath=./Mergical_IOS/Mergical/Unity-iPhone.xcworkspace
target=Unity-iPhone
packgeName=Mergical-$(date "+%Y-%m-%d-%H-%M")
outputArchivePath=/Users/meraki/Xcarchives/${packgeName}.xcarchive
outputIPAPath=./Build
exportOptionsFilePath=./BuildScripts/ExportOptions.plist


echo "===============清理xcode项目================="
xcodebuild clean -workspace ${xcodeWorkspacePath} -scheme ${target} -configuration Release

echo "===============开始编译xcode项目================="
xcodebuild archive -workspace ${xcodeWorkspacePath} -scheme ${target} -configuration Release \
-archivePath ${outputArchivePath} #

echo "===============开始导出ipa================="
xcodebuild -exportArchive -archivePath ${outputArchivePath} \
-exportPath ${outputIPAPath} -exportOptionsPlist ${exportOptionsFilePath}

rm -rf $xcarchiveFilePath

#重命名ipa
ipa_name=$(find ./Build/*.ipa |head -n 1)
mv ${ipa_name} ./Build/${packgeName}.ipa

#上传ipa到文件服务器
#source ./BuildScripts/upload_package.sh ios