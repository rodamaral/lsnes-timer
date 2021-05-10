local set_timer_timeout = _G.set_timer_timeout
local pool = require 'timer.pool'
local get_current_microseconds = require'timer.utils'.get_current_microseconds

local M = {}
local M_mt = {__index = M}

-- singleton pattern
function M.get_instance()
    if M._instance then return M._instance end

    local instance = {}
    setmetatable(instance, M_mt)
    instance.lastId = 0
    instance.pool = pool.new()

    _G.callback.timer:register(function() instance.pool:execute() end)

    M._instance = instance
    return instance
end

function M:set_timeout(callback, microseconds, is_interval)
    local time = microseconds * 1000
    local current_time = get_current_microseconds()
    local time_execution = current_time + time
    local lastId = self.lastId
    self.pool:insert({
        time_execution = time_execution,
        callback = callback,
        id = lastId,
        is_interval = is_interval,
        interval = time
    })

    -- set callback
    local min = self.pool:get_next()
    if min then set_timer_timeout(min - current_time) end

    self.lastId = lastId + 1
    return lastId
end

function M:clear_timeout(id)
    local current_time = get_current_microseconds()
    local min = self.pool:get_next()
    if min then set_timer_timeout(min - current_time) end -- FIXME: not needed?
    return self.pool:remove(id)
end

function M:update(id, microseconds)
    local time = microseconds * 1000
    local current_time = get_current_microseconds()
    local time_execution = current_time + time
    self.pool:update(id, time_execution)

    local min = self.pool:get_next()
    if min then set_timer_timeout(min - current_time) end
end

function M:set_interval(callback, time)
    return self:set_timeout(callback, time, true)
end

function M:get_debounced(callback, time)
    local pending = false
    local id = nil

    local function do_callback_and_release()
        callback()
        pending = false
    end

    local function debounced()
        if pending then
            self:update(id, time)
        else
            pending = true
            id = self:set_timeout(do_callback_and_release, time)
        end
    end

    return debounced
end

function M.debounce(callback, time)
    local timer = M.get_instance()
    return timer:get_debounced(callback, time)
end

function M:debug()
    print '\nDEBUG:\n'
    print(self.lastId)
    for num, value in ipairs(self.pool) do print(num, value) end
    print '\n'
end

return M
