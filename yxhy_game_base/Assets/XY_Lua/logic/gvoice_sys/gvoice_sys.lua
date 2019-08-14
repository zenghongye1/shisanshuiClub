gvoice_sys = {}
local this = gvoice_sys


local gameID = "1972877540"                              --开通业务的游戏ID
local gameKey = "65a29af924ca754f8666b81f63d2e19e"       --开通业务的游戏Key
local openID = nil								         --玩家唯一标示(uid)

local unloadfilePath = Application.persistentDataPath.."/record"		--语音文件上传存储路径
local downloadfilePath = Application.persistentDataPath.."/voice.dat"   --语音文件下载存储路径

local msTimeout = 50000                                  --超时时间
local maxTimeout = 110000								 --最大语音长度
local voiceengine = nil                                	 --语音服务引擎
local isInit = false   									 --是否已经初始化

local curRecordFilePath = nil
local uploadFileLst = {}
local downFileLst = {}
local playFileLst = {}

local isStartRecord = false   --是否开始录音
local isUpload = false        --是否上传
local isDownload = false      --是否下载
local isPlayRecord = false    --是否播放录音

local fileIndex = 0           --录音存放文件索引值
local maxFileCount = 10       --最大存放录音文件数量

local curPlayTime = nil       --当前播放录音时间
local maxPlayTime = 20        --最长录音的时间
local minPlayTime = 1         --最小录音的时间


--[[
语音服务初始化
]]
function this.GVoiceInit()
	voiceengine = GVoiceInterface.Instance:GetVoiceEngine()     --语音引擎实例化

	if(voiceengine==nil) then
		Trace("=====================================语音引擎没有实例")
		return
	end

	GVoiceInterface.Instance:SetDelegateMessageKey(function (code)
		Trace("==================安全密钥==================="..tostring(code))
		if(code==7) then
			isInit=true
		else
			UI_Manager:Instance():FastTip(LanguageMgr.GetWord(10110))
		end
	end)

	GVoiceInterface.Instance:SetDelegateUploadReccord(function (code, filePath, fileID)
		Trace("==================上传回调==================="..tostring(code)..tostring(fileID))

		if(code==11) then
			if #uploadFileLst > 0 then
				table.remove(uploadFileLst, 1)				
			end
			Notifier.dispatchCmd(cmdName.MSG_VOICE_INFO, fileID)						
			isUpload = false
		else			
			if #uploadFileLst > 0 then
				table.remove(uploadFileLst, 1)				
			end			
			isUpload = false
		end
	end)

	GVoiceInterface.Instance:SetDelegateDownloadReccord(function (code, filePath, fileID)  
		Trace("==================下载回调==================="..tostring(code))
		if(code==13) then						
			--将下载文件加入播放队列
			if #downFileLst > 0 then
				table.insert(playFileLst, downFileLst[1])		
				table.remove(downFileLst, 1)
			end
			isDownload = false
		else
			if #downFileLst > 0 then
				table.remove(downFileLst, 1)
			end			
			isDownload = false
		end
	end)

	GVoiceInterface.Instance:SetDelegatePlayReccord(function (code, filePath)
	 	Trace("==================播放回调==================="..tostring(code))
		if(code==21) then	 	 		
	 		if #playFileLst > 0 then
	 			if playFileLst[1].viewSeat ~= nil then
	 				Notifier.dispatchCmd(cmdName.MSG_VOICE_PLAY_END, playFileLst[1].viewSeat)					
	 			end
	 			table.remove(playFileLst, 1)
	 		end
	 		isPlayRecord = false	
	 	else	 
	 		if #playFileLst > 0 then
	 			if playFileLst[1].viewSeat ~= nil then	 		
	 				Notifier.dispatchCmd(cmdName.MSG_VOICE_PLAY_END, playFileLst[1].viewSeat)
	 			end
				table.remove(playFileLst, 1)	 		
			end
			isPlayRecord = false
	 	end
	end)
	
	Trace("===========================语音服务初始化开始==========================")	
	openID = data_center.GetLoginUserInfo().uid 
	GVoiceInterface.Instance:SetAppInfo(gameID, gameKey, openID)     	--上传玩家业务信息
	GVoiceInterface.Instance:Init()                                  	--初始化
	GVoiceInterface.Instance:SetMode(GCloudVoiceMode.Messages)       	--设置语音模式
	GVoiceInterface.Instance:ApplyMessageKey(msTimeout)             	--申请服务
	GVoiceInterface.Instance:SetMaxMessageLength(maxTimeout)            --设置语音最长时间
	UpdateBeat:Add(this.Update)
