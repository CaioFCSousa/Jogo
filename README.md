Estrutura do Projeto Godot
Seu projeto está organizado da seguinte forma:

Raiz do Projeto
project.godot - Arquivo de configuração do projeto Godot
README.md - Documentação do projeto
assets/ - Recursos do Jogo
Contém todos os assets visuais:

platformer_metroidvania asset pack v1.01/
enemies sprites/ - Sprites dos inimigos (bomber goblin, fly, goblin, mushroom, slime, worm)
fauna sprites/ - Sprites de animais (pássaros, coelhos)
herochar sprites(new)/ - Sprites do personagem principal
Subpastas: Fall, Idle, jump, Run, slide
Animações: idle, run, jump, ataque, morte, dano, etc.
hud elements/ - Elementos da interface (moedas, vidas, corações, orbs)
miscellaneous sprites/ - Sprites diversos
tiles and background_foreground (new)/ - Tiles para mapas e fundos
shaders/
Shaders GLSL para efeitos visuais (cor.gdshader)
sprites/
Ícnes e assets gerais
components/ - Componentes Reutilizáveis
camera/ - Lógica de câmera
ajuste_camera.gd - Script de ajuste
logica_ponto_camera.gd - Ponto focal da câmera
ponto_camera.tscn - Cena da câmera
entities/ - Entidades do Jogo
player/ - Personagem principal
movimentacao_Player.gd - Script de movimentação
Player.tscn - Cena do player
levels/ - Fases/Níveis
levels/ - Contém as cenas dos níveis
level_Teste.tscn - Nível de teste
tetse.tscn - Outro nível
world/ - Mundo do Jogo
tileset/ - Tileset do cenário
tile_dos_blocosdo_cenario.tscn - Tiles dos blocos
