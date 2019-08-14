local base = require "logic/framework/ui/uibase/ui_view_base"
local ClubAdView = class("ClubAdView", base)

function ClubAdView:InitView()
	self.texture = self:GetComponent("Texture", typeof(UITexture))
end


return ClubAdView