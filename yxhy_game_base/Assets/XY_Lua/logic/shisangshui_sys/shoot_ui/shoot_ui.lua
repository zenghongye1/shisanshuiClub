--[[--
 * @Description: 打枪
 * @Author:      zhy
 * @FileName:    shoot_ui.lua
 * @DateTime:    2017-07-08
 ]]
 require "logic/animations_sys/animations_sys"

 
shoot_ui = ui_base.New()
local this = shoot_ui 
local transform; 

function this.Awake()
   this.initinfor()
  	--this.registerevent() 
end

function this.Show()
	if this.gameObject==nil then
		require ("logic/shisangshui_sys/shoot_ui/shoot_ui")
		this.gameObject=newNormalUI("Prefabs/UI/ShootUI/shoot_ui")
	else
		GameObject.Destroy(this.gameObject)
        this.gameObject=nil
	end
	--this.LoadAnimal()
	this.PlayShootKuang()
  	--this.addlistener()
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

function this.PlayShootKuang(tran)
	if this.gameObject == nil then
		this.Show()
	end
	animations_sys.PlayAnimation(tran,"shisanshui_shoot_kuang","bomb box",100,100,false, function() end)
end

function this.PlayShoot(tran)
	if this.gameObject == nil then
		this.Show()
	end
	animations_sys.PlayAnimation(tran,"shisanshui_shoot","Shoot",100,100,false, function() end)
end

function this.PlayShootHole(tran)
	if this.gameObject == nil then
		this.Show()
	end
	animations_sys.PlayAnimation(tran,"shisanshui_shoot","Shoot2",100,100,false, this.PlayShoot())
end

function this.initinfor()
end

--注册事件
function this.registerevent()
	this.BtnClickEvent()
end



