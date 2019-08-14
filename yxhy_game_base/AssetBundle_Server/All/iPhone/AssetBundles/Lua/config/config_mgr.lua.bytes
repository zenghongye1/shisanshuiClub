local config_mgr = {}

local _cfgMap = {}

local _basePath = "config/"

-- 获取单条config
function config_mgr.getConfig(name, id)
	local configs = config_mgr.getConfigs(name)
	if configs == nil then
		return nil
	end
	if configs[id] == nil then
		-- logError("找不到Id", name, id)
		return nil
	end

	return configs[id]
end


-- 获取全部config
function config_mgr.getConfigs(name)
	if _cfgMap[name] ~= nil then
		return _cfgMap[name]
	end
	local cfgs = require(_basePath .. name)

	if not cfgs then
		-- logError("找不到配置表", name)
		return nil
	end
	_cfgMap[name] = cfgs
	return cfgs
end

function config_mgr.release()
	_cfgMap = {}
end


return config_mgr