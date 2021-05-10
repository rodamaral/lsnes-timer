local set_timer_timeout = _G.set_timer_timeout
local get_current_microseconds = require'timer.utils'.get_current_microseconds

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

return pool
