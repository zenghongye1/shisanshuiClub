local mode_comp_base = require "logic/mahjong_sys/components/base/mode_comp_base"

local comp_mjOperatorcard = class("comp_mjOperatorcard", mode_comp_base)


function comp_mjOperatorcard:ctor()
	self.name = "comp_operatorcard"
	self.operObj =nil --操作组对象
	self.operData = nil --操作组数据
	self.keyItem = nil --关键牌，通过需要做特殊旋转的牌
	self.itemList = {} --操作组麻将列表
	self.viewSeat = 0 --玩家视图座位

	self:CreateOperObj()
end

function comp_mjOperatorcard:CreateOperObj()
	self.operObj = GameObject.New()
	self.operObj.name = "oper_root"
end

--[[--
 * @Description: 获取总宽度  
 ]]
function comp_mjOperatorcard:GetWidth()
	if self.operData.operType == MahjongOperAllEnum.Collect then
		return mahjongConst.MahjongOffset_x * 3
	end

	if self.operData.operType == MahjongOperAllEnum.TripletLeft or
		self.operData.operType == MahjongOperAllEnum.TripletCenter or
		self.operData.operType == MahjongOperAllEnum.TripletRight then
		return mahjongConst.MahjongOffset_x * 2 + mahjongConst.MahjongOffset_z
	end

	if self.operData.operType == MahjongOperAllEnum.DarkBar then
		return mahjongConst.MahjongOffset_x * 4
	end

	if self.operData.operType == MahjongOperAllEnum.BrightBarLeft or
		self.operData.operType == MahjongOperAllEnum.BrightBarCenter or
		self.operData.operType == MahjongOperAllEnum.BrightBarRight then
		return mahjongConst.MahjongOffset_x * 3 + mahjongConst.MahjongOffset_z
	end

	if self.operData.operType == MahjongOperAllEnum.AddBar or
		self.operData.operType == MahjongOperAllEnum.AddBarLeft or
		self.operData.operType == MahjongOperAllEnum.AddBarCenter or
		self.operData.operType == MahjongOperAllEnum.AddBarRight then
		return mahjongConst.MahjongOffset_x * 3 + mahjongConst.MahjongOffset_z
	end

	return 0
end

--[[--
 * @Description: 显示  
 ]]
function comp_mjOperatorcard:Show(operData, operCardList)
	self.operData = operData
	self.operData.card = operCardList[1].paiValue
	self.itemList = operCardList
	local keyIndex = operData:GetKeyCardIndex()
	if(keyIndex>0) then
		self.keyItem = operCardList[keyIndex]
	end
	local xOffset = 0
	for i=1,#operCardList do
		operCardList[i]:SetParent(self.operObj.transform, false)

        operCardList[i]:SetState(MahjongItemState.inOperatorCard)

		if(i == keyIndex) then
			operCardList[i]:DOLocalMove(

                Vector3(xOffset, 0, mahjongConst.MahjongOffset_z / 4-mahjongConst.MahjongOffset_x/2), 
                0.05,
                false)
            operCardList[i]:DOLocalRotate(Vector3(0,90,0), 0, DG.Tweening.RotateMode.Fast)
        else
        	operCardList[i]:DOLocalMove(Vector3(xOffset, 0, 0), 0.05, false)
        	if operData.operType == MahjongOperAllEnum.DarkBar and i~=1 then
            	operCardList[i]:DOLocalRotate(Vector3(0, 0, 180), 0, DG.Tweening.RotateMode.Fast)
            else
            	operCardList[i]:DOLocalRotate(Vector3.zero, 0, DG.Tweening.RotateMode.Fast)
            end
        end

        if (i == keyIndex or i == keyIndex-1)then
            xOffset = xOffset + (mahjongConst.MahjongOffset_x+ mahjongConst.MahjongOffset_z)/ 2
        else
            xOffset = xOffset + mahjongConst.MahjongOffset_x
        end
        operCardList[i]:ShowShadow()
	end
