-- Lua Script1
-- Author: Technostar
-- DateCreated: 9/14/2019 8:34:59 PM
--------------------------------------------------------------
-- Save functions brought to you by Sukritact's Save Utils.

--include( "Sukritact_SaveUtils.lua" ); MY_MOD_NAME = "OrientalUruguay";
--include( "Sukritact_ChangeResearchProgress.lua" ); MY_MOD_NAME = "OrientalUruguay";
local MY_MOD_NAME = "LuaAIOverhaul";

-- I was having difficulty getting SaveUtils to work, so I threw the code right in here.

--=======================================================================================================================
-- Sukritact_SaveUtils
-- Modified from NewSaveUtils.lua
--=======================================================================================================================

print("Uruguay Beta 6 loading");

gbLogSaveData = false;

-- Connection to the Modding save data.  Keep one global connection, rather than opening/closing, to speed up access
g_SaveData = Modding.OpenSaveData();
g_Properties = nil;
-------------------------------------------------------------- 
-- Access the modding database entries through a locally cached table
function GetPersistentProperty(name)
	if(g_Properties == nil) then
		g_Properties = {};
	end
	
	if(g_Properties[name] == nil) then
		g_Properties[name] = g_SaveData.GetValue(name);
	end
	
	return g_Properties[name];
end
print("Loaded method 1");
--------------------------------------------------------------
-- Access the modding database entries through a locally cached table
function SetPersistentProperty(name, value)
	if(g_Properties == nil) then
		g_Properties = {};
	end
	
	if (g_Properties[name] ~= value) then
		g_SaveData.SetValue(name, value);
		g_Properties[name] = value;
	end
end
print("Loaded method 2");
--=======================================================================================================================
-- Utility Functions
--=======================================================================================================================
function InitializeInstances()
	--print(Player)
	--print(Player)
	--print(Team)
	--print(Team)
	--print(Plot)
	local pPlot = Map.GetPlotByIndex(0)
	--print(Plot)
	--print(Unit)
	local pPlayer = Players[0]
	for pUnit in pPlayer:Units() do
		break
	end
	--print(Unit)
end
InitializeInstances()
print("Loaded method 3");

function CompileUnitID(pUnit)
	local iOwner = pUnit:GetOwner()
	local iUnit = pUnit:GetID()
	local iTurn = pUnit:GetGameTurnCreated()
    return(iOwner .. "_ID" .. iUnit .. "_T" .. iTurn)
end

function CompilePlotID(pPlot)
    local iX = pPlot:GetX()
    local iY = pPlot:GetY()
    return(iX .. "_Y" .. iY)
end
print("Loaded method 4");
--=======================================================================================================================
-- Save/Load Functions
--=======================================================================================================================
function save(pObject, sKey, Val)
	
	--Booleans must be converted to strings
	if Val == true then
		Val = "bTrue"
	elseif Val == false then
		Val = "bFalse"
	end
	
	local sTrueKey = nil
	--if pObject == "GAME" or variants save without other ID
	if (type(pObject) == "string") then
		if string.upper(pObject) == "GAME" then
			sTrueKey = (MY_MOD_NAME .. "_" .. sKey)
		else
			--print("Error on Save: Invalid type")
			return
		end
	--Else ensure pObject is an Object
	elseif (pObject == nil or type(pObject) ~= "table") then
		--print("Error on Save: Invalid type")
		return
	end
	
	--Player
	if (getmetatable(pObject).__index == Player) then
		sTrueKey = (MY_MOD_NAME .. "_Player" .. pObject:GetID() .. "_" .. sKey)
	--Team
	elseif (getmetatable(pObject).__index == Team) then
		sTrueKey = (MY_MOD_NAME .. "_Team" .. pObject:GetID() .. "_" .. sKey)
	--Unit
	elseif (getmetatable(pObject).__index == Unit) then
		sTrueKey = (MY_MOD_NAME .. "_Unit".. CompileUnitID(pObject) .. "_" .. sKey)
	--Plot
	elseif (getmetatable(pObject).__index == Plot) then
		sTrueKey = (MY_MOD_NAME .. "_Plot".. CompilePlotID(pObject) .. "_" .. sKey)
	end
	
	--Save Data
	if	sTrueKey ~= nil then
		--print("Save", sTrueKey, Val)
		SetPersistentProperty(sTrueKey, Val)
	else
		--print("Error on Save: Key Creation Failed")
	end
