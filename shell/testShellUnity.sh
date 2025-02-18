
#!/bin/sh

#!/bin/bash

echo "this is testShellUnity.sh"

echo "WORKSPACE=${WORKSPACE}"
UNITY_PATH=/Applications/Unity/Hub/Editor/2022.3.26f1/Unity.app/Contents/MacOS/Unity

PROJECT_PATH="${WORKSPACE}/Project"
echo "PROJECT_PATH=${PROJECT_PATH}"

# 设置环境变量,导出给 Unity 使用
export MY_PARAM_1="ttttttAAAAAA"
export MY_PARAM_2=1000
export MY_PARAM_3=5.1
export MY_PARAM_4=true
export MY_PARAM_5=false

$UNITY_PATH -projectPath $PROJECT_PATH \
-buildTarget android \
-executeMethod PojectExport.Export \
-logfile - \
-batchMode -quit \
-GMMode 


echo "this is testShellUnity.sh end"
