--[[--
 * @Description: 福州麻将开房ui逻辑
 * @Author:      huangxupeng,shine整理
 * @FileName:    fuzhoumj_room_ui.lua
 * @DateTime:    2017-07-13 11:28:08
 ]]

fuzhoumj_room_ui={}
local this=fuzhoumj_room_ui 

local toggleTbl = {}

local paramtable=
{
    ["halfpure"]=0,
    ["allpure"]=0,
    ["kindD"]=0,
    ["DkingD"]=0,
    ["rounds"]=0,
    ["pnum"]=0,
    ["settlement"]=0, 
}

local lblRoundTbl = {}


function this.Start()
    this.InitWidgets()
    this.SetWidgetValue()
     
    --用于苹果审核
    if LuaHelper.isAppleVerify ~= nil and LuaHelper.isAppleVerify then
        this.AppleVerifyHandler()
    end     
end

function  this.Hide()
    if not IsNil(this.gameObject) then 
		GameObject.Destroy(this.gameObject)
        this.gameObject=nil
	end
end

function this.GetPlayerprefs()
    
end

function this.InitWidgets()    
    toggleTbl.toggle_halfpure = subComponentGet(this.transform, "toggletype_01/toggle_grid/toggle_01", "UIToggle")
    toggleTbl.toggle_allpure = subComponentGet(this.transform, "toggletype_01/toggle_grid/toggle_02", "UIToggle")
    toggleTbl.toggle_kingD = subComponentGet(this.transform, "toggletype_01/toggle_grid/toggle_03", "UIToggle")
    toggleTbl.toggle_DkingD = subComponentGet(this.transform, "toggletype_01/toggle_grid/toggle_04", "UIToggle")

    toggleTbl.toggle_pnum_grid = child(this.transform, "toggletype_02/toggle_grid")
    toggleTbl.toggle_pnum_4 = subComponentGet(this.transform, "toggletype_02/toggle_grid/toggle_01", "UIToggle")
    toggleTbl.toggle_pnum_3 = subComponentGet(this.transform, "toggletype_02/toggle_grid/toggle_02", "UIToggle")
    toggleTbl.toggle_pnum_2 = subComponentGet(this.transform, "toggletype_02/toggle_grid/toggle_03", "UIToggle")
    addClickCallbackSelf(toggleTbl.toggle_pnum_4.gameObject,function ()this.UpdateRound(4) end,this)
    addClickCallbackSelf(toggleTbl.toggle_pnum_3.gameObject,function ()this.UpdateRound(3) end,this)
    addClickCallbackSelf(toggleTbl.toggle_pnum_2.gameObject,function ()this.UpdateRound(2) end,this)
    toggleTbl.toggle_rounds_grid = child(this.transform, "toggletype_03/toggle_grid")
    toggleTbl.toggle_rounds_4 = subComponentGet(this.transform, "toggletype_03/toggle_grid/toggle_01", "UIToggle")
    toggleTbl.toggle_rounds_8 = subComponentGet(this.transform, "toggletype_03/toggle_grid/toggle_02", "UIToggle")
    toggleTbl.toggle_rounds_16 = subComponentGet(this.transform, "toggletype_03/toggle_grid/toggle_03", "UIToggle")

    toggleTbl.toggle_settlement_grid = child(this.transform, "toggletype_04/toggle_grid")
    toggleTbl.toggle_settlement_1 = subComponentGet(this.transform, "toggletype_04/toggle_grid/toggle_01", "UIToggle")
    toggleTbl.toggle_settlement_2 = subComponentGet(this.transform, "toggletype_04/toggle_grid/toggle_02", "UIToggle")        

    lblRoundTbl.lblRoundObjSel1 = child(this.transform, "toggletype_03/toggle_grid/toggle_01/lab_select")
    lblRoundTbl.lblRoundObjNo1 = child(this.transform, "toggletype_03/toggle_grid/toggle_01/lab_noselect")

    lblRoundTbl.lblRoundSel1 = componentGet(lblRoundTbl.lblRoundObjSel1, "UILabel")
    lblRoundTbl.lblRoundNo1 = componentGet(lblRoundTbl.lblRoundObjNo1, "UILabel")    

    lblRoundTbl.lblRoundObjSel2 = child(this.transform, "toggletype_03/toggle_grid/toggle_02/lab_select")
    lblRoundTbl.lblRoundObjNo2 = child(this.transform, "toggletype_03/toggle_grid/toggle_02/lab_noselect")

    lblRoundTbl.lblRoundSel2 = componentGet(lblRoundTbl.lblRoundObjSel2, "UILabel")
    lblRoundTbl.lblRoundNo2 = componentGet(lblRoundTbl.lblRoundObjNo2, "UILabel")  

    lblRoundTbl.lblRoundObjSel3 = child(this.transform, "toggletype_03/toggle_grid/toggle_03/lab_select")
    lblRoundTbl.lblRoundObjNo3 = child(this.transform, "toggletype_03/toggle_grid/toggle_03/lab_noselect")

    lblRoundTbl.lblRoundSel3 = componentGet(lblRoundTbl.lblRoundObjSel3, "UILabel")
    lblRoundTbl.lblRoundNo3 = componentGet(lblRoundTbl.lblRoundObjNo3, "UILabel")     
