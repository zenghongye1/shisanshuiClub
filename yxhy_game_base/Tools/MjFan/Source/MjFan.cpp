#include "MjFan.h"
#include "json/json.h"

static char global_str[1024 * 100] = { '\0' };

EXPORT_DLL void initLib(BYTE byStyle /*= 0*/, BOOL bZiMoJiaDi /*= FALSE*/, BOOL bJiaJiaYou /*= FALSE*/) {
	if (fz != NULL) {
		delete fz;
		fz = NULL;
	}

	fz = new CMJFun();
	if (fz != NULL)
	{
		fz->InitFanMJCounter(byStyle, bZiMoJiaDi > 0, bJiaJiaYou > 0);
	}
}

EXPORT_DLL int checkHuPaiCount() {
	if (fz == NULL) {
		initLib();
	}
	return fz->HuPaiCount();
}

EXPORT_DLL int setEnvironment(char* env)
{
	if (env == NULL || strlen(env) < 1)
	{
		return 1;
	}
	if (fz == NULL)
	{
		initLib();
	}

	Json::Reader jsonReader;
	Json::Value root;
	if (!jsonReader.parse(env, root, false))
	{
		return 2;
	}

	tagENVIRONMENT* arg = fz->MutableEnv();
	arg->init();

	unsigned int byChair = root["byChair"].asUInt(); // 检查谁的
	byChair--;
	arg->byChair = byChair;

	unsigned int byTurn = root["byTurn"].asUInt();  // 轮到谁，如果是点炮，则是点炮的那个人
	byTurn--;
	arg->byTurn = byTurn;

	// 四家手上的牌
	int count1 = 0, count2 = 0, count3 = 0;
	Json::Value& tHandJson = root["tHand"];
	count1 = sizeof(arg->tHand) / sizeof(arg->tHand[0]);
	count2 = sizeof(arg->tHand[0]) / sizeof(arg->tHand[0][0]);
	for (int i = 0; i < count1 && i < tHandJson.size(); i++)
	{
		for (int j = 0; j < count2 && j < tHandJson[i].size(); j++)
		{
			arg->tHand[i][j] = tHandJson[i][j].asUInt();
		}
	}

	//手上有几张牌
	Json::Value& byHandCountJson = root["byHandCount"];
	count1 = sizeof(arg->byHandCount) / sizeof(arg->byHandCount[0]);
	for (int i = 0; i < count1 && i < byHandCountJson.size(); i++)
	{
		arg->byHandCount[i] = byHandCountJson[i].asUInt();
	}

	// 四家，4手牌，flag、tile、chair
	Json::Value& tSetJson = root["tSet"];
	count1 = sizeof(arg->tSet) / sizeof(arg->tSet[0]);
	count2 = sizeof(arg->tSet[0]) / sizeof(arg->tSet[0][0]);
	count3 = sizeof(arg->tSet[0][0]) / sizeof(arg->tSet[0][0][0]);
	for (int i = 0; i < count1 && i < tSetJson.size(); i++)
	{
		for (int j = 0; j < count2 && j < tSetJson[i].size(); j++)
		{
			for (int k = 0; k < count3 && k < tSetJson[i][j].size(); k++)
			{
				arg->tSet[i][j][k] = tSetJson[i][j][k].asUInt();
			}
		}
	}

	// set有几手牌
	Json::Value& bySetCountJson = root["bySetCount"];
	count1 = sizeof(arg->bySetCount) / sizeof(arg->bySetCount[0]);
	for (int i = 0; i < count1 && i < bySetCountJson.size(); i++)
	{
		arg->bySetCount[i] = bySetCountJson[i].asUInt();
	}

	// 四家出过的牌
	Json::Value& tGiveJson = root["tGive"];
	count1 = sizeof(arg->tGive) / sizeof(arg->tGive[0]);
	count2 = sizeof(arg->tGive[0]) / sizeof(arg->tGive[0][0]);
	for (int i = 0; i < count1 && i < tGiveJson.size(); i++)
	{
		for (int j = 0; j < count2 && j < tGiveJson[i].size(); j++)
		{
			arg->tGive[i][j] = tGiveJson[i][j].asUInt();
		}
	}

	// 每人出了几张牌
	Json::Value& byGiveCountJson = root["byGiveCount"];
	count1 = sizeof(arg->byGiveCount) / sizeof(arg->byGiveCount[0]);
	for (int i = 0; i < count1 && i < byGiveCountJson.size(); i++)
	{
		arg->byGiveCount[i] = byGiveCountJson[i].asUInt();
	}

	arg->tLast = root["tLast"].asUInt(); // 最后和的那张牌
	arg->byFlag = root["byFlag"].asUInt(); // 0自摸、1点炮、2杠上花、3抢杠

	arg->byRoundWind = root["byRoundWind"].asUInt(); // 圈风
	arg->byPlayerWind = root["byPlayerWind"].asUInt(); // 门风
	arg->byTilesLeft = root["byTilesLeft"].asUInt(); // 还剩多少张牌，用来计算海底等

	// 4家各有多少张花
	Json::Value& byFlowerCountJson = root["byFlowerCount"];
	count1 = sizeof(arg->byFlowerCount) / sizeof(arg->byFlowerCount[0]);
	for (int i = 0; i < count1 && i < byFlowerCountJson.size(); i++)
	{
		arg->byFlowerCount[i] = byFlowerCountJson[i].asUInt();
	}

	// 听牌的玩家
	Json::Value& byTingJson = root["byTing"];
	count1 = sizeof(arg->byTing) / sizeof(arg->byTing[0]);
	for (int i = 0; i < count1 && i < byTingJson.size(); i++)
	{
		arg->byTing[i] = byTingJson[i].asUInt();
	}

	// 4家是否出过牌(这个主要用来判断地胡)
	Json::Value& byDoFirstGiveJson = root["byDoFirstGive"];
	count1 = sizeof(arg->byDoFirstGive) / sizeof(arg->byDoFirstGive[0]);
	for (int i = 0; i < count1 && i < byDoFirstGiveJson.size(); i++)
	{
		arg->byDoFirstGive[i] = byDoFirstGiveJson[i].asUInt();
	}

	Json::Value& byRecvJson = root["byRecv"];
	count1 = sizeof(arg->byRecv) / sizeof(arg->byRecv[0]);
	for (int i = 0; i < count1 && i < byRecvJson.size(); i++)
	{
		arg->byRecv[i] = byRecvJson[i].asUInt();
	}

	// 癞子牌数组，暂定最大是4个
	Json::Value& byLaiziCardsJson = root["byLaiziCards"];
	count1 = sizeof(arg->byLaiziCards) / sizeof(arg->byLaiziCards[0]);
	for (int i = 0; i < count1 && i < byLaiziCardsJson.size(); i++)
	{
		arg->byLaiziCards[i] = byLaiziCardsJson[i].asUInt();
	}

	// 剩余各个牌的数目
	Json::Value& nNSNumJson = root["nNSNum"];
	count1 = sizeof(arg->nNSNum) / sizeof(arg->nNSNum[0]);
	for (int i = 0; i < count1 && i < nNSNumJson.size(); i++)
	{
		arg->nNSNum[i] = nNSNumJson[i].asUInt();
	}

	arg->byMaxHandCardLength = root["byMaxHandCardLength"].asUInt(); //手牌最大的数量

	//需要计算的番型
	Json::Value& byDoCheckJson = root["byDoCheck"];
	count1 = sizeof(arg->byDoCheck) / sizeof(arg->byDoCheck[0]);
	for (int i = 0; i < count1 && i < byDoCheckJson.size(); i++)
	{
		arg->byDoCheck[i] = byDoCheckJson[i].asInt();
	}

	//番型数据:{"byFanNumber"=1,"byFanType"=2,"byNoCheck"={1,2,3...}}
	Json::Value& byEnvFanJson = root["byEnvFan"];
	count1 = sizeof(arg->byEnvFan) / sizeof(arg->byEnvFan[0]);
	count2 = sizeof(arg->byEnvFan[0].byNoCheck) / sizeof(arg->byEnvFan[0].byNoCheck[0]);
	for (int i = 0; i < count1 && i < byEnvFanJson.size(); i++)
	{
		Json::Value& fanJson = byEnvFanJson[i];
		arg->byEnvFan[i].byFanType = fanJson["byFanType"].asUInt();
		arg->byEnvFan[i].byFanNumber = fanJson["byFanNumber"].asUInt();
		arg->byEnvFan[i].byCount = fanJson["byCount"].asUInt();

		Json::Value& byNoCheckJson = fanJson["byNoCheck"];
		for (int j = 0; j < count2 && j < byNoCheckJson.size(); j++)
		{
			arg->byEnvFan[i].byNoCheck[j] = byNoCheckJson[j].asInt();
		}
	}

	//checkWin 一些附带参数
	Json::Value& checkWinParamJson = root["checkWinParam"];
	arg->checkWinParam.byCheck7pairs = checkWinParamJson["byCheck7pairs"].asUInt();
	arg->checkWinParam.byCheck8Pairs = checkWinParamJson["byCheck8Pairs"].asUInt();
	arg->checkWinParam.byCheckShiSanYao = checkWinParamJson["byCheckShiSanYao"].asUInt();
	arg->checkWinParam.byLaiziWinNums = checkWinParamJson["byLaiziWinNums"].asUInt();
	arg->checkWinParam.byShiSanBuKao = checkWinParamJson["byShiSanBuKao"].asUInt();
	arg->checkWinParam.byQiXingBuKao = checkWinParamJson["byQiXingBuKao"].asUInt();

	arg->checkWinParam.by258Jiang = checkWinParamJson["by258Jiang"].asUInt();
	arg->checkWinParam.byWindPu = checkWinParamJson["byWindPu"].asUInt();
	arg->checkWinParam.byJiangPu = checkWinParamJson["byJiangPu"].asUInt();
	arg->checkWinParam.byYaoJiuPu = checkWinParamJson["byYaoJiuPu"].asUInt();

	arg->checkWinParam.byShunZFB = checkWinParamJson["byShunZFB"].asUInt();
	arg->checkWinParam.byShunWind = checkWinParamJson["byShunWind"].asUInt();

	arg->checkWinParam.byBKDHu = checkWinParamJson["byBKDHu"].asUInt();

	arg->checkWinParam.byBaiChangeGoldUse = checkWinParamJson["byBaiChangeGoldUse"].asUInt();
	arg->checkWinParam.byMaxHandCardLength = checkWinParamJson["byMaxHandCardLength"].asUInt();
	arg->checkWinParam.nGameStyle = checkWinParamJson["nGameStyle"].asUInt();

	arg->checkWinParam.nEightFlowerHu = checkWinParamJson["nEightFlowerHu"].asUInt();
	arg->checkWinParam.byKaiMenLimit = checkWinParamJson["byKaiMenLimit"].asUInt();
	arg->checkWinParam.byColorLimit = checkWinParamJson["byColorLimit"].asUInt();
	arg->checkWinParam.byQYSHu = checkWinParamJson["byQYSHu"].asUInt();
	arg->checkWinParam.byYaoJiuLimit = checkWinParamJson["byYaoJiuLimit"].asUInt();
	arg->checkWinParam.byDanDiaoLimit = checkWinParamJson["byDanDiaoLimit"].asUInt();

	//剩余各个牌的数目
	Json::Value& checkWinParamnNSNumJson = checkWinParamJson["nNSNum"];
	count1 = sizeof(arg->checkWinParam.nNSNum) / sizeof(arg->checkWinParam.nNSNum[0]);
	for (int i = 0; i < count1 && i < checkWinParamnNSNumJson.size(); i++)
	{
		arg->checkWinParam.nNSNum[i] = checkWinParamnNSNumJson[i].asUInt();
	}

	arg->checkWinParam.byOneGoldLimit = checkWinParamJson["byOneGoldLimit"].asUInt();
	arg->checkWinParam.byTwoGoldLimit = checkWinParamJson["byTwoGoldLimit"].asUInt();

	arg->byQYSNoWord = root["byQYSNoWord"].asUInt(); //清一色是否包含字一色
	arg->nMissHu = root["nMissHu"].asUInt(); // 缺一门标志
	arg->nMissWind = root["nMissWind"].asUInt(); // 缺一门可以有风牌

	unsigned int byDealer = root["byDealer"].asUInt(); // 庄家
	byDealer--;
	arg->byDealer = byDealer;

	arg->gamestyle = root["gamestyle"].asUInt(); // 游戏类型

	arg->laizi = root["laizi"].asUInt(); // 癞子数量，或金数量
	arg->flower = root["flower"].asUInt(); // 花数量
	arg->byGangTimes = root["byGangTimes"].asUInt(); // 杠上花时，杠的次数
	arg->byHaiDi = root["byHaiDi"].asUInt(); // 是否是海底(荒局前最后一张，用来判断海底捞月和海底炮)

	arg->byGodTingFlag = root["byGodTingFlag"].asUInt(); // 天听标志
	arg->byGroundTingFlag = root["byGroundTingFlag"].asUInt(); // 地听标志
	arg->byXiaoSaTingFlag = root["byXiaoSaTingFlag"].asUInt(); //潇洒标志
	//arg->bDanDiaoHu = root["bDanDiaoHu"].asUInt(); // 单吊胡
	arg->byHunYouFlag = root["byHunYouFlag"].asUInt(); // 混悠标志

	arg->KeLimit = root["KeLimit"].asUInt(); //刻子limit
	arg->byHaveWinds = root["byHaveWinds"].asUInt(); //是否带风牌(东南西北中发白) 都带为1，只带东南西北为2
	//arg->bkaAdd = root["bkaAdd"].asUInt(); // 卡张胡
	//arg->n258Jiang = root["n258Jiang"].asUInt(); // 258标志

	return 0;
}

