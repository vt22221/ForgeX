-- ForgeX Battle Pass System (server-side) - Revisado & Persistente

-- Carrega configuração do battlepass de arquivo externo
local bpConfig = {}
local bpLevels = {}

local function loadBattlePassConfig()
    local f = fileOpen("data/battlepass.json")
    if f then
        local content = fileRead(f, fileGetSize(f))
        bpConfig = fromJSON(content) or {}
        fileClose(f)
        bpLevels = bpConfig.levels or {}
    else
        bpLevels = {}
    end
end
loadBattlePassConfig()

-- Carrega dados do battlepass do jogador
function getPlayerBattlePass(acc)
    local result = DB.query("SELECT json FROM battlepass WHERE acc=?", acc)
    return (result and result[1] and fromJSON(result[1].json)) or {level=1, xp=0, premium=false, claimed={}}
end

-- Salva dados do battlepass do jogador
function savePlayerBattlePass(acc, data)
    DB.exec("INSERT OR REPLACE INTO battlepass VALUES (?,?)", acc, toJSON(data))
end

function addBattlePassXP(acc, amount)
    local bp = getPlayerBattlePass(acc)
    bp.xp = (bp.xp or 0) + amount
    local lvl = bp.level or 1
    local nextLvl = bpLevels[lvl+1]
    while nextLvl and bp.xp >= nextLvl.xp do
        bp.level = lvl + 1
        lvl = bp.level
        triggerClientEvent(getPlayerFromAccount(acc), "forgex:showNotification", resourceRoot, "Battle Pass: Nível "..lvl.." alcançado!", 225,180,60)
        nextLvl = bpLevels[lvl+1]
    end
    savePlayerBattlePass(acc, bp)
end

function claimBattlePassReward(acc, level)
    local bp = getPlayerBattlePass(acc)
    if not bp.claimed then bp.claimed = {} end
    if (bp.level or 1) < level or bp.claimed[level] then return end
    local reward = bpLevels[level] and bpLevels[level].reward or nil
    if not reward then return end
    if reward.premium and not bp.premium then return end
    -- Prêmios
    if reward.lootbox then fx_giveItem(getPlayerFromAccount(acc), reward.lootbox, 1) end
    if reward.skin then fx_giveItem(getPlayerFromAccount(acc), reward.skin, 1) end
    if reward.cash then -- Implementar função de dinheiro conforme seu sistema
        -- DB.modifyPlayerMoney(getPlayerFromAccount(acc), reward.cash)
    end
    bp.claimed[level] = true
    savePlayerBattlePass(acc, bp)
    triggerClientEvent(getPlayerFromAccount(acc), "forgex:showNotification", resourceRoot, "Battle Pass: Recompensa do nível "..level.." coletada!", 225,200,20)
    triggerEvent("forgex:syncInventory", getPlayerFromAccount(acc))
end

function setBattlePassPremium(acc)
    local bp = getPlayerBattlePass(acc)
    if bp.premium then return end
    bp.premium = true
    savePlayerBattlePass(acc, bp)
    triggerClientEvent(getPlayerFromAccount(acc), "forgex:showNotification", resourceRoot, "Battle Pass Premium ativado!", 255,215,40)
end

-- Eventos XP, recompensa, premium
addEvent("forgex:battlepassAddXP", true)
addEventHandler("forgex:battlepassAddXP", root, function(xp)
    local acc = getAccountName(getPlayerAccount(client))
    addBattlePassXP(acc, xp)
end)

addEvent("forgex:claimBattlePassReward", true)
addEventHandler("forgex:claimBattlePassReward", root, function(level)
    local acc = getAccountName(getPlayerAccount(client))
    claimBattlePassReward(acc, level)
end)

addEvent("forgex:battlepassPremium", true)
addEventHandler("forgex:battlepassPremium", root, function()
    local acc = getAccountName(getPlayerAccount(client))
    setBattlePassPremium(acc)
end)

addEvent("forgex:requestBattlePass", true)
addEventHandler("forgex:requestBattlePass", root, function()
    local acc = getAccountName(getPlayerAccount(client))
    local bp = getPlayerBattlePass(acc)
    triggerClientEvent(client, "forgex:battlepassDataSync", resourceRoot, bp)
end)

addEvent("forgex:battlepassDataSync", true)
addEventHandler("forgex:battlepassDataSync", root, function()
    local acc = getAccountName(getPlayerAccount(client))
    local bp = getPlayerBattlePass(acc)
    triggerClientEvent(client, "forgex:battlepassDataSync", resourceRoot, bp)
end)

-- Comandos admin (exemplo de alguns principais, o resto pode ser adaptado conforme necessidade)
local function isAdmin(plr)
    return isObjectInACLGroup("user."..getAccountName(getPlayerAccount(plr)), aclGetGroup("Admin"))
end

addCommandHandler("bpaddxp", function(plr, _, acc, xp)
    if not isAdmin(plr) then return end
    if not acc or not xp then return end
    if not getAccount(acc) then
        outputChatBox("Conta não encontrada: "..tostring(acc), plr, 255, 100, 100)
        return
    end
    addBattlePassXP(acc, tonumber(xp))
    outputChatBox("Adicionado "..xp.." XP ao Battle Pass de "..acc, plr, 180,255,180)
end)

addCommandHandler("bpclaim", function(plr, _, acc, level)
    if not isAdmin(plr) then return end
    if not acc or not level then return end
    if not getAccount(acc) then
        outputChatBox("Conta não encontrada: "..tostring(acc), plr, 255, 100, 100)
        return
    end
    claimBattlePassReward(acc, tonumber(level))
    outputChatBox("Recompensa do Battle Pass nível "..level.." coletada para "..acc, plr, 180,255,180)
end)

addCommandHandler("bppremium", function(plr, _, acc)
    if not isAdmin(plr) then return end
    if not acc then return end
    if not getAccount(acc) then
        outputChatBox("Conta não encontrada: "..tostring(acc), plr, 255, 100, 100)
        return
    end
    setBattlePassPremium(acc)
    outputChatBox("Battle Pass Premium ativado para "..acc, plr, 180,255,180)
end)

addCommandHandler("bpsync", function(plr, _, acc)
    if not isAdmin(plr) then return end
    if not acc then return end
    if not getAccount(acc) then
        outputChatBox("Conta não encontrada: "..tostring(acc), plr, 255, 100, 100)
        return
    end
    local player = getPlayerFromAccount(getAccount(acc))
    if player then
        triggerEvent("forgex:requestBattlePass", player)
        outputChatBox("Sincronização do Battle Pass iniciada para "..acc, plr, 180,255,180)
    end
end)

addCommandHandler("bprestart", function(plr, _, acc)
    if not isAdmin(plr) then return end
    if not acc then return end
    if not getAccount(acc) then
        outputChatBox("Conta não encontrada: "..tostring(acc), plr, 255, 100, 100)
        return
    end
    savePlayerBattlePass(acc, {level=1, xp=0, premium=false, claimed={}})
    outputChatBox("Battle Pass redefinido para "..acc, plr, 180,255,180)
    local player = getPlayerFromAccount(getAccount(acc))
    if player then
        triggerClientEvent(player, "forgex:battlepassDataSync", resourceRoot, {level=1, xp=0, premium=false, claimed={}})
    end
end)