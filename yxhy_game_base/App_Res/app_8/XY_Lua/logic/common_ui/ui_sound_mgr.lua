--[[--
 * @Description: ui音效管理
 * @Author:      shine
 * @FileName:    ui_sound_mgr.lua
 * @DateTime:    2016-03-12 16:23:28
 ]]

ui_sound_mgr = {}
local this = ui_sound_mgr

local bgAudioSource = nil
local commAudioSource = nil 
local audiosourcetable={}
local soundResTable = {}
local copybgAudioSource=nil 
local bg
--[[--
 * @Description: 音效管理初始化  
 ]]
function this.Init()
	
end

function this.UnInit()

end

function this.SceneLoadFinish() 
    if commAudioSource~=nil and bgAudioSource~=nil then 
        return
    end
    local camera=GameObject.Find("Camera")   
	commAudioSource = subComponentGet(camera.transform, "comm_sound", "AudioSource")
	if commAudioSource == nil then 
		local commSoundObj = child(camera.transform, "comm_sound")  
		if commSoundObj ~= nil then
			commSoundObj.gameObject:AddComponent(typeof(AudioSource))	
		end	
	end	 
	bgAudioSource = subComponentGet(camera.transform, "bg_sound", "AudioSource")
	if bgAudioSource == nil then
		local bgSoundObj = child(camera.transform, "bg_sound")
		if bgSoundObj ~= nil then
			bgSoundObj.gameObject:AddComponent(typeof(AudioSource))
		end
	end   
    bg= GameObject.New("bgAS")
    bg.transform.parent=bgAudioSource.transform.parent
end

--[[--
 * @Description: 播放背景音乐  
 ]]
function this.PlayBgSound(name)  
    local count=bg.transform.childCount-1
    if bg.transform.childCount>0 then
        for i=0,bg.transform.childCount-1 do
            componentGet(bg.transform:GetChild(i),"AudioSource"):Stop()
            --destroy(bg.transform:GetChild(count-i).gameObject)
        end
    end
    copybgAudioSource=GameObject.Instantiate(bgAudioSource)   
    copybgAudioSource.transform.parent=bg.transform
	if copybgAudioSource ~= nil then
		local bgAudioClip = newNormalObjSync("app_8/sound/"..name, typeof(AudioClip)) 
		if bgAudioClip ~= nil then	 
			copybgAudioSource.clip = bgAudioClip 
			copybgAudioSource.loop = true 
			copybgAudioSource:Play()
		end
	end
end

--[[--
 * @Description: 暂停背景音乐  
 ]]
function this.PauseBgSound()
	if bgAudioSource ~= nil then	
		bgAudioSource:Pause()
	end
end

--[[--
 * @Description: 停止背景音乐  
 ]]
function this.StopBgSound( )
	if bgAudioSource ~= nil then	
		bgAudioSource:Stop()
	end
end

--[[--
 * @Description: 播放音效文件  
 ]]
function this.PlaySoundClip(name,isLoop)
	if commAudioSource == nil then
		return
	end
    this.FindUsableAudio()
    local audio=nil
    if audio==nil then 
        audio=GameObject.Instantiate(commAudioSource)
        audio.transform.parent=commAudioSource.transform.parent
        audio.transform.localScale={x=1,y=1,z=1}
        audio.gameObject.name="newAudio"..table.getCount(audiosourcetable)
        table.insert(audiosourcetable, audio.gameObject)  
    end
    if audio~=nil then  
    	local soundSrc = name
    	local commAudioClip
    	if soundResTable[soundSrc]~=nil and not IsNil(soundResTable[soundSrc]) then
    		commAudioClip = soundResTable[soundSrc]
    	else
    	commAudioClip = newNormalObjSync(soundSrc, typeof(AudioClip))
    		soundResTable[soundSrc] = commAudioClip
    	end
         
        if commAudioClip ~= nil and not IsNil(commAudioClip) then	
	       audio.clip = commAudioClip
	       if isLoop then
	       	audio.loop = isLoop
		   else
			audio.loop = false
	       end 
	       audio:Play()   
	       return audio
	    end
    end
end

--[[--
 * @Description: 开始音频播放  
 ]]
function this.StartSound()
	if (not IsNil(commAudioSource)) then
		commAudioSource.enabled = true
	end
end

--[[--
 * @Description: 停止音频播放  
 ]]
function this.StopSound()
	if (not IsNil(commAudioSource)) then
		commAudioSource.enabled = false
	end
end

--[[--
 * @Description: 暂停音效文件  
 ]]
function this.PauseSoundClip()
	if commAudioSource ~= nil then
		commAudioSource:Pause()
	end
end

--[[--
 * @Description: 停止音效文件  
 ]]
function this.StopSoundClip()
	if commAudioSource ~= nil then
		commAudioSource:Stop()
	end
end

function this.PlayMessageClip(paras)
	local value = paras.para1
	this.PlayAnimationSounder(value)
end

function this.PlayAnimationSounder(name)
	if commAudioSource ~= nil then
		local commAudioClip = newNormalObjSync("Sound/animation/"..name, typeof(AudioClip))
		if commAudioClip ~= nil then	
			commAudioSource.clip = commAudioClip
			commAudioSource:Play()
		end
	end
end

function this.controlValue(value)  
	--Trace("bgAudioSource----------------------"..bgAudioSource.name)  
    --componentGet(bgAudioSource, "AudioSource").volume = value
    bgAudioSource.volume = value
end

function this.ControlCommonAudioValue(value )
    commAudioSource.volume=value 
end

function  this.GetBGVolume()
    return  componentGet(bgAudioSource,"AudioSource").volume 
end

function  this.GetCommonVolume()
    return  componentGet(commAudioSource,"AudioSource").volume 
end

--在列表中寻找不在播放的音频
function this.FindUsableAudio() 
    for i=1,#audiosourcetable do
       if not IsNil(audiosourcetable[i]) then   
          local audio=componentGet(audiosourcetable[i],"AudioSource")
          if audio.isPlaying~=true then
             destroy(audiosourcetable[i])
          end
       end
    end
    table.remove_if(audiosourcetable,function(t)if IsNil(t) then return t end end)

    return nil
end

--[[--
 * @Description: 设置所有音源成静音与否  
 ]]
function this.SetAllAudioSourceMute(isMute) 
    commAudioSource.mute=isMute 
	bgAudioSource.mute = isMute
end

