local PlaceID = game.PlaceId
local AllIDs = {}
local foundAnything = ""
local actualHour = os.date("!*t").hour
local Deleted = false
local File = pcall(function()
    AllIDs = game:GetService('HttpService'):JSONDecode(readfile("NotSameServers.json"))
end)
if not File then
    table.insert(AllIDs, {id = actualHour, timestamp = os.time()})
    writefile("NotSameServers.json", game:GetService('HttpService'):JSONEncode(AllIDs))
end

function RemoveOldServers()
    local currentTime = os.time()
    for i = #AllIDs, 1, -1 do
        if currentTime - AllIDs[i].timestamp > 60 then
            table.remove(AllIDs, i)
        end
    end
end

function TPReturner()
    local Site
    if foundAnything == "" then
        Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100'))
    else
        Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100&cursor=' .. foundAnything))
    end
    local ID = ""
    if Site.nextPageCursor and Site.nextPageCursor ~= "null" and Site.nextPageCursor ~= nil then
        foundAnything = Site.nextPageCursor
    end
    local num = 0
    for i, v in pairs(Site.data) do
        local Possible = true
        ID = tostring(v.id)
        if tonumber(v.maxPlayers) > tonumber(v.playing) then
            for _, Existing in pairs(AllIDs) do
                if num ~= 0 then
                    if ID == tostring(Existing.id) then
                        Possible = false
                    end
                else
                    if tonumber(actualHour) ~= tonumber(Existing.id) then
                        local delFile = pcall(function()
                            delfile("NotSameServers.json")
                            AllIDs = {}
                            table.insert(AllIDs, {id = actualHour, timestamp = os.time()})
                        end)
                    end
                end
                num = num + 1
            end
            if Possible == true then
                table.insert(AllIDs, {id = ID, timestamp = os.time()})
                wait()
                pcall(function()
                    RemoveOldServers()
                    writefile("NotSameServers.json", game:GetService('HttpService'):JSONEncode(AllIDs))
                    wait()
                    game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceID, ID, game.Players.LocalPlayer)
                end)
                wait(2.5)
            end
        end
    end
end

function Teleport()
    while wait() do
        pcall(function()
            TPReturner()
            if foundAnything ~= "" then
                TPReturner()
            end
        end)
    end
end

local NotificationLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/IceMinisterq/Notification-Library/Main/Library.lua"))()
gamevalue = game:GetService("ReplicatedStorage"):WaitForChild("ReplicatedInfo"):WaitForChild("CurrentStage").Value
real = [[loadstring(game:HttpGet("https://raw.githubusercontent.com/evilionx3/serverhop/refs/heads/main/main.lua"))()]]
if gamevalue == "2" then
    NotificationLibrary:SendNotification("Success", "Found server!! :D", 3)
else
    queue_on_teleport(real)
    NotificationLibrary:SendNotification("Error", "Server isnt currently in runway, serverhopping", 9999)
    Teleport()
end
