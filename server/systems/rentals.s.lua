-- ForgeX Skin Rental System (Server-side)

local rentalOptions = {
    ["AK-47|Redline"] = {price=500, duration=24, name="Redline (AK)", canRenew=true}
}
local playerRentals = {} -- [player] = { [skin]={expires=timestamp, canRenew=bool, price=int, name=string} }

addEvent("forgex:requestRentals", true)
addEventHandler("forgex:requestRentals", root, function()
    local plr = client
    local rented = playerRentals[plr] or {}
    triggerClientEvent(plr, "forgex:syncRentals", plr, rented, rentalOptions)
end)

addEvent("forgex:rentSkin", true)
addEventHandler("forgex:rentSkin", root, function(skin)
    local plr = client
    local opt = rentalOptions[skin]
    if not opt then return end
    if getPlayerMoney(plr) < opt.price then
        triggerClientEvent(plr, "forgex:rentalFeedback", plr, "Saldo insuficiente.")
        return
    end
    takePlayerMoney(plr, opt.price)
    if not playerRentals[plr] then playerRentals[plr] = {} end
    playerRentals[plr][skin] = {expires=getRealTime().timestamp+opt.duration*3600, canRenew=opt.canRenew, price=opt.price, name=opt.name}
    triggerClientEvent(plr, "forgex:rentalFeedback", plr, "Skin alugada!")
end)

addEvent("forgex:renewRental", true)
addEventHandler("forgex:renewRental", root, function(skin)
    local plr = client
    local rental = playerRentals[plr] and playerRentals[plr][skin]
    local opt = rentalOptions[skin]
    if not rental or not opt or not rental.canRenew then
        triggerClientEvent(plr, "forgex:rentalFeedback", plr, "Não pode renovar.")
        return
    end
    if getPlayerMoney(plr) < opt.price then
        triggerClientEvent(plr, "forgex:rentalFeedback", plr, "Saldo insuficiente.")
        return
    end
    takePlayerMoney(plr, opt.price)
    rental.expires = rental.expires + opt.duration*3600
    triggerClientEvent(plr, "forgex:rentalFeedback", plr, "Renovado!")
end)
addEvent("forgex:evolveRental", true)
addEventHandler("forgex:evolveRental", root, function(skin)
    local plr = client
    local rental = playerRentals[plr] and playerRentals[plr][skin]
    if not rental then
        triggerClientEvent(plr, "forgex:rentalFeedback", plr, "Você não possui essa skin alugada.")
        return
    end
    -- Exemplo de evolução: aumentar o nível ou mudar a skin
    rental.level = (rental.level or 0) + 1
    triggerClientEvent(plr, "forgex:rentalFeedback", plr, "Skin evoluída para nível " .. rental.level)
end)
function getPlayerRentals(acc)
    local qh = dbQuery(ForgeXDB.connection, "SELECT skin, expires, level FROM rentals WHERE account=?", acc)
    if not qh then return {} end
    local result = dbPoll(qh, -1)
    local rentals = {}
    for _,v in ipairs(result or {}) do
        rentals[v.skin] = {expires=v.expires, level=v.level}
    end
    return rentals
end
function syncRentalsAll()
    for _,plr in ipairs(getElementsByType("player")) do
        local rentals = getPlayerRentals(getAccountName(getPlayerAccount(plr)))
        triggerClientEvent(plr, "forgex:syncRentals", plr, rentals, rentalOptions)
    end
