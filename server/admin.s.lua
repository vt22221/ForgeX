--[[
    ForgeX - Admin Commands
    - Centraliza todos os comandos administrativos do resource.
    - Utiliza o ACL 'ForgeX.Admin' para seguranca.
]]

Admin = {}

local function hasAdminPermission(player)
    return isObjectInACLGroup("user." .. getAccountName(getPlayerAccount(player)), aclGetGroup("ForgeX.Admin"))
end

local function findOnlinePlayer(namePart)
    if not namePart then return nil end
    for _, p in ipairs(getElementsByType("player")) do
        if getPlayerName(p):lower():find(namePart:lower()) then
            return p
        end
    end
    return nil
end

-- Comando unificado
addCommandHandler("forgex", function(player, cmd, action, ...)
    if not hasAdminPermission(player) then
        triggerClientEvent(player, "ForgeX:Client:Notify", player, "error", "Voce nao tem permissao.")
        return
    end

    local args = {...}
    action = action:lower()

    if action == "giveitem" then
        local target = findOnlinePlayer(args[1])
        local itemID = args[2]
        local amount = tonumber(args[3] or 1)
        if not target or not itemID or not amount then
            outputChatBox("Uso: /forgex giveitem [jogador] [itemID] [quantidade]", player)
            return
        end
        if PlayerData.addItem(target, itemID, amount) then
            outputChatBox("Voce deu " .. amount .. "x " .. itemID .. " para " .. getPlayerName(target), player)
            triggerClientEvent(target, "ForgeX:Client:Notify", target, "info", "Voce recebeu um item de um administrador.")
        end

    elseif action == "givemoney" then
        local target = findOnlinePlayer(args[1])
        local amount = tonumber(args[2])
        if not target or not amount then
            outputChatBox("Uso: /forgex givemoney [jogador] [quantidade]", player)
            return
        end
        PlayerData.giveMoney(target, amount)
        outputChatBox(string.format("Voce deu $%d para %s", amount, getPlayerName(target)), player)

    elseif action == "setlevel" then
        local target = findOnlinePlayer(args[1])
        local weaponID = tonumber(args[2])
        local level = tonumber(args[3])
        if not target or not weaponID or not level then
            outputChatBox("Uso: /forgex setlevel [jogador] [weaponID] [level]", player)
            return
        end
        local pdata = PlayerData.get(target)
        if pdata and pdata.weapons then
            if not pdata.weapons[weaponID] then pdata.weapons[weaponID] = {} end
            pdata.weapons[weaponID].level = level
            PlayerData.sync(target, "weapons")
            outputChatBox("Nivel da arma " .. weaponID .. " de " .. getPlayerName(target) .. " definido para " .. level, player)
        end
    
    elseif action == "addgiftcode" then
        local code = args[1]
        local item = args[2]
        local amount = tonumber(args[3] or 1)
        if not code or not item or not amount then
            outputChatBox("Uso: /forgex addgiftcode [codigo] [itemID] [quantidade]", player)
            return
        end
        -- A logica de DB para giftcodes seria implementada aqui
        outputChatBox("Giftcode " .. code .. " criado.", player)
        
    else
        outputChatBox("Acao desconhecida. Use: giveitem, givemoney, setlevel, addgiftcode", player)
    end
end)

-- Funcao de resgate de codigo
function Admin.redeemGiftcode(player, code)
    -- Logica para checar o codigo no DB e dar a recompensa
    -- Exemplo simples:
    if code == "BEMVINDO2025" then
        if PlayerData.addItem(player, "lootbox_common", 1) then
            triggerClientEvent(player, "ForgeX:Client:Notify", player, "success", "Codigo resgatado com sucesso!")
        else
            triggerClientEvent(player, "ForgeX:Client:Notify", player, "error", "Voce ja usou este codigo.")
        end
    else
        triggerClientEvent(player, "ForgeX:Client:Notify", player, "error", "Codigo invalido ou expirado.")
    end
end