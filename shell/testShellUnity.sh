
#!/bin/sh

#!/bin/bash

echo "this is testShellUnity.sh"

UNITY_PATH=/Applications/Unity/Hub/Editor/2022.3.26f1/Unity.app/Contents/MacOS/Unity

# 设置环境变量
export MY_PARAM="ttttttAAAAAA"


${UNITY_PATH} -batchmode -quit -projectPath /path/to/your/project -executeMethod PojectExport.PojectExport


echo "this is testShellUnity.sh end"
