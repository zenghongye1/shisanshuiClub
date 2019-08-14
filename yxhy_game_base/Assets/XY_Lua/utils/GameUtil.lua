local GameUtil = {}
local config_mgr = config_mgr
local GameModel

function GameUtil.GetShareContent(id)
  return LanguageMgr.GetWord(9100)
   --  local cfg = config_mgr.getConfig("cfg_game", id)
   --  if cfg == nil then
   --    return  ""
   --  end
	  -- return cfg.gameShareConent or ""
end


function GameUtil.CheckGameIdIsMahjong(id)
  local cfg = config_mgr.getConfig("cfg_game", id)
  if cfg == nil then
    return  false
  end
  return cfg.isMahjong == 1
end

function GameUtil.GetGameName(id)
  -- local cfg = config_mgr.getConfig("cfg_game", id)
  -- if cfg == nil then
  --   return  ""
  -- end
  -- return cfg.name or ""
  if GameModel == nil then
    GameModel = model_manager:GetModel("GameModel")
  end

  return GameModel:GetGameName(id)
end


function GameUtil.CheckHasGame(id)
   local cfg = config_mgr.getConfig("cfg_game", id)
   return cfg ~= nil
end

function GameUtil.GetRuleName(id)
	local cfg = config_mgr.getConfig("cfg_game", id)
  	if cfg == nil then
    	return  ""
  	end
  	return cfg.ruleName or ""
end

function GameUtil.CheckNeedDown(id)
	local cfg = config_mgr.getConfig("cfg_game", id)
	if cfg == nil then
		return false
	end
	return cfg.needDownload == 1
end

function GameUtil.GetHideRuleKeys(id)
	local cfg = config_mgr.getConfig("cfg_game", id)
	if cfg == nil then
		return nil
	end
	return cfg.hideKey
end

function GameUtil.GetShareKeys(id)
  local cfg = config_mgr.getConfig("cfg_game", id)
  if cfg == nil then
    return nil
  end
  return cfg.shareKey
end

function GameUtil.GetRoomRulesKeys(id)
  local cfg = config_mgr.getConfig("cfg_game", id)
  if cfg == nil then
    return nil
  end
  return cfg.roomRulesKey
end
function GameUtil.GetRoomRulesOtherKeys(id)
	local cfg = config_mgr.getConfig("cfg_game", id)
	if cfg == nil then
		return nil
	end
	return cfg.roomRulesOtherKey
end

function GameUtil.GetRoomGamePlayKeys(id)
	local cfg = config_mgr.getConfig("cfg_game", id)
	if cfg == nil then
		return nil
	end
	return cfg.roomGamePlayKey
end

function GameUtil.GetGameListOrderKeys(id)
	local cfg = config_mgr.getConfig("cfg_game", id)
	if cfg == nil then
		return nil
	end
	return cfg.showOrder or 10000
end

-- 获取游戏图标
function GameUtil.GetGameIcon(id)
  local cfg = config_mgr.getConfig("cfg_game", id)
  if cfg == nil then
    return "club_56"
  end
  if cfg.isMahjong == 1 then
    return "club_56"
  end
  return cfg.icon
end

function GameUtil.GetResId(gid)
  local cfg = config_mgr.getConfig("cfg_game", gid)
  if cfg == nil then
    return nil
  end
  return cfg.resId
end

return GameUtil