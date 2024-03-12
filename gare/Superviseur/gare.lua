--[[
Title : gare.lua
Autor : Liwis776
Language : lua
Date : 18/07/2022 
Gestionnaire d'arriver en gare de train railcraft
]]
local component = require("component")
local j 		= require("json")
local event 	= require("event")
local io 		= require("io")
local t         = require("term")
local thread	= require("thread")
local string 	= require("string")
local log 		= require("/common/logger")
local utils		= require("/common/utils")
local r = component.redstone
local m = component.modem
local gpu = component.gpu
local serveGareAdd = 0

local port 		 = 1
local direction  = 0
local action 	 = 0
local act 		 = 0
local gare 		 = 0
local table 	 = 0
local aiguillage = 0

gare 		= utils.getFile("config/gare.json")
table 		= utils.getFile("config/table.json")
aiguillage  = utils.getFile("config/aiguillage.json")

r.setBundledOutput(5,gare["voie"]["entre"][1]["bloc"],0)
r.setBundledOutput(5,gare["quai"][1]["bloc"],0)
r.setBundledOutput(5,gare["quai"][2]["bloc"],0)
m.open(port)
t.clear()

type_locomotive = {
	["railcraft.cart.loco.creative"] 	= "railcraft.cart.loco.creative",
	["railcraft.cart.loco.eletric"] 	= "railcraft.cart.loco.eletric",
	["railcraft.cart.loco.steam.solid"] = "railcraft.cart.loco.steam.solid"
}


function checkQuai()
	for n = 1,gare["nbQuai"] do
		if r.getBundledInput(5,gare["quai"][n]["detecRQ"]) == 0 then 
			gare["quai"][n]["full"] = false
		else
			gare["quai"][n]["full"] = true
		end
	end
end

function giveQuai()
	found = false
	for n=1,gare["nbQuai"] do
		if gare["quai"][n]["full"] == false then
			found = true
			num = n
			break
		end
	end
	if found == true then
		return num
	else
		return "no station free"
	end
end

function rooting(voie, quai)
	for n = 1, aiguillage["nbAig"] do
		r.setBundledOutput(5,aiguillage["add"][n],table[quai][action][n])
	end
end

function arri(voie,nbWag)
	gpu.set(1,8,tostring(nbWag))
	repeat
		nbQuai = giveQuai()
		checkQuai()
		os.sleep(1)
	until(nbQuai ~= "no station free")
	rooting(voie,nbQuai)
	while r.getBundledInput(5,gare["quai"][nbQuai]["detecRQ"]) == 0 do
		r.setBundledOutput(5,gare["voie"]["entre"][voie]["bloc"],255)
	end
	r.setBundledOutput(5,gare["voie"]["entre"][voie]["bloc"],0)
end


function pass(voie,nbWag)
	
	repeat
		nbQuai = giveQuai()
		checkQuai()
		os.sleep(1)
	until(nbQuai ~= "no station free")
	rooting(voie,nbQuai)
	--while  r.getBundledInput(5,gare["quai"][nbQuai]["detecRS"]) == 0 do
		r.setBundledOutput(5,gare["quai"][nbQuai]["bloc"],255)
		r.setBundledOutput(5,gare["voie"]["entre"][voie]["bloc"],255)
	--end
	os.sleep(5)
	r.setBundledOutput(5,gare["voie"]["entre"][voie]["bloc"],0)
	r.setBundledOutput(5,gare["quai"][nbQuai]["bloc"],0)

end

function getAction(trainID)
	gpu.set(1,4,"message send")
	repeat
		m.send(serveGareAdd,port,"test","getTrainInfo",trainID)
		_,_,_,_,_,_,_,act,nbWag = event.pull(1,"modem_message")
	until (act ~= nil and nbWag ~= nil) 
	gpu.set(1,5,tostring(act))
	gpu.set(1,6,tostring(nbWag))
	return act,nbWag
end

function filtre(name,add,Id,_,_,...)
	message= {...}
	local cond = false
	if name == "minecart" then
		if type_locomotive[Id] ~= nil and cond == false then
			for n = 1, gare["nbVoieE"] do 
				if gare["voie"]["entre"][n]["detec"] == add:sub(1,4) then	
					act,nbWagon = getAction(message[2])
					if act == "arret" then
						action = "arrive"
						arri(n,nbWagon)
						cond = true
					elseif act == "pass" then
						action = "arrive"
						pass(n,nbWagon)
						cond = true
					end
				end
			end
		end
	elseif name == "modem_message" then
		if message[1] == "test" then
			if message[2] == "serveGare"then
				serveGareAdd = Id
				gpu.set(1,3,serveGareAdd)
			end
		end
	end
end




check_thread=thread.create(function()
	while true do 
		checkQuai()
		t.clear()
		gpu.set(1,3,tostring(serveGareAdd))
		gpu.set(1,1,string.format("Quai 1 full : %s",tostring(gare["quai"][1]["full"])))
		gpu.set(1,2,string.format("Quai 2 full : %s",tostring(gare["quai"][2]["full"])))
		os.sleep(1)
	end
end)

action_thread=thread.create(function()
	while true do
		event.pullFiltered(1,filtre)
	end
end)

interrupt_thread=thread.create(function()
	while true do
		event.pull(1,"interrupted")
	end
end)


thread.waitForAny({check_thread,action_thread,interrupt_thread})
os.exit(0)