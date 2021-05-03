lsnes-timer
========

`lsnes-timer` is a class that provides methods for executing a Lua functions at desired times.
It uses lsnes functionality internally and exposes a more user-friendly, habitual API.


API
===


`local clock = timer.get_instance()`
Creates a clock instance with timing methods. Notice that this object is a singleton instance due to limitations of the lsnes timer functions.

`local id = clock:set_timeout(callback, microseconds)`
Sets a timer which executes a function once the timer expires.
Returns an unique timeout id so you can remove it later by calling `clear_timeout`.

`clock:set_interval(callback, time)`
repeatedly calls a function or executes a code snippet, with a fixed time delay between each call.
Returns an unique interval id so you can remove it later by calling `clear_timeout`.

`clock:clear_timeout(id)`
Cancels a timeout previously established by calling `set_timeout` or timed, repeating action which was previously established by a call to `set_interval`.

`clock:update(id, microseconds)`
Updates a timeout or interval with a (possibly) new value. In each case, the current timeout is reset.

`clock:get_debounced(callback, time)`
Creates a debounced function that delays invoking the `callback` until after `time` milliseconds have elapsed since the last time the debounced function was invoked.

*TODO*: create throttle.

Examples
========

```lua
local timer = require'timer'
local clock = timer.get_instance()

clock:set_timeout(function() print(1) end, 1000) -- prints `1` once after 1 second
clock:set_interval(function() print(2) end, 2000) -- prints `2` every 2 seconds after

local num = 0
clock:set_interval(function()
    num = num + 1;
    gui.repaint()
end, 100)
callback.register('paint', function()
    gui.text(0, 0, num) -- displays `num` in the screen incrementing every 0.1 second, regardless of whether the emulator is paused or not
end)
```

Gotchas / Warnings
==================

* `lsnes-timer` depends on lsnes global function `set_timer_timeout`. Calling this function outside this library may cause issues for this lib and for the other code. Therefore, if you use this library, schedule all timers using the provided methods instead of using lsnes API directly.
* lsnes global `on_timer` event callback will be called everytime a callback is executed.


Installation
============

Just copy the `timer.lua` file somewhere in your project and require it accordingly.


Specs
=====

TODO
