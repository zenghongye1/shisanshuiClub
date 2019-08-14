
--[[--
 * @Description: 福州麻将玩法配置
 * @FileName:    play_mode_config_fuzhou.lua
 ]]

local mahjong_config_fuzhou = {}

mahjong_config_fuzhou.MahjongTotalCount = 144  -- 麻将总数量
mahjong_config_fuzhou.MahjongDunCount = 18	-- 一排多少墩
mahjong_config_fuzhou.MahjongHandCount = 16	-- 手牌数量
mahjong_config_fuzhou.MahjongWallCount = 4	-- 排墙数量

mahjong_config_fuzhou.byFanType = {--0平胡，32无花无杠,33一张花,34金雀,35金龙,36半清一色,37清一色,38闲金，39三金倒
	[0] = "平胡",
	[16] = "天胡",
	[17] = "地胡",
	[31] = "闲金",
	[32] = "无花无杠",
	[33] = "一张花",
	[34] = "金雀",
	[35] = "金龙",
	[36] = "半清一色",
	[37] = "清一色",
	[38] = "抢金",
	[39] = "三金倒",
	
}

mahjong_config_fuzhou.sceneCfg = {}
mahjong_config_fuzhou.sceneCfg.mainCameraPos = Vector3(0, 9.29, -8.71)
mahjong_config_fuzhou.sceneCfg.mainCameraEulers = Vector3(47, 0,0)

mahjong_config_fuzhou.sceneCfg.twoCameraPos = Vector3(0, 2.77, -5.95)
mahjong_config_fuzhou.sceneCfg.twoCameraEulers = Vector3(12, 0, 0)

return mahjong_config_fuzhou