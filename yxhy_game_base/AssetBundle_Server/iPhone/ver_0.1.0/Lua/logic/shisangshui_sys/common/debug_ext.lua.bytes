import( "common.debug")
function LOG_ERROR(format, ...)
    local str = nil
    if #arg > 0  then
            str = string.format(format, unpack(arg))
    else
        str = format
    end
    local info = debug.getinfo(2)
    local src = info.short_src ..":" .. info.linedefined .. "  "


    echoError(src ..str)
end
function LOG_DEBUG(format, ...)
    local str = nil
    if #arg > 0  then
            str = string.format(format, unpack(arg))
    else
        str = format
    end
    local info = debug.getinfo(2)
    local src = info.short_src ..":" .. info.linedefined .. "  "
    echoDebug(src ..str)
end
