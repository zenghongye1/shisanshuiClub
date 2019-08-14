--region *.lua
--Date
--此文件由[BabeLua]插件自动生成 
 
rules_ui = ui_base.New()
local this = rules_ui 
local rules_table=
{
    ["bSupportHalfColor"]={"可胡清一色",{"是","否"}},
    ["bSupportGoldDragon"]={"可胡金龙",{"是","否"}},
    ["maxplayernum"]={"牌局人数",{"2人","3人","4人"}},
    ["bSupportGunOne"]={"放炮几人赔",{"1人","3人"}}
}
local rules_key=
{
    "bSupportHalfColor",
    "bSupportGoldDragon",
    "maxplayernum",
    "bSupportGunOne"
}
function this.Show()
	if this.gameObject==nil then
		require ("logic/common_ui/rules_ui")
		this.gameObject=newNormalUI("app_8/ui/common/rules_ui")
	else  
        this.gameObject:SetActive(true)
	end 
    this.addlistener()
    this.Init()
end

function this.Start() 
    this:RegistUSRelation()
end

function this.OnDestroy()
    this:UnRegistUSRelation()
end
function this.addlistener() 
    local btn_close=child(this.transform,"rules_panel/btn_close")
    if btn_close~=nil then
        addClickCallbackSelf(btn_close.gameObject,this.Hide,this)
    end 
end

function this.Init()
    local grid= child(this.transform,"rules_panel/Grid")
    local item=child(this.transform,"rules_panel/item")
    for i=1, #rules_key do 
        local t=GameObject.Instantiate(item)
        t.parent=grid
        t.transform.localScale={x=1,y=1,z=1}
        t.name =i
        local label=subComponentGet(t.transform,"content","UILabel")
        label.text=i.."、"..rules_table[rules_key[i]][1]..":"
        local value=subComponentGet(t.transform,"value","UILabel")
        if roomdata_center.gamesetting[rules_key[i]]~=nil then
           if roomdata_center.gamesetting[rules_key[i]]==true then
               value.text=rules_table[rules_key[i]][2][1]
           else
               value.text=rules_table[rules_key[i]][2][2]
           end
        else
            value.text=rules_table[rules_key[i]][2][tonumber(roomdata_center[rules_key[i]])-1]
        end
        t.gameObject:SetActive(true)
    end
end

function  this.Hide()
    ui_sound_mgr.PlaySoundClip("app_8/sound/common/audio_button_click")
    if not IsNil(this.gameObject) then   
		GameObject.Destroy(this.gameObject)
        this.gameObject=nil
	end
end
