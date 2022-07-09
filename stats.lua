getgenv().userName = 0;
getgenv().showMOT = true;
getgenv().startMoney = 0;
getgenv().totalMoney = 0;
getgenv().allPlayers = {};

local MONEY_FORMAT = 0
local TIME_FORMAT = 1

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()


-- Create GUI
local Window = Library.CreateLib("$$$$", "DarkTheme");
-- local playerSelectTab = Window:NewTab("Player Select");
local MainTab = Window:NewTab("$$/h");

local playerSelectSection = MainTab:NewSection("Players");
local statsSection = MainTab:NewSection("Stats");

local playerDropdown = playerSelectSection:NewDropdown(
  "Player",
  "Select Player",
  {},
  function(selected)
    print(string.format("user selected: %s", selected))
    getgenv().userName = selected;
    getgenv().startTime = os.clock();
    getgenv().startMoney = game.Players[selected].leaderstats.Cash.Value;
  end
);

local totalMoneyLabel = statsSection:NewLabel("Total Money");
local moneyPerHourLabel = statsSection:NewLabel("$/h");
local moneyPerSecondLabel = statsSection:NewLabel("$/s");
local playTimeLabel = statsSection:NewLabel("Play Time");

-- formatNum(Number)
--   format a number for human readable output
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

-- GameGetPlayers
--  returns a list of all current players
function GameGetPlayers()
  local players = {}
  for i, v in pairs(game.Players:GetChildren()) do
    table.insert(players, v.Name);
  end
  return players;
end

print("starting: ", getgenv().showMOT);

spawn(function()
  while getgenv().showMOT do

    -- wait half a second
    wait(0.5);

    -- get list of players
    playerDropdown:Refresh(GameGetPlayers());

    -- no user selected, leave
    if getgenv().userName == 0 then
      print("user not selected");
    else
      -- get current amount of money
      getgenv().totalMoney = game.Players[getgenv().userName].leaderstats.Cash.Value;

      -- how much money we've earned since start
      local growth = getgenv().totalMoney - getgenv().startMoney;

      -- how much time has passed
      local tickTime = os.clock() - getgenv().startTime;

      -- multiplier based on s/h
      local hourMulti = 3600 / tickTime;
      local secMulti = growth / tickTime;

      -- total earnings * time over an hour
      local moneyPerHour = FormatNum(growth * hourMulti, MONEY_FORMAT);
      local moneyPerSec = FormatNum(secMulti, MONEY_FORMAT);

      moneyPerHourLabel:UpdateLabel(string.format("$/h: %s", moneyPerHour));
      totalMoneyLabel:UpdateLabel(
        string.format(
          "total: %s", FormatNum(getgenv().totalMoney, MONEY_FORMAT)
        )
      );

      moneyPerSecondLabel:UpdateLabel(string.format("$/s: %s", moneyPerSec));

      playTimeLabel:UpdateLabel(
        string.format(
          "time: %s", FormatNum(tickTime, TIME_FORMAT)
        )
      );
    end
  end
end)
