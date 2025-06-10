function drawXPBar(x,y,w,h,xp,xpNext)
    local perc = math.min(xp/xpNext,1)
    dxDrawRectangle(x,y,w,h,tocolor(30,30,30,200))
    dxDrawRectangle(x,y,w*perc,h,tocolor(50,200,60,230))
    dxDrawText(string.format("%d/%d XP",xp,xpNext),x,y,x+w,y+h,tocolor(255,255,255),1,"default-bold","center","center")
end

function drawLootboxAnimation(reward)
    -- Animação real de roleta, highlight, efeito sonoro, etc
    local x, y = 400, 300
    local w, h = 300, 200
    dxDrawRectangle(x, y, w, h, tocolor(0, 0, 0, 180))
    dxDrawText("Você ganhou:", x, y + 20, x + w, y + 60, tocolor(255, 255, 0), 1.5, "default-bold", "center", "top")
    local svg = getSVGImage("images/"..string.lower(reward)..".svg", 64, 64)
    if svg then
        dxDrawImage(x + (w - 64) / 2, y + 80, 64, 64, svg)
    else
        dxDrawText(reward, x + (w - 64) / 2, y + 80, x + (w + 64) / 2, y + 144, tocolor(255, 100, 100), 1.2, "default-bold", "center", "center")
    end
    dxDrawText("Parabéns!", x, y + 160, x + w, y + 200, tocolor(255, 255, 255), 1.2, "default-bold", "center", "top")
    setTimer(function()
        -- Fechar animação após 3 segundos
        isLootboxVisible = false
    end, 3000, 1)
    isLootboxVisible = true
end

-- Leaderboard (top XP, top kills, top skins raras)
function drawLeaderboard(x,y)
    -- Busque dados do server (triggerServerEvent/triggerClientEvent) e desenhe
    local leaderboardData = {
        {name = "Jogador1", xp = 5000, kills = 150, rareSkins = 3},
        {name = "Jogador2", xp = 4800, kills = 200, rareSkins = 5},
        {name = "Jogador3", xp = 4700, kills = 180, rareSkins = 2},
    }
    dxDrawRectangle(x, y, 300, 200, tocolor(20, 20, 20, 220))
    dxDrawText("Leaderboard", x + 10, y + 10, x + 290, y + 40, tocolor(255, 255, 255), 1.3, "default-bold", "left", "top")
    local offsetY = y + 50
    for i, player in ipairs(leaderboardData) do
        local text = string.format("%d. %s - XP: %d | Kills: %d | Skins Raras: %d", i, player.name, player.xp, player.kills, player.rareSkins)
        dxDrawText(text, x + 10, offsetY + (i-1)*20, x + 290, offsetY + i*20, tocolor(255, 255, 255), 1, "default", "left", "top")
    end
end