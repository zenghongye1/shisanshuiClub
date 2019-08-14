testUrl = ui_base.New()
local this = testUrl

require "logic/login_sys/login_sys"

local startUrl = "ws://test.dstars.cc:8001?uid=%s&token=%s"
local input_url

function this.Show()
	Trace("Show-------------------------------------")

	if this.gameObject==nil then
		newNormalUI("Prefabs/UI/TestCmd/testUrl")
	else
		this.gameObject:SetActive(true)
	end
end

function this.Hide( )
 	 GameObject.Destroy(this.transform.gameObject);
end

function this.Start()
	Trace("Start-------------------------------------")
    this.RegisterEvents()
    this.Init()
end

function this.Init()
	Trace("Init-------------------------------------")
	input_url.value = startUrl
end
function this.OnDestroy()

end

function this.RegisterEvents()
	Trace("RegisterEvents-------------------------------------")

	input_url = componentGet(child(this.transform,"Input_Url"),"UIInput")

	local btnUrlTran = child(this.transform, "btn_url")
	if btnUrlTran ~=nil then 
	   addClickCallbackSelf(btnUrlTran.gameObject, this.OnBtnUrlClick, this)
	end

	input_url = componentGet(child(this.transform,"Input_Url"),"UIInput")	
end

function this.OnBtnUrlClick()
	login_sys.url = input_url.value
end



