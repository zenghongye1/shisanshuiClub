--[[--
 * @Description: 退出框逻辑处理
 * @Author:      shine
 * @FileName:    exit_ui.lua
 * @DateTime:    2017-07-22 20:25:26
 ]]

exit_ui = {}
local this = exit_ui

function this.Show()
	MessageBox.ShowYesNoBox(LanguageMgr.GetWord(6023), function() Application.Quit() end)
end