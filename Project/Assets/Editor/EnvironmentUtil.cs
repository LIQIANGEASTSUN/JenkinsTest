using System;

public class EnvironmentUtil
{
    public static string GetString(string key, string defaultValue = "")
    {
        string value = Environment.GetEnvironmentVariable(key);
        if (string.IsNullOrEmpty(value))
        {
            return defaultValue;
        }
        return value;
    }

    public static int GetInt(string key, int defaultValue = 0)
    {
        string value = GetString(key, string.Empty);
        if (string.IsNullOrEmpty(value))
        {
            return defaultValue;
        }

        return int.Parse(value);
    }

    public static float GetFloat(string key, int defaultValue = 0)
    {
        string value = GetString(key, string.Empty);
        if (string.IsNullOrEmpty(value))
        {
            return defaultValue;
        }

        return float.Parse(value);
    }

    public static bool GetBool(string key, bool defaultValue = false)
    {
        string value = GetString(key);
        if (string.IsNullOrEmpty(value))
        {
            return defaultValue;
        }

        return value.CompareTo("true") == 0;
    }
}
