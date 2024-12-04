import 'package:flutter/foundation.dart';
import 'dart:math';

class CombatProvider with ChangeNotifier {
  int enemyHealth = 100;
  int enemyLevel = 1;

  void attackEnemy(int damage) {
    enemyHealth -= damage;
    if (enemyHealth < 0) enemyHealth = 0;
    notifyListeners();
  }

  void resetCombat() {
    enemyHealth = 100;
    notifyListeners();
  }

  String generateItemReward() {
    const List<String> possibleRewards = [
      'Espada Comum',
      'Elmo de Ferro',
      'Anel de Prata',
      'Escudo de Bronze',
    ];
    final random = Random();
    return possibleRewards[random.nextInt(possibleRewards.length)];
  }

  int calculateXpReward() {
    return enemyLevel * 20;
  }
}
