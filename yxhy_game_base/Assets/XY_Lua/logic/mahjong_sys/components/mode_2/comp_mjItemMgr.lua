local poolBaseClass = require "logic/common/poolBaseClass"
local mode_comp_base = require "logic/mahjong_sys/components/base/mode_comp_base"

local comp_mjItemMgr = class("comp_mjItemMgr", mode_comp_base)

function comp_mjItemMgr:ctor(itemPath)
	itemPath = itemPath or "logic/mahjong_sys/components/mode_2/comp_mjItem"
	self.name = "comp_mjItemMgr"
    self.mjItemClass = require (itemPath)

    self.mjItemList = {}--麻将子组件列表，从视图玩家1左边第一墩从下至上开始

    self.mjObjDict = {}

    -- 混牌
    self.exLaiziMj = nil
    -- 翻开的牌
    self.exMj = nil
    
    self.huItemList = {}

    setmetatable(self.mjObjDict, {__mode = "kv"})
    self.config = nil
    self.poolRoot_tr = nil
    self.mjObjectPool = nil
end

function comp_mjItemMgr:Initialize()
	mode_comp_base.Initialize(self)
	self:InitMJObj()
end

function comp_mjItemMgr:InitMJObj()
    local mjObj = newNormalObjSync(mahjong_path_mgr.GetMjPath("mj"), typeof(GameObject))
    local newFunc = function ()
        return newobject(mjObj)
    end
    local recycleFunc = function (obj)
        self:PutToPoolRoot(obj)
    end
    self.mjObjectPool = poolBaseClass:create(newFunc,nil,recycleFunc)
    local list = {}
    for i=1,144 do
        local obj = self.mjObjectPool:Get()
        list[i] = obj
    end
    for i=1,144 do
        self.mjObjectPool:Recycle(list[i])
    end
end

function comp_mjItemMgr:PutToPoolRoot(obj)
    if self.poolRoot_tr == nil then
        local o = GameObject.New("MJPoolRoot")
        o:SetActive(false)
        self.poolRoot_tr = o.transform
    end
    obj.transform:SetParent(self.poolRoot_tr,false)
end

--[[--
 * @Description: 初始化麻将子  
 ]]
function comp_mjItemMgr:InitMJItems()
    if self.config == nil then
        self.config = self.mode.config
    end
    if #self.mjItemList == 0 then
        for i=1,self.config.MahjongTotalCount,1 do
            local mj = self.mjItemClass:new()
            mj:CreateObj(self.mjObjectPool:Get())
            mj.mode = self.mode
            if tostring(Application.platform) == "WindowsEditor" then
                mj.mjObj.name = "MJ"..i
            end

            mj:Init()
            table.insert(self.mjItemList, mj)
            self.mjObjDict[mj.mjObj] = mj   
        end

        if self.exMj == nil then
            self.exMj = self.mjItemClass:new()
            self.exMj:CreateObj(self.mjObjectPool:Get())
            self.exMj.mode = self.mode
            self.exMj.mjObj.name = "mjEx"            
        end
        self.exMj:Init()


        if self.exLaiziMj == nil then
            self.exLaiziMj = self.mjItemClass:new()
            self.exLaiziMj:CreateObj(self.mjObjectPool:Get())
            self.exLaiziMj.mode = self.mode
            self.exLaiziMj.mjObj.name = "mjexLaizi"         
        end
        self.exLaiziMj:Init()  

        if #self.huItemList == 0 then
            for i=1,4 do
                local mj = self.mjItemClass:new()
                mj:CreateObj(self.mjObjectPool:Get())
                mj.mode = self.mode
                mj.mjObj.name = "HUMJ"..i

                mj:Init()
                table.insert(self.huItemList, mj)
            end
        end              
    else
        for i=1,self.config.MahjongTotalCount,1 do
            self.mjItemList[i]:Init()
        end
    end
end

function comp_mjItemMgr:GetNextHuMJ(index)
    return self.huItemList[index]
end

function comp_mjItemMgr:SetMJKeMat(num)
    local matName = "Mahjong_blue"
    if num == 2 then
        matName = "Mahjong_green"
    elseif num == 3 then
        matName = "Mahjong_yellow"
    end
    local mat = newNormalObjSync(mahjong_path_mgr.GetMaterialPath(matName), typeof(UnityEngine.Material))
    for i=1,#self.mjItemList do
        subComponentGet(self.mjItemList[i].transform,"mjobj/Mahjong_ke",typeof(UnityEngine.MeshRenderer)).sharedMaterial = mat
    end
end

function comp_mjItemMgr:Uninitialize()
	mode_comp_base.Uninitialize(self)
    for i,v in ipairs(self.mjItemList) do
        if v~=nil then
            v:Uninitialize()
        end
    end

    for i,v in ipairs(self.huItemList) do
        if v~=nil then
            v:Uninitialize()
        end
    end    
    self.mjObjDict = {}
end

return comp_mjItemMgr