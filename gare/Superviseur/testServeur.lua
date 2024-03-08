local e = require("event")
local c = require("component")
local io = require("io")
local m = c.modem
m.open(1)

while true do 
	m.broadcast(1,"aaa","test")
	io.read()

	m.broadcast(1,"test","setDest","test","arret",3)
	print(e.pull("modem_message"))
	io.read()

	m.broadcast(1,"test","getTrainInfo","test")
	print(e.pull("modem_message"))
	io.read()

	m.broadcast(1,"test","getTaille","test")
	print(e.pull("modem_message"))
	io.read()

	m.broadcast(1,"test","modDest","test","pass")
	print(e.pull("modem_message"))
	io.read()

	m.broadcast(1,"test","getDest","test")
	print(e.pull("modem_message"))
	io.read()

	m.broadcast(1,"test","delDest","test")
	print(e.pull("modem_message"))
	io.read()

	m.broadcast(1,"test","getDest","test")
	print(e.pull("modem_message"))
	io.read()
	
	m.close(1)
	os.exit()
end