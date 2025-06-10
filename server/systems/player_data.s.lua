--[[
    ForgeX - Player Data Manager
    - Centraliza o carregamento, cache e salvamento de TODOS os dados do jogador.
    - Oferece uma API segura para outros modulos manipularem os dados.
]]

PlayerData = {}
local g_PlayerDataCache = {} -- Cache de dados dos jogadores online

-- Estrutura de dados padrao para um novo jogador
local function getDefaultPlayerData()
    return {
        profile = {
            money = 1000,
            elo = 1000,
            bp_xp = 0,
            bp_level = 1,
            premium_bp = false,
        },
        inventory = {},
        achievements = {},
        battlepass = {
            claimed_levels = {}
        },
        missions = {
            daily = {},
            weekly = {}
        },
        rentals = {},
        weapons = {} -- { [weaponID] = { xp=0, level=1, mods={}, skin='default' } }
    }
end

-- Carrega os dados de um jogador do DB para o cache
function PlayerData.load(player)
    local accountName = getAccountName(getPlayerAccount(player))
    if not accountName then return end

    local accountResult = DB.query("SELECT id FROM accounts WHERE account_name = ?", accountName)
    local playerID
    
    if not accountResult or #accountResult == 0 then
        -- Cria a conta no DB se for a primeira vez
        DB.exec("INSERT INTO accounts (account_name) VALUES (?)", accountName)
        playerID = DB.query("SELECT id FROM accounts WHERE account_name = ?")[1].id
        setElementData(player, "dbid", playerID)

        -- Insere os dados padrao
        local defaultData = getDefaultPlayerData()
        DB.exec("INSERT INTO player_data (player_id, profile, inventory, achievements, battlepass, missions, rentals) VALUES (?, ?, ?, ?, ?, ?, ?)",
            playerID, toJSON(defaultData.profile), toJSON(defaultData.inventory), toJSON(defaultData.achievements), 
            toJSON(defaultData.battlepass), toJSON(defaultData.missions), toJSON(defaultData.rentals))
        
        g_PlayerDataCache[player] = defaultData
    else
        -- Carrega os dados existentes
        playerID = accountResult[1].id
        setElementData(player, "dbid", playerID)
        local dataResult = DB.query("SELECT * FROM player_data WHERE player_id = ?", playerID)
        
        if dataResult and #dataResult > 0 then
            local row = dataResult[1]
            g_PlayerDataCache[player] = {
                profile = fromJSON(row.profile or '{}'),
                inventory = fromJSON(row.inventory or '{}'),
                achievements = fromJSON(row.achievements or '{}'),
                battlepass = fromJSON(row.battlepass or '{}'),
                missions = fromJSON(row.missions or '{}'),
                rentals = fromJSON(row.rentals or '{}'),
                weapons = {} -- Dados de armas sao carregados separadamente se necessario ou mantidos aqui
            }
        else
            -- Caso de corrupcao (conta existe mas dados nao), insere padrao
            g_PlayerDataCache[player] = getDefaultPlayerData()
        end
    end
    DB.exec("UPDATE accounts SET last_login = ? WHERE id = ?", getRealTime().timestamp, playerID)
    
    -- Sincroniza todos os dados com o cliente de uma so vez
    triggerClientEvent(player, "ForgeX:Client:SyncAllData", player, g_PlayerDataCache[player])
end

-- Salva os dados de um jogador do cache para o DB
function PlayerData.save(player)
    if g_PlayerDataCache[player] then
        local playerID = getElementData(player, "dbid")
        if playerID then
            local data = g_PlayerDataCache[player]
            DB.exec("UPDATE player_data SET profile=?, inventory=?, achievements=?, battlepass=?, missions=?, rentals=? WHERE player_id=?",
                toJSON(data.profile), toJSON(data.inventory), toJSON(data.achievements), toJSON(data.battlepass), 
                toJSON(data.missions), toJSON(data.rentals), playerID)
        end
        g_PlayerDataCache[player] = nil -- Limpa o cache
    end
end

-- API para outros modulos
function PlayerData.get(player)
    return g_PlayerDataCache[player]
end

function PlayerData.getProfile(player)
    return g_PlayerDataCache[player] and g_PlayerDataCache[player].profile
end

function PlayerData.getInventory(player)
    return g_PlayerDataCache[player] and g_PlayerDataCache[player].inventory
end

function PlayerData.giveMoney(player, amount)
    if not g_PlayerDataCache[player] then return false end
    g_PlayerDataCache[player].profile.money = g_PlayerDataCache[player].profile.money + amount
    PlayerData.sync(player, "profile")
    return true
end

function PlayerData.takeMoney(player, amount)
    if not g_PlayerDataCache[player] or g_PlayerDataCache[player].profile.money < amount then return false end
    g_PlayerDataCache[player].profile.money = g_PlayerDataCache[player].profile.money - amount
    PlayerData.sync(player, "profile")
    return true
end

function PlayerData.addItem(player, itemID, amount)
    if not g_PlayerDataCache[player] then return false end
    local inv = g_PlayerDataCache[player].inventory
    inv[itemID] = (inv[itemID] or 0) + amount
    PlayerData.sync(player, "inventory")
    return true
end

function PlayerData.removeItem(player, itemID, amount)
    if not g_PlayerDataCache[player] then return false end
    local inv = g_PlayerDataCache[player].inventory
    if not inv[itemID] or inv[itemID] < amount then return false end
    inv[itemID] = inv[itemID] - amount
    if inv[itemID] <= 0 then
        inv[itemID] = nil
    end
    PlayerData.sync(player, "inventory")
    return true
end

-- Sincroniza uma parte especifica dos dados com o cliente
function PlayerData.sync(player, dataType)
    if g_PlayerDataCache[player] and g_PlayerDataCache[player][dataType] then
        triggerClientEvent(player, "ForgeX:Client:UpdateData", player, dataType, g_PlayerDataCache[player][dataType])
    end
end

-- Handlers de login e quit
addEventHandler("onPlayerLogin", root, PlayerData.load)
addEventHandler("onPlayerQuit", root, PlayerData.save)

-- Garante que todos os jogadores online sejam salvos ao parar o resource
addEventHandler("onResourceStop", resourceRoot, function()
    for _, player in ipairs(getElementsByType("player")) do
        PlayerData.save(player)
    end
end)