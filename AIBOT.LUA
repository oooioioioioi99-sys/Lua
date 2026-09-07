-- Sistema de Inventário
local Inventario = {
    itens = {},
    capacidade = 20
}

-- Função para adicionar item
function Inventario:adicionar(item, quantidade)
    quantidade = quantidade or 1
    
    if self:contarItens() >= self.capacidade then
        print("❌ Inventário cheio!")
        return false
    end
    
    if self.itens[item] then
        self.itens[item] = self.itens[item] + quantidade
    else
        self.itens[item] = quantidade
    end
    
    print("✅ Adicionado " .. quantidade .. "x " .. item)
    return true
end

-- Função para remover item
function Inventario:remover(item, quantidade)
    quantidade = quantidade or 1
    
    if not self.itens[item] then
        print("❌ Item não encontrado: " .. item)
        return false
    end
    
    if self.itens[item] < quantidade then
        print("❌ Você só tem " .. self.itens[item] .. "x " .. item)
        return false
    end
    
    self.itens[item] = self.itens[item] - quantidade
    
    if self.itens[item] <= 0 then
        self.itens[item] = nil
    end
    
    print("🗑️ Removido " .. quantidade .. "x " .. item)
    return true
end

-- Função para listar itens
function Inventario:listar()
    print("\n📦 INVENTÁRIO (" .. self:contarItens() .. "/" .. self.capacidade .. "):")
    
    if next(self.itens) == nil then
        print("  (vazio)")
        return
    end
    
    for item, qtd in pairs(self.itens) do
        print("  • " .. item .. ": " .. qtd .. "x")
    end
    print("")
end

-- Função para contar itens únicos
function Inventario:contarItens()
    local total = 0
    for _ in pairs(self.itens) do
        total = total + 1
    end
    return total
end

-- Função para verificar se tem item
function Inventario:temItem(item, quantidade)
    quantidade = quantidade or 1
    return self.itens[item] and self.itens[item] >= quantidade
end

-- ===== TESTANDO O SISTEMA =====

-- Criando um inventário
local meuInventario = Inventario

-- Adicionando itens
meuInventario:adicionar("Poção de Vida", 5)
meuInventario:adicionar("Espada de Ferro", 1)
meuInventario:adicionar("Poção de Vida", 3)  -- Adiciona mais

-- Listando
meuInventario:listar()

-- Verificando itens
if meuInventario:temItem("Poção de Vida", 8) then
    print("⚔️ Você tem poções suficientes!")
end

-- Removendo
meuInventario:remover("Poção de Vida", 2)
meuInventario:listar()

-- Tentando remover mais do que tem
meuInventario:remover("Poção de Vida", 20)
