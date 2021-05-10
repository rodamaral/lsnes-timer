# lsnes-timer

`lsnes-timer` is a module that provides static methods for executing Lua
functions at desired times. It uses lsnes functionality internally and
exposes a more user-friendly, habitual API.

# API

`local timer = require 'timer'`

Requires the library.

`local id = timer.set_timeout(callback, microseconds[, ...arguments])`

Sets a timer which executes a function once the timer expires. Returns
an unique timeout id so you can remove it later by calling
`clear_timeout`.

`local id = timer.set_interval(callback, time)`

Repeatedly calls a function or executes a code snippet, with a fixed
time delay between each call. Returns an unique interval id so you can
remove it later by calling `clear_interval`.

`timer.clear_timeout(id)`

Cancels a timeout previously established by calling `set_timeout`.

`timer.clear_timeout(id)`

Cancels an interval previously established by calling `set_interval`.

It’s worth noting that the pool of IDs used by set\_timeout() and
set\_interval() are shared, which means you can technically use
clear\_timeout() and clear\_interval() interchangeably. However, for
clarity, you should avoid doing so.

`timer.update(id, microseconds)`

Updates a timeout or interval with a (possibly) new value. In each case,
the current timeout is reset.

`timer.debounce(callback, time[, ...arguments])`

Creates a debounced function that delays invoking the `callback` until
after `time` milliseconds have elapsed since the last time the debounced
function was invoked.

`timer.throttle(callback, time[, ...arguments])`

Creates a throttled function that only invokes the `callback` at most
once per every `time` milliseconds.

# Examples

``` lua
local timer = require'timer'
local set_timeout = timer.set_timeout
local set_interval = timer.set_interval

set_timeout(function() print(1) end, 1000) -- prints `1` once after 1 second
set_interval(print, 2000, 2, 'custom args') -- prints `2	custom args` every 2 seconds after

local num = 0
set_interval(function()
    num = num + 1;
    gui.repaint()
end, 100)
callback.register('paint', function()
    gui.text(0, 0, num) -- displays `num` in the screen incrementing every 0.1 second, regardless of whether the emulator is paused or not
end)
```

# Gotchas / Warnings

- `lsnes-timer` depends on lsnes global function `set_timer_timeout`.
  Calling this function outside this library may cause issues for this
  lib and for the other code. Therefore, if you use this library,
  schedule all timers using the provided methods instead of using lsnes
  API directly.
- lsnes global `on_timer` event callback will be called everytime a
  callback is executed.

# Installation

Just copy the `timer.lua` file somewhere in your project and require it
accordingly.

# Specs

TODO
