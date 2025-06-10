--[[
    ForgeX - UI Manager (Client-side)
    - Centraliza o controle de todos os paineis da interface.
    - Garante que apenas um painel esteja aberto por vez.
    - Otimiza a renderizacao.
]]

ForgeX_UI = {}
ForgeX_UI.activePanel = nil
ForgeX_UI.panels = {}

-- Registra um novo painel no gerenciador
-- @param name - Nome unico do painel (ex: "inventory")
-- @param key - Tecla de atalho (ex: "F1")
-- @param drawFunction - Funcao que desenha o painel (ex: drawInventoryPanel)
function ForgeX_UI.registerPanel(name, key, drawFunction)
    if not name or not key or type(drawFunction) ~= "function" then
        return
    end

    ForgeX_UI.panels[name] = {
        key = key,
        drawFunc = drawFunction,
    }

    bindKey(key, "down", function()
        ForgeX_UI.togglePanel(name)
    end)
end

-- Abre ou fecha um painel
function ForgeX_UI.togglePanel(name)
    if not ForgeX_UI.panels[name] then return end

    if ForgeX_UI.activePanel == name then
        ForgeX_UI.activePanel = nil
        showCursor(false)
    else
        ForgeX_UI.activePanel = name
        showCursor(true)
        -- Ao abrir um painel, sempre pede uma sincronizacao para ter os dados mais recentes
        triggerServerEvent("ForgeX:Server:RequestFullSync", localPlayer)
    end
end

-- Handler global para a tecla ESC
addEventHandler("onClientKey", root, function(button, press)
    if ForgeX_UI.activePanel and button == "escape" and press then
        ForgeX_UI.togglePanel(ForgeX_UI.activePanel) -- Fecha o painel ativo
        cancelEvent()
    end
end, false) -- Prioridade baixa para nao interferir com outros sistemas

-- Handler de renderizacao unico e otimizado
addEventHandler("onClientRender", root, function()
    if ForgeX_UI.activePanel then
        local panel = ForgeX_UI.panels[ForgeX_UI.activePanel]
        if panel and panel.drawFunc then
            panel.drawFunc() -- Chama a funcao de desenho do painel ativo
        end
    end
end)

-- Limpa tudo ao parar o resource
addEventHandler("onClientResourceStop", resourceRoot, function()
    if ForgeX_UI.activePanel then
        showCursor(false)
        ForgeX_UI.activePanel = nil
    end
end)