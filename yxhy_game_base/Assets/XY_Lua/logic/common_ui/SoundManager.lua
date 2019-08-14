local SoundManager = class("SoundManager")
local Sound = require("logic/common_ui/Sound")
local MAX_COMMON_SOUND = 5

function SoundManager:ctor()
	self.bgSound = nil
	self.soundList = {}
	self.commonSoundRootGo = nil
	self.bgSoundRootGo = nil
	self.cachedClipMap = {}
end

function SoundManager:Init()
	self.commonSoundRootGo = GameObject.Find("uiroot_xy/Camera/comm_sound")
	self.bgSoundRootGo = GameObject.Find("uiroot_xy/Camera/bg_sound")
	self.bgSound = Sound:create(self.bgSoundRootGo)
end


function SoundManager:PlayBgSound(path)
	local clip = self:GetSoundClip(path)
	if clip == nil then
		return
	end
	self.bgSound:Play(clip, true, path)
end

function SoundManager:PlaySoundClip(path, isLoop)
	local sound = self:GetCommonSound()
	local clip = self:GetSoundClip(path)
	if clip ~= nil then
		sound:Play(clip, isLoop or false, path)
	end
end

function SoundManager:GetCommonSound()
	local sound = nil
	for i = 1, #self.soundList do
		if not self.soundList[i]:CheckIsPlaying() then
			return self.soundList[i]
		end
	end

	if #self.soundList > MAX_COMMON_SOUND then
		-- 暂时重用第一个  如果出问题 再加策略修改  可以考虑播放进度
		return self.soundList[1]
	end

	sound = Sound:create(self.commonSoundRootGo)
	table.insert(self.soundList, sound)
	return sound
end


function SoundManager:GetSoundClip(path)
	if self.cachedClipMap[path] ~= nil then
		return self.cachedClipMap[path]
	end
	local clip = newNormalObjSync(path, typeof(AudioClip))
	if clip ~= nil then
		self.cachedClipMap[path] = clip 
	end
	return clip
end

function SoundManager:SetBgVolume(value)
	self.bgSound:SetVolume(value)
end

function SoundManager:SetCommonVolume(value)
	for i = 1, #self.soundList do
		self.soundList[i]:SetVolume(value)
	end
end

function SoundManager:SetAllMute(value)
	self.bgSound:Mute(value)
	for i = 1, #self.soundList do
		self.soundList[i]:Mute(value)
	end
end

function SoundManager:StopBgSound()
	self.bgSound:Stop()
end

return SoundManager