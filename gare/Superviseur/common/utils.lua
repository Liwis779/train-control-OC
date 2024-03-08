local j  = require("json")
local io = require("io")
local os = require("os")

utils = {}

function utils.getFile(name)
	temp = nil
	file,err = io.open(name,"r")
	if err ~= nil then file:close() error("Erreur d'ouverture du fichier") os.exit()  end
	temp = file:read()
	file:close()
	temp = j.decode(temp)
	return temp
end

return utils