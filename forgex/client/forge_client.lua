-- ForgeX™ - Cliente Principal
-- Este arquivo gerencia as funcionalidades principais no lado do cliente.

local ForgeX = {
    version = "1.0.0",
    initialized = false,
    ui = {},
    stats = {},
    playerData = {}
}

-- Carregar Configurações do Cliente
function ForgeX:loadConfig()
    local configFile = fileOpen("config/config.json")
    if configFile then
        local configContent = fileRead(configFile, fileGetSize(configFile))
        self.config = fromJSON(configContent)
        fileClose(configFile)
        outputDebugString("[ForgeX] Configurações do cliente carregadas com sucesso.")
    else
        outputDebugString("[ForgeX] Erro ao carregar as configurações do cliente!", 1)
    end
end

-- Inicializar Interface Gráfica (DX)
function ForgeX:initializeUI()
    self.ui.mainMenuVisible = false

    -- Função para desenhar a interface gráfica principal
    addEventHandler("onClientRender", root, function()
        if self.ui.mainMenuVisible then
            dxDrawRectangle(100, 100, 600, 400, tocolor(0, 0, 0, 200))
            dxDrawText("ForgeX™ Menu Principal", 120, 120, 680, 160, tocolor(255, 255, 255, 255), 1.2, "default-bold")
            dxDrawText("1. Skins", 120, 180, 680, 220, tocolor(255, 255, 255, 255), 1, "default")
            dxDrawText("2. Economia", 120, 220, 680, 260, tocolor(255, 255, 255, 255), 1, "default")
            dxDrawText("3. Crafting", 120, 260, 680, 300, tocolor(255, 255, 255, 255), 1, "default")
            dxDrawText("4. Sair do Menu (ESC)", 120, 300, 680, 340, tocolor(255, 255, 255, 255), 1, "default")
        end
    end)
end

-- Abrir Menu Principal
function ForgeX:toggleMainMenu()
    self.ui.mainMenuVisible = not self.ui.mainMenuVisible
    showCursor(self.ui.mainMenuVisible)
end

-- Sistema de Estatísticas do Jogador
function ForgeX:initializeStats()
    self.stats.playtime = 0

    -- Atualizar tempo jogado
    setTimer(function()
        self.stats.playtime = self.stats.playtime + 1
        triggerServerEvent("updatePlaytime", localPlayer, self.stats.playtime)
    end, 60000, 0) -- Atualiza a cada minuto
end

-- Sistema de Comunicação com o Servidor
function ForgeX:initializeEvents()
    -- Ouvir eventos do servidor
    addEvent("onReceiveForgeCoins", true)
    addEventHandler("onReceiveForgeCoins", root, function(amount)
        outputChatBox("Você recebeu " .. amount .. " ForgeCoins!", 0, 255, 0)
    end)

    addEvent("onPlayerSkinChanged", true)
    addEventHandler("onPlayerSkinChanged", root, function(skinName)
        outputChatBox("Sua skin foi alterada para: " .. skinName, 0, 255, 255)
    end)
end

-- Inicializar Sistema ForgeX no Cliente
function ForgeX:initialize()
    self:loadConfig()
    self:initializeUI()
    self:initializeStats()
    self:initializeEvents()

    -- Mostrar mensagem de inicialização
    outputChatBox("[ForgeX] Sistema inicializado no cliente! Versão: " .. self.version, 0, 255, 0)
    self.initialized = true
end

-- Vincular Teclas
bindKey("F2", "down", function() ForgeX:toggleMainMenu() end)

-- Eventos de Inicialização
addEventHandler("onClientResourceStart", resourceRoot, function()
    ForgeX:initialize()
end)

-- Eventos de Finalização
addEventHandler("onClientResourceStop", resourceRoot, function()
    showCursor(false)
    outputDebugString("[ForgeX] Sistema encerrado no cliente.")
end)

return ForgeX