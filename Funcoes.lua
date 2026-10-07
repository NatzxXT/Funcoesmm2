-- ==========================================
-- REPOSITÓRIO B: MÓDULOS DO JOGO
-- ==========================================

-- 1. Espera o HUD do Repositório A carregar
repeat task.wait() until getgenv().YARHM and getgenv().YARHM_FUNCTIONS

-- 2. O TRUQUE: Criamos um 'script' falso que aponta para o Menu do Repositório A
-- Assim, todas as linhas originais que usam 'script.Parent' vão funcionar de primeira!
local script = { Parent = getgenv().YARHM }

-- 3. Puxa as funções do menu
local fu = getgenv().YARHM_FUNCTIONS

-- ==========================================
-- COLE AS ROTINAS A PARTIR DAQUI:
-- ==========================================

local function JWXW_routine() -- StarterGui.YARHM.Universal
    -- (Código original da rotina Universal inteira)
end

local function XEEC_routine() -- StarterGui.YARHM.Murder Mystery 2
    -- (Código original da rotina Murder Mystery 2 inteira)
end

local function UPQDPIR_routine() -- StarterGui.YARHM.AdLoader
    -- (Código original da rotina AdLoader inteira)
end

-- ==========================================
-- EXECUÇÃO DOS MÓDULOS
-- ==========================================
coroutine.wrap(JWXW_routine)()
coroutine.wrap(XEEC_routine)()
coroutine.wrap(UPQDPIR_routine)()

print("✅ [YARHM] Módulos do jogo (MM2, Universal) carregados com sucesso!")
