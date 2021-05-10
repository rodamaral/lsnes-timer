local function get_script_name()
    local token = '@@LUA_SCRIPT_FILENAME@@'
    return string.match(token, '%[%[(.+)%]%]')
end

local script_name = get_script_name()
local root = resolve_filename('../', script_name)
package.path = root .. '/src/?.lua;' .. root .. '/src/?/init.lua'

local timer = require 'timer'
local set_timeout = timer.set_timeout
local set_interval = timer.set_interval
local clear_timeout = timer.clear_timeout

local message = ''
local function remind()
    message = 'Hello from timeout'
    gui.repaint()
end

local function get_mouse()
    local raw = input.raw()
    local x = math.floor(raw.mouse_x.value)
    local y = math.floor(raw.mouse_y.value)

    return x, y
end

local function is_inside(x, y, xrec, yrec, width, height)
    return x >= xrec and x < xrec + width and y >= yrec and y < yrec + height
end

local function draw_button(x, y, symbol)
    gui.box(x, y, 16, 20)
    gui.text(x + 4, y, symbol, 'black')
end

local color = 'green'

local interval_id = set_interval(function()
    color = color == 'green' and 'red' or 'green'
    gui.repaint()
end, 400)

function on_paint()
    gui.solidrectangle(80, 180, 200, 70, 0x80000000)

    gui.text(100, 200, 'Remind me in 2 seconds')
    draw_button(100, 216, 'R')

    if message ~= '' then
        gui.textHV(120, 0, message, 'red', 'darkblue')
        draw_button(120, 216, 'X')
    end

    gui.rectangle(color == 'green' and 0 or 32, 448 - 32, 32, 32, 2, 'black',
                  color)
    if interval_id then draw_button(70, 448 - 24, 'X') end
end

local id = nil
function on_keyhook(key, state)
    if key == 'mouse_left' and (state.value == 1) then
        local x, y = get_mouse()

        if is_inside(x, y, 100, 216, 16, 20) then
            clear_timeout(id)
            id = set_timeout(remind, 2000)
            print('timeout id', id)
            message = ''
            gui.repaint()
        elseif is_inside(x, y, 120, 216, 16, 20) then
            if message ~= '' then
                message = ''
                gui.repaint()
            end
        elseif is_inside(x, y, 70, 448 - 24, 16, 20) then
            print('clearing interval id', interval_id)
            clear_timeout(interval_id)
            interval_id = nil
            gui.repaint()
        end
    end
end

input.keyhook('mouse_left', true)
gui.repaint()
