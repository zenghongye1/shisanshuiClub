webview_ui = ui_base.New()
local this = webview_ui 

this.url=""

function this.Show(str)
	Trace("webview_ui.show-------------------------------------2")
	if this.gameObject==nil then
		newNormalUI("app_8/ui/common/webview_ui")
	else
		this.gameObject:SetActive(true)
	end
    this.ShowWeb()
end
function this.ShowWeb()
    if this.url~=nil then
        webview.ShowByUrl(this.url)
        webview.RunJSFunctionByurl(this.url,"publicWebFunction")
    end 
end

function this.Start()
	this:InitPanelRenderQueue()
	this.CloseBtn()
end

function  this.CloseBtn()
	local closeBtn = child(this.transform,"panel/btn_close")
 	if closeBtn ~= nil then
        addClickCallbackSelf(closeBtn.gameObject,this.OnBtnCloseClick,this)
    end
end
function this.Hide()
    destroy(this.gameObject)
	this.gameObject=nil
end
function this.OnBtnCloseClick()  
    webview.HideByUrl(this.url)
	destroy(this.gameObject)
    this.url=nil
	this.gameObject=nil
end

function this.UpdateTitle(spName)
	local title=child(this.transform,"panel/Panel_Top/Title") 
	local sprite= componentGet(title.gameObject,"UISprite") 
    local rate= 1280.0/720.0
    local screenrate=Screen.width*1.0/Screen.height*1.0
    local scale=1.0 
    if rate>screenrate then
        scale=rate/screenrate
    end 
    title.transform.localPosition={x=0,y=173*scale+(sprite.height*scale-sprite.height),z=0}  
    local background=child(this.transform,"panel/Panel_Top/Texture") 
    local tx= componentGet(background,"UITexture")
	if sprite ~= nil then
	   sprite.spriteName=spName
       sprite:MakePixelPerfect()
    end 
end 