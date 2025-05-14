local playerInventory = {}

-- Adicionar item ao inventário
function addItemToInventory(item)
    table.insert(playerInventory, item)
    outputChatBox("Item adicionado ao inventário: " .. item.name)
end

-- Remover item do inventário
function removeItemFromInventory(itemName)
    for i, item in ipairs(playerInventory) do
        if item.name == itemName then
            table.remove(playerInventory, i)
            outputChatBox("Item removido do inventário: " .. itemName)
            return true
        end
    end
    return false
end

-- Exibir inventário
function showInventory()
    outputChatBox("=== Inventário ===")
    for _, item in ipairs(playerInventory) do
        outputChatBox("* " .. item.name .. " (Raridade: " .. item.rarity .. ")")
    end
end

-- Comandos
addCommandHandler("additem", function(_, itemName)
    addItemToInventory({name = itemName, rarity = "common"})
end)

addCommandHandler("removeitem", function(_, itemName)
    removeItemFromInventory(itemName)
end)

addCommandHandler("showinventory", showInventory)