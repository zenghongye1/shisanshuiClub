local base = require "logic.mahjong_sys.action.common.mahjong_action_base"
local mahjong_mjAction_gameStart = class("mahjong_mjAction_gameStart", base)
local offsetMap = 
{
    Vector3(0,0, -0.5),
    Vector3(0.5, 0, 0),
    Vector3(0,0, 0.5),
    Vector3(-0.5, 0, 0),
}
local yOffset = -0.5

function mahjong_mjAction_gameStart:Execute(tbl)
	local neetTing = tbl._para.bIsNeedTing
    mahjong_client_ting_mgr:SetClientTing(neetTing == 0)
    mahjong_anim_state_control.Reset()
    mahjong_anim_state_control.ShowAnimState(MahjongGameAnimState.start, function()
        --mahjong_ui:HideStartFee()
        if comp_show_base.isInit == false then
            comp_show_base:InitForReady()
            comp_show_base.isInit = true
        end
        if self.cfg.isShowWall then
            self:ShowWall()
        else
            self:DontShowWall()
        end
    end, true)
end

function mahjong_mjAction_gameStart:ShowWall()
    for i = 1, 3 do
        self:DoSequenceMove(self.compTable.mjWallRootTrList[i], offsetMap[i])
    end
    self:DoSequenceMove(self.compTable.mjWallRootTrList[4], offsetMap[4], 
        function ()
        self:OnShowWall()
    end, function ()
       self:OnShowEnd()
    end)
end

function mahjong_mjAction_gameStart:DontShowWall()
    self:OnShowWall()
    self:OnShowEnd()
end

function mahjong_mjAction_gameStart:OnShowWall()
    self.compTable:ShowWallInternal(nil, function (mj)
        if self.cfg.isShowWall then
            mj:Show(false)
            mj:ShowShadow()
        end
        mj:SetState(MahjongItemState.inWall)
     end)
end

function mahjong_mjAction_gameStart:OnShowEnd()
    Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_GAMESTART)
end


function mahjong_mjAction_gameStart:DoSequenceMove(transform, offset, downCallback, endCallback)
    local duration = 0.2
    local seq = DG.Tweening.DOTween.Sequence()
    local pos = transform.localPosition 
    pos.y = pos.y + yOffset
    seq:Append(transform:DOLocalMoveY(pos.y, duration * self:AnimSpd(), false))
    seq:AppendInterval(duration * self:AnimSpd())
    pos = pos + offset
    seq:Append(transform:DOLocalMove(pos, 0.1 * self:AnimSpd(), false))
    if downCallback ~= nil then
        seq:AppendCallback(downCallback)
    end
    seq:AppendInterval(0.1 * self:AnimSpd())
    pos = pos - offset
    seq:Append(transform:DOLocalMove(pos, 0.1 * self:AnimSpd(), false))
    seq:AppendInterval(0.1 * self:AnimSpd())
    pos.y = pos.y - yOffset
    seq:Append(transform:DOLocalMoveY(pos.y, 0.3 * self:AnimSpd(), false))
    seq:AppendInterval(0.3 * self:AnimSpd())
    if endCallback ~= nil then
        seq:OnComplete(endCallback)
    end
end

return mahjong_mjAction_gameStart