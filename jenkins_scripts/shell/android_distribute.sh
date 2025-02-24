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
export EXPORT_PATH="${WORKSPACE}/Export/Android"
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
OUT_PUT_APKS_PATH="${EXPORT_PATH}/output_1.apks"
# extract-apks 从 OUT_PUT_APKS_PATH的APK 集中提取设备专用 APK
EXTRACT_APK_FROM_APKS_PATH="${EXPORT_PATH}/output_2.apks"
# extract-apks 使用的设备规范 JSON
SAMSUNG_S9_PATH="${WORKSPACE}/jenkins_scripts/Tools/Samsung_S9.json"    


echo "UNITY_PATH=${UNITY_PATH}"
echo "PROJECT_PATH=${PROJECT_PATH}"
echo "BUNDLE_TOOL_PATH=${BUNDLE_TOOL_PATH}"
echo "APK_NAME=${APK_NAME}"
echo "EXPORT_APK_PATH=${EXPORT_APK_PATH}"
echo "BUILD_AAB=${BUILD_AAB}"
echo "GOOGLE_PLAY_AAB_PATH=${GOOGLE_PLAY_AAB_PATH}"
echo "OUT_PUT_APKS_PATH=${OUT_PUT_APKS_PATH}"
echo "EXTRACT_APK_FROM_APKS_PATH=${EXTRACT_APK_FROM_APKS_PATH}"
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
java -jar ${BUNDLE_TOOL_PATH} build-apks --bundle=${GOOGLE_PLAY_AAB_PATH} --output=${OUT_PUT_APKS_PATH}
java -jar ${BUNDLE_TOOL_PATH} extract-apks --apks=${OUT_PUT_APKS_PATH} --output-dir=${EXTRACT_APK_FROM_APKS_PATH} --device-spec=${SAMSUNG_S9_PATH}


echo "this is android_distribute.sh end"


# ProjectExportApk.ExportApkAndAAB 方法中生成 .apk 和 .aab 文件
# Android 上线 Google Play 只需要将生成的 .aab 上传到 GooglePlay 即可

# bundletool 命令的作用，官方文档 https://developer.android.com/tools/bundletool?hl=zh-cn
# java -jar ${BUNDLE_TOOL_PATH} build-apks --bundle=${GOOGLE_PLAY_AAB_PATH} --output=${OUT_PUT_PATH} 
# 作用是使用 bundletool 工具从 Android App Bundle（.aab 文件）生成 APK 集合
# 并将生成的 APK 集合打包成一个名为“APK set archive”的文件，文件扩展名为 .apks
# 这个命令会将指定的 .aab 文件转换为 APK 集合，并将结果输出到指定的路径（OUT_PUT_PATH）。


# java -jar ${BUNDLE_TOOL_PATH} extract-apks --apks=${OUT_PUT_PATH} --output-dir=${OUT_APKS_PATH} --device-spec=${SAMSUNG_S9_PATH} 
# 作用是从之前生成的 APK 集合（.apks 文件）中提取出针对特定设备配置的 APK
# --device-spec 参数指定了一个 JSON 文件（SAMSUNG_S9_PATH），该文件描述了目标设备的特性（如屏幕大小、CPU 架构等），从而确保提取的 APK 适合该设备

# 从上面两条 bundletool 命令的作用，我们了解到，只是用 .aab 生成 apk 组到 .apks，然后再通过 --device-spec 指定的 Json 配置文件
# 从 .apks 文件中提取出满足特定设备的 apk
# .aab 文件还是ProjectExportApk.ExportApkAndAAB 方法中生成的，没有做任何处理
# 那么为什么要添加上面两条 bundletool 命令?
# 这在开发和测试阶段是非常有用的，因为它允许开发者在本地测试和验证 APK 的功能，特别是在不同的设备配置下确保其在目标设备上能正常运行。
# 对于上传到 Google Play 的生产版本，这些步骤可能不是必须的，但常常在 CI/CD 流程中用于验证构建的有效性。
# 这些命令在比较典型的开发工作流中是有用的，尤其是在测试和验证阶段，当开发者需要验证构建后的 APK 是否如预期那样工作时



