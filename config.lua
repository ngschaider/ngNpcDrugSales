Config = {};

Config.Debug = true;
Config.Locale = "de";

Config.FailTime = 5;
Config.MinSellTime = 5; -- min amount of time one deal takes
Config.MaxSellTime = 5; -- max amount of time one deal takes

Config.MinAmount = 1; -- min amount of items sold in one deal
Config.MaxAmount = 3; -- max amount of items sold in one deal

Config.MinPrice = 250; -- min price per item
Config.MaxPrice = 440; -- max price per item

Config.SuccessChance = 0.5; -- chance for a deal to succeed
Config.DispatchChance = 0.10; -- chance for a failed deal to trigger a dispatch

Config.NpcCooldown = 5; -- disable dealing with that npc for x minutes

Config.SellableItem = "kokaintuetchen";

Config.JobRequirement = {
	MinPlayers = 0,
	JobName = "police",
};