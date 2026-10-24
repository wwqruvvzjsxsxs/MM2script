local env = getgenv and getgenv() or _G
if env.NIGHT_JOB == game.JobId then return end -- защита от двойного запуска
env.NIGHT_JOB = game.JobId

local DELAY = 75        -- секунд после захода (поставь 90 для полутора минут)
local MODE = "black"    -- "black" = чёрный экран, "dim" = очень тёмный, но картинка остаётся

if not game:IsLoaded() then game.Loaded:Wait() end

local HttpService = game:GetService("HttpService")
local BASE = "https://raw.githubusercontent.com/wwqruvvzjsxsxs/MM2script/refs/heads/main/"

-- поставить себя в очередь на следующий перезаход
local q = queue_on_teleport or queueonteleport or (syn and syn.queue_on_teleport)
if q then q('loadstring(game:HttpGet("' .. BASE .. 'nightboot.lua"))()') end

task.wait(DELAY)

-- принудительно включить нужный режим в настройках Night Hub
local t = {}
pcall(function()
    if isfile("night_settings.json") then
        t = HttpService:JSONDecode(readfile("night_settings.json"))
    end
end)
if MODE == "black" then
    t.black, t.clock = true, true
else
    t.dim, t.dimv = true, 90
end
pcall(writefile, "night_settings.json", HttpService:JSONEncode(t))

pcall(function() loadstring(game:HttpGet(BASE .. "night.lua"))() end)
