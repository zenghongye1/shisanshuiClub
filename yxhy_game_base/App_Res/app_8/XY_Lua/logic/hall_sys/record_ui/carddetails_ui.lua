--region *.lua
--Date
--此文件由[BabeLua]插件自动生成



--endregion
carddetails_ui=ui_base.New()
local this=carddetails_ui
local datatable={} 
function this.Show(data,m)
    recorddetails_ui.gameObject:SetActive(false)
	if this.gameObject==nil then
		require ("logic/hall_sys/record_ui/carddetails_ui")
		this.gameObject = newNormalUI("app_8/ui/openrecord_ui/carddetails_ui")
	else
		this.gameObject:SetActive(true) 
	end
    this.addlistener()
    if data~=nil then
       datatable=data   
       this.InitInfo(m)
    else
        datatable=nil
    end 
end
function this.Awake()
    componentGet(this.transform,"UIPanel").depth=componentGet(recorddetails_ui.gameObject,"UIPanel").depth+1
    componentGet(child( this.transform,"cardetails_panel/Panel_Middle/sv_all"),"UIPanel").depth=componentGet(this.transform,"UIPanel").depth+1
end
function this.Start() 
    this:RegistUSRelation()
end

function this.OnDestroy()
    this:UnRegistUSRelation()
end
function this.Hide()
    ui_sound_mgr.PlaySoundClip("app_8/sound/common/audio_button_click")
    if this.gameObject==nil then
		return
	else
		GameObject.Destroy(this.gameObject)
        this.gameObject=nil
	end
    recorddetails_ui.gameObject:SetActive(true)
end

function this.addlistener()
    local btn_close=child(this.transform,"cardetails_panel/btn_close")
    if btn_close~=nil then
        addClickCallbackSelf(btn_close.gameObject,this.Hide,this)
    end

    this.grid_rank=child(this.transform,"cardetails_panel/Panel_Middle/sv_all/grid_rank") 
end

function this.InitInfo(index) 
   if datatable==nil then
      return
   end
   if datatable.ctime~=nil then
      local datatabletime=child(this.transform,"cardetails_panel/Panel_Middle/sp_data/lab_data")
      componentGet(datatabletime,"UILabel").text=os.date("%Y/%m/%d %H:%M",datatable.ctime)
      datatabletime.gameObject:SetActive(true)
   end
   if datatable.clog~=nil and datatable.clog.scorelog~=nil and table.getCount(datatable.clog.scorelog)~=0 then
     
   else 
        return
   end 
   if datatable.aRankId  ==nil then
       return
   end
   local key=datatable.aRankId  
   local cardInfo=datatable.clog.scorelog[index]["cardInfo"]
   if cardInfo == nil then
      return
   end 
   for i=1, table.getCount(cardInfo) do        
      local item=child(this.transform, "cardetails_panel/Panel_Middle/sv_all/item_"..i)
      if item==nil then
            local old_item=child(this.transform, "cardetails_panel/Panel_Middle/sv_all/item_rank")
            item=NGUITools.AddChild(this.grid_rank.gameObject,old_item.gameObject)
            item.transform.localScale={x=1,y=1,z=1}
            item.name="item_"..i
            item.gameObject:SetActive(true)
            componentGet(this.grid_rank.gameObject,"UIGrid"):Reposition()   
      end    
      local lab_number=child(item.transform,"sp_number/lab_number") 
      componentGet(lab_number.gameObject,"UILabel").text=i 
      local lab_score=child(item.transform,"lab_score")
      local lab_type=child(this.transform, "cardetails_panel/Panel_Middle/lab_type")
      componentGet(lab_score.gameObject,"UILabel").text=datatable.clog.scorelog[index][key[i]]
      local lab_name=child(item.transform,"lab_name")
      componentGet(lab_name.gameObject,"UILabel").text=datatable.accountc.rewards[key[i]].nickname
      local tex_photo=child(item.transform,"tex_photo") 
      local imagetype=datatable.accountc.rewards[key[i]].img.type 
      local imageurl=datatable.accountc.rewards[key[i]].img.url 
      hall_data.getuserimage(componentGet(tex_photo.gameObject,"UITexture"),imagetype,imageurl)
      
      if  tonumber(datatable.gid)==ENUM_GAME_TYPE.TYPE_SHISHANSHUI then
              local card=cardInfo[key[i]].cards 
              local grid1={card[13],card[12],card[11]} 
              local grid2={card[10],card[9],card[8],card[7],card[6]}
              local grid3={card[5],card[4],card[3],card[2],card[1]}
              local g={grid1,grid2,grid3}
              local sg={card[13],card[12],card[11],card[10],card[9],card[8],card[7],card[6],card[5],card[4],card[3],card[2],card[1]} 
             if tonumber(cardInfo[key[i]].nSpecialType)~=0 then
                local grid=child(item.transform,"grid_card1") 
                this.LoadAllCard(grid,sg)
                lab_type.gameObject:SetActive(false)  
                local lab_s=child(item.transform,"lab_s")   
                componentGet(lab_s.gameObject,"UILabel").text= GStars_Special_Type_Name[tonumber(cardInfo[key[i]].nSpecialType)]
             else
                 for l=1 ,3 do
                    local grid=child(item.transform,"grid_card"..l) 
                    this.LoadAllCard(grid,g[l])
                    lab_type.gameObject:SetActive(true)
                 end 
             end
          else  
             lab_type.gameObject:SetActive(false)
             local card=cardInfo[key[i]].cards
             table.sort(card) 
             if table.getCount(cardInfo[key[i]].combineTile)>0 then 
                for j=1,#cardInfo[key[i]].combineTile do 
                    local ttt=cardInfo[key[i]].combineTile[j]
                    if tonumber(ttt.ucFlag)==16 then
                        table.insert(card,tonumber(ttt.card))
                        table.insert(card,tonumber(ttt.card)+1)
                        table.insert(card,tonumber(ttt.card)+2)
                    elseif tonumber(ttt.ucFlag)==17 then
                        table.insert(card,tonumber(ttt.card))
                        table.insert(card,tonumber(ttt.card))
                        table.insert(card,tonumber(ttt.card))
                    elseif tonumber(ttt.ucFlag)==18 or tonumber(ttt.ucFlag)==19 or tonumber(ttt.ucFlag)==20 then
                        table.insert(card,tonumber(ttt.card))
                        table.insert(card,tonumber(ttt.card))
                        table.insert(card,tonumber(ttt.card))
                        table.insert(card,tonumber(ttt.card))
                    end
                    ttt.ucFlag=0
                end
             end
             local scale=1
             if table.getCount(card)>16 then
                 scale= 16/table.getCount(card)
             end
             local grid=child(item.transform,"grid_card1") 
             for l=1,#card do
                local c=newNormalUI("app_8/ui/common/card") 
                c.transform.localScale={x=scale,y=scale,z=scale}
                componentGet(grid.gameObject,"UIGrid").cellWidth=35*scale
                c.transform.parent=grid
                local sp=child(c.transform,"card")
                componentGet(sp,"UISprite").spriteName=card[l].."_hand"
                if tonumber(datatable.clog.scorelog[index].laizicards[1])==tonumber(card[l]) then
                    local laizi=child(c.transform,"Sprite")
                    laizi.gameObject:SetActive(true)
                end
             end
             if table.getCount(cardInfo[key[i]].win_card)>0 then
                table.foreach(cardInfo[key[i]].win_card,print)
                local c=newNormalUI("app_8/ui/common/card")
                local sp=child(c.transform,"card")
                componentGet(sp,"UISprite").spriteName=cardInfo[key[i]].win_card[1].."_hand"
                if tonumber(datatable.clog.scorelog[index].laizicards[1])==tonumber(cardInfo[key[i]].win_card[1]) then
                    local laizi=child(c.transform,"Sprite")
                    laizi.gameObject:SetActive(true)
                end
                c.transform.localScale={x=scale,y=scale,z=scale}
                c.transform.parent=grid.transform.parent
                c.transform.localPosition={x=grid.localPosition.x+35*scale*(table.getCount(card))+10,y=grid.localPosition.y,z=0}
             end 
          end   
   end
