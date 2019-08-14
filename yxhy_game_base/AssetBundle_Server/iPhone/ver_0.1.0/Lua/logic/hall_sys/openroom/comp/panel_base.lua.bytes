--region *.lua
--Date
--此文件由[BabeLua]插件自动生成



--endregion
panel_base={}
 

panel_base.__index = panel_base 

function panel_base.New()
    local result = {
    ToggleTable={},
    selectIndex={1},
    title="",
    height=0,
    itemWidth=330,
    itemHeight=80,
    maxperLine=4,
    connect=0,
    }
	setmetatable(result,panel_base)
	return result
end

function panel_base:AddToggle(toggle)
    table.insert(self.ToggleTable,toggle)
    return self.ToggleTable
end

function panel_base:DeleteToggle(toggle)
    local p=0
    for i=1,#self.ToggleTable do
        if toggle.text==self.ToggleTable.text then
            p=i
        end 
    end
    table.remove(self.ToggleTable,p)
end

function panel_base:GetToggleSelect()
   local t={}
   for  i=1,#self.ToggleTable do
      if self.ToggleTable[i].toggle.value==true then
          t[self.ToggleTable[i].selectIndex]=1
      else
          t[self.ToggleTable[i].selectIndex]=0
      end 
   end
   return t
end

