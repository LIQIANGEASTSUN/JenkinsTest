using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;

public class ProjectExportApk
{

    protected static BuildOptions s_BuildOptions = BuildOptions.CompressWithLz4HC;

    public static void ExportAPK()
    {
        Debug.Log("ExportApk ExportAPK start");

        bool switchAndroid = EditorUserBuildSettings.SwitchActiveBuildTarget(BuildTargetGroup.Android, BuildTarget.Android);
        if (!switchAndroid)
        {
            Debug.LogError("ExportApk Switch Android Error");
            return;
        }

        Debug.Log("ExportApk Switch Android success");

        PlayerSettings.applicationIdentifier = "com.DeCompany.Project";

        PlayerSettings.Android.keystoreName = GetKeyStorePath();
        PlayerSettings.Android.keystorePass = "123456";
        PlayerSettings.Android.keyaliasName = "testapk";
        PlayerSettings.Android.keyaliasPass = "123456";
        PlayerSettings.Android.useCustomKeystore = true;
        PlayerSettings.Android.bundleVersionCode = 2;

        PlayerSettings.Android.useAPKExpansionFiles = false;
        EditorUserBuildSettings.buildAppBundle = false;

        EditorUserBuildSettings.androidCreateSymbols = AndroidCreateSymbols.Public;
        EditorUserBuildSettings.exportAsGoogleAndroidProject = false;

        string apkDirectory = GetApkDirectory();
        if (Directory.Exists(apkDirectory))
        {
            Directory.Delete(apkDirectory);
        }
        Directory.CreateDirectory(apkDirectory);
        Debug.LogError("apkDirectory:" + apkDirectory);

        var options = s_BuildOptions;
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

        string apkPath = Path.Combine(apkDirectory, "test.apk");
        Debug.LogError("apkPath:" + apkPath);
        BuildPipeline.BuildPlayer(levels.ToArray(), apkPath, BuildTarget.Android, options);
    }

    private static string GetKeyStorePath()
    {
        string keystorePath = Path.Combine(Application.dataPath, "Keystore", "user.keystore");
        return keystorePath;
    }

    private static string GetApkDirectory()
    {
        string apkPath = Path.Combine(Application.dataPath, "Export");
        return apkPath;
    }

}
