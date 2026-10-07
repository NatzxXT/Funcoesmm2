-- 1. Carrega o HUD (Repositório A)
local urlHUD = "https://raw.githubusercontent.com/NatzzXT/HUDmm2/main/HUD.lua"
loadstring(game:HttpGet(urlHUD))()

-- 2. Espera o HUD carregar completamente
repeat task.wait() until getgenv().YARHM
task.wait(2) -- Dá um tempo extra para o menu animar na tela

-- 3. Carrega as Funções (Repositório B)
local urlFuncoes = "https://raw.githubusercontent.com/NatzzXT/Funcoesmm2/main/Funcoes.lua"
loadstring(game:HttpGet(urlFuncoes))()

print("🚀 YARHM carregado com sucesso usando o método Loader!")
