--[[--
 * @Description:	替换 hall_data.getuserimage()
 * 					改为 HeadImageHelper.SetImage()
 ]]

HeadImageHelper = {}

local this = HeadImageHelper

local baseImage = nil
local selfImage = {}
local texList = {}

function this.SetSelfImage(tx)
	if not tx then
		return
	end
	local userInfo 
	if data_center and data_center.GetLoginUserInfo() then
		userInfo = data_center.GetLoginUserInfo()
	else
		tx.mainTexture = this.GetBaseImage()
	end
	if (not userInfo.imagetype) or userInfo.imagetype ~= 2 then
        tx.mainTexture = this.GetBaseImage()
    end
    if (not userInfo.imageurl) or tostring(userInfo.imageurl) == "" then
    	tx.mainTexture = this.GetBaseImage()
    end
    if IsNil(selfImage[userInfo.uid]) then
    	DownloadCachesMgr.Instance:LoadImage(userInfo.imageurl,function( code,texture )
			if code == 0 then
				selfImage[userInfo.uid] = texture
				tx.mainTexture = selfImage[userInfo.uid]
			else
				tx.mainTexture = this.GetBaseImage()
			end
	    end)
    else
    	tx.mainTexture = selfImage[userInfo.uid]
    end
end

function this.SetImage(tx, itype, iurl,uid)
	if not tx then
		return
	end
	if this.IsSelfPlayer(itype, iurl, uid) then
		this.SetSelfImage(tx)
		return
	end
	if itype == nil and iurl == nil then
		this.SetSelfImage(tx)
		return
	end
	if (not itype) or itype ~= 2 then
        tx.mainTexture = this.GetBaseImage()
    end

	if iurl then
		local tex = texList[iurl]
		if tex then
			tx.mainTexture = tex
			return
		end
		DownloadCachesMgr.Instance:LoadImage(iurl,function( code,texture )
			if code == 0 then
				tx.mainTexture = texture
				texList[iurl] = texture
			else
				tx.mainTexture = this.GetBaseImage()
			end
	    end)
	else
		tx.mainTexture = this.GetBaseImage()
	end
end

function this.GetBaseImage()
    if IsNil(baseImage) then
        local baseImagePrefab = newNormalObjSync(data_center.GetAppConfDataTble().appPath.."/uitextures/art/common_head", typeof(UnityEngine.Texture2D))
        baseImage = newobject(baseImagePrefab)
        GameObject.DontDestroyOnLoad(baseImage)
    end
    return baseImage
end

function this.IsSelfPlayer(itype, iurl, uid)
	local userInfo 
	if data_center and data_center.GetLoginUserInfo() then
		userInfo = data_center.GetLoginUserInfo()
	else
		return
	end
	if uid then
		if userInfo.uid and userInfo.uid == uid then
			return true
		end
	end
	if itype and iurl then
		if userInfo.imagetype and userInfo.imagetype == itype and userInfo.imageurl and userInfo.imageurl == iurl then
			return true
		end
	end
end