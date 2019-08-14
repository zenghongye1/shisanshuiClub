	local poker_player_ui_base = class("poker_player_ui_base")


function poker_player_ui_base:ctor(transform, ui, index)
	self.transform = transform
	self.viewSeat = -1
	self.parentUI = ui
	self.position_index = index
	self.all_score = 0
	
	self.midJoin = false
	self:InitWidget()
end

function poker_player_ui_base:InitWidget()

	--头像
	self.head = child(self.transform, "bg/head")
	self.headTexture = self.head.gameObject:GetComponent(typeof(UITexture))
	addClickCallbackSelf(self.head.gameObject, self.OnPlayerIconClick, self)
end


function poker_player_ui_base:SetCallback(callback, target)
	self.target = target
	self.callback = callback
end


function poker_player_ui_base:OnPlayerIconClick()
	if self.callback ~= nil then
		self.callback(self.target, self)
	end
end

function poker_player_ui_base:GetExpressionCfg()
	return nil
end


-- 播放互动表情
function poker_player_ui_base:playInteractiveExpressionAnimation(cfg, _iKind, _fromPos, _toPos)
	
	local expressionCfg = self:GetExpressionCfg()
	-- 换图
	local prefabPath = data_center.GetAppConfDataTble().appPath.."/mj_common/effects/" .. cfg.prefab
    local prefabObj = newNormalObjSync(prefabPath, typeof(GameObject))
	if prefabObj then
	    local animObj = newobject(prefabObj)
	    animObj.transform.parent = self.transform

	    local headPanel = child(self.transform, "bg/head/headPanel")
	    if headPanel then
	    	animObj.transform.parent = headPanel

	    	-- 设置to相对坐标0
	    	local curPos = headPanel.transform.localPosition
			_toPos.x = _toPos.x -curPos.x
			_toPos.y = _toPos.y -curPos.y

		    local head = child(self.transform, "bg/head")
		    if head then
		    	-- 设置from相对坐标0
		    	local curPos2 = head.transform.localPosition
				_fromPos.x = _fromPos.x -curPos2.x -curPos.x
				_fromPos.y = _fromPos.y -curPos2.y -curPos.y
		    end
	    end

		local animIndex = 0
		-- self.InteractiveExSprite = subComponentGet(self.transform, "bg/InteractiveExSprite", typeof(UISprite))
		local interactiveExSprite = componentGet(animObj, "UISprite")
		interactiveExSprite.spriteName = cfg.frameName..animIndex
		interactiveExSprite:MakePixelPerfect()
		interactiveExSprite.gameObject:SetActive(true)

		local animSpriteObj = interactiveExSprite.gameObject
		if self.viewSeat == 1 and expressionCfg ~=nil and expressionCfg.scale ~= nil  then		--自己大头像
			animSpriteObj.transform.localScale = expressionCfg.scale
		end
		-- scale 
		-- animSpriteObj.transform.localScale = Vector3.New(1.2, 1.2, 1)
		-- rotation 
		if _fromPos.x >_toPos.x then
			-- flipX
			animSpriteObj.transform.localRotation = Vector3.New(0, 180, 0)
		else
			animSpriteObj.transform.localRotation = Vector3.zero
		end
		-- move 
		animSpriteObj.transform.localPosition = _fromPos

		-- 播放帧动画
		local function playAnimation()
			local animationTimer = nil
			animationTimer = Timer.New(function ()
				-- Trace("InteractiveExSprite:"..animIndex)
				-- Trace("InteractiveExSpriteFrame:"..animData.frameName..animIndex)
	  	 		if animIndex < cfg.frameCount then
					animIndex = animIndex +1
					interactiveExSprite.spriteName = cfg.frameName..animIndex
					interactiveExSprite:MakePixelPerfect()
					if self.viewSeat == 1 and expressionCfg ~=nil and expressionCfg.scale ~= nil  then			--自己大头像
						interactiveExSprite.transform.localScale = expressionCfg.scale
					end
				else
					animationTimer:Stop()
					-- interactiveExSprite.gameObject:SetActive(false)
					-- interactiveExSprite = nil

					-- 销毁动画对象
					if animObj then
						destroy(animObj)
						animObj = nil
					end
				end
		  	end, 0.1, -1)
			animationTimer:Start()
		end
		-- 移到指定位置
		_toPos.y = _toPos.y +20
		if _fromPos.x >_toPos.x then
			-- 泼水坐标修正
			if _iKind ==3 then
				_toPos.x = _toPos.x -23
				_toPos.y = _toPos.y +16
				if self.viewSeat == 1 and expressionCfg ~= nil and expressionCfg.offset ~= nil then
					_toPos.x = _toPos.x + expressionCfg.offset.x
					_toPos.y = _toPos.y + expressionCfg.offset.y
				end
			end
		else
			-- 泼水坐标修正
			if _iKind ==3 then
				_toPos.x = _toPos.x +23
				_toPos.y = _toPos.y +16
			end
		end
		_toPos.y = _toPos.y +18

		local isMoveEnd = false
		-- local animTweener = animSpriteObj.transform:DOLocalJump(_toPos, 1,1, 0.5, true)
		local animTweener = animSpriteObj.transform:DOLocalMove(_toPos, 0.3, true)
		animTweener:SetEase(DG.Tweening.Ease.Linear):OnComplete(function()
			playAnimation()
			isMoveEnd = true
		end)
		animTweener:OnKill(function()
			-- 销毁动画对象
			if animObj and not isMoveEnd then
				destroy(animObj)
				animObj = nil
			end
		end)
	end
