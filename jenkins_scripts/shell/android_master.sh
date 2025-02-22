#!/bin/sh

#!/bin/bash

echo "this is android_master.sh"
# 输出工作目录
echo "WORKSPACE=${WORKSPACE}"

# Unity 安装目录
UNITY_PATH=/Applications/Unity/Hub/Editor/2022.3.26f1/Unity.app/Contents/MacOS/Unity
# Unity 项目目录 Assets、Library、ProjectSettings 文件夹在 PROJECT_PATH 路径下
PROJECT_PATH="${WORKSPACE}/Project"

# 通过 export 将变量标记为环境变量，并传递给 Unity 使用
# 导出到 Unity 后都是 字符串
# 在 Unity 中通过 string value = Environment.GetEnvironmentVariable(key); 获取
# bool 类型的传递过去是字符串 "true" 和 "false"
export WORKSPACE_PATH="${WORKSPACE}"
# 生成文件保存目录，也通过 export 传递给 Unity
export EXPORT_PATH="${WORKSPACE}/Export"
export KEY_STORE_PATH="${WORKSPACE}/jenkins_scripts/Tools/user.keystore"
# 生成的 apk 名字
export APK_NAME="${JOB_BASE_NAME}_${BUILD_ID}_${BRANCH_NAME}.apk"
# 生成的 apk 路径
export EXPORT_APK_PATH="${EXPORT_PATH}/${APK_NAME}"
# 生成 .aab 文件
export BUILD_AAB="false"    

echo "UNITY_PATH=${UNITY_PATH}"
echo "PROJECT_PATH=${PROJECT_PATH}"
echo "APK_NAME=${APK_NAME}"
echo "EXPORT_APK_PATH=${EXPORT_APK_PATH}"
echo "BUILD_AAB=${BUILD_AAB}"


# 下面是调用 Unity 的命令
# 在 Assets 文件夹下任意目录 创建文件夹 Editor
# 新建 ProjectExportApk.cs  删除继承 MonoBehaviour   
# 添加一个 public static void ExportAPK() 方法
# 下面命令通过 ProjectExportApk.ExportAPK 调用
$UNITY_PATH -projectPath $PROJECT_PATH \
-buildTarget android \
-executeMethod ProjectExportApk.ExportAPK \
-logfile - \
-batchMode -quit \
-GMMode 


echo "this is testShellUnity.sh end"
