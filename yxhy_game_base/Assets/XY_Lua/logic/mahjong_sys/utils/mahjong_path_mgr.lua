mahjong_path_mgr = {}

local mahjong_path_enum = mahjong_path_enum


mahjong_path_mgr.mjPath = "scene"
mahjong_path_mgr.effectPath = "effects"
mahjong_path_mgr.materialPath = "materials"
mahjong_path_mgr.soundPath = "sound"
mahjong_path_mgr.commonSoundPath = "sound/common"
mahjong_path_mgr.commonMJPrefix = data_center.GetAppConfDataTble().appPath .. "/mj_common"
mahjong_path_mgr.pathMap = {}
-- 语言路径可能经常变化 需要单独处理
mahjong_path_mgr.mjSoundMap = {}

function mahjong_path_mgr.InitGameId(gameId, commonPath)
	if mahjong_path_mgr.curGameId == gameId and commonPath ~= nil and mahjong_path_mgr.commonPrefix == commonPath then
		return
	end
	mahjong_path_mgr.curGameId = gameId
	mahjong_path_mgr.curGamePrefix = "game_" .. gameId
	mahjong_path_mgr.commonPrefix = commonPath or data_center.GetAppConfDataTble().appPath
	mahjong_path_mgr.commonMJPrefix = data_center.GetAppConfDataTble().appPath .. "/mj_common"
	mahjong_path_mgr.pathMap = {}
end


-- game_id/scene/name
function mahjong_path_mgr.GetMjPath(name, pathType)
	pathType = pathType or mahjong_path_enum.mjCommon
	return mahjong_path_mgr.GetPath(name, pathType, mahjong_path_mgr.mjPath)
end

-- game_id/effects/name
function mahjong_path_mgr.GetEffPath(name, pathType)
	return mahjong_path_mgr.GetPath(name, pathType, mahjong_path_mgr.effectPath)
end

-- game_id/materials/name
function mahjong_path_mgr.GetMaterialPath(name, pathType)
	pathType = pathType or mahjong_path_enum.mjCommon
	return mahjong_path_mgr.GetPath(name, pathType, mahjong_path_mgr.materialPath)
end

function mahjong_path_mgr.GetMjCommonSoundPath(name, pathType)
	if pathType == true or pathType == nil then
		pathType = mahjong_path_enum.common
	end
	return mahjong_path_mgr.GetPath(name, pathType, mahjong_path_mgr.commonSoundPath)
end

-- 麻将语音 区分男女 方言
function mahjong_path_mgr.GetMjSoundPath(name, pathType)
	pathType = pathType or mahjong_path_enum.mjCommon
	-- 获取sex, 方言前缀
	local sex = "woman"
    -- if  tonumber(hall_data.GetPlayerPrefs("woman","1"))==1 then 
    --     sex="woman"
    -- else
    --     sex = "man"
    -- end
    -- local language_type = hall_data.GetPlayerPrefs("language","1") 
    -- local fangyan=""
    -- if tonumber(language_type)==0 then
    --     fangyan="putong"
    -- else
    --     fangyan="fangyan"
    -- end
	if mahjong_path_mgr.mjSoundMap[name] ~= nil then
		return mahjong_path_mgr.mjSoundMap[name]
	end
	local prefix = mahjong_path_mgr.curGamePrefix
	if pathType == mahjong_path_enum.mjCommon then
		prefix = mahjong_path_mgr.commonMJPrefix
	elseif pathType == mahjong_path_enum.common then
		prefix = mahjong_path_mgr.commonPrefix
	end
	local mid = mahjong_path_mgr.soundPath
	local path = mahjong_path_mgr.GetConcatPath(prefix, mid, sex, name)
	mahjong_path_mgr.mjSoundMap[name] = path
	return path
end

-- 切换语音设置时调用
function mahjong_path_mgr.ChangeMjSoundType()
	mahjong_path_mgr.mjSoundMap = {}
end


function mahjong_path_mgr.GetPath(name, pathType, mid)
	if mahjong_path_mgr.pathMap[name] ~= nil then
		return mahjong_path_mgr.pathMap[name]
	end
	local prefix = mahjong_path_mgr.curGamePrefix
	if pathType == mahjong_path_enum.mjCommon then
		prefix = mahjong_path_mgr.commonMJPrefix
	elseif pathType == mahjong_path_enum.common then
		prefix = mahjong_path_mgr.commonPrefix
	end
	local path = mahjong_path_mgr.GetConcatPath(prefix, mid, name)
	mahjong_path_mgr.pathMap[name] = path
	return path
end

function mahjong_path_mgr.GetConcatPath(...)
	local tab = {...}
	return table.concat(tab, "/")
end