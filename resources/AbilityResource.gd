extends Resource
class_name AbilityResource

@export_group("Identidade")
@export var nome: String = "Nova Habilidade"
@export_enum("PASSIVA", "ATIVA") var modo_uso: String = "ATIVA"

# AbilityResource.gd
@export_group("Visual")
@export var camadas_custom: Array[CartaCamada] = []

@export_group("Status e Poder")
@export var cooldown: float = 2.0
@export var multiplicador_pulo: float = 1.0
@export var multiplicador_velocidade: float = 1.0
@export var debuff_velocidade: float = 1.0
@export var concede_escalada: bool = false
@export var bloqueia_pulo: bool = false    
@export var duracao_debuff: float = 3.0
