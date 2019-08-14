--[[--
 * @Description: 负责回包的统一错误处理
 * @Author:      shine
 * @FileName:    global_rsp_handler
 * @DateTime:    2017-05-17 21:01:29
 ]]


global_rsp_handler = {}
local this = global_rsp_handler
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
 * @param:       rsp 　　　		:json数据
                 hideErrorMsg	:是否隐藏错误信息
 * @return:      false if error occur, true otherwise
 ]]
function this.ParseFromString(rsp, pkgData, hideErrorMsg)
	rsp:ParseFromString(pkgData)

	if (rsp.RetCode ~= nil and rsp:HasField("RetCode") and rsp.RetCode ~= 0) then
		local retCode = rsp.RetCode

		--todo, 几个特殊的RetCode，比如重新登录，版本不一致，token过期等，直接在这里统一处理

		--非特殊的RetCode，直接展示MsgBox
		if (hideErrorMsg == nil or not hideErrorMsg) then
			local info,_type = GetDictStringAndType(retCode)
			if (_type == nil or _type == 0 or _type == 1) then
				local msg = message_box.Show(GetDictString(6032), "[00ff00]"..info.."[-]", 1)
	        	msg:SetBtnInfo(1, "关闭")
	        else
	        	fast_tip.Show(info)
	        end
		end
		
		return false
	end
	
	return true
end

--[[--
 * @Description: 处理错误显示
 ]]
function this.HandleErrorInfo(retCode)
	local info = GetDictString(retCode)
	local msg = message_box.Show(GetDictString(6032), "[00ff00]"..info.."[-]", 1)
	msg:SetBtnInfo(1, "关闭")
end