--[[
ForgeX Missions System
- Missões diárias e semanais, progresso persistente
- Pode ser integrada a UI, conquistas, battlepass, etc
- Funções e eventos reais, prontos para expansão
]]

Missions = {
    daily = {
        {id="ak47_kills", desc="Faça 20 kills com AK-47", type="weapon_kill", weapon="ak47", amount=20, reward={"lootbox", "rare"}},
        {id="lootbox_open", desc="Abra 3 lootboxes", type="lootbox_open", amount=3, reward={"skin", "ak47_gold"}}
    },
    weekly = {
        {id="market_sell", desc="Venda 5 skins no marketplace", type="market_sell", amount=5, reward={"cash", 1000}},
    }
}

PlayerMissionProgress = {}

function getPlayerMissionProgress(acc)
    if not PlayerMissionProgress[acc] then
        PlayerMissionProgress[acc] = {daily={}, weekly={}}
        for _,m in ipairs(Missions.daily) do PlayerMissionProgress[acc].daily[m.id]=0 end
        for _,m in ipairs(Missions.weekly) do PlayerMissionProgress[acc].weekly[m.id]=0 end
    end
    return PlayerMissionProgress[acc]
end

function savePlayerMissionProgress(acc)
    -- Sugestão: salve progresso no banco se quiser persistir entre reinícios
    -- Exemplo: dbExec(ForgeXDB.db, "INSERT OR REPLACE INTO missions VALUES (?,?)", acc, toJSON(PlayerMissionProgress[acc]))
end

function updateMissionProgress(acc, missionType, weapon)
    local prog = getPlayerMissionProgress(acc)
    -- Diárias
    for _,m in ipairs(Missions.daily) do
        if m.type==missionType and (not m.weapon or m.weapon==weapon) then
            prog.daily[m.id]=math.min(m.amount, (prog.daily[m.id] or 0)+1)
            if prog.daily[m.id]==m.amount then
                giveMissionReward(acc, m.reward)
                triggerClientEvent(getPlayerFromAccount(acc), "forgex:showNotification", resourceRoot, "Missão diária completa: "..m.desc, 80,255,255)
            end
        end
    end
    -- Semanais
    for _,m in ipairs(Missions.weekly) do
        if m.type==missionType and (not m.weapon or m.weapon==weapon) then
            prog.weekly[m.id]=math.min(m.amount, (prog.weekly[m.id] or 0)+1)
            if prog.weekly[m.id]==m.amount then
                giveMissionReward(acc, m.reward)
                triggerClientEvent(getPlayerFromAccount(acc), "forgex:showNotification", resourceRoot, "Missão semanal completa: "..m.desc, 255,200,80)
            end
        end
    end
    savePlayerMissionProgress(acc)
end

function giveMissionReward(acc, reward)
    if reward[1]=="lootbox" then ForgeXDB.addLootbox(acc, reward[2], 1)
    elseif reward[1]=="skin" then ForgeXDB.addPlayerSkin(acc, reward[2])
    elseif reward[1]=="cash" then ForgeXDB.giveMoney(acc, reward[2])
    end
    triggerEvent("forgex:syncInventory", getPlayerFromAccount(acc))
end

-- EVENTOS reais: chame updateMissionProgress sempre que ação relevante ocorrer
addEvent("forgex:missionEvent", true)
addEventHandler("forgex:missionEvent", root, function(missionType, weapon)
    local acc = getAccountName(getPlayerAccount(client))
    updateMissionProgress(acc, missionType, weapon)
end)

-- Exemplo de integração com kills
addEvent("onPlayerWeaponKill", true)
addEventHandler("onPlayerWeaponKill", root, function(plr, weapon)
    local acc = getAccountName(getPlayerAccount(plr))
    updateMissionProgress(acc, "weapon_kill", weapon)
end)

-- Exemplo de integração com lootbox aberta
addEvent("forgex:openLootbox", true)
addEventHandler("forgex:openLootbox", root, function(boxType)
    local acc = getAccountName(getPlayerAccount(client))
    updateMissionProgress(acc, "lootbox_open")
end)

-- Exemplo de integração com venda no marketplace:
-- updateMissionProgress(acc, "market_sell")

-- Reinício diário/semanal (reset progresso)
function resetDailyMissions()
    for acc, p in pairs(PlayerMissionProgress) do
        for _,m in ipairs(Missions.daily) do p.daily[m.id]=0 end
    end
    -- Salve se persistir no banco
    for acc, p in pairs(PlayerMissionProgress) do
        savePlayerMissionProgress(acc)
    end
    triggerEvent("forgex:syncMissions", root) -- Notifica clientes sobre reset
    triggerEvent("forgex:showNotification", root, "Missões diárias foram reiniciadas!", 80, 255, 80)
    outputDebugString("Missões diárias reiniciadas para todos os jogadores.")
    -- Debug: Exibe progresso atual
    for acc, p in pairs(PlayerMissionProgress) do
        outputDebugString("Progresso de missões diárias para " .. acc .. ": " .. toJSON(p.daily))
    end
end

function resetWeeklyMissions()
    for acc, p in pairs(PlayerMissionProgress) do
        for _,m in ipairs(Missions.weekly) do p.weekly[m.id]=0 end
    end
    -- Salve se persistir no banco
    for acc, p in pairs(PlayerMissionProgress) do
        savePlayerMissionProgress(acc)
    end
    triggerEvent("forgex:syncMissions", root) -- Notifica clientes sobre reset
    triggerEvent("forgex:showNotification", root, "Missões semanais foram reiniciadas!", 255, 200, 80)
    outputDebugString("Missões semanais reiniciadas para todos os jogadores.")
    -- Debug: Exibe progresso atual
    for acc, p in pairs(PlayerMissionProgress) do
        outputDebugString("Progresso de missões semanais para " .. acc .. ": " .. toJSON(p.weekly))
    end
end

setTimer(resetDailyMissions, 24*60*60*1000, 0)   -- todo dia
setTimer(resetWeeklyMissions, 7*24*60*60*1000, 0) -- toda semana
addEventHandler("onResourceStart", resourceRoot, function()
    -- Inicializa progresso de missões para todos os jogadores
    for _, plr in ipairs(getElementsByType("player")) do
        local acc = getAccountName(getPlayerAccount(plr))
        getPlayerMissionProgress(acc) -- Garante que o progresso exista
    end
    outputDebugString("Sistema de missões iniciado.")
end)
addEventHandler("onResourceStop", resourceRoot, function()
    -- Salva progresso de missões ao parar o recurso
    for acc, p in pairs(PlayerMissionProgress) do
        savePlayerMissionProgress(acc)
    end
    outputDebugString("Sistema de missões parado. Progresso salvo.")
end)