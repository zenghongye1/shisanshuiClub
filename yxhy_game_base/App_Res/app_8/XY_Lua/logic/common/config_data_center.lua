--[[--
 * @Description: 配置数据中心，其他系统统一从这里拿配置数据
 * @Author:      shine
 * @FileName:    logic/common/config_data_center.lua
 * @DateTime:    2015-08-05 15:19:15
 ]]


config_data_center = {}
local this = config_data_center
local loadConfig = nil

local doFunc = nil

config_data_center.dataValue = nil
config_data_center.resultValue = nil
config_data_center.resultValue2 = nil
config_data_center.resultValue3 = nil
config_data_center.resultValue4 = nil 

local fucDict = {}
local elementDataDict = {}

local configProtobufDict = {}
local configProtobufItemsDict = {}
local pre = "protobuf_conf_parser/dataconfig_"
local dp = "dataconfig_"
local pdt = configProtobufDict
local configInitFuncDict = {
[dp.."sceneconfig"] = function () require(pre.."sceneconfig_pb") pdt[dp.."sceneconfig"] = sceneconfig_x end,
[dp.."shopconfig"] = function () require(pre.."shopconfig_pb") pdt[dp.."shopconfig"] = shopconfig_x end,
[dp.."dicinfoconfig"] = function () require(pre.."dicinfoconfig_pb") pdt[dp.."dicinfoconfig"] = dicinfoconfig_x end,
[dp.."friendroomconfig"] = function () require(pre.."friendroomconfig_pb") pdt[dp.."friendroomconfig"] = friendroomconfig_x end,
[dp.."shisanshuitableconfig"] = function () require(pre.."shisanshuitableconfig_pb") pdt[dp.."shisanshuitableconfig"] = shisanshuitableconfig_x end
--[dp.."小写"] = function () require(pre.."小写_pb") pdt[dp.."小写"] = 小写sheet名字_x end,--最好注释下xlsx名啊，不然别人根本找不到是哪个xlsx里的
}

--[[--
 * @Description: 载入某配置文件  
 * @param:       configName config对应的Bytes文件名 
 * @return:      nil
 ]]
function loadConfig(configName)
	local bytesData = ProtobufDataConfigMgr.ReadOneDataConfigForLua(configName)
	if (configProtobufDict[configName] == nil) then
		local func = configInitFuncDict[configName]
		if (func ~= nil) then
			func()
		else
			Fatal("config_data_center does not has a parser for: "..configName)
		end

		if configProtobufDict[configName]==nil then
			Fatal("config_data_center does not has a parser for: "..configName)
		end

		local protoBufConfig = nil
		local protoBufConfig = configProtobufDict[configName]:GetProtobuf()
		protoBufConfig:ParseFromString(bytesData)

		local plainTable = configProtobufDict[configName]:New()
		plainTable:ParseData(protoBufConfig)
		configProtobufItemsDict[configName] = plainTable.items
		protoBufConfig:Clear()
		protoBufConfig = nil
		bytesData = nil
		--collectgarbage("collect")
	end
end

--[[--
 * @Description: 根据游戏业务一些表格预先加载了，请按字母排序！！
]]
function this.PreLoadConfigData()
	--this.getConfigData("dataconfig_monsterproperty")
end

--[[--
 * @Description: 根据config名字得到配置数据,注意:已经是对应protobuf结构的items字段了!!!
 * @param:       configName config对应的Bytes文件名 
 * @return:      对应protobuf结构的items字段
 ]]
function this.getConfigData(configName)
	local lowerConfigName = string.lower(configName)
	local ret = nil
	ret = configProtobufItemsDict[lowerConfigName]
	if (ret == nil) then
		loadConfig(lowerConfigName)
		
	end
	ret = configProtobufItemsDict[lowerConfigName]

	return ret
end

--[[--
 * @Description: 通过自定义函数得到配置数据  
 * @param:        configName config对应的Bytes文件名 
                  func       自定义函数
 * @return:      对应protobuf结构的items字段
 ]]
