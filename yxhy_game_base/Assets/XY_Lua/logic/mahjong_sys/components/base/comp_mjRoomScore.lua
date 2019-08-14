local mode_comp_base = require "logic/mahjong_sys/components/base/mode_comp_base"
local comp_mjRoomScore = class("comp_mjRoomScore", mode_comp_base)

function comp_mjRoomScore:ctor(tr)
	self.tr = tr
	self.go = tr.gameObject
	self.numInfoList = {}
	self:InitNumInfo()
end


function comp_mjRoomScore:InitNumInfo()
	self.go:SetActive(false)
	for i = 1, 6 do 
		local subTr = child(self.tr, "num/"..i)
		local sp = componentGet(subTr, typeof(UnityEngine.SpriteRenderer))
		local tmp = {}
		tmp.tr = subTr
		tmp.sp = sp
		table.insert(self.numInfoList, tmp)
		tmp.tr.gameObject:SetActive(false)		
	end
end

function comp_mjRoomScore:SetRoomScore(roomScore)	
	local scoreStr = tostring(roomScore)
	local len = string.len(scoreStr)
	if len >= 5 then
		local value = tonumber(string.sub(scoreStr, 1, 1))
		self.numInfoList[1].tr.gameObject:SetActive(true)	
		self.numInfoList[2].tr.gameObject:SetActive(true)		
		self:SetSpImg(self.numInfoList[1].sp, value)
		self:SetSpImg(self.numInfoList[2].sp, "wan")
	else
		for i = 1, len do			
			local value = tonumber(string.sub(scoreStr, i, i))
			self.numInfoList[i].tr.gameObject:SetActive(true)			
			self:SetSpImg(self.numInfoList[i].sp, value)
		end
	end

	self.go:SetActive(true)
end


function comp_mjRoomScore:SetSpImg(sp, num)	
	local tex = newNormalObjSync(mahjong_path_mgr.commonMJPrefix.."/texture/d_"..num, typeof(UnityEngine.Texture2D))
	sp.sprite = UnityEngine.Sprite.Create(tex,UnityEngine.Rect.New(0,0,64,64),Vector2(0.5,0.5))
end

function comp_mjRoomScore:Uninitialize()
	self.go:SetActive(false)
end



return comp_mjRoomScore