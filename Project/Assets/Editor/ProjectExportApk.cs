using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System;
using System.IO;
using Google.Android.AppBundle.Editor;

public class ProjectExportApk : Editor
{

    private static BuildOptions s_BuildOptions = BuildOptions.CompressWithLz4HC;

    /// <summary>
    /// 手动打包时设置环境变量
    /// </summary>
    private static void ManualExportEnvironment()
    {
        string rootPath = Application.dataPath;
        rootPath = Path.GetDirectoryName(rootPath);
        rootPath = Path.GetDirectoryName(rootPath);

        string keystorePath = Path.Combine(rootPath, "jenkins_scripts", "Tools", "user.keystore");
        string exportPath = Path.Combine(rootPath, "Export/Android");
        string exportApkPath = Path.Combine(exportPath, "test.apk");
        string exportAABPath = Path.Combine(exportPath, "googleplay.aab");

        Environment.SetEnvironmentVariable("KEY_STORE_PATH", keystorePath);
        Environment.SetEnvironmentVariable("EXPORT_PATH", exportPath);
        Environment.SetEnvironmentVariable("EXPORT_APK_PATH", exportApkPath);
        Environment.SetEnvironmentVariable("GOOGLE_PLAY_AAB_PATH", exportAABPath);
    }

    /// <summary>
    /// 手动打包时设置环境变量
    /// </summary>
    private static void ManualExportAPKSpecial()
    {
        Environment.SetEnvironmentVariable("BUILD_AAB", "false");
    }

    /// <summary>
    /// 手动打包时设置环境变量
    /// </summary>
    private static void ManualExportAABSpecial()
    {
        Environment.SetEnvironmentVariable("BUILD_AAB", "true");
    }

    /// <summary>
    /// 添加一个测试打包的方法
    /// </summary>
    [MenuItem("Tools/ExportAPK")]
    private static void ExportAPKManual()
    {
        ManualExportEnvironment();
        ManualExportAPKSpecial();
        ExportAPK();
    }

    /// <summary>
    /// 添加一个测试打包的方法
    /// </summary>
    [MenuItem("Tools/ExportAAB")]
    private static void ExportAABManual()
    {
        ManualExportEnvironment();
        ManualExportAABSpecial();
        ExportApkAndAAB();
    }

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
        string exportPath = WorkExportPath();
        if (Directory.Exists(exportPath))
        {
            Directory.Delete(exportPath, true);
        }
        Directory.CreateDirectory(exportPath);

        PlayerSettings.applicationIdentifier = "com.DeCompany.Project";

        string keystorePath = GetKeyStorePath();
        Debug.Log("keystorePath:" + keystorePath);
        // 配置 keystore 信息
        PlayerSettings.Android.keystoreName = keystorePath;
        PlayerSettings.Android.keystorePass = "123456";
        PlayerSettings.Android.keyaliasName = "testapk";
        PlayerSettings.Android.keyaliasPass = "123456";
        PlayerSettings.Android.useCustomKeystore = true;

        PlayerSettings.Android.bundleVersionCode = 2;
        PlayerSettings.Android.useAPKExpansionFiles = false;

        EditorUserBuildSettings.buildAppBundle = EnvironmentUtil.GetBool("BUILD_AAB", false);
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

        string apkPath = GetApkPath();
        Debug.Log("apkPath:" + apkPath);
        BuildPipeline.BuildPlayer(levels.ToArray(), apkPath, BuildTarget.Android, options);
    }

    public static void ExportApkAndAAB()
    {
        ExportAPK();
        if (!EditorUserBuildSettings.buildAppBundle)
        {
            return;
        }

        Debug.Log("Start Export aab");

        string aabPath = GetAABPath();
        var buildPlayerOptions = AndroidBuildHelper.CreateBuildPlayerOptions(aabPath);
        var assetPackConfig = new AssetPackConfig();
        assetPackConfig.SplitBaseModuleAssets = true;
        Google.Android.AppBundle.Editor.Internal.AppBundlePublisher.Build(buildPlayerOptions, assetPackConfig, false);
    }

    public static string WorkExportPath()
    {
        return EnvironmentUtil.GetString("EXPORT_PATH", Application.dataPath);
    }

    private static string GetKeyStorePath()
    {
        return EnvironmentUtil.GetString("KEY_STORE_PATH", string.Empty);
    }

    private static string GetApkPath()
    {
        return EnvironmentUtil.GetString("EXPORT_APK_PATH", "output.apk");
    }

    private static string GetAABPath()
    {
        return EnvironmentUtil.GetString("GOOGLE_PLAY_AAB_PATH", "googleplay.aab");
    }

}
