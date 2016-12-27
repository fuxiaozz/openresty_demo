local _M = {}

function _M.is_number (...)
    local args = {...}
    local num
    for _, v in pairs(args) do
        num = tonumber(v)
        if nil == num then
            return false
        end
    end
    return true
end

return _M