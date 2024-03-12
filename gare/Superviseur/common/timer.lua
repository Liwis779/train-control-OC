--[[
    gestion des timer
]]

local event = require("event")
local math = require("math")
local log = require("common/logger")

local timer={ }
timer.register = {}

function timer.create(interval,callback)
    id = event.timer(interval,callback,math.huge)

    timer.register [id] = {
        interval=interval,
        callback=callback,
        time="inf"
    }
    log.infoMsg("timer id="..id.." created")
    return id
end

function timer.createOnce (interval,callback)
    id = event.timer(interval,callback,1)

    timer.register [id] = {
        interval=interval,
        callback=callback,
        time=1
    }
    log.infoMsg("timer id="..id.." created")
    return id
end

function timer.delete(id)
    event.cancel(id)
    timer.register[id] = nil
    log.infoMsg("timer id="..id.." deleted")
end

return timer