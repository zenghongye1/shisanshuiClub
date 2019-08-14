/********************************************************************
	created:	2015/06/09  14:12
	file base:	LuaNotifier
	file ext:	cs
	author:		shine
	
	purpose:	实现lua notifier c#层调用
*********************************************************************/
public interface ILuaNotifier
{
    /// 发送消息到lua函数（string类型不适用）
    void dispatchCmd(string sCmdID, System.Object para1 = null, System.Object para2 = null, System.Object para3 = null, System.Object para4 = null);
}