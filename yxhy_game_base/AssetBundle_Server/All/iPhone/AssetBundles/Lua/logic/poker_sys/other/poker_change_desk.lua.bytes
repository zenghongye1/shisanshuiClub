local poker_change_desk = class("poker_change_desk")
function poker_change_desk:ctor(tableModelObj,roomNumComp)
	self.tableModelObj = tableModelObj
	 self.roomNumComp = roomNumComp
	self.TableFontColor = 
	{
		[1] = Color(1/255,2/255,2/255,70/255),
		[2] = Color(1/255,2/255,2/255,70/255),
		[3] = Color(1/255,2/255,2/255,70/255),
	}
end

--[[--
 * @Description: 更换桌布  
 ]]
function poker_change_desk:ChangeDeskCloth()
    local clothNum = self:GetPlayerPrefs("poker_desk")
    if clothNum~= "1" and clothNum~= "2" and clothNum~= "3" then
     --   return
		clothNum = "1"
    end
    local matName = "poker_table_cloth_0"..clothNum..""
    local mat = newNormalObjSync(data_center.GetResPokerCommPath().."/materials/"..matName, typeof(UnityEngine.Material))
    local meshRenderer = self.tableModelObj:GetComponent(typeof(UnityEngine.MeshRenderer))
    meshRenderer.sharedMaterial = mat
	
	
    if self.table_name_sprite then
        componentGet(self.table_name_sprite,"SpriteRenderer").color = mahjongConst.TableFontColor[tonumber(clothNum)] -- Color.green -- mahjongConst.TableFontColor[clothNum]
    end
	local tip1 = GameObject.Find("roomInfo/tip1")
	if tip1 ~= nil then
		componentGet(tip1.transform,"SpriteRenderer").color = self.TableFontColor[tonumber(clothNum)]
	end
	
	local tip2 = GameObject.Find("roomInfo/tip2")
	if tip2 ~= nil then
		componentGet(tip2.transform,"SpriteRenderer").color = self.TableFontColor[tonumber(clothNum)]
	end
	local gameIcon = GameObject.Find("roomInfo/gameIcon")
	if gameIcon ~= nil then
		componentGet(gameIcon.transform,"SpriteRenderer").color = self.TableFontColor[tonumber(clothNum)]
	end
	 if self.roomNumComp then
        self.roomNumComp:SetColorByColor(self.TableFontColor[tonumber(clothNum)])
    end
end

function poker_change_desk:SetPlayerPrefs(key, v)
    PlayerPrefs.SetString(key, v)
    if this.playerprefs[key]~=nil then
      this.playerprefs[key] = v
    end
end

function poker_change_desk:GetPlayerPrefs(key)
    return PlayerPrefs.GetString(key)
end

return poker_change_desk