local warnings = {}

-- Adicionar advertência
function addWarning(player, targetName, reason)
    if not hasPermission(player, "moderation.warn") then
        outputChatBox("Você não tem permissão para advertir jogadores.", player, 255, 0, 0)
        return
    end

    local target = getPlayerFromName(targetName)
    if not target then
        outputChatBox("Jogador não encontrado.", player, 255, 0, 0)
        return
    end

    if not reason then
        outputChatBox("Motivo da advertência necessário.", player, 255, 0, 0)
        return
    end

    local playerName = getPlayerName(target)
    warnings[playerName] = warnings[playerName] or {}
    table.insert(warnings[playerName], {
        admin = getPlayerName(player),
        reason = reason,
        timestamp = os.date("%Y-%m-%d %H:%M:%S")
    })

    outputChatBox("Jogador " .. playerName .. " advertido por: " .. reason, root, 255, 165, 0)
end

-- Visualizar advertências
function viewWarnings(player, targetName)
    if not hasPermission(player, "moderation.view") then
        outputChatBox("Você não tem permissão para visualizar advertências.", player, 255, 0, 0)
        return
    end

    if not targetName then
        outputChatBox("Especifique o nome do jogador.", player, 255, 0, 0)
        return
    end

    local targetWarnings = warnings[targetName]
    if not targetWarnings or #targetWarnings == 0 then
        outputChatBox("Nenhuma advertência encontrada para " .. targetName, player, 255, 255, 0)
        return
    end

    outputChatBox("=== Advertências de " .. targetName .. " ===", player, 0, 255, 255)
    for _, warning in ipairs(targetWarnings) do
        outputChatBox("* " .. warning.reason .. " (Admin: " .. warning.admin .. ", Data: " .. warning.timestamp .. ")", player, 255, 255, 255)
    end
end

-- Comandos
addCommandHandler("warn", function(player, _, targetName, ...)
    local reason = table.concat({...}, " ")
    addWarning(player, targetName, reason)
end)

addCommandHandler("viewwarnings", function(player, _, targetName)
    viewWarnings(player, targetName)
end)