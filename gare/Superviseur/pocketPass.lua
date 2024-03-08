local c = require("component")
local io = require("io")
local string = require("string")
local gpu = c.gpu
--local json = require("/home/pocketPass/json")
local json = require("json")
local ecranActuel = "menu"
local term = require("term")
l,h = gpu.getResolution()

term.clear()
ecran = {
	menu = {
		{text="gestion des mots de passes",ecranSuiv="mdpMenu"},
		{text="gestion des adresses",ecranSuiv="addMenu"},
		{text="quitter",ecranSuiv="exit"},
	},
	mdpMenu = {
		{text="ajouter une gare",ecranSuiv="ajGareMdp"},
		{text="ajouter un mot de passe",ecranSuiv="ajMdp"},
		{text="exporter un mot de passe",ecranSuiv="exMdp"},
		{text="voir les mots de passes",ecranSuiv="seMdp"},
		{text="retour",ecranSuiv="menu"},
	},
	addMenu = {
		{text="ajouter une gare",ecranSuiv="ajGareAdd"},
		{text="ajouter une adresse",ecranSuiv="ajAdd"},
		{text="exporter une adresse",ecranSuiv="exAdd"},
		{text="voir les adresses",ecranSuiv="seAdd"},
		{text="retour",ecranSuiv="menu"},
	} 
}

function cadre(xHautG,yHautG,xBasD,yBasD)
	--Barres horizontales
	gpu.fill(xHautG+1,yHautG,(xHautG)+(xBasD)-1,1,"─")
	gpu.fill(xHautG+1,yBasD,(xHautG)+(xBasD)-1,1,"─")

	--Barres Verticales
	gpu.fill(xHautG,yHautG+1,xHautG,(yBasD)-(yHautG)-1,"│")
	gpu.fill(xBasD,yHautG+1,xBasD,(yBasD)-(yHautG)-1,"│")

	--Coin haut
	gpu.set(xHautG,yHautG,"┌")
	gpu.set(xBasD,yHautG,"┐")

	--Coin bas
	gpu.set(xHautG,yBasD,"└")
	gpu.set(xBasD,yBasD,"┘")
end

function changementEcran()
	term.clear()
	cadre(1,1,l,h)
	i=0
	if ecranActuel == "exit" then os.exit() end
	if ecran[ecranActuel] ~= nil then
		for nameMenu, _ in pairs(ecran[ecranActuel]) do
			gpu.set((l/2)-13,(h/2)+i,string.format("%s | %s",nameMenu,ecran[ecranActuel][nameMenu].text))
			i=i+1
		end
		gpu.set((l/2)-13,(h/2)+(i+1),"Choix :")
		term.setCursor((l/2)-6,(h/2)+(i+1))
	end
end


function getFile(name)
	temp = 0
	file = io.open(name,"r")
	temp = file:read()
	file:close()
	temp = json.decode(temp)
	return temp
end

function menu()
	choix = tonumber(io.read())
	if ecran[ecranActuel][choix] ~= nil then
		ecranActuel = ecran[ecranActuel][choix].ecranSuiv
		changementEcran()
	else
		changementEcran()
	end
end


cadre(1,1,l,h)
changementEcran()
while true do 
	menu()
end

--[[à faire le setup
	fonction mdp add 
	fonction decodage
	fonction affichage
	]]