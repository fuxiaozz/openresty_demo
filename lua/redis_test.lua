local redis = require('redis')

local red = redis:new()

red:set_timeout(1000) -- 1 sec

local ok, err = red:connect("127.0.0.1", 6379)

if not ok then
    ngx.say("failed to connect:", err)
    return
end

ok, err = red:set('dog', 'an animal')

if not ok then
    ngx.say('failed to set dog: ', err)
end

ngx.say('set result:', ok)

local res, err = red:get('dog')

if not res then
    ngx.say('failed to get dog:', err)
    return
end

if res == ngx.null then
    ngx.say('dog not found')
    return
end

ngx.say("dog:", res)

red:init_pipeline()
red:set('cat', 'Maarry')
red:set('horse', 'Bob')
red:get('cat')
red:get('horse')

local result, err = red:commit_pipeline()
if not result then
    ngx.say("failed to commit the pipelined result: ", err)
    return
end

for k, v in pairs(result) do
    if type(v) == "table" then
        if v[1] == false then
            ngx.say("failed to run commad ", k, " : ", v[2])
        else

        end
    else

    end
end

local ok, err = red:set_keepalive(10000, 100)
if not ok then
    ngx.say("failed to set keepalive:", err)
    return
end