end

function this.SetToggleState(toggle, value)
    if value == 1 then
        toggle:Set(true)
    else
        toggle:Set(false)
    end
end

function this.SetWidgetValue()
    local fzmjroomDataInfo = room_data.GetFzmjRoomDataInfo()
    for i,v in pairs(paramtable)do
        if PlayerPrefs.HasKey(i) then
            fzmjroomDataInfo[i]=tonumber(PlayerPrefs.GetString(i))
        end
    end
    if fzmjroomDataInfo ~= nil then        
        this.SetToggleState(toggleTbl.toggle_halfpure, fzmjroomDataInfo.halfpure)
        this.SetToggleState(toggleTbl.toggle_halfpure, fzmjroomDataInfo.allpure)        
        this.SetToggleState(toggleTbl.toggle_kingD, fzmjroomDataInfo.kindD)
      --  this.SetToggleState(toggleTbl.toggle_DkingD, fzmjroomDataInfo.DkingD) 
        if tonumber(fzmjroomDataInfo.pnum) == 4 then
            this.SetToggleState(toggleTbl.toggle_pnum_4, 1)
            this.UpdateRound(4)
        elseif tonumber(fzmjroomDataInfo.pnum)  == 3 then
            this.SetToggleState(toggleTbl.toggle_pnum_3, 1)
            this.UpdateRound(3)
        else
            this.SetToggleState(toggleTbl.toggle_pnum_2, 1)
            this.UpdateRound(2)
        end

        if tonumber(fzmjroomDataInfo.rounds) == 4 then
            this.SetToggleState(toggleTbl.toggle_rounds_4, 1)
        elseif tonumber(fzmjroomDataInfo.rounds) == 8 then
            this.SetToggleState(toggleTbl.toggle_rounds_8, 1)
        else
            this.SetToggleState(toggleTbl.toggle_rounds_16, 1)
        end

        if tonumber(fzmjroomDataInfo.settlement) == 0 then
            this.SetToggleState(toggleTbl.toggle_settlement_1, 1)
        else
            this.SetToggleState(toggleTbl.toggle_settlement_2, 1)
        end
    end
    --this.InitButton()
end

function this.InitButton()
    local btninfo=room_data.GetButtonInfo()
    this.ChangeButtonLabel(toggleTbl.toggle_halfpure,btninfo.halfpure)
    this.ChangeButtonLabel(toggleTbl.toggle_kingD, btninfo.kindD)
    this.ChangeButtonLabel(toggleTbl.toggle_pnum_4,btninfo.pnum[1])
    this.ChangeButtonLabel(toggleTbl.toggle_pnum_3,btninfo.pnum[2])
    this.ChangeButtonLabel(toggleTbl.toggle_pnum_2,btninfo.pnum[3])
    this.ChangeButtonLabel(toggleTbl.toggle_rounds_4,btninfo.rounds[1])
    this.ChangeButtonLabel(toggleTbl.toggle_rounds_8,btninfo.rounds[2])
    this.ChangeButtonLabel(toggleTbl.toggle_rounds_16,btninfo.rounds[3])
    this.ChangeButtonLabel(toggleTbl.toggle_settlement_1,btninfo.settlement[1])
    this.ChangeButtonLabel(toggleTbl.toggle_settlement_2,btninfo.settlement[2])
end

function this.ChangeButtonLabel(button,detail)
    local label_1=child(button.transform,"lab_select") 
    local label_2=child(button.transform,"lab_noselect")
    componentGet(label_1,"UILabel").text=detail
    componentGet(label_2,"UILabel").text=detail
end

