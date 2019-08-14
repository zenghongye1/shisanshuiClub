using UnityEngine;
using System.Collections;

#if UNITY_IPHONE
using UnityEngine.iOS;
#endif

public static class DeviceQuality 
{
    public enum Performance
    {
        Fastest = 0,
        Fast = 1,
        Simple = 2,
        Good = 3,
        Beautiful = 4,
        Fantastic = 5,
        Auto = 6,
    }

    public static Performance PerformanceGrade
    {
        get { return performance; }
    }

    public static Performance performance = Performance.Auto;
    static bool beInitialized = false;

    public static void Initialize(Performance suggestion = Performance.Auto)
    {        
        if (suggestion != Performance.Auto)
        {
            performance = suggestion;
            SetPerformanceLevel(performance);
        }
        else
        {
            Check();
        }
    }

    public static Performance GetDetectedPerformanceLevel()
    {
		
#if UNITY_EDITOR
        return Performance.Fantastic;   
#endif

#if UNITY_IPHONE
		DeviceGeneration generation = Device.generation;

        switch (generation)
        {
		case DeviceGeneration.iPhone:
		case DeviceGeneration.iPodTouch1Gen:
		case DeviceGeneration.iPodTouch2Gen:                
		case DeviceGeneration.iPhone3G:
		case DeviceGeneration.iPhone3GS:            
		case DeviceGeneration.iPodTouch3Gen:
		case DeviceGeneration.iPad1Gen:
                return Performance.Fastest;
		case DeviceGeneration.iPhone4:
		case DeviceGeneration.iPodTouch4Gen:
                return Performance.Fast;                
		case DeviceGeneration.iPad2Gen:
		case DeviceGeneration.iPhone4S:
		case DeviceGeneration.iPad3Gen:
		case DeviceGeneration.iPodTouch5Gen:
		case DeviceGeneration.iPadMini1Gen:
                return Performance.Good;                
		case DeviceGeneration.iPhone5:
		case DeviceGeneration.iPhone5C:
		case DeviceGeneration.iPhone5S:
		case DeviceGeneration.iPad4Gen:
		case DeviceGeneration.iPad5Gen:
		case DeviceGeneration.iPadMini2Gen:
		case DeviceGeneration.iPhone6:
		case DeviceGeneration.iPhone6Plus:
		case DeviceGeneration.iPadMini3Gen:       
		case DeviceGeneration.iPadAir2:
                return Performance.Beautiful;                
        default:
                return Performance.Beautiful;  
        }
#elif UNITY_ANDROID
        if (SystemInfo.supportedRenderTargetCount > 1 || SystemInfo.supportsInstancing)
        {
            return Performance.Beautiful;
        }
        else if (SystemInfo.supportsStencil <= 0 || !SystemInfo.supportsImageEffects || !SystemInfo.supportsRenderTextures || SystemInfo.graphicsShaderLevel <= 20
            || !SystemInfo.supportsVertexPrograms)
        {
            return Performance.Fastest;
        }
        else if (SystemInfo.systemMemorySize <= 512 || SystemInfo.graphicsMemorySize < 128 || SystemInfo.processorCount <= 2 || SystemInfo.maxTextureSize <= 2048)
        {
            return Performance.Fast;
        }
        else if (SystemInfo.systemMemorySize <= 1024)
        {
            return Performance.Simple;
        }
        else if (SystemInfo.systemMemorySize <= 2048 || SystemInfo.processorCount <= 4)
        {
            return Performance.Good;
        }
        else
        {
            return Performance.Beautiful;
        }
#elif UNITY_STANDALONE
        if (SystemInfo.graphicsShaderLevel >= 30 && SystemInfo.processorCount >= 2 && SystemInfo.graphicsMemorySize >= 512 && SystemInfo.systemMemorySize >= 4096)
        {
            return Performance.Beautiful;
        }
        else if (SystemInfo.graphicsMemorySize >= 256 && SystemInfo.systemMemorySize >= 2048)
        {
            return Performance.Good;
        }
        else if (SystemInfo.graphicsMemorySize >= 128 && SystemInfo.systemMemorySize >= 1024)
        {
            return Performance.Simple;
        }
        else
        {
            return Performance.Fast;
        }
#else
        return Performance.Fast;
#endif
    }

