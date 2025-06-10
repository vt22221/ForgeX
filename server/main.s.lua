--[[
    ForgeX - Server Main Logic
    - Ponto de entrada principal do resource no lado do servidor.
    - Carrega configuracoes, verifica licenca e inicializa modulos.
]]

-- Tabela global para armazenar todas as configuracoes carregadas dos arquivos JSON
Config = {}
local g_IsLicensed = false

-- Carrega todos os arquivos de configuracao .json da pasta /data
local function loadAllConfigs()
    local configFiles = {
        "achievements", "battlepass", "collections", "contracts", "crafting",
        "lootboxes", "mods", "missions", "shop", "skins", "upgrades"
    }
    
    local success = true
    for _, filename in ipairs(configFiles) do
        local path = "data/" .. filename .. ".json"
        local file = fileOpen(path)
        if file then
            local content = fileRead(file, fileGetSize(file))
            fileClose(file)
            local data = fromJSON(content)
            if data then
                Config[filename] = data
            else
                outputServerLog("[ForgeX] ERRO: Falha ao decodificar JSON em " .. path)
                success = false
            end
        else
            outputServerLog("[ForgeX] AVISO: Arquivo de configuracao nao encontrado: " .. path)
        end
    end
    
    if success then
        outputServerLog("[ForgeX] Todas as configuracoes .json foram carregadas.")
    end
    return success
end

-- Verifica a licenca do resource
local function checkLicense()
    local licenseFile = fileOpen("data/license.json")
    if not licenseFile then
        outputServerLog("[ForgeX] ERRO FATAL: Arquivo 'data/license.json' nao encontrado.")
        return false
    end
    
    local content = fileRead(licenseFile, fileGetSize(licenseFile))
    fileClose(licenseFile)
    local licenseData = fromJSON(content) or {}
    
    if licenseData.ip == getServerIp() or licenseData.ip == "ANY" then
        g_IsLicensed = true
        outputServerLog("[ForgeX] Licenca validada para o IP: " .. getServerIp())
        return true
    else
        outputServerLog("[ForgeX] ERRO FATAL: Licenca invalida ou IP do servidor nao autorizado.")
        return false
    end
end

-- Inicializacao principal do resource
addEventHandler("onResourceStart", resourceRoot, function()
    if not checkLicense() then
        cancelEvent()
        return
    end

    if not loadAllConfigs() then
        outputServerLog("[ForgeX] Resource nao pode ser iniciado devido a erros de configuracao.")
        cancelEvent()
        return
    end

    -- Os modulos (player_data, events, etc.) serao inicializados pelos seus proprios
    -- event handlers de 'onResourceStart'.
    
    outputServerLog("[ForgeX] Resource iniciado com sucesso.")
end)

-- Funcao de exportacao para que outros scripts possam verificar a licenca
function isForgeXLicensed()
    return g_IsLicensed
end
exports:add("isForgeXLicensed", isForgeXLicensed)