local utime, set_timer_timeout = _G.utime, _G.set_timer_timeout

-- Returns how many miliseconds have passed since UNIX epoch
local function get_current_microseconds()
    local epoch, usecs = utime()
    return epoch * 1000000 + usecs
end

--------------------------------------------------------

local pool = {}
local pool_mt = {__index = pool}

function pool.new()
    local instance = {}
    return setmetatable(instance, pool_mt)
end

function pool:insert(element) table.insert(self, element) end

function pool:remove(id)
    for num, value in ipairs(self) do
        if value.id == id then
            local element = table.remove(self, num)
            return element
        end
    end
end

function pool:update(id, time_execution)
    for _, value in ipairs(self) do
        if value.id == id then
            value.time_execution = time_execution
            return id
        end
    end
end

function pool:get_next()
    local min = nil
    for _, value in ipairs(self) do
        local time = value.time_execution
        min = min and math.min(min, time) or time
    end

    return min
end

function pool:execute()
    local time = get_current_microseconds()

    for _, value in ipairs(self) do
        local time_execution = value.time_execution

        if time >= time_execution then
            value.callback()
            if value.is_interval then
                value.time_execution = value.time_execution + value.interval
            else
                self:remove(value.id)
            end
        end
    end

    local min = self:get_next()
    if min then set_timer_timeout(min - time) end
end

--------------------------------------------------------

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
