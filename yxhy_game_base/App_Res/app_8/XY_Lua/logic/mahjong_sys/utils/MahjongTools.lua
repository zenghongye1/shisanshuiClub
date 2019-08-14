--[[--
 * @Description: 麻将工具类
 * @Author:      ShushingWong
 * @FileName:    MahjongTools.lua
 * @DateTime:    2017-06-20 15:28:23
 ]]


MahjongTools = {}
this = MahjongTools

--[[--
 * @Description: 后台麻将数值 
 * 1-9      万
 * 11-19    条
 * 21-29    筒
 * 31-37    东南西北中发白
 * 41-48    季节、花   
 ]]

--[[--
 * @Description: mesh 下标 
 * 1-9      条
 * 10-18    万
 * 19       骰子
 * 20-28    筒
 * 29       空白
 * 30-32    发中白
 * 33-36    花
 * 37-40    季节
 * 41-44    东南西北
 ]]



--[[--
 * @Description: 牌值转mesh下标  
 ]]
function this.MahjongValueToMeshIndex(value)
    if (value >= 1 and value < 10) then --万
        return value + 9;
    elseif (value >= 11 and value < 20) then --条
        return value - 10;
    elseif (value >= 21 and value < 30) then --筒
        return value - 1;
    elseif (value >= 31 and value < 35) then --东南西北
        if value == 32 then
           value = value + 1
        elseif value == 33 then
            value = value + 1
        elseif value == 34 then
            value = value - 2
        end
        return value + 10;
    elseif (value >= 35 and value < 38) then --发中白
        if value == 35 then
           value = value + 1
        elseif value == 36 then
            value = value - 1
        end
        return value - 5;
    elseif (value >= 41 and value < 45) then --季节
        return value - 4;
    elseif (value >= 45 and value < 49) then --花
        return value - 12;
    end

    return 0;
end

local mahjongValueList = {}

local function InitTestMahjong()

    for i = 1,9,1 do 
        table.insert(mahjongValueList,i)
    end
    for i = 11,19,1 do 
        table.insert(mahjongValueList,i)
    end
    for i = 21,29,1 do 
        table.insert(mahjongValueList,i)
    end
    for i = 31,37,1 do 
        table.insert(mahjongValueList,i)
    end
end

InitTestMahjong()


--[[--
 * @Description: 获得一个随机的牌值   
 ]]
function this.GetRandomCard()
    return mahjongValueList[math.random(1, #mahjongValueList)]
end

--[[--
 * @Description: 得到座位信息描述
 * @param:       sPlayer 自己视图座位  oPlayer 别人视图座位
 * @return:      位置描述，本家\下家\对家\上家  
 ]]
function this.GetPosDes(sPlayer,oPlayer)
    local offset = oPlayer - sPlayer
    if offset<0 then
        offset = offset + 4
    end
    local str = ""
    if offset == 0 then
        str = "本家"
        elseif offset == 1 then
            str = "下家"
            elseif offset == 2 then
                str = "对家"
                elseif offset == 3 then
                    str = "上家"
                end
                return str 
end

function this.NumberToChinese(num)
    local hzNum = {"一", "二", "三", "四", "五", "六", "七", "八", "九"}
    if num >0 and num<10 then
        return hzNum[num]
    end
    return ""
end

--文字转换  
function  this.NumberToString(szNum)  
    local szChMoney = ""  
    local szNum = 0  
    local iLen = 0  
    local iNum = 0  
    local iAddZero = 0  
    --local hzUnit = {"", "拾", "佰", "仟", "万", "拾", "佰", "仟", "亿", "拾", "佰", "仟", "万", "拾", "佰", "仟"}  
    --local hzNum = {"零", "壹", "贰", "叁", "肆", "伍", "陆", "柒", "捌", "玖"}  
    local hzUnit = {"", "十", "百", "千", "万", "十", "百", "千", "亿", "十", "百", "千", "万", "十", "百", "千"}  
    local hzNum = {"零", "一", "二", "三", "四", "五", "六", "七", "八", "九"} 
  
  if nil == tonumber(szNum) then  
    --return '错误的数字'  
    return ''
  end  
    
  iLen =string.len(szNum)   
  
   if iLen > 15 or iLen == 0 or tonumber(szNum) < 0 then  
      --return "错误的数字" 
      return ''  
    end  
  local i = 0  
  for i = 1, iLen  do   
    iNum = string.sub(szNum,i,i)  
    if iNum == 0 then  
      iAddZero = iAddZero + 1  
    else  
      if iAddZero > 0 then  
        szChMoney = szChMoney..hzNum[1]    
      end  
  
      szChMoney = szChMoney..hzNum[iNum + 1] --//转换为相应的数字  
      iAddZero = 0  
  
    end  
  
    if iNum ~=0 or iLen-i==3 or iLen-i==11 or ((iLen-i+1)%8==0 and iAddZero<4) then  
      szChMoney = szChMoney..hzUnit[iLen-i+1]  
    end  
  
  end  
  
  return szChMoney  
  
end  