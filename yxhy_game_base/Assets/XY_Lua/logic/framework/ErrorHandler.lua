local ErrorHandler = {}


function ErrorHandler.CheckMsgErrorNo(msgTab, noTips, errorHandler)
	if msgTab._errno == nil then
		return true
	end
	-- 大于10000 默认弹tips  小于10000 客户端自己处理
	if msgTab._errno >= 10000 then
		if msgTab._errstr ~= nil and msgTab._errstr ~= "" and not noTips then
			UIManager:FastTip(msgTab._errstr)
		end
	end

	-- 1000 --> 1100  是房卡不足处理
	if msgTab._errno >= 1000 and msgTab._errno <= 1100 then
		ErrorHandler.HandleMoneyNotEnough(msgTab._errstr)
	end

	if msgTab._errno == 401 then
		ErrorHandler.HandleRelogin()
	end

	if msgTab._errno == 400 or msgTab._erron == 500 then
		ErrorHandler.HandleNetError()
	end

	if errorHandler ~= nil then
		errorHandler(msgTab._errno, msgTab._errstr)
	end

	return false

end

function ErrorHandler.HandleMoneyNotEnough(msg)
	if msg == "" then
		return
	end
	MessageBox.ShowYesNoBox(msg, function ()
         UIManager:ShowUiForms("shop_ui")
    end)
end


function ErrorHandler.HandleRelogin(msg)
	UIManager:FastTip("请重新登录")
	game_scene.gotoLogin()  		
	game_scene.GoToLoginHandle()
end

function ErrorHandler.HandleNetError()
	MessageBox.ShowYesNoBox(LanguageMgr.GetWord(6015))
end

return ErrorHandler