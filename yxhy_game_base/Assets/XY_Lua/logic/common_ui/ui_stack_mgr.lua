--[[--
 * @Description: 负责
 * @Author:      shine
 * @FileName:    ui_stack_mgr
 * @DateTime:    2016-05-23 15:19:33
 ]]


ui_stack_mgr = {}
local this = ui_stack_mgr

this.ui_stack = {}
this.ui_with_3dmodel = {}
this.registFlag = false

local farPos = Vector3.New(1000000,0,0)
local zeroPos = Vector3.New(0,0,0)

local allValidHud = {}

--[[--
 * @Description: 
 ]]
function this.PushToStack(uiObj)
	if (not this.registFlag) then
		this.registFlag = true
		Notifier.regist(cmdName.SHOW_SCENE, function ( ... )
			this.ui_stack = {}
		end)
	end

	if (uiObj.with3d) then
		table.insert(this.ui_with_3dmodel, uiObj)
	end

	this.CleanSameItemInStack(uiObj)

	if (uiObj.needToHideOther) then
		for k, v in ipairs(this.ui_stack) do
			if (not IsNil(v.gameObject) and v.canNotHide == nil) then
				if (v.gameObject.activeSelf) then
					if (not (uiObj.isDialogue and v.isHud)) then						
						if (v.logicBaseLuaScript ~= nil) then
							v.logicBaseLuaScript:FastHide()
						else
							v.gameObject:SetActive(false)
						end

						v.controlVisibleBySelf = false
						v.hideByStack = true
					end
				else
					if (not v.hideByStack) then
						v.controlVisibleBySelf = true
					else
						if (uiObj.isDialogue and v.isHud) then						
							if (v.logicBaseLuaScript ~= nil) then
								v.logicBaseLuaScript:FastShow()
							else
								v.gameObject:SetActive(true)
							end

							v.controlVisibleBySelf = false
							v.hideByStack = false
						end
					end
				end
			end

			if (v.canNotHide ~= nil) then
				v.transform.position = farPos
			end
		end
	end

	table.insert(this.ui_stack, uiObj)
end

function this.PopFromStack(uiObj)
	if (uiObj.with3d) then
		local idxToRemove = -1
		for k, v in ipairs(this.ui_with_3dmodel) do
			if (not IsNil(v.gameObject) and v == uiObj) then
				idxToRemove = k
				break
			end
		end

		if (idxToRemove ~= -1) then
			table.remove(this.ui_with_3dmodel, idxToRemove)
		end
	end

	if (uiObj.needToHideOther) then
		local objIdx = this.FindUIObjIdx(uiObj)
		local hasOtherFullScreenHigher = this.IsOtherFullScreenTopOfThis(objIdx)
		if (not hasOtherFullScreenHigher and objIdx ~= -1) then
			local startIdx = this.GetNearestLastFullScreenIdx(uiObj)
			for k = startIdx, objIdx -1 do
				local uiObjElement = this.ui_stack[k]
				if (not uiObjElement.controlVisibleBySelf and not IsNil(uiObjElement.gameObject)) then

					if (uiObjElement.logicBaseLuaScript ~= nil and not (uiObjElement.fakeDestroyed == false)) then
						uiObjElement.logicBaseLuaScript:FastShow()
					else
						uiObjElement.gameObject:SetActive(true)
					end

					if (uiObjElement.hideByStack) then
						uiObjElement.hideByStack = false
					end

					if (uiObjElement.OnEnable ~= nil) then
						uiObjElement:OnEnable()
					end
				end

				if (not IsNil(uiObjElement.gameObject) and uiObjElement.canNotHide ~= nil) then
					uiObjElement.transform.position = zeroPos
				end
			end
		end
	end

	local objIdx = this.FindUIObjIdx(uiObj)
	if (objIdx ~= -1) then
		table.remove(this.ui_stack, objIdx)
	end

end

function this.ClearStack()
	this.ui_stack = {}
end

function this.FindUIObjIdx(uiObj)
	local ret = -1
	for k,v in ipairs(this.ui_stack) do
		if (v == uiObj ) then
			ret = k
			break
		end
	end

	return ret
end

function this.DestroyAllExceptMainScene()
	local idxToRemove = {}
	for k, v in ipairs(this.ui_stack) do
		if not this.ShouldPreserve(v) then
			if (not IsNil(v.gameObject)) then
				local targetIdx = this.FindUIObjIdx(v)
				table.insert(idxToRemove, targetIdx)
				destroy(v.gameObject)
			end
		else
			if (not IsNil(v.gameObject) and (v.controlVisibleBySelf == false)) then
				v.gameObject:SetActive(true)
			end
		end
	end

	for k, v in ipairs(idxToRemove) do
		table.remove(this.ui_stack, v)
	end
