local _M = {}

function _M.toStringByTable(tab)
    local _str = ""
    if tab then
        for k, v in pairs(tab) do
            _str = _str .. k .. "="
            if type(v) == "function" then
                _str = _str .. v()
            else
                _str = _str .. v
            end
            _str = _str .. "&"
        end
    end
    if _str == "" then
        return _str
    else
        return string.sub(_str, 1, string.len(_str) - 1)
    end
end

return _M