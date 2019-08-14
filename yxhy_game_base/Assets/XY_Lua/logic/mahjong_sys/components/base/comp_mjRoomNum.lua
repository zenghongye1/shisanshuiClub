local mode_comp_base = require "logic/mahjong_sys/components/base/mode_comp_base"
local comp_mjRoomNum = class("comp_mjRoomNum", mode_comp_base)

function comp_mjRoomNum:ctor(tr)
	self.tr = tr
	self.go = tr.gameObject
	self.numSpList = {}
	self.fangjian_spr = subComponentGet(self.tr, "lbl1", typeof(UnityEngine.SpriteRenderer))
	self:InitNumSps()
end


function comp_mjRoomNum:InitNumSps()
	self.go:SetActive(false)
	for i = 1, 6 do 
		local sp = subComponentGet(self.tr, i, typeof(UnityEngine.SpriteRenderer))
		self.numSpList[i] = sp
	end
end

function comp_mjRoomNum:SetRoomNum(roomNum,resPath)
	local num = roomNum
	for i = 6, 1, -1 do
		local value = math.fmod(num, 10)
		self:SetSpImg(self.numSpList[i], value,resPath)
		num = math.floor(num / 10)
	end
	if num > 0 then
		logError("房间号异常", roomNum)
	end
	self.go:SetActive(true)
end

function comp_mjRoomNum:SetColor(num)
	if self.fangjian_spr then
		componentGet(self.fangjian_spr,"SpriteRenderer").color = mahjongConst.TableFontColor[num]
	end
	for i=1,#self.numSpList do
		self.numSpList[i].color = mahjongConst.TableFontColor[num]
	end
end

function comp_mjRoomNum:SetColorByColor(color)
	if self.fangjian_spr then
		componentGet(self.fangjian_spr,"SpriteRenderer").color = color
	end
	for i=1,#self.numSpList do
		self.numSpList[i].color = color
	end
end

function comp_mjRoomNum:SetSpImg(sp, num,resPath)
	if sp ~= nil and sp.sprite ~= nil and sp.sprite.name == tostring(num) then
		return
	end
	local path = mahjong_path_mgr.commonMJPrefix
	if resPath ~= nil then 
		path = resPath
	end
	local tex = newNormalObjSync(path.."/texture/"..num, typeof(UnityEngine.Texture2D))
	sp.sprite = UnityEngine.Sprite.Create(tex,UnityEngine.Rect.New(0,0,64,64),Vector2(0.5,0.5))
	sp.sprite.name = num
end

function comp_mjRoomNum:SetSpImgByTransform(trans,iconName,resPath,width,heght)
	local sp = componentGet(trans, typeof(UnityEngine.SpriteRenderer))
	local tex = newNormalObjSync(resPath.."/texture/"..iconName, typeof(UnityEngine.Texture2D))
	sp.sprite = UnityEngine.Sprite.Create(tex,UnityEngine.Rect.New(0,0,width,heght),Vector2(0.5,0.5))
end

function comp_mjRoomNum:Uninitialize()
	self.go:SetActive(false)
end



return comp_mjRoomNum