local base = require "logic/framework/ui/uibase/ui_view_base"
local record_view_item = class("record_view_item",base)

function record_view_item:InitView()
	self.lab_index_lb = subComponentGet(self.transform, "index/Label","UILabel") -- 索引
    self.lab_clubName_lb = subComponentGet(self.transform, "clubName","UILabel") -- 俱乐部名字
	self.lab_date_lb = subComponentGet(self.transform, "time","UILabel") --日期
    self.lab_type_lb = subComponentGet(self.transform, "name","UILabel") --类型
    self.lab_des_lb = subComponentGet(self.transform, "des","UILabel") -- 人数局数
    self.lab_bnumber_lb = subComponentGet(self.transform, "score1","UILabel")
    self.lab_gnumber_lb = subComponentGet(self.transform, "score","UILabel")
end

function record_view_item:UpdateRecord(realindex,wraprecord)
	local rindext=realindex
	self.gameObject.name = rindext
    self.lab_index_lb.text=tostring(rindext)
    if wraprecord.ts~=nil then
        self.lab_date_lb.text ="".. os.date("%Y.%m.%d  %H:%M:%S",wraprecord.ts)
    end 
    if wraprecord.gid~=nil then
       self.lab_type_lb.text=""..GameUtil.GetGameName(tonumber(wraprecord.gid))
    end

    local cfg = wraprecord.cfg
    if cfg~=nil then
        if cfg.bsupportke and cfg.bsupportke == 1 then
            self.lab_des_lb.text = cfg.pnum.."人".."打课"
        else
            self.lab_des_lb.text = cfg.pnum.."人"..cfg.rounds.."局"
        end
    end

    if self.lab_clubName_lb then
		if wraprecord.ctype == 1 then
			self.lab_clubName_lb.text = "大厅"
		else
			self.lab_clubName_lb.text = wraprecord.cname or ""
		end
        
    end

    if wraprecord.all_score~=nil  then
        if  tonumber(wraprecord.all_score) >=0  then
            self.lab_bnumber_lb.gameObject:SetActive(false)  
            self.lab_gnumber_lb.gameObject:SetActive(true)
            self.lab_gnumber_lb.text="+"..wraprecord.all_score
        else 
            self.lab_gnumber_lb.gameObject:SetActive(false)
            self.lab_bnumber_lb.gameObject:SetActive(true)
            self.lab_bnumber_lb.text=wraprecord.all_score 
        end
    end

end

return record_view_item