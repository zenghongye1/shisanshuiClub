-- 过程动画 简易状态机

require "logic/mahjong_sys/Utils/mahjong_path_mgr"

mahjong_anim_state_control = {}
local mahjong_path_mgr = mahjong_path_mgr

local stateList = nil
local currentIndex = 1

local animMap = {}

local coroutineList = {}
-- 预设名，动画名，动画时长
animMap[MahjongGameAnimState.start] = {"anim_game_start", false, "duijukaishi", 1}
animMap[MahjongGameAnimState.changeFlower] = {"anim_buhua", false,  "hua", 1,"buhua"}
animMap[MahjongGameAnimState.grabGold] = {"anim_kaiqiangjin", false,  "qiangjin", 1}
animMap[MahjongGameAnimState.openGold] = {"anim_kaiqiangjin", false, "kaijin", 1}

function mahjong_anim_state_control.InitFuzhouAnims()
	stateList = {}
	table.insert(stateList,MahjongGameAnimState.start)
	table.insert(stateList,MahjongGameAnimState.changeFlower)
	table.insert(stateList,MahjongGameAnimState.openGold)
	table.insert(stateList,MahjongGameAnimState.grabGold)
end


function mahjong_anim_state_control.ShowAnimState(animState, callback, needwait,playSound)


	if currentIndex > #stateList or stateList[currentIndex] ~= animState then
		if callback ~= nil then
			callback()
		end
		return
	end
	local data = animMap[animState]
	currentIndex = currentIndex + 1
	if data == nil then
		if callback ~= nil then
			callback()
		end
		return
	end

	if playSound and data[5] ~= nil then
		ui_sound_mgr.PlaySoundClip(mahjong_path_mgr.GetMjSoundPath(data[5])) 
	end
	local path = mahjong_path_mgr.GetEffPath(data[1], data[2])
	mahjong_anim_state_control.PlayMahjongUIAnim(path,data[3])
	if needwait then
		local time = data[4]
		local anim_c = coroutine.start(function()
			coroutine.wait(time)
			if callback ~= nil then
				callback()
			end
		end)
		table.insert(coroutineList, anim_c)
	else
		if callback ~= nil then
			callback()
		end
	end
end

function mahjong_anim_state_control.Reset()
	currentIndex = 1
	for i = 1, #coroutineList do
		coroutine.stop(coroutineList[i])
	end
	coroutineList = {}
end

function mahjong_anim_state_control.SetState(index)
	currentIndex = index
end

function mahjong_anim_state_control.GetCurrentIndex()
	return currentIndex
end


function mahjong_anim_state_control.PlayMahjongUIAnim(prefab, animName)
	mahjong_ui.ShowUIAnimation(prefab, animName)
end