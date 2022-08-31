local ESX = nil;

TriggerEvent("esx:getSharedObject", function(obj)
	ESX = obj;
end);

local lastDeal = {};

ESX.RegisterServerCallback("ngNpcDrugSales:GetItemCount", function(src, cb, item)
	local xPlayer = ESX.GetPlayerFromId(src);
	local itemCount = xPlayer.getInventoryItem(item).count;
	cb(itemCount);
end);

ESX.RegisterServerCallback("ngNpcDrugSales:CanSellToPed", function(src, cb, netId)	
	local jobCount = 0;
	for _,src in pairs(ESX.GetPlayers()) do
		local xPlayer = ESX.GetPlayerFromId(src);
		if xPlayer.getJob().name == Config.JobRequirement.JobName then
			jobCount = jobCount + 1;
		end
	end
	
	if jobCount < Config.JobRequirement.MinPlayers then
		debugPrint("not enough cops");
		cb(false);
		return;
	end

	local ped = NetworkGetEntityFromNetworkId(netId);
	
	if lastDeal[netId] then
		if lastDeal[netId] + Config.NpcCooldown * 60 * 1000 < GetGameTimer() then
			cb(true);
		else
			cb(false);
		end
	else
		cb(true);
	end
end);

RegisterNetEvent("ngNpcDrugSales:SellDrugs", function(amount)
	local xPlayer = ESX.GetPlayerFromId(source);
	
	local itemCount = xPlayer.getInventoryItem(Config.SellableItem).count;
	
	if amount > itemCount then
		print("Player " .. GetPlayerName(source) .. " / " .. xPlayer.name .. " (" .. xPlayer.identifier .. ") tried to sell more drugs than in inventory");
		return;
	end
	
	if amount > Config.MaxAmount then
		print("Player " .. GetPlayerName(source) .. " / " .. xPlayer.name .. " (" .. xPlayer.identifier .. ") tried to sell more drugs than possible");
		return;		
	end
	
	local price = math.random(Config.MinPrice, Config.MaxPrice);
	local total = price * amount;
	
	xPlayer.removeInventoryItem(Config.SellableItem, amount);
	xPlayer.addAccountMoney("black_money", total);
	
	xPlayer.showNotification(_U("selling_drugs_success", amount, total));
end);

RegisterNetEvent("ngNpcDrugSales:TryToSell", function(netId)
	lastDeal[netId] = GetGameTimer();
end);

function debugPrint(...)
	if Config.Debug then
		print(...);
	end
end