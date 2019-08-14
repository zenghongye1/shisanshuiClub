using UnityEngine;
using System.Collections;
using LuaInterface;
using LitJson;

public class LoginRetInfo
{
    public string Result="";   //1 成功为 success
    public string Uid="";
    public string PlatType="";
    public string Token="";
    public string Passwd="";

    public static string RESULT_SUCCESS = "success";
}

public class PayRetInfo
{
    public bool ret;
}

public class SDKBaseComponent
{
    protected string mChannelId;

    public Callback<bool> initCallback;

    public Callback<LoginRetInfo> loginCallback;
    public LuaFunction loginCallbackByLua;

    public Callback<bool> logoutCallback;
    public LuaFunction logoutCallbackByLua;

    public Callback<PayRetInfo> payCallback;
    public LuaFunction payCallbackByLua;

    public Callback<bool> exitCallback;
    public LuaFunction exitCallbackByLua;

    protected SDKBaseComponent(string channelId) { mChannelId = channelId; }

    virtual public void Init() { }
    virtual public void HandleInitMsg(string ret) {
        if (initCallback != null)
        {
            bool r;
            if (!bool.TryParse(ret, out r))
                r = false;

            initCallback(r);
        }
    }
    virtual public void Login() { }
    virtual public void HandleLoginMsg(string ret) { }
    virtual public void Logout() {
        HandleLogoutMsg("true");
    }
    virtual public void HandleLogoutMsg(string ret) {
        bool r;
        if (!bool.TryParse(ret, out r))
            r = false;
        if (logoutCallback != null)
            logoutCallback(r);
        else if (logoutCallbackByLua != null)
            Utility_LuaHelper.CallParaLuaFunc(logoutCallbackByLua, r);
    }
    virtual public void Pay() { }
    virtual public void HandlePayMsg(string ret) { }

    virtual public void SubmitRoleData(string ret) { }

    virtual public void Exit() { HandleExit("true"); }
    virtual public void HandleExit(string ret) {
        bool r;
        if (!bool.TryParse(ret, out r))
            r = false;
        if (exitCallback != null)
            exitCallback(r);
        else if (exitCallbackByLua != null)
            Utility_LuaHelper.CallParaLuaFunc(exitCallbackByLua, r);
    }

    public string GetChannelId() { return mChannelId; }
    protected bool ContainsKey(JsonData jsonData, string name)
    {
        if (((IDictionary)jsonData).Contains(name))
        {
            return true;
        }
        return false;
    }
}
