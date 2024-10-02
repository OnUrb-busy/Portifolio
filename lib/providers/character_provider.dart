import 'package:flutter/foundation.dart';
import '../models/character.dart';

class CharacterProvider with ChangeNotifier {
  Character _character = Character(level: 1, strength: 10);

  Character get character => _character;

  void levelUp() {
    _character.level += 1;
    notifyListeners();
  }

  void increaseStrength() {
    _character.strength += 5;
    notifyListeners();
  }
}
