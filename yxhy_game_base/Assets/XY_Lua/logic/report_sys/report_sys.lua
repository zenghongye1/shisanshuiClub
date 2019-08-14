report_sys = {}

function report_sys.EventUpload(num,gid)
	if data_center.GetCurPlatform() == "WindowsEditor" or data_center.GetCurPlatform() == "OSXEditor" then
		return
	end
	local param = {}
	local tbl = config_mgr.getConfig("cfg_eventload",num)
	if tbl == nil or tbl["eventName"] == nil then
		return
	end
	param["eventName"]= tbl["eventName"]
	if gid ~= nil then
		param["gid"] = gid
	end
	--logError(GetTblData(param))
	http_request_interface.EventUpload(param)
end