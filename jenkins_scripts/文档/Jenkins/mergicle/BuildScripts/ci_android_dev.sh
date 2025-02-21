#!/bin/sh

#unity程序的路径#
UNITY_PATH=/Applications/Unity/Hub/Editor/2021.3.41f1/Unity.app/Contents/MacOS/Unity

#项目的路径#
#GAME_PROJECT_PATH=/var/lib/jenkins/workspace/Mergical-Unity3D
#GAME_PROJECT_PATH=/Users/fotoable/Program/Git_Android/mergical-unity3d

#游戏程序的路径#
PROJECT_PATH=./MergeTown

rm -rf $PROJECT_PATH/Assets/XLua/Gen
#生成APK#
echo "==============开始导出APK=============="

$UNITY_PATH -projectPath $PROJECT_PATH \
-buildTarget android \
-executeMethod MergeTownAppPacker.AndroidCommandLineBuild \
-logfile - \
-batchMode -quit \
-GMMode 

# 正式打包方法 ：BuildFormalJenkinsProject
# 测试打包方法 ：BuildTextJenkinsProject

echo "==============导出APK完毕=============="
