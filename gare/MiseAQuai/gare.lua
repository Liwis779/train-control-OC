local component = require("component")
local j 		= require("json")
local event 	= require("event")
local io 		= require("io")
local t         = require("term")
local r = component.redstone
local m = component.modem

local direction  = 0
local action 	 = 0
local gare 		 = 0
local table 	 = 0
local aiguillage = 0
t.clear()
function getFile(name)
	temp = 0
	file = io.open(name,"r")
	temp = file:read()
	file:close()
	temp = j.decode(temp)
	return temp
end

function checkQuai()
	for n = 1,gare["nbQuai"] do
		if r.getBundledInput(5,gare["quai"][n]["detecR"]) == 0 then 
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

function arri(voie)
	repeat
		nbQuai = giveQuai()
		checkQuai()
		print(nbQuai)
		os.sleep(1)
	until(nbQuai ~= "no station free")
	rooting(voie,nbQuai)
	r.setBundledOutput(5,gare["voie"]["entre"][voie]["bloc"],255)
	os.sleep(5)
	r.setBundledOutput(5,gare["voie"]["entre"][voie]["bloc"],0)
end

function filtre(name,add,Id)
	local cond = false
	if name == "minecart" then
		if Id == "railcraft.cart.loco.creative" then
			if cond == false then
				for n = 1, gare["nbVoieE"] do 
					if gare["voie"]["entre"][n]["detec"] == add:sub(1,4) then
						action = "arrive"
						arri(n)
						cond = true
					end 
				end
			end
			if cond == false then
				for n = 1, gare["nbVoieE"] do 
					if gare["voie"]["sortie"][n]["detec"] == add:sub(1,4) then
						cond = true
					end 
				end
			end
		end
	end
end

gare 		= getFile("/home/gare.json")
table 		= getFile("/home/table.json")
aiguillage  = getFile("/home/aiguillage.json")

while true do 
	checkQuai()
	event.pullFiltered(2,filtre)
	print(gare["quai"][1]["full"])
	print(gare["quai"][2]["full"])
end
