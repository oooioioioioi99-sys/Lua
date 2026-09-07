-- Configurações
local alvo = "Ovo"  -- Nome do item
local distancia = 5  -- Raio de busca

-- Função principal
function coletarItem()
    local item = localizarObjeto(alvo, distancia)
    if item then
        moverAte(item.posicao)
        interagir(item)
        print("Item coletado: " .. alvo)
    else
        print("Nenhum " .. alvo .. " encontrado")
    end
end

-- Loop de execução
while true do
    coletarItem()
    esperar(1)  -- Pausa de 1 segundo
end
