
messagedefine = {}
local this = messagedefine;

this.CG_LOGIN					= 1
this.GC_LOGIN					= 2

-- server define ----------------------------
this.EField_Sn = "_check"    --//这个有时间得改成EField_check
this.EField_Ver = "_ver"
this.EField_SessionNumber = "_sn"

this.EField_UID = "_uid"
this.EField_EID = "_cmd"    --//"eID"
this.EField_EType = "_st"    --//"eType"
this.EField_EPara = "_para"  --//"ePara"
this.EField_EPath = "_src"  --//"ePatah"


this.EField_JRet = "_errno"
this.EField_EStr = "_errstr"

this.EField_AppID = "_gid"  --//"app_id" //游戏appid
this.EField_Rule = "_gsc" --//"game_cfg"  //游戏玩法
this.EField_Level = "_glv"  --//"level" //游戏玩法等级


this.EField_TableID = "_gt"    --//"table_id" //请求的桌子ID, 
this.EField_SeatID = "_chair"    --//  "seat"  //请求的座位号

this.EField_SitMode = "_from"      --// "sitmode"  //坐下模式,来源: 快速选场坐下"quick"or放开"bykey"

this.EField_TableConfig = "_gt_cfg"  --//"table_cfg"
this.EFiled_TableKey = "_gt_key"  --//"table_key"
this.EField_TableTag = "_gt_tag"        --//"table_tag"  

this.EField_ClientType = "_client"  --//"client_type" //客户端类型


this.EField_Ts = "_ts"

this.EField_ServerName = "_svr_t"  --//"server_name"
this.EField_ServerID = "_svr_id"  --//"server_id"
this.EField_PlayerList = "_plist"  --//"plist"

this.EField_Event = "_events"
this.EField_Session = "_dst"


this.onlinePath = "/online/1"
this.chessPath = "/chess/1"

