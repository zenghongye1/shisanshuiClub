--[[--
 * @Description: 创建房间组件
 * @Author:      shine
 * @FileName:    hall_ui.lua
 * @DateTime:    2017-05-19 14:33:25
 ]]
 
require "logic/hall_sys/hall_data"
require "logic/network/http_request_interface"
require"logic/common_ui/message_box"
require"logic/network/majong_request_protocol"

 
room_prepare = ui_base.New()
local this = room_prepare 
local transform;  

function this.Awake() 
   this.initinfor()   
  	--this.registerevent() 
end

function this.Show()
	print("room_prepare")
	if this.gameObject==nil then
		require ("logic/hall_sys/room_prepare")
		this.gameObject=newNormalUI("Prefabs/UI/Room/room_prepare")
	else
		GameObject.Destroy(this.gameObject)
        this.gameObject=nil
	end
end

function this.Hide()
	if this.gameObject == nil then
		return
	else
		GameObject.Destroy(this.gameObject)
		this.gameObject = nil
	end
end

--[[--
 * @Description: 逻辑入口  
 ]]
function this.Start()   
	this.registerevent()
end

--[[--
 * @Description: 销毁  
 ]]
function this.OnDestroy()
end

---[[
function this.initinfor()
end
--]]

--注册事件
function this.registerevent() 
end


