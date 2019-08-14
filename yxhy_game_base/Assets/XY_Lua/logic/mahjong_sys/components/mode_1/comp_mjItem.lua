local mode_comp_base = require "logic/mahjong_sys/components/base/mode_comp_base"
local mahjong_path_mgr = mahjong_path_mgr
local comp_mjItem = class("comp_mjItem", mode_comp_base)
local containerClass = require "logic/mahjong_sys/components/ObjectContainer"


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

    self.config = mode_manager:GetCurrentMode().config

    self.paiValue = nil--牌值
    self.sortPaiValue = nil  -- 用于排序的值（替换值）
    self.mjObj = nil--麻将对象
    self.mjModelObj = nil -- 麻将模型
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
    -- 是否显示扣标志
    self.isShowKouIcon = false

    self.meshRenderer = nil--麻将网格渲染
    self.originalMat = nil--麻将原材质

    -- self.listener = nil  --拖动事件监听comp
    self.isDrag = false -- 是否在拖动

    self.curLayer = layerEnum.layer3D

    self.curState = MahjongItemState.hide


    -- 是否处于选中状态
    self.isSelect = false

    self.canClick = true

    self.maskCollect = false  --是否标记为吃


    -- callback  需要时slot  保留mjplayer引用
    self.onClickCallback = nil
    self.onDragCallback = nil

    self.isDown = false   -- 是否横放(吃碰杠)


    self.isDisable = false

    self.isActive = false

    self.localEulers = Vector3.zero
    self.localPosition = Vector3.zero

end

--[[--
 * @Description: 获取unity相关组件  
 ]]
function comp_mjItem:CreateObj(mjObj)
    self.mjObj = mjObj
    self.transform = self.mjObj.transform
    self.mjModelObj = child(self.transform, "mjobj").gameObject

    self.meshFilter = self.mjModelObj:GetComponent(typeof(UnityEngine.MeshFilter))
    self.meshRenderer = self.mjModelObj:GetComponent(typeof(UnityEngine.MeshRenderer))
    self.originalMat = self.meshRenderer.sharedMaterial

    self.specialIconGo = child(self.transform,"sr_hun").gameObject
    self.tingIconGo = child(self.transform, "sr_select").gameObject
    self.kouIconGo = child(self.transform,"sr_kou").gameObject

	self.transform.localScale = Vector3.one * mahjongConst.MahjongScale

    
    local shadowStandGo = child(self.transform, "mjobj/MahjongShadow/MahjongShadow_01").gameObject
    local shadowDownGo = child(self.transform, "mjobj/MahjongShadow/MahjongShadow").gameObject

    self.shadowDownGoContainer = containerClass:create(shadowDownGo)
    self.shadowStandGoContainer = containerClass:create(shadowStandGo)

    self:HideShadow()

    self.localEulers = self.transform.localEulerAngles
    self.localPosition = self.transform.localPosition
    self.isActive = self.mjObj.activeSelf
    

    self.parent = nil
end

function comp_mjItem:ShowShadow()
    if self.transform == nil then
        return
    end
    if self.parent == nil then
        self:HideShadow();
        return
    end
    -- 自己手牌暂时不显示
   if self.curState == MahjongItemState.inOtherHand then
        local eulerX = self.localEulers.x
        if math.abs(eulerX + 90) < 1 then
            LuaHelper.SetTransformLocalY(self.shadowDownGoContainer.tr, 0.26)
            self.shadowDownGoContainer:SetActive(true)
            self.shadowStandGoContainer:SetActive(false)
        elseif math.abs(eulerX - 90) < 1 then
            LuaHelper.SetTransformLocalY(self.shadowDownGoContainer.tr, -0.26)
            self.shadowDownGoContainer:SetActive(true)
            self.shadowStandGoContainer:SetActive(false)
        else 
			self.shadowDownGoContainer:SetActive(false)
            self.shadowStandGoContainer:SetActive(true)
        end
   -- elseif self.transform.parent.name == "WallPoint" or self.transform.parent.name == "OutCardPoint" 
   --      or self.transform.parent.name == "OutCardPoint" or self.transform.parent.name == "huaPoint" 
   --      or self.transform.parent.name == "oper_root" then
    elseif self.curState ~= MahjongItemState.inSelfHand and self.curState ~= MahjongItemState.inOtherHand then
        local eulerZ = self.localEulers.z
        if eulerZ == 180 then
            LuaHelper.SetTransformLocalY(self.shadowDownGoContainer.tr, 0.26)
        elseif eulerZ == 0 then
            LuaHelper.SetTransformLocalY(self.shadowDownGoContainer.tr, -0.26)
        else 
            self.shadowDownGoContainer:SetActive(false)
            return
        end
        self.shadowDownGoContainer:SetActive(true)
        self.shadowStandGoContainer:SetActive(false)
    else
        self:HideShadow()
    end
