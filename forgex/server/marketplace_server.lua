local marketplace = {}

-- Listar item no marketplace
function listMarketplaceItem(player, itemName, price)
    if not hasPermission(player, "marketplace.list") then
        outputChatBox("Você não tem permissão para listar itens no marketplace.", player, 255, 0, 0)
        return
    end

    if not itemName or not price or tonumber(price) <= 0 then
        outputChatBox("Parâmetros inválidos. Use: /listitem <item> <preço>", player, 255, 0, 0)
        return
    end

    table.insert(marketplace, {seller = player, item = itemName, price = tonumber(price)})
    outputChatBox("Item listado no marketplace: " .. itemName .. " por " .. price .. " ForgeCoins.", player, 0, 255, 0)
end

-- Comprar item no marketplace
function buyMarketplaceItem(player, itemIndex)
    if not marketplace[itemIndex] then
        outputChatBox("Item não encontrado.", player, 255, 0, 0)
        return
    end

    local item = marketplace[itemIndex]
    local balance = getForgeCoins(player)

    if balance < item.price then
        outputChatBox("Saldo insuficiente para comprar este item.", player, 255, 0, 0)
        return
    end

    removeForgeCoins(player, item.price, "Compra no marketplace")
    addForgeCoins(item.seller, item.price, "Venda no marketplace")
    outputChatBox("Você comprou " .. item.item .. " por " .. item.price .. " ForgeCoins.", player, 0, 255, 0)
    table.remove(marketplace, itemIndex)
end

-- Comandos
addCommandHandler("listitem", function(player, _, itemName, price)
    listMarketplaceItem(player, itemName, price)
end)

addCommandHandler("buyitem", function(player, _, itemIndex)
    buyMarketplaceItem(player, tonumber(itemIndex))
end)