local mode_comp_base = require "logic/mahjong_sys/components/base/mode_comp_base"
local comp_mjResMgr = class ("comp_mjResMgr", mode_comp_base)


function comp_mjResMgr:ctor()
	self.name = "comp_resMgr"

    self.mjMeshs = {} --麻将mesh列表
    self.outCardEfObj = nil -- 出牌标志
    self.highLightMat = nil -- 高亮材质

    self.mjItemPool = {} --麻将子克隆池

    self:LoadMJMesh()
    self:InitOutCardEfObj()
    self:LoadHighLightMat()
end

 --[[--
 * @Description: 加载麻将网格  
 ]]
function comp_mjResMgr:LoadMJMesh()
	local resMJMeshObj = newNormalObjSync(mahjong_path_mgr.GetMjPath("mahjongtiles"), typeof(GameObject))
    local meshFilters = resMJMeshObj:GetComponentsInChildren(typeof(UnityEngine.MeshFilter))
    for i = 0,meshFilters.Length-1,1 do
        table.insert(self.mjMeshs, meshFilters[i].sharedMesh)
    end
end

 --[[--
 * @Description: 初始化出牌标志
 ]]
function comp_mjResMgr:InitOutCardEfObj()
  	local outCardEfRes = newNormalObjSync(mahjong_path_mgr.GetMjPath("jiantou"), typeof(GameObject))
    self.outCardEfObj = newobject(outCardEfRes)     
end

--[[--
 * @Description: 加载高亮材质  
 ]]
function comp_mjResMgr:LoadHighLightMat()
    self.highLightMat = newNormalObjSync(mahjong_path_mgr.GetMaterialPath("mahjongtilespecular_new_blue"), typeof(UnityEngine.Material))
end

--[[--
 * @Description: 获取麻将mesh  
 ]]
function comp_mjResMgr:GetMahjongMesh(index)
	local mesh = self.mjMeshs[index]
	if mesh == nil then
		Trace("GetMahjongMesh !!!!!!!!!!!!!!!!!!!!!!!!!! error !!!!!!!!! index"..index)
	end
    return mesh
end

function comp_mjResMgr:GetOutCardEfObj()
    return self.outCardEfObj
end

--[[--
 * @Description: 设置出牌标志  
 ]]
function comp_mjResMgr:SetOutCardEfObj(pos)
    self.outCardEfObj.transform.position = pos
end

--[[--
 * @Description: 隐藏出牌标志  
 ]]
function comp_mjResMgr:HideOutCardEfObj()
    self.outCardEfObj.transform.position = self.outCardEfObj.transform.position + Vector3(0,-1,0)
end

--[[--
 * @Description: 获取高亮材质  
 ]]
function comp_mjResMgr:GetHighLightMat()
    return self.highLightMat
end

--[[--
 * @Description: 创建一个麻将子克隆  
 ]]
function comp_mjResMgr:CeateMJItem(original)
    local mj
    if #self.mjItemPool >0 then
        mj = self.mjItemPool[#self.mjItemPool]
        table.remove(self.mjItemPool,#self.mjItemPool)
    else
        mj = comp_mjItem.create()
    end
    if original~=nil then
        mj.transform.position = original.transform.position
        mj.transform.eulerAngles = original.transform.eulerAngles
        mj:SetMesh(original.paiValue)
        RecursiveSetLayerVal(mj.transform,original.mjModelObj.layer)
    end
    mj.mjObj:SetActive(true)
    return mj
end

--[[--
 * @Description: 销毁一个麻将子克隆  
 ]]
function comp_mjResMgr:DestroyMJItem(mj)
    mj.mjObj:SetActive(false)
    table.insert(self.mjItemPool,mj)
end

function comp_mjResMgr:Uninitialize()
	mode_comp_base.Uninitialize(self)
    if not IsNil(self.outCardEfObj) then
        GameObject.DestroyImmediate(self.outCardEfObj)
    end
    for i,v in ipairs(self.mjItemPool) do
        if v~=nil then
            v:Uninitialize()
        end
    end
end

return comp_mjResMgr