--[[--
 * @Description: 网页webview相关代码 
 * @Author:      huangxupeng
 * @FileName:    webview.lua
 * @DateTime:    --
 ]]
webview={}
local this=webview 
--endregion
local wleft=180
local wright=180
local wbottom=30
local wtop=180

-------初始化页面-------------------
function this.InitWeb(url)
    local webpage=SingleWeb.Instance:InitWebPage(url)  
    this.InitSize(webpage,wtop,wleft,wbottom,wright)
    return webpage
end

function this.SetSize(top,left,bottom,right)
    wleft=left
    wtop=top
    wright=right
    wbottom=bottom
end

function this.InitSize(webpage,top,bottom,left,right)
    local t=top or 0
    local l=left or 0
    local b=bottom or 0 
    local r=right or 0
    webpage:SetSize(top,bottom,left,right)  
end

function this.InitwithSize(url,top,bottom,left,right)
   local webpage= SingleWeb.Instance:InitWebPage(url,top,bottom,left,right)
  -- this.InitSize(webpage,top,bottom,left,right)
   return webpage
end



-------------------页面API调用--------------------
function this.ShowBywebpage(webpage) 
    webpage:Show()
    return webpage
end

function this.ShowByUrl(url)
   local webpage=SingleWeb.Instance:GetDicObj(url)
   this.ShowBywebpage(webpage) 
   return webpage
end



function this.HideBywebpage(webpage)
    webpage:Hide() 
end

function this.HideByUrl(url)
    local webpage=SingleWeb.Instance:GetDicObj(url)
    this.HideBywebpage(webpage)
end

function this.RunJSFunction(webpage,name)
    local strfunction="function concatme(){"..name.."(); }"
    local strrun="concatme()"
    webpage:RunJavaScript(strfunction,strrun) 
end

function this.RunJSFunctionByurl(url,name)
    local webpage=SingleWeb.Instance:GetDicObj(url) 
    this.RunJSFunction(webpage,name)
end



-------------页面委托事件添加-------------------
function this.AddCompleteFunction(webview,f)
   webview.complete=function (webView,success,errorMessage) 
      f(webView,success,errorMessage)
   end
end
function this.AddCompleteFunctionByurl(url,f)
   local webview=SingleWeb.Instance:GetDicObj(url) 
   this.AddCompleteFunction(webview,f)
end

function this.AddReceiveFunction(webview,f)
   webview.receive=function(webView,message)
      f(webView,message)
   end
end
function this.AddReceiveFunctionByurl(url,f)
   local webview=SingleWeb.Instance:GetDicObj(url) 
   this.AddReceiveFunction(webview,f)
end
