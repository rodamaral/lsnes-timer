local function get_script_name()
    local token = '@@LUA_SCRIPT_FILENAME@@'
    return string.match(token, '%[%[(.+)%]%]')
end

local script_name = get_script_name()
local root = resolve_filename('../', script_name)
package.path = root .. '/src/?.lua;' .. root .. '/src/?/init.lua'

local timer = require 'timer'
local set_timeout = timer.set_timeout

local function _test(num) print('timeout after ' .. num .. ' ms') end

function _G.test(num)
    if type(num) ~= 'number' or num < 0 or num % 1 ~= 0 then
        error 'The parameter should be a non-negative integer'
    end

    local id = set_timeout(_test, num, num)
    print('Scheduling a ' .. num .. ' ms timeout', id)
end

function on_paint()
    gui.text(0, 0, 'run L test(1000) in the Messages window', 'white', 'black')
end

gui.repaint()