function this.getConfigDataByFunc(configName, func)
	local ret = nil
	local configDataArray = this.getConfigData(configName)

	if (func ~= nil and type(func) == "function") then
		for k, v in ipairs(configDataArray) do
			if (func(v)) then
				ret = v
				break
			end
		end
	end

	return ret
end

--[[--
 * @Description: 通过自定义函数得到配置数据(多个) 
 * @param:        configName config对应的Bytes文件名 
                  func       自定义函数
 * @return:      对应protobuf结构的items字段
 ]]
function this.getConfigDatasByFunc(configName, func)
	local ret = {}
	local configDataArray = this.getConfigData(configName)

	if (func ~= nil and type(func) == "function") then
		for k, v in ipairs(configDataArray) do
			if (func(v)) then
				table.insert(ret, v)
			end
		end
	end

	return ret
end

--[[--
 * @Description: 根据ID去得到指定的信息  
 * @param:       configName config对应的Bytes文件名  
                 IDName     ID字段对应的列名字
                 ID         传入的ID值
 ]]
function this.getConfigDataByID(configName, IDName, ID)
	if (elementDataDict[configName] == nil) then
		elementDataDict[configName] = {}
	end

	local element = elementDataDict[configName][ID]
	if (element ~= nil) then
		return element
	end

	local retValue = nil
	local configDataArray = this.getConfigData(configName)
	for k, v in ipairs(configDataArray) do
		config_data_center.dataValue = v
		if (fucDict[IDName] == nil) then
			fucDict[IDName] = loadstring("config_data_center.resultValue = config_data_center.dataValue."..IDName)
		end

		local func = fucDict[IDName]
		func()
		if (config_data_center.resultValue == ID) then
			retValue = v
			break
		end
	end


	if (ID ~= nil) then
		elementDataDict[configName][ID] = retValue
	end

	return retValue
end

--[[和楼上的一样，不过返回list
]]
function this.getConfigDatasByID(configName, IDName, ID)
	local ret = {}
	local configDataArray = this.getConfigData(configName)
	for k, v in ipairs(configDataArray) do
		config_data_center.dataValue = v
		if (fucDict[IDName] == nil) then
			fucDict[IDName] = loadstring("config_data_center.resultValue = config_data_center.dataValue."..IDName)
		end

		local func = fucDict[IDName]
		func()

		if (config_data_center.resultValue == ID) then
			table.insert(ret, v)
		end
	end

	return ret
end

--[[--
 * @Description: 根据ID去得到指定的信息  
 * @param:       configName config对应的Bytes文件名  
                 IDName1     ID字段对应的列名字
                 ID1         传入的ID值
                 IDName2     ID字段对应的列名字
                 ID2         传入的ID值                
 ]]
function this.getConfigDataByTwoID(configName, IDName1, ID1, IDName2, ID2)
	local retValue = nil
	local configDataArray = this.getConfigData(configName)
	local sumName = IDName1.."_"..IDName2
	for k, v in ipairs(configDataArray) do
		config_data_center.dataValue = v
		if (fucDict[sumName] == nil) then
			local funTmp1 = loadstring("config_data_center.resultValue = config_data_center.dataValue."..IDName1)
			local funTmp2 = loadstring("config_data_center.resultValue2 = config_data_center.dataValue."..IDName2)
			local funInfo = {}
			funInfo.func1 = funTmp1
			funInfo.func2 = funTmp2
			fucDict[sumName] = funInfo
		end

		local func1 = fucDict[sumName].func1
		local func2 = fucDict[sumName].func2
		func1()
		func2()

		if (config_data_center.resultValue == ID1 and config_data_center.resultValue2 == ID2) then
			retValue = v
			break
		end
	end
	return retValue
end

