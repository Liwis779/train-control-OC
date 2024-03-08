--[[
    objectif ecrire les log dans un fichier 
    type de log 
    -info
    -debug
    -erreur
    -warning
]]

local io = require("filesystem")
local str = require("string")
local os = require("os")

logger = {
    isReady = false,
    file = nil,
    path = nil
}

function logger.init(path)
    if logger.isReady  then return end
    logger.file,err = io.open(path,'a')
    if err ~= nil then error("error when open the file") end 
    logger.path = path
    logger.isReady = true
end

function logger.close()
    if not logger.isReady then return end
    logger.file:close()
    logger.isReady = false
end

function logger.infoMsg(msg) 
    logger.file:write(str.format("[%s][info]%s \n",os.date('%c'),msg))
    --print(str.format("[%s][info]%s \n",os.date('%c'),msg))
end

function logger.debugMsg(msg)
    logger.file:write(str.format("[%s][debug]%s \n",os.date('%c'),msg))
    --print(str.format("[%s][debug]%s \n",os.date('%c'),msg))
end

function logger.warnMsg(msg)
    logger.file:write(str.format("[%s][warn]%s \n",os.date('%c'),msg))
    --print(str.format("[%s][warn]%s \n",os.date('%c'),msg))
end

function logger.errMsg(msg)
    logger.file:write(str.format("[%s][error]%s \n",os.date('%c'),msg))
    --print(str.format("[%s][error]%s \n",os.date('%c'),msg))
end

return logger