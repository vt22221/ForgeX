--[[
ForgeX Language System
- Multi-idioma para notificações, UI, comandos e mensagens
- Suporte para expansão fácil (adicione/edite arquivos em data/lang/)
- Integração automática: use lang para mensagens em todos módulos
]]

local langFiles = {}
local defaultLang = "pt"

-- Carrega arquivos de tradução (exemplo: data/lang/pt.json, data/lang/en.json)
function loadLanguages()
    langFiles = {}
    local files = fileOpen("data/lang/")
    if files then
        repeat
            local fname = fileRead(files, 128)
            if fname and fname:match("%.json$") then
                local langcode = fname:match("([%a_]+)%.json$")
                local content = fileGetContents("data/lang/"..fname)
                if content and langcode then
                    langFiles[langcode] = fromJSON(content)
                end
            end
        until not fname
        fileClose(files)
    end
end
loadLanguages()

-- Retorna string traduzida
function tr(key, lang, data)
    lang = lang or defaultLang
    local t = langFiles[lang] and langFiles[lang][key] or langFiles[defaultLang][key] or key
    if data then
        for k,v in pairs(data) do
            t = t:gsub("{"..k.."}", tostring(v))
        end
    end
    return t
end

-- Exemplo de uso em notificação:
-- triggerClientEvent(plr, "forgex:showNotification", resourceRoot, tr("mission_complete", plrLang, {desc=missao}), 80,255,255)

-- Detecta idioma do player (pode usar config, conta, IP, etc)
function getPlayerLang(plr)
    -- Exemplo: detectar por ACL, variável, config, etc
    return getElementData(plr, "lang") or defaultLang
end

-- Evento para atualizar idioma do jogador
addEvent("forgex:setLang", true)
addEventHandler("forgex:setLang", root, function(lang)
    setElementData(client, "lang", lang)
    triggerClientEvent(client, "forgex:showNotification", resourceRoot, tr("lang_set", lang), 80,255,255)
end)

-- Exemplo de integração em qualquer módulo:
-- local msg = tr("battlepass_reward", getPlayerLang(plr), {level=5, prize="AK47 Gold"})