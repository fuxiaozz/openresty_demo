local myProxy = require "proxy.proxy"
local stringTools = require "tools.string_tools"

local requestURL = ngx.var.document_uri
local proxy, err = myProxy:new({uri = requestURL})

if not proxy then
    ngx.status = 404
    ngx.say("no proxy")
    return
end

local connURI, err = proxy:getProxy()
if not connURI and not proxyURI then
    ngx.status = 404
    ngx.say(err)
    return
end

ngx.log(ngx.ERR, "connURI = ", connURI)

local http = require "resty.http"
local stringTools = require "tools.string_tools"

local _headers = ngx.req.get_headers() or {}
local _method = ngx.var.request_method
local _get_args_str = stringTools.toStringByTable(ngx.req.get_uri_args())
local _post_args_str = ""

if _method == "POST" then
    local _body = {}
    ngx.req.read_body()
    local post_args, err = ngx.req.get_post_args()
    if post_args then
        for k, v in pairs(post_args) do
            _body[k] = v
        end
    end
    _post_args_str = stringTools.toStringByTable(_body)
end

ngx.log(ngx.ERR, "method = ", _method)
ngx.log(ngx.ERR, "post param = ", _post_args_str)
ngx.log(ngx.ERR, "get param = ", _get_args_str)


local httpc = http.new()
httpc:set_timeout(10000) -- 10 sec

local res, err = httpc:request_uri(connURI, {
        method = _method,
        body = _post_args_str,
        query = _get_args_str,
        headers = _headers
})
httpc:set_keepalive(10000, 100) -- 10 sec 100 pool size

if not res then
    ngx.status = 502
    ngx.say(err)
    return
end

ngx.status = 200
for k, v in pairs(res.headers) do
    ngx.header[k] = v;
end
ngx.say(res.body)

