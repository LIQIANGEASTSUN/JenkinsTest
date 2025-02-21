using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;

public class ProjectExportApk : Editor
{

    protected static BuildOptions s_BuildOptions = BuildOptions.CompressWithLz4HC;

    [MenuItem("Tools/ExportAPK")]
    public static void ExportAPK()
    {
        Debug.Log("ExportApk ExportAPK start");

        // 切换平台到 Android 分支
        bool switchAndroid = EditorUserBuildSettings.SwitchActiveBuildTarget(BuildTargetGroup.Android, BuildTarget.Android);
        if (!switchAndroid)
        {
            Debug.LogError("ExportApk Switch Android Error");
            return;
        }

        Debug.Log("ExportApk Switch Android success");
        string workspacePath = WorkSpacePath();

        PlayerSettings.applicationIdentifier = "com.DeCompany.Project";

        string keystorePath = GetKeyStorePath(workspacePath);
        Debug.Log("keystorePath:" + keystorePath);
        // 配置 keystore 信息
        PlayerSettings.Android.keystoreName = keystorePath;
        PlayerSettings.Android.keystorePass = "123456";
        PlayerSettings.Android.keyaliasName = "testapk";
        PlayerSettings.Android.keyaliasPass = "123456";
        PlayerSettings.Android.useCustomKeystore = true;

        PlayerSettings.Android.bundleVersionCode = 2;
        PlayerSettings.Android.useAPKExpansionFiles = false;

        EditorUserBuildSettings.buildAppBundle = false;
        // 生成符号文件
        EditorUserBuildSettings.androidCreateSymbols = AndroidCreateSymbols.Public;
        EditorUserBuildSettings.exportAsGoogleAndroidProject = false;

        var options = s_BuildOptions;
        // 是否连接 profiler
        bool connectProfiler = false;
        if (connectProfiler)
        {
            options |= BuildOptions.Development;
            EditorUserBuildSettings.development = true;
            EditorUserBuildSettings.connectProfiler = true;
            EditorUserBuildSettings.buildWithDeepProfilingSupport = true;
        }

        EditorUserBuildSettings.androidBuildSystem = AndroidBuildSystem.Gradle;
        PlayerSettings.bundleVersion = "1.1.1";
        PlayerSettings.productName = "TestProduct";
        var targetArchitectures = AndroidArchitecture.ARM64 | AndroidArchitecture.ARMv7;
        PlayerSettings.Android.targetArchitectures = (AndroidArchitecture)targetArchitectures;

        // PlayerSettings.SetScriptingDefineSymbolsForGroup(BuildTargetGroup.Android, defs);

        List<string> levels = new List<string>();
        foreach (EditorBuildSettingsScene scene in EditorBuildSettings.scenes)
        {
            if (!scene.enabled) continue;
            // 获取有效的 Scene
            levels.Add(scene.path);
        }

        string apkDirectory = GetApkDirectory(workspacePath);
        Debug.Log("apkDirectory:" + apkDirectory);
        if (Directory.Exists(apkDirectory))
        {
            Directory.Delete(apkDirectory);
        }
        Directory.CreateDirectory(apkDirectory);
        string apkName = EnvironmentUtil.GetString("APK_NAME", "product.apk");
        string apkPath = Path.Combine(apkDirectory, apkName);
        Debug.Log("apkPath:" + apkPath);
        BuildPipeline.BuildPlayer(levels.ToArray(), apkPath, BuildTarget.Android, options);
    }

    public static string WorkSpacePath()
    {
        string path = Application.dataPath;
        path = Path.GetDirectoryName(path);
        path = Path.GetDirectoryName(path);
        return path;
    }

    private static string GetKeyStorePath(string workspacePath)
    {
        string keystorePath = Path.Combine(workspacePath, "Keystore", "user.keystore");
        return keystorePath;
    }

    private static string GetApkDirectory(string workspacePath)
    {
        string apkPath = Path.Combine(workspacePath, "Export");
        return apkPath;
    }

}
