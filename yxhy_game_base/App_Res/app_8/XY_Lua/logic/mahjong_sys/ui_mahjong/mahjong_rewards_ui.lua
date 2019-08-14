

mahjong_rewards_ui = ui_base.New()

local this = mahjong_rewards_ui
local widgetTbl = {}
local data = nil

function this.Show(tbl ,win_viewSeat,isBigReward,t_rid)
	data = {
		tbl = tbl,
		win_viewSeat = win_viewSeat,
		isBigReward = isBigReward,
		t_rid = t_rid,
	}
	if IsNil(this.gameObject) then
		this.gameObject = newNormalUI("Prefabs/UI/Mahjong/mahjong_rewards_ui")
    this.gameObject.transform:SetParent(mahjong_ui.transform, false)
	else
		this.gameObject:SetActive(true)
    this.SetRewards(tbl ,win_viewSeat,isBigReward,t_rid)
	end
end

function this.Hide()
	if not IsNil(this.gameObject) then
 		this.gameObject:SetActive(false)
 	end
 	data = nil
end

function this.Awake()
 	this.RegisterEvents()
end

function this.Start()
	if data ~=nil then
		this.SetRewards(data.tbl ,data.win_viewSeat,data.isBigReward,data.t_rid)
	end
end

function this.OnDestroy()

end

function this.RegisterEvents()
	this.FindChild_Rewards()
end

function this.FindChild_Rewards()
	widgetTbl.rewards_panel = this.gameObject.transform
	widgetTbl.rewards_back = child(widgetTbl.rewards_panel,"back")
	if widgetTbl.rewards_back~=nil then
       addClickCallbackSelf(widgetTbl.rewards_back.gameObject, Onbtn_rewardsBackClick, this)
    end
	--开始下一局
	widgetTbl.rewards_ready = child(widgetTbl.rewards_panel,"ready")
	if widgetTbl.rewards_ready~=nil then
       addClickCallbackSelf(widgetTbl.rewards_ready.gameObject, Onbtn_readyClick, this)
    end
    widgetTbl.rewards_splayers = {}
    for i=1,4 do
    	local p = {}
    	p.rewards_player = child(widgetTbl.rewards_panel,"small/player"..i)
    	p.rewards_player_name = child(p.rewards_player,"name")
    	p.rewards_player_point = child(p.rewards_player,"point")
    	p.rewards_player_head = child(p.rewards_player,"head_bg/head_bg2/head")
    	p.rewards_player_vip = child(p.rewards_player_head,"vip")
    	p.rewards_player_vip.gameObject:SetActive(false)
    	p.rewards_player_zhuang = child(p.rewards_player_head,"zhuang")
    	p.rewards_player_zhuang.gameObject:SetActive(false)
      if roomdata_center.MaxPlayer() == 2 and (i == 2 or i == 4 ) then
        
      else
        table.insert(widgetTbl.rewards_splayers,p)
      end
    	p.rewards_player.gameObject:SetActive(false)
    end

    widgetTbl.rewards_bplayers = {}
    for i=1,4 do
    	local p = {}
    	p.rewards_player = child(widgetTbl.rewards_panel,"big/player"..i)
    	p.rewards_player_name = child(p.rewards_player,"name")
    	p.rewards_player_point = child(p.rewards_player,"point")
    	p.rewards_player_head = child(p.rewards_player,"head_bg/head_bg2/head")
    	p.rewards_player_vip = child(p.rewards_player_head,"vip")
    	p.rewards_player_vip.gameObject:SetActive(false)
    	p.rewards_player_zhuang = child(p.rewards_player_head,"zhuang")
    	p.rewards_player_zhuang.gameObject:SetActive(false)
    	p.rewards_player_itemEx = child(p.rewards_player,"itemEx")
    	p.rewards_player_itemEx.gameObject:SetActive(false)
    	p.rewards_player_scrollView = child(p.rewards_player,"Scroll View")
    	p.rewards_player_grid = child(p.rewards_player_scrollView,"Grid")
      if roomdata_center.MaxPlayer() == 2 and (i == 2 or i == 4 ) then
        
      else
        table.insert(widgetTbl.rewards_bplayers,p)
      end
    	p.rewards_player.gameObject:SetActive(false)
    end

    -- 新结算界面
    widgetTbl.newRewards_big = child(widgetTbl.rewards_panel,"player1")
    widgetTbl.newRewards_small = {}
    for i=2,4 do
      local newRewards_small = child(widgetTbl.rewards_panel,"player"..i)
      table.insert(widgetTbl.newRewards_small,newRewards_small)
    end
    widgetTbl.newRewards_item = child(widgetTbl.rewards_panel,"item")
    widgetTbl.newRewards_grid = child(widgetTbl.rewards_panel,"Container/Grid")

