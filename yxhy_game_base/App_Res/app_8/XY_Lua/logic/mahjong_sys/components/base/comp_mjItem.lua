local mode_comp_base = require "logic/mahjong_sys/components/base/mode_comp_base"
local mahjong_path_mgr = mahjong_path_mgr
local comp_mjItem = class("comp_mjItem", mode_comp_base)

local MahjongItemState = MahjongItemState
local destroy = destroy
local RecursiveSetLayerValIncludeSelf = RecursiveSetLayerValIncludeSelf
local LuaHelper = LuaHelper
local Input = Input
local Screen = Screen
local MahjongLayer = MahjongLayer

local layerEnum = 
{
    layer3D = 1,
    layer2D = 2,
}

function comp_mjItem:ctor()
	self.name = "comp_mjItem"

    self.paiValue = nil--牌值
    self.mjObj = nil--麻将对象
    self.mjModelObj = nil -- 麻将模型
    self.shadowDownGo = nil  -- 倒下阴影
    self.shadowStandGo = nil -- 站立的阴影
    self.transform = nil  -- transform 缓存
    self.meshFilter = nil--麻将self.meshFilter
    -- @todo  牌图片作为可配置
    self.specialIconGo = nil -- 特殊牌图标
    self.isFront = false--是否显示正面

    -- 麻将上的小箭头
    self.tingIconGo = nil

    -- 显示小箭头的牌
    self.isTing = false

    self.eventPai = nil--点击牌事件
    self.dragEvent = nil -- 拖动牌事件

    -- 是否为特殊牌
    self.isSpecialCard = false

    self.meshRenderer = nil--麻将网格渲染
    self.originalMat = nil--麻将原材质
    self.originalPos = nil

    self.listener = nil  --拖动事件监听comp
    self.isDrag = false -- 是否在拖动

    self.curLayer = layerEnum.layer3D

    self.curState = MahjongItemState.hide


    -- 是否处于选中状态
    self.isSelect = false

    self.canClick = true


    -- callback  需要时slot  保留mjplayer引用
    self.onClickCallback = nil
    self.onDragCallback = nil

end

--[[--
 * @Description: 获取unity相关组件  
 ]]
function comp_mjItem:CreateObj()
    local resMJObj = newNormalObjSync(mahjong_path_mgr.GetMjPath("mj"), typeof(GameObject))	
    self.mjObj = newobject(resMJObj)
    self.transform = self.mjObj.transform
    self.mjModelObj = child(self.transform, "mjobj").gameObject

    self.meshFilter = self.mjModelObj:GetComponent(typeof(UnityEngine.MeshFilter))
    self.meshRenderer = self.mjModelObj:GetComponent(typeof(UnityEngine.MeshRenderer))
    self.originalMat = self.meshRenderer.sharedMaterial

    self.specialIconGo = child(self.transform,"sr_hun").gameObject
    self.tingIconGo = child(self.transform, "sr_select").gameObject

	self.transform.localScale = Vector3.one * mahjongConst.MahjongScale

    self.listener = UIEventListener.Get(self.mjObj)
    
    self.shadowStandGo = child(self.transform, "mjobj/MahjongShadow/MahjongShadow_01").gameObject
    self.shadowDownGo = child(self.transform, "mjobj/MahjongShadow/MahjongShadow").gameObject
    self:HideShadow()
    -- self:AddEventListener()
end

function comp_mjItem:ShowShadow()
    if self.transform == nil then
        return
    end
    if self.transform.parent == nil then
        self:HideShadow();
        return
    end
    -- 自己手牌暂时不显示
   if self.curState == MahjongItemState.inOtherHand then
        self.shadowDownGo:SetActive(false)
        self.shadowStandGo:SetActive(true)
   -- elseif self.transform.parent.name == "WallPoint" or self.transform.parent.name == "OutCardPoint" 
   --      or self.transform.parent.name == "OutCardPoint" or self.transform.parent.name == "huaPoint" 
   --      or self.transform.parent.name == "oper_root" then
    elseif self.curState ~= MahjongItemState.inSelfHand and self.curState ~= MahjongItemState.inOtherHand then
        local eulerZ = self.transform.localEulerAngles.z
        if eulerZ == 180 then
            LuaHelper.SetTransformLocalY(self.shadowDownGo.transform, 0.26)
        elseif eulerZ == 0 then
            LuaHelper.SetTransformLocalY(self.shadowDownGo.transform, -0.26)
        else 
            self.shadowDownGo:SetActive(false)
            return
        end
        self.shadowDownGo:SetActive(true)
        self.shadowStandGo:SetActive(false)
    else
        self:HideShadow()
    end
