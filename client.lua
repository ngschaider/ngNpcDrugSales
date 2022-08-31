local ESX = nil;
local lastPed = nil;

local isSelling = false;
local canSellToPed = false;

TriggerEvent('esx:getSharedObject', function(obj)
	ESX = obj;
end)

local function debugPrint(...)
	if Config.Debug then
		print(...);
	end
end

local function GetClosestPed()
	local peds  = GetGamePool("CPed")
	
	local playerPed = PlayerPedId();
	local playerPos = GetEntityCoords(playerPed);

	for _,ped in pairs(peds) do
		local coords = GetEntityCoords(ped);
		local dist = GetDistanceBetweenCoords(coords[1], coords[2], coords[3], playerPos[1], playerPos[2], playerPos[3], true);
		
		if dist < 1.5 then
			if not IsPedInAnyVehicle(ped, false) then
				if not IsPedDeadOrDying(ped) then
					if not IsPedAPlayer(ped) then
						if GetEntitySpeed(ped) > 0 then
							local pedType = GetPedType(ped);
							if pedType ~= 28 and pedType ~= 29 then 
								return ped;
							else
								--debugPrint("wrong ped type");
							end
						end							
					else
						--debugPrint("is player");
					end
				end
			else
				--debugPrint("is in vehicle");
			end
		end
	end
	
	return nil;
end

local function Tick()
	local ped = GetClosestPed();
	
	if ped and not isSelling and canSellToPed then
		ESX.ShowHelpNotification(_U("sell_drugs_help_notification"));
		if IsControlJustPressed(0, 51) then
			TrySellingToPed(ped);
		end
	end
	
	if ped then
		if ped ~= lastPed then
			debugPrint("ped change");
			local netId = NetworkGetNetworkIdFromEntity(ped);
			
			debugPrint("request ", ped);
			ESX.TriggerServerCallback("ngNpcDrugSales:GetItemCount", function(itemCount)
				ESX.TriggerServerCallback("ngNpcDrugSales:CanSellToPed", function(canSell)
					debugPrint("requested", ped, canSell);
					canSellToPed = canSell and itemCount > 0;
				end, netId);
			end, Config.SellableItem);			
		end
	end
	
	lastPed = ped;
end

function TrySellingToPed(ped)
	local netId = NetworkGetNetworkIdFromEntity(ped);
	TriggerServerEvent("ngNpcDrugSales:TryToSell", netId);
	canSellToPed = false;
	
	isSelling = true;
	
	SetEntityAsMissionEntity(ped);
	ClearPedTasksImmediately(ped);
	--FreezeEntityPosition(ped, true);
	
	ESX.TriggerServerCallback("ngNpcDrugSales:GetItemCount", function(itemCount)	
		local amount = math.random(Config.MinAmount, Config.MaxAmount);
		if amount > itemCount then 
			amount = itemCount;
		end

		local duration = (amount - Config.MinAmount) * (Config.MaxSellTime - Config.MinSellTime) / (Config.MaxAmount - Config.MinAmount) + Config.MinSellTime;
		local success = math.random() < Config.SuccessChance;
		if not success then 
			duration = Config.FailTime 
		end

		if math.random() < 0.5 then
			debugPrint("numero uno 1");
			-- think 3
			PlayAnimation(ped, "timetable@tracy@ig_8@base", "base", (duration - 1) * 1000);
		else
			debugPrint("numero dos 2");
			-- think 5
			PlayAnimation(ped, "mp_cp_welcome_tutthink", "b_think", (duration - 1) * 1000);
		end

		if math.random() < Config.SuccessChance then
			debugPrint("sell success", amount, duration);
			TriggerEvent('pogressBar:drawBar', duration * 1000, _U("selling_drugs"), function()	
				OnSellFinish(ped, true, amount);
			end);
		else
			debugPrint("sell fail");
			TriggerEvent('pogressBar:drawBar', Config.FailTime * 1000, _U("selling_drugs"), function()
				OnSellFinish(ped, false, amount);
			end);
		end
	end, Config.SellableItem);
end

function OnSellFinish(ped, success, amount)
	isSelling = false;
	
	local playerPed = PlayerPedId();
	local playerPos = GetEntityCoords(playerPed);
	local pedPos = GetEntityCoords(ped);
	local dist = GetDistanceBetweenCoords(playerPos, pedPos);
	
	if dist > 4 then
		ESX.ShowNotification(_U("customer_not_nearby"));
	else
		if IsPedDeadOrDying(ped) then	
			ESX.ShowNotification(_U("customer_is_dead"));
		else
			ClearPedTasksImmediately(ped);
				
			if success then
				--TaskStartScenarioInPlace(ped, "PROP_HUMAN_ATM", 0, false);
				PlayAnimation(ped, "mp_arresting", "a_uncuff", 2000);
				TriggerServerEvent("ngNpcDrugSales:SellDrugs", amount);
			else
				ESX.ShowNotification(_U("selling_drugs_failed"));
				if math.random() < Config.DispatchChance then
					local pos = GetEntityCoords(ped);
					debugPrint("police dispatch");
					TriggerServerEvent('esx_addons_gcphone:startCall', "police", _U("phone_message_text"));
					TriggerServerEvent('esx_addons_gcphone:startCall', "police", _U("phone_message_text"), {
						x = pos[1],
						y = pos[2],
						z = pos[3],
					});
				end
				
				local r = math.random();
				if r < 0.33 then
					PlayAnimation(ped, "anim@heists@ornate_bank@chat_manager", "fail", 4000);
				elseif r > 0.33 and r < 0.66 then
					PlayAnimation(ped, "gestures@m@standing@casual", "gesture_no_way", 2000);
				else
					PlayAnimation(ped, "anim@mp_player_intselfiethe_bird", "idle_a", 3000);
				end
			end	
		end
	end
	
	--FreezeEntityPosition(ped, false);
	--TaskWanderStandard(ped, 10.0, 10);
	SetPedAsNoLongerNeeded(ped);
end

function PlayAnimation(ped, dict, name, duration)
	TaskPlayAnim(ped, dict, name, 2.0, 2.0, duration, 1, 0, false, false, false);
end

Citizen.CreateThread(function()
	while true do
		Tick();
		Citizen.Wait(0);		
	end
end);




function LoadDict(dict)
  while not HasAnimDictLoaded(dict) do
    RequestAnimDict(dict)
    Wait(10)
  end
end