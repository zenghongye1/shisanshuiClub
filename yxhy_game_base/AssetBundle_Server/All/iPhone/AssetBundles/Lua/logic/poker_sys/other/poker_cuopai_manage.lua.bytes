require "logic/poker_sys/utils/poker3D_dictionary"
local poker_cuopai_manage = class("poker_cuopai_manage")
function poker_cuopai_manage:ctor()
	self.cuoPaiAnchor = nil
	self.cuoPaiAnimObj = nil
	self.rendererObj = nil
	self.isFinshCuoPai = false
	self.animState = nil
	self.cuoPaiCard = {}
	self.animationCount = 3
	self.animationTable = {}
	self.animationName = {
		[1] = "poker_cuopai_up",
		[2] = "poker_cuopai_left",
		[3] = "poker_cuopai_right",
	}
	self:InitCuoPaiAnchor()
end

function poker_cuopai_manage:InitCuoPaiAnchor()
	if self.cuoPaiAnchor == nil then
		self.cuoPaiAnchor = GameObject.Find("cuopaianchor")
	end

	for i =1,self.animationCount do
		local obj = GameObject.Find("cuopaianchor/Poker_niu_"..tostring(i))
		local anim = componentGet(obj.gameObject.transform,"Animator")
		table.insert(self.animationTable,anim)
	end
	self.cuoPaiAnchor.gameObject:SetActive(false)
end



function poker_cuopai_manage:SetCuoPaiAnchor(isShow,cardData)
	self.cuoPaiAnchor.gameObject:SetActive(isShow)
	if isShow == true then
		if self.cuoPaiAnimObj ~= nil then
			self.cuoPaiAnimObj:Play(self.animState,0,0)
			self.cuoPaiAnimObj = nil
			Notifier.dispatchCmd("CUO_PAI", self.cuoPaiAnimObj)
		end
		self:SetLastCardValue(cardData)
		
	end
	
end

--设置搓牌的值
function poker_cuopai_manage:SetLastCardValue(cardData)
	local matName = tostring(cardData)
    local mat = newNormalObjSync(data_center.GetResPokerCommPath().."/materials/card/"..matName, typeof(UnityEngine.Material))
	for i,v in ipairs(self.animationTable) do
		local rendererObj = child(v.transform,"Object001")
		local meshRenderer = rendererObj:GetComponent(typeof(UnityEngine.SkinnedMeshRenderer))
		meshRenderer.materials[0]:CopyPropertiesFromMaterial(mat)
	end
--	logError("matName================"..tostring(mat.name))
end

function poker_cuopai_manage:OnDragAction(gesture,card,callback)
	if self.isFinshCuoPai == true then	return end
	if gesture ~= nil then
		if gesture.isShowAnchor ~=nil and gesture.isShowAnchor == true then
			self:SetCuoPaiAnchor(gesture.isShowAnchor,card)
		end
		if gesture.DeltaMove ~= nil then		
		--	self.totalDelta = gesture.DeltaMove.y
			local deltaY = gesture.DeltaMove.y
			local deltaX = gesture.DeltaMove.x
		--	logError("deltaX:"..tostring(deltaX))
			
			if self.cuoPaiAnimObj == nil then
				if math.abs(deltaX) > math.abs(deltaY) then
					if deltaX > 0 then
						self:PlayAnimStateByIndex(3)--向右划动
					else
						self:PlayAnimStateByIndex(2)--向左划动
					end
				else
					self:PlayAnimStateByIndex(1)--向上划动
				end
			else
				if self.animState == "poker_cuopai_up" then
					self.totalDelta = gesture.DeltaMove.y
				else if self.animState == "poker_cuopai_left" then
					self.totalDelta = -(gesture.DeltaMove.x)
				elseif self.animState == "poker_cuopai_right" then
					self.totalDelta = gesture.DeltaMove.x
				end
			end
			self.cuoPaiAnimObj:Play(self.animState)
		
			
		--	logError("播放动画:"..tostring(self.animState))
		--	logError("动画name:"..tostring(self.cuoPaiAnimObj.name))
			local speed = self.totalDelta / 10
			self.cuoPaiAnimObj:SetFloat("SingSpeed",speed)
			local stateInfo = self.cuoPaiAnimObj:GetCurrentAnimatorStateInfo(0)
		--	logError("stateInfo.normalizedTime:"..tostring(stateInfo.normalizedTime))
			if stateInfo.normalizedTime > 0.6 then
				--搓开60%的进度，那么直接播放剩下的动画
				self.isFinshCuoPai = true
				self.cuoPaiAnimObj:SetFloat("SingSpeed",1)
				coroutine.start(function()
					coroutine.wait(0.5)
					self:SetCuoPaiAnchor(false)
					UI_Manager:Instance():CloseUiForms("cuopai_ui")
					local cuopai_ui = UI_Manager:Instance():GetUiFormsInShowList ("cuopai_ui")
					if cuopai_ui ~= nil then
						logError("cuopai_ui 不为 nil")
					else
						Trace("cuopai_ui 销毁")
					end
					if callback ~= nil then
						callback()
					end
				end)
			elseif stateInfo.normalizedTime <= 0 then
			--	logError("动画回到原点")
				if self.cuoPaiAnimObj ~= nil then
					self.cuoPaiAnimObj:Play(self.animState,0,0)
					self.cuoPaiAnimObj = nil
					Notifier.dispatchCmd("CUO_PAI", self.cuoPaiAnimObj)
				end	
			end
		end
		
		end
	end
end

function poker_cuopai_manage:PlayAnimStateByIndex(index)
	for i,v in ipairs(self.animationTable) do
		if i == index then
			v.gameObject:SetActive(true)
			self.animState = self.animationName[i]
			self.cuoPaiAnimObj = self.animationTable[i]
		--	self.cuoPaiAnimObj:Play(self.animState)
			Notifier.dispatchCmd("CUO_PAI", self.cuoPaiAnimObj)
		else
			v.gameObject:SetActive(false)
		end
	end
end

function poker_cuopai_manage:OnFingerUpAction(tbl)
	logError("手指离开")
end

function poker_cuopai_manage:Reset()
--	self.cuoPaiAnimObj:SetFloat("SingSpeed",-10)
	self.isFinshCuoPai = false
end

return poker_cuopai_manage