--[[--
 * @Description: 弹框提示
 * @Author:      shine
 * @FileName:    message_box.lua
 * @DateTime:    2015-07-06 19:52
 ]]

message_box = ui_base.New() 
local this=message_box  


MessageBoxType = 
{
    defalut = 0,
    vote = 1,
}

local validPosition = nil
local btnCloseCallBack = nil

--[[--
	 * @Description: 显示UI
	                title: 标题，可以为空
					content: 正文，可以为空
					btnNumber: 按钮数量，不能超过 3
					btnCallback: 事件回调，带一个参数(index)：点击了第几个按钮，-1表示关闭按钮, 可以为空----table类型
                    btbname:fonts_01 确定，fonts_02 取消，fonts_05 放弃，fonts_06 充值，fonts_07立即领取， 

	 * @Return:     message_box 类对象，可以操纵其它接口

	 ]]
 
function message_box.ShowGoldBox(content, btnCallback, btnname, btnbacksprite, type,other)
    if this.gameObject == nil then
        this.messageType = type
        local obj = newNormalUI("app_8/ui/common/message_box")
        validPosition = obj.transform.position
        validPosition.z = -1001
        obj.transform.localPosition = validPosition
        this.gameObject = obj
        if obj ~= nil then  
    		this.SetGoldBaseInfo(content, btnCallback,btnname,btnbacksprite,other)
		end
        return obj
    else
        message_box.Close()
        return message_box.ShowGoldBox(content,btnCallback,btnname,btnbacksprite, type)
    end
end


function message_box.OnCloseClick()
    if btnCloseCallBack ~= nil then
        btnCloseCallBack()
        btnCloseCallBack = nil
    end    
    this.Close()
end

-- msgType 为nil 或者 msgType相等时才会关闭
function message_box.Close(msgType)
    if msgType ~= nil and this.messageType ~= nil and this.messageType ~= msgType then
        return 
    end

    this.messageType = nil
	if this.gameObject~=nil then
        Trace("nil------------------")
        GameObject.Destroy(this.gameObject)
        this.gameObject=nil
    end
end 

--[[--
 * @Description: 设置关闭按钮的回调事件  
 ]]
function this.SetBtnCloseCallBack(callback)
    btnCloseCallBack = callback
end

--[[--
 * @Description: 基本信息设置
                title: 标题，可以为空
				content: 正文，可以为空
				btnNumber: 按钮数量，不能超过 3
				btnCallback: 事件回调，带两个参数(1：点击了第几个按钮，从1开始，-1表示关闭按钮。2：customData）可以为空
 ]]
function this.SetGoldBaseInfo(content, btnCallback,btnname, btnbacksprite,other) 
	--content
    this.closebtn=child(this.transform,"bg/sv_gold/btn_close");
    if this.closebtn~=nil then
        addClickCallbackSelf(this.closebtn.gameObject, this.OnCloseClick)
    end

    local lb_content_gt = child(this.transform, "bg/sv_gold/lab_content")
    this.lb_content_g=componentGet(lb_content_gt.gameObject,"UILabel") 
    this.lb_content_g.text=content  
     
    local parent=child(this.transform,"bg/sv_gold/btn_grid") 
    this.HideButton(parent);
	--btns
	for k = 1, #btnCallback,1 do
        local btn=child(this.transform,"bg/sv_gold/btn_grid/btn_0"..tostring(k)) 
        if btn==nil then 
            local obj=child(this.transform,"bg/sv_gold/btn_grid/btn_0"..tostring(k-1)) 
            btn=GameObject.Instantiate(obj)
            btn.transform.parent=obj.parent
            btn.transform.localScale={x=1,y=1,z=1}
            btn.name="btn_0"..tostring(k)
        end 
        addClickCallbackSelf(btn.gameObject,btnCallback[k],this) 
        btn.gameObject:SetActive(true)
        if btnname[k]~=nil then
            local btn_sp=child(btn.transform,"Sprite"); 
            componentGet(btn_sp.gameObject,"UISprite").spriteName=btnname[k]
            componentGet(btn_sp.gameObject,"UISprite"):MakePixelPerfect()
            if btnname[k]=="quding" then
                componentGet(child(btn.transform,"Background").gameObject,"UISprite").spriteName="a01"
            else    
                componentGet(child(btn.transform,"Background").gameObject,"UISprite").spriteName="a02"
            end 
        end 
        if  btnbacksprite~=nil and btnbacksprite[k]~=nil then 
            componentGet(child(btn.transform,"Background").gameObject,"UISprite").spriteName=btnbacksprite[k]
        end
	end 
end

 
 function this.HideButton(parent)
    for i=0,parent.transform.childCount-1 do
        local btn=parent.transform:GetChild(i);
        btn.gameObject:SetActive(false)
    end
 end