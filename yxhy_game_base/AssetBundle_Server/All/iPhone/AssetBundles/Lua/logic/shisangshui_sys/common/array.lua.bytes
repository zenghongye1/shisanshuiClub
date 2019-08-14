Array = {}
function Array.Exist(tbArray, key)

    for _,v in ipairs(tbArray) do
        if v == key then return true end
    end
     return false
end

function Array.RemoveOne(tbArray, val)
    local len = #tbArray
    for i=1,len do
        if tbArray[i] == val then
            table.remove(tbArray, i)
            return true
        end
    end
    
    return false
end

-- arrA 是不是 arrB的子集
-- 即arrB是否包括arrA
function Array.IsSubSet(arrA, arrB)
    local arrASize = #arrA
    local arrBSize = #arrB
    if arrASize <= 0 then
        return true
    end
    if arrASize > arrBSize then
        return false
    end
    local arrCopy = Array.Clone(arrB)
    Array.DelElements(arrCopy, arrA)
    

    if #arrCopy == arrBSize - arrASize then
        return true
    end
    return false

end
function Array.Sort(arr)
    table.sort(arr)
    return arr
end
function Array.Clone(arr)
    local copy = {}
    for _,item in ipairs(arr) do
       table.insert(copy, item)
    end
    return copy
end
function Array.DelElements(arrSelf, arrDel)
    for _,del in ipairs(arrDel) do
        for i,val in ipairs(arrSelf) do
            if del == val then
                table.remove(arrSelf, i)
                break
            end
        end
    end
end

function Array.Reverse(arr)
     local size = #arr
    for i=1,size/2 do
        local val = arr[i]
        arr[i] = arr[size - i + 1]
        arr[size - i + 1] = val
    end
end

function Array.Add(arr1, arr2)
	for i = 1, #arr2 do
		table.insert(arr1, arr2[i])
	end
	return arr1
end

function Array.CardSort(cards, nspecial)
	--普通牌型排序
	if nspecial == nil then
		table.sort(cards, function(a,b)
			local valueA,colorA = GetCardValue(a), GetCardColor(a)
			local valueB,colorB = GetCardValue(b), GetCardColor(b)
			if valueA == valueB then
				return colorA < colorB
			else
				return valueA < valueB
			end
		end)
		return cards
	else 
		logError("特殊牌型客户端暂不作排序，由服务器排序")
	end
end