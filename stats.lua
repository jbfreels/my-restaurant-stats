getgenv().showMOT = true;

local MONEY_FORMAT = 0
local TIME_FORMAT = 1

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()

-- Create GUI
local Window = Library.CreateLib("$$$$", "Serpent");
-- local playerSelectTab = Window:NewTab("Player Select");
local MainTab = Window:NewTab(game.Players.LocalPlayer.Name);

local statsSection = MainTab:NewSection("current money stats:");

local totalMoneyLabel = statsSection:NewLabel("0");
local moneyPerHourLabel = statsSection:NewLabel("hello");
local moneyPerSecondLabel = statsSection:NewLabel("0");
local playTimeLabel = statsSection:NewLabel("0");
local sinceLaunchMoneyLabel = statsSection:NewLabel("0");
local goButton = statsSection:NewButton("pause", "start/stop", function()
  if getgenv().showMOT == true then
    getgenv().showMOT = false
  else
    getgenv().showMOT = true
  end
  print("toggle: " .. tostring(getgenv().showMOT));
end)

Player = {};
Player.__index = Player;
function Player:Create(name, starttime, startmoney)
  local this = {
    name = name,
    startTime = starttime,
    startMoney = startmoney,
    totalMoney = 0
  }
  setmetatable(this, Player);
  self.__index = self;
  return this;
end

function Player:TotalMoney()
  self.totalMoney = game.Players[self.name].leaderstats.Cash.Value;
  return self.totalMoney;
end

function Player:MoneySinceLaunch()
  return self.totalMoney - self.startMoney;
end

function Player:LapTime()
  return os.clock() - self.startTime;
end

function Player:MoneyPerHour()
  local g = self:TotalMoney() - self.startMoney;
  local t = os.clock() - self.startTime;
  local multi = 3600 / t;
  return g * multi;
end

function Player:MoneyPerSecond()
  local g = self:TotalMoney() - self.startMoney;
  local t = os.clock() - self.startTime;
  return g / t;
end

function FormatNum(n, t)
  if t == MONEY_FORMAT then
    if n >= 10 ^ 9 then
      return string.format("%.3f B", n / 10 ^ 9);
    elseif n >= 10 ^ 6 then
      return string.format("%.3f M", n / 10 ^ 6);
    elseif n >= 10 ^ 3 then
      return string.format("%.3f k", n / 10 ^ 3);
    else
      return tostring(n);
    end
  elseif t == TIME_FORMAT then
    local days = math.floor(n / 86400);
    local hours = math.floor(math.fmod(n, 86400) / 3600);
    local minutes = math.floor(math.fmod(n, 3600) / 60);
    local seconds = math.floor(math.fmod(n, 60));
    return string.format(
      "%d:%02d:%02d:%02d",
      days, hours, minutes, seconds);
  else
    return "!! bad output type specified"
  end
end

print("starting money stats");

getgenv().stats = Player:Create(
  game.Players.LocalPlayer.Name,
  os.clock(),
  game.Players[game.Players.LocalPlayer.Name].leaderstats.Cash.Value
);

spawn(function()
  while true do
    wait(0.5);

    if getgenv().showMOT then

      local stats = getgenv().stats;

      -- time played
      local timePlayed = FormatNum(stats:LapTime(), TIME_FORMAT)
      playTimeLabel:UpdateLabel(timePlayed);

      -- total money
      local totalMoney = FormatNum(stats:TotalMoney(), MONEY_FORMAT);
      totalMoneyLabel:UpdateLabel("total money: " .. totalMoney);

      -- money since launch
      local moneySinceLaunch = FormatNum(stats:MoneySinceLaunch(), MONEY_FORMAT);
      sinceLaunchMoneyLabel:UpdateLabel("since launch you've made: " .. moneySinceLaunch);

      -- money per hour
      moneyPerHourLabel:UpdateLabel("per hour: " ..
        FormatNum(stats:MoneyPerHour(), MONEY_FORMAT));

      -- money per second
      moneyPerSecondLabel:UpdateLabel("per second: " ..
        FormatNum(stats:MoneyPerSecond(), MONEY_FORMAT));
    end
  end
end)
