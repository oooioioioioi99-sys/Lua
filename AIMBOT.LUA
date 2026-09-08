-- Sistema Anti-Cheat para BLOX FRUITS (Ambiente de Teste)
-- Detecta padrões de scripts populares no jogo

local Detector = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

-- ============================================
-- CONFIGURAÇÕES ESPECÍFICAS DO BLOX FRUITS
-- ============================================
local CONFIG = {
    -- Teleport: cheats de AutoFarm teleportam para baús/chest [citation:1]
    MAX_TELEPORT_DIST = 50,  -- studs por frame (movimento natural é contínuo)
    
    -- Auto-Click: cliques excessivos para farm [citation:1]
    MAX_CLICKS_PER_SECOND = 15,
    
    -- Auto-Farm: ficar parado em área de spawn de NPCs
    MAX_IDLE_FARM_TIME = 300, -- 5 minutos sem se mover em área de farm
    
    -- Detecção de "Server Hop" para evitar ban [citation:5]
    MAX_REJOIN_PER_MINUTE = 3,
    
    -- Fruit Grabber: teleport para frutas [citation:10]
    FRUIT_GRAB_DISTANCE = 100, -- distância máxima para interagir com fruta
    
    -- Limiar para marcar como suspeito
    SUSPECT_THRESHOLD = 3
}

local playerData = {}

-- ============================================
-- DETECTOR 1: TELEPORTE (AutoFarm/AutoChest)
-- ============================================
function Detector:checkTeleport(player)
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    local data = playerData[player.UserId]
    if not data then return end
    
    local currentPos = char.HumanoidRootPart.Position
    local dist = (currentPos - data.lastPos).Magnitude
    
    -- Teleport suspeito (maior que o permitido em 1 frame)
    if dist > CONFIG.MAX_TELEPORT_DIST then
        data.suspicious = data.suspicious + 1
        table.insert(data.alerts, {
            type = "Teleport (AutoFarm)",
            time = os.time(),
            distance = math.floor(dist)
        })
        self:report(player, string.format("🚀 Teleporte suspeito: %d studs", math.floor(dist)))
    end
    
    data.lastPos = currentPos
end

-- ============================================
-- DETECTOR 2: AUTO-CLICK (Farm de dinheiro)
-- ============================================
function Detector:registerClick(player)
    local data = playerData[player.UserId]
    if not data then return end
    
    local now = tick()
    table.insert(data.clicks, now)
    
    -- Remove clicks antigos (>1s)
    while #data.clicks > 0 and data.clicks[1] < now - 1 do
        table.remove(data.clicks, 1)
    end
    
    -- Acima do limite humano (~8-12 clicks/seg) [citation:1]
    if #data.clicks > CONFIG.MAX_CLICKS_PER_SECOND then
        data.suspicious = data.suspicious + 1
        table.insert(data.alerts, {
            type = "Auto-Click",
            time = os.time(),
            rate = #data.clicks
        })
        self:report(player, string.format("🖱️ Auto-Click detectado: %d clicks/seg", #data.clicks))
    end
end

-- ============================================
-- DETECTOR 3: FRUIT GRABBER (Teleport para frutas)
-- ============================================
function Detector:checkFruitInteraction(player, fruitPosition)
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    local dist = (char.HumanoidRootPart.Position - fruitPosition).Magnitude
    
    -- Interagiu com fruta longe do personagem
    if dist > CONFIG.FRUIT_GRAB_DISTANCE then
        self:report(player, string.format("🍎 Fruit Grabber suspeito: %d studs de distância", math.floor(dist)))
    end
end

-- ============================================
-- DETECTOR 4: EXECUTOR DETECTION (Detecta scripts rodando)
-- ============================================
function Detector:checkExecutorEnvironment()
    -- Verifica se getfenv foi modificado (comum em executors) [citation:7]
    local ok, info = pcall(debug.getinfo, getfenv, "S")
    if ok and info and info.what ~= "C" then
        warn("⚠️ Ambiente de execução suspeito detectado (getfenv modificado)")
    end
    
    -- Verifica se funções comuns de executor existem [citation:7]
    local executorFuncs = {"getgenv", "syn", "getexecutorname", "identifyexecutor"}
    for _, funcName in ipairs(executorFuncs) do
        if _G[funcName] then
            warn(string.format("⚠️ Função de executor detectada: %s", funcName))
        end
    end
end

-- ============================================
-- RELATÓRIO E LOG
-- ============================================
function Detector:report(player, reason)
    print(string.format("[ANTI-CHEAT BLOX FRUITS] %s (%d) - %s", player.Name, player.UserId, reason))
    
    local data = playerData[player.UserId]
    if data and data.suspicious >= CONFIG.SUSPECT_THRESHOLD then
        warn(string.format("⚠️ JOGADOR MARCADO: %s - %d alertas - CONSIDERE BANIR", player.Name, data.suspicious))
        -- Em produção: kick, ban temporário ou log para análise
    end
end

-- ============================================
-- INICIALIZAÇÃO
-- ============================================
function Detector:init()
    -- Players existentes
    for _, player in ipairs(Players:GetPlayers()) do
        playerData[player.UserId] = {
            lastPos = Vector3.new(),
            clicks = {},
            suspicious = 0,
            alerts = {},
            joinTime = os.time()
        }
    end
    
    -- Novos jogadores
    Players.PlayerAdded:Connect(function(player)
        playerData[player.UserId] = {
            lastPos = Vector3.new(),
            clicks = {},
            suspicious = 0,
            alerts = {},
            joinTime = os.time()
        }
    end)
    
    Players.PlayerRemoved:Connect(function(player)
        playerData[player.UserId] = nil
    end)
    
    -- Loop principal
    RunService.Heartbeat:Connect(function()
        for _, player in ipairs(Players:GetPlayers()) do
            self:checkTeleport(player)
        end
        self:checkExecutorEnvironment()
    end)
    
    print("[ANTI-CHEAT BLOX FRUITS] Sistema iniciado!")
end

return Detector