    static void Check()
    {
        if (beInitialized)
        {
            return;
        }

        beInitialized = true;
        Performance level = GetDetectedPerformanceLevel();
        SetPerformanceLevel(level);
    }

    static void SetPerformanceLevel(Performance perfLevel)
    {
        int level = (int)perfLevel;

        if (level >= QualitySettings.names.Length)
        {
            return;
        }

        switch (perfLevel)
        {
            case Performance.Fantastic:
            case Performance.Beautiful:
                //RenderSettings.fog = true;                
                QualitySettings.SetQualityLevel(level, true);
                QualitySettings.masterTextureLimit = 0;
                break;
            case Performance.Good:
            case Performance.Simple:
            case Performance.Fast:
                QualitySettings.SetQualityLevel(level, true);
                QualitySettings.masterTextureLimit = 0;
                break;
            case Performance.Fastest:
            default: 
                QualitySettings.SetQualityLevel(level, true);
                QualitySettings.masterTextureLimit = 1;
                break;
        }

#if !UNITY_EDITOR
        QualitySettings.vSyncCount = 0;
#endif
        QualitySettings.antiAliasing = 0;
        Debug.Log("Set game quality level:" + performance);
        int index = QualitySettings.GetQualityLevel();
        Debug.Log("Current quality level is " + QualitySettings.names[index]);
    }

    static bool IsTegra3()
    {
        string graphicsDeviceName = SystemInfo.graphicsDeviceName;
        string graphicsDeviceVendor = SystemInfo.graphicsDeviceVendor;

        if (SystemInfo.processorCount >= 4)
        {
            string vendor = graphicsDeviceVendor.ToUpper();

            if (vendor.IndexOf("NVIDIA") != -1)
            {
                string deviceName = graphicsDeviceName.ToUpper();

                if (deviceName.IndexOf("TEGRA 3") != -1)
                {
                    return true;
                }
            }
        }

        return false;
    }


    public static void DecreaseLevel()
    {
        QualitySettings.DecreaseLevel();
        int level = QualitySettings.GetQualityLevel();

        if (performance != Performance.Auto)
        {
            if (level >= 0 && level <= (int)Performance.Fantastic)
            {
                performance = (Performance)level;
            }
        }
    }

    public static void IncreaseLevel()
    {
        QualitySettings.IncreaseLevel();
        int level = QualitySettings.GetQualityLevel();

        if (performance != Performance.Auto)
        {
            if (level >= 0 && level <= (int)Performance.Fantastic)
            {
                performance = (Performance)level;
            }
        }
    }

    public static int GetQualityLevel()
    {
        return QualitySettings.GetQualityLevel();
    }

    public static Performance GetPerformanceLevel()
    {
        int level = QualitySettings.GetQualityLevel();
        
        if (level >= 0 && level <= (int)Performance.Fantastic)
        {
            performance = (Performance)level;
            return performance;
        }
        else
        {
            Debug.LogError("Error level in QualitySettings" + level);
        }

        return Performance.Auto;
    }

    /// <summary>
    /// 是否推荐游玩，iOS内存小于1G不推荐; 安卓不做判读
    /// </summary>
    /// <returns></returns>
    public static bool IsRecommendPlay()
    {
#if UNITY_IPHONE && !UNITY_EDITOR
		DeviceGeneration generation = Device.generation;

        switch (generation)
        {
			case DeviceGeneration.iPadAir2:
			case DeviceGeneration.iPhone6S:
			case DeviceGeneration.iPhone6SPlus:
			case DeviceGeneration.iPadPro1Gen:
			case DeviceGeneration.iPadMini4Gen:
			case DeviceGeneration.iPadPro10Inch1Gen:
			case DeviceGeneration.iPhone7:
			case DeviceGeneration.iPhone7Plus:
			case DeviceGeneration.iPhoneSE1Gen:
			case DeviceGeneration.iPhoneUnknown:
			case DeviceGeneration.iPadUnknown:
                return true;
            default:
                return false;
        }
#endif
        return true;
    }
}
