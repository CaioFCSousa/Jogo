# 🎮 Teste Jogo Legal

Um jogo 2D de **plataforma com elementos de metroidvania** desenvolvido em **Godot 4.6**, apresentando um inovador sistema de seleção de habilidades baseado em cartas para até 2 jogadores.

---

## 📋 Sumário

- [Características](#características)
- [Requisitos](#requisitos)
- [Instalação](#instalação)
- [Como Jogar](#como-jogar)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Sistemas do Jogo](#sistemas-do-jogo)
- [Controles](#controles)
- [Desenvolvimento](#desenvolvimento)

---

## ✨ Características

### 🎯 Mecânicas Principais
- **Movimentação fluida** com coyote time para pulos mais naturais
- **Sistema de estados** (Idle, Move, Jump, Fall, Slide, Climb)
- **Escalada** em paredes (com habilidade desbloqueável)
- **Deslizamento** (slide) rápido com animações
- **Animações dinâmicas** que respondem ao estado do personagem

### 🎴 Sistema de Cartas de Habilidades
- Tela de seleção pré-fase para 2 jogadores
- **3 cartas** por jogador para escolher 1 habilidade
- Habilidades podem ser **PASSIVAS** ou **ATIVAS**
- Modificadores de status: velocidade, força de pulo, cooldown
- **Efeitos especiais**: escalada, bloqueio de pulo, debuff de velocidade

### ⚔️ Sistema de Debuffs
- Jogadores afetados por habilidades ativas de inimigos
- Mudança visual de cor durante debuff
- Efeitos temporários que revertam após duração

### 👾 Entidades
- **Personagem Jogável (P1 e P2)** com cores customizáveis
- **Inimigos** (Base implementada com Cogumelo como exemplo)
- **Sistema de Hitbox/Hurtbox** para detectar colisões

### 📷 Câmera
- **Câmera normal** para um jogador
- **Câmera de 2 alvos** para modo cooperativo
- Ponto focal ajustável

---

## 🛠️ Requisitos

- **Godot Engine 4.6** (ou superior)
- **Sistema Operacional**: Windows, Linux ou macOS
- **Resolução**: 1920x1080 (padrão do projeto)

---

## 📥 Instalação

1. **Clone o repositório**:
   ```bash
   git clone <seu-repositorio>
   cd teste-jogo-legal-
   ```

2. **Abra em Godot 4.6**:
   - Abra Godot Engine
   - Clique em "Abrir Projeto"
   - Selecione a pasta do projeto
   - Aguarde a importação dos assets

3. **Execute o projeto**:
   - Pressione `F5` ou clique em "Play" no editor
   - A cena padrão é `res://levels/level_test.tscn`

---

## 🎮 Como Jogar

### Objetivo
Completar fases como um/dois jogadores, selecionando habilidades estratégicas para superar obstáculos e inimigos.

### Fluxo do Jogo
1. **Tela de Seleção**: Ambos jogadores escolhem 1 de 3 habilidades
2. **Fase**: Controle o personagem, desvie de inimigos, complete desafios
3. **Vitória**: Alcance a saída da fase

### Mecânicas Especiais
- **Coyote Time**: Pule mesmo após sair da plataforma (0.15s)
- **Gravidade Dinâmica**: Gravidade aumenta ao cair, diminui ao subir
- **Debuffs**: Se atingido por inimigos com habilidades, sofra modificadores

---

## 📁 Estrutura do Projeto

```
teste-jogo-legal-/
│
├── assets/                           # Recursos visuais
│   ├── atlas/                        # Atlas de texturas
│   ├── Cards/                        # Sprites de cartas e VFX
│   ├── platformer_metroidvania/      # Asset pack importado
│   ├── shaders/                      # Shaders GLSL
│   └── sprites/                      # Sprites gerais
│
├── components/                       # Componentes reutilizáveis
│   ├── camera/                       # Lógica de câmera
│   ├── comportamentos/               # Comportamentos
│   ├── controle/                     # Cenas de controle
│   ├── hitbox/                       # Sistema de colisão
│   ├── morte/                        # Sistema de morte/respawn
│   └── vida/                         # Sistema de vida
│
├── entities/                         # Entidades do jogo
│   ├── player/                       # Personagem jogável
│   │   ├── movimentacao_Player.gd
│   │   ├── Player.tscn
│   │   ├── player1.tres
│   │   └── player2.tres
│   └── inimigos/                     # Inimigos
│       ├── congumelo.gd
│       └── congumelo.tscn
│
├── levels/                           # Fases do jogo
│   ├── level_test.tscn
│   ├── level_components_test.tscn
│   ├── level_enemies_test.tscn
│   └── level_old.tscn
│
├── resources/                        # Dados e resources
│   ├── AbilityResource.gd
│   ├── abilities/
│   │   ├── arpao.tres
│   │   ├── fogo.tres
│   │   ├── garras.tres
│   │   ├── gelo.tres
│   │   └── levitar.tres
│   └── card_resources/
│       └── card_camada.gd
│
├── ui/                               # Interface do usuário
│   ├── card/
│   │   ├── CardUI.gd
│   │   └── CardUI.tscn
│   ├── selection_screen/
│   │   ├── SelectionManager.gd
│   │   └── SelectionManager.tscn
│   └── vida_ui/
│
├── world/                            # Mundo do jogo
│   └── tileset/
│       ├── bloco_defalut.tres
│       └── tile_dos_blocosdo_cenario.tscn
│
├── project.godot
└── MudancaLog.md
```

---

## 🎮 Sistemas do Jogo

### 1. Sistema de Movimentação
**Arquivo**: `entities/player/movimentacao_Player.gd`

Gerencia todos os estados do personagem com máquina de estados (FSM):
- Movimentação horizontal
- Pulo com coyote time (0.15s após sair da plataforma)
- Slide rápido (deslizamento)
- Escalada em paredes
- Gravidade dinâmica (aumenta ao cair, diminui ao subir)

**Estados**:
```
IDLE → MOVE ↔ JUMP → FALL
          ↓
       SLIDE
          ↓
       CLIMB (com escalada desbloqueada)
```

### 2. Sistema de Habilidades
**Arquivo**: `resources/AbilityResource.gd`

Define propriedades das habilidades:
- Nome e modo (PASSIVA ou ATIVA)
- Multiplicadores: velocidade, pulo
- Efeitos: escalada, bloqueio de pulo, debuff
- Cooldown e duração do debuff

**5 Habilidades Disponíveis**:
1. **Arpão** - Disparar ganchos
2. **Fogo** - Queimar inimigos
3. **Garras** - Aumentar dano
4. **Gelo** - Congelar inimigos
5. **Levitar** - Flutuar

### 3. Tela de Seleção
**Arquivo**: `ui/selection_screen/SelectionManager.gd`

- Pausa o jogo durante seleção
- Gera 3 cartas aleatórias por jogador
- Animações visuais das seleções
- Resume o jogo após ambos escolherem

### 4. Sistema de Câmera
**Arquivo**: `components/camera/`

- Câmera normal (1 jogador)
- Câmera de 2 alvos (cooperativo)
- Ajustes de zoom dinâmico

---

## 🎮 Controles

### Jogador 1 (P1)
| Ação | Tecla |
|------|-------|
| Mover Esquerda | `A` ou `←` |
| Mover Direita | `D` ou `→` |
| Pular | `W` ou `↑` |
| Deslizar | Customizável |
| Habilidade | Customizável |

### Jogador 2 (P2)
Configurável via input map em `project.godot`.

---

## 🔧 Desenvolvimento

### Adicionar Nova Habilidade
1. Crie um arquivo `.tres` em `resources/abilities/`
2. Configure as propriedades em `AbilityResource`
3. Adicione à lista do `SelectionManager`

### Criar Novo Inimigo
1. Crie script em `entities/inimigos/`
2. Herde de `CharacterBody2D`
3. Implemente lógica de IA e colisões
4. Adicione à cena do nível

### Adicionar Nova Fase
1. Nova cena em `levels/`
2. Use tileset de `world/tileset/`
3. Instancie `Player.tscn`
4. Configure câmera

### Padrões de Código
- **Variáveis**: `snake_case`
- **Funções privadas**: `_func_name()`
- **Constantes**: `CONSTANT_NAME`
- **Classes**: `PascalCase`

---

## 📊 Roadmap

- [ ] Multiplayer online
- [ ] Sistema de save/load
- [ ] Menu principal
- [ ] Mais fases (5+ níveis)
- [ ] Boss battles
- [ ] Sistema de upgrades
- [ ] Trilha sonora e SFX
- [ ] Cutscenes

---

## 🐛 Troubleshooting

### Script não encontrado
- Verifique os imports em `project.godot`
- Confirme os caminhos estão corretos

### Textura faltando
- Reimporte assets: `File` → `Reimport`
- Delete `.godot/` para limpar cache

### Personagem não se move
- Verifique se está na cena correta
- Confirme CollisionShape2D existe
- Teste inputs em `project.godot`

---

## 📄 Licença

Apache 2.0

---

## 👤 Autor

Desenvolvido como projeto de estudo de Godot 4.6.

---

## 🤝 Contribuindo

1. Fork o repositório
2. Crie uma branch (`git checkout -b feature/melhoria`)
3. Commit suas mudanças (`git commit -m 'Adiciona melhoria'`)
4. Push (`git push origin feature/melhoria`)
5. Abra um Pull Request

---

## 📞 Suporte

- Abra uma issue no repositório
- Documentação Godot: [docs.godotengine.org](https://docs.godotengine.org)

---

**Versão**: 0.1.0  
**Atualizado**: Fevereiro 2026  
**Engine**: Godot 4.6
