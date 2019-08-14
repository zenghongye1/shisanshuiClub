--[[--------------------------------------------------------------

%%%cfg_rule(自动生成，请勿修改！)

----------------------------------------------------------------]]

local t = {}

t["bSupportOneColor"] = {name = "清一色", shareValue = {[1]="清一色"}, RoomRuleKey = "nOneColor"}
t["bSupportGoldDragon"] = {name = "金龙", shareValue = {[1]="金龙"}, RoomRuleKey = "nGoldDragon"}
t["maxplayernum"] = {name = "人数", shareValue = {[2]="2人",[3]="3人",[4]="4人",[5]="5人",[6]="6人",[7]="7人",[8]="8人"}, RoomRuleKey = "pnum"}
t["costtype"] = {name = "房费", shareValue = {[0]="房主支付",[1]="AA支付",[2]="大赢家支付",[3]="会长支付"}, RoomRuleKey = "costtype"}
t["bSupportGunAll"] = {name = "点炮结算", nameByGid = {[2213015] = "一炮多响",[2215001] = "一炮多响",[2215002] = "一炮多响",[2213083] = "一炮多响"}, shareValue = {[1]="点炮全赔",[0]="点炮单赔"}, shareValueByGid = {[2213015] = {[1]="一炮多响"},[2215001] = {[1]="一炮多响"},[2215002] = {[1]="一炮多响"},[2213083] = {[1]="一炮多响"}}, connect = "bSupportGunWin", RoomRuleKey = "nGunAll"}
t["bSupportJu"] = {name = "玩法", shareValue = {[1]="打局",[0]="打课"}, RoomRuleKey = "bsupportju"}
t["bsupportke"] = {name = "玩法", shareValue = {[1]="打课",[0]="打局"}, }
t["bSupportSanJinDao"] = {name = "三金倒", shareValue = {[1]="三金倒"}, RoomRuleKey = "nSanJinDao"}
t["bNoSupportPingHuByOneGold"] = {name = "单金不能平胡", shareValue = {[1]="单金不能平胡"}, RoomRuleKey = "nonegold"}
t["bMustYouJinByTwoGold"] = {name = "双金以上游金", shareValue = {[1]="双金及以上要游金"}, RoomRuleKey = "ntwogold"}
t["bSupportXiaPao"] = {name = "下注", nameByGid = {[2241008] = "下跑",[2241009] = "下跑",[2241010] = "下跑",[2241029] = "下漂",[2241030] = "下跑",[2241048] = "下跑",[2241054] = "下跑",[2241055] = "下跑",[2241056] = "下跑",[2241057] = "下跑",[2241068] = "下跑",[2241069] = "下跑",[2242001] = "定漂",[2213082] = "下跑",[2252001] = "估卖",[2213087] = "下跑"}, shareValue = {[1]="下注"}, shareValueByGid = {[2241008] = {[1]="下跑"},[2241009] = {[1]="下跑"},[2241010] = {[1]="下跑"},[2241029] = {[1]="下漂"},[2241030] = {[1]="下跑"},[2241048] = {[1]="下跑"},[2241054] = {[1]="下跑"},[2241055] = {[1]="下跑"},[2241056] = {[1]="下跑"},[2241057] = {[1]="下跑"},[2241068] = {[1]="下跑"},[2241069] = {[1]="下跑"},[2215002] = {[1]="下跑"},[2215003] = {[1]="下跑"},[2242001] = {[1]="自由漂",[0]="不漂"},[2213082] = {[1]="下跑"},[2252001] = {[1]="估卖"},[2213087] = {[1]="跑"}}, RoomRuleKey = "lowrun"}
t["bSupportCB"] = {name = "承包", shareValue = {[1]="承包"}, }
t["bBankerType"] = {name = "坐庄方式", shareValue = {[0]="胡庄",[1]= "轮庄"}, }
t["bSupportGunWin"] = {name = "点炮胡", nameByGid = {[2213089] = "可点炮胡",[2213086] = "可点炮胡",[2213087] = "可点炮胡"}, shareValue = {[0]="无点炮胡",[1]="有点炮胡"}, shareValueByGid = {[2213089] = {[1]="可点炮胡"},[2213086] = {[1]="可点炮胡"},[2213087] = {[1]="可点炮胡"}}, RoomRuleKey = "hutype"}
t["bSupportGoldIsBai"] = {name = "白板金", shareValue = {[1]="白板金"}, }
t["bBankerDouble"] = {name = "庄翻倍", shareValue = {[1]="庄翻倍"}, }
t["bHalfSelfDraw"] = {name = "玩法", shareValue = {[1]="半自摸", [0]="全自摸"}, }
t["nYouJinFanNum"] = {name = "游金倍数", shareValue = {[4]="游金4倍",[5]="游金5倍"}, }
t["bSupportThreePeng"] = {name = "开局三连碰", shareValue = {[1]="开局三连碰"}, }
t["nSubGameStyle"] = {name = "有金", shareValue = {[1]="有金"}, }
t["bGunWinSanShui"] = {name = "3水以上可以平胡", shareValue = {[1]="3水以上可以平胡"}, }
t["nFlower"] = {name = "花牌", shareValue = {[8]="8花",[12]="12花",[16]="16花"}, }
t["bSupGroundWin"] = {name = "地胡", shareValue = {[1]="地胡"}, }
t["bSupNonPingHu"] = {name = "无平胡", shareValue = {[1]="无平胡"}, }
t["bSupGunDouble"] = {name = "点炮结算", shareValue = {[0]="单赔",[1]="全赔",[2]="2倍单赔"}, }
t["bMustYouJinBySanGold"] = {name = "三金以上游金", shareValue = {[1]="三金及以上要游金"}, }
t["nSupportBaiStyle"] = {name = "玩法", shareValue = {[1]="白板普通牌",[2]="白板替金",[3]="白板补牌"}, }
t["bSupportBaiScore"] = {name = "计分", shareValue = {[1]="白板计2分"}, }
t["bSupportGoldAdd"] = {name = "定金", shareValue = {[0]="不进金",[1]="进金"}, }
t["nSupportBaseScore"] = {name = "底分", shareValue = {[1]="1分",[3]="3分",[5]="5分",[10]="10分"}, }
t["bSupportGangPao"] = {name = "带杠跑", nameByGid = {[2241029] = "带杠漂"}, shareValue = {[1]="带杠跑"}, shareValueByGid = {[2241029] = {[1]="带杠漂"}}, RoomRuleKey = "gangrun"}
t["bSupportWind"] = {name = "带风牌", nameByGid = {[2213081] = "风牌",[2213089] = "带风牌",[2213085] = "风牌",[2213086] = "带风牌",[2213087] = "带风牌"}, shareValue = {[1]="带风牌"}, shareValueByGid = {[2213081] = {[1]="风牌"},[2213089] = {[1]="带风牌"},[2213085] = {[1]="风牌"},[2213086] = {[1]="带风牌"},[2213087] = {[1]="带风牌"}}, RoomRuleKey = "wind"}
t["bSupportHun"] = {name = "带混牌", nameByGid = {[2241068] = "红中癞子",[2213086] = "红中混儿"}, shareValue = {[1]="带混牌"}, shareValueByGid = {[2241068] = {[1]="红中癞子"},[2213086] = {[1]="红中混儿"}}, RoomRuleKey = "hun"}
t["bSupportDealerAdd"] = {name = "庄家加底", nameByGid = {[2241069] = "庄家加2底",[2213015] = "庄家加番",[2213085] = "庄家加倍",[2213087] = "庄翻倍"}, shareValue = {[1]="庄家加底"}, shareValueByGid = {[2241069] = {[1]="庄家加2底"},[2213015] = {[1]="庄家加番"},[2213085] = {[1]="庄家加倍"},[2213087] = {[1]="庄翻倍"}}, RoomRuleKey = "dealeradd"}
t["bSupportGangFlowAdd"] = {name = "杠上花加倍", nameByGid = {[2222001] = "杠上开花"}, shareValue = {[1]="杠上花加倍"}, shareValueByGid = {[2222001] = {[1]="杠上开花"}}, RoomRuleKey = "gfadd"}
t["bSupportSevenDoubleAdd"] = {name = "七对加倍", nameByGid = {[2213084] = "七对8倍",[2213089] = "七对加番"}, shareValue = {[1]="七对加倍"}, shareValueByGid = {[2213084] = {[1]="七对8倍"},[2213089] = {[1]="七对加番"}}, RoomRuleKey = "spadd"}
t["bSupportPiCi"] = {name = "皮次胡", shareValue = {[1]="皮次胡"}, }
t["bGangCiAdd"] = {name = "杠次翻倍", shareValue = {[1]="杠次翻倍"}, }
t["bSuHuAdd"] = {name = "素胡加倍", shareValue = {[1]="素胡加倍"}, }
t["bKaWuAdd"] = {name = "卡五星加倍", shareValue = {[1]="卡五星加倍"}, }
t["bGangAddNoWin"] = {name = "荒庄不荒杠", shareValue = {[1]="荒庄不荒杠"}, }
t["bFourHunAdd"] = {name = "四混胡加倍", nameByGid = {[2241068] = "四赖翻倍",[2213087] = "混儿杠"}, shareValue = {[1]="四混胡加倍"}, shareValueByGid = {[2241068] = {[1]="四赖翻倍"},[2213087] = {[1]="混儿杠"}}, }
t["bJiangHu"] = {name = "258将", shareValue = {[1]="258将"}, }
t["bMissHu"] = {name = "缺一门", shareValue = {[1]="缺一门"}, }
t["bDianGangHua"] = {name = "点杠花", shareValue = {[0]="点杠花自摸",[1]="点杠花点炮"}, RoomRuleKey = "settlement"}
t["bQiangGang"] = {name = "抢杠胡", shareValue = {[1]="抢杠胡"}, RoomRuleKey = "qghu"}
t["bQiangGangAdd"] = {name = "抢杠胡加倍", shareValue = {[1]="抢杠胡加倍"}, }
t["bSupportTing"] = {name = "报听胡", nameByGid = {[2213086]="报听"}, shareValue = {[1]="报听胡"}, shareValueByGid = {[2213086] = {[1]="报听"}}, }
t["bSupportSevenDoubleHun"] = {name = "七对带混", nameByGid = {[2241068]="七对带赖"}, shareValue = {[1]="七对带混"}, shareValueByGid = {[2241068] = {[1]="七对带赖"}}, }
t["bMissHuAdd"] = {name = "断门加倍", shareValue = {[1]="断门加倍"}, }
t["bWindDrawAdd"] = {name = "风摸加倍", shareValue = {[1]="风摸加倍"}, }
t["bWindPu"] = {name = "风扑", shareValue = {[1]="风扑"}, }
t["bJiangPu"] = {name = "将扑", shareValue = {[1]="将扑"}, }
t["bYaojiuPu"] = {name = "幺九扑", shareValue = {[1]="幺九扑"}, }
t["bkaAdd"] = {name = "卡张加分", shareValue = {[1]="卡张加分"}, }
t["bDanDiaoAddScore"] = {name = "单吊加倍", shareValue = {[1]="单吊加倍"}, }
t["nBuyCode"] = {name = "马牌", shareValue = {[0]="无马牌",[1]="红心8马牌",[2]="红心5马牌",[3]="红心10马牌",[4]="红心K马牌",[5]="随机马牌"}, RoomRuleKey = "bSupportBuyCode"}
t["nGhostAdd"] = {name = "加大小鬼", shareValue = {[0]="不加鬼",[1]="加1鬼",[2]="加2鬼",[3]="加3鬼",[4]="加4鬼",[5]="加5鬼",[6]="加6鬼",[7]="加7鬼",[8]="加8鬼"}, RoomRuleKey = "bSupportGhostCard"}
t["bSupportWaterBanker"] = {name = "加一色坐庄", shareValue = {[1]="加一色坐庄"}, RoomRuleKey = "nWaterBanker"}
t["nSupportAddColor"] = {name = "加色", shareValue = {[0]="不加色",[1]="加一色",[2]="加二色",[3]="加三色",[4]="加四色"}, RoomRuleKey = "nColorAdd"}
t["nSupportMaxMult"] = {name = "闲家最大倍数", shareValue = {[1]="闲家最大1倍",[2]="闲家最大2倍",[3]="闲家最大3倍",[4]="闲家最大4倍",[5]="闲家最大5倍"}, RoomRuleKey = "nMaxMult"}
t["nChooseCardTime"] = {name = "摆牌时间", shareValue = {[120]="120秒摆牌",[60]="60秒摆牌",[30]="30秒摆牌"}, }
t["nRePortNo"] = {name = "炸弹/同花顺不能报道", shareValue = {[1]="炸弹/同花顺不能报道"}, }
t["nRePortAdd"] = {name = "炸弹/同花顺报道额外+6水", shareValue = {[1]="炸弹/同花顺报道额外+6水"}, }
t["nGunAdd"] = {name = "打枪额外+1水", shareValue = {[1]="打枪额外+1水"}, }
t["nColorType"] = {name = "花色", shareValue = {[1]="方片",[2]="梅花",[3]="红心",[4]="黑桃"}, }
t["takeTurnsMode"] = {name = "定庄方式", shareValue = {[1]="自由抢庄",[2]="明牌抢庄",[3]="固定坐庄", [4]="轮流坐庄", [5]="赢家坐庄",[6]="随机坐庄"}, }
t["baseScore"] = {name = "底分", shareValue = "走PokerShareSpecialDeal.lua特殊处理", }
t["rubCard"] = {name = "搓牌", shareValue = {[1]="搓牌",[0]="不搓牌"}, }
t["multipleRule"] = {name = "翻倍规则", shareValue = "走PokerShareSpecialDeal.lua特殊处理", }
t["wuhuaniu"] = {name = "五花牛", shareValue = {[5]="五花牛x5"}, }
t["zhadanniu"] = {name = "炸弹牛", shareValue = {[10]="炸弹牛x10"}, }
t["wuxiaoniu"] = {name = "五小牛", shareValue = {[12]="五小牛x12"}, }
t["wuhuazhadan"] = {name = "五花炸弹", shareValue = {[15]="五花炸弹x15"}, }
t["playsMode"] = {name = "玩法", shareValue = {[1]="经典玩法",[2]="爆玖(9倍)",[3]="AAA最大"}, shareValueByGid = {[93]={[1]="传统玩法",[2]="激情玩法"}}, }
t["blindTurn"] = {name = "闷牌", shareValue = {[0]="不闷牌",[1]="闷1轮",[2]="闷2轮",[3]="闷3轮"}, }
t["baseScoreNum"] = {name = "底注", shareValue = {[1]="1底分",[2]="2底分",[3]="3底分",[4]="4底分",[5]="5底分",[6]="6底分",[7]="7底分",[8]="8底分",[9]="9底分",[10]="10底分"}, }
t["sp235Single"] = {name = "附加", shareValue = {[1]="235>豹子"}, }
t["n234Min"] = {name = "附加", shareValue = {[1]="234最小"}, }
t["bSuppShiSanBuKao"] = {name = "十三不靠", shareValue = {[1]="十三不靠"}, }
t["bQingYiSeAdd"] = {name = "清一色2倍", shareValue = {[1]="清一色2倍"}, }
t["bSupportSixNineLink"] = {name = "6连9连", shareValue = {[1]="6连9连"}, }
t["bSupportRuleType"] = {name = "玩法", shareValue = {[1]="独听胡",[2]="515场",[3]="报听胡"}, }
t["bAnKaAdd"] = {name = "暗卡加倍", shareValue = {[1]="暗卡加倍"}, }
t["bMQDMAdd"] = {name = "门清断门加倍", shareValue = {[1]="门清断门加倍"}, }
t["bBKDAdd"] = {name = "边卡吊加倍", nameByGid = {[2241057]="掐张偏次",[2213084]="边卡吊",[2213087]="边卡吊"}, shareValue = {[1]="边卡吊加倍"}, shareValueByGid = {[2241057]={[1]="掐张偏次加倍"},[2213084]={[1]="边卡吊"},[2213087]={[1]="边卡吊"}}, RoomRuleKey = "bkd"}
t["bAnGangAdd"] = {name = "暗杠加倍", shareValue = {[1]="暗杠加倍"}, }
t["bSelfAdd"] = {name = "自摸加倍", nameByGid = {[2213084]="自摸翻倍",[2213089]="自摸加番"}, shareValue = {[1]="自摸加倍"}, shareValueByGid = {[2215001]={[1]="自摸加底",[2]="自摸加倍"},[2213084]={[1]="自摸翻倍"},[2213089]={[1]="自摸加番"}}, }
t["bWindGangHu"] = {name = "风杠胡", shareValue = {[1]="风杠胡"}, }
t["bHSevenFourAdd"] = {name = "豪七加倍", shareValue = {[1]="豪七加倍"}, }
t["bSuppGodHu"] = {name = "天胡地胡", shareValue = {[1]="天胡地胡"}, }
t["bSuppDragon"] = {name = "一条龙翻倍", nameByGid = {[2213087] = "一条龙"}, shareValue = {[1]="一条龙翻倍"}, shareValueByGid = {[2213087]={[1]="一条龙"}}, }
t["bShowGive"] = {name = "亮四打一", shareValue = {[1]="亮四打一"}, }
t["bGangLock"] = {name = "暗杠锁死", shareValue = {[1]="暗杠锁死"}, }
t["bGunBaoAll"] = {name = "点炮包胡", nameByGid = {[2213085] = "结算:"}, shareValue = {[0]="点炮1家付",[1]="点炮大包"}, shareValueByGid = {[2213085]={[1]="点炮小包",[2]="点炮大包"}}, }
t["bFollowDealer"] = {name = "跟庄", shareValue = {[1]="跟庄"}, }
t["bXiaoSa"] = {name = "潇洒", shareValue = {[1]="潇洒"}, }
t["bSupportGGWin"] = {name = "天胡地胡", shareValue = {[1]="天胡地胡"}, }
t["bSupportGangDrawGun"] = {name = "杠后炮", nameByGid = {[2215001] = "流泪"}, shareValue = {[1]="杠后炮"}, shareValueByGid = {[2215001]={[1]="流泪"}}, }
t["bSupportGangDrawSelf"] = {name = "杠上花", nameByGid = {[2215001] = "插旗"}, shareValue = {[1]="杠上花"}, shareValueByGid = {[2215001]={[1]="插旗"}}, }
t["bSupportHuMore"] = {name = "胡多张", shareValue = {[1]="胡多张"}, }
t["bSupportNBJ"] = {name = "牛逼叫", shareValue = {[1]="牛逼叫"}, }
t["bSupportBuySelfDraw"] = {name = "买自摸", shareValue = {[1]="买自摸"}, }
t["bSupportLiangXiEr"] = {name = "亮喜", shareValue = {[1]="亮喜"}, }
t["bSupportMengHuAdd"] = {name = "闷胡加倍", shareValue = {[1]="闷胡加倍"}, }
t["bSupportQYS"] = {name = "清一色", shareValue = {[1]="清一色"}, }
t["nSupportFDBaoHu"] = {name = "封顶", shareValue = {[0]="不封顶",[1]="50封顶",[2]="100封顶"}, }
t["nSupportZiMoMaiMa"] = {name = "买马", shareValue = {[0]="不买马",[1]="自摸买马",[2]="亮倒自摸买马"}, }
t["bSupportKaWuXing"] = {name = "卡五星4番", shareValue = {[1]="卡五星4番"}, }
t["bSupportChaJiao"] = {name = "查叫", shareValue = {[1]="查叫"}, }
t["bSupportShangLou"] = {name = "上楼", shareValue = {[1]="上楼"}, }
t["bSupportAllChannel"] = {name = "玩法", shareValue = {[0]="半频道",[1]="全频道"}, }
t["bSupportSelfJi"] = {name = "本鸡", shareValue = {[1]="本鸡"}, }
t["bSupportWuGuJi"] = {name = "乌骨鸡", shareValue = {[1]="乌骨鸡"}, }
t["bSupportWeekJi"] = {name = "星期鸡", shareValue = {[1]="星期鸡"}, }
t["bSupportBlowJi"] = {name = "吹风鸡", shareValue = {[1]="吹风鸡"}, }
t["bSupportMissHu"] = {name = "缺门", shareValue = {[1]="缺门"}, }
t["bSupportTurnJi"] = {name = "鸡牌", shareValue = {[0]="摇摆鸡",[1]="翻牌鸡"}, }
t["nSupportLianZhuang"] = {name = "连庄", shareValue = {[1]="一扣二",[2]="连庄",[3]="通三"}, }
t["nTingMode"] = {name = "模式", shareValue = {[0]="慢听",[1]="快听"}, }
t["bSupportKuaiBao"] = {name = "快宝", shareValue = {[1]="快宝"}, }
t["bSupportKanDuiBao"] = {name = "砍对宝", shareValue = {[1]="砍对宝"}, }
t["bNoTingBaoHu"] = {name = "未上听包胡", shareValue = {[1]="未上听包胡"}, }
t["bKaiMenLimit"] = {name = "四清", shareValue = {[1]="四清"}, }
t["byCheck7pairs"] = {name = "七小对", shareValue = {[1]="七小对"}, }
t["bSupportBianAdd"] = {name = "三七夹", shareValue = {[1]="三七夹"}, }
t["bSupportBaoSanJia"] = {name = "点炮包胡", shareValue = {[1]="点炮包胡"}, }
t["bSupportGunMore"] = {name = "一炮多响", shareValue = {[1]="一炮多响"}, }
t["bSupportZFB"] = {name = "中发白成顺儿", shareValue = {[1] = "中发白成顺儿"}, }
t["bSupportBIAN"] = {name = "边", shareValue = {[1] = "带边"}, }
t["bSupportZUAN"] = {name = "钻", shareValue = {[1] = "带钻"}, }
t["bSupportZA"] = {name = "砸", shareValue = {[1] = "带砸"}, }
t["bSupportWinType"] = {name = "结算", shareValue = {[1]="点炮一家给",[2]="点炮三家出",[3]="点炮包胡"}, }
t["bSupportCollect"] = {name = "可吃牌", shareValue = {[1] = "可吃牌"}, }
t["bSupportMT"] = {name = "明提", shareValue = {[1] = "明提"}, }
t["bSupportWindGang"] = {name = "旋风杠", shareValue = {[1] = "旋风杠"}, }
t["bSupportFaGang"] = {name = "乱杠", shareValue = {[1] = "乱杠"}, }
t["nPaoNum"] = {name = "下跑", shareValue = {[1] = "不跑",[2] = "跑2",[3] = "跑3",[4] = "跑5"}, }
t["dealeradd"] = {name = "庄家加番", nameByGid = {[2213085] = "庄家加倍",[2213087] = "庄翻倍"}, shareValue = {[1] = "庄家加番"}, shareValueByGid = {[2213085] = {[1]="庄家加倍"},[2213087] = {[1]="庄翻倍"}}, }
t["bSupportZhuoWuKui"] = {name = "捉五魁", shareValue = {[1] = "捉五魁"}, }
t["bMingGangAll"] = {name = "明杠三家出", shareValue = {[1] = "明杠三家出"}, }
t["bSupportDaBaJiang"] = {name = "打八张", shareValue = {[1] = "打八张"}, }
t["bSupportTingAdd"] = {name = "报听加倍", shareValue = {[1] = "报听加倍"}, }
t["bSupportQiangGangAdd"] = {name = "抢杠加倍", shareValue = {[1] = "抢杠加倍"}, }
t["bSupportYKX"] = {name = "一口香", shareValue = {[1] = "一口香"}, }
t["bSupportPPHu"] = {name = "碰碰胡", shareValue = {[1] = "碰碰胡"}, }
t["bBaoGang"] = {name = "点杠包杠", shareValue = {[1] = "点杠包杠"}, }
t["bSupportDragon"] = {name = "一条龙", shareValue = {[1] = "一条龙"}, }
t["bGunMultiWin"] = {name = "一炮多响", shareValue = {[1] = "一炮多响"}, }
t["bNoTingBaoHuBaoGang"] = {name = "不报听包胡包杠", shareValue = {[1] = "不报听包胡包杠"}, }
t["bDoubleHun"] = {name = "混牌", shareValue = {[0] = "无混儿",[1] = "四个混儿",[2] = "七个混儿"}, }
t["bYangWindGang"] = {name = "养风", shareValue = {[1] = "养风"}, }

return t