class Character {
  int level;
  int strength;
  Map<String, String?> equipment; // Certifique-se de incluir esta propriedade.

  Character({
    required this.level,
    required this.strength,
    required this.equipment,
  });
}
