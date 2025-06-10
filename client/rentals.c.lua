-- ForgeX Rentals Panel (Client-side)

local rentalsData = {}
local rentalOptions = {}
local isRentalsVisible = false

addEvent("forgex:syncRentals", true)
addEventHandler("forgex:syncRentals", root, function(rented, options)
    rentalsData = rented or {}
    rentalOptions = options or {}
end)

bindKey("F8", "down", function()
    isRentalsVisible = not isRentalsVisible
    if isRentalsVisible then
        triggerServerEvent("forgex:requestRentals", localPlayer)
    end
end)

addEventHandler("onClientKey", root, function(btn, press)
    if isRentalsVisible and btn == "escape" and press then
        isRentalsVisible = false
        cancelEvent()
    end
end)

function drawRentalsPanel()
    if not isRentalsVisible then return end
    local x, y, w, h = 180, 110, 520, 340
    dxDrawRectangle(x, y, w, h, tocolor(40,60,40,220))
    dxDrawText("ALUGUEL DE SKINS", x, y, x+w, y+40, tocolor(120,255,120), 1.3, "default-bold", "center", "top")
    local idx = 0
    for skin, opt in pairs(rentalOptions or {}) do
        local rental = rentalsData[skin]
        local by = y+50 + idx*64
        dxDrawRectangle(x+18, by, w-36, 54, tocolor(60,80,60,170))
        dxDrawText(skin, x+26, by+6, x+200, by+26, tocolor(200,255,180), 1, "default-bold")
        dxDrawText("Preço: "..opt.price.."$ | Duração: "..opt.duration.."h", x+240, by+6, x+w-36, by+26, tocolor(255,255,255), 0.95, "default")
        if rental and rental.expires then
            dxDrawText("Expira em: "..math.floor((rental.expires-getRealTime().timestamp)/3600).."h", x+26, by+28, x+200, by+48, tocolor(255,255,180), 0.95, "default")
        end
        idx = idx + 1
        if idx > 4 then break end
    end
end
addEventHandler("onClientRender", root, drawRentalsPanel)
addEvent("forgex:rentalUpdated", true)
addEventHandler("forgex:rentalUpdated", root, function(skin, expires)
    if rentalsData[skin] then
        rentalsData[skin].expires = expires
    end
    if isRentalsVisible then
        triggerServerEvent("forgex:requestRentals", localPlayer)
    end
end)
addEvent("forgex:rentalRemoved", true)
addEventHandler("forgex:rentalRemoved", root, function(skin)
    if rentalsData[skin] then
        rentalsData[skin] = nil
    end
    if isRentalsVisible then
        triggerServerEvent("forgex:requestRentals", localPlayer)
    end
end)
addEvent("forgex:rentalReset", true)
addEventHandler("forgex:rentalReset", root, function()
    rentalsData = {}
    if isRentalsVisible then
        triggerServerEvent("forgex:requestRentals", localPlayer)
    end
end)