end
print("Loaded method 5");
function Load_Booleanfy(Val)
	--Booleans must be converted from strings
	if Val == "bTrue" then
		Val = true
	elseif Val == "bFalse" then
		Val = false
	end
	return Val
end
print("Loaded method 6");
function load(pObject, sKey)
	
	local sTrueKey = nil
	--if pObject == "GAME" or variants save without other ID
	if (type(pObject) == "string") then
		if string.upper(pObject) == "GAME" then
			sTrueKey = (MY_MOD_NAME .. "_" .. sKey)
		else
			--print("Error on Load: Invalid type")
			return
		end
	--Else ensure pObject is an Object
	elseif (pObject == nil or type(pObject) ~= "table") then
		--print("Error on Load: Invalid type")
		return
	end
	
	--Player
	if (getmetatable(pObject).__index == Player) then
		sTrueKey = (MY_MOD_NAME .. "_Player" .. pObject:GetID() .. "_" .. sKey)
	--Team
	elseif (getmetatable(pObject).__index == Team) then
		sTrueKey = (MY_MOD_NAME .. "_Team" .. pObject:GetID() .. "_" .. sKey)
	--Unit
	elseif (getmetatable(pObject).__index == Unit) then
		sTrueKey = (MY_MOD_NAME .. "_Unit".. CompileUnitID(pObject) .. "_" .. sKey)
	--Plot
	elseif (getmetatable(pObject).__index == Plot) then
		sTrueKey = (MY_MOD_NAME .. "_Plot".. CompilePlotID(pObject) .. "_" .. sKey)
	end
	
	--Load Data
	if	sTrueKey ~= nil then
		Val = Load_Booleanfy(GetPersistentProperty(sTrueKey))
		--print("Load", sTrueKey, Val)
		return Val
	else
		--print("Error on Load: Key Creation Failed")
	end
end
print("Loaded method 7");



--MOD CORE

-- Override civ AI to make better use of abilities

-- This part makes sure that the AI isn't going to spam too many settlers for the map size.
local iMapSizes = {};
iMapSizes[6] = 40 * 25 - 100;
iMapSizes[5] = 56 * 36 - 100;
iMapSizes[4] = 66 * 42 - 100;
iMapSizes[3] = 80 * 52 - 100;
iMapSizes[2] = 104 * 64 - 100;
iMapSizes[1] = 128 * 80 - 100;
iMapSizes[0] = 180 * 94 - 100;
local iBuildSettlerLimit = 0;
local iBuildSecondSettlerLimit = 0;
local iMapPlots = Map.GetNumPlots();
print("Map plots: " .. iMapPlots);
for i8 = 0, 6 do
	if iMapPlots > iMapSizes[i8] then 
		iBuildSettlerLimit = 6 - i8;
		break;
	end
end
iBuildSettlerLimit = iBuildSettlerLimit + 2;
if iBuildSettlerLimit > 6 then
	iBuildSecondSettlerLimit = iBuildSettlerLimit - 6;
end
print("Build limit set at " .. iBuildSettlerLimit .. " settlers");

--Controls frequency of buy down

local iFrequency = {};
iFrequency[0] = 30;
iFrequency[1] = 15;
iFrequency[2] = 10;
iFrequency[3] = 7;
	-- Construct useful tables of all units
	--print("Constructing reference tables");
	--print("Constructing table 1 ");
	local i1 = 0;
	local unitsIDTable = {};
	local unitsTable = {};
	--print("step 1");
	
	for i = 0, 1000 do
		if GameInfo.Units[i] ~= nil then
			--print("iterating " .. i1);
			unitsIDTable[i1] = GameInfo.Units[i].ID;
			unitsTable[i1] = GameInfo.Units[GameInfo.Units[i].ID];
			i1 = i1 + 1;
		end
	end
	local iUnitsSize = i1;

	--print("Constructing table 2 ");
	-- Construct useful tables of all buildings
	local i2 = 0;
	local BuildingsIDTable = {};
	local BuildingsTable = {};
	for i = 0, 1000 do
		if GameInfo.Buildings[i] ~= nil then
			BuildingsIDTable[i2] = GameInfo.Buildings[i].ID;
			BuildingsTable[i2] = GameInfo.Buildings[GameInfo.Buildings[i].ID];
			i2 = i2 + 1;
		end
	end
	local iBuildingsSize = i2;


