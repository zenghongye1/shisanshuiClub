local Sound = class("Sound")

function Sound:ctor(go)
	self.go = go
	self.audioSrc = self.go:AddComponent(typeof(UnityEngine.AudioSource))
end


function Sound:Play(clip, isLoop, resPath)
	self.resPath = resPath
	self.audioSrc.clip = clip
	self.audioSrc.loop = isLoop or false
	self.audioSrc:Play()
end

function Sound:CheckIsPlaying()
	return self.audioSrc ~= nil and self.audioSrc.isPlaying
end

function Sound:Stop()
	self.audioSrc:Stop()
	self.resPath = nil
end

function Sound:SetVolume(value)
	self.audioSrc.volume = value
end


function Sound:Mute(isMute)
	self.audioSrc.mute = isMute
end

return Sound