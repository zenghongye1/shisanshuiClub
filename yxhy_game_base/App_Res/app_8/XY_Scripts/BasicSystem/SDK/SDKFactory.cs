using UnityEngine;
using System.Collections;
using LuaInterface;
using System.Reflection;
public enum SDKPlatform
{
    develop,
    //xiaomi,
}

public class SDKFactory
{
    public static SDKBaseComponent CreateSDKComponent(string channelId)
    {
        //Debug.Log(channelId);
        switch (channelId)
        {
            case "test":
                return new DevelopSDKComp(channelId);
        }
        return new DevelopSDKComp("test");
    }
}
