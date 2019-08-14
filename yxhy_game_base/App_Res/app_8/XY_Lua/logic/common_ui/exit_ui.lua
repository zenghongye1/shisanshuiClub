--[[--
 * @Description: 退出框逻辑处理
 * @Author:      shine
 * @FileName:    exit_ui.lua
 * @DateTime:    2017-07-22 20:25:26
 ]]

exit_ui = {}
local this = exit_ui

function this.Show()
	message_box.ShowGoldBox(GetDictString(6023), {function ()
	        message_box:Close()
	    end, function ()
	    	Application.Quit()
	        message_box:Close()
	    end}, {"quxiao","queding"},{"button_03","button_02"})	
end