end

function comp_mjItem:HideShadow()
    self.shadowStandGo:SetActive(false)
    self.shadowDownGo:SetActive(false)
end


--[[--
 * @Description: 初始化  
 ]]
function comp_mjItem:Init()
    self:HideAndReset()
    self:DestroyWinEff()
end

function comp_mjItem:DOScale(value, time)
    return self.transform:DOScale(value, time)
end

function comp_mjItem:DOMove(pos, time, snap)
    self:HideShadow()
     snap = snap or false
    if(time == 0) then
        self.transform.position = pos
    else
       return self.transform:DOMove(pos, time, snap)
    end
    return nil
end

function comp_mjItem:DOLocalMove(pos, time, snap)
    self:HideShadow()

    snap = snap or false
    if(time == 0) then
        self.transform.localPosition = pos
    else
        return self.transform:DOLocalMove(pos, time, snap)
    end
    return nil
end

function comp_mjItem:DOLocalRotate(eulers, time, mode)
    self:HideShadow()
    mode = mode or DG.Tweening.RotateMode.Fast
    if time == 0 then
        self.transform.localEulerAngles = eulers
    else
       return self.transform:DOLocalRotate(eulers, time, mode)
    end
    return nil
end

-- 设置为2dlayer
function comp_mjItem:Set2DLayer()
    if self.curLayer == layerEnum.layer2D then
        return
    end
    self.curLayer = layerEnum.layer2D
    RecursiveSetLayerValIncludeSelf(self.transform, MahjongLayer.TwoDLayer)
end

-- 设置为3dlayer
function comp_mjItem:Set3DLayer()
    if self.curLayer == layerEnum.layer3D then
        return
    end
    self.curLayer = layerEnum.layer3D
    RecursiveSetLayerValIncludeSelf(self.transform, MahjongLayer.DefaultLayer)
end

--[[--
 * @Description: 显示  
 ]]
function comp_mjItem:Show(front,isAnim)
    if front~=nil then
        self.isFront = front
    end
    if(self.mjObj~=nil) then
        self.mjObj:SetActive(true)
        if self.isFront then
            if isAnim~=nil and isAnim then
                self:DOLocalRotate(Vector3(0,0,0), 0.3, DG.Tweening.RotateMode.Fast)
            else
                self.transform.localEulerAngles = Vector3(0, 0, 0)
            end
        else
            if isAnim~=nil and isAnim then
                self:DOLocalRotate(Vector3(0,0,180), 0.3, DG.Tweening.RotateMode.Fast)
            else
                self.transform.localEulerAngles = Vector3(0, 0, 180)
            end
        end
    end
    self:ShowShadow()
end


function comp_mjItem:SetParent(parent, inWorld)
    if self.mjObj ~= nil then
        self.transform:SetParent(parent, inWorld or false)
    end
end

--[[--
 * @Description: 隐藏  
 ]]
function comp_mjItem:Hide()
    if(self.mjObj~=nil) then
        self.mjObj:SetActive(false)
    end
	self:SetSpecialCard(false)
end

--[[--
 * @Description: 设置mesh  
 ]]
function comp_mjItem:SetMesh(value)
    self.paiValue = value
    if(self.paiValue~=nil and self.meshFilter~=nil) then
        if self.paiValue == 0 then
            logError('self.paiValue')
        end
        local comp_resMgr = mode_manager.GetCurrentMode():GetComponent("comp_resMgr")
        local index = MahjongTools.MahjongValueToMeshIndex(self.paiValue)
        self.meshFilter.mesh = comp_resMgr:GetMahjongMesh(index)
        self:UpdateSpecialCard()
    end
end

function comp_mjItem:UpdateSpecialCard()
    local ret, t = roomdata_center.CheckIsSpecialCard(self.paiValue)
    if ret then
        self:SetSpecialCard(true)
    else
        self:SetSpecialCard(false)
    end
