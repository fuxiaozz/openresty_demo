local _M = {}

local myRedis = require "redis.redis"
local lrucache = require "resty.lrucache"

local c = lrucache.new(20000)
local cc = lrucache.new(200)

_M._VERSION = '0.0.1'

local mt = { __index = _M }

function _M.new(self, params)
    local uri = params.uri
    if not uri then
        return nil, "params.uri is nil"
    end
    return setmetatable({uri = uri}, mt)
end

-- 计算appId,及代理uri
local function getAppIdAndProxyURI(_uri)

    if not _uri then
        return nil, nil, "_uri is null"
    end

    local appId = ""
    local proxy = ""
    local index = 1
    local secondIndex = string.find(_uri, "/", index + 1) or -1
    if secondIndex ~= -1 then
        proxy = string.sub(_uri, secondIndex + 1)
        secondIndex = secondIndex - 1
    end
    appId = string.sub(_uri, index + 1, secondIndex)
    return appId, proxy
end

function _M.getProxy(self)
    local _uri = self.uri
    local _conn = {}
    local appId = ""
    local proxy = ""

    ngx.log(ngx.ERR, "get proxy _uri : ", _uri)
    
    local _res = c:get(_uri)
    if not _res then
        appId, proxy, err = getAppIdAndProxyURI(_uri)
        if not appId then
            return nil, err
        end
        c:set(_uri, {appId = appId, proxy = proxy}, 60) -- 60 sec
    else
        ngx.log(ngx.ERR, "****** use uri cache *********")
        appId = _res.appId
        proxy = _res.proxy
    end

    -- 获取redis
    local _connect = cc:get(_uri)
    if not _connect then
        local red, err = myRedis:new({auth="123456"})
        local connectURI, err = red:hmget(appId, "connect")
        if not connectURI then
            return nil, err
        end
        cc:set(_uri, connectURI, 60) -- 60 sec
        table.insert(_conn, connectURI[1])
    else
        ngx.log(ngx.ERR, "**** use redis cache *********")
        table.insert(_conn, _connect[1])
    end
    table.insert(_conn, proxy)
    return table.concat(_conn, "/"), nil
end

return _M