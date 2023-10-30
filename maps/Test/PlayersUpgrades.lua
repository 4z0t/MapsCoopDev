---@param playersData PlayersData
function Main(playersData)

	local enhancements = {
		Aeon = {
			"AdvancedEngineering",
			"T3Engineering",
			"ResourceAllocation",
		},
		Cybran = {
			"AdvancedEngineering",
			"T3Engineering",
			"ResourceAllocation",
		},
		UEF = {
			"AdvancedEngineering",
			"T3Engineering",
			"ResourceAllocation",
			"Shield",
		},
		Seraphim = {
			"AdvancedEngineering",
			"T3Engineering",
			"DamageStabilization",
			"ResourceAllocation",
		}
	}

	local n = table.getsize(playersData)
	LOG(n)

	local count = 0


	local playersDone = {}
	local tblArmy = ListArmies()

	UI4Sim.Callback
	{
		name = "PlayersUpgrades",
		fileName = "/maps/Test/UI/PlayersUpgrades.lua",
		functionName = "CreateUI",
		func = function(data)
			local args = data.args
			local from = data.from

			if playersDone[from] then return end

			count = count + 1
			playersDone[from] = args.option

			if args.option == 1 then
				print(tblArmy[from] .. " had chosen easy")
			elseif args.option == 2 then
				print(tblArmy[from] .. " had chosen hard")
			end

		end
	}

	while count ~= n do
		WaitSeconds(1)
	end

	UI4Sim.Callback
	{
		name = "PlayersUpgrades",
		fileName = "/maps/Test/UI/PlayersUpgrades.lua",
		functionName = "DestroyUI",

	}



	for iArmy, strArmy in pairs(tblArmy) do
		if StringStartsWith(strArmy, "Player") then
			if not playersDone[iArmy] then
				error("something is wrong!")
			end
			local option = playersDone[iArmy]
			if option == 1 then

			elseif option == 2 then
				playersData[strArmy].enhancements = enhancements[playersData[strArmy].faction]
			end
		end
	end

	return playersDone
end
