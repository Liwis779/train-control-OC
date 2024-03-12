if package.loaded["/common/logger"] ~= nil then package.loaded["/common/logger"] = nil end
local log = require("/common/logger")
local utils = require("/common/utils")
local timer = require("/common/timer")
local sound = require("/common/sound")
local event = require("event")
local shell = require("shell")
local computer = require("computer")
--utils.getFile("/home/config/gare.json")
--os.execute("test2.lua")

--shell.setWorkingDirectory("train-control-oc/gare/Superviseur/logs")
log.init(shell.getWorkingDirectory().."/logs/log.txt")
--[[log.infoMsg("test info")
log.debugMsg("test debug")
log.warnMsg("test warn")
log.errMsg("test error")]]
--[[
t=timer.create(2,(function()
    computer.beep(300,0.01)
    computer.beep(100,0.01)
    --computer.beep(550,0.01)
  end))
t2=timer.createOnce(1,(function() print("test2") end))
event.pull(math.huge,"key_down")
timer.delete(t)
timer.delete(t2)]]

sound.turnOn()
event.pull(math.huge,"key_down")
sound.turnOff()
event.pull(math.huge,"key_down")
a=sound.createAlarme(1)
event.pull(math.huge,"key_down")
sound.deleteAlarme(a)

a=sound.createAlarme(2)
event.pull(math.huge,"key_down")
sound.deleteAlarme(a)

a=sound.createAlarme(3)
event.pull(math.huge,"key_down")
sound.deleteAlarme(a)
log.close()