
#!/bin/sh

#!/bin/bash

echo "this is testShellParams.sh"

# 输出 Jenkins 中参数
echo "Workspace=${WORKSPACE}"
echo "BRANCH_NAME=${BRANCH_NAME}"

echo "ABC=${ABC}"
echo "Type=${Type}"

# Pipeline 通过 withEnv(["MY_PARAM_ABC=${ABC}", "MY_PARAM_Type=${Type}"]) 传递参数
# 在这里可以直接获取
echo "MY_PARAM_ABC=${MY_PARAM_ABC}"
echo "MY_PARAM_Type=${MY_PARAM_Type}"


