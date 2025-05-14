local licenseConfig = {
    authorizedIP = "123.123.123.123",
    expirationDate = "2025-12-31"
}

function validateLicense()
    local serverIP = getServerIP()
    local currentDate = getRealTime().timestamp

    if serverIP ~= licenseConfig.authorizedIP then
        outputDebugString("Licença inválida: IP não autorizado!", 1)
        return false
    end

    local expirationTimestamp = getTimestampFromDate(licenseConfig.expirationDate)
    if currentDate > expirationTimestamp then
        outputDebugString("Licença expirada!", 1)
        return false
    end

    outputDebugString("Licença válida.", 3)
    return true
end

function getTimestampFromDate(dateString)
    local year, month, day = dateString:match("(%d+)-(%d+)-(%d+)")
    return os.time({year = year, month = month, day = day})
end

addEventHandler("onResourceStart", resourceRoot, function()
    if not validateLicense() then
        cancelEvent()
    end
end)