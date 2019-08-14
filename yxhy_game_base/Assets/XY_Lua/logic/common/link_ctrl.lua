--[[--
 * @Description: 关键字链接事件控制处理
 * @Author:      shine
 * @FileName:    link_ctrl.lua
 * @DateTime:    2015-09-29 10:00:09
 ]]

link_ctrl = {}
local this = link_ctrl

LinkCmdID = 
{
	CMD_Click_UserName = "1",
	CMD_Click_ItemName = "2",	
}

--[[--
 * @Description: 生成链接文字，通用命令处理方法  [url=LinkCmdID|parm1,parm2]context[/url] 
 * @param:       参数1[string]：cmd        -linkCmdID定义的枚举 
 				 参数2[string]：strParam   -链接参数，以','分割多个参数
 				 参数3[string]: stringData -链接显示的文字
 * @return:      生成的链接文字
 ]]
function this.GenLinkNameStr(cmd, strParam, stringData)
	local linkText = "[url="..cmd.."|"..strParam.."]"..stringData.."[/url]"
	return linkText
end

--[[--
 * @Description: 点击Labellink后，命令解析处理函数  
 * @param:       参数1[GameObject]: go - label obje
 				 参数2[string]:link String返回到字符串
 * @return:      无 通过：cmdName.MSG_LBL_LINK_MSG链接字解析结果
 				  cmdInfo [strCmdID linkCmdID定义的枚举 ]， [params- GenLinkNameStr传入的参数]
 ]]
function this.ProcLinkClickMsg(go)
	local lblClickItem = componentGet(go.transform, "UILabel")
	if lblClickItem == nil then
		return
	end

	local cmdInfo = {}
	local urlCmd = lblClickItem:GetUrlAtPosition(UICamera.lastWorldPosition)
	if urlCmd ~= nil then
		local endPos = string.find(urlCmd, "|")
		if endPos == nil then
			endPos = -1
			cmdInfo.strCmdID = string.sub(urlCmd, 1, endPos)
		else
			cmdInfo.strCmdID = string.sub(urlCmd, 1, endPos-1)
			local str = string.sub(urlCmd, endPos + 1, -1)
			cmdInfo.params = Utils.split(str , ",")
		end
		Notifier.dispatchCmd(cmdName.MSG_LBL_LINK_MSG, cmdInfo)
	end
end