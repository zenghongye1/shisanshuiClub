local MessageHelper = {}

local fastTipList = {}
local messageBoxList = {}

function MessageHelper.Init()
	Notifier.regist(GameEvent.OnChangeScene, MessageHelper.OnSceneChange)
end


function MessageHelper.OnSceneChange()
	if game_scene.getCurSceneType() == scene_type.HALL then
		MessageHelper.ShowCachedFastTipInternal()
		MessageHelper.ShowCacheMessageBoxInternal()
	end
end


function MessageHelper.CacheFastTip(content)
	table.insert(fastTipList, content)
end

-- 暂时不支持回调，只做通知
function MessageHelper.CacheMessageBox(content, override)
	if override then
		messageBoxList = {}
	end
	table.insert(messageBoxList, content)
end

function MessageHelper.ClearCacheMessage()
	fastTipList = {}
	messageBoxList = {}
end




-- 直接覆盖tips
function MessageHelper.ShowCachedFastTipInternal()
	for i = 1, #fastTipList do
		UIManager:FastTip(fastTipList[i])
	end
	fastTipList = {}
end


function MessageHelper.ShowCacheMessageBoxInternal()
	if #messageBoxList > 0 then
		MessageBox.ShowSingleBox(messageBoxList[1], 
			function() table.remove(messageBoxList,1) MessageHelper.ShowCacheMessageBoxInternal() end,
			 nil, nil, false)
	else
		MessageBox.HideBox()
	end
end


return MessageHelper