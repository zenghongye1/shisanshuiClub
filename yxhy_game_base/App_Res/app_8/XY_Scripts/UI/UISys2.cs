/********************************************************************
	created:	2015/07/02  14:27
	file base:	UISys2
	file ext:	cs
	author:			
	purpose:	目前还在使用遗留机制的UI
*********************************************************************/
partial class UISys
{
    partial void InitPrefabTable()
    {
        // 手动处理的UI  
        m_UITable[typeof(Loading).ToString()] = Loading.Create(this, cachedGo, m_UICamera, "app_8/ui/loading_ui/loading_ui", false, (int)UISys.EnmUIDestroyType.ENMUIDT_FREEDESTROY);
    }
}