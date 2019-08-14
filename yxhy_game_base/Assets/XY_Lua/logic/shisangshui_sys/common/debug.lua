--[[


]]
local _assert = assert
DEBUG = 1

DEUBG_LOG_FILE_NAME="debug_lua.log"
DEUBG_LOG_FILE_REF=nil
io.output():setvbuf('no')

function __G__TRACKBACK__(errorMessage)

    print("----------------------------------------")
    print("LUA ERROR: " .. tostring(errorMessage) .. "\n")
    print(debug.traceback("", 3))
    print("----------------------------------------")


end
--_G[__G__TRACKBACK__] = __G__TRACKBACK__

function assert(v,message)
    if DEBUG <= 0 then return end
   _assert(v,message)
end

function echoToLogFile(content)
    local mode = mode or "w+b"
    if DEUBG_LOG_FILE_REF == nil then
        DEUBG_LOG_FILE_REF = io.open(DEUBG_LOG_FILE_NAME, mode)
    end


    local file = DEUBG_LOG_FILE_REF
    if file then
        if file:write(content) == nil then
            return false
        end
        file:flush()
        return true
    else
        return false
    end
end
function echo(...)
    local arr = {}
    for i, a in ipairs({...}) do
        arr[#arr + 1] = tostring(a)
    end
    --LuaLog(table.concat(arr, "\t"))
    print(table.concat(arr, "\t"))

   -- arr[#arr + 1] = tostring("\n")
    --echoToLogFile(table.concat(arr, "\t"))
end

--print = echo

function printf(fmt, ...)
    echo(string.format(tostring(fmt), ...))
end

function echoDebug(...)
    if DEBUG > 0 then echo(...) end
end
--[[

]]
function echoError(fmt, ...)
    if fmt == nil then
        echo( debug.traceback("", 2) )
        return
    end
    echo(string.format("[ERR] %s%s", string.format(tostring(fmt), ...), debug.traceback("", 2)))
    --os.exit(0)
end

function echoInfo(fmt, ...)
    echo("[INFO] " .. string.format(tostring(fmt), ...))
end

function echoLog(tag, fmt, ...)
    echo(string.format("[%s] %s", string.upper(tostring(tag)), string.format(tostring(fmt), ...)))
end

function dump(object, label, isReturnContents, nesting)
    if type(nesting) ~= "number" then nesting = 99 end

    local lookupTable = {}
    local result = {}

    local function _v(v)
        if type(v) == "string" then
            v = "\"" .. v .. "\""
        end
        return tostring(v)
    end

    local traceback = string.split(debug.traceback("", 2), "\n")
    echo("dump from: " .. string.trim(traceback[3]))

    local function _dump(object, label, indent, nest, keylen)
        label = label or "<var>"
        spc = ""
        if type(keylen) == "number" then
            spc = string.rep(" ", keylen - string.len(_v(label)))
        end
        if type(object) ~= "table" then
            result[#result +1 ] = string.format("%s%s%s = %s", indent, _v(label), spc, _v(object))
        elseif lookupTable[object] then
            result[#result +1 ] = string.format("%s%s%s = *REF*", indent, label, spc)
        else
            lookupTable[object] = true
            if nest > nesting then
                result[#result +1 ] = string.format("%s%s = *MAX NESTING*", indent, label)
            else
                result[#result +1 ] = string.format("%s%s = {", indent, _v(label))
                local indent2 = indent.."    "
                local keys = {}
                local keylen = 0
                local values = {}
                for k, v in pairs(object) do
                    keys[#keys + 1] = k
                    local vk = _v(k)
                    local vkl = string.len(vk)
                    if vkl > keylen then keylen = vkl end
                    values[k] = v
                end
                table.sort(keys, function(a, b)
                    if type(a) == "number" and type(b) == "number" then
                        return a < b
                    else
                        return tostring(a) < tostring(b)
                    end
                end)
                for i, k in ipairs(keys) do
                    _dump(values[k], k, indent2, nest + 1, keylen)
                end
                result[#result +1] = string.format("%s}", indent)
            end
        end
    end
    _dump(object, label, "- ", 1)

    if isReturnContents then
        return table.concat(result, "\n")
    end

    for i, line in ipairs(result) do
        echo(line)
    end
end

function vardump(object, label)
    local lookupTable = {}
    local result = {}

    local function _v(v)
        if type(v) == "string" then
            v = "\"" .. v .. "\""
        end
        return tostring(v)
    end

    local function _vardump(object, label, indent, nest)
        label = label or "<var>"
        local postfix = ""
        if nest > 1 then postfix = "," end
        if type(object) ~= "table" then
            if type(label) == "string" then
                result[#result +1] = string.format("%s%s = %s%s", indent, label, _v(object), postfix)
            else
                result[#result +1] = string.format("%s%s%s", indent, _v(object), postfix)
            end
        --elseif not lookupTable[object] then
         --   lookupTable[object] = true
        else
            if type(label) == "string" then
                result[#result +1 ] = string.format("%s%s = {", indent, label)
            else
                result[#result +1 ] = string.format("%s{", indent)
            end
            local indent2 = indent .. "    "
            local keys = {}
            local values = {}
            for k, v in pairs(object) do
                keys[#keys + 1] = k
                values[k] = v
            end
            -- table.sort(keys, function(a, b)
            --     if type(a) == "number" and type(b) == "number" then
            --         return a < b
            --     else
            --         return tostring(a) < tostring(b)
            --     end
            -- end)
            for i, k in ipairs(keys) do
                _vardump(values[k], k, indent2, nest + 1)
            end
            result[#result +1] = string.format("%s}%s", indent, postfix)
        end
    end
    _vardump(object, label, "", 1)

    return table.concat(result, "\n")
end
