--[[
    ForgeX - Client Main Logic
    - Ponto de entrada principal do resource no lado do cliente.
    - Inicializa modulos, gerencia o cache de dados e logica de armas.
]]

ForgeX = {}
ForgeX.Data = {} -- Cache central de todos os dados do jogador
local originalWeaponProperties = {} -- Guarda as propriedades originais para resetar
local localPlayer = getLocalPlayer()

-- Recebe todos os dados do servidor de uma vez
addEvent("ForgeX:Client:SyncAllData", true)
addEventHandler("ForgeX:Client:SyncAllData", root, function(allData)
    if type(allData) ~= "table" then return end
    ForgeX.Data = allData
    
    -- Forca a atualizacao da arma atual, caso necessario
    local currentWeaponID = getPedWeapon(localPlayer)
    if currentWeaponID and currentWeaponID > 0 then
        updateCurrentWeapon(currentWeaponID)
    end
end)

-- Recebe uma atualizacao de uma parte especifica dos dados
addEvent("ForgeX:Client:UpdateData", true)
addEventHandler("ForgeX:Client:UpdateData", root, function(dataType, data)
    if type(data) ~= "table" or not dataType then return end
    ForgeX.Data[dataType] = data
    
    -- Se os dados da arma foram atualizados, aplica as mudancas
    if dataType == "weapons" then
        local currentWeaponID = getPedWeapon(localPlayer)
        if currentWeaponID and currentWeaponID > 0 then
            updateCurrentWeapon(currentWeaponID)
        end
    end
end)

-- Logica de Modificacao de Armas
function updateCurrentWeapon(weaponID)
    local weaponData = ForgeX.Data.weapons and ForgeX.Data.weapons[weaponID]

    if not weaponData then
        resetWeaponProperties(weaponID)
        return
    end

    applyWeaponMods(weaponID, weaponData.mods)
    applyWeaponSkin(weaponID, weaponData.skin)
end

function applyWeaponMods(weaponID, mods)
    resetWeaponProperties(weaponID) -- Sempre reseta antes de aplicar
    if type(mods) ~= "table" then return end
    
    for modType, modName in pairs(mods) do
        local modInfo = Config.mods[modType]
        if modInfo then
            -- A logica de setWeaponProperty seria aplicada aqui
            -- Ex: setWeaponProperty(weaponID, "accuracy", originalAccuracy * modInfo.bonus)
        end
    end
end

function applyWeaponSkin(weaponID, skinID)
    if not skinID or not Config.skins[skinID] then
        engineRestoreModel(getWeaponModelFromID(weaponID))
        return
    end

    local skinInfo = Config.skins[skinID]
    local txd = engineLoadTXD("data/models/" .. skinInfo.texture)
    engineImportTXD(txd, weaponID)

    if skinInfo.model then
        local dff = engineLoadDFF("data/models/" .. skinInfo.model)
        engineReplaceModel(dff, weaponID)
    end
end

function resetWeaponProperties(weaponID)
    if originalWeaponProperties[weaponID] then
        for prop, value in pairs(originalWeaponProperties[weaponID]) do
            setWeaponProperty(weaponID, prop, value)
        end
    end
    engineRestoreModel(getWeaponModelFromID(weaponID))
end

-- Listener para troca de arma
addEventHandler("onClientPlayerWeaponSwitch", localPlayer, function(prev, current)
    updateCurrentWeapon(current)
end)

-- Inicializacao do cliente
addEventHandler("onClientResourceStart", resourceRoot, function()
    -- Solicita os dados iniciais ao servidor
    triggerServerEvent("ForgeX:Server:RequestFullSync", localPlayer)
end)