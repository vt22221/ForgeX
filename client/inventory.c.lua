--[[
    ForgeX - Inventory Panel
    - Apenas desenha o painel do inventario.
    - A logica de controle e do ui_manager.c.lua.
]]

local panelW, panelH = 600, 450
local screenW, screenH = guiGetScreenSize()
local panelX, panelY = (screenW - panelW) / 2, (screenH - panelH) / 2

function drawInventoryPanel()
    -- Desenha o fundo do painel
    dxDrawRectangle(panelX, panelY, panelW, panelH, tocolor(20, 25, 30, 220))
    dxDrawText(tr("inventory_title"), panelX, panelY, panelX + panelW, panelY + 40, tocolor(255, 255, 255), 1.5, "default-bold", "center", "center")

    -- Desenha os itens
    if ForgeX.Data.inventory then
        local startX = panelX + 20
        local startY = panelY + 60
        local col, row = 0, 0
        local itemSize = 64
        local padding = 15

        for itemID, amount in pairs(ForgeX.Data.inventory) do
            local itemX = startX + col * (itemSize + padding)
            local itemY = startY + row * (itemSize + padding)

            if itemX + itemSize > panelX + panelW - padding then
                col = 0
                row = row + 1
                itemX = startX + col * (itemSize + padding)
                itemY = startY + row * (itemSize + padding)
            end

            -- Fundo do item
            dxDrawRectangle(itemX, itemY, itemSize, itemSize, tocolor(40, 45, 50, 180))
            
            -- TODO: Desenhar imagem do item (SVG ou PNG)
            -- dxDrawImage(...)
            
            -- Nome e quantidade
            dxDrawText(itemID, itemX, itemY + itemSize - 14, itemX + itemSize, itemY + itemSize, tocolor(200, 200, 200), 0.7, "default", "center", "center")
            dxDrawText("x"..amount, itemX + itemSize - 20, itemY, itemX + itemSize, itemY + 20, tocolor(255, 255, 255), 0.8, "default-bold", "right", "top")

            col = col + 1
        end
    end
end

-- Logica de clique
addEventHandler("onClientClick", root, function(button, state, absX, absY)
    if ForgeX_UI.activePanel ~= "inventory" or button ~= "left" or state ~= "down" then
        return
    end

    -- Adicionar logica para clicar em um item aqui
    -- Ex: Verificar se o clique foi dentro de um dos retangulos dos itens
end)

-- Registra este painel no gerenciador de UI
ForgeX_UI.registerPanel("inventory", "i", drawInventoryPanel) -- Tecla 'I' como atalho