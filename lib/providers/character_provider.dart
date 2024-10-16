import 'package:flutter/foundation.dart';
import '../models/character.dart';

class CharacterProvider with ChangeNotifier {
  Character _character = Character(
    level: 1,
    strength: 10,
    equipment: {
      'Sword': null,
      'Acc': null,
      'Glove': null,
      'Wrist': null,
      'Helmet': null,
      'Chest': null,
      'Legs': null,
      'Boots': null,
    },
  );

  Character get character => _character;

  void levelUp() {
    _character.level += 1;
    notifyListeners();
  }

  void increaseStrength() {
    _character.strength += 5;
    notifyListeners();
  }

  void equipSword(String equipment) {
    _character.equipment['Sword'] = equipment;
    notifyListeners();
  }

  void equipAcc(String equipment) {
    _character.equipment['Acc'] = equipment;
    notifyListeners();
  }

  void equipGlove(String equipment) {
    _character.equipment['Glove'] = equipment;
    notifyListeners();
  }

  void equipWrist(String equipment) {
    _character.equipment['Wrist'] = equipment;
    notifyListeners();
  }

  void equipHelmet(String equipment) {
    _character.equipment['Helmet'] = equipment;
    notifyListeners();
  }

  void equipChest(String equipment) {
    _character.equipment['Chest'] = equipment;
    notifyListeners();
  }

  void equipLegs(String equipment) {
    _character.equipment['Legs'] = equipment;
    notifyListeners();
  }

  void equipBoots(String equipment) {
    _character.equipment['Boots'] = equipment;
    notifyListeners();
  }
}
