screenshotHelper = {}

local YX_APIManage = YX_APIManage

--[[--
 * @Description: 截屏并分享
 * platform		2 微信，3 QQ，
 * shareType	0微信好友，1朋友圈，2微信收藏
 * contentType	1文本，2图片，3声音，4视频，5网页
 * title		"分享战绩"
 * url			"http://connect.qq.com/"
 * Description 	"分享战绩"
 ]]
function screenshotHelper.GetShot(platform,shareType,contentType,title,url,description)
	ui_sound_mgr.PlaySoundClip(data_center.GetAppConfDataTble().appPath.."/sound/common/audio_button_click")

	local picName= "screenshot"..tostring(os.date("%Y%m%d%H%M%S", os.time()))..".png"
	local filePath = YX_APIManage.Instance.ScreenshotPath..picName
    local callback = function(tx)
		shareHelper.doShare(platform,shareType,contentType,title,filePath,url,description)
    end
    screenshotHelper.ScreenShot(picName,callback)
end

--[[--
 * @Description: 截屏至相册  
 ]]
function screenshotHelper.ShotToPhoto(callback)
	ui_sound_mgr.PlaySoundClip(data_center.GetAppConfDataTble().appPath.."/sound/common/audio_button_click")

	local picName= "screenshot"..tostring(os.date("%Y%m%d%H%M%S", os.time()))..".png"
	local filePath = YX_APIManage.Instance.ScreenshotPath..picName
	local cb = function(tx)
		YX_APIManage.Instance:SavePicToPhoto(picName)
		if callback then
			callback()
		end
	end
	screenshotHelper.ScreenShot(picName,cb)
end

function screenshotHelper.ScreenShot(picName,callback)
	YX_APIManage.Instance:GetCenterPicture(picName)
    YX_APIManage.Instance.onfinishtx = callback
end

---截图指定相机	Rect,RenderTexture,Texture2D
function screenshotHelper.GetPictureByRect(picName,camera,posx,posy,width,height,callback)
	coroutine.start(function()
		local rect = UnityEngine.Rect.New(posx,posy,width,height)
		local renderTexture = UnityEngine.RenderTexture.New(width,height,0)
		camera.pixelRect = rect
		camera.targetTexture = renderTexture
		WaitForEndOfFrame()
		
		local tex2D = UnityEngine.Texture2D.New(rect.width,rect.height)
		camera:Render()
		UnityEngine.RenderTexture.active = renderTexture
		tex2D:ReadPixels(rect,0,0)
		camera.targetTexture = nil
		UnityEngine.RenderTexture.active = nil
		
		local bytes = tex2D:EncodeToJPG(50)
		local path = YX_APIManage.Instance:onGetStoragePath()..tostring(picName)..tostring(os.date("%Y%m%d%H%M%S", os.time()))..".png"

		FileUtils.CreateAndWriteToFile(path,bytes)

		if callback then
			callback(tex2D)
		end
	end)
end

---截图指定相机
function screenshotHelper.GetPictureByCarema(picName,camera,posx,posy,width,height,callback)
	YX_APIManage.Instance:GetCenterPicture(picName,camera,posx,posy,width,height)
end