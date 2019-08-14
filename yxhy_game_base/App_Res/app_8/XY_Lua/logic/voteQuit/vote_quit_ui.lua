
require("logic/voteQuit/vote_quit_view")
vote_quit_ui = ui_base.New()

local closeBtn
local contentLabel
local btnYes
local btnNo

local voteView

local callback = nil
local playerNum
local playerList
local playName
local voteView = vote_quit_view.New()

local this = vote_quit_ui
local currTime=23
local timeTabel
local timeLabel
local grid
local item

local itemGoList = {}

function this.Show(name, boolcallback, players, time)
	if this.gameObject==nil then
		--require ("logic/open_room/get_in_ui")
		this.gameObject = newNormalUI("app_8/ui/votequit_ui/vote_quit")
	else
		this.gameObject:SetActive(true)
		--voteView:Show(players)
		contentLabel.text = this.GetStr()
	end
	playName = name
	callback = boolcallback
	playerHeadUrlList = players
	this.CalTime(time or 30)
    this.Init()
	this.UpdateGrid()
	playerList=this.GetAllPlayerData()
end

function this.ChangeTime()
	timeLabel.text=currTime
	currTime=currTime-1
end

function  this.CalTime( time)
	currTime = time
	timeTabel=Timer.New(this.ChangeTime,1,time)
	timeTabel:Start()
end

function this.Start()
	this.RegisterEvents()
end

function this.AddVote(value, viewSeat)

	if this.gameObject == nil or this.gameObject.activeSelf == false then
		return
	end
	local index=-1
    for i=1,#playerList,1
    do
       if playerList[i].viewSeat == viewSeat
       then
          index=i
       end
    end
    if index == -1 then return end
	if value then 
		itemGoList[index].transform:GetComponentInChildren(typeof(UILabel)).text="同意"
	else
		itemGoList[index].transform:GetComponentInChildren(typeof(UILabel)).text="拒绝"
	end
	--voteView:AddVote(value,viewSeat)
end


function this.Init()
	closeBtn = child(this.transform, "panel/btn_close")
	btnYes = child(this.transform, "panel/btn1")
	btnNo = child(this.transform, "panel/btn2")
	contentLabel = subComponentGet(this.transform, "panel/contentLabel", typeof(UILabel))
	contentLabel.text = this.GetStr()
	timeLabel=subComponentGet(this.transform,"panel/time/time","UILabel")
	timeLabel.text=currTime
	grid=child(this.transform,"panel/Grid")
	item=child(this.transform,"panel/Grid/item")
	if #itemGoList == 0 then
		table.insert(itemGoList, item.gameObject)
	end

end

function this.RegisterEvents()
	addClickCallback(closeBtn,this.OnClose,closeBtn.gameObject)
	addClickCallback(btnYes, this.OnYesClick, btnYes.gameObject)
	addClickCallback(btnNo, this.OnNoClick, btnNo.gameObject)
end

function this.GetStr()
	return "[bb0d01]" .. playName .. "[-][7e5239]想要解散房间\n您是否同意解散？[-]"
end


function this.OnClose()
	ui_sound_mgr.PlaySoundClip("app_8/sound/common/audio_button_click")
	if callback ~= nil then
		callback(false)
	end
	this.Hide()
end

function this.OnYesClick()
	if callback ~= nil then
		callback(true)
	end
	this.Hide()
end

function this.OnNoClick()
	if callback ~= nil then
		callback(false)
	end
	this.Hide()
end

function this.Hide()
	if this.gameObject ~= nil then
		timeTabel:Stop()
		this.gameObject:SetActive(false)
		this.ClearTexture()
	end
end


function this.OnDestroy()
	this:UnRegistUSRelation()
	this.itemGoList = {}
end

function  this.UpdateGrid()
	voteView:UpdateChildList(itemGoList,roomdata_center.maxplayernum,grid.gameObject,item.gameObject)
	local tempGrid=grid:GetComponent("UIGrid")
	-- local count=grid.transform.childCount
	-- itemList = {}
	-- for i=0,count-1,1 do
	-- 	grid.transform:GetChild(i).gameObject:SetActive(true)
	-- 	table.insert(itemList,grid.transform:GetChild(i).gameObject)
	-- end
	local tempList=this.GetAllPlayerData()
	-- logError(#itemList, "!!!!")
	-- for i = 1, #itemList do
	-- 	logError(itemList[i])
	-- end
    for i=1,#tempList,1
    do
        Trace("headurl:"..tempList[i].headurl..":"..tostring(i))
        --DownloadCachesMgr.Instance:LoadImage(tempList[i].headurl,function( code,texture )
		--grid.transform:GetChild(0).gameObject.transform:GetComponentInChildren(typeof(UITexture)).mainTexture = texture 
		--grid.transform:GetChild(i-1).gameObject.transform:GetComponentInChildren(typeof(UILabel)).text ="" 
        -- itemList[i].transform:GetComponentInChildren(typeof(UITexture)).mainTexture = texture 
        -- itemList[i].transform:GetComponentInChildren(typeof(UILabel)).text ="" 
        itemGoList[i]:SetActive(true)
        --itemGoList[i].transform:GetComponentInChildren(typeof(UITexture)).mainTexture = texture 
        hall_data.getuserimage(itemGoList[i].transform:GetComponentInChildren(typeof(UITexture)),2,tempList[i].headurl)
        itemGoList[i].transform:GetComponentInChildren(typeof(UILabel)).text ="" 
	    --end)
    end
	--[[for i=1,roomdata_center.maxplayernum,1
    do
        local tempUserData=room_usersdata_center.GetUserByViewSeat(i)
        DownloadCachesMgr.Instance:LoadImage(tempUserData.headurl,function( code,texture )
		grid.transform:GetChild(i-1).gameObject.transform:GetComponentInChildren(typeof(UITexture)).mainTexture = texture 
	    end)
    end--]]
    --UIGrid位置刷新
	tempGrid:Reposition()
end

--获取所有在线玩家的信息
function this.GetAllPlayerData()
	local userList={}
	for i=roomdata_center.maxplayernum,1,-1
	do
	   local user= room_usersdata_center.GetUserByViewSeat(i)
	   table.insert(userList,user)
    end
    return userList
end
--清空图片缓存
function  this.ClearTexture()
	-- local count=grid.transform.childCount
	-- grid.transform:GetChild(0).gameObject.transform:GetComponentInChildren(typeof(UILabel)).text ="" 
	-- for i=1,count-1,1 do
	-- 	if grid.transform:GetChild(i).gameObject.transform:GetComponentInChildren(typeof(UITexture)).mainTexture ~=nil then
	-- 		GameObject.Destroy(grid.transform:GetChild(i).gameObject.transform:GetComponentInChildren(typeof(UITexture)).mainTexture)
	-- 	end
	-- end
	for i = 1, #itemGoList do
		local texture = subComponentGet(itemGoList[i].transform, "Texture", typeof(UITexture))
		if texture.mainTexture ~= nil then
			texture.mainTexture = UnityEngine.Texture2D.whiteTexture
			--GameObject.Destroy(texture.mainTexture)
		end
	end
end