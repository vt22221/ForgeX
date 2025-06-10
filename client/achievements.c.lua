-- ForgeX Achievements Panel (Client-side)
-- Revisado e otimizado por Copilot para integração robusta

local achievementsData = {}
local playerAchievements = {}
local isAchievementsVisible = false

-- Atualiza achievements do player
addEvent("forgex:syncAchievements", true)
addEventHandler("forgex:syncAchievements", root, function(data)
    playerAchievements = data or {}
end)

-- Solicita dados ao abrir painel
bindKey("F2", "down", function()
    isAchievementsVisible = not isAchievementsVisible
    if isAchievementsVisible then
        triggerServerEvent("forgex:requestAchievements", localPlayer)
    end
end)

-- Fecha painel com ESC
addEventHandler("onClientKey", root, function(btn, press)
    if isAchievementsVisible and btn == "escape" and press then
        isAchievementsVisible = false
        cancelEvent()
    end
end)

-- Renderização do painel
function drawAchievementsPanel()
    if not isAchievementsVisible then return end
    local x, y, w, h = 170, 110, 520, 340
    dxDrawRectangle(x, y, w, h, tocolor(45,45,60,215))
    dxDrawText("CONQUISTAS", x, y, x+w, y+40, tocolor(255,255,140), 1.5, "default-bold", "center", "top")
    local idx = 0
    for id, ach in pairs(playerAchievements or {}) do
        if type(ach) == "table" then
            local by = y+50 + idx*64
            dxDrawRectangle(x+18, by, w-36, 54, tocolor(60,60,80,170))
            dxDrawText(id, x+26, by+6, x+w-36, by+26, tocolor(200,255,180), 1, "default-bold")
            local status = ach.unlocked and "Desbloqueada!" or "Bloqueada"
            dxDrawText("Progresso: "..tostring(ach.progress or 0).." | "..status, x+26, by+28, x+w-36, by+48, tocolor(255,255,255), 0.95, "default")
            idx = idx + 1
            if idx > 4 then break end
        end
    end
end
addEventHandler("onClientRender", root, drawAchievementsPanel)

-- Notificação de conquista desbloqueada
addEvent("forgex:achievementUnlocked", true)
addEventHandler("forgex:achievementUnlocked", root, function(id)
    outputChatBox("Parabéns! Você desbloqueou a conquista: "..id, 255, 220, 120)
    if isAchievementsVisible then
        triggerServerEvent("forgex:requestAchievements", localPlayer)
    end
end)

-- Atualização de progresso
addEvent("forgex:achievementProgressUpdate", true)
addEventHandler("forgex:achievementProgressUpdate", root, function(id, progress)
    if playerAchievements[id] then
        playerAchievements[id].progress = progress
        if isAchievementsVisible then
            triggerServerEvent("forgex:requestAchievements", localPlayer)
        end
    end
end)

-- Reset de progresso de conquista
addEvent("forgex:achievementReset", true)
addEventHandler("forgex:achievementReset", root, function(id)
    if playerAchievements[id] then
        playerAchievements[id].progress = 0
        if isAchievementsVisible then
            triggerServerEvent("forgex:requestAchievements", localPlayer)
        end
    end
end)

-- Sincronização de dados de achievements (estrutura e definições)
addEvent("forgex:achievementDataSync", true)
addEventHandler("forgex:achievementDataSync", root, function(data)
    achievementsData = data or {}
end)

-- Atualização dos dados de achievements (full update)
addEvent("forgex:achievementDataUpdate", true)
addEventHandler("forgex:achievementDataUpdate", root, function(data)
    achievementsData = data or {}
    if isAchievementsVisible then
        triggerServerEvent("forgex:requestAchievements", localPlayer)
    end
end)

-- Reset dos dados de achievements (estrutura)
addEvent("forgex:achievementDataReset", true)
addEventHandler("forgex:achievementDataReset", root, function()
    achievementsData = {}
    if isAchievementsVisible then
        triggerServerEvent("forgex:requestAchievements", localPlayer)
    end
end)

-- Solicitações e resposta de dados (evita múltiplos handlers duplicados)
addEvent("forgex:achievementDataRequest", true)
addEventHandler("forgex:achievementDataRequest", root, function()
    triggerServerEvent("forgex:requestAchievementData", localPlayer)
end)

addEvent("forgex:achievementDataResponse", true)
addEventHandler("forgex:achievementDataResponse", root, function(data)
    achievementsData = data or {}
    if isAchievementsVisible then
        triggerServerEvent("forgex:requestAchievements", localPlayer)
    end
end)

-- Carrega achievements ao iniciar resource
addEventHandler("onClientResourceStart", resourceRoot, function()
    triggerServerEvent("forgex:requestAchievements", localPlayer)
    triggerServerEvent("forgex:requestAchievementData", localPlayer)
end)

-- Limpa painel ao parar resource
addEventHandler("onClientResourceStop", resourceRoot, function()
    isAchievementsVisible = false
end)