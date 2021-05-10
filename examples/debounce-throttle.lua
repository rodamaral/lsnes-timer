local function get_script_name()
    local token = '@@LUA_SCRIPT_FILENAME@@'
    return string.match(token, '%[%[(.+)%]%]')
end

local script_name = get_script_name()
local root = resolve_filename('../', script_name)
package.path = root .. '/?.lua;' .. root .. '/?/init.lua'

local timer = require 'timer'
local debounce = timer.debounce
local throttle = timer.throttle

local count1, count2, count3 = 0, 0, 0

local increment1 = function()
    count1 = count1 + 1
    gui.repaint()
end

local increment2 = throttle(function()
    count2 = count2 + 1
    gui.repaint()
end, 500)

local increment3 = debounce(function()
    count3 = count3 + 1
    gui.repaint()
end, 500)

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

function on_paint()
    gui.solidrectangle(80, 80, 180, 150, 0x80000000)

    gui.text(100, 100, 'Normal')
    draw_button(100, 116, '+')
    gui.text(130, 116, count1)

    gui.text(100, 140, 'Throttled 500 ms')
    draw_button(100, 156, '+')
    gui.text(130, 156, count2)

    gui.text(100, 180, 'Debounced 500 ms')
    draw_button(100, 196, '+')
    gui.text(130, 196, count3)
end

function on_keyhook(key, state)
    if key == 'mouse_left' and (state.value == 1) then
        local x, y = get_mouse()

        if is_inside(x, y, 100, 116, 16, 20) then
            increment1()
        elseif is_inside(x, y, 100, 156, 16, 20) then
            increment2()
        elseif is_inside(x, y, 100, 196, 16, 20) then
            increment3()
        end
    end
end

input.keyhook('mouse_left', true)
gui.repaint()
