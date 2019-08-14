-- Generated By protoc-gen-lua Do not Edit
local protobuf = require "protobuf/protobuf"


local DICINFOCONFIG = protobuf.Descriptor();
local DICINFOCONFIG_ID_FIELD = protobuf.FieldDescriptor();
local DICINFOCONFIG_INFO_FIELD = protobuf.FieldDescriptor();
local DICINFOCONFIG_TYPE_FIELD = protobuf.FieldDescriptor();
local DICINFOCONFIGARRAY = protobuf.Descriptor();
local DICINFOCONFIGARRAY_ITEMS_FIELD = protobuf.FieldDescriptor();

DICINFOCONFIG_ID_FIELD.name = "id"
DICINFOCONFIG_ID_FIELD.full_name = ".dataconfig.DicInfoConfig.id"
DICINFOCONFIG_ID_FIELD.number = 1
DICINFOCONFIG_ID_FIELD.index = 0
DICINFOCONFIG_ID_FIELD.label = 2
DICINFOCONFIG_ID_FIELD.has_default_value = true
DICINFOCONFIG_ID_FIELD.default_value = 0
DICINFOCONFIG_ID_FIELD.type = 5
DICINFOCONFIG_ID_FIELD.cpp_type = 1

DICINFOCONFIG_INFO_FIELD.name = "info"
DICINFOCONFIG_INFO_FIELD.full_name = ".dataconfig.DicInfoConfig.info"
DICINFOCONFIG_INFO_FIELD.number = 2
DICINFOCONFIG_INFO_FIELD.index = 1
DICINFOCONFIG_INFO_FIELD.label = 1
DICINFOCONFIG_INFO_FIELD.has_default_value = true
DICINFOCONFIG_INFO_FIELD.default_value = ""
DICINFOCONFIG_INFO_FIELD.type = 9
DICINFOCONFIG_INFO_FIELD.cpp_type = 9

DICINFOCONFIG_TYPE_FIELD.name = "type"
DICINFOCONFIG_TYPE_FIELD.full_name = ".dataconfig.DicInfoConfig.type"
DICINFOCONFIG_TYPE_FIELD.number = 3
DICINFOCONFIG_TYPE_FIELD.index = 2
DICINFOCONFIG_TYPE_FIELD.label = 1
DICINFOCONFIG_TYPE_FIELD.has_default_value = true
DICINFOCONFIG_TYPE_FIELD.default_value = 0
DICINFOCONFIG_TYPE_FIELD.type = 13
DICINFOCONFIG_TYPE_FIELD.cpp_type = 3

DICINFOCONFIG.name = "DicInfoConfig"
DICINFOCONFIG.full_name = ".dataconfig.DicInfoConfig"
DICINFOCONFIG.nested_types = {}
DICINFOCONFIG.enum_types = {}
DICINFOCONFIG.fields = {DICINFOCONFIG_ID_FIELD, DICINFOCONFIG_INFO_FIELD, DICINFOCONFIG_TYPE_FIELD}
DICINFOCONFIG.is_extendable = false
DICINFOCONFIG.extensions = {}
DICINFOCONFIGARRAY_ITEMS_FIELD.name = "items"
DICINFOCONFIGARRAY_ITEMS_FIELD.full_name = ".dataconfig.DicInfoConfigArray.items"
DICINFOCONFIGARRAY_ITEMS_FIELD.number = 1
DICINFOCONFIGARRAY_ITEMS_FIELD.index = 0
DICINFOCONFIGARRAY_ITEMS_FIELD.label = 3
DICINFOCONFIGARRAY_ITEMS_FIELD.has_default_value = false
DICINFOCONFIGARRAY_ITEMS_FIELD.default_value = {}
DICINFOCONFIGARRAY_ITEMS_FIELD.message_type = DICINFOCONFIG
DICINFOCONFIGARRAY_ITEMS_FIELD.type = 11
DICINFOCONFIGARRAY_ITEMS_FIELD.cpp_type = 10

DICINFOCONFIGARRAY.name = "DicInfoConfigArray"
DICINFOCONFIGARRAY.full_name = ".dataconfig.DicInfoConfigArray"
DICINFOCONFIGARRAY.nested_types = {}
DICINFOCONFIGARRAY.enum_types = {}
DICINFOCONFIGARRAY.fields = {DICINFOCONFIGARRAY_ITEMS_FIELD}
DICINFOCONFIGARRAY.is_extendable = false
DICINFOCONFIGARRAY.extensions = {}

DicInfoConfig = protobuf.Message(DICINFOCONFIG)
DicInfoConfigArray = protobuf.Message(DICINFOCONFIGARRAY)

--[[Another parser, for the memory reason, use plain table struct 
instead of protobuf table! Auto generated, do not edit!!]]
dicinfoconfig_x = {}
dicinfoconfig_x.__index = dicinfoconfig_x


--[[The class create method]]
function dicinfoconfig_x.New()
    local self = {}
    setmetatable(self, dicinfoconfig_x)
    self.items = {}
    return self
end


--[[The data parse method, input the protobuf data instance]]
function dicinfoconfig_x:ParseData(protobufData)
    for k, v in ipairs(protobufData.items) do 
        local item = {}
        item.id = v.id
        if v:HasField("info") then 
            item.info = v.info
        end
        if v:HasField("type") then 
            item.type = v.type
        end
        table.insert(self.items, item)
    end
end


--[[Get the protobuf instance]]
function dicinfoconfig_x:GetProtobuf()
    return DicInfoConfigArray()
end
