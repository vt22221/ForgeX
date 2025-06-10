--[[
    ForgeX - Marketplace System
    - Logica de negocio para o marketplace.
    - Criacao, compra e remocao de listagens.
    - Utiliza o banco de dados diretamente para persistencia global.
]]

Marketplace = {}

function Marketplace.sendListingsToPlayer(player, filters)
    -- TODO: Implementar filtros se necessario
    local listings = DB.query("SELECT l.*, a.account_name as seller_name FROM marketplace_listings l JOIN accounts a ON l.seller_id = a.id ORDER BY l.timestamp DESC LIMIT 100")
    triggerClientEvent(player, "ForgeX:Client:UpdateData", player, "marketplace", listings or {})
end

function Marketplace.listItem(player, itemID, amount, price)
    local pdata = PlayerData.get(player)
    local playerID = getElementData(player, "dbid")

    if not pdata or not pdata.inventory[itemID] or pdata.inventory[itemID] < amount or price <= 0 then
        triggerClientEvent(player, "ForgeX:Client:Notify", player, "error", "Dados da listagem invalidos.")
        return
    end

    if PlayerData.removeItem(player, itemID, amount) then
        DB.exec("INSERT INTO marketplace_listings (seller_id, item_id, amount, price, timestamp) VALUES (?, ?, ?, ?, ?)",
            playerID, itemID, amount, price, getRealTime().timestamp)
        
        triggerClientEvent(player, "ForgeX:Client:Notify", player, "success", "Item listado no marketplace.")
        Marketplace.broadcastUpdate()
    else
        triggerClientEvent(player, "ForgeX:Client:Notify", player, "error", "Nao foi possivel remover o item do seu inventario.")
    end
end

function Marketplace.buyItem(player, listingID)
    local listingResult = DB.query("SELECT * FROM marketplace_listings WHERE listing_id = ?", listingID)
    if not listingResult or #listingResult == 0 then
        triggerClientEvent(player, "ForgeX:Client:Notify", player, "error", "Esta oferta nao existe mais.")
        return
    end

    local listing = listingResult[1]
    local buyerID = getElementData(player, "dbid")

    if listing.seller_id == buyerID then
        triggerClientEvent(player, "ForgeX:Client:Notify", player, "error", "Voce nao pode comprar seu proprio item.")
        return
    end

    if PlayerData.takeMoney(player, listing.price) then
        local seller = nil
        for _, p in ipairs(getElementsByType("player")) do
            if getElementData(p, "dbid") == listing.seller_id then
                seller = p
                break
            end
        end

        -- Se o vendedor estiver online, da o dinheiro na hora. Se nao, precisa de um sistema de 'caixa de correio' ou balanco offline.
        if seller then
            PlayerData.giveMoney(seller, listing.price)
            triggerClientEvent(seller, "ForgeX:Client:Notify", seller, "success", string.format("Seu item '%s' foi vendido por $%d!", listing.item_id, listing.price))
        else
            -- TODO: Adicionar dinheiro a uma tabela de 'unclaimed_money' para o vendedor pegar quando logar.
        end
        
        PlayerData.addItem(player, listing.item_id, listing.amount)
        DB.exec("DELETE FROM marketplace_listings WHERE listing_id = ?", listingID)
        
        triggerClientEvent(player, "ForgeX:Client:Notify", player, "success", "Item comprado com sucesso.")
        Marketplace.broadcastUpdate()
    else
        triggerClientEvent(player, "ForgeX:Client:Notify", player, "error", "Dinheiro insuficiente.")
    end
end

function Marketplace.removeListing(player, listingID)
    local playerID = getElementData(player, "dbid")
    local listingResult = DB.query("SELECT * FROM marketplace_listings WHERE listing_id = ? AND seller_id = ?", listingID, playerID)

    if not listingResult or #listingResult == 0 then
        triggerClientEvent(player, "ForgeX:Client:Notify", player, "error", "Oferta nao encontrada ou nao pertence a voce.")
        return
    end

    local listing = listingResult[1]
    if PlayerData.addItem(player, listing.item_id, listing.amount) then
        DB.exec("DELETE FROM marketplace_listings WHERE listing_id = ?", listingID)
        triggerClientEvent(player, "ForgeX:Client:Notify", player, "info", "Sua oferta foi removida do marketplace.")
        Marketplace.broadcastUpdate()
    end
end

-- Envia a lista atualizada para todos os jogadores
function Marketplace.broadcastUpdate()
    for _, p in ipairs(getElementsByType("player")) do
        Marketplace.sendListingsToPlayer(p)
    end
end