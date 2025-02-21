#!/bin/sh

#!/bin/bash

echo "this is android_distribute.sh"
# 输出工作目录
echo "WORKSPACE=${WORKSPACE}"

# Unity 安装目录
UNITY_PATH=/Applications/Unity/Hub/Editor/2022.3.26f1/Unity.app/Contents/MacOS/Unity
# Unity 项目目录 Assets、Library、ProjectSettings 文件夹在 PROJECT_PATH 路径下
PROJECT_PATH="${WORKSPACE}/Project"
# bundleTool 路径 https://developer.android.com/tools/bundletool?hl=zh-cn
BUNDLE_TOOL_PATH="${WORKSPACE}/jenkins_scripts/Tools/bundletool-all-1.18.0.jar"

# 通过 export 将变量标记为环境变量，并传递给 Unity 使用
# 导出到 Unity 后都是 字符串
# 在 Unity 中通过 string value = Environment.GetEnvironmentVariable(key); 获取
# bool 类型的传递过去是字符串 "true" 和 "false"
export WORKSPACE_PATH="${WORKSPACE}"
export EXPORT_PATH="${WORKSPACE}/Export"
export KEY_STORE_PATH="${WORKSPACE}/jenkins_scripts/Tools/user.keystore"
# 生成的 apk 名字
export APK_NAME="${JOB_BASE_NAME}_${BUILD_ID}_${BRANCH_NAME:18}.apk"
# 生成的 apk 路径
export EXPORT_APK_PATH="${EXPORT_PATH}/${APK_NAME}"
# 生成 .aab 文件
export BUILD_AAB="true"
# aab 生成路径
export GOOGLE_PLAY_AAB_PATH="${EXPORT_PATH}/googlePlay.aab"
# build-apks 命令从aab 生成的 apk 组路径
OUT_PUT_APKS_PATH_1="${EXPORT_PATH}/output_1.apks"
# extract-apks 从 OUT_PUT_APKS_PATH_1的APK 集中提取设备专用 APK
OUT_PUT_APKS_PATH_2="${EXPORT_PATH}/output_2.apks"
# extract-apks 使用的设备规范 JSON
SAMSUNG_S9_PATH="${WORKSPACE}/jenkins_scripts/Tools/Samsung_S9.json"    


echo "UNITY_PATH=${UNITY_PATH}"
echo "PROJECT_PATH=${PROJECT_PATH}"
echo "BUNDLE_TOOL_PATH=${BUNDLE_TOOL_PATH}"
echo "APK_NAME=${APK_NAME}"
echo "EXPORT_APK_PATH=${EXPORT_APK_PATH}"
echo "BUILD_AAB=${BUILD_AAB}"
echo "GOOGLE_PLAY_AAB_PATH=${GOOGLE_PLAY_AAB_PATH}"
echo "OUT_PUT_APKS_PATH_1=${OUT_PUT_APKS_PATH_1}"
echo "OUT_PUT_APKS_PATH_2=${OUT_PUT_APKS_PATH_2}"
echo "SAMSUNG_S9_PATH=${SAMSUNG_S9_PATH}"


# 下面是调用 Unity 的命令
# 在 Assets 文件夹下任意目录 创建文件夹 Editor
# 新建 PojectExport.cs  删除继承 MonoBehaviour   
# 添加一个 public static void Export() 方法
# 下面命令通过 PojectExport.Export 调用
$UNITY_PATH -projectPath $PROJECT_PATH \
-buildTarget android \
-executeMethod ProjectExportApk.ExportApkAndAAB \
-logfile - \
-batchMode -quit \
-GMMode

echo "Export apk and aab success"

#BundleTools
java -jar ${BUNDLE_TOOL_PATH} build-apks --bundle=${GOOGLE_PLAY_AAB_PATH} --output=${OUT_PUT_APKS_PATH_1}
java -jar ${BUNDLE_TOOL_PATH} extract-apks --apks=${OUT_PUT_APKS_PATH_1} --output-dir=${OUT_PUT_APKS_PATH_2} --device-spec=${SAMSUNG_S9_PATH}


echo "this is android_distribute.sh end"
