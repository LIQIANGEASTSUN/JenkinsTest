
#!/bin/sh

#!/bin/bash

echo "this is testShellUnity.sh"
# 输出工作目录
echo "WORKSPACE=${WORKSPACE}"

# Unity 安装目录
UNITY_PATH=/Applications/Unity/Hub/Editor/2022.3.26f1/Unity.app/Contents/MacOS/Unity

# Unity 项目目录 Assets、Library、ProjectSettings 文件夹在 PROJECT_PATH 路径下
PROJECT_PATH="${WORKSPACE}/Project"
echo "PROJECT_PATH=${PROJECT_PATH}"

# 通过 export 将变量导出给 Unity 使用
# 导出到 Unity 后都是 字符串
# 在 Unity 中通过 string value = Environment.GetEnvironmentVariable(key); 获取
# bool 类型的传递过去是字符串 "true" 和 "false"
export MY_PARAM_1="ttttttAAAAAA"
export MY_PARAM_2=1000
export MY_PARAM_3=5.1
export MY_PARAM_4=true
export MY_PARAM_5=false

# 下面是调用 Unity 的命令
# 在 Assets 文件夹下任意目录 创建文件夹 Editor
# 新建 PojectExport.cs  删除继承 MonoBehaviour   
# 添加一个 public static void Export() 方法
# 下面命令通过 PojectExport.Export 调用
$UNITY_PATH -projectPath $PROJECT_PATH \
-buildTarget android \
-executeMethod ProjectExportApk.ExportAPK \
-logfile - \
-batchMode -quit \
-GMMode 


echo "this is testShellUnity.sh end"
