local resty_sha1 = require "resty.sha1"

local sha1 = resty_sha1:new()
if not sha1 then
    ngx.say("failed to create the sha1 object")
    return
end

local ok = sha1:update('hello, ')
if not ok then
    ngx.say('failed to add update')
    return
end

ok = sha1:update("world")
if not ok then
    ngx.say('failed to add data')
    return
end

local digest = sha1:final()

ngx.say(digest)

local str = require "resty.string"

ngx.say("sha1: ", str.to_hex(digest))

local resty_md5 = require 'resty.md5'
local md5 = resty_md5:new()
if not md5 then
    ngx.say('faild to create md5 object')
    return
end

local ok = md5:update("hel")
if not ok then
    ngx.say("faild to add data")
    return
end

ok = md5:update("lo")
if not ok then
    ngx.say("faild to add data")
    return
end

local digest = md5:final()
local str = require "resty.string"

ngx.say("md5: ", str.to_hex(digest))

