local playerStats = {}

function updatePlaytime(player)
    local account = getPlayerAccount(player)
    if account then
        local playtime = getAccountData(account, "playtime") or 0
        setAccountData(account, "playtime", playtime + 1)
    end
end

addEventHandler("onPlayerJoin", root, function()
    setTimer(updatePlaytime, 60000, 0, source) -- Atualiza a cada minuto
end)