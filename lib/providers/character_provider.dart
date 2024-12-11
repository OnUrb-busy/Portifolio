import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/character.dart';

class CharacterProvider with ChangeNotifier {
  Character _character = Character(
    level: 1,
    strength: 10,
    xp: 0,
    xpToNextLevel: 100,
    currentHp: 70,
    currentMp: 30,
    equipment: {
      'Espada': null,
      'Capacete': null,
      'Peitoral': null,
      'Acessórios': null,
      'calça': null,
      'Escudo': null,
      'Anel': null,
      'Luva': null,
    },
    inventory: [],
  );

  Timer? _hpRegenTimer;
  Timer? _mpRegenTimer;

  final FirebaseFirestore _firestore;

  Character get character => _character;

  // Construtor modificado para permitir a injeção de FirebaseFirestore
  CharacterProvider({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance {
    _startRegenTimers();
  }

  Future<void> loadCharacter({required String userId}) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc =
          await _firestore.collection('characters').doc(userId).get();

      if (doc.exists) {
        Map<String, dynamic>? data = doc.data();
        if (data != null) {
          _character = Character(
            level: data['level'] ?? 1,
            strength: data['strength'] ?? 10,
            xp: data['xp'] ?? 0,
            xpToNextLevel: data['xpToNextLevel'] ?? 100,
            currentHp: data['currentHp'] ?? 70,
            currentMp: data['currentMp'] ?? 30,
            equipment: Map<String, String?>.from(data['equipment'] ?? {}),
            inventory: List<String>.from(data['inventory'] ?? []),
          );
        } else {
          await saveCharacter(userId: userId);
        }
      } else {
        await saveCharacter(userId: userId);
      }
      notifyListeners();
    } catch (e) {
      print("[ERROR] Erro ao carregar personagem do Firestore: $e");
    }
  }

  Future<void> saveCharacter({required String userId}) async {
    try {
      await _firestore.collection('characters').doc(userId).set({
        'level': _character.level,
        'strength': _character.strength,
        'xp': _character.xp,
        'xpToNextLevel': _character.xpToNextLevel,
        'currentHp': _character.currentHp,
        'currentMp': _character.currentMp,
        'equipment': _character.equipment,
        'inventory': _character.inventory,
      });
    } catch (e) {
      print("[ERROR] Erro ao salvar personagem no Firestore: $e");
    }
  }

  void addXp({required String userId, required int xpGained}) {
    _character.xp += xpGained;
    if (_character.xp >= _character.xpToNextLevel) {
      _character.xp -= _character.xpToNextLevel;
      levelUp(userId: userId);
    }
    saveCharacter(userId: userId);
    notifyListeners();
  }

  void applyXpPenalty({required String userId, required int penalty}) {
    _character.xp -= penalty;
    if (_character.xp < 0) {
      _character.xp = 0;
    }
    saveCharacter(userId: userId);
    notifyListeners();
  }

  void levelUp({required String userId}) {
    _character.level += 1;
    _character.strength += 5;
    _character.xpToNextLevel += 50 * _character.level;
    _character.currentHp = _character.totalHp;
    _character.currentMp = _character.totalMp;

    saveCharacter(userId: userId);
    notifyListeners();
  }

  void equipItem(
      {required String userId, required String slot, required String item}) {
    if (_character.equipment.containsKey(slot)) {
      _character.equipment[slot] = item;
      saveCharacter(userId: userId);
      notifyListeners();
    }
  }

  void updateHp({required String userId, required int hpChange}) {
    _character.currentHp += hpChange;
    if (_character.currentHp > _character.totalHp) {
      _character.currentHp = _character.totalHp;
    } else if (_character.currentHp < 0) {
      _character.currentHp = 0;
    }
    saveCharacter(userId: userId);
    notifyListeners();
  }

  void addReward({required String userId, required String item}) {
    if (!_character.inventory.contains(item)) {
      _character.inventory.add(item);
      saveCharacter(userId: userId);
      notifyListeners();
    } else {
      print("[INFO] Item já no inventário: $item");
    }
  }

  void _startRegenTimers() {
    _hpRegenTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_character.currentHp < _character.totalHp) {
        _character.currentHp += 1;
        notifyListeners();
      }
    });

    _mpRegenTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      if (_character.currentMp < _character.totalMp) {
        _character.currentMp += 1;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _hpRegenTimer?.cancel();
    _mpRegenTimer?.cancel();
    super.dispose();
  }
}
