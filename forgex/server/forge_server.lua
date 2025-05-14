-- ForgeX™ - Servidor Principal
-- Este arquivo gerencia as funcionalidades principais do sistema ForgeX™ no lado do servidor.

local ForgeX = {
    version = "1.0.0",
    modules = {},
    initialized = false
}

-- Carregar Configurações
function ForgeX:loadConfig()
    local configFile = fileOpen("config/config.json")
    if configFile then
        local configContent = fileRead(configFile, fileGetSize(configFile))
        self.config = fromJSON(configContent)
        fileClose(configFile)
        outputDebugString("[ForgeX] Configurações carregadas com sucesso.")
    else
        outputDebugString("[ForgeX] Erro ao carregar as configurações!", 1)
    end
end

-- Inicializar Módulos
function ForgeX:initializeModules()
    self.modules.economy = exports["economy_server"]
    self.modules.acl = exports["acl_server"]
    self.modules.marketplace = exports["marketplace_server"]
    self.modules.crafting = exports["crafting_server"]
    self.modules.moderation = exports["moderation_server"]

    for name, module in pairs(self.modules) do
        if module.initialize then
            module:initialize()
            outputDebugString("[ForgeX] Módulo " .. name .. " inicializado.")
        end
    end
end

-- Gerenciar Eventos
function ForgeX:initializeEventHandlers()
    -- Gerenciar login de jogadores
    addEventHandler("onPlayerLogin", root, function(_, account)
        local player = source
        outputChatBox("[ForgeX] Bem-vindo, " .. getPlayerName(player) .. "!", player, 0, 255, 0)
        -- Carregar saldo e permissões
        self.modules.economy:loadPlayerBalance(player)
        self.modules.acl:assignPlayerPermissions(player, account)
    end)

    -- Gerenciar saída de jogadores
    addEventHandler("onPlayerQuit", root, function()
        local player = source
        self.modules.economy:savePlayerBalance(player)
        outputDebugString("[ForgeX] Jogador saiu: " .. getPlayerName(player))
    end)
end

-- Comando para exibir informações do ForgeX
addCommandHandler("forgeinfo", function(player)
    if not ForgeX.modules.acl:hasPermission(player, "admin.view") then
        outputChatBox("Você não tem permissão para usar este comando.", player, 255, 0, 0)
        return
    end

    local info = string.format(
        "ForgeX™ v%s\nJogadores Online: %d\nMódulos Ativos: %d",
        ForgeX.version,
        #getElementsByType("player"),
        #ForgeX.modules
    )
    outputChatBox(info, player, 0, 255, 255)
end)

-- Inicializar Sistema ForgeX™
function ForgeX:initialize()
    self:loadConfig()
    self:initializeModules()
    self:initializeEventHandlers()
    self.initialized = true
    outputDebugString("[ForgeX] Sistema inicializado com sucesso!")
end

-- Iniciar o Sistema ao Carregar o Resource
addEventHandler("onResourceStart", resourceRoot, function()
    ForgeX:initialize()
end)

-- Encerrar o Sistema ao Parar o Resource
addEventHandler("onResourceStop", resourceRoot, function()
    for _, player in ipairs(getElementsByType("player")) do
        ForgeX.modules.economy:savePlayerBalance(player)
    end
    outputDebugString("[ForgeX] Sistema encerrado.")
end)

return ForgeX