end
-- Exemplo de integração com ranked
addEvent("forgex:rankedMatch", true)
addEventHandler("forgex:rankedMatch", root, function()
    local plr = client
    if not playerRentals[plr] then playerRentals[plr] = {} end
    -- Exemplo de recompensa por vitória
    local reward = 100 -- Valor fixo ou baseado em algum critério
    -- Atualiza o aluguel da skin, se necessário
    for skin,rental in pairs(playerRentals[plr]) do
        if rental.expires < getRealTime().timestamp then
            playerRentals[plr][skin] = nil -- Remove aluguel expirado
        end
    end
    -- Simula vitória para aumentar ELO ou similar
    local elo = (playerRentals[plr].elo or 1000) + reward
    playerRentals[plr].elo = math.min(3000, elo) -- Limite máximo de ELO
    triggerClientEvent(plr, "forgex:rankedDataSync", plr, {elo=playerRentals[plr].elo, rentals=playerRentals[plr]})
end)
-- Exemplo de integração com kills
addEvent("onPlayerWeaponKill", true)
addEventHandler("onPlayerWeaponKill", root, function(plr, weapon)
    local acc = getAccountName(getPlayerAccount(plr))
    if playerRentals[plr] then
        -- Atualiza o aluguel da skin, se necessário
        for skin,rental in pairs(playerRentals[plr]) do
            if rental.expires < getRealTime().timestamp then
                playerRentals[plr][skin] = nil -- Remove aluguel expirado
            end
        end
        -- Exemplo de recompensa por kill
        local reward = 50 -- Valor fixo ou baseado em algum critério
        local elo = (playerRentals[plr].elo or 1000) + reward
        playerRentals[plr].elo = math.min(3000, elo) -- Limite máximo de ELO
        triggerClientEvent(plr, "forgex:rankedDataSync", plr, {elo=playerRentals[plr].elo, rentals=playerRentals[plr]})
    end
end)
-- Exemplo de integração com lootbox
addEvent("forgex:openLootbox", true)
addEventHandler("forgex:openLootbox", root, function(boxType)
    local plr = client
    if not playerRentals[plr] then playerRentals[plr] = {} end
    -- Exemplo de recompensa por abrir lootbox
    local reward = boxType == "rare" and 50 or 20
    local elo = (playerRentals[plr].elo or 1000) + reward
    playerRentals[plr].elo = math.min(3000, elo) -- Limite máximo de ELO
    triggerClientEvent(plr, "forgex:rankedDataSync", plr, {elo=playerRentals[plr].elo, rentals=playerRentals[plr]})
end)
-- Exemplo de integração com venda no marketplace
addEvent("forgex:marketplaceSell", true)
addEventHandler("forgex:marketplaceSell", root, function(skin, price)
    local plr = client
    if not playerRentals[plr] or not playerRentals[plr][skin] then
        triggerClientEvent(plr, "forgex:inventoryFeedback", plr, "Você não possui essa skin alugada.")
        return
    end
    -- Exemplo de recompensa por venda
    local reward = math.min(100, price / 10) -- Limite máximo de recompensa
    local elo = (playerRentals[plr].elo or 1000) + reward
    playerRentals[plr].elo = math.min(3000, elo) -- Limite máximo de ELO
    triggerClientEvent(plr, "forgex:rankedDataSync", plr, {elo=playerRentals[plr].elo, rentals=playerRentals[plr]})
end)
-- Salva os aluguéis no banco de dados ao parar o recurso
addEventHandler("onResourceStop", resourceRoot, function()
    for plr, rentals in pairs(playerRentals) do
        local acc = getAccountName(getPlayerAccount(plr))
        for skin, rental in pairs(rentals) do
            dbExec(ForgeXDB.connection, "REPLACE INTO rentals (account, skin, expires, level) VALUES (?, ?, ?, ?)", acc, skin, rental.expires, rental.level or 0)
        end
    end
end)
-- Carrega os aluguéis do banco de dados ao iniciar o recurso
addEventHandler("onResourceStart", resourceRoot, function()
    local qh = dbQuery(ForgeXDB.connection, "SELECT account, skin, expires, level FROM rentals")
    if not qh then return end
    local result = dbPoll(qh, -1)
    for _,v in ipairs(result or {}) do
        if not playerRentals[v.account] then playerRentals[v.account] = {} end
        playerRentals[v.account][v.skin] = {expires=v.expires, level=v.level}
    end
    syncRentalsAll() -- Sincroniza com todos os jogadores
end)
-- Exemplo de integração com missões
addEvent("forgex:rentMissionProgress", true)
addEventHandler("forgex:rentMissionProgress", root, function(missionId, progress)
    local plr = client
    local acc = getAccountName(getPlayerAccount(plr))
    if not playerRentals[plr] then playerRentals[plr] = {} end
    -- Atualiza o progresso da missão de aluguel
    playerRentals[plr].missions = playerRentals[plr].missions or {}
    playerRentals[plr].missions[missionId] = (playerRentals[plr].missions[missionId] or 0) + progress
    triggerClientEvent(plr, "forgex:rentMissionUpdate", plr, playerRentals[plr].missions)
end)
-- Exemplo de integração com marketplace
addEvent("forgex:marketplaceSell", true)
addEventHandler("forgex:marketplaceSell", root, function(skin, price)
    local plr = client
    if not playerRentals[plr] or not playerRentals[plr][skin] then
        triggerClientEvent(plr, "forgex:inventoryFeedback", plr, "Você não possui essa skin alugada.")
        return
    end
    -- Exemplo de recompensa por venda
    local reward = math.min(100, price / 10) -- Limite máximo de recompensa
    local elo = (playerRentals[plr].elo or 1000) + reward
    playerRentals[plr].elo = math.min(3000, elo) -- Limite máximo de ELO
    triggerClientEvent(plr, "forgex:rankedDataSync", plr, {elo=playerRentals[plr].elo, rentals=playerRentals[plr]})
end)