end

function comp_mjItem:HideShadow()
    self.shadowStandGoContainer:SetActive(false)
    self.shadowDownGoContainer:SetActive(false)
end




function comp_mjItem:SetActive(value)
    if self.isActive == value then
        return
    end
    self.isActive = value
    if not IsNil(self.mjObj) then
        self.mjObj:SetActive(value)
    end
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

function comp_mjItem:DOLocalMove(x,y,z,time, snap, force)
    self:HideShadow()
    snap = snap or false
    local isChange = self:SetAndCheckVector3Change(self.localPosition, x,y,z)
    if not isChange  and time == 0 and not force then
        return nil
    end
    if time == 0 or time == nil then
        self.transform.localPosition = self.localPosition
    else
        return self.transform:DOLocalMove(self.localPosition, time, snap)
    end
    return nil
end


function comp_mjItem:DOLocalRotate(x, y , z, time, mode)
    self:HideShadow()
    mode = mode or DG.Tweening.RotateMode.Fast
    local isChange = self:SetAndCheckVector3Change(self.localEulers, x,y,z)
    if not isChange and time == 0 then
        return nil
    end

    if time == 0 then
        self.transform.localEulerAngles = self.localEulers
    else
        return self.transform:DOLocalRotate(self.localEulers, time, mode)
    end
    return nil
end

function comp_mjItem:SetAndCheckVector3Change(v3, x, y, z)
    local isChange = false
    if x ~= nil and v3.x ~= x then
        isChange = true
        v3.x = x
    end
    if y ~= nil and v3.y ~= y then
        isChange = true
        v3.y = y
    end
    if z ~= nil and v3.z ~= z then
        isChange = true
        v3.z = z
    end
    return isChange
end

-- function comp_mjItem:DOLocalRotate(eulers, time, mode)
--     self:HideShadow()
--     mode = mode or DG.Tweening.RotateMode.Fast
--     if time == 0 then
--         self.transform.localEulerAngles = eulers
--     else
--        return self.transform:DOLocalRotate(eulers, time, mode)
--     end
--     return nil
-- end

-- 设置为2dlayer
function comp_mjItem:Set2DLayer()
    if self.curLayer == layerEnum.layer2D then
        return
    end
    self.curLayer = layerEnum.layer2D
    self.meshRenderer.sharedMaterial = mode_manager.GetCurrentMode():GetComponent("comp_resMgr"):GetNormalMat_1024()
    self.originalMat = mode_manager.GetCurrentMode():GetComponent("comp_resMgr"):GetNormalMat_1024()
    RecursiveSetLayerValIncludeSelf(self.transform, MahjongLayer.TwoDLayer)
end

-- 设置为3dlayer
function comp_mjItem:Set3DLayer()
    if self.curLayer == layerEnum.layer3D then
        return
    end
    self.curLayer = layerEnum.layer3D
    self.meshRenderer.sharedMaterial = mode_manager.GetCurrentMode():GetComponent("comp_resMgr"):GetNormalMat_512()
    self.originalMat = mode_manager.GetCurrentMode():GetComponent("comp_resMgr"):GetNormalMat_512()
    RecursiveSetLayerValIncludeSelf(self.transform, MahjongLayer.DefaultLayer)
end


-- function comp_mjItem:RotateByKey(key, value, time)
--     local eulers = self.transform.localEulerAngles
--     local keyValue = eulers[key]
--     if keyValue == nil then
--         return
--     end
--     if keyValue == value then
--         return
--     end
--     eulers[key] = value

--     local x,y,z = eulers:Get()
--     time = time or 0
--     self:DOLocalRotate(x,y,z, time)
-- end

function comp_mjItem:LocalMoveByKey(key, value, time)
    local localPos = self.transform.localPosition
    local keyValue = localPos[key]

    if keyValue == nil then
        return
    end

    if keyValue == value then
        return
    end

    localPos[key] = value

    time = time or 0
    
    local x,y,z = localPos:Get()
    self:DOLocalMove(x,y,z, time)
end


--[[--
 * @Description: 显示  
 ]]
function comp_mjItem:Show(front,isAnim)
    if front~=nil then
        self.isFront = front
    end
    local time = 0
    if isAnim then
        time = 0.3
    end
    self:SetActive(true)
    if self.isFront then
        self:DOLocalRotate(0,0,0, time)
    else
        self:DOLocalRotate(0,0,180, time)
    end
    self:ShowShadow()
end


function comp_mjItem:SetParent(parent, inWorld)
    if self.parent == parent then
        return
    end
    self.parent = parent
    self.transform:SetParent(parent, inWorld or false)
    if inWorld then
        self.localEulers = self.transform.localEulerAngles
        self.localPosition = self.transform.localPosition
    end
end

