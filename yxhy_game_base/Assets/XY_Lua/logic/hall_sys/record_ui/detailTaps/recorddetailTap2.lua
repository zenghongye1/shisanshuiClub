local base = require("logic.framework.ui.uibase.ui_childwindow")
local Tab_class = class("recorddetailTap2",base)
function Tab_class:ctor()
	base.ctor(self)
end

function Tab_class:OnInit()
	base.OnInit(self)
end

function Tab_class:OnOpen()
	base.OnOpen(self)
	Trace("Tab_b OnOpen")
end

function Tab_class:OnClose()
	base.OnClose(self)
	Trace("Tab_b OnClose")
end

function Tab_class:UpdateView(_data, _isTimer)

	if not self.updateTimer then
	    self.updateTimer = FrameTimer.New(function()
	        self:UpdateView(_data, true)
	        self.updateTimer = nil
	      end,1,1)
	    self.updateTimer:Start()
	end
	if not _isTimer then
		local scrollViewGrid = child(self.gameObject.transform, "ScrollView/Grid")
		if scrollViewGrid then
		    for i = (scrollViewGrid.transform.childCount -1),0,-1 do
		      GameObject.Destroy(scrollViewGrid.transform:GetChild(i).gameObject)
		    end
		end

		return
	end

	if not _data then
		return
	end

	local datatable = _data
	if datatable.accountc==nil then
		return
	end
	local rewards = datatable.accountc.rewards

	local Label_blank = child(self.gameObject.transform, "Label_blank")
	if Label_blank then
		Label_blank.gameObject:SetActive(not rewards or table.getCount(rewards) <1)
	end

	if rewards==nil or table.getCount(rewards)==0 then
		return
	end
	if datatable.rank_id==nil then
		return
	end

	local scrollViewGrid = child(self.gameObject.transform, "ScrollView/Grid")
	if not scrollViewGrid then
		return
	end
	
	local item_model = child(self.gameObject.transform, "ScrollView/item_model")
	if not item_model then
		return
	end
	local i = 1
	for j=1,#datatable.rank_id do
		local key=datatable.rank_id[j]
		local item = child(scrollViewGrid.gameObject.transform, "item_"..i)
		if not item then
			item = NGUITools.AddChild(scrollViewGrid.gameObject, item_model.gameObject)
			item.name="item_"..i
			item.gameObject:SetActive(true)
			componentGet(scrollViewGrid.gameObject,"UIGrid"):Reposition()   
		end
		local lab_number=child(item.transform,"sp_number/lab_number")
		componentGet(lab_number.gameObject,"UILabel").text =i

		local lab_name=child(item.transform,"tex_photo/lab_name")
		componentGet(lab_name.gameObject,"UILabel").text=rewards[key].nickname

		if tonumber(datatable.uid)==tonumber(rewards[key].uid) then
			child(item.transform,"tex_photo/fangzhu").gameObject:SetActive(true)
		else 
			child(item.transform,"tex_photo/fangzhu").gameObject:SetActive(false)
		end
		local lab_win=child(item.transform,"tex_photo/lab_win")
		local nWinNums = rewards[key].hu_num

		componentGet(lab_win.gameObject,"UILabel").text="胜局:"..tostring(nWinNums)

		local lab_gnumber=componentGet(child(item.transform,"lab_gnumber").gameObject,"UILabel")
		local lab_bnumber=componentGet(child(item.transform,"lab_bnumber").gameObject,"UILabel")
		local score = tonumber(rewards[key].all_score)
		print("score-----", score)
		if score >=0 then
			lab_gnumber.gameObject:SetActive(true)
			lab_bnumber.gameObject:SetActive(false)  
			lab_gnumber.text = "+"..score
		else 
			lab_bnumber.gameObject:SetActive(true)
			lab_gnumber.gameObject:SetActive(false)
			lab_bnumber.text = score
		end 
		local tex_photo=child(item.transform,"tex_photo") 
		local imagetype=rewards[key].img.type 
		local imageurl=rewards[key].img.url
		HeadImageHelper.SetImage(componentGet(tex_photo.gameObject,"UITexture"),imagetype,imageurl)

		i = i+1
	end
	
	componentGet(child(self.gameObject.transform, "ScrollView"), "UIScrollView"):ResetPosition()
end

return Tab_class