end

--[[--
 * @Description: 在操作组上加一个牌  
 * @param:       isChangeToBright 是否变成明杠 
 ]]
function comp_mjOperatorcard:AddShow(operData, mj,isChangeToBright)
	mj:SetParent(self.operObj.transform, false)
	self.operData.card = mj.paiValue
    mj:SetState(MahjongItemState.inOperatorCard)

	if isChangeToBright then
		Trace("AddShow-----------self.operData "..tostring(self.operData))
		if self.operData.operType == MahjongOperAllEnum.TripletLeft or self.operData.operType == MahjongOperAllEnum.TripletCenter then
			mj:DOLocalMove(
			self.itemList[#self.itemList].transform.localPosition + Vector3(mahjongConst.MahjongOffset_x, 0, 0), 
			0.05,
			false)
        	mj:DOLocalRotate(Vector3.zero, 0, DG.Tweening.RotateMode.Fast)
        elseif self.operData.operType == MahjongOperAllEnum.TripletRight then
        	mj:DOLocalMove(
			self.itemList[1].transform.localPosition, 
			0.05,
			false)
        	mj:DOLocalRotate(Vector3.zero, 0, DG.Tweening.RotateMode.Fast)
        	for i,v in ipairs(self.itemList) do
        		v:DOLocalMove(
				v.transform.localPosition + Vector3(mahjongConst.MahjongOffset_x, 0, 0), 
				0.05,
				false)
        	end
        end
	else
		mj:DOLocalMove(
			self.keyItem.transform.localPosition + Vector3(0, 0, mahjongConst.MahjongOffset_x), 
			0.05,
			false)
        mj:DOLocalRotate(Vector3(0, 90, 0), 0, DG.Tweening.RotateMode.Fast)
    end
    self.operData = operData

    mj:ShowShadow()
    table.insert(self.itemList,mj)
end

--[[--
 * @Description: 断线恢复  
 ]]
function comp_mjOperatorcard:ReShow( operData, operCardList )
	self.operData = operData
	self.itemList = operCardList
	self.operData.card = operCardList[1].paiValue
	local keyIndex = operData:GetKeyCardIndex()
	if(keyIndex>0) then
		self.keyItem = operCardList[keyIndex]
	end
	local xOffset = 0
	for i=1,#operCardList do
		operCardList[i]:SetParent(self.operObj.transform, false)

        operCardList[i]:SetState(MahjongItemState.inOperatorCard)

		if(i == keyIndex) then

			operCardList[i].transform.localPosition = Vector3(xOffset, 0, mahjongConst.MahjongOffset_z / 4-mahjongConst.MahjongOffset_x/2)
            operCardList[i].transform.localEulerAngles = Vector3(0,90,0)
        else
        	operCardList[i].transform.localPosition = Vector3(xOffset, 0, 0)
        	if operData.operType == MahjongOperAllEnum.DarkBar and i~=1 then
            	operCardList[i].transform.localEulerAngles=Vector3(0, 0, 180)
            else
            	operCardList[i].transform.localEulerAngles=Vector3.zero
            end
        end

        if (i == keyIndex or i == keyIndex-1)then
            xOffset = xOffset + (mahjongConst.MahjongOffset_x+ mahjongConst.MahjongOffset_z)/ 2
        else
            xOffset = xOffset + mahjongConst.MahjongOffset_x
        end
        operCardList[i]:ShowShadow()
	end
end

function comp_mjOperatorcard:GetServerOperData()
	local tab = {0,0,0}
	-- 别人暗杠
	if this.viewSeat ~= 1 and this.operData.ucflag == 19 then
		return tab
	end
	tab[1] = self.operData.ucflag
	tab[2] = self.operData.card
	tab[3] = self.operData.operWho
	return tab
end


return comp_mjOperatorcard