-- TODO: Implement this check correctly
-- Prevents purchasing settlers if the number of active settlers is greater than a certain number, determined by map size.
function GetShouldPurchaseSettlers(iPlayer) 
	local pPlayer = Players[iPlayer];
	local iTotalSettlers = 0;
	if pPlayer:IsAlive() then
		for pUnit in pPlayer:Units() do
			if pUnit ~= nil and pUnit:GetUnitType() == GameInfoTypes.UNIT_SETTLER then
				iTotalSettlers = iTotalSettlers + 1;
			end
		end
	end
	print("Found " .. iTotalSettlers .. " settlers");
	local bRet = iTotalSettlers <= 1 + (iBuildSettlerLimit - 1) / 3.55;
	local sRet = "";
	if bRet then
		sRet = "true";
	else
		sRet = "false";
	end
	local sThresh = "";
	if (iTotalSettlers <= 1 + (iBuildSettlerLimit - 2) / 3.55) then
		sThresh = "true";
	else
		sThresh = "false";
	end
	print("Buy settler? " .. sRet .. ". Why? Less than active settler threshold? " .. ".");
	return bRet;
end


function AIOGoldBuyDown(iPlayer, iGoldThreshold)
	local pPlayer = Players[iPlayer];
	local iInitialGold = pPlayer:GetGold();
	local iGold = iInitialGold;
	print("Buying down");
	

	for pCity in pPlayer:Cities() do
		--print("City");
		local iRand = Game.Rand(6, "What to buy?");
		local iThreshold = 3;
		if pPlayer:GetCurrentEra() < 2 then
			iThreshold = 6;
		end


		if iRand < iThreshold then
			--print("Attempt to buy unit");
			validUnits = {};
			unitFlavor = {};
			--local iBestUnit = -1;
			local iUnitOptions = 0;
			local i4 = 0;
			for i = 0, iUnitsSize do
				local pUnit = unitsTable[i];
				local iUnit = unitsIDTable[i]
				
				
				if pUnit ~= nil and pCity:IsCanPurchase(true, true, iUnit, -1, -1, YieldTypes.YIELD_GOLD) then
					if (iUnit == GameInfoTypes.UNIT_SETTLER and GetShouldPurchaseSettlers(iPlayer)) then
						--print(iUnit .. " valid * 5!");
						validUnits[i4] = pUnit;
						i4 = i4 + 1;
						validUnits[i4] = pUnit;
						i4 = i4 + 1;
						validUnits[i4] = pUnit;
						i4 = i4 + 1;
						validUnits[i4] = pUnit;
						i4 = i4 + 1;
						validUnits[i4] = pUnit;
						i4 = i4 + 1;
					elseif iUnit ~= GameInfoTypes.UNIT_SETTLER and iUnit ~= GameInfoTypes.UNIT_WORKER and iUnit ~= GameInfoTypes.UNIT_CARAVAN and iUnit ~= GameInfoTypes.UNIT_CARGO_SHIP and iUnit ~= GameInfoTypes.UNIT_WORKBOAT and pPlayer:GetCurrentEra() >= 2 and not GetShouldPurchaseSettlers(iPlayer) then
						--print(iUnit .. " valid");
						validUnits[i4] = pUnit;
						i4 = i4 + 1;
					end
				end
				

				
			end
			iUnitOptions = i4;
			if iUnitOptions > 0 then
				-- Pick at random from valid units, weighted by flavor
				local iRandB = Game.Rand(iUnitOptions, "Randomly selecting unit");
			

				--Game.CityPurchaseUnit(pCity, validUnits[iRandB].ID, -1, -1);
				local iCost = pCity:GetUnitPurchaseCost(validUnits[iRandB].ID);
				local iGold = pPlayer:GetGold();
				if iGold - iCost > 0 and iCost >= 0 then
					pPlayer:InitUnit(validUnits[iRandB].ID, pCity:GetX(), pCity:GetY());
					print(iGold .. " gold registered, should be " .. pPlayer:GetGold() .. ", difference: " .. (pPlayer:GetGold() - iGold) .. " cost: " .. iCost);
					pPlayer:SetGold(iGold - iCost);
					print("Purchasing unit " .. validUnits[iRandB].ID);
					print(pPlayer:GetGold() .. " gold detected after purchasing unit");
				end

			elseif pPlayer:GetCurrentEra() >= 2 then
				--Build building if you can't buy a unit.
				--print("Attempt to buy building");
			
				-- Attempt to buy unit
				validBuildings = {};
			
				--local iBestBuilding = -1;
				local iBuildingsOptions = 0;
				local i4 = 0;
				for i = 0, iBuildingsSize do
					local pBuilding = BuildingsTable[i];
					local iBuilding = BuildingsIDTable[i]
				
				
					if pBuilding ~= nil and pCity:IsCanPurchase(true, true, -1, iBuilding, -1, YieldTypes.YIELD_GOLD) then
						--print(iBuilding .. " valid");
						validBuildings[i4] = pBuilding;
						i4 = i4 + 1;
					end
				

				
				end
				iBuildingsOptions = i4;
				if iBuildingsOptions > 0 then
					-- Pick at random from valid Buildings, weighted by flavor
					local iRandB = Game.Rand(iBuildingsOptions, "Randomly selecting Building");
				

					--Game.CityPurchaseBuilding(pCity, validBuildings[iRandB].ID, -1, -1);

					local iCost = pCity:GetBuildingPurchaseCost(validBuildings[iRandB].ID);
					local iGold = pPlayer:GetGold();
					if iGold - iCost > 0 and iCost >= 0 then
						pCity:SetNumRealBuilding(validBuildings[iRandB].ID, 1);
						print(iGold .. " gold registered, should be " .. pPlayer:GetGold() .. ", difference: " .. (pPlayer:GetGold() - iGold) .. " cost: " .. iCost);
					
						pPlayer:SetGold(iGold - iCost);
						print("Purchasing Building " .. validBuildings[iRandB].ID);
						print(pPlayer:GetGold() .. " gold detected after purchasing building");
					end
				end

			end



		else
			--print("Attempt to buy building");
			
			-- Attempt to buy unit
			validBuildings = {};
			
			--local iBestBuilding = -1;
			local iBuildingsOptions = 0;
			local i4 = 0;
			for i = 0, iBuildingsSize do
				local pBuilding = BuildingsTable[i];
				local iBuilding = BuildingsIDTable[i]
				
				
				if pBuilding ~= nil and pCity:IsCanPurchase(true, true, -1, iBuilding, -1, YieldTypes.YIELD_GOLD) then
					--print(iBuilding .. " valid");
					validBuildings[i4] = pBuilding;
					i4 = i4 + 1;
				end
				

				
			end
			iBuildingsOptions = i4;
			if iBuildingsOptions > 0 then
				-- Pick at random from valid Buildings, weighted by flavor
				local iRandB = Game.Rand(iBuildingsOptions, "Randomly selecting Building");
				

				--Game.CityPurchaseBuilding(pCity, validBuildings[iRandB].ID, -1, -1);

				local iCost = pCity:GetBuildingPurchaseCost(validBuildings[iRandB].ID);
				local iGold = pPlayer:GetGold();
				if iGold - iCost > 0 and iCost >= 0 then
					pCity:SetNumRealBuilding(validBuildings[iRandB].ID, 1);
					print(iGold .. " gold registered, should be " .. pPlayer:GetGold() .. ", difference: " .. (pPlayer:GetGold() - iGold) .. " cost: " .. iCost);
					
					pPlayer:SetGold(iGold - iCost);
					print("Purchasing Building " .. validBuildings[iRandB].ID);
					print(pPlayer:GetGold() .. " gold detected after purchasing building");
				end
			end

		end

		iGold = pPlayer:GetGold();
		if iGold < iGoldThreshold then
			return;
		end
	end