end

-- 准备按钮
local function Onbtn_readyClick()	
	ui_sound_mgr.PlaySoundClip("app_8/sound/common/audio_ready")
	mahjong_play_sys.ReadyGameReq()
end

--返回按钮
local function Onbtn_rewardsBackClick()
	this.Hide()
	mahjong_ui.ShowReadyBtns()
end

--[[--
 * @Description: 
 * tbl = {
 * [1] = {"name" = "123","point" = 500}
 * [2] = {"name" = "123","point" = 500}
 * }  
 ]]
function this.SetRewards(tbl ,win_viewSeat,isBigReward,t_rid)
  if isBigReward then
    bigSettlement_ui.Init(t_rid)
    addClickCallbackSelf(widgetTbl.rewards_ready.gameObject, function ()
      this.Hide()
      local rid = t_rid
      Notifier.dispatchCmd(cmdName.GAME_SOCKET_LUMP_SUM, {rid})
    end, this) 
    addClickCallbackSelf(widgetTbl.rewards_back.gameObject, function ()
      this.Hide()
      local rid = t_rid
      Notifier.dispatchCmd(cmdName.GAME_SOCKET_LUMP_SUM, {rid})
    end, this)
  else
    addClickCallbackSelf(widgetTbl.rewards_ready.gameObject, Onbtn_readyClick, this)
    addClickCallbackSelf(widgetTbl.rewards_back.gameObject, Onbtn_rewardsBackClick, this)
  end
  Trace("SetRewards----------")
	widgetTbl.rewards_panel.gameObject:SetActive(true)


	 for i=1,roomdata_center.MaxPlayer() do
	 	local p = widgetTbl.rewards_splayers[i]
	 	--昵称
	 	if p.rewards_player_name_comp == nil then
	 		p.rewards_player_name_comp = p.rewards_player_name:GetComponent(typeof(UILabel))
	 	end
	 	p.rewards_player_name_comp.text = tbl[i].name
	 	--金币
	 	if p.rewards_player_point_comp == nil then
	 		p.rewards_player_point_comp = p.rewards_player_point:GetComponent(typeof(UILabel))
	 	end 

	 	p.rewards_player_point_comp.text = tbl[i].point
	 	--庄
	 	if tbl[i].isBanker then
	 		p.rewards_player_zhuang.gameObject:SetActive(true)
    else
      p.rewards_player_zhuang.gameObject:SetActive(false)
	 	end
	 	--头像
	 	if p.rewards_player_headTexture==nil then
			p.rewards_player_headTexture = p.rewards_player_head.gameObject:GetComponent(typeof(UITexture))
		end
		--mahjong_ui_sys.GetHeadPic(p.rewards_player_headTexture,tbl[i].url)
    	hall_data.getuserimage(p.rewards_player_headTexture,2,tbl[i].url)
		--大信息框
	 	if i==win_viewSeat then
	 		local bp = widgetTbl.rewards_bplayers[i]
	 		--昵称
		 	if bp.rewards_player_name_comp == nil then
		 		bp.rewards_player_name_comp = bp.rewards_player_name:GetComponent(typeof(UILabel))
		 	end
		 	bp.rewards_player_name_comp.text = tbl[i].name
		 	--金币
		 	if bp.rewards_player_point_comp == nil then
		 		bp.rewards_player_point_comp = bp.rewards_player_point:GetComponent(typeof(UILabel))
		 	end 
		 	bp.rewards_player_point_comp.text = tbl[i].point
		 	--庄
		 	if tbl[i].isBanker then
		 		bp.rewards_player_zhuang.gameObject:SetActive(true)
      else
        bp.rewards_player_zhuang.gameObject:SetActive(false)
		 	end
		 	--头像
		 	if bp.rewards_player_headTexture==nil then
				bp.rewards_player_headTexture = bp.rewards_player_head.gameObject:GetComponent(typeof(UITexture))
			end
			bp.rewards_player_headTexture.gameObject:SetActive(true)
			--mahjong_ui_sys.GetHeadPic(bp.rewards_player_headTexture,tbl[i].url)
      		hall_data.getuserimage(bp.rewards_player_headTexture,2,tbl[i].url)
			--积分内容
			--p.rewards_player_itemEx = child(p.rewards_player,"itemEx")
    		--p.rewards_player_scrollView = child(p.rewards_player,"Scroll View")

    		destroyAllChild(bp.rewards_player_grid)

			for i,v in ipairs(tbl[i].scoreItem) do
				local item = newobject(bp.rewards_player_itemEx.gameObject)
				item.transform.parent = bp.rewards_player_grid
				item.transform.localScale = Vector3.one
				local des = child(item.transform,"des")
				des.gameObject:GetComponent(typeof(UILabel)).text = v.des
				local num = child(item.transform,"num")
				num.gameObject:GetComponent(typeof(UILabel)).text = v.num
				local p_des = child(item.transform,"p")
				p_des.gameObject:GetComponent(typeof(UILabel)).text = v.p
				item.gameObject:SetActive(true)
			end
			bp.rewards_player_grid:GetComponent(typeof(UIGrid)).enabled = true
		 	
		 	p.rewards_player.gameObject:SetActive(false)
		 	bp.rewards_player.gameObject:SetActive(true)
		 else
		 	local bp = widgetTbl.rewards_bplayers[i]
		 	p.rewards_player.gameObject:SetActive(true)
		 	bp.rewards_player.gameObject:SetActive(false)
		end

	 end

   -----------------新结算显示--------------------

    if win_viewSeat==0 then
      win_viewSeat = 1
      destroyAllChildImmediate(widgetTbl.newRewards_grid)
    else
      --组装麻将列表
      local combineTile = tbl[win_viewSeat].combineTile
      local cards = tbl[win_viewSeat].cards      
      local list = {}
      for i,v in ipairs(combineTile) do
        if v.ucFlag == 16 then
          table.insert(list,v.card)
          table.insert(list,v.card+1)
          table.insert(list,v.card+2)
        elseif v.ucFlag == 17 then
          table.insert(list,v.card)
          table.insert(list,v.card)
          table.insert(list,v.card)
        elseif v.ucFlag == 18 then
          table.insert(list,v.card)
          table.insert(list,v.card)
          table.insert(list,v.card)
          table.insert(list,v.card)
        elseif v.ucFlag == 20 then
          table.insert(list,v.card)
          table.insert(list,v.card)
          table.insert(list,v.card)
          table.insert(list,v.card)
        elseif v.ucFlag == 19 then
          table.insert(list,v.card)
          table.insert(list,0)
          table.insert(list,v.card)
          table.insert(list,v.card)
        end
      end

      for i,v in ipairs(cards) do
        table.insert(list,v)
      end
      --显示列表
      --TODO 待优化
      destroyAllChildImmediate(widgetTbl.newRewards_grid)
      local lastItem
      for i,v in ipairs(list) do
        local item = newobject(widgetTbl.newRewards_item.gameObject)
        item.transform.parent = widgetTbl.newRewards_grid
        item.transform.localScale = Vector3.one
        local bg_comp = componentGet(item.transform , "UISprite")
        local lightTrans = child(item.transform,"light")
        local cardTrans = child(item.transform,"card")
        local jinTrans = child(item.transform,"card/icon")
        if v == 0 then
          componentGet(item.transform , "UISprite").spriteName = "xjs_di_006"
          lightTrans.gameObject:SetActive(false)
          cardTrans.gameObject:SetActive(false)
        else
          componentGet(item.transform , "UISprite").spriteName = "xjs_di_004"
          if i~=#list then
            lightTrans.gameObject:SetActive(false)
          else
            lightTrans.gameObject:SetActive(true)
            lastItem = item.transform
          end
          componentGet(cardTrans.transform , "UISprite").spriteName = v.."_hand"
          if roomdata_center.CheckIsSpecialCard(v) then
            jinTrans.gameObject:SetActive(true)
          else
            jinTrans.gameObject:SetActive(false)
          end
        end
        item.gameObject:SetActive(true)
      end
      widgetTbl.newRewards_grid:GetComponent(typeof(UIGrid)):Reposition()  
      local scale = 22/#list
      widgetTbl.newRewards_grid.localScale = Vector3(scale,scale,0)
      lastItem.localPosition = Vector3(lastItem.localPosition.x+25,0,0)
    end

    local win_tbl = tbl[win_viewSeat]
    --昵称
    local big_name = child(widgetTbl.newRewards_big,"name")
    local big_name_comp = componentGet(big_name , "UILabel")
    big_name_comp.text = win_tbl.name
    --分数
    local big_point = child(widgetTbl.newRewards_big,"point")
    local big_point_comp = componentGet(big_point , "UILabel")
    big_point_comp.text = win_tbl.point
    --头像
    local big_head = child(widgetTbl.newRewards_big,"head_bg/head_bg2/head")
    local big_head_comp = componentGet(big_head , "UITexture")
    hall_data.getuserimage(big_head_comp,2,win_tbl.url)
    --庄
    local big_banker = child(big_head,"zhuang")
    if win_tbl.isBanker then
      big_banker.gameObject:SetActive(true)
    else
      big_banker.gameObject:SetActive(false)
    end
    --积分项item
    local big_item = child(widgetTbl.newRewards_big,"itemEx")
    --积分项grid
    local big_grid = child(widgetTbl.newRewards_big,"Scroll View/Grid")
    destroyAllChildImmediate(big_grid)

    for i,v in ipairs(win_tbl.scoreItem) do
      local item = newobject(big_item.gameObject)
      item.transform.parent = big_grid
      item.transform.localScale = Vector3.one
      local des = child(item.transform,"des")
      des.gameObject:GetComponent(typeof(UILabel)).text = v.des
      local num = child(item.transform,"num")
      num.gameObject:GetComponent(typeof(UILabel)).text = v.num
      local p_des = child(item.transform,"p")
      p_des.gameObject:GetComponent(typeof(UILabel)).text = v.p
      item.gameObject:SetActive(true)
    end
    big_grid:GetComponent(typeof(UIGrid)):Reposition()


    for i,v in ipairs(widgetTbl.newRewards_small) do
      v.gameObject:SetActive(false)
    end

    local index = 0
    for i=win_viewSeat+1,win_viewSeat+#tbl do
      local viewSeat = i
      if i>roomdata_center.MaxPlayer() then
        viewSeat = viewSeat - roomdata_center.MaxPlayer()
      end
      if viewSeat == win_viewSeat then
        break
      end
      index = index + 1
      local p_tbl = tbl[viewSeat]
      local p = widgetTbl.newRewards_small[index]
      --昵称
      local p_name = child(p,"name")
      local p_name_comp = componentGet(p_name , "UILabel")
      p_name_comp.text = p_tbl.name
      --分数
      local p_point = child(p,"point")
      local p_point_comp = componentGet(p_point , "UILabel")
      p_point_comp.text = p_tbl.point
      --头像
      local p_head = child(p,"head_bg/head_bg2/head")
      local p_head_comp = componentGet(p_head , "UITexture")
      hall_data.getuserimage(p_head_comp,2,p_tbl.url)
      --庄
      local p_banker = child(p_head,"zhuang")
      if p_tbl.isBanker then
        p_banker.gameObject:SetActive(true)
      else
        p_banker.gameObject:SetActive(false)
      end
      p.gameObject:SetActive(true)
    end

    if index == 1 then
      widgetTbl.newRewards_small[1].localPosition = Vector3(0,207,0)
    elseif index ==2 then
      widgetTbl.newRewards_small[1].localPosition = Vector3(-198,207,0)
      widgetTbl.newRewards_small[2].localPosition = Vector3(198,207,0)
    else
      widgetTbl.newRewards_small[1].localPosition = Vector3(-396,207,0)
      widgetTbl.newRewards_small[2].localPosition = Vector3(0,207,0)
      widgetTbl.newRewards_small[3].localPosition = Vector3(396,207,0)
    end

end