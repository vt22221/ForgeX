local logFiles = {
    economy = "logs/economy_transactions.log",
    marketplace = "logs/marketplace.log",
    crafting = "logs/crafting.log"
}

function logAction(logType, message)
    local logFile = fileExists(logFiles[logType]) and fileOpen(logFiles[logType]) or fileCreate(logFiles[logType])
    if logFile then
        local timestamp = os.date("%Y-%m-%d %H:%M:%S")
        local logMessage = string.format("[%s] %s\n", timestamp, message)
        fileSetPos(logFile, fileGetSize(logFile))
        fileWrite(logFile, logMessage)
        fileClose(logFile)
    end
end