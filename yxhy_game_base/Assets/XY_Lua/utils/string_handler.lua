--[[--
 * @Description: 用来封装更贴近逻辑层的一些字符串操作：
                 (1) 替换字符串中的逻辑占位符
 * @Author:      shine
 * @FileName:    string_handler.lua
 * @DateTime:    2017-05-16 14:20:39
 ]]


string_handler = {}
local this = string_handler

--[[--
 * @Description: 设置属性，根据特征字符串，用法如下：

 	local testStr = "攻击力是{ak}的一件武器，攻击力是{ak}哦，另外它的魔法增益是{mp}"
	require("utils/string_handler")
	testStr = string_handler.setProperty(testStr, "ak", 800)
	testStr = string_handler.setProperty(testStr, "mp", 100)
	Trace(testStr)  
	concole输出：攻击力是800的一件武器，攻击力是800哦，另外它的魔法增益是100

 * @param:       targetStr : 目标字符串
                 propName  ：属性名字，这个也是配置表里面的特征字符串，比如hp,mp,ak之类的
                 value     ：要替换成的值，比如800
 * @return:      结果字符串
 ]]
function this.setProperty(targetStr, propName, value)
	local patternStr = "{"..propName.."}"
	local posArray = string.find(targetStr, patternStr)
	if (posArray == nil) then
		local propNameTmp = string.lower(propName)
		patternStr = "{"..propNameTmp.."}"
		posArray = string.find(targetStr, string.lower(patternStr))
	end

	local retStr = targetStr
	if (posArray ~= nil) then
		retStr = string.gsub(targetStr, patternStr, value)
	end

	return retStr
end

--[[--
 * @Description: 得到格式转义后的字符串
                 因为NGUI天然支持了bbCode标签的子集，只需要特殊处理下换行即可  
 * @param:       string 原始字符串 
 * @return:      格式化后的字符串
 ]]
function formatTransfer(srcStr)
	local patternStr = "{n}"
	local posArray = string.find(srcStr, patternStr)
	local retStr = srcStr
	if (posArray ~= nil) then
		retStr = string.gsub(srcStr, patternStr, "\n")
	end

	return retStr
end

--[[--
 * @Description: 字符串分割函数,传入字符串和分隔符
 * @param:       str 原始字符串 
 * @return:      返回分割后的table
 ]]
function string.split(str, delimiter)
	if str==nil or str=='' or delimiter==nil then
		return nil
	end
	
    local result = {}
    for match in (str..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match)
    end
    return result
end