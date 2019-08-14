local mode_comp_base = require "logic/mahjong_sys/components/base/mode_comp_base"

local comp_mjDice = class("comp_mjDice", mode_comp_base)

function comp_mjDice:ctor()
	self.name = "comp_dice"

	self.AllTime = 0
    self.bAni = false
    self.bLaterHide = true
    self.midTime = 0
    self.passTime = 0
    self.rSpeed = 3000
    self.offsetMax = Vector3(0, 0.723, 0.286)
    self.offsetMin = Vector3(0, 0.723, 0.138)
    self.objSelf = nil
    self.quatSaizi0 = Quaternion.identity
    self.quatSaizi1 = Quaternion.identity
    self.dice1_trans = nil
	self.dice2_trans = nil

	self.callback = nil

	self.m_coroutine = nil

	self:fun_createDice()
end


function comp_mjDice:fun_createDice()
	local resDiceObj = newNormalObjSync(mahjong_path_mgr.GetMjPath("mjdice"), typeof(GameObject))	
	self.objSelf = newobject(resDiceObj)
	self.dice1_trans = child(self.objSelf.transform,"Dice1")
	self.dice2_trans = child(self.objSelf.transform,"Dice2")
	self.objSelf:SetActive(false)
end

function comp_mjDice:fun_getSaiziRotate(value)
	local identity;
    local quaternion2;
    if value == 4 then
    	identity = Quaternion.identity * Quaternion.AngleAxis(-90, Vector3.forward)
        quaternion2 = Quaternion.AngleAxis(math.random(0,360), Vector3.left)
    elseif value == 1 then
    	identity = Quaternion.identity * Quaternion.AngleAxis(180, Vector3.right)
        quaternion2 = Quaternion.AngleAxis(math.random(0,360), Vector3.up)
    elseif value == 2 then
    	identity = Quaternion.identity * Quaternion.AngleAxis(90, Vector3.forward)
        quaternion2 = Quaternion.AngleAxis(math.random(0,360), Vector3.left)
    elseif value == 3 then
    	identity = Quaternion.identity * Quaternion.AngleAxis(-90, Vector3.right)
        quaternion2 = Quaternion.AngleAxis(math.random(0,360), Vector3.forward)
    elseif value == 5 then
    	identity = Quaternion.identity * Quaternion.AngleAxis(90, Vector3.right)
        quaternion2 = Quaternion.AngleAxis(math.random(0,360), Vector3.forward)
    elseif value == 6 then
    	identity = Quaternion.identity
        quaternion2 = Quaternion.AngleAxis(math.random(0,360), Vector3.up)
    end
    return (identity * quaternion2)
end

function comp_mjDice:Init()
	self.bAni = false
    self.AllTime = 2
    self.passTime = 0
    self.midTime = 0
    self.dice1_trans.localRotation = self:fun_getSaiziRotate(math.random(1, 6))
    self.dice2_trans.localRotation = self:fun_getSaiziRotate(math.random(1, 6))
    self.objSelf:SetActive(false)
end

function comp_mjDice:Play(val1,val2,cb,isLaterHide)
	if (not self.bAni) then
        if not self.objSelf.activeSelf then
            self.objSelf:SetActive(true)
        end
        self.midTime = self.AllTime * 0.5
        self.passTime = 0
        self.bLaterHide = isLaterHide or true
        local num1 = val1
        local num2 = val2
        self.quatSaizi0 = self:fun_getSaiziRotate(num1)
        self.quatSaizi1 = self:fun_getSaiziRotate(num2)
        self.bAni = true
        self.callback = cb
    end
end

function comp_mjDice:Hide()
	self.objSelf:SetActive(false)
end

function comp_mjDice:Update()
	if self.bAni then
        self.passTime = self.passTime + Time.deltaTime
        if self.passTime < self.AllTime then
            local t = self.passTime / self.AllTime
            self.objSelf.transform:Rotate(Vector3.up, (Time.deltaTime * Mathf.Lerp(self.rSpeed, 0, t)))
            self.objSelf.transform:Rotate(Vector3.up, 1)
            if self.passTime < self.midTime then
                t = self.passTime / self.midTime;
                self.dice1_trans.localPosition = Vector3.Lerp(self.offsetMin, self.offsetMax, t)
                self.dice2_trans.localPosition = Vector3(-self.dice1_trans.localPosition.x,self.dice1_trans.localPosition.y,-self.dice1_trans.localPosition.z)
                self.dice1_trans.localRotation = Quaternion(math.random(0, 1),math.random(0, 1),math.random(0, 1),math.random(0, 1))--UnityEngine.Random.rotation
                self.dice2_trans.localRotation = Quaternion(math.random(0, 1),math.random(0, 1),math.random(0, 1),math.random(0, 1))--UnityEngine.Random.rotation
            else
                t = (self.passTime - self.midTime) / (self.AllTime - self.midTime)
                self.dice1_trans.localPosition = Vector3.Lerp(self.offsetMax, self.offsetMin, t)
                self.dice2_trans.localPosition = Vector3(-self.dice1_trans.localPosition.x,self.dice1_trans.localPosition.y,-self.dice1_trans.localPosition.z)
                self.dice1_trans.localRotation = Quaternion.Slerp(self.dice1_trans.localRotation, self.quatSaizi0, t)
                self.dice2_trans.localRotation = Quaternion.Slerp(self.dice2_trans.localRotation, self.quatSaizi1, t)
            end
        elseif not self.bLaterHide then
            self.bAni = false
        elseif self.passTime > self.AllTime then
            if self.bLaterHide then
            	self.m_coroutine = coroutine.start(function ()
            		coroutine.wait(4)
            		self:Hide()
            	end)
            end
            self.bAni = false
            if self.callback ~=nil then
            	self.callback()
            	self.callback = nil
            end
        end
    end
end

function comp_mjDice:Uninitialize()
	mode_comp_base.Uninitialize(self)
	if self.m_coroutine~=nil then
		coroutine.stop(self.m_coroutine)
		self.m_coroutine = nil
	end
end

return comp_mjDice