end

function AIOPurchaseOverride(iPlayer) 
	local pPlayer = Players[iPlayer];
	--ONLY AI
	if pPlayer:IsAlive() and not pPlayer:IsHuman() then
		--print("Checking for gold");
		local iGold = pPlayer:GetGold();
		--print("found " .. iGold .. " gold");


		--local bCanContinue = true;
		if iGold > 5000 then
			local iMax = 20000 + pPlayer:CalculateGrossGold() * 5;
			if iGold > iMax then
				print("Found " .. iGold .. ", which is greater than the max of " .. iMax .. " that should be possible.");
				print("This is most likely caused by a bug that is nearly impossible to fix. Reducing gold to " .. iMax);
				pPlayer:SetGold(iMax);
				print(pPlayer:GetGold() .. " gold detected after normalizing treasury");
			end
			print("Calling GoldBuyDown");
			AIOGoldBuyDown(iPlayer, 5000);
		end


	end


end

local sThingToProduce = "ThingToProduce";
local sTimer = "Timer";
local sProd = "Production store";
local sSettlers = "Settlers built";
function AIOPurchaseAuto(iPlayer)
	--print("Autopurchase?");
	local frequency = 10;
	if Game.GetGameSpeedType() < 4 then 
		frequency = iFrequency[Game.GetGameSpeedType()];
	end
	local pPlayer = Players[iPlayer];
	--ONLY AI
	if pPlayer:IsAlive() and not pPlayer:IsHuman() then
		
		local iGold = pPlayer:GetGold();

		if Game.GetElapsedGameTurns() % frequency == 0 then
			AIOGoldBuyDown(iPlayer, 100);
		end

		
	end


