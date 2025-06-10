-- ForgeX Achievements System (Server-side) - Revisado & Persistente

local achievementsConfig = {}
local function loadAchievementsConfig()
    local f = fileOpen("data/achievements.json")
    if f then
        local content = fileRead(f, fileGetSize(f))
        achievementsConfig = fromJSON(content) or {}
        fileClose(f)
    end
end
loadAchievementsConfig()

-- Estrutura: playerAchievements[player] = { [achievementID] = { progress=0, unlocked=false, date=nil } }
local playerAchievements = {}

-- Carrega conquistas do banco ao logar
addEventHandler("onPlayerLogin", root, function()
    local player = source
    local playerID = DB.getPlayerID(player)
    playerAchievements[player] = {}
    for id, ach in pairs(achievementsConfig) do
        playerAchievements[player][id] = { progress = 0, unlocked = false, date = nil }
    end

    -- Busca progresso salvo
    local results = DB.query("SELECT * FROM player_achievements WHERE player_id = ?", playerID)
    if results then
        for _, row in ipairs(results) do
            if playerAchievements[player][row.achievement_id] then
                playerAchievements[player][row.achievement_id] = {
                    progress = tonumber(row.progress) or 0,
                    unlocked = row.unlocked == 1,
                    date = row.date
                }
            end
        end
    end
    triggerClientEvent(player, "forgex:syncAchievements", player, playerAchievements[player])
end)

-- Salva conquistas no banco ao sair
addEventHandler("onPlayerQuit", root, function()
    local player = source
    local playerID = DB.getPlayerID(player)
    if not playerAchievements[player] then return end
    for id, ach in pairs(playerAchievements[player]) do
        DB.exec(
            "INSERT OR REPLACE INTO player_achievements (player_id, achievement_id, progress, unlocked, date) VALUES (?, ?, ?, ?, ?)",
            playerID, id, ach.progress, ach.unlocked and 1 or 0, ach.date or ""
        )
    end
    playerAchievements[player] = nil
end)

-- Sincronização manual (caso precise)
addEvent("forgex:requestAchievements", true)
addEventHandler("forgex:requestAchievements", root, function()
    local plr = client
    if playerAchievements[plr] then
        triggerClientEvent(plr, "forgex:syncAchievements", plr, playerAchievements[plr])
    end
end)

-- Função para desbloquear conquista
function fx_unlockAchievement(player, id)
    if not playerAchievements[player] or not playerAchievements[player][id] then return end
    local ach = playerAchievements[player][id]
    if ach.unlocked then return end
    ach.unlocked = true
    ach.date = os.date("%y/%m/%d")
    ach.progress = achievementsConfig[id].goal or 1
    DB.exec(
        "INSERT OR REPLACE INTO player_achievements (player_id, achievement_id, progress, unlocked, date) VALUES (?, ?, ?, ?, ?)",
        DB.getPlayerID(player), id, ach.progress, 1, ach.date
    )
    -- Dar prêmio
    if achievementsConfig[id].reward then
        fx_giveItem(player, achievementsConfig[id].reward, 1)
    end
    triggerClientEvent(player, "forgex:achievementUnlocked", player, achievementsConfig[id].desc)
    triggerClientEvent(player, "forgex:syncAchievements", player, playerAchievements[player])
end

-- Event: progresso em conquista
addEvent("forgex:achievementProgressUpdate", true)
addEventHandler("forgex:achievementProgressUpdate", root, function(id, progress)
    local player = client
    if not playerAchievements[player] or not playerAchievements[player][id] then return end
    local ach = playerAchievements[player][id]
    ach.progress = progress
    if not ach.unlocked and ach.progress >= (achievementsConfig[id].goal or 1) then
        fx_unlockAchievement(player, id)
    else
        DB.exec(
            "INSERT OR REPLACE INTO player_achievements (player_id, achievement_id, progress, unlocked, date) VALUES (?, ?, ?, ?, ?)",
            DB.getPlayerID(player), id, ach.progress, ach.unlocked and 1 or 0, ach.date or ""
        )
        triggerClientEvent(player, "forgex:syncAchievements", player, playerAchievements[player])
    end
end)

-- Event: reset de conquista individual
addEvent("forgex:achievementReset", true)
addEventHandler("forgex:achievementReset", root, function(id)
    local player = client
    if playerAchievements[player] and playerAchievements[player][id] then
        playerAchievements[player][id] = { progress = 0, unlocked = false, date = nil }
        DB.exec(
            "INSERT OR REPLACE INTO player_achievements (player_id, achievement_id, progress, unlocked, date) VALUES (?, ?, ?, ?, ?)",
            DB.getPlayerID(player), id, 0, 0, ""
        )
        triggerClientEvent(player, "forgex:syncAchievements", player, playerAchievements[player])
    end
end)

-- Event: reset de todas as conquistas (admin)
addCommandHandler("resetachievements", function(plr, cmd, target)
    if not isObjectInACLGroup("user."..getAccountName(getPlayerAccount(plr)), aclGetGroup("Admin")) then return end
    local tgt = getPlayerFromName(target)
    if tgt and playerAchievements[tgt] then
        for id, _ in pairs(playerAchievements[tgt]) do
            playerAchievements[tgt][id] = { progress = 0, unlocked = false, date = nil }
            DB.exec(
                "INSERT OR REPLACE INTO player_achievements (player_id, achievement_id, progress, unlocked, date) VALUES (?, ?, ?, ?, ?)",
                DB.getPlayerID(tgt), id, 0, 0, ""
            )
        end
        triggerClientEvent(tgt, "forgex:syncAchievements", tgt, playerAchievements[tgt])
        outputChatBox("Conquistas de " .. getPlayerName(tgt) .. " resetadas.", plr)
    else
        outputChatBox("Jogador não encontrado ou sem conquistas.", plr)
    end
end)

-- Inicializa conquistas para jogadores conectados ao iniciar recurso
addEventHandler("onResourceStart", resourceRoot, function()
    for _, plr in ipairs(getElementsByType("player")) do
        local playerID = DB.getPlayerID(plr)
        playerAchievements[plr] = {}
        for id, ach in pairs(achievementsConfig) do
            playerAchievements[plr][id] = { progress = 0, unlocked = false, date = nil }
        end
        local results = DB.query("SELECT * FROM player_achievements WHERE player_id = ?", playerID)
        if results then
            for _, row in ipairs(results) do
                if playerAchievements[plr][row.achievement_id] then
                    playerAchievements[plr][row.achievement_id] = {
                        progress = tonumber(row.progress) or 0,
                        unlocked = row.unlocked == 1,
                        date = row.date
                    }
                end
            end
        end
        triggerClientEvent(plr, "forgex:syncAchievements", plr, playerAchievements[plr])
    end
end)

-- Garante limpeza ao reiniciar/parar recurso
addEventHandler("onResourceStop", resourceRoot, function()
    for plr, _ in pairs(playerAchievements) do
        playerAchievements[plr] = nil
    end
end)