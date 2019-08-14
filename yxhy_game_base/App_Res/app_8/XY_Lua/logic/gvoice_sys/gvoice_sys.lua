gvoice_sys = {}
local this = gvoice_sys


local gameID = "1972877540"                              --开通业务的游戏ID
local gameKey = "65a29af924ca754f8666b81f63d2e19e"       --开通业务的游戏Key
local openID = nil								         --玩家唯一标示(uid)

--local voiceFileID = nil                                  				--语音文件上传成功后返回的文件ID
local unloadfilePath = Application.persistentDataPath.."/record"		--语音文件上传存储路径
local downloadfilePath = Application.persistentDataPath.."/voice.dat"   --语音文件下载存储路径

local msTimeout = 50000                                  --超时时间
local m_voiceengine = nil                                --语音服务引擎
local isInit = false   									 --是否已经初始化

local voiceTblLst = {}
local curVoiceInfoTbl = {}
local curDownFileInfo = {}
local downFileInfoLst = {}

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
	m_voiceengine = GVoiceInterface.Instance:GetVoiceEngine()     --语音引擎实例化

	if(m_voiceengine==nil) then
		Trace("=====================================语音引擎没有实例")
		return
	end

	GVoiceInterface.Instance:SetDelegateMessageKey(function (code)
		Trace("==================安全密钥==================="..tostring(code))
		if(code==7) then
			isInit=true
			Trace("===========================================语音服务初始化成功============================")
		else 
			Trace("===========================================语音服务初始化失败============================")
		end
	end)

	GVoiceInterface.Instance:SetDelegateUploadReccord(function (code, filePath, fileID)
		Trace("==================上传回调==================="..tostring(code)..tostring(fileID))

		if(code==11) then			
			Trace("======================语音文件上传完成========================")
			if curVoiceInfoTbl ~= nil then
				table.remove(voiceTblLst, 1)
			end
			Notifier.dispatchCmd(cmdName.MSG_VOICE_INFO, fileID)			
			isUpload = false
		else			
			table.remove(voiceTblLst, 1)			
			isUpload = false
		end
	end)

	GVoiceInterface.Instance:SetDelegateDownloadReccord(function (code, filePath, fileID)  
		Trace("==================下载回调==================="..tostring(code))

		if(code==13) then
			Trace("=========================语音文件下载完成==========================")
			table.remove(voiceTblLst, 1)
			isDownload = false
			--将下载文件加入播放队列
			table.insert(downFileInfoLst, curDownFileInfo)		
		else
			table.remove(voiceTblLst, 1)
			isDownload = false
		end
	end)

	GVoiceInterface.Instance:SetDelegatePlayReccord(function (code,filePath)
	 	Trace("==================播放回调==================="..tostring(code))
		if(code==21) then
	 		Trace("================================播放完成=====================")	 
	 		isPlayRecord = false	
			if downFileInfoLst[1] ~=nil then	
				Notifier.dispatchCmd(cmdName.MSG_VOICE_PLAY_END, downFileInfoLst[1].viewSeat)
				table.remove(downFileInfoLst, 1)
			end	 
	 	else	 
	 		isPlayRecord = false
	 		Notifier.dispatchCmd(cmdName.MSG_VOICE_PLAY_END, downFileInfoLst[1].viewSeat)
			table.remove(downFileInfoLst, 1)	 		
	 	end
	end)
	
	Trace("===========================语音服务初始化开始==========================")	
	openID = data_center.GetLoginUserInfo().uid 
	GVoiceInterface.Instance:SetAppInfo(gameID, gameKey, openID)     	--上传玩家业务信息
	GVoiceInterface.Instance:Init()                                  	--初始化
	GVoiceInterface.Instance:SetMode(GCloudVoiceMode.Messages)       	--设置语音模式
	GVoiceInterface.Instance:ApplyMessageKey(msTimeout)             	--申请服务
	GVoiceInterface.Instance:SetMaxMessageLength(msTimeout)             --设置语音最长时间
	UpdateBeat:Add(this.Update)
end


function this.Update()
	if #voiceTblLst > 0 then		
		curVoiceInfoTbl = voiceTblLst[1]

		if curVoiceInfoTbl.flag == 1 and (not isUpload) then
			isUpload = true
			GVoiceInterface.Instance:UploadRecordedFile(curVoiceInfoTbl.filePath, msTimeout)
		elseif curVoiceInfoTbl.flag == 2 and (not isDownload) and (not isPlayRecord) then
			isDownload = true	
			local downFileInfo = {}
			downFileInfo.filePath = downloadfilePath		
			downFileInfo.viewSeat = curVoiceInfoTbl.viewSeat
			curDownFileInfo = downFileInfo
			GVoiceInterface.Instance:DownloadRecordedFile(curVoiceInfoTbl.fileID, downFileInfo.filePath, msTimeout)				
		end
	end

	if #downFileInfoLst > 0 and (not isPlayRecord) and (not isStartRecord) and (not isDownload) then
		isPlayRecord = true
		this.PlayRecordedFile(downFileInfoLst[1].filePath)   -- 语音播放
		Notifier.dispatchCmd(cmdName.MSG_VOICE_PLAY_BEGIN, downFileInfoLst[1].viewSeat)
		curPlayTime = os.time()
	else
		if curPlayTime ~= nil and isPlayRecord then
			if (os.time() - curPlayTime) > maxPlayTime then
				isPlayRecord = false
				Notifier.dispatchCmd(cmdName.MSG_VOICE_PLAY_END, curDownFileInfo.viewSeat)		
			end
		end
	end
end

--[[--
 * @Description: 反初始化处理  
 ]]
function this.Uinit()
	--UpdateBeat:Remove(this.Update)
	voiceTblLst = {}
	curVoiceInfoTbl = {}
	curDownFileInfo = {}
	downFileInfoLst = {}

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
		fast_tip.Show("语音播放中，请稍后")
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
		local sendVoiceInfo = {}
		sendVoiceInfo.flag = 1  	--1代表发送 2代表接收
		sendVoiceInfo.filePath = curRecordFilePath
		table.insert(voiceTblLst, sendVoiceInfo)	
		Trace("voiceTblLst1-------------------------------"..#voiceTblLst)
	end
end

--[[
 将需要下载的fileID 加入语音文件队列
]]
function this.AddDownloadFile(voiceInfoTbl)
	if voiceInfoTbl ~= nil then
		table.insert(voiceTblLst, voiceInfoTbl)
		Trace("voiceTblLst2-------------------------------"..#voiceTblLst)
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
	return m_voiceengine
end

function this.GetIsInit()
	return isInit
end

--[[--
 * @Description: 获取语音长度  
 ]]
function this.GetVoiceFileLen(recordPath)
	local ret = GVoiceInterface.Instance:GetVoiceFileLen(recordPath)
	Trace("ret--------------------"..tostring(ret))
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

function this.IsInitSuccess()
	Trace(tostring(MessageKeyCode))
	if(MessageKeyCode==7) then
		Trace("================================语音服务初始化成功=================================")
	else 
		Trace("================================语音服务初始化失败=================================")
	end
end

--//////////////////////////语音外部接口 end//////////////////////////////

