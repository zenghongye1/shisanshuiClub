mahjong_path_mgr = {}

mahjong_path_mgr.mjPath = "scene"
mahjong_path_mgr.effectPath = "effects"
mahjong_path_mgr.materialPath = "materials"
mahjong_path_mgr.soundPath = "sound"
mahjong_path_mgr.commonSoundPath = "sound/common"
mahjong_path_mgr.pathMap = {}
-- 语言路径可能经常变化 需要单独处理
mahjong_path_mgr.mjSoundMap = {}

function mahjong_path_mgr.InitGameId(gameId, commonPath)
	if mahjong_path_mgr.curGameId == gameId and mahjong_path_mgr.commonPrefix == commonPath then
		return
	end
	mahjong_path_mgr.curGameId = gameId
	mahjong_path_mgr.curGamePrefix = "game_" .. gameId
	mahjong_path_mgr.commonPrefix = commonPath or "app_4"
	mahjong_path_mgr.pathMap = {}
end


-- game_id/scene/name
function mahjong_path_mgr.GetMjPath(name, isCommon)
	return mahjong_path_mgr.GetPath(name, isCommon, mahjong_path_mgr.mjPath)
end

-- game_id/effects/name
function mahjong_path_mgr.GetEffPath(name, isCommon)
	return mahjong_path_mgr.GetPath(name, isCommon, mahjong_path_mgr.effectPath)
end

-- game_id/materials/name
function mahjong_path_mgr.GetMaterialPath(name, isCommon)
	return mahjong_path_mgr.GetPath(name, isCommon, mahjong_path_mgr.materialPath)
end

function mahjong_path_mgr.GetNormalPath(name, mid, isCommon)
	return mahjong_path_mgr.GetPath(name, isCommon, mid)
end

function mahjong_path_mgr.GetMjCommonSoundPath(name, isCommon)
	return mahjong_path_mgr.GetPath(name, isCommon, mahjong_path_mgr.commonSoundPath)
end

-- 麻将语音 区分男女 方言
function mahjong_path_mgr.GetMjSoundPath(name, isCommon)
	-- 获取sex, 方言前缀
	local sex = "woman"
	if mahjong_path_mgr.mjSoundMap[name] ~= nil then
		return mahjong_path_mgr.mjSoundMap[name]
	end
	local prefix = isCommon and mahjong_path_mgr.commonPrefix or mahjong_path_mgr.curGamePrefix
	local mid = mahjong_path_mgr.soundPath
	local path = mahjong_path_mgr.GetConcatPath(prefix, mid, sex, name)
	mahjong_path_mgr.mjSoundMap[name] = path
	return path
end

-- 切换语音设置时调用
function mahjong_path_mgr.ChangeMjSoundType()
	mahjong_path_mgr.mjSoundMap = {}
end


function mahjong_path_mgr.GetPath(name, isCommon, mid)
	if mahjong_path_mgr.pathMap[name] ~= nil then
		return mahjong_path_mgr.pathMap[name]
	end
	local prefix = isCommon and mahjong_path_mgr.commonPrefix or mahjong_path_mgr.curGamePrefix
	local path = mahjong_path_mgr.GetConcatPath(prefix, mid, name)
	mahjong_path_mgr.pathMap[name] = path
	return path
end

function mahjong_path_mgr.GetConcatPath(...)
	local tab = {...}
	return table.concat(tab, "/")
end