end


function this.Update()
	if #playFileLst > 0 and (not isPlayRecord) and (not isStartRecord) and (not isDownload) then
		isPlayRecord = true
		this.PlayRecordedFile(downloadfilePath)   -- 语音播放
		Notifier.dispatchCmd(cmdName.MSG_VOICE_PLAY_BEGIN, playFileLst[1].viewSeat)
		curPlayTime = os.time()
	else
		if curPlayTime ~= nil and isPlayRecord then
			if (os.time() - curPlayTime) > maxPlayTime then
				isPlayRecord = false
				Notifier.dispatchCmd(cmdName.MSG_VOICE_PLAY_END, playFileLst[1].viewSeat)		
			end
		end
	end

	if #uploadFileLst > 0 and (not isUpload) then
		isUpload = true
		GVoiceInterface.Instance:UploadRecordedFile(uploadFileLst[1].filePath, msTimeout)
	end 

	if #downFileLst > 0 and (not isDownload) and (not isPlayRecord) then
		isDownload = true	
		GVoiceInterface.Instance:DownloadRecordedFile(downFileLst[1].fileID, downloadfilePath, msTimeout)			
	end
end

--[[--
 * @Description: 反初始化处理  
 ]]
function this.Uinit()
	--UpdateBeat:Remove(this.Update)
	uploadFileLst = {}
	downFileLst = {}
	playFileLst = {}

	isStartRecord = false
	isUpload = false
	isDownload = false
	isPlayRecord = false
end


--[[
 开始录音
]]
function this.StartRecording()
	if not isPlayRecord then
		isStartRecord = true
		fileIndex = fileIndex + 1
		if fileIndex > maxFileCount then
			fileIndex = 1
		end

		--将音频设置成静音
		ui_sound_mgr.SetAllAudioSourceMute(true)

		curRecordFilePath = unloadfilePath..tostring(fileIndex)..".dat"		
		GVoiceInterface.Instance:StartRecording(curRecordFilePath)
	else
		curRecordFilePath = nil
		UI_Manager:Instance():FastTip("语音播放中，请稍后")
		return false
	end
	return true
end

--[[
录音停止
]]
function this.StopRecording()
	GVoiceInterface.Instance:StopRecording()
	isStartRecord = false

	--恢复静音
	ui_sound_mgr.SetAllAudioSourceMute(false)	
end

--[[
上传录音文件
]]
function this.AddRecordedFileLst()
	if curRecordFilePath ~= nil then
		local voiceInfo = {}
		voiceInfo.flag = 1  	--1代表发送 2代表接收
		voiceInfo.filePath = curRecordFilePath
		table.insert(uploadFileLst, voiceInfo)	
		Trace("uploadFileLst-------------------------------"..#uploadFileLst)
	end
end

--[[
 将需要下载的fileID 加入语音文件队列
]]
function this.AddDownloadFile(voiceInfoTbl)
	if voiceInfoTbl ~= nil then
		table.insert(downFileLst, voiceInfoTbl)
		Trace("downFileLst-------------------------------"..#downFileLst)
	end	
end

--[[
	播放语音文件
]]
function this.PlayRecordedFile(filePath)
	GVoiceInterface.Instance:PlayRecordedFile(filePath)
end


function this.Pause(isPause)
	GVoiceInterface.Instance:OnApplicationPause(isPause)
end

function this.Resume(isPause)
	GVoiceInterface.Instance:OnApplicationResume(isPause)
end

--[[
	停止播放语音
]]
function this.StopPlayFile()
	GVoiceInterface.Instance:StopPlayFile()
end

--//////////////////////////语音外部接口 start////////////////////////////
--[[
获得服务引擎
]]
function this.GetEngine()
	return voiceengine
end

function this.GetIsInit()
	return isInit
end

--[[--
 * @Description: 获取语音长度  
 ]]
function this.GetVoiceFileLen(recordPath)
	local ret = GVoiceInterface.Instance:GetVoiceFileLen(recordPath)
	return ret
end


function this.GetUploadfilePath()
	return unloadfilePath
end

function this.GetDownloadfilePath()
	return downloadfilePath
end

function this.GetMaxRecordTime()
	return maxPlayTime
end

function this.GetMinRecordTime()
	return minPlayTime
end
--//////////////////////////语音外部接口 end//////////////////////////////

