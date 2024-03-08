local component = require("component")
local j     = require("json")
local event   = require("event")
local io    = require("io")
local t         = require("term")
local string  = require("string")
local r = component.redstone
local m = component.modem
local gpu = component.gpu
local serveGareAdd = 0
local port     = 1
local direction  = 0
local action   = 0
local act      = 0
local gare     = 0
local table    = 0
local aiguillage = 0
t.clear()


function getFile(name)
  temp = 0
  file = io.open(name,"r")
  --if file == nil then error("Erreur d'ouverture du fichier")
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

function arri(voie,nbWag)
  gpu.set(1,8,tostring(nbWag))
  repeat
    nbQuai = giveQuai()
    checkQuai()
    print(nbQuai)
    os.sleep(1)
  until(nbQuai ~= "no station free")
  rooting(voie,nbQuai)
  while r.getBundledInput(5,gare["quai"][nbQuai]["detecR"]) == 0 do
    r.setBundledOutput(5,gare["voie"]["entre"][voie]["bloc"],255)
  end
  r.setBundledOutput(5,gare["voie"]["entre"][voie]["bloc"],0)
end

--[[
function pass(voie,nbWag)
  repeat
    nbQuai = giveQuai()
    checkQuai()
    print(nbQuai)
    os.sleep(1)
  until(nbQuai ~= "no station free")
  rooting(voie,nbQuai)
  while r.getBundledInput(5,gare["quai"][nbQuai]["detecR"]) == 0 do
    r.setBundledOutput(5,gare["quai"][nbQuai]["bloc"],255)
    r.setBundledOutput(5,gare["voie"]["entre"][voie]["bloc"],255)
  end
  r.setBundledOutput(5,gare["voie"]["entre"][voie]["bloc"],0)
  r.setBundledOutput(5,gare["quai"][nbQuai]["bloc"],0)

end]]

function getAction(trainID)
  m.send(serveGareAdd,port,"test","getTrainInfo",trainID)
  _,_,_,_,_,_,_,act,nbWag = event.pull("modem_message")
  gpu.set(1,5,tostring(act))
  gpu.set(1,6,tostring(nbWag))
  return act,nbWag
end

function filtre(name,add,Id,_,_,...)
  message= {...}
  local cond = false
  if name == "minecart" then
    if Id == "railcraft.cart.loco.creative" and cond == false then
      for n = 1, gare["nbVoieE"] do 
        if gare["voie"]["entre"][n]["detec"] == add:sub(1,4) then --add:sub recup l'addres du detecteur
          act,nbWagon = getAction(message[2])
          if act == "arret" then
            action = "arrive"
            arri(n,nbWagon)
            cond = true
          else
            cond = true
          end
        end 
      end
    end
  elseif name == "modem_message" then
    if message[1] == "test" and message[2] == "serveGare" then
      serveGareAdd = Id
      gpu.set(1,3,serveGareAdd)
    end
  end
end

gare    = getFile("/home/gare.json")
table     = getFile("/home/table.json")
aiguillage  = getFile("/home/aiguillage.json")
m.open(port)
while true do
  checkQuai()
  event.pullFiltered(2,filtre)
  t.clear()
  gpu.set(1,3,tostring(serveGareAdd))
  gpu.set(1,1,string.format("Quai 1 full : %s",tostring(gare["quai"][1]["full"])))
  gpu.set(1,2,string.format("Quai 2 full : %s",tostring(gare["quai"][2]["full"])))
end
