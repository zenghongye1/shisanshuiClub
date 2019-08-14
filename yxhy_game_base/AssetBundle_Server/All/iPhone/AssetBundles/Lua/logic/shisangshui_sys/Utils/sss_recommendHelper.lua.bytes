sss_recommendHelper = {}
local this = sss_recommendHelper
local _libNormalCardLogic = {}
local _libRecomand = {}

function this.SetRecommendHelper(gid)
	-- if gid == ENUM_GAME_TYPE.TYPE_SHISHANSHUI then
		_libNormalCardLogic = require("logic.shisangshui_sys.lib.lib_normal_card_logic"):create()
		_libRecomand = require ("logic.shisangshui_sys.lib.lib_recomand"):create()
	-- elseif gid == ENUM_GAME_TYPE.TYPE_PINGTAN_SSS then
	-- 	_libNormalCardLogic = require("logic.shisangshui_sys.pingtan_shisanshui_lib.lib_normal_card_logic_ptsss"):create()
	-- 	_libRecomand = require ("logic.shisangshui_sys.pingtan_shisanshui_lib.lib_recomand_ptsss"):create()
	-- else
	-- 	logError("非十三水的gid:  "..tostring(gid))
	-- 	_libNormalCardLogic = require("logic.shisangshui_sys.lib.lib_normal_card_logic"):create()
	-- 	_libRecomand = require ("logic.shisangshui_sys.lib.lib_recomand"):create()
	-- end
end

function this.GetLibNormalCardLogic()
	return _libNormalCardLogic
end

function this.GetLibRecomand()
	return _libRecomand
end