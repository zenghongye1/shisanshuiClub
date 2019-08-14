--[[--
 * @Description: 提示吃碰杠操作数据缓存
 * @Author:      ShushingWong
 * @FileName:    operatorcachedata.lua
 * @DateTime:    2017-06-22 11:51:24
 ]]

 operatorcachedata = {}

 local this = operatorcachedata

 local operTipsList = {}

 function this.AddOperTips( operData )
 	table.insert(operTipsList,operData)
 end

 function this.ClearOperTipsList()
 	operTipsList = {}
 end

 function this.GetOperTipsList( ... )
 	return operTipsList
 end

 function this.GetOpTipsTblByType( operType )
 	for i,v in ipairs(operTipsList) do
 		if v.operType == operType then
 			return v.operTbl
 		end
 	end
 end