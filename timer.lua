local set_timer_timeout = _G.set_timer_timeout
local pool = require 'timer.pool'
local get_current_microseconds = require'timer.utils'.get_current_microseconds
local pack = table.pack or _G.pack
local unpack = table.unpack or _G.unpack

-- singleton pattern
local M = {lastId = 0, pool = pool.new()}

_G.callback.timer:register(function() M.pool:execute() end)

function M._set_timer(callback, microseconds, is_interval, ...)
    local time = microseconds * 1000
    local args = pack(...)
    local current_time = get_current_microseconds()
    local time_execution = current_time + time
    local lastId = M.lastId
    M.pool:insert({
        time_execution = time_execution,
        callback = function() callback(unpack(args)) end,
        id = lastId,
        is_interval = is_interval,
        interval = time
    })

    -- set callback
    local min = M.pool:get_next()
    if min then set_timer_timeout(min - current_time) end

    M.lastId = lastId + 1
    return lastId
end

function M.clear_timeout(id)
    local current_time = get_current_microseconds()
    local min = M.pool:get_next()
    if min then set_timer_timeout(min - current_time) end -- FIXME: not needed?
    return M.pool:remove(id)
end

function M.update(id, microseconds)
    local time = microseconds * 1000
    local current_time = get_current_microseconds()
    local time_execution = current_time + time
    M.pool:update(id, time_execution)

    local min = M.pool:get_next()
    if min then set_timer_timeout(min - current_time) end
end

function M.set_timeout(callback, time, ...)
    return M._set_timer(callback, time, false, ...)
end

function M.set_interval(callback, time, ...)
    return M._set_timer(callback, time, true, ...)
end

function M.debounce(callback, time, ...)
    local pending = false
    local id = nil
    local args = pack(...)

    local function do_callback_and_release()
        callback(unpack(args))
        pending = false
    end

    local function debounced()
        if pending then
            M.update(id, time)
        else
            pending = true
            id = M.set_timeout(do_callback_and_release, time)
        end
    end

    return debounced
end

function M.debug()
    print '\nDEBUG:\n'
    print(M.lastId)
    for num, value in ipairs(M.pool) do print(num, value) end
    print '\n'
end

return M
