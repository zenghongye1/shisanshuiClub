co_mgr = {}

local coMap = {}
setmetatable(coMap, {__mode = "kv"})

function co_mgr.start(f, ...)
	local co = coroutine.start(f, ...)
	coMap[co] = 1
	return co
end


function co_mgr.stop(co)
	coroutine.stop(co)
	if coMap[co] ~= nil then
		coMap[co] = nil
	end
end


function co_mgr.stopAll()
	local tab = {}
	for k, v in pairs(coMap) do
		if k ~= nil then
			table.insert(tab,k)
		end
	end
	for i = 1, #tab do
		coroutine.stop(tab[i])
	end
	coMap = {}
end