end


function poker_player_ui_base:ShowInteractinAnimation(viewSeat,content)
	Trace("ShowInteractinAnimation:"..viewSeat..","..content)

	local cfg = config_mgr.getConfig("cfg_interact",tonumber(content))

	if cfg == nil then
		logError("找不到互动表情", content)
		return
	end
	
	local fromPlayer = self.parentUI.playerList[viewSeat]
	if fromPlayer then
		local fromPos = fromPlayer.transform.localPosition
	    local head = child(fromPlayer.transform, "bg/head")
	    if head then
	    	-- 设置from相对坐标0
	    	local curPos = head.transform.localPosition
			fromPos.x = fromPos.x + curPos.x
			fromPos.y = fromPos.y + curPos.y
	    end
		-- 计算相对坐标
		local curPos = self.transform.localPosition
		fromPos = Vector3.New(fromPos.x-curPos.x, fromPos.y-curPos.y, 0)
		-- 播放动画
		self:playInteractiveExpressionAnimation(cfg, tonumber(content), fromPos, Vector3.zero)
	end

	-- 播放音效
	local sfxName = cfg.sound
	if sfxName then
		ui_sound_mgr.PlaySoundClip(data_center.GetAppConfDataTble().appPath.."/sound/specialFace/"..sfxName)
	end
end

-- 中途加入
function poker_player_ui_base:ShowHeadMask()
	if self.midJoin then
		return
	end
	self.midJoin = true
	if self.viewSeat == 1 then
		self.headTexture.color = Color.New(74/255, 74/255, 74/255, 1)
	else
		if self.headMask == nil then
			local go = newNormalObjSync(data_center.GetAppPath().."/ui/common/headMask", typeof(GameObject))
			self.headMask = newobject(go)
			self.headMask.transform:SetParent(self.transform, false)
		end
		self.headMask:SetActive(true)
	end
end

function poker_player_ui_base:HideHeadMask()
	if not self.midJoin then
		return
	end
	self.midJoin = false
	if self.viewSeat == 1 then
		self.headTexture.color = Color.New(1, 1, 1, 1)
	else
		if self.headMask == nil then
			return
		else
			self.headMask:SetActive(false)
		end
	end
end


function poker_player_ui_base:SetGratuityPlay(content)
	local fromPos = ParseJsonStr(content)
	coroutine.start(function()
		local effect1 = EffectMgr.PlayEffect(data_center.GetResPokerCommPath().."/effects/Effect_feixin",0.5)
		effect1.transform.localPosition = fromPos
		effect1.transform:SetParent(self.head.transform,true)
		Utils.SetEffectSortLayer(effect1.gameObject,self.sortingOrder + self.m_subPanelCount + 1)
		local animTweener = effect1.transform:DOLocalMove(Vector3.zero,0.5,true)
		animTweener:SetEase(DG.Tweening.Ease.Linear):OnComplete(function()
			local effect2 = EffectMgr.PlayEffect(data_center.GetResPokerCommPath().."/effects/Effect_wen",0.5)
			effect2.transform:SetParent(self.head.transform,false)
			Utils.SetEffectSortLayer(effect2.gameObject,self.sortingOrder + self.m_subPanelCount + 1)
		end)
	end)
end

return poker_player_ui_base