EXPORT_DLL char* getHuPaiCount()
{
	if (fz == NULL) {
		initLib();
	}

	Json::Value root;
	int nodeIndex = 0;

	CMJFanCounter::HUPAI_COUNT& fzHuPaiCount = fz->GetHuPaiCount();
	int nodeCount = sizeof(fzHuPaiCount.m_HuPaiNode) / sizeof(fzHuPaiCount.m_HuPaiNode[0]);
	int infoCount = sizeof(fzHuPaiCount.m_HuPaiNode[0].szHuPaiInfo) / sizeof(fzHuPaiCount.m_HuPaiNode[0].szHuPaiInfo[0]);
	for (int i = 0; i < nodeCount; i++)
	{
		CMJFanCounter::HUPAI_NODE& huPaiNode = fzHuPaiCount.m_HuPaiNode[i];
		if (huPaiNode.bCanHuPai == 1)
		{
			Json::Value nodeJson;
			nodeJson["give"] = huPaiNode.szGiveCard; //出的牌
			nodeJson["flag"] = huPaiNode.flag; //胡任意牌的标志,1代表胡任意牌
			//nodeJson["bIsYouJin"] = false;

			int infoIndex = 0;
			Json::Value infoJson;
			for (int j = 0; j < infoCount; j++)
			{
				if (huPaiNode.szHuPaiInfo[j].szHuCard > 0)
				{
					Json::Value itemJson;
					itemJson["nFan"] = 0; //番数
					itemJson["nCard"] = huPaiNode.szHuPaiInfo[j].szHuCard; //听的牌
					itemJson["nLeft"] = huPaiNode.szHuPaiInfo[j].szHuCardleft; //听的牌剩余几张					
					//infoJson["bHu"] = huPaiNode.szHuPaiInfo[j].bHu; // 每种胡是否满足

					infoJson[infoIndex] = itemJson;
					infoIndex++;
				}
			}
			nodeJson["win"] = infoJson;

			root[nodeIndex] = nodeJson;
			nodeIndex++;
		}
	}

	Json::FastWriter writer;
	std::string json_file = writer.write(root);
	memset(global_str, '\0', sizeof(global_str) / sizeof(global_str[0]));
	strcpy(global_str, json_file.c_str());
	return global_str;
}

EXPORT_DLL int getVersion() {
	return SO_VERSION;
}