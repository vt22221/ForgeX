-- ForgeX™ - Ferramentas Administrativas
-- Este arquivo oferece comandos e funções administrativas para gerenciar o servidor.

-- Lista de comandos administrativos protegidos por ACL
local adminCommands = {
    kick = "admin.kick",
    ban = "admin.ban",
    mute = "admin.mute",
    unmute = "admin.unmute",
    givecoins = "admin.givecoins",
    setgroup = "admin.setgroup"
}

-- Função para verificar permissões administrativas
local function hasAdminPermission(player, permission)
    if not exports.acl_server:hasPermission(player, permission) then
        outputChatBox("Você não tem permissão para usar este comando.", player, 255, 0, 0)
        return false
    end
    return true
end

-- Comando: Expulsar jogador
addCommandHandler("kick", function(player, _, targetName, ...)
    if not hasAdminPermission(player, adminCommands.kick) then return end

    local targetPlayer = getPlayerFromName(targetName)
    if not targetPlayer then
        outputChatBox("Jogador não encontrado.", player, 255, 0, 0)
        return
    end

    local reason = table.concat({...}, " ")
    reason = reason ~= "" and reason or "Sem motivo especificado"
    kickPlayer(targetPlayer, player, reason)
    outputChatBox("Jogador " .. targetName .. " foi expulso. Motivo: " .. reason, root, 255, 165, 0)
end)

-- Comando: Banir jogador
addCommandHandler("ban", function(player, _, targetName, duration, ...)
    if not hasAdminPermission(player, adminCommands.ban) then return end

    local targetPlayer = getPlayerFromName(targetName)
    if not targetPlayer then
        outputChatBox("Jogador não encontrado.", player, 255, 0, 0)
        return
    end

    local banDuration = tonumber(duration) or 0 -- 0 significa banimento permanente
    local reason = table.concat({...}, " ")
    reason = reason ~= "" and reason or "Sem motivo especificado"
    
    banPlayer(targetPlayer, true, false, player, reason, banDuration)
    local banMessage = "Jogador " .. targetName .. " foi banido"
    if banDuration > 0 then
        banMessage = banMessage .. " por " .. banDuration .. " minutos"
    end
    banMessage = banMessage .. ". Motivo: " .. reason
    outputChatBox(banMessage, root, 255, 0, 0)
end)

-- Comando: Mutar jogador
addCommandHandler("mute", function(player, _, targetName, duration)
    if not hasAdminPermission(player, adminCommands.mute) then return end

    local targetPlayer = getPlayerFromName(targetName)
    if not targetPlayer then
        outputChatBox("Jogador não encontrado.", player, 255, 0, 0)
        return
    end

    local muteDuration = tonumber(duration) or 5 -- Padrão de 5 minutos
    setPlayerMuted(targetPlayer, true)
    outputChatBox("Jogador " .. targetName .. " foi mutado por " .. muteDuration .. " minutos.", root, 255, 165, 0)

    -- Desmutar automaticamente após o tempo especificado
    setTimer(function()
        setPlayerMuted(targetPlayer, false)
        outputChatBox("Jogador " .. getPlayerName(targetPlayer) .. " foi desmutado automaticamente.", root, 255, 165, 0)
    end, muteDuration * 60000, 1)
end)

-- Comando: Desmutar jogador
addCommandHandler("unmute", function(player, _, targetName)
    if not hasAdminPermission(player, adminCommands.unmute) then return end

    local targetPlayer = getPlayerFromName(targetName)
    if not targetPlayer then
        outputChatBox("Jogador não encontrado.", player, 255, 0, 0)
        return
    end

    setPlayerMuted(targetPlayer, false)
    outputChatBox("Jogador " .. targetName .. " foi desmutado.", root, 255, 165, 0)
end)

-- Comando: Dar ForgeCoins a um jogador
addCommandHandler("givecoins", function(player, _, targetName, amount)
    if not hasAdminPermission(player, adminCommands.givecoins) then return end

    local targetPlayer = getPlayerFromName(targetName)
    if not targetPlayer then
        outputChatBox("Jogador não encontrado.", player, 255, 0, 0)
        return
    end

    local coinAmount = tonumber(amount)
    if not coinAmount or coinAmount <= 0 then
        outputChatBox("Quantidade inválida. Use: /givecoins <jogador> <quantidade>", player, 255, 0, 0)
        return
    end

    exports.economy_server:addForgeCoins(targetPlayer, coinAmount, "Administração")
    outputChatBox("Você deu " .. coinAmount .. " ForgeCoins para " .. targetName .. ".", player, 0, 255, 0)
end)

-- Comando: Alterar grupo ACL de um jogador
addCommandHandler("setgroup", function(player, _, targetName, groupName)
    if not hasAdminPermission(player, adminCommands.setgroup) then return end

    local targetAccount = getAccount(targetName)
    if not targetAccount then
        outputChatBox("Conta do jogador não encontrada.", player, 255, 0, 0)
        return
    end

    local aclGroup = aclGetGroup(groupName)
    if not aclGroup then
        outputChatBox("Grupo ACL não encontrado.", player, 255, 0, 0)
        return
    end

    aclGroupAddObject(aclGroup, "user." .. targetName)
    outputChatBox("Jogador " .. targetName .. " foi adicionado ao grupo ACL " .. groupName .. ".", player, 0, 255, 255)
end)

-- Mensagem de boas-vindas para administradores
addEventHandler("onPlayerLogin", root, function(_, account)
    local player = source
    if exports.acl_server:hasPermission(player, "admin.view") then
        outputChatBox("Bem-vindo(a), administrador(a) " .. getPlayerName(player) .. "!", player, 0, 255, 255)
    end
end)