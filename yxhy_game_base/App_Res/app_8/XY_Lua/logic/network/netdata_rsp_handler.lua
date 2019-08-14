--[[--
 * @Description: 负责回包的统一错误处理
 * @Author:      shine
 * @FileName:    netdata_rsp_handler
 * @DateTime:    2017-05-17 21:01:29
 ]]

require "common/ucoder"

netdata_rsp_handler = {}
local this = netdata_rsp_handler
local configName = "dataconfig_dicinfoconfig"


-- 从局部到全局，需要后续继续调整
--[[--
 * @Description: 得到错误码对应的信息  
 * @param:       codeID 错误码 
 * @return:      错误码对应的信息  
 ]]
function GetDictString(codeID)
	local ret = "[ffffff]服务器返回异常[-]"
	local foundFlag = false

	local config = config_data_center.getConfigDataByID(configName, "id", codeID)
	if (config ~= nil) then
		foundFlag = true
		ret = config.info
	end
	
	if (not foundFlag) then
		ret = ret.."[00ff00]{"..codeID.."}[-]".."\n[fd2200]配置表中没有找到这个错误码的释义！请策划和server协商添加！[-]"
	end

	--todo, 在这里可能还要进行逻辑转义处理，目前先留空

	return ret
end


function GetDictStringAndType(codeID)
	local ret = "[ffffff]服务器返回异常[-]"
	local foundFlag = false
	local _type = nil

	local config = config_data_center.getConfigDataByID(configName, "id", codeID)
	if (config ~= nil) then
		foundFlag = true
		ret = config.info
		_type = config.type
	end

	if (not foundFlag) then
		ret = ret.."[00ff00]{"..codeID.."}[-]".."\n[fd2200]配置表中没有找到这个错误码的释义！请策划和server协商添加！[-]"
	end

	return ret, _type
end

--[[--
 * @Description: 解析回包  
 * @param:       pkgData 　　　	:json数据
                 hideErrorMsg	:是否隐藏错误信息
 * @return:      返回解析后的数据
 ]]
function this.ParseFromString(pkgData, hideErrorMsg)
	--测试使用	后续去掉
	local newData = ucoder.unicode_to_utf8_000(pkgData)


	local rsp = ParseJsonStr(newData)	
	--Trace("rsp================================"..tostring(rsp))
    Trace("rsp================================"..CombinJsonStr(rsp))

   if rsp._para~=nil and rsp._para._errno~=nil then 
      Trace(rsp._para._errno.."-------------------msg._para._errno")
      local t= GetDictString(rsp._para._errno)  
      if t~=nil then
          message_box.ShowGoldBox(t,{
          	function ()
          		if game_scene.getCurSceneType() ~= scene_type.HALL then
          			game_scene.DestroyCurSence() 
          			game_scene.gotoHall()          			
          		end
          		message_box.Close()          		
          	end}, {"fonts_01"})
          waiting_ui.Hide()
      end

      return -1
   	end

    return rsp
end

--[[--
 * @Description: 处理错误显示
 ]]
function this.HandleErrorInfo(retCode)
	local info = GetDictString(retCode)
	local msg = message_box.Show(GetDictString(6032), "[00ff00]"..info.."[-]", 1)
	msg:SetBtnInfo(1, "关闭")
end