using UnityEngine;
using System.Collections;
using System;
using LuaInterface;
using System.Collections.Generic;
using LitJson;

public class DevelopSDKComp : SDKBaseComponent
{
    //暂时 希望lua 和C#用一个获取key接口 
    string PREFIX_MACHINE = "PREFIX_MACHINE";
    string prefsNameId = "login_role_id";
    string prefsNamePasswd = "login_role_passwd";
    GameObject myReceiver = null;

    public DevelopSDKComp(string channelId) : base(channelId) { }

    public override void Init()
    {
        base.Init();
        HandleInitMsg("true");
    }

    public override void Login()
    {
        base.Login();
        Debugger.Log("登录成功");
        Dictionary<string, string> dict = new Dictionary<string, string>();
        Util.GetString(prefsNameId);
        string uid = PlayerPrefs.GetString(PREFIX_MACHINE + prefsNameId);
        string plat_type = "QQ";
        string token = "i am" + uid + " from " + "QQ";
        string passwd = PlayerPrefs.GetString(PREFIX_MACHINE + prefsNamePasswd);
       
        if (string.IsNullOrEmpty(uid))
            token = "";

        dict.Add("user_id", uid);
        dict.Add("token", token);
        dict.Add("plat_type", plat_type);
        dict.Add("passwd", passwd);

        HandleLoginMsg(LitJson.JsonMapper.ToJson(dict));
    }

    public override void HandleLoginMsg(string ret)
    {
        //Debugger.Log(ret);
        JsonData jsonData = JsonMapper.ToObject(ret);
        LoginRetInfo retInfo = new LoginRetInfo();

        if ((IDictionary)jsonData == null)
        {
            Debugger.Log("登录返回格式不正确");
            retInfo.Result = "返回非json数据";
        }
        else
        {
            retInfo.Result = ContainsKey(jsonData, "result") ? (string)jsonData["result"] : "没有result字段";
        }

        retInfo.Uid = ContainsKey(jsonData, "user_id") ? (string)jsonData["user_id"] : "";
        retInfo.Token = ContainsKey(jsonData, "token") ? (string)jsonData["token"] : "";
        retInfo.PlatType = ContainsKey(jsonData, "plat_type") ? (string)jsonData["plat_type"] : "";
        retInfo.Passwd = ContainsKey(jsonData, "passwd") ? (string)jsonData["passwd"] : "";

        if (loginCallback != null)
        {
            loginCallback(retInfo);
        }
        else if (loginCallbackByLua != null)
        {
            Utility_LuaHelper.CallParaLuaFunc(loginCallbackByLua, retInfo.Uid, retInfo.Token, retInfo.PlatType, retInfo.Passwd,true);
        }
    }

    public override void Pay()
    {
        base.Pay();
    }
}
