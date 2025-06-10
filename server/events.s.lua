--[[
    ForgeX - Server Event Handlers
    - Centraliza todos os 'addEvent' para comunicacao cliente -> servidor.
    - Mantem o codigo organizado e delega acoes para os modulos corretos.
]]

-- Evento de Request de Sincronizacao
-- O cliente pede todos os dados novamente, util para reabrir paineis.
addEvent("ForgeX:Server:RequestFullSync", true)
addEventHandler("ForgeX:Server:RequestFullSync", root, function()
    local playerData = PlayerData.get(client)
    if playerData then
        triggerClientEvent(client, "ForgeX:Client:SyncAllData", client, playerData)
    end
end)

--== SISTEMA DE INVENTARIO E LOOTBOX ==--
addEvent("ForgeX:Server:UseLootbox", true)
addEventHandler("ForgeX:Server:UseLootbox", root, function(itemID)
    Inventory.useLootbox(client, itemID)
end)

addEvent("ForgeX:Server:EquipSkin", true)
addEventHandler("ForgeX:Server:EquipSkin", root, function(weaponID, skinID)
    Inventory.equipSkin(client, weaponID, skinID)
end)


--== SISTEMA DE BATTLE PASS ==--
addEvent("ForgeX:Server:ClaimBattlepassReward", true)
addEventHandler("ForgeX:Server:ClaimBattlepassReward", root, function(level)
    Battlepass.claimReward(client, level)
end)


--== SISTEMA DE MARKETPLACE ==--
addEvent("ForgeX:Server:MarketplaceList", true)
addEventHandler("ForgeX:Server:MarketplaceList", root, function(filters)
    Marketplace.sendListingsToPlayer(client, filters)
end)

addEvent("ForgeX:Server:MarketplaceSellItem", true)
addEventHandler("ForgeX:Server:MarketplaceSellItem", root, function(itemID, amount, price)
    Marketplace.listItem(client, itemID, amount, price)
end)

addEvent("ForgeX:Server:MarketplaceBuyItem", true)
addEventHandler("ForgeX:Server:MarketplaceBuyItem", root, function(listingID)
    Marketplace.buyItem(client, listingID)
end)

addEvent("ForgeX:Server:MarketplaceRemoveListing", true)
addEventHandler("ForgeX:Server:MarketplaceRemoveListing", root, function(listingID)
    Marketplace.removeListing(client, listingID)
end)


--== SISTEMA DE GIFTCODE ==--
addEvent("ForgeX:Server:RedeemGiftcode", true)
addEventHandler("ForgeX:Server:RedeemGiftcode", root, function(code)
    -- A logica do giftcode agora estara dentro do modulo de admin/playerdata
    Admin.redeemGiftcode(client, code)
end)

-- Adicione outros eventos de sistemas aqui...
-- Ex: Contratos, Colecoes, Alugueis, etc.