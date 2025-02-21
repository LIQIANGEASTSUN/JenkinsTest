#!/bin/sh

#unity程序的路径#
UNITY_PATH=/Applications/Unity/Hub/Editor/2021.3.35f1/Unity.app/Contents/MacOS/Unity

#项目的路径#
#GAME_PROJECT_PATH=/var/lib/jenkins/workspace/Mergical-Unity3D
#GAME_PROJECT_PATH=/Users/fotoable/Program/Git_Android/mergical-unity3d

#游戏程序的路径#
PROJECT_PATH=./MergeTown

#生成APK#
echo "==============开始生成bundle=============="
buildVersion=$1
platform=$2

$UNITY_PATH -projectPath $PROJECT_PATH \
-buildTarget $platform \
-executeMethod MergeTownAppPacker.HotfixCommandBuild \
-logfile - \
-batchMode -quit \

# 正式打包方法 ：BuildFormalJenkinsProject
# 测试打包方法 ：BuildTextJenkinsProject

echo "==============bundle生成结束=============="

python3 ./BuildScripts/hotfix_gen.py $buildVersion $platform