--[[
 * 和楼上的一样，不过返回list
]]
function this.getConfigDatasByTwoID(configName, IDName1, ID1, IDName2, ID2)
	local ret = {}
	local configDataArray = this.getConfigData(configName)
	local sumName = IDName1.."_"..IDName2
	for k, v in ipairs(configDataArray) do
		config_data_center.dataValue = v
		if (fucDict[sumName] == nil) then
			local funTmp1 = loadstring("config_data_center.resultValue = config_data_center.dataValue."..IDName1)
			local funTmp2 = loadstring("config_data_center.resultValue2 = config_data_center.dataValue."..IDName2)
			local funInfo = {}
			funInfo.func1 = funTmp1
			funInfo.func2 = funTmp2
			fucDict[sumName] = funInfo
		end

		local func1 = fucDict[sumName].func1
		local func2 = fucDict[sumName].func2
		func1()
		func2()

		if (config_data_center.resultValue == ID1 and config_data_center.resultValue2 == ID2) then
			table.insert(ret, v)
		end
	end
	return ret
end


--[[--
 * @Description: 根据ID去得到指定的信息  
 * @param:       configName config对应的Bytes文件名  
                 IDName1     ID字段对应的列名字
                 ID1         传入的ID值
                 IDName2     ID字段对应的列名字
                 ID2         传入的ID值       
                 IDName3     ID字段对应的列名字
                 ID3         传入的ID值               
 ]]
function this.getConfigDataByThreeID(configName, IDName1, ID1, IDName2, ID2, IDName3, ID3)
	local retValue = nil
	local configDataArray = this.getConfigData(configName)
	local sumName = IDName1.."_"..IDName2.."_"..IDName3
	for k, v in ipairs(configDataArray) do
		config_data_center.dataValue = v

		if (fucDict[sumName] == nil) then
			local funTmp1 = loadstring("config_data_center.resultValue = config_data_center.dataValue."..IDName1)
			local funTmp2 = loadstring("config_data_center.resultValue2 = config_data_center.dataValue."..IDName2)
			local funTmp3 = loadstring("config_data_center.resultValue3 = config_data_center.dataValue."..IDName3)
			local funInfo = {}
			funInfo.func1 = funTmp1
			funInfo.func2 = funTmp2
			funInfo.func3 = funTmp3
			fucDict[sumName] = funInfo
		end

		local func1 = fucDict[sumName].func1
		local func2 = fucDict[sumName].func2
		local func3 = fucDict[sumName].func3
		func1()
		func2()
		func3()

		if (config_data_center.resultValue == ID1 and config_data_center.resultValue2 == ID2 
			and config_data_center.resultValue3 == ID3) then
			retValue = v
			break
		end
	end

	return retValue
end

function this.getConfigDataByFourID(configName, IDName1, ID1, IDName2, ID2, IDName3, ID3, IDName4, ID4)
	local retValue = nil
	local configDataArray = this.getConfigData(configName)
	local sumName = IDName1.."_"..IDName2.."_"..IDName3.."_"..IDName4
	for k, v in ipairs(configDataArray) do
		config_data_center.dataValue = v

		if (fucDict[sumName] == nil) then
			local funTmp1 = loadstring("config_data_center.resultValue = config_data_center.dataValue."..IDName1)
			local funTmp2 = loadstring("config_data_center.resultValue2 = config_data_center.dataValue."..IDName2)
			local funTmp3 = loadstring("config_data_center.resultValue3 = config_data_center.dataValue."..IDName3)
			local funTmp4 = loadstring("config_data_center.resultValue4 = config_data_center.dataValue."..IDName4)
			local funInfo = {}
			funInfo.func1 = funTmp1
			funInfo.func2 = funTmp2
			funInfo.func3 = funTmp3
			funInfo.func4 = funTmp4
			fucDict[sumName] = funInfo
		end

		local func1 = fucDict[sumName].func1
		local func2 = fucDict[sumName].func2
		local func3 = fucDict[sumName].func3
		local func4 = fucDict[sumName].func4
		func1()
		func2()
		func3()
		func4()
		if (config_data_center.resultValue == ID1 and config_data_center.resultValue2 == ID2 
			and config_data_center.resultValue3 == ID3 and config_data_center.resultValue4 == ID4) then
			retValue = v
			break
		end
	end

	return retValue
end