end

GameEvents.PlayerDoTurn.Add(AIOPurchaseOverride);
GameEvents.PlayerDoTurn.Add(AIOPurchaseAuto);

--Override civ production priorities
function AIOBuildOverride(iPlayer)
	local frequency = 10;
	if Game.GetGameSpeedType() < 4 then 
		frequency = iFrequency[Game.GetGameSpeedType()];
	end
	local pPlayer = Players[iPlayer];
	

	--DON'T MESS WITH PLAYER OR URUGUAY AI
	if pPlayer:IsAlive() and not (pPlayer:GetCivilizationType() == iUruguayCiv) and not pPlayer:IsHuman() then

		--Good research priorities are good
		if pPlayer:CanResearch(GameInfoTypes.TECH_MATHEMATICS) then
			print("Setting research to maths");
			pPlayer:PushResearch(GameInfoTypes.TECH_MATHEMATICS, false);
		elseif pPlayer:CanResearch(GameInfoTypes.TECH_MASONRY) then
			print("Setting research to masonry");
			pPlayer:PushResearch(GameInfoTypes.TECH_MASONRY, false);
		elseif pPlayer:CanResearch(GameInfoTypes.TECH_WRITING) then
			print("Setting research to writing");
			pPlayer:PushResearch(GameInfoTypes.TECH_WRITING, false);
		elseif pPlayer:CanResearch(GameInfoTypes.TECH_OPTICS) then
			print("Setting research to optics");
			pPlayer:PushResearch(GameInfoTypes.TECH_OPTICS, false);
		elseif pPlayer:CanResearch(GameInfoTypes.TECH_ASTRONOMY) then
			print("Setting research to astronomy");
			pPlayer:PushResearch(GameInfoTypes.TECH_ASTRONOMY, false);
		end

		--Order new units every frequency * 2 turns (20 standard)
		if Game.GetElapsedGameTurns() % (frequency * 2) == 0 then
			for pCity in pPlayer:Cities() do
				iCity = pCity:GetID();
				local iThingToProduce = load(pPlayer, sThingToProduce .. iCity);
				if iThingToProduce == nil then 
					iThingToProduce = -1; 
				end

				if iThingToProduce == -1 then 
					iThingToProduce = -2; 
				end
				print("Ordering unit production");
				save(pPlayer, sThingToProduce .. iCity, iThingToProduce);
			end
		end

		--Custom early game
		if Game.GetElapsedGameTurns() < frequency * 10 then


			local iCityCount = 0;
			for pCity in pPlayer:Cities() do
				local iCity = pCity:GetID();
				local iProd = load(pPlayer, sProd .. iCity);
				if iProd == nil then 
					iProd = 0;
				end
				local iSettlers = load(pPlayer, sSettlers .. iCity);
				if iSettlers == nil then 
					iSettlers = 0; 
				end
				--print(iSettlers .. " settlers built");
				--print(iProd .. " production, adding " .. (pCity:GetOverflowProduction()  + pCity:GetProduction()) .. " production");
				
				iProd = iProd + pCity:GetOverflowProduction() + pCity:GetProduction();
				--print(iProd .. " production after addition");
				pCity:SetProduction(0);

				if pCity:CanConstruct(GameInfoTypes.BUILDING_GRANARY) and iCityCount < 20 then
					--print("Checking if can build BUILDING_GRANARY");
					if iProd >= pPlayer:GetBuildingProductionNeeded(GameInfoTypes.BUILDING_GRANARY) / (1 + pCity:GetBuildingProductionModifier(GameInfoTypes.BUILDING_GRANARY) / 100) then
						pCity:SetNumRealBuilding(GameInfoTypes.BUILDING_GRANARY, 1);
						iProd = iProd - pPlayer:GetBuildingProductionNeeded(GameInfoTypes.BUILDING_GRANARY) / (1 + pCity:GetBuildingProductionModifier(GameInfoTypes.BUILDING_GRANARY) / 100);
					end
				elseif pCity:CanConstruct(GameInfoTypes.BUILDING_MONUMENT) and iCityCount < 20 then
					--print("Checking if can build BUILDING_MONUMENT");
					if iProd >= pPlayer:GetBuildingProductionNeeded(GameInfoTypes.BUILDING_MONUMENT) / (1 + pCity:GetBuildingProductionModifier(GameInfoTypes.BUILDING_MONUMENT) / 100) then
						pCity:SetNumRealBuilding(GameInfoTypes.BUILDING_MONUMENT, 1);
						iProd = iProd - pPlayer:GetBuildingProductionNeeded(GameInfoTypes.BUILDING_MONUMENT) / (1 + pCity:GetBuildingProductionModifier(GameInfoTypes.BUILDING_MONUMENT) / 100);
					end
				elseif pCity:CanTrain(GameInfoTypes.UNIT_SETTLER) and ((iSettlers < 1 and iCityCount < iBuildSettlerLimit - iBuildSecondSettlerLimit) or (Game.GetElapsedGameTurns() > frequency * 5 and iSettlers < 2 and iCityCount < iBuildSecondSettlerLimit)) then
					--print("Checking if can build UNIT_SETTLER");
					if iProd >= pPlayer:GetUnitProductionNeeded(GameInfoTypes.UNIT_SETTLER) / (1 + pCity:GetUnitProductionModifier(GameInfoTypes.UNIT_SETTLER) / 100) then
						pPlayer:InitUnit(GameInfoTypes.UNIT_SETTLER, pCity:GetX(), pCity:GetY());
						iSettlers = iSettlers + 1;
						iProd = iProd - (pPlayer:GetUnitProductionNeeded(GameInfoTypes.UNIT_SETTLER) / (1 + pCity:GetUnitProductionModifier(GameInfoTypes.UNIT_SETTLER) / 100));
					end
				elseif pCity:CanConstruct(GameInfoTypes.BUILDING_LIBRARY) and iCityCount < 20 then
					--print("Checking if can build BUILDING_LIBRARY");
					if iProd >= pPlayer:GetBuildingProductionNeeded(GameInfoTypes.BUILDING_LIBRARY) / (1 + pCity:GetBuildingProductionModifier(GameInfoTypes.BUILDING_LIBRARY) / 100) then
						pCity:SetNumRealBuilding(GameInfoTypes.BUILDING_LIBRARY, 1);
						iProd = iProd - pPlayer:GetBuildingProductionNeeded(GameInfoTypes.BUILDING_LIBRARY) / (1 + pCity:GetBuildingProductionModifier(GameInfoTypes.BUILDING_LIBRARY) / 100);
					end
				else
					--print("Nothing to build, returning production");
					pCity:SetOverflowProduction(pCity:GetOverflowProduction() + iProd);
					iProd = 0;
				end

				--print(iProd .. " production for city");

				iCityCount = iCityCount + 1;
				save(pPlayer, sProd .. iCity, iProd);
				save(pPlayer, sSettlers .. iCity, iSettlers);
			end

		elseif Game.GetElapsedGameTurns() == frequency * 10 then
			for pCity in pPlayer:Cities() do
				local iCity = pCity:GetID();
				local iProd = load(pPlayer, sProd .. iCity);
				if iProd == nil then 
					iProd = 0;
				end
				--print("Nothing to build, returning production");
				pCity:SetOverflowProduction(pCity:GetOverflowProduction() + iProd);
				iProd = 0;
				save(pPlayer, sProd .. iCity, iProd);
			end
		else
			-- If the turn is over 10xfrequency, add units to queue for production


			for pCity in pPlayer:Cities() do
				
				local iCity = pCity:GetID();
				local iProd = load(pPlayer, sProd .. iCity);
				if iProd == nil then 
					iProd = 0;
				end
				local iThingToProduce = load(pPlayer, sThingToProduce .. iCity);
				if iThingToProduce == nil then 
					iThingToProduce = -1; 
				end
				--print(iProd .. " production, adding " .. (pCity:GetOverflowProduction()  + pCity:GetProduction()) .. " production");
				
				iProd = iProd + pCity:GetOverflowProduction() + pCity:GetProduction();
				--print(iProd .. " production after addition");
				pCity:SetProduction(0);


				if iThingToProduce > -1 or iThingToProduce == -2 then
				-- Create table of buildable units
					
					if iThingToProduce == -2 or not pCity:CanTrain(iThingToProduce) then
						--print("Selecting new target unit");
						--Update target unit
						local pWeights = {};
						local iWeightsSize = 0;
						local iTotalWeight = 0;
						for i = 0, iUnitsSize do
							pWeights[i] = 0;
							iWeightsSize = iWeightsSize + 1;
							local pUnit = unitsTable[i];
							local iUnit = unitsIDTable[i];
							if pUnit ~= nil and pCity:CanTrain(iUnit) then
								local iWeight = GameInfo.Units[iUnit].Combat;
								if GameInfo.Units[iUnit].RangedCombat > 0 then
									iWeight = (iWeight + GameInfo.Units[iUnit].RangedCombat) / 2;
								end
								if iUnit == iCascosUnit then
									iWeight = iWeight * 4;
								end
								pWeights[i] = iWeight;
								iTotalWeight = iTotalWeight + iWeight;
								--print("Unit " .. iUnit .. " given weight of " .. iWeight .. " for a total of " .. iTotalWeight);

							end
						end

						if iTotalWeight > 0 then
							local iRandB = Game.Rand(iTotalWeight, "Randomly selecting unit");


						
							local iRandLeft = iRandB;
							for i = 0, iUnitsSize do
								iRandLeft = iRandLeft - pWeights[i];
								if iRandLeft < 0 then
									iThingToProduce = i;
									break;
								end
							end
						else
							iThingToProduce = -1;
						end

						--print("Selected unit " .. iThingToProduce);

					end

					if iThingToProduce >= 0 then
						--print("Checking if can build unit " .. iThingToProduce);
						if pCity:CanTrain(iThingToProduce) and iProd >= pPlayer:GetUnitProductionNeeded(iThingToProduce) / (1 + pCity:GetUnitProductionModifier(iThingToProduce) / 100) then
							pPlayer:InitUnit(iThingToProduce, pCity:GetX(), pCity:GetY());
							print("Initializing unit " .. iThingToProduce);
							--iSettlers = iSettlers + 1;
							iProd = iProd - (pPlayer:GetUnitProductionNeeded(iThingToProduce) / (1 + pCity:GetUnitProductionModifier(iThingToProduce) / 100));
							iThingToProduce = -1;
						end
					else
						--print("Nothing to build, returning production");
						pCity:SetOverflowProduction(pCity:GetOverflowProduction() + iProd);
						iProd = 0;
					end
					

				else 
					--print("Nothing to build, returning production");
					pCity:SetOverflowProduction(pCity:GetOverflowProduction() + iProd);
					iProd = 0;
				end
				save(pPlayer, sProd .. iCity, iProd);
				save(pPlayer, sThingToProduce .. iCity, iThingToProduce);


			end


		end
	end

end

GameEvents.PlayerDoTurn.Add(AIOBuildOverride);