function this.GetUserSelectData()
    local t={
    ["halfpure"]=0,
    ["allpure"]=0,
    ["kindD"]=0,
    ["DkingD"]=0,
    ["rounds"]=0,
    ["pnum"]=0,
    ["settlement"]=0, 
    }

    for i=0,toggleTbl.toggle_pnum_grid.transform.childCount-1,1 do
        local toggle_pnum=toggleTbl.toggle_pnum_grid.transform:GetChild(i)                
        if componentGet(toggle_pnum, "UIToggle").value==true then
            t["pnum"]= 4-i
        end
    end
    
    for i=0,toggleTbl.toggle_rounds_grid.transform.childCount-1,1 do
        local toggle_rounds = toggleTbl.toggle_rounds_grid.transform:GetChild(i)
        if componentGet(toggle_rounds, "UIToggle").value==true then            
            t["rounds"]= 2 ^ (i+2)
        end
    end
    for i=0,toggleTbl.toggle_settlement_grid.transform.childCount-1,1 do
        local toggle_settlement=toggleTbl.toggle_settlement_grid.transform:GetChild(i)
        if componentGet(toggle_settlement, "UIToggle").value==true then
            t["settlement"]= i
        end
    end
    if componentGet(toggleTbl.toggle_halfpure.gameObject, "UIToggle").value==true then
        t["halfpure"]=1
        t["allpure"]=1 
    end
  --  if componentGet(toggleTbl.toggle_allpure.gameObject, "UIToggle").value==true then
 --       paramtable["allpure"]=1
 --   end
    if componentGet(toggleTbl.toggle_kingD.gameObject, "UIToggle").value==true then
        t["kindD"]=1
    end
    --[[if componentGet(toggleTbl.toggle_DkingD.gameObject, "UIToggle").value==true then
        paramtable["DkingD"]=1
    end]]-- 
    for i ,v in pairs(t) do 
        PlayerPrefs.SetString(i,v) 
        local fzmjroomDataInfo = room_data.GetFzmjRoomDataInfo()
        fzmjroomDataInfo[i]=v 
    end 
    return t
end
 
function this.EnterGameReq(dataTbl) 
    local gameData = dataTbl.data
    local t = dataTbl.data.cfg
  
    gameData["pnum"] = t["pnum"]
    gameData["rounds"] = t["rounds"]
    gameData["nHalfColor"] = t["halfpure"]
    gameData["nOneColor"] = t["allpure"]
    gameData["nGoldDragon"] = t["kindD"]
    gameData["nSingleGold"] = t["DkingD"]
    gameData["nGunAll"] = (t["settlement"] == 0) and 1 or 0
    gameData["nGunOne"] = (t["settlement"] == 1) and 1 or 0


    majong_request_interface.EnterGameReq(gameData)
end

function this.UpdateRound(number)
    if LuaHelper.isAppleVerify ~= nil and LuaHelper.isAppleVerify then
        this.AppleVerifyHandler()
    else
        lblRoundTbl.lblRoundSel1.text = "4局（房卡X"..room_data.GetRoundInfo()[tostring(number)]["4"].."）"
        lblRoundTbl.lblRoundNo1.text = "4局（房卡X"..room_data.GetRoundInfo()[tostring(number)]["4"].."）"

        lblRoundTbl.lblRoundSel2.text = "8局（房卡X"..room_data.GetRoundInfo()[tostring(number)]["8"].."）"
        lblRoundTbl.lblRoundNo2.text = "8局（房卡X"..room_data.GetRoundInfo()[tostring(number)]["8"].."）"

        lblRoundTbl.lblRoundSel3.text = "16局（房卡X"..room_data.GetRoundInfo()[tostring(number)]["16"].."）"
        lblRoundTbl.lblRoundNo3.text = "16局（房卡X"..room_data.GetRoundInfo()[tostring(number)]["16"].."）"  
    end 
    
end

--[[--
 * @Description: 审核处理  
 ]]
function this.AppleVerifyHandler()
    lblRoundTbl.lblRoundSel1.text = "4局（X1）"
    lblRoundTbl.lblRoundNo1.text = "4局（X1）"   

    lblRoundTbl.lblRoundSel2.text = "8局（X2）"
    lblRoundTbl.lblRoundNo2.text = "8局（X2）"

    lblRoundTbl.lblRoundSel3.text = "16局（X4）"
    lblRoundTbl.lblRoundNo3.text = "16局（X4）"   
end