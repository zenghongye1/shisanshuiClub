resMgr_component = {}


function resMgr_component.create()
	require "logic/shisangshui_sys/mode_comp_base"
	local this = mode_comp_base.create()
	this.Class = resMgr_component
	this.name = "resMgr_component"
		
	this.cardMeshs = {}	
	
	local highLightMat = {} 
	local originalMat = {}
	this.base_init = this.Initialize
	function this:Initialize()
		this.base_init()
	end
	
	this.base_unInit = this.Uninitialize	
	function this:Uninitialize()
		this.base_unInit()
		highLightMat = {}
		originalMat = {}
		this.cardMeshs = {}
	end

	--[[function this.LoadCardMesh()
		this.cardMeshs = {}
		local resCardMeshObj = newNormalObjSync(data_center.GetResRootPath().."/scene/poker",typeof(UnityEngine.GameObject))
		local meshFilters = resCardMeshObj:GetComponentsInChildren(typeof(UnityEngine.MeshFilter))
		for i = 0, meshFilters.Length - 1,1 do
			table.insert(this.cardMeshs,meshFilters[i].sharedMesh)		
		end
	end--]]
		
--[[	function this.GetCardMesh(index)
		local mesh = this.cardMeshs[index+1]
		if mesh == nil then
			Trace("GetCardMesh !!!!!!!!!!!!!!!!!!!!!!!!!! error !!!!!!!!! index"..index)
		end
		return mesh
	end	--]]	
	
    --[[--
     * @Description: 加载高亮材质  
     ]]
    local function LoadHighLightMat()
        highLightMat.mat1 = newNormalObjSync(data_center.GetResRootPath().."/meterials/poker_highlight", typeof(UnityEngine.Material))
        highLightMat.mat2 = newNormalObjSync(data_center.GetResRootPath().."/meterials/jinse_fireb", typeof(UnityEngine.Material))
		originalMat.mat1 = newNormalObjSync(data_center.GetResPokerCommPath().."/Materials/dipai",typeof(UnityEngine.Material))
    end
	
	

    --[[--
     * @Description: 获取高亮材质  
     ]]
    function this.GetHighLightMat()
        return highLightMat
    end
	
	function this.GetOriginalMat()
		return originalMat
	end


	Trace("----------------------LoadCardMesh")
 	--LoadCardMesh()
 	LoadHighLightMat()
	return this
	
end