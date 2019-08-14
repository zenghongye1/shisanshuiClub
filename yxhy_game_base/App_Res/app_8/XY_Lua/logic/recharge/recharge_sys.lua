require "logic/recharge/rechargeConfig"
recharge_sys = {}
local this = recharge_sys
-- "stype":支付平台类型(1微信2支付宝3爱贝4UC5腾讯6笨手机8百度),

function this.requestIAppPayOrder( stype,pid,num )
  if not stype or not pid then return end

  http_request_interface.GetPayOrder(stype,pid,num,function ( code,m,str )
    local s=string.gsub(str,"\\/","/")  
        local t=ParseJsonStr(s)
        Trace("requestIAppPayOrder  callback ==".. s);
        if t.ret == 0 then -- 下单成功
          if stype == rechargeConfig.IAppPay then
            if t.transid then
              YX_APIManage.Instance:startIAppPay(tostring(t.transid),function ( msg )
                Trace("requestIAppPayOrder  callback success startIAppPay  " ..  msg);
                --{"ret":0,"account":{"uid":5647672,"diamond":0,"card":100000,"coin":5000000,"vip":0,"safecoin":0,"bankrupt":0,"bankruptc":0,"feewin":0,"feelose":0}}
                http_request_interface.getAccount("",function ( code,m,str )
                    local s=string.gsub(str,"\\/","/")
                    Trace("getAccount callback =="..s)
                    local t=ParseJsonStr(s)
                    if t.ret == 0 then
                      -- 刷新当前携带货币数量


                    end
                  end)
                local msgT=ParseJsonStr(msg)
                if msgT.result == 0 then
                  
                else

                end

              end)
            end

          end

                    
        else

        end
  end)
end