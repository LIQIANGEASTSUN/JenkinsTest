using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PojectExport
{

    public static void Export()
    {
        Debug.LogError("PojectExport  Export");

        // 获取环境变量
        string myParam = Environment.GetEnvironmentVariable("MY_PARAM");

        if (myParam != null)
        {
            Debug.Log("Received parameter: " + myParam);
        }
        else
        {
            Debug.Log("No parameter received.");
        }

    }

}
