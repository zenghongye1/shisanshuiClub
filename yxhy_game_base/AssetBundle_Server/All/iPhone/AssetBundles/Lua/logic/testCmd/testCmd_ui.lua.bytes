testCmd_ui = ui_base.New()
local this = testCmd_ui

function this.Show()
	Trace("Show-------------------------------------")

	if this.gameObject==nil then
		newNormalUI("Prefabs/UI/TestCmd/testCmd")
	else
		this.gameObject:SetActive(true)
	end
end

function this.Hide( )
 	this.gameObject:SetActive(false)
end

function this.Start()
	Trace("Start-------------------------------------")
    this.RegisterEvents()
end

function this.Init()
	Trace("Init-------------------------------------")

end

function this.RegisterEvents(  )
	Trace("RegisterEvents-------------------------------------")
	this.scrollView=child(this.transform, "ScrollView");
    if this.scrollView~=nil then
        this.grid = child(this.scrollView,"Grid")
        if this.grid then
        	local btn1 = child(this.grid.transform, "btn_game01")
        	if btn1 ~= nil then
				addClickCallbackSelf(btn1.gameObject, this.OnBtn1Click, this)
				local btnTxt = child(btn1.transform, "txt")
				 componentGet(btnTxt,"UILabel").text= "测试发牌"
			end

			local btn2 = child(this.grid.transform, "btn_game02")
        	if btn2 ~= nil then
				addClickCallbackSelf(btn2.gameObject, this.OnBtn2Click, this)
				local btnTxt = child(btn2.transform, "txt")
				 componentGet(btnTxt,"UILabel").text= "测试碰"
			end

			local btn3 = child(this.grid.transform, "btn_game03")
        	if btn3 ~= nil then
				addClickCallbackSelf(btn3.gameObject, this.OnBtn3Click, this)
				local btnTxt = child(btn3.transform, "txt")
				 componentGet(btnTxt,"UILabel").text= "测试杠"
			end

			local btn4 = child(this.grid.transform, "btn_game04")
        	if btn4 ~= nil then
				addClickCallbackSelf(btn4.gameObject, this.OnBtn4Click, this)
				local btnTxt = child(btn4.transform, "txt")
				 componentGet(btnTxt,"UILabel").text= "测试胡"
			end

        end
    end
	
end

function this.OnDestroy()

end

function this.OnBtn1Click(  )
	Trace("---------OnBtn1Click------")
	local str = [[
			{"_cmd":"deal","_para":{"banker":4,"cardCount":{"p1":13,"p2":13,"p3":13,"p4":14},"cardLeft":83,"cards":[25,11,27,26,25,31,37,17,22,16,32,26,36],"dice":[1,6],"roundWind":0,"subRound":4},"_src":"p2","_st":"nti"}
			]]
	local data = netdata_rsp_handler.ParseFromString(str)
	LogW(data)
    msg_dispatch_mgr.HandleRecvData("deal", data)
end


function this.OnBtn2Click(  )
	Trace("---------OnBtn2Click------")
	local str = [[
		{"_cmd":"triplet","_para":{"cardTriplet":{"triplet":25,"useCards":[25,25]},"tripletWho":3},"_src":"p2","_st":"nti"} 
			]]
	local data = netdata_rsp_handler.ParseFromString(str)
	LogW(data)
    msg_dispatch_mgr.HandleRecvData("triplet", data)
end

function this.OnBtn3Click(  )
	Trace("---------OnBtn3Click------")
	local str = [[
		{"_cmd":"quadruplet","_para":{"cardQuadruplet":{"quadruplet":25,"useCards":[25,25,25]},"quadrupletWho":3,"quadrupletType":1},"_src":"p2","_st":"nti"} 
			]]
	local data = netdata_rsp_handler.ParseFromString(str)
	LogW(data)
    msg_dispatch_mgr.HandleRecvData("triplet", data)
end


function this.OnBtn4Click(  )
	Trace("---------OnBtn4Click------")
	
end