end

function this.ShouldPreserve(uiObj)

	local ret = false
	if (uiObj.shouldPreserve) then
		ret = true
	else
		if (not IsNil(uiObj.gameObject)) then
			local currGameObj = uiObj.gameObject
			while (currGameObj.transform.parent ~= nil) do			
				local uiLuaScript = logicLuaObjMgr.getLuaObjByGameObj(currGameObj)			
				if (uiLuaScript ~= nil and uiLuaScript.shouldPreserve) then
					ret = true
					break
				end

				currGameObj = currGameObj.transform.parent.gameObject
			end
		end
	end

	return ret
end

function this.ShouldActivePreviousUI(uiObj)
	local ret = true
	local objIdx = this.FindUIObjIdx(uiObj)
	if (objIdx ~= -1) then
		for k = 1, objIdx do
			local uiObject = this.ui_stack[k]
			if (uiObj ~= uiObject and not IsNil(uiObject.gameObject)) then
				if (uiObject.needToHideOther) then
					ret = false
				end
			end
		end
	end

	return ret
end

--[[这个接口超级费，没事不要去调，zjw]]
function this.IsFullScreenUIExistInStack()
	local ret = false
	for k, v in ipairs(this.ui_stack) do
		if (not IsNil(v.gameObject) and v.needToHideOther and v.gameObject.activeSelf and not v.isDialogue) then
			ret = true
			break
		end	
	end

	return ret
end

function this.HandleSceneVisible()

end

local npcHudRootPanel = nil
local playerHudRootPanel = nil
function this.SetAllHudVisible(value)
	if (not value) then
		for k, v in ipairs(this.ui_stack) do
			if (not IsNil(v.gameObject) and v.isHud and v.gameObject.activeSelf) then
				v.setVisibleByExtra = true
				v.gameObject:SetActive(value)
			end	
		end	

		
		Notifier.dispatchCmd(cmdName.MSG_PLAYER_HUB_ACTIVE, {["para1"] = false})
		Notifier.dispatchCmd(cmdName.MSG_MONSTER_HUB_ACTIVE, {["para1"] = false})
	else
		for k, v in ipairs(this.ui_stack) do
			if (not IsNil(v.gameObject) and v.isHud and v.setVisibleByExtra) then
				v.gameObject:SetActive(value)
			end
		end

		Notifier.dispatchCmd(cmdName.MSG_PLAYER_HUB_ACTIVE, {["para1"] = true})
		Notifier.dispatchCmd(cmdName.MSG_MONSTER_HUB_ACTIVE, {["para1"] = true})
	end
end

function this.GetNearestLastFullScreenIdx(uiObj)
	local ret = 1
	local objIdx = this.FindUIObjIdx(uiObj)
	if (objIdx ~= -1 and objIdx > 1) then
		for k = 1, objIdx -1 do
			local uiObject = this.ui_stack[k]
			if (uiObj ~= uiObject and not IsNil(uiObject.gameObject)) then
				if (uiObject.needToHideOther) then
					ret = k
				end
			end
		end
	end

	return ret
end

function this.CloseAllUIWith3dModelVisible()
	for k, v in ipairs(this.ui_with_3dmodel) do
		if (not IsNil(v.gameObject)) then
			destroy(v.gameObject)
		end
	end

	this.ui_with_3dmodel = {}
end

--[[--
 * @Description: 是否在此idx之上，栈上还有全屏UI
 ]]
function this.IsOtherFullScreenTopOfThis(idx)
	local ret = false
	local stackCount = table.getn(this.ui_stack)
	if (idx + 1 > stackCount) then
		return ret
	end

	for k = idx+1, stackCount do
		local uiObject = this.ui_stack[k]
		if (uiObj ~= uiObject and not IsNil(uiObject.gameObject)) then
			if (uiObject.needToHideOther) then
				ret = true
				break
			end
		end
	end

	return ret
end

--[[--
 * @Description: 清除栈中的相同元素，多个防御
 ]]
function this.CleanSameItemInStack(obj)
	local count = table.getn(this.ui_stack)
	for k = count, 1, -1 do
		if (this.ui_stack[k] == obj) then
			table.remove(this.ui_stack, k)
		end
	end
end