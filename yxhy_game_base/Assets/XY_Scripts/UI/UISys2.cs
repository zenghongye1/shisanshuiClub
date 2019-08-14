/********************************************************************
	created:	2015/07/02  14:27
	file base:	UISys2
	file ext:	cs
	author:			
	purpose:	目前还在使用遗留机制的UI
*********************************************************************/
using LitJson;
using Framework;

partial class UISys
{
    partial void InitPrefabTable()
    {
        // 手动处理的UI  
        JsonData deJson = JsonMapper.ToObject(GameAppInstaller.appConfData);
        System.Text.StringBuilder stringBuilder = new System.Text.StringBuilder(deJson["appPath"].ToString());
        m_UITable[typeof(Loading).ToString()] = Loading.Create(this, cachedGo, m_UICamera, stringBuilder.Append("/ui/loading_ui/loading_ui").ToString(), false, (int)UISys.EnmUIDestroyType.ENMUIDT_FREEDESTROY);
    }
}