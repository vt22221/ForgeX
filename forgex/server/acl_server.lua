local aclGroups = {}

function loadAclConfig()
    local configFile = fileOpen("config/acl.json")
    if configFile then
        local configContent = fileRead(configFile, fileGetSize(configFile))
        aclGroups = fromJSON(configContent)
        fileClose(configFile)
    end
end

function hasPermission(player, permission)
    local account = getPlayerAccount(player)
    if isGuestAccount(account) then return false end

    for group, data in pairs(aclGroups.groups) do
        if isObjectInACLGroup("user." .. getAccountName(account), aclGetGroup(group)) then
            if table.indexOf(data.permissions, permission) ~= -1 then
                return true
            end
        end
    end
    return false
end

addEventHandler("onResourceStart", resourceRoot, loadAclConfig)