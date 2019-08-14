local base = require("logic.framework.ui.uibase.ui_childwindow")
local Tab_class = class("recorddetailTap1",base)
function Tab_class:ctor()
	base.ctor(self)
end

function Tab_class:OnInit()
	base.OnInit(self)
end

function Tab_class:OnOpen()
	base.OnOpen(self)
	Trace("Tab_a OnOpen")
end

function Tab_class:OnClose()
	base.OnClose(self)
	Trace("Tab_a OnClose")
end

function Tab_class:UpdateView(_data, _isTimer)

	--临时处理再次打开界面错乱问题
	if not self.updateTimer then
	    self.updateTimer = FrameTimer.New(function()
	        self:UpdateView(_data, true)
	        self.updateTimer = nil
	        UI_Manager:Instance():GetUiFormsInShowList("recorddetails_ui"):RefreshDepth()
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
	if datatable.clog ==nil or table.getCount(datatable.clog)==0 then
		return
	end

	local Label_blank = child(self.gameObject.transform, "Label_blank")
	if Label_blank then
		Label_blank.gameObject:SetActive(not datatable.clog or table.getCount(datatable.clog) <1)
	end

	local scrollViewGrid = child(self.gameObject.transform, "ScrollView/Grid")
	if not scrollViewGrid then
		return
	end

	local item_model = child(self.gameObject.transform, "ScrollView/item_model")
	if not item_model then
		return
	end
	for i=1,table.getCount(datatable.clog) do 
		local item = child(scrollViewGrid.gameObject.transform, "item_"..i)
		if not item then
			item = NGUITools.AddChild(scrollViewGrid.gameObject, item_model.gameObject)
			item.name="item_"..i
			item.gameObject:SetActive(true)
			componentGet(scrollViewGrid.gameObject,"UIGrid"):Reposition()

			addClickCallbackSelf(item.gameObject, function(obj)
				
				Trace("OpenCardDetail---"..i)
				local rounds = i
				report_sys.EventUpload(17)

				UI_Manager:Instance():ShowUiForms("carddetails_ui",UiCloseType.UiCloseType_CloseNothing,function() 
                                    Trace("Close carddetails_ui")
                                  end,datatable,rounds)

			end, self)
		end

		local lab_number=child(item.transform,"sp_number/lab_number") 
		componentGet(lab_number.gameObject,"UILabel").text=i
		local k = 1
		for j,reward in pairs(datatable.clog[i].rewards) do 
			subComponentGet(item.transform,"sv_user","UIPanel").depth = 2
			local tex_photo=child(item.transform, "sv_user/grid_player/tex_photo_"..k)
			if tex_photo==nil then
				local old_tex_photo=child(item.transform, "sv_user/grid_player/tex_photo_1")
				tex_photo=NGUITools.AddChild(child(item.transform,"sv_user/grid_player").gameObject,old_tex_photo.gameObject)
				tex_photo.name="tex_photo_"..k
				componentGet(child(item.transform,"sv_user/grid_player"),"UIGrid"):Reposition()
			end

			local imagetype=datatable.accountc.rewards[reward._chair].img.type 
			local imageurl=datatable.accountc.rewards[reward._chair].img.url
			HeadImageHelper.SetImage(componentGet(tex_photo.gameObject,"UITexture"),imagetype,imageurl)
			local lab_name=child(tex_photo.transform,"lab_name")
			componentGet(lab_name.gameObject,"UILabel").text=datatable.accountc.rewards[reward._chair].nickname

			local lab_earn = child(tex_photo.transform,"lab_reward")
			local lab_earn_red = child(tex_photo.transform,"lab_reward_red")
			local score = tonumber(reward.all_score) or 0
			if score >=0 then
				lab_earn.gameObject:SetActive(true)
				lab_earn_red.gameObject:SetActive(false)

				componentGet(lab_earn.gameObject,"UILabel").text = "+"..score
			else
				lab_earn.gameObject:SetActive(false)
				lab_earn_red.gameObject:SetActive(true)

				componentGet(lab_earn_red.gameObject,"UILabel").text = score
			end

			k = k+1
		end
	end

	componentGet(child(self.gameObject.transform, "ScrollView"), "UIScrollView"):ResetPosition()
end

return Tab_class