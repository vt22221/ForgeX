--[[
    ForgeX - Database Manager (SQLite)
    Gerencia a conexao, criacao de tabelas e operacoes no banco de dados.
    Esta versao e centralizada e robusta.
]]

DB = {}
local dbh -- Database handler

-- Inicia a conexao com o banco de dados e cria todas as tabelas necessarias
function DB.init()
    local dbFilePath = "data/forgex_data.db"
    dbh = dbConnect("sqlite", ":" .. getResourceName(getThisResource()) .. "/" .. dbFilePath)

    if not dbh then
        outputServerLog("[ForgeX] ERRO FATAL: Nao foi possivel conectar ou criar o banco de dados SQLite em: " .. dbFilePath)
        return false
    end

    dbExec(dbh, "PRAGMA journal_mode = WAL;") -- Melhora a concorrencia de escrita/leitura
    dbExec(dbh, "PRAGMA foreign_keys = ON;")

    -- Tabela principal de contas dos jogadores
    dbExec(dbh, [[
        CREATE TABLE IF NOT EXISTS accounts (
            id INTEGER PRIMARY KEY,
            account_name TEXT NOT NULL UNIQUE,
            last_login INTEGER
        );
    ]])

    -- Tabela de dados gerais do jogador (JSON para flexibilidade)
    dbExec(dbh, [[
        CREATE TABLE IF NOT EXISTS player_data (
            player_id INTEGER PRIMARY KEY,
            profile TEXT, -- JSON com: { money=1000, elo=1000, bp_xp=0, bp_level=1, ... }
            inventory TEXT, -- JSON com: { [item_id] = amount }
            achievements TEXT, -- JSON com: { [ach_id] = { progress=N, unlocked_date=timestamp } }
            battlepass TEXT, -- JSON com: { claimed_levels = { [level]=true } }
            missions TEXT, -- JSON com: { daily={...}, weekly={...} }
            rentals TEXT, -- JSON com: { [skin_id] = { expires_at=timestamp, level=N } }
            FOREIGN KEY(player_id) REFERENCES accounts(id)
        );
    ]])
    
    -- Tabela do Marketplace
    dbExec(dbh, [[
        CREATE TABLE IF NOT EXISTS marketplace_listings (
            listing_id INTEGER PRIMARY KEY AUTOINCREMENT,
            seller_id INTEGER NOT NULL,
            item_id TEXT NOT NULL,
            amount INTEGER NOT NULL,
            price INTEGER NOT NULL,
            timestamp INTEGER NOT NULL,
            FOREIGN KEY(seller_id) REFERENCES accounts(id)
        );
    ]])

    -- Tabela de Logs do Sistema
    dbExec(dbh, [[
        CREATE TABLE IF NOT EXISTS system_logs (
            log_id INTEGER PRIMARY KEY AUTOINCREMENT,
            timestamp INTEGER NOT NULL,
            category TEXT NOT NULL, -- ex: 'marketplace', 'admin', 'inventory'
            actor_id INTEGER,
            target_id INTEGER,
            details TEXT
        );
    ]])
    
    outputServerLog("[ForgeX] Banco de dados SQLite conectado e tabelas verificadas com sucesso.")
    return true
end

-- Funcao generica para executar queries que retornam dados (SELECT)
function DB.query(sql, ...)
    if not dbh then return nil end
    local qh, num_rows, err = dbQuery(dbh, sql, ...)
    if qh then
        return dbPoll(qh, -1)
    end
    if err then
        outputServerLog("[ForgeX] DB Query Error: " .. err)
    end
    return nil
end

-- Funcao generica para executar comandos que nao retornam dados (INSERT, UPDATE, DELETE)
function DB.exec(sql, ...)
    if not dbh then return false end
    return dbExec(dbh, sql, ...)
end

-- Fecha a conexao com o banco de dados
function DB.close()
    if dbh then
        dbClose(dbh)
        dbh = nil
    end
end

-- Adiciona listeners para garantir a inicializacao e o fechamento corretos
addEventHandler("onResourceStart", resourceRoot, DB.init, true)
addEventHandler("onResourceStop", resourceRoot, DB.close)