end 
--加载13张牌
function this.LoadAllCard(grid,cards)  
	
	for i = 1, #cards do
		local card = cards[i]
		local card_data = {}
		card_data.tran = newNormalUI("game_80011/scene/card/"..tostring(card), grid)
        componentGet(card_data.tran.gameObject,"BoxCollider").enabled=false
		if card_data.tran == nil then
			fast_tip.Show(GetDictString(6045)..tostring(card))
			break
		end 
		local k = i - 1   
        card_data.tran.transform.localScale={x=0.4,y=0.4,z=0.4} 
		componentGet(child(card_data.tran.transform, "bg"),"UISprite").depth = i * 2 + 3
		componentGet(child(card_data.tran.transform, "num"),"UISprite").depth = i * 2 + 5
		componentGet(child(card_data.tran.transform, "color1"),"UISprite").depth = i * 2 + 5
		componentGet(child(card_data.tran.transform, "color2"),"UISprite").depth = i * 2 + 5
		if room_data.GetSssRoomDataInfo().isChip == true and card == 40 then
			componentGet(child(card_data.tran.transform, "ma"),"UISprite").depth = i * 2 + 4
		end  
	end 
end  
--[[ 
{"ret":0,"data":{"rid":16238,"uid":18204136,"rno":"309431","gid":18,"cfg":{"settlement":1,"allpure":1,"halfpure":1,"kindD":1,"DkingD":0,"rounds":4,"pnum":2},"accountc":{"banker":1,"curr_ju":1,"ju_num":4,"rewards":{"p2":{"uid":7581913,"hu_score":0,"all_score":11,"hu_num":1,"score":[{"selfdraw":0},{"gunwin":1},{"nGoldBird":0},{"nGoldDragon":0},{"nQYS":0}],"nickname":"玩家269520","img":{"url":"10","type":1,"uid":7581913}},"p1":{"uid":18204136,"hu_score":0,"all_score":-11,"hu_num":0,"score":[{"selfdraw":0},{"gunwin":0},{"nGoldBird":0},{"nGoldDragon":0},{"nQYS":0}],"nickname":"玩家88D7F67B","img":{"url":"20","type":1,"uid":18204136}}}},"status":2,"uri":"\/chess\/1","ctime":1502186113,"clog":{"chairs":{"p1":"玩家88D7F67B","p2":"玩家269520"},"imgs":{"p1":{"url":"20","type":1,"uid":18204136},"p2":{"url":"10","type":1,"uid":7581913}},"scorelog":[{"cardInfo":{"p1":{"cards":[13,13,11,23,4,17,7,9,7,1,16,9,9,3,22,16],"win_card":[],"combineTile":[]},"p2":{"cards":[1,19,1,17,18,18,4,6,19,5],"win_card":[17],"combineTile":[{"card":26,"ucFlag":16,"value":1},{"card":14,"ucFlag":16,"value":0}]}},"p1":-11,"p2":11,"laizicards":[5],"ts":1502186239,"banker":1}]},"cost":1,"expiretime":1502187913,"aRankId":["p2","p1"]}}
]]--