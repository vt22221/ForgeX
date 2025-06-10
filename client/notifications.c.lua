--[[
    ForgeX - Notification System
    - Exibe notificacoes visuais para o jogador de forma organizada.
]]

local notificationQueue = {}
local currentNotification = nil
local notificationStartTick = 0

local NOTIFY_DURATION = 4000 -- ms
local FADE_TIME = 500 -- ms
local FONT = "default-bold"
local WIDTH, HEIGHT = 400, 50
local screenW, screenH = guiGetScreenSize()

local NOTIFICATION_COLORS = {
    error = {220, 50, 50},
    success = {50, 220, 50},
    info = {50, 150, 220},
    warning = {240, 180, 50},
}

-- Ouve o evento para mostrar uma notificacao
addEvent("ForgeX:Client:Notify", true)
addEventHandler("ForgeX:Client:Notify", root, function(type, message)
    if not message or not type then return end
    table.insert(notificationQueue, { type = type, text = message })
end)

-- Processa a fila de notificacoes
setTimer(function()
    if not currentNotification and #notificationQueue > 0 then
        currentNotification = table.remove(notificationQueue, 1)
        notificationStartTick = getTickCount()
        playSoundFrontEnd(41) -- Som de notificacao
    elseif currentNotification then
        if getTickCount() - notificationStartTick > NOTIFY_DURATION + FADE_TIME then
            currentNotification = nil
        end
    end
end, 100, 0)

-- Renderiza a notificacao atual
addEventHandler("onClientRender", root, function()
    if not currentNotification then return end

    local elapsed = getTickCount() - notificationStartTick
    local alpha = 230
    
    if elapsed < FADE_TIME then
        alpha = interpolateBetween(0, 0, 0, 230, 0, 0, elapsed / FADE_TIME, "Linear")
    elseif elapsed > NOTIFY_DURATION then
        alpha = interpolateBetween(230, 0, 0, 0, 0, 0, (elapsed - NOTIFY_DURATION) / FADE_TIME, "Linear")
    end
    alpha = math.max(0, math.min(230, alpha))

    local x = (screenW - WIDTH) / 2
    local y = screenH * 0.05
    
    local color = NOTIFICATION_COLORS[currentNotification.type] or NOTIFICATION_COLORS.info

    dxDrawRectangle(x, y, WIDTH, HEIGHT, tocolor(20, 25, 30, alpha))
    dxDrawRectangle(x, y, 5, HEIGHT, tocolor(color[1], color[2], color[3], alpha))
    dxDrawText(currentNotification.text, x + 15, y, x + WIDTH - 15, y + HEIGHT, tocolor(255, 255, 255, alpha * 1.1), 1.0, FONT, "center", "center", true)
end)