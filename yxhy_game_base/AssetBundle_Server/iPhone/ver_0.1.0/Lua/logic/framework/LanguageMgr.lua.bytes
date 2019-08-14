local LanguageMgr = {}
local config_mgr = config_mgr
local wordConfigName = "cfg_language"

function LanguageMgr.GetWord(id, ...)
	local cfg = config_mgr.getConfig(wordConfigName, id)
	if cfg == nil then
		return ""
	end
	if ... == nil then
		return cfg.content
	else
		return string.format(cfg.content, ...)
	end
end


return LanguageMgr