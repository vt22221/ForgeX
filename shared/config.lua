--[[
    ForgeX - Shared Configuration File
    Este arquivo contem configuracoes globais acessiveis pelo cliente e pelo servidor.
    Facilita o balanceamento e a personalizacao do resource.
]]

Config = {}

-- [[ EVOLUCAO DE ARMAS ]]
Config.XPPerKill = 50
Config.MaxLevel = 100
Config.XPFormula = function(level)
    -- Formula de progressao de XP (pode ser ajustada para ser mais ou menos dificil)
    return math.floor(100 * (level ^ 1.5))
end

-- [[ MODIFICACOES FUNCIONAIS ]]
-- Multiplicadores aplicados as propriedades originais da arma.
-- Ex: 0.8 de recoil = 20% de reducao de recuo.
Config.ModStats = {
    -- ID do Mod       { propriedade, valor, operacao ("multiply" ou "add") }
    ["mira"]        = { prop = "accuracy", value = 0.85, op = "multiply" }, -- Menor e melhor
    ["coronha"]     = { prop = "recoil", value = 0.75, op = "multiply" }, -- Menor e melhor
    ["gatilho"]     = { prop = "firerate", value = 1.15, op = "multiply" }, -- Maior e melhor
    ["cano"]        = { prop = "range", value = 1.20, op = "multiply" },  -- Maior e melhor
    ["lanterna"]    = { prop = "special", value = "flashlight" },
    ["silenciador"] = { prop = "special", value = "silencer" }
}

-- [[ BONUS DE DANO ]]
-- Bonus de dano percentual por nivel da arma. 0.005 = 0.5% por nivel.
Config.DamageBonusPerLevel = 0.005

-- [[ COMANDOS ]]
Config.OpenPanelCommand = "forgex"

-- [[ MARKETPLACE ]]
Config.MarketplaceTax = 0.05 -- 5% de taxa sobre as vendas.

-- [[ ARMAS ]]
-- Mapeia o ID da arma para um nome amigavel.
Config.WeaponNames = {
    [22] = "Colt 45",
    [23] = "Silenced Colt 45",
    [24] = "Desert Eagle",
    [29] = "SMG",
    [30] = "AK-47",
    [31] = "M4",
    [33] = "Rifle",
    [34] = "Sniper Rifle"
    -- Adicione outras armas aqui
}
-- [[ SKINS ]]
Config.SkinNames = {
    ["ak-47"] = "AK-47 Skin",
    ["m4"] = "M4 Skin",
    ["sniper_rifle"] = "Sniper Rifle Skin"
    -- Adicione outras skins aqui
}
-- [[ NOTIFICACOES ]]
Config.NotificationDuration = 5 -- Duração em segundos
Config.NotificationFadeTime = 0.5 -- Tempo de fade in/out em segundos
Config.NotificationFont = "default-bold"    -- Fonte usada nas notificações
Config.NotificationWidth = 450 -- Largura da notificação
Config.NotificationHeight = 50 -- Altura da notificação
-- [[ BATTLE PASS ]]
Config.BattlePassLevels = 100 -- Total de níveis do Battle Pass
Config.BattlePassXPPerLevel = 1000 -- XP necessário para subir de nível
Config.BattlePassRewards = {
    [1] = { free = "ak-47|skin1", premium = "m4|skin2" },
    [2] = { free = "sniper_rifle|skin3", premium = "desert_eagle|skin4" },
    -- Adicione mais níveis e recompensas conforme necessário
}
-- [[ LOOTBOXES ]]
Config.LootboxItems = {
    ["common"] = { "ak-47|skin1", "m4|skin2" },
    ["rare"] = { "sniper_rifle|skin3", "desert_eagle|skin4" },
    ["epic"] = { "colt_45|skin5", "silenced_colt_45|skin6" }
}
-- [[ MARKETPLACE ]]  
Config.MarketplaceItemLimit = 10 -- Limite de itens por venda
Config.MarketplaceItemPriceMin = 100 -- Preço mínimo de venda
Config.MarketplaceItemPriceMax = 100000 -- Preço máximo de venda
-- [[ MISC ]]
Config.MaxInventorySlots = 100 -- Limite máximo de slots no inventário
Config.MaxLootboxSlots = 50 -- Limite máximo de slots para lootboxes
-- [[ EVENTOS ]]    
Config.Events = {
    ["onPlayerJoin"] = "forgex:playerJoined",
    ["onPlayerLeave"] = "forgex:playerLeft",
    ["onWeaponLevelUp"] = "forgex:weaponLevelUp",
    ["onBattlePassUpdate"] = "forgex:battlePassUpdated"
}
-- [[ UTILITARIOS ]]
Config.Util = {}
Config.Util.isMouseInPosition = function(x, y, w, h)
    if not isCursorShowing() then return false end
    local mx, my = getCursorPosition()
    local sx, sy = guiGetScreenSize()
    mx, my = mx * sx, my * sy
    return mx >= x and mx <= x + w and my >= y and my <= y + h
end
-- [[ FUNCOES GLOBAIS ]]
Config.triggerNotification = function(msg, r, g, b)
    triggerEvent("forgex:showNotification", localPlayer, msg, r, g, b)
end
-- [[ FIM DO ARQUIVO ]]