-- 过程动画 简易状态机
require "logic/mahjong_sys/utils/mahjong_path_mgr"

mahjong_anim_state_control = {}

local mahjong_path_mgr = mahjong_path_mgr
local mahjong_path_enum = mahjong_path_enum
local stateList = nil
local currentIndex = 1

local animMap = {}

local coroutineList = {}
-- -- 预设名，isCommon,动画名，动画时长

function mahjong_anim_state_control.InitFuzhouAnims(config)
	stateList = {}
	animMap = {}
	for i = 1, #config.stateAnimList do
		animMap[config.stateAnimList[i]] = config.stateAnimMap[config.stateAnimList[i]]
		table.insert(stateList,config.stateAnimList[i])
	end

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
	--local path = mahjong_path_mgr.GetEffPath(data[1], data[2])
	mahjong_anim_state_control.PlayMahjongUIAnim(data[1])
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

function mahjong_anim_state_control.SetStateByName(state)
	for index,stateName in ipairs(stateList) do
		if state == stateName then
			currentIndex = index
			return
		end
	end
end

function mahjong_anim_state_control.GetCurrentIndex()
	return currentIndex
end

function mahjong_anim_state_control.GetCurrentStateName()
	return stateList[currentIndex]
end

function mahjong_anim_state_control.PlayMahjongUIAnim(effectId)
	mahjong_ui:ShowUIAnimationById(effectId)
end