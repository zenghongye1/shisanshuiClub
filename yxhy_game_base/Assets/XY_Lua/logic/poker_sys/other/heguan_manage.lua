local heguan_manage = class("heguan_manage")

function heguan_manage:ctor()
	self.heguan = nil
	self.Camera = nil
	self.particle = nil
	self:HeGuan()
end

function heguan_manage:HeGuan()
	self.heguan = GameObject.Find("TableAnchor/heguan")
	if self.heguan == nil then
		logError("找不到荷官对象")
		return
	end
	self.heguanAnimation = componentGet(self.heguan.transform,"Animator")
	if self.heguanAnimation == nil then
		logError("找不到动画组件")
	end
	local cameraObj = GameObject.Find("cameras/Table_Camera")
	self.Camera = componentGet(cameraObj.transform,"Camera")
	local particle = GameObject.Find("heguan/Effect_xin/Particle System")
	self.particle = componentGet(particle.transform,"ParticleSystem")
	if self.particle == nil then
		logError("heguan particle is null")
	end
end

function heguan_manage:MouseBinDown(position)
	if self.Camera == nil then
		self.Camera = Camera.main
	end
	if self.Camera == nil then
		return
	end
	local ray = self.Camera:ScreenPointToRay(position)
	if ray == nil then return end
	local isCast,rayhit = Physics.Raycast(ray,nil)
	if isCast then
		 local tempObj = rayhit.collider.gameObject
		if tempObj.transform.name == "heguan" then
			require("logic.poker_sys.other.GratuitySys"):create():GratuityAction()
			local stateInfo =  self.heguanAnimation:GetCurrentAnimatorStateInfo(0)
			if stateInfo and not stateInfo:IsName("xipai") and not stateInfo:IsName("daiji2") then
				self:PlayHeGuanAnimationByClipName("daiji3")
			end
			if self.particle ~= nil then
				self.particle:Play()
			end
		end
	end
end

--[[
	播放荷官动画
	动画名称有：  daiji1	daiji2	fapai	
]]
function heguan_manage:PlayHeGuanAnimationByClipName(clipName)
	local transitionDuration = 0.1
	self.heguanAnimation:CrossFade(clipName,transitionDuration)
	--[[if self.particle ~= nil then
		self.particle:Play()
	end--]]
end

function heguan_manage:StopPlayHeGuanAnimation()
	if self.heguanAnimation ~= nil then
		if self.heguanAnimation.IsPlaying == true then
			self.heguanAnimation:Stop()
		end
	end
end

return heguan_manage