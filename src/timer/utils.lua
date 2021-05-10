local utime = _G.utime
local M = {}

-- Returns how many miliseconds have passed since UNIX epoch
function M.get_current_microseconds()
    local epoch, usecs = utime()
    return epoch * 1000000 + usecs
end

return M
