local _proxy = require "proxy"

local temp_proxy, err = _proxy:new({uri = "/hk.cn.com.crv.ydsd/api"})
if not temp_proxy then
    print(err)
    return
end

local appId, proxyURI = temp_proxy:getAppIdAndProxyURI()
print("appId: " .. appId .. " ,proxyURI: " .. proxyURI)
