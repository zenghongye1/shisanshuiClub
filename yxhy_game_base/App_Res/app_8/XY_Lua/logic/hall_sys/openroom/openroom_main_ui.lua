--[[--
 * @Description: 开房主界面逻辑处理
 * @Author:      shine
 * @FileName:    openroom_main_ui.lua
 * @DateTime:    2017-07-13 19:11:00
 ]]

require "logic/hall_sys/openroom/room_data"

openroom_main_ui = ui_base.New()
local this = openroom_main_ui

local toggleTbl = {}

function this.Awake()
end


function this.AppleVerifyHandler(  )
	--[[toggleTbl.shisanshuiToggle = subComponentGet(this.transform, "panel_openroom/Panel_Left/13shuiToggle", "UIToggle")
    if toggleTbl.shisanshuiToggle~=nil then
        toggleTbl.shisanshuiToggle.gameObject:SetActive(false)
    end]]
    --[[if toggleTbl.fzmjToggle.value then
        fuzhoumj_room_ui.AppleVerifyHandler()
    else
        shisangshui_room_ui.AppleVerifyHandler()
    end]]
end

function this.Show()
	room_data.InitData()
	if this.gameObject==nil then
		this.gameObject=newNormalUI("app_8/ui/openroom_ui/openroom_main_ui")
	else
		GameObject.Destroy(this.gameObject)
        this.gameObject=nil
	end
end


function this.Start()	
	toggleTbl.fzmjToggle = subComponentGet(this.transform, "panel_openroom/Panel_Left/majiangToggle", "UIToggle")
    if toggleTbl.fzmjToggle~=nil then
        addClickCallbackSelf(toggleTbl.fzmjToggle.gameObject,this.fzmj,this)
    end
	toggleTbl.shisanshuiToggle = subComponentGet(this.transform, "panel_openroom/Panel_Left/13shuiToggle", "UIToggle")
    if toggleTbl.shisanshuiToggle~=nil then
        addClickCallbackSelf(toggleTbl.shisanshuiToggle.gameObject,this.sss,this)
    end
	this.btnCreate = child(this.transform, "panel_openroom/CreateBtn")
	if this.btnCreate ~= nil then
		addClickCallbackSelf(this.btnCreate.gameObject, this.OnBtnCreateClick, this)
	end
  --  local roomcard=child(this.transform,"panel_openroom/roomcard/Label")
  --  if roomcard~=nil then
  --     componentGet(roomcard,"UILabel").text="x"..data_center.GetLoginUserInfo().card
  --  end
    local btn_close=child(this.transform,"panel_openroom/btn_close")
    if btn_close~=nil then
        addClickCallbackSelf(btn_close.gameObject,this.Hide,this)
    end	
     
    if LuaHelper.isAppleVerify ~= nil and LuaHelper.isAppleVerify then
        local lblTip = child(this.transform, "panel_openroom/Panel_Top/Label")
        if lblTip ~= nil then
        	lblTip.gameObject:SetActive(false)
        end
    end
	
----------------------------换皮十三水--------------------------------------     
	this.SetDefaultSelect(ENUM_GAME_TYPE.TYPE_SHISHANSHUI)
	toggleTbl.fzmjToggle.gameObject:SetActive(false)
	toggleTbl.shisanshuiToggle.gameObject:SetActive(true)
	toggleTbl.shisanshuiToggle.transform.localPosition = Vector3(-418,186,0)
-----------------------------------------------------------------------------
	
   --[[ local curGameID = nil
    if PlayerPrefs.HasKey("CUR_GAME_ID") then
    	curGameID = PlayerPrefs.GetString("CUR_GAME_ID")    	
    end
	logError(curGameID)
    if curGameID ~= nil then
    	this.SetDefaultSelect(curGameID)
    end  --]]  

    --用于苹果审核
    if LuaHelper.isAppleVerify ~= nil and LuaHelper.isAppleVerify then
        this.AppleVerifyHandler()
    end    
end
 

--[[--
 * @Description: 设置当前默认选择游戏
 ]]
function this.SetDefaultSelect(curGameID)
	
	if tonumber(curGameID) == ENUM_GAME_TYPE.TYPE_FUZHOU_MJ then
		toggleTbl.fzmjToggle:Set(true)
		toggleTbl.shisanshuiToggle:Set(false)
	elseif tonumber(curGameID) == ENUM_GAME_TYPE.TYPE_SHISHANSHUI then
		toggleTbl.fzmjToggle:Set(false)
		toggleTbl.shisanshuiToggle:Set(true)
	end
end

function this.fzmj()
    this.btnCreate.transform.localPosition={x=108.7,y=-272.2,z=0}
end
function this.sss()
    this.btnCreate.transform.localPosition={x=108.7,y=-272.2,z=0}
end
function this.Hide()
	if this.gameObject == nil then
		return
	else
		GameObject.Destroy(this.gameObject)
		this.gameObject = nil
	end
end


--///////////////////////////////外部获取接口start//////////////////////////////

function this.GetFzmjToggle()
	return toggleTbl.fzmjToggle
end

function this.GetShiSanShuiToggle()
	return toggleTbl.shisanshuiToggle
end
--///////////////////////////////外部获取接口end////////////////////////////////

 

--///////////////////////////////////点击事件处理start////////////////////////////////////////////

function this.OnBtnCreateClick(obj)
	waiting_ui.Show()
	this.Hide()	

	if toggleTbl.fzmjToggle.value then
    	local confData = fuzhoumj_room_ui.GetUserSelectData()
    	confData.gid = ENUM_GAME_TYPE.TYPE_FUZHOU_MJ		
    	PlayerPrefs.SetString("CUR_GAME_ID", confData.gid)
        --room_data.RequestFzMJCreateRoom(confData)
        room_data.SetFzmjRoomDataInfo(confData)
        roomdata_center.gameRuleStr = room_data.GetFZShareString()
        join_room_ctrl.CreateRoom(confData)
    elseif toggleTbl.shisanshuiToggle.value then
		local confData ={}
		local gameDataInfo = room_data.GetSssRoomDataInfo()
		confData["rounds"] = gameDataInfo.play_num
		confData["pnum"] = gameDataInfo.people_num		
		confData["leadership"] = gameDataInfo.isZhuang
		confData["joker"] = gameDataInfo.add_ghost
		confData["addColor"] = gameDataInfo.add_card
		confData["buyhorse"] = gameDataInfo.isChip
		confData["maxfan"] = gameDataInfo.max_multiple

		confData.gid = ENUM_GAME_TYPE.TYPE_SHISHANSHUI
		room_data.GetSssRoomDataInfo().gid = ENUM_GAME_TYPE.TYPE_SHISHANSHUI
		--room_data.RequestSssCreateRoom(confData)
		PlayerPrefs.SetString("CUR_GAME_ID", confData.gid)
		join_room_ctrl.CreateRoom(confData)
    end
end
--///////////////////////////////////点击事件处理end//////////////////////////////////////////////