--[[--
 * @Description: 隐藏  
 ]]
function comp_mjItem:Hide()
    -- self:SetActive(false)
    self:DOLocalRotate(999,999,999,0)
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
        if self.curState ~= MahjongItemState.inOtherHand then
            self:UpdateSpecialCard()
        end
        self:SetSortValue()
    end
end

function comp_mjItem:SetSortValue()
    local value = self.paiValue
    if self.config.GetReplaceSpecialCardValue() == value and roomdata_center.specialCard[1] ~= nil then
        self.sortPaiValue = roomdata_center.specialCard[1]
    else
        self.sortPaiValue = value
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

function comp_mjItem:SetKouIcon(isShow)
    if self.isShowKouIcon == isShow then
        return
    end
    if self.kouIconGo~=nil then
        self.isShowKouIcon = isShow
        self.kouIconGo:SetActive(isShow)
    end
end

-- 设置显示小箭头
function comp_mjItem:SetTingIcon(value)
    if self.transform == nil then
        return
    end
    if self.isDisable then
        return
    end
    if self.curState ~= MahjongItemState.inSelfHand then
        value = false
    end
    if mahjong_ui:GetOperTipShowState()  then
        value = false
    end
    if self.tingIconGo ~= nil and self.isTing ~= value then
        self.isTing = value
        self.tingIconGo:SetActive(value)
    end
end

function comp_mjItem:SetDown(value)
    if self.isDown == value then
        return
    end
    self.isDown = value
    local angle = 0
    if self.isDown then
        angle = 90
    else
        angle = 0
    end
    self:DOLocalRotate(nil, angle, 0, 0)
end

function comp_mjItem:GetWidth()
    if self.isDown then
        return mahjongConst.MahjongOffset_z
    else
        return mahjongConst.MahjongOffset_x
    end
end

function comp_mjItem:GetHeight()
    if self.isDown then
        return mahjongConst.MahjongOffset_x
    else
        return mahjongConst.MahjongOffset_z
    end
end


--[[--
 * @Description: 设置高亮，相同牌显示  
 ]]
function comp_mjItem:SetHighLight(isHighLight)
    if isHighLight then 
        self.meshRenderer.sharedMaterial = mode_manager.GetCurrentMode():GetComponent("comp_resMgr"):GetHighLightMat()
    else
        if self.maskCollect == true then
            self.meshRenderer.sharedMaterial = mode_manager.GetCurrentMode():GetComponent("comp_resMgr"):GetCollectHighLightMat()
        else
            self.meshRenderer.sharedMaterial = self.originalMat
        end
    end
end

function comp_mjItem:SetDisable(value)
    if self.isDisable == value then
        return
    end
    self.isDisable = value
    if self.isDisable then
        self.meshRenderer.sharedMaterial = mode_manager.GetCurrentMode():GetComponent("comp_resMgr"):GetDisableMat()
        self:SetSelectState(false)
    else
        self.meshRenderer.sharedMaterial = self.originalMat
    end
end

--[[--
 * @Description: 设置吃牌高亮显示
 ]]
function comp_mjItem:SetCollectHighLight(isHighLight)
    if isHighLight then 
        self.meshRenderer.sharedMaterial = mode_manager.GetCurrentMode():GetComponent("comp_resMgr"):GetCollectHighLightMat()
        self.maskCollect = true
    else
        self.meshRenderer.sharedMaterial = self.originalMat
        self.maskCollect = false
    end
end

function comp_mjItem:HideAndReset()
    if(not IsNil(self.mjObj)) then
        --self.mjObj:SetActive(false)
        -- self:SetActive(false)
        self:DOLocalMove(999,999,999,0)
        self.transform.localScale = Vector3.one * mahjongConst.MahjongScale
        self.isDrag = false
        --self.transform:SetParent(nil, false)
        -- self:SetParent(nil, false)
    end
    self:SetState(MahjongItemState.hide)
end

--[[--
 * @Description: 点击按下状态  
 ]]
-- function comp_mjItem:OnClickDown()
--     if roomdata_center.CheckCardTing(self.paiValue) then
--         self:SetTingIcon(false)
--         mahjong_ui.cardShowView:ShowHu(roomdata_center.GetTingInfo(self.paiValue))
--     end
--     self:DOLocalMove(nil, nil, mahjongConst.MahjongOffset_z/3,  
--         0, false)
-- end

--[[--
 * @Description: 非点击状态  
 ]]
function comp_mjItem:OnClickUp()
    -- 吃的时候不需要隐藏
     mahjong_ui.cardShowView:HideIfNotChi()
     self:SetTingIcon(roomdata_center.CheckCardTing(self.paiValue))

    self:DOLocalMove(nil, nil, 0, 0, false)
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
    self:DOLocalMove(nil, nil, mahjongConst.MahjongOffset_z/3,  
        0, false)
