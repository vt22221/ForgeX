local skins = {}
local selectedSkin = nil

function loadSkins()
    local skinsData = fileOpen("data/skins.json")
    if skinsData then
        local content = fileRead(skinsData, fileGetSize(skinsData))
        skins = fromJSON(content)
        fileClose(skinsData)
    end
end

function previewSkin(skinId)
    for _, skin in ipairs(skins.skins) do
        if skin.id == skinId then
            selectedSkin = skin
            outputChatBox("Pré-visualizando skin: " .. skin.name)
            -- Lógica para aplicar visualmente a skin no modelo
            return
        end
    end
    outputChatBox("Skin não encontrada!", 255, 0, 0)
end

function applySkin()
    if selectedSkin then
        triggerServerEvent("applyPlayerSkin", resourceRoot, selectedSkin.id)
        outputChatBox("Skin aplicada: " .. selectedSkin.name, 0, 255, 0)
        selectedSkin = nil
    else
        outputChatBox("Nenhuma skin selecionada!", 255, 0, 0)
    end
end

addCommandHandler("previewskin", function(_, skinId)
    previewSkin(tonumber(skinId))
end)

addCommandHandler("applyskin", applySkin)