--[[
    ForgeX - Inventory & Lootbox System
    - Logica de negocio para o inventario.
    - Abertura de lootboxes e aplicacao de skins.
    - Utiliza o PlayerData para persistencia.
]]

Inventory = {}

function Inventory.useLootbox(player, itemID)
    local pdata = PlayerData.get(player)
    if not pdata or not pdata.inventory[itemID] or pdata.inventory[itemID] < 1 then
        triggerClientEvent(player, "ForgeX:Client:Notify", player, "error", "Voce nao possui esta lootbox.")
        return
    end
    
    local lootboxType = itemID:gsub("lootbox_", "")
    local lootboxInfo = Config.lootboxes[lootboxType]
    if not lootboxInfo then
        triggerClientEvent(player, "ForgeX:Client:Notify", player, "error", "Configuracao da lootbox invalida.")
        return
    end
    
    -- Logica de sorteio baseada em chances
    local rewardsPool = lootboxInfo.rewards.comum -- Simplificado, poderia ter raro, epico, etc.
    local totalChance = 0
    for _, reward in ipairs(rewardsPool) do
        totalChance = totalChance + reward.chance
    end
    
    local roll = math.random(1, totalChance)
    local cumulativeChance = 0
    local prize = nil
    
    for _, reward in ipairs(rewardsPool) do
        cumulativeChance = cumulativeChance + reward.chance
        if roll <= cumulativeChance then
            prize = reward
            break
        end
    end
    
    if prize then
        PlayerData.removeItem(player, itemID, 1)
        PlayerData.addItem(player, prize.key, 1)
        
        -- Envia a notificacao e o evento de animacao para o cliente
        triggerClientEvent(player, "ForgeX:Client:Notify", player, "success", "Voce ganhou: " .. prize.key)
        triggerClientEvent(player, "ForgeX:Client:ShowLootboxAnimation", player, prize.key)
    else
        triggerClientEvent(player, "ForgeX:Client:Notify", player, "error", "Ocorreu um erro ao abrir a caixa.")
    end
end

function Inventory.equipSkin(player, weaponID, skinID)
    local pdata = PlayerData.get(player)
    if not pdata then return end

    if skinID ~= "default" and (not pdata.inventory[skinID] or pdata.inventory[skinID] < 1) then
        triggerClientEvent(player, "ForgeX:Client:Notify", player, "error", "Voce nao possui esta skin.")
        return
    end

    if not pdata.weapons then pdata.weapons = {} end
    if not pdata.weapons[weaponID] then pdata.weapons[weaponID] = {} end

    pdata.weapons[weaponID].skin = skinID
    PlayerData.sync(player, "weapons")
    triggerClientEvent(player, "ForgeX:Client:Notify", player, "info", "Skin equipada com sucesso.")
end