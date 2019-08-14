local base = require "logic/mahjong_sys/components/base/comp_mjOperatorcard"
local comp_mjOperatorcard_fuzhou = class("comp_mjOperatorcard_fuzhou", base)



function comp_mjOperatorcard_fuzhou:GetWidth()
	return mahjongConst.MahjongOffset_x * 3
end

--[[--
 * @Description: 显示  
 ]]
function comp_mjOperatorcard_fuzhou:Show(operData, operCardList)
	self.operData = operData
	self.itemList = operCardList
    self.operData.card = operCardList[1].paiValue
	local xOffset = 0
	for i=1,#operCardList do
		operCardList[i]:SetParent(self.operObj.transform, false)

        operCardList[i]:SetState(MahjongItemState.inOperatorCard)

    	if (operData.operType == MahjongOperAllEnum.DarkBar or 
    		operData.operType == MahjongOperAllEnum.BrightBarLeft or 
    		operData.operType == MahjongOperAllEnum.BrightBarCenter or 
    		operData.operType == MahjongOperAllEnum.BrightBarRight or 
    		operData.operType == MahjongOperAllEnum.AddBar or 
    		operData.operType == MahjongOperAllEnum.AddBarLeft or 
    		operData.operType == MahjongOperAllEnum.AddBarCenter or 
    		operData.operType == MahjongOperAllEnum.AddBarRight) and i==4 then
    		operCardList[i]:DOLocalMove(Vector3(xOffset-mahjongConst.MahjongOffset_x*2, mahjongConst.MahjongOffset_y, 0), 0.05, false)
    	else
    		operCardList[i]:DOLocalMove(Vector3(xOffset, 0, 0), 0.05, false)
		end

    	if operData.operType == MahjongOperAllEnum.DarkBar and 
    		((i~=4 and self.viewSeat == 1) or self.viewSeat ~= 1) then
        	operCardList[i]:DOLocalRotate(Vector3(0, 0, 180), 0, DG.Tweening.RotateMode.Fast)
        else
        	operCardList[i]:DOLocalRotate(Vector3.zero, 0, DG.Tweening.RotateMode.Fast)
        end

        xOffset = xOffset + mahjongConst.MahjongOffset_x

        operCardList[i]:ShowShadow()

	end
end

--[[--
 * @Description: 在操作组上加一个牌  
 * @param:       isChangeToBright 是否变成明杠 
 ]]
function comp_mjOperatorcard_fuzhou:AddShow(operData, mj,isChangeToBright)
	mj:SetParent(self.operObj.transform, false)
    self.operData = operData
    self.operData.card = mj.paiValue
    mj:SetState(MahjongItemState.inOperatorCard)

	Trace("AddShow-----------self.operData "..tostring(self.operData))
	mj:DOLocalMove(
	self.itemList[2].transform.localPosition + Vector3(0, mahjongConst.MahjongOffset_y, 0), 
	0.05,
	false)
	mj:DOLocalRotate(Vector3.zero, 0, DG.Tweening.RotateMode.Fast)

    self.operData = operData
    mj:ShowShadow()
    table.insert(self.itemList,mj)

end

--[[--
 * @Description: 断线恢复  
 ]]
function comp_mjOperatorcard_fuzhou:ReShow( operData, operCardList )
	self.operData = operData
	self.itemList = operCardList
    self.operData.card = operCardList[1].paiValu
	local xOffset = 0
	for i=1,#operCardList do
		operCardList[i]:SetParent(self.operObj.transform, false)

        operCardList[i]:SetState(MahjongItemState.inOperatorCard)

    	if (operData.operType == MahjongOperAllEnum.DarkBar or 
    		operData.operType == MahjongOperAllEnum.BrightBarLeft or 
    		operData.operType == MahjongOperAllEnum.BrightBarCenter or 
    		operData.operType == MahjongOperAllEnum.BrightBarRight or 
    		operData.operType == MahjongOperAllEnum.AddBar or 
    		operData.operType == MahjongOperAllEnum.AddBarLeft or 
    		operData.operType == MahjongOperAllEnum.AddBarCenter or 
    		operData.operType == MahjongOperAllEnum.AddBarRight) and i==4 then
    		operCardList[i].transform.localPosition = Vector3(xOffset-mahjongConst.MahjongOffset_x*2, mahjongConst.MahjongOffset_y, 0)
    	else
    		operCardList[i].transform.localPosition = Vector3(xOffset, 0, 0)
		end

    	if operData.operType == MahjongOperAllEnum.DarkBar and i~=4 then
    		operCardList[i].transform.localEulerAngles =Vector3(0, 0, 180) 
    	else
        	operCardList[i].transform.localEulerAngles=Vector3.zero
        end

        xOffset = xOffset + mahjongConst.MahjongOffset_x

        operCardList[i]:ShowShadow()

	end
end


return comp_mjOperatorcard_fuzhou
