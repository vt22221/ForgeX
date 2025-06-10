-- ForgeX Ranked System (Server-side)

local rankedData = {} -- [player] = {elo=1000, division="Bronze", history={...}}
local leaderboard = {} -- atualizado conforme necessário

local divisions = {
    {min=0, max=999, name="Bronze"},
    {min=1000, max=1299, name="Prata"},
    {min=1300, max=1599, name="Ouro"},
    {min=1600, max=1999, name="Diamante"},
    {min=2000, max=9999, name="Elite"}
}

function getDivision(elo)
    for _,d in ipairs(divisions) do
        if elo >= d.min and elo <= d.max then return d.name end
    end
    return "Bronze"
end

addEvent("forgex:requestRanked", true)
addEventHandler("forgex:requestRanked", root, function()
    local plr = client
    if not rankedData[plr] then
        rankedData[plr] = {elo=1000, division="Bronze", history={}}
    end
    -- Atualizar divisão
    rankedData[plr].division = getDivision(rankedData[plr].elo)
    -- Leaderboard
    leaderboard = {}
    for p,data in pairs(rankedData) do
        table.insert(leaderboard, {player=getPlayerName(p), elo=data.elo, division=data.division})
    end
    table.sort(leaderboard, function(a,b) return a.elo > b.elo end)
    local top10 = {}
    for i=1,math.min(10,#leaderboard) do table.insert(top10, leaderboard[i]) end
    triggerClientEvent(plr, "forgex:syncRanked", plr, {elo=rankedData[plr].elo, division=rankedData[plr].division, history=rankedData[plr].history, leaderboard=top10})
end)

-- Exemplo de função para registrar resultado de partida
function fx_rankedMatch(plr, result)
    if not rankedData[plr] then rankedData[plr] = {elo=1000, division="Bronze", history={}} end
    local change = (result=="win" and 30) or (result=="lose" and -20) or 0
    rankedData[plr].elo = math.max(0, rankedData[plr].elo + change)
    local oldDiv = rankedData[plr].division
    rankedData[plr].division = getDivision(rankedData[plr].elo)
    table.insert(rankedData[plr].history, 1, {result=result, elo=rankedData[plr].elo, division=rankedData[plr].division, date=os.date("%y/%m/%d")})
    if oldDiv ~= rankedData[plr].division then
        triggerClientEvent(plr, "forgex:rankedDivisionUp", plr, rankedData[plr].division)
    end
    triggerClientEvent(plr, "forgex:rankedMatchResult", plr, result, rankedData[plr].elo, rankedData[plr].division)
end
addEvent("forgex:rankedMatch", true)
addEventHandler("forgex:rankedMatch", root, function(result)
    fx_rankedMatch(client, result)
end)
addEvent("forgex:rankedLeaderboardUpdate", true)
addEventHandler("forgex:rankedLeaderboardUpdate", root, function()
    triggerClientEvent(root, "forgex:rankedLeaderboardUpdate", root, leaderboard)
end)
addEventHandler("onResourceStart", resourceRoot, function()
    -- Inicializa dados de ranked
    rankedData = {}
    leaderboard = {}
end)
addEvent("forgex:rankedReset", true)
addEventHandler("forgex:rankedReset", root, function()
    rankedData = {}
    leaderboard = {}
    triggerClientEvent(root, "forgex:rankedReset", root)
    outputDebugString("Ranked data reset for all players.")
end)
addEventHandler("onPlayerQuit", root, function()
    local plr = source
    if rankedData[plr] then
        rankedData[plr] = nil -- Limpa dados do jogador ao sair
    end
end)
-- Exemplo de integração com missões
addEvent("forgex:rankedMissionProgress", true)
addEventHandler("forgex:rankedMissionProgress", root, function(missionId, progress)
    local plr = client
    if not rankedData[plr] then rankedData[plr] = {elo=1000, division="Bronze", history={}} end
    if not rankedData[plr].missions then rankedData[plr].missions = {} end
    rankedData[plr].missions[missionId] = (rankedData[plr].missions[missionId] or 0) + progress
    triggerClientEvent(plr, "forgex:rankedMissionUpdate", plr, rankedData[plr].missions)
end)
function getRankedData(plr)
    return rankedData[plr] or {elo=1000, division="Bronze", history={}}
end
function getRankedLeaderboard()
    return leaderboard
end
-- Exemplo de integração com lootbox
addEvent("forgex:openLootbox", true)
addEventHandler("forgex:openLootbox", root, function(boxType)
    local plr = client
    if not rankedData[plr] then rankedData[plr] = {elo=1000, division="Bronze", history={}} end
    -- Exemplo de recompensa por abrir lootbox
    local reward = boxType == "rare" and 50 or 20
    rankedData[plr].elo = math.min(3000, rankedData[plr].elo + reward) -- Limite máximo de ELO
    fx_rankedMatch(plr, "win") -- Simula vitória para aumentar ELO
end)
-- Exemplo de integração com venda no marketplace
addEvent("forgex:marketplaceSell", true)
addEventHandler("forgex:marketplaceSell", root, function(skin, price)
    local plr = client
    if not rankedData[plr] then rankedData[plr] = {elo=1000, division="Bronze", history={}} end
    -- Exemplo de recompensa por venda
    local reward = math.min(100, price / 10) -- Limite máximo de recompensa
    rankedData[plr].elo = math.min(3000, rankedData[plr].elo + reward) -- Limite máximo de ELO
    fx_rankedMatch(plr, "win") -- Simula vitória para aumentar ELO
end)
addEvent("forgex:rankedUIVisibility", true)
addEventHandler("forgex:rankedUIVisibility", root, function(visible)
    isRankedUIVisible = visible
    if visible then
        triggerServerEvent("forgex:requestRanked", client)
    end
end)
-- Exemplo de integração com kills
addEvent("onPlayerWeaponKill", true)
addEventHandler("onPlayerWeaponKill", root, function(plr, weapon)
    local acc = getAccountName(getPlayerAccount(plr))
    if rankedData[plr] then
        updateMissionProgress(acc, "weapon_kill", weapon)
        fx_rankedMatch(plr, "win") -- Simula vitória para aumentar ELO
    end
end)
addEvent("forgex:rankedDataSync", true)
addEventHandler("forgex:rankedDataSync", root, function(data)
    if data and type(data) == "table" then
        rankedData = data
        for plr,data in pairs(rankedData) do
            data.division = getDivision(data.elo)
        end
        triggerClientEvent(root, "forgex:rankedDataSync", root, rankedData)
    end
end)
addEvent("forgex:rankedDataRequest", true)
addEventHandler("forgex:rankedDataRequest", root, function()
    local plr = client
    if rankedData[plr] then
        triggerClientEvent(plr, "forgex:rankedDataSync", plr, rankedData[plr])
    else
        triggerClientEvent(plr, "forgex:rankedDataSync", plr, {elo=1000, division="Bronze", history={}})
    end
end)
addEvent("forgex:rankedDataReset", true)
addEventHandler("forgex:rankedDataReset", root, function()
    local plr = client
    rankedData[plr] = {elo=1000, division="Bronze", history={}}
    triggerClientEvent(plr, "forgex:rankedDataSync", plr, rankedData[plr])
end)
-- Exemplo de integração com lootbox aberta
addEvent("forgex:openLootbox", true)
addEventHandler("forgex:openLootbox", root, function(boxType)
    local plr = client
    if not rankedData[plr] then rankedData[plr] = {elo=1000, division="Bronze", history={}} end
    -- Exemplo de recompensa por abrir lootbox
    local reward = boxType == "rare" and 50 or 20
    rankedData[plr].elo = math.min(3000, rankedData[plr].elo + reward) -- Limite máximo de ELO
    fx_rankedMatch(plr, "win") -- Simula vitória para aumentar ELO
end)