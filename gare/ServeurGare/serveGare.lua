local component = require("component")
--local j 		= require("json")
local event 	= require("event")
local io 		= require("io")
local t         = require("term")
local table     = require("table")
local term 		= require("term")
local m = component.modem

local gareTable = { }
local port 		= 123

term.clear()

function ping(port)
	m.broadcast(port,test)
end

function filtre(name,_,add,port,_,nomGare,fonction,...)
	message={...}
	if name == "modem_message" then
		if gareTable[nomGare] == nil then
			if fonction == "test" then
				gareTable[nomGare]={add=add,train={}}
				print("Gare ajoute")
			else
				print("Gare non inconnu")
			end
		elseif fonction == "setDest" and add == gareTable[nomGare]["add"]then
			if gareTable[nomGare]["train"][message[1]] == nil then
				gareTable[nomGare]["train"][message[1]]=message[2]
				m.send(add,port,nomGare,"train ajouter")
				print("train ajoute")
			else
				m.send(add,port,nomGare,"train deja ajouter")
				print("train deja ajoute")
			end
		elseif fonction == "getDest" then
				m.send(add,port,nomGare,fonction,gareTable[nomGare]["train"][message[1]])
				print("message envoye")
		else
				print("Gare deja ajoute")
		end
	end
end

while true do 
	m.open(port)
	event.pullFiltered(filtre)
end