-- ForgeX Ranked System (Client-side)

local rankedData = { elo = 0, division = "Bronze", history = {}, leaderboard = {} }
local isRankedUIVisible = false

addEvent("forgex:syncRanked", true)
addEventHandler("forgex:syncRanked", root, function(data)
    rankedData = data or rankedData
end)

addEventHandler("onClientResourceStart", resourceRoot, function()
    triggerServerEvent("forgex:requestRanked", localPlayer)
end)

bindKey("F4", "down", function()
    isRankedUIVisible = not isRankedUIVisible
    if isRankedUIVisible then
        triggerServerEvent("forgex:requestRanked", localPlayer)
    end
end)

addEventHandler("onClientKey", root, function(btn, press)
    if isRankedUIVisible and btn == "escape" and press then
        isRankedUIVisible = false
        cancelEvent()
    end
end)

function drawRankedUI()
    if not isRankedUIVisible then return end
    local x, y, w, h = 170, 120, 520, 360
    dxDrawRectangle(x, y, w, h, tocolor(25,30,40,210))
    dxDrawText("RANKED", x, y, x+w, y+40, tocolor(100,220,255), 1.4, "default-bold", "center", "top")
    dxDrawText("ELO: "..rankedData.elo, x+40, y+60, x+200, y+90, tocolor(255,255,255), 1, "default-bold")
    dxDrawText("Divisão: "..rankedData.division, x+200, y+60, x+w-40, y+90, tocolor(255,255,190), 1, "default-bold")
    dxDrawText("TOP 10:", x+40, y+110, x+120, y+130, tocolor(255,255,255), 1, "default-bold")
    for i, pl in ipairs(rankedData.leaderboard or {}) do
        dxDrawText(i..". "..pl.player.." | "..pl.elo.." ("..pl.division..")", x+60, y+110+i*18, x+w-80, y+110+i*18+16, tocolor(220,220,255), 0.95, "default")
    end
    dxDrawText("Histórico:", x+40, y+300, x+120, y+320, tocolor(255,255,255), 1, "default-bold")
    for i, hist in ipairs(rankedData.history or {}) do
        dxDrawText(hist.date.." "..hist.result.." "..hist.elo.." ("..hist.division..")", x+60, y+300+i*18, x+w-80, y+300+i*18+16, tocolor(220,255,220), 0.9, "default")
        if i >= 4 then break end
    end
end
addEventHandler("onClientRender", root, drawRankedUI)

addEvent("forgex:rankedDivisionUp", true)
addEventHandler("forgex:rankedDivisionUp", root, function(newDivision)
    outputChatBox("Parabéns! Você subiu para "..tostring(newDivision).."!")
end)

addEvent("forgex:rankedMatchResult", true)
addEventHandler("forgex:rankedMatchResult", root, function(result, elo, division)
    outputChatBox("Resultado: "..result.." | ELO: "..elo.." | Divisão: "..division)
end)
addEvent("forgex:rankedLeaderboardUpdate", true)
addEventHandler("forgex:rankedLeaderboardUpdate", root, function(leaderboard)
    rankedData.leaderboard = leaderboard or {}
    if isRankedUIVisible then
        triggerServerEvent("forgex:requestRanked", localPlayer)
    end
end)
addEvent("forgex:rankedHistoryUpdate", true)
addEventHandler("forgex:rankedHistoryUpdate", root, function(history)
    rankedData.history = history or {}
    if isRankedUIVisible then
        triggerServerEvent("forgex:requestRanked", localPlayer)
    end
end)
addEvent("forgex:rankedEloUpdate", true)
addEventHandler("forgex:rankedEloUpdate", root, function(elo, division)
    rankedData.elo = elo or rankedData.elo
    rankedData.division = division or rankedData.division
    if isRankedUIVisible then
        triggerServerEvent("forgex:requestRanked", localPlayer)
    end
end)
addEvent("forgex:rankedReset", true)
addEventHandler("forgex:rankedReset", root, function()
    rankedData.elo = 0
    rankedData.division = "Bronze"
    rankedData.history = {}
    rankedData.leaderboard = {}
    if isRankedUIVisible then
        triggerServerEvent("forgex:requestRanked", localPlayer)
    end
end)
addEventHandler("onClientResourceStart", resourceRoot, function()
    triggerServerEvent("forgex:requestRanked", localPlayer)
end)
addEvent("forgex:rankedDataSync", true)
addEventHandler("forgex:rankedDataSync", root, function(data)
    rankedData = data or rankedData
    if isRankedUIVisible then
        triggerServerEvent("forgex:requestRanked", localPlayer)
    end
end)
addEventHandler("onClientResourceStop", resourceRoot, function()
    isRankedUIVisible = false
    rankedData = { elo = 0, division = "Bronze", history = {}, leaderboard = {} }
end)
addEvent("forgex:rankedDataReset", true)
addEventHandler("forgex:rankedDataReset", root, function()
    rankedData = { elo = 0, division = "Bronze", history = {}, leaderboard = {} }
    if isRankedUIVisible then
        triggerServerEvent("forgex:requestRanked", localPlayer)
    end
end)
addEvent("forgex:rankedDataRequest", true)
addEventHandler("forgex:rankedDataRequest", root, function()
    triggerServerEvent("forgex:requestRanked", localPlayer)
end)
addEvent("forgex:rankedDataResponse", true)
addEventHandler("forgex:rankedDataResponse", root, function(data)
    rankedData = data or rankedData
    if isRankedUIVisible then
        triggerServerEvent("forgex:requestRanked", localPlayer)
    end
end)