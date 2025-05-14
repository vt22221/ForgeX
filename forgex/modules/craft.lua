function createCraftItem(player, recipeId)
    if not hasPermission(player, "crafting.create") then
        outputChatBox("Você não tem permissão para criar este item.", player, 255, 0, 0)
        return
    end

    local recipe = craftingRecipes[recipeId]
    if not recipe then
        outputChatBox("Receita inválida.", player, 255, 0, 0)
        return
    end

    -- Lógica de crafting aqui
    outputChatBox("Item criado com sucesso!", player, 0, 255, 0)
end