end

function comp_mjItem:SetSpecialCard(isShow)
    if self.isSpecialCard == isShow then
        return
    end
    if self.specialIconGo~=nil then
        self.isSpecialCard = isShow
        self.specialIconGo:SetActive(isShow)
    end
end


-- 设置显示小箭头
function comp_mjItem:SetTingIcon(value)
    if self.transform == nil then
        return
    end
    if self.curState ~= MahjongItemState.inSelfHand then
        value = false
    end
    if mahjong_ui.GetOperTipShowState()  then
        value = false;
    end
    if self.tingIconGo ~= nil and self.isTing ~= value then
        self.isTing = value
        self.tingIconGo:SetActive(value)
    end
end

--[[--
 * @Description: 设置高亮，相同牌显示  
 ]]
function comp_mjItem:SetHighLight(isHighLight)
    if isHighLight then 
        self.meshRenderer.sharedMaterial = mode_manager.GetCurrentMode():GetComponent("comp_resMgr"):GetHighLightMat()
    else
        self.meshRenderer.sharedMaterial = self.originalMat
    end
end

function comp_mjItem:HideAndReset()
    if(self.mjObj~=nil) then
        self.mjObj:SetActive(false)
        self.transform.localScale = Vector3.one * mahjongConst.MahjongScale
        self.transform:SetParent(nil, false)
    end
    self:SetState(MahjongItemState.hide)
end

--[[--
 * @Description: 点击按下状态  
 ]]
function comp_mjItem:OnClickDown()
    if roomdata_center.CheckCardTing(self.paiValue) then
        self:SetTingIcon(false)
        mahjong_ui.cardShowView:ShowHu(roomdata_center.GetTingInfo(self.paiValue))
    end
    self:DOLocalMove(
        Vector3(self.transform.localPosition.x,
            self.transform.localPosition.y,
            mahjongConst.MahjongOffset_z/3),  
        0, false)
end

--[[--
 * @Description: 非点击状态  
 ]]
function comp_mjItem:OnClickUp()
    -- 吃的时候不需要隐藏
     mahjong_ui.cardShowView:HideIfNotChi()
     self:SetTingIcon(roomdata_center.CheckCardTing(self.paiValue))


    self:DOLocalMove(
        Vector3(self.transform.localPosition.x,self.transform.localPosition.y,0), 
        0, false)
end

function comp_mjItem:SetSelectState(state)
    if self.isSelect == state then
        return
    end
    self.isSelect = state
    if self.isSelect then
        self:OnSelected()
    else
        self:OnDeselect()
    end
end

function comp_mjItem:OnSelected()
    if roomdata_center.CheckCardTing(self.paiValue) then
        self:SetTingIcon(false)
        mahjong_ui.cardShowView:ShowHu(roomdata_center.GetTingInfo(self.paiValue))
    end
    self:DOLocalMove(
        Vector3(self.transform.localPosition.x,
            self.transform.localPosition.y,
            mahjongConst.MahjongOffset_z/3),  
        0, false)
end

function comp_mjItem:OnDeselect() -- 吃的时候不需要隐藏
    mahjong_ui.cardShowView:HideIfNotChi()
    self:SetTingIcon(roomdata_center.CheckCardTing(self.paiValue))


    self:DOLocalMove(
        Vector3(self.transform.localPosition.x,self.transform.localPosition.y,0), 
        0, false)
end

function comp_mjItem:RemoveMouseEvent()
    self.onClickCallback = nil
    self.onDragCallback = nil
end

---------- 点击事件相关----------------------------------
--[[--
 * @Description: 添加拖动事件监听comp  
 ]]
-- function comp_mjItem:AddEventListener()
--     if not IsNil(self.mjModelObj) then
--         -- addClickCallbackSelf(self.mjModelObj, self.OnClick, self)
--         -- addDragCallbackSelf(self.mjModelObj, self.OnDrag, self)
--         -- addPressedCallbackSelf(self.transform, "",self.OnPress, self)
--         -- addDragEndCallbackSelf(self.mjModelObj, self.OnDragEnd, self)
--     end
-- end

