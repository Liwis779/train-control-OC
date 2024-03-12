--[[
    gestion des alarmes
]]

local computer = require("computer")
local timer = require("/common/timer")
local log = require("/common/logger")

sound = {}

function sound.turnOn()
    computer.beep(250,0.01)
    computer.beep(300,0.01)
end

function sound.turnOff()
    computer.beep(300,0.01)
    computer.beep(250,0.01)
end

function sound.createAlarme(gravity)
    if  gravity == 1 then
       id = timer.create(2,(function () computer.beep(500,1) end))
       sound[id] = {
        timerId = id,
        severity = 1,
       }
    elseif gravity == 2 then
        id = timer.create(1,(function () computer.beep(500,0.1) computer.beep(350,0.1) end))
        sound[id] = {
         timerId = id,
         severity = 2,
        }
    elseif gravity == 3 then
        id = timer.create(0.1,(function () computer.beep(700,0.1) computer.beep(600,0.1) end))
        sound[id] = {
         timerId = id,
         severity = 3,
        }
    end
    log.infoMsg("Alarm id="..id.." created")
    return id
end

function sound.deleteAlarme(id)
    timer.delete(id)
    sound[id]=nil
    log.infoMsg("Alarm id="..id.." deleted")
end

return sound