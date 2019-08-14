--[[--
 * @Description: 提供tween动画安全调用
 * @Author:      ShushingWong
 * @FileName:    dotween_sys.lua
 * @DateTime:    2017-07-29 16:03:01
 ]]

 this = dotween_sys

 --local KillTweenFuns = {}
 local tweenersTable = {}

 --[[
 function this.AddKillFun( fun )
 	table.insert(KillTweenFuns,fun)
 end

 function this.RemoveKillFun(fun)
 	for i,v in ipairs(table_name) do
 		if v == fun then
 			table.remove(i)
 			break
 		end
 	end
 end
 ]]

function this.DOLocalMove(trans,endPos,time,callback,ease)
	local tweener = trans:DOLocalMove(endPos,time,false)
	table.insert(tweenersTable,tweener)
	tweener:OnComplete(function()
		for i,v in ipairs(tweenersTable) do
			if v == tweener then
	 			table.remove(i)
	 			break
	 		end
		end
		if callback~=nil then
			callback()
		end
	end)

	if ease~=nil and ease == type(DG.Tweening.Ease) then
		tweener:SetEase(ease)
	end
end

function this.DOLocalRotate(trans,endRot,time,callback)
local tweener = trans:DOLocalRotate(endRot, time, DG.Tweening.RotateMode.Fast)
	table.insert(tweenersTable,tweener)
	tweener:OnComplete(function()
		for i,v in ipairs(tweenersTable) do
			if v == tweener then
	 			table.remove(i)
	 			break
	 		end
		end
		if callback~=nil then
			callback()
		end
	end)
end

function this.DOScale(trans,endSize,time,callback)
	local tweener = trans:DOScale(endSize, time)
	table.insert(tweenersTable,tweener)
	tweener:OnComplete(function()
		for i,v in ipairs(tweenersTable) do
			if v == tweener then
	 			table.remove(i)
	 			break
	 		end
		end
		if callback~=nil then
			callback()
		end
	end)
end

function CancelTween()
	for i,v in ipairs(tweenersTable) do
		if v:IsComplete() then
			v:Complete(true)
		end
		v = nil
	end
	tweenersTable = {}
end