function comp_mjItem:OnClick(go)
    -- if self.isDrag then
    --     self:BackToOriginPos()
    --     return
    -- end

    if self:CheckCanClick() and self.onClickCallback ~= nil then
        self.onClickCallback(self)
    end
end

-- function comp_mjItem:OnDrag(go, delta)
--     if not self:CheckCanClick() then
--         return
--     end
--     if not self.isDrag then
--         -- if delta.y > 3 then 
--             self.originalPos = Vector3(self.transform.localPosition.x,self.transform.localPosition.y,0)
--             self.transform.localPosition = self.transform.localPosition + Vector3(0,mahjongConst.MahjongOffset_y,0)
--             -- self.isDrag = true
--             -- mode_manager.GetCurrentMode():GetComponent("comp_playerMgr"):GetPlayer(1):CancelClick()
--             mode_manager.GetCurrentMode():GetComponent("comp_playerMgr"):SetHighLight(self.paiValue)
--         -- end
--     else
--         -- local v = mode_manager.GetCurrentMode():GetComponent("comp_clickevent").Camera2D:ScreenToWorldPoint(Input.mousePosition)
--         -- self.transform.position = Vector3(v.x,v.y-mahjongConst.MahjongOffset_z,self.transform.position.z)
--     end
-- end

-- function comp_mjItem:OnDragEnd(go)
--      if self.isDrag and self:CheckCanClick() then
--         if Input.mousePosition.y > Screen.height/4 then
--             self.dragEvent(self)
--             --self.mode:GetComponent("comp_playerMgr"):GetPlayer(1):DragCardEvent(self)
--             --mahjong_play_sys.OutCardReq(self.paiValue)
--         end
--         self:BackToOriginPos()
--         mode_manager.GetCurrentMode():GetComponent("comp_playerMgr"):GetPlayer(1):TidyHandCard()
--     end
-- end

-- function comp_mjItem:BackToOriginPos()
--     self.transform.localPosition = self.originalPos
--     mode_manager.GetCurrentMode():GetComponent("comp_playerMgr"):HideHighLight()
--     self.isDrag = false
-- end


-- function comp_mjItem:OnPress(go, value)
--     if self.isDrag then
--         self:BackToOriginPos()
--     end
-- end
------------------------------------------------------


function comp_mjItem:ShowWinEff()
    if true then
        return
    end
    self:DestroyWinEff()
    local eff = newNormalObjSync(mahjong_path_mgr.GetEffPath("shandian", true), typeof(GameObject))
    self.winEff = newobject(eff)
    self.winEff.transform.position = self.transform.position
end

function comp_mjItem:DestroyWinEff()
    if self.winEff ~= nil then
        destroy(self.winEff)
        self.winEff = nil
    end
end

function comp_mjItem:Uninitialize()
	mode_comp_base.Uninitialize(self)
    self:DestroyWinEff()
    if not IsNil(self.mjObj) then
        GameObject.DestroyImmediate(self.mjObj)
    end
end



--------- 麻将状态相关 -------------------
-- @todo 或者外部条件   如托管
function comp_mjItem:CheckCanClick()
    return self.curState == MahjongItemState.inSelfHand and self.canClick
end


function comp_mjItem:SetState(state)
    if self.curState == state then
        return
    end
    self.curState = state
    self:UpdateState()
end

function comp_mjItem:SetHandState(isSelf)
    if isSelf then 
        self:SetState(MahjongItemState.inSelfHand)
    else
        self:SetState(MahjongItemState.inOtherHand)
    end
end

function comp_mjItem:UpdateState()
    if self.curState == MahjongItemState.hide or self.curState == MahjongItemState.inWall then
        self:SetTingIcon(false)
        self:SetSpecialCard(false)
        self:SetMesh(nil)
        self:Set3DLayer()
        self:RemoveMouseEvent()
        self:SetSelectState(false)
    end
    if self.curState == MahjongItemState.inOperatorCard or self.curState == MahjongItemState.inOtherHand 
        or self.curState == MahjongItemState.others or self.curState == MahjongItemState.inDiscardCard then
        self:Set3DLayer()
        self:SetTingIcon(false)
        self:RemoveMouseEvent()
        self:SetSelectState(false)
    end
    if self.curState == MahjongItemState.inSelfHand then
        self:Set2DLayer()
    end
end

return comp_mjItem