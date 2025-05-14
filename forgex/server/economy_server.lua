addCommandHandler("addcoins", function(player, _, targetName, amount)
    if not hasPermission(player, "economy.manage") then
        outputChatBox("Você não tem permissão para usar este comando.", player, 255, 0, 0)
        return
    end

    local targetPlayer = getPlayerFromName(targetName)
    if not targetPlayer then
        outputChatBox("Jogador não encontrado.", player, 255, 0, 0)
        return
    end

    local amountNum = tonumber(amount)
    if not amountNum or amountNum <= 0 then
        outputChatBox("Quantidade inválida.", player, 255, 0, 0)
        return
    end

    addForgeCoins(targetPlayer, amountNum, "Administração")
    outputChatBox("Você adicionou " .. amountNum .. " ForgeCoins para " .. targetName .. ".", player, 0, 255, 0)
end)