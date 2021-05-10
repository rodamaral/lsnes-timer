local function get_script_name()
    local token = '@@LUA_SCRIPT_FILENAME@@'
    return string.match(token, '%[%[(.+)%]%]')
end

local script_name = get_script_name()
local root = resolve_filename('../', script_name)
package.path = root .. '/?.lua;' .. root .. '/?/init.lua'

local timer = require 'timer'
local set_interval = timer.set_interval

local function create_counter(timeout)
    local count = 0

    set_interval(function()
        count = count + 1
        gui.repaint()
    end, timeout)

    return function() return count end
end

local counter1 = create_counter(1000)
local counter2 = create_counter(100)
local counter3 = create_counter(10)

function on_paint()
    gui.textHV(10, 10, counter1(), 'white', 'black')
    gui.textHV(10, 50, counter2(), 'white', 'black')
    gui.textHV(10, 90, counter3(), 'white', 'black')
end

gui.repaint()
