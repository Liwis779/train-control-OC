local component = require("component")
local j 		= require("json")
local event 	= require("event")
local io 		= require("io")
local t         = require("term")
local term 		= require("term")
local m = component.modem

local gareTable = 0
local port 		= 123

term.clear()

function getFile(name)
	temp = 0
	file = io.open(name,"r")
	temp = file:read()
	file:close()
	temp = j.decode(temp)
	return temp
end

function ping(port)
	m.broadcast(port,test)
end

function filtre(name,_,add,port,_,nomGare,fonction,...)
	message={...}
	if name == "modem_message" then
		if gareTable[nomGare] == nil then
			--[[if fonction == "ajoutGare" then
				gareTable[nomGare]={add=add,train={}}
				print("Gare ajoute")
			else
				print("Gare inconnu")
			end]]
			print("Gare inconnu")
		elseif fonction == "modDest" then
			if gareTable[nomGare]["train"][message[1]] ~= nil then
				gareTable[nomGare]["train"][message[1]]=message[2]
				m.send(add,port,nomGare,"train modifie")
				print("train modifie")
			else
				m.send(add,port,nomGare,"train inconnu")
				print("train inconnu")
			end
		elseif fonction == "delDest" then
			if gareTable[nomGare]["train"][message[1]] ~= nil then
				gareTable[nomGare]["train"][message[1]]=nil
				m.send(add,port,nomGare,"train supprime")
				print("train supprime")
			else
				m.send(add,port,nomGare,"train inconnu")
				print("train inconnu")
			end
		elseif fonction == "setDest" then
			if gareTable[nomGare]["train"][message[1]] == nil then
				gareTable[nomGare]["train"][message[1]]=message[2]
				m.send(add,port,nomGare,"train ajouter")
				print("train ajoute")
			else
				m.send(add,port,nomGare,"train deja ajouter")
				print("train deja ajoute")
			end
		elseif fonction == "getDest" then
			if gareTable[nomGare]["train"][message[1]] ~= nil then
				m.send(add,port,nomGare,fonction,gareTable[nomGare]["train"][message[1]])
				print("message envoye")
			else
				m.send(add,port,nomGare,"train inconnu")
				print("train inconnu")
			end
		else
				print("Gare deja ajoute")
		end
	end
end

gareTable = getFile("/home/gareServe.json")

while true do 
	m.open(port)
	event.pullFiltered(filtre)
end