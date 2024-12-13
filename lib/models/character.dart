class Character {
  int level;
  int strength;
  int xp;
  int xpToNextLevel;
  int currentHp;
  int currentMp;
  Map<String, String?> equipment;
  List<String> inventory;

  Character({
    required this.level,
    required this.strength,
    required this.xp,
    required this.xpToNextLevel,
    required this.currentHp,
    required this.currentMp,
    required this.equipment,
    this.inventory = const [],
  }) {
    // Certifique-se de que todos os slots estão inicializados
    equipment.addAll({
      'Espada': equipment['Espada'] ?? null,
      'Capacete': equipment['Capacete'] ?? null,
      'Peitoral': equipment['Peitoral'] ?? null,
      'Acessório': equipment['Acessório'] ?? null,
      'Calça': equipment['Calça'] ?? null,
      'Escudo': equipment['Escudo'] ?? null,
      'Anel': equipment['Anel'] ?? null,
      'Luva': equipment['Luva'] ?? null,
    });
  }

  // Cálculo de força total
  int get totalStrength {
    int bonus = _getEquipmentBonus('strength');
    return strength + bonus; // Força base + bônus de equipamentos
  }

  // Cálculo de HP total
  int get totalHp {
    int bonus = _getEquipmentBonus('hp');
    return 50 + (level * 20) + bonus; // HP base aumentado para 50 + bônus
  }

  // Cálculo de MP total
  int get totalMp {
    int bonus = _getEquipmentBonus('mp');
    return 20 + (level * 10) + bonus; // MP base aumentado para 20 + bônus
  }

  // Cálculo de bônus de atributos baseados em equipamentos
  int _getEquipmentBonus(String attribute) {
    int bonus = 0;
    for (var item in equipment.values) {
      if (item != null) {
        bonus += _equipmentBonuses[item]?[attribute] ?? 0;
      }
    }
    return bonus;
  }

  // Atualiza o HP atual ao equipar itens que alteram o HP total
  void updateCurrentHp() {
    if (currentHp > totalHp) {
      currentHp = totalHp;
    }
  }

  // Atualiza o MP atual ao equipar itens que alteram o MP total
  void updateCurrentMp() {
    if (currentMp > totalMp) {
      currentMp = totalMp;
    }
  }
}

// Atualização no mapa de equipamentos disponíveis
const Map<String, Map<String, int>> _equipmentBonuses = {
  // Swords
  'Espada Lendária': {'strength': 10, 'hp': 0, 'mp': 0},
  'Espada Comum': {'strength': 5, 'hp': 0, 'mp': 0},

  // Helmets
  'Elmo de Guerreiro': {'strength': 0, 'hp': 10, 'mp': 0},
  'Elmo de Ferro': {'strength': 0, 'hp': 5, 'mp': 0},

  // Peitoral armors
  'Peitoral de Aço': {'strength': 0, 'hp': 30, 'mp': 0},
  'Peitoral Mágico': {'strength': 0, 'hp': 0, 'mp': 15},

  // Accessories
  'Anel Mágico': {'strength': 0, 'hp': 0, 'mp': 20},
  'Anel de Prata': {'strength': 2, 'hp': 0, 'mp': 5},

  // Calça
  'Perneiras de Aço': {'strength': 0, 'hp': 15, 'mp': 0},
  'Perneiras de Couro': {'strength': 0, 'hp': 5, 'mp': 0},

  // Shields
  'Escudo de Bronze': {'strength': 0, 'hp': 20, 'mp': 0},
  'Escudo Mágico': {'strength': 0, 'hp': 10, 'mp': 10},

  // Gloves
  'Luvas de Força': {'strength': 5, 'hp': 0, 'mp': 0},
  'Luvas de Couro': {'strength': 2, 'hp': 0, 'mp': 0},
};

// Atualização no equipamento inicial (incluindo os novos slots)
final Map<String, String?> initialEquipment = {
  'Espada': null,
  'Capacete': null,
  'Peitoral': null,
  'Acessório': null,
  'Calça': null,
  'Escudo': null,
  'Anel': null,
  'Luva': null,
};

// Atualize o construtor do Character para usar os novos slots
final Character defaultCharacter = Character(
  level: 1,
  strength: 10,
  xp: 0,
  xpToNextLevel: 100,
  currentHp: 70,
  currentMp: 30,
  equipment: initialEquipment,
);
