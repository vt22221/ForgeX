function drawMarketplace()
    dxDrawRectangle(100, 100, 600, 400, tocolor(0, 0, 0, 200))
    dxDrawText("Marketplace - Itens Disponíveis", 120, 120, 580, 140, tocolor(255, 255, 255, 255), 1, "default-bold")

    for i, item in ipairs(marketplace) do
        local y = 140 + (i * 20)
        dxDrawText(i .. ". " .. item.item .. " - " .. item.price .. " ForgeCoins", 120, y, 580, y + 20, tocolor(255, 255, 255, 255), 1, "default")
    end
end

addEventHandler("onClientRender", root, drawMarketplace)