end

function comp_mjItem:OnDeselect() -- 吃的时候不需要隐藏
    mahjong_ui.cardShowView:HideIfNotChi()
    self:SetTingIcon(roomdata_center.CheckCardTing(self.paiValue))

    self.isDrag = false
    self:DOLocalMove(nil, nil, 0, 
        0, false)
end

function comp_mjItem:RemoveMouseEvent()
    self.onClickCallback = nil
    self.onDragCallback = nil
end

function comp_mjItem:OnClick(go)
    if self:CheckCanClick() and self.onClickCallback ~= nil then
        self.onClickCallback(self)
    end
end


function comp_mjItem:ShowWinEff(isZiMo)
    self:DestroyWinEff()
    local effectName = "Effect_dianpao"
    if isZiMo then
        effectName = "Effect_zhizizimo"
    end
    local eff = newNormalObjSync(mahjong_path_mgr.GetEffPath(effectName,mahjong_path_enum.mjCommon), typeof(GameObject))
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
    return self.curState == MahjongItemState.inSelfHand and self.canClick and (not self.isDisable)
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
    -- if self.curState == MahjongItemState.hide or self.curState == MahjongItemState.inWall then
    --     self:SetTingIcon(false)
    --     self:SetSpecialCard(false)
    --     self:SetMesh(nil)
    --     self:Set3DLayer()
    --     -- self:RemoveMouseEvent()
    --     self:SetSelectState(false)
    --     self:SetCollectHighLight(false)
    --     self:SetDisable(false)
    -- end
    -- if self.curState == MahjongItemState.inOperatorCard or self.curState == MahjongItemState.inOtherHand 
    --     or self.curState == MahjongItemState.others or self.curState == MahjongItemState.inDiscardCard then
    --     self:Set3DLayer()
    --     self:SetTingIcon(false)
    --     -- self:RemoveMouseEvent()
    --     self:SetSelectState(false)
    --     self:SetDisable(false)
    -- end
    -- if self.curState == MahjongItemState.inSelfHand then
    --     self:Set2DLayer()
    -- end

    -- if self.curState ~= MahjongItemState.inOperatorCard then
    --     self:SetDown(false)
    -- end
    for i = 1, #comp_mjItem.stateMap do
        local value = comp_mjItem.stateMap[i][self.curState]
        local func = comp_mjItem.stateFunList[i]
        self:CallStateFunction(func, value)
    end
end

function comp_mjItem:CallStateFunction(func, value)
    -- 0 表示不操作
    if value == 0 or value == nil then
        return
    end
    if value == 1 then
        func(self,false)
    else
        func(self,true)
    end
end

function comp_mjItem:SetMeshState(value)
    if value == false then
        self:SetMesh(nil)
    end
end

function comp_mjItem:SetLayerState(value)
    if value == true then
        self:Set2DLayer()
    else
        self:Set3DLayer()
    end
end


-- MahjongItemState =
-- {
--     inWall = 1, --牌墩
--     inSelfHand = 2,  -- 在自己手牌
--     inOtherHand = 3,    -- 在别人手牌
--     inOperatorCard = 4, -- 在操作牌区
--     inDiscardCard = 5,  -- 出牌区
--     hide = 6,   -- 隐藏
--     other = 7,  -- 其他（金，clone牌等）
-- }


comp_mjItem.stateMap = 
{
--   1,2,3,4,5,6,7
    {1,0,0,0,0,1,0},  --setmesh   1 mesh = nil
    {1,2,1,1,1,1,0},  --setlayer  1 3dLayer 2 2dLayer
    {1,0,1,1,1,1,1},  --settingicon
    {1,0,1,0,0,1,0},  --specialCard
    {1,1,1,0,1,1,1},  --SetCollectHighLight
    {1,0,1,1,1,1,1},  --SetDisable
    {1,0,1,1,1,1,1},  --SetDown 
    {1,0,1,1,1,1,1},  --SetSelectState
    {1,0,1,1,1,1,1},  --SetKouIcon
}

comp_mjItem.stateFunList = 
{
    comp_mjItem.SetMeshState,
    comp_mjItem.SetLayerState,
    comp_mjItem.SetTingIcon,
    comp_mjItem.SetSpecialCard,
    comp_mjItem.SetCollectHighLight,
    comp_mjItem.SetDisable,
    comp_mjItem.SetDown,    
    comp_mjItem.SetSelectState,
    comp_mjItem.SetKouIcon,
}

function comp_mjItem:Clone(mj)
    mj:SetParent(self.transform.parent)
    mj.transform.localPosition = self.transform.localPosition
    mj.transform.localEulerAngles = self.transform.localEulerAngles
    mj:SetMesh(self.paiValue)
    mj:SetActive(self.mjObj.activeSelf)
end

return comp_mjItem