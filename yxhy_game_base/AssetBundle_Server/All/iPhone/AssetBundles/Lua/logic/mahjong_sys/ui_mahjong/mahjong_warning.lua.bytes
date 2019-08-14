mahjong_warning = ui_base.New()

local this = mahjong_warning
local data = nil
local warning_timer = nil

function this.Show(context, time)
	data = {
		context = context,
    	time = time,
	}
	if IsNil(this.gameObject) then
		local gameObject_prefab = newNormalObjSync(data_center.GetResMJCommPath().."/ui/game/mahjong_warning", typeof(GameObject))
		this.gameObject = newobject(gameObject_prefab)
		this.transform = this.gameObject.transform
    	this.gameObject.transform:SetParent(mahjong_ui.transform, false)
	elseif this.gameObject.activeSelf==false then
		this.gameObject:SetActive(true)
    	this.SetContext(context, time)
	end
end

function this.Hide()
	if not IsNil(this.gameObject) then		
 		this.gameObject:SetActive(false)
 	end
 	data = nil
 	if warning_timer then
 		warning_timer:Stop()
 		warning_timer = nil
 	end
end

function this.Awake()
 	this.FindChild()
end

function this.Start()
	if data ~=nil then
		this.SetContext(data.context, data.time)
	end
end

function this.OnDestroy()
	this.gameObject = nil
end

function this.FindChild()
	this.contextLabel_trans = child(this.transform,"sp_bg/Label")
end


function this.SetContext(context, time)
	if this.contextLabel_comp == nil then
		this.contextLabel_comp = componentGet(this.contextLabel_trans, "UILabel")
	end
	this.contextLabel_comp.text = tostring(context)
	if warning_timer then
 		warning_timer:Stop()
 		warning_timer = nil
 	end 
	warning_timer = Timer.New(function()
		this.Hide()
	end, time, 1)
	warning_timer:Start() 
end