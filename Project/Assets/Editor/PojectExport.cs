using UnityEngine;

public class PojectExport
{
    public static void Export()
    {
        Debug.LogError("PojectExport  Export");

        // 获取环境变量
        string myParam_1 = EnvironmentUtil.GetString("MY_PARAM_1", string.Empty);
        Debug.LogError("myParam_1=" + myParam_1);

        int myParam_2 = EnvironmentUtil.GetInt("MY_PARAM_2", 0);
        Debug.LogError("myParam_2=" + myParam_2);

        float myParam_3 = EnvironmentUtil.GetFloat("MY_PARAM_3", 0);
        Debug.LogError("myParam_3=" + myParam_3);

        bool myParam_4 = EnvironmentUtil.GetBool("MY_PARAM_4", false);
        Debug.LogError("myParam_4=" + myParam_4);

        bool myParam_5 = EnvironmentUtil.GetBool("MY_PARAM_5", false);
        Debug.LogError("myParam_5=" + myParam_5);

        string myParam_6 = EnvironmentUtil.GetString("MY_PARAM_6", string.Empty);
        Debug.LogError("myParam_6=" + myParam_6);
    }

}
