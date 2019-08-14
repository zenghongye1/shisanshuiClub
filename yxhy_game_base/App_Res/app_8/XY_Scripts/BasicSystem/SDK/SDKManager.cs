using UnityEngine;
using System.Collections;
using LuaInterface;

public class SDKManager
{
    static SDKBaseComponent mSdkImpl = null;
    //static ExternalMsgHandle mSdkCallback= null;

    public static void InitEnv()
    {
        if(ExternalMsgHandle.Instance==null)
        {
            GameObject obj = new GameObject();
            //mSdkCallback = obj.AddComponent<ExternalMsgHandle>();
        }

        string channelId = ExternalMsgHandle.CallExternalFun<string>("getChannelId");
        mSdkImpl = SDKFactory.CreateSDKComponent(channelId);
    }

    #region 接口调用

    public static void InitSDK(Callback<bool> initCallback)
    {
        if (mSdkImpl != null)
        {
            mSdkImpl.initCallback = initCallback;
            mSdkImpl.Init();
        }
    }

    public static void LoginByLua(string funcName)
    {
        if (mSdkImpl != null)
        {
            mSdkImpl.loginCallback = null;
            mSdkImpl.loginCallbackByLua = LuaClient.GetMainState().GetFunction(funcName);
            mSdkImpl.Login();
        }
    }

    public static void Login(Callback<LoginRetInfo> loginCallback)
    {
        if (mSdkImpl != null)
        {
            mSdkImpl.loginCallback = loginCallback;
            mSdkImpl.loginCallbackByLua = null;
            mSdkImpl.Login();
        }
    }

    public static void Logout(Callback<bool> logoutCallback)
    {
        if (mSdkImpl != null)
        {
            mSdkImpl.logoutCallback = logoutCallback;
            mSdkImpl.logoutCallbackByLua = null;
            mSdkImpl.Logout();
        }
    }
    public static void LogoutByLua(string funcName)
    {
        if (mSdkImpl != null)
        {
            mSdkImpl.logoutCallback = null;
            mSdkImpl.logoutCallbackByLua = LuaClient.GetMainState().GetFunction(funcName);
            mSdkImpl.Logout();
        }
    }
    public static void SwitchAccount(Callback<LoginRetInfo> switchAcc)
    {
    }
    public static void SwitchAccountByLua(string funcName)
    {
        //处理我们自己的切换帐号操作
        LuaFunction lf = LuaClient.GetMainState().GetFunction(funcName);
        if(lf!=null)
        {
            LoginRetInfo retInfo = new LoginRetInfo();
            Utility_LuaHelper.CallParaLuaFunc(lf, retInfo.Uid, retInfo.Token, retInfo.PlatType, retInfo.Passwd, true);
        }
    }

    public static void Pay(Callback<PayRetInfo> payCallback)
    {
        if (mSdkImpl != null)
        {
            mSdkImpl.payCallback = payCallback;
            mSdkImpl.payCallbackByLua = null;
            mSdkImpl.Pay();
        }
    }

    public static void PayByLua(string funcName)
    {
        if(mSdkImpl!=null)
        {
            mSdkImpl.payCallback = null;
            mSdkImpl.payCallbackByLua = LuaClient.GetMainState().GetFunction(funcName);
            mSdkImpl.Pay();
        }
    }

    public static void SubmitRoleData(string info)
    {
        if(mSdkImpl!=null)
        {
            mSdkImpl.SubmitRoleData(info);
        }
    }

    public static void Exit(Callback<bool> exitCallback)
    {
        if(mSdkImpl!=null)
        {
            mSdkImpl.exitCallback = exitCallback;
            mSdkImpl.exitCallbackByLua = null;
            mSdkImpl.Exit();
        }
    }

    public static void ExitByLua(string funcName)
    {
        if(mSdkImpl!=null)
        {
            mSdkImpl.exitCallback = null;
            mSdkImpl.exitCallbackByLua = LuaClient.GetMainState().GetFunction(funcName);
            mSdkImpl.Exit();
        }
    }
    public static string GetChannelNum()
    {
        return mSdkImpl.GetChannelId();
    }
    #endregion
}
