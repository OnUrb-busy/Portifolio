import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'character_provider.dart';

class Quest {
  final String name;
  final String description;
  final int rewardPoints;
  final int penaltyPoints;
  bool isCompleted;
  bool isCancelled;
  int remainingTime;

  Quest({
    required this.name,
    required this.description,
    required this.rewardPoints,
    required this.penaltyPoints,
    this.isCompleted = false,
    this.isCancelled = false,
    this.remainingTime = 300, // 5 minutos em segundos por padrão
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'rewardPoints': rewardPoints,
      'penaltyPoints': penaltyPoints,
      'isCompleted': isCompleted,
      'isCancelled': isCancelled,
      'remainingTime': remainingTime,
    };
  }

  static Quest fromMap(Map<String, dynamic> map) {
    return Quest(
      name: map['name'],
      description: map['description'],
      rewardPoints: map['rewardPoints'],
      penaltyPoints: map['penaltyPoints'],
      isCompleted: map['isCompleted'],
      isCancelled: map['isCancelled'],
      remainingTime: map['remainingTime'],
    );
  }
}

class QuestProvider with ChangeNotifier {
  List<Quest> _quests = [];
  final FirebaseFirestore _firestore;
  final Map<int, Timer> _timers = {};
  Timer? _renewalTimer;
  final String userId;
  late CharacterProvider _characterProvider;

  List<Quest> get quests => _quests;

  // Construtor modificado para injeção de FirebaseFirestore
  QuestProvider({
    required this.userId,
    required CharacterProvider characterProvider,
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance {
    _characterProvider = characterProvider;
    _init();
  }

  Future<void> _init() async {
    await checkAndRenewQuests();
    _startAutoRenewal(); // Inicia a renovação automática a cada minuto
  }

  /// Verifica e renova quests se necessário
  Future<void> checkAndRenewQuests() async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('quests').doc(userId).get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        final lastRenewalTimestamp = data?['lastRenewal'] as Timestamp?;

        if (lastRenewalTimestamp != null) {
          final lastRenewalDate = lastRenewalTimestamp.toDate();
          final now = DateTime.now();

          if (now.difference(lastRenewalDate).inMinutes >= 10) {
            await _renewQuests();
          } else {
            await loadQuests(userId);
          }
        } else {
          await _renewQuests();
        }
      } else {
        await _renewQuests();
      }
    } catch (e) {
      print("Erro ao verificar e renovar quests: $e");
    }
  }

  /// Renova as quests
  Future<void> _renewQuests() async {
    _cancelAllTimers();
    _quests = [
      Quest(
          name: '30 flexões',
          description: 'Faça 30 flexões',
          rewardPoints: 50,
          penaltyPoints: 10),
      Quest(
          name: '60 agachamentos',
          description: 'Faça 60 agachamentos',
          rewardPoints: 70,
          penaltyPoints: 15),
      Quest(
          name: '40 abdominais',
          description: 'Faça 40 abdominais',
          rewardPoints: 100,
          penaltyPoints: 20),
    ];
    await saveLastRenewal();
    await saveQuests();
    _startQuestTimers();
    notifyListeners();
  }

  /// Salva a data de última renovação no Firestore
  Future<void> saveLastRenewal() async {
    try {
      await _firestore.collection('quests').doc(userId).set({
        'lastRenewal': FieldValue.serverTimestamp(),
        'quests': _quests.map((quest) => quest.toMap()).toList(),
      });
    } catch (e) {
      print("Erro ao salvar data de renovação: $e");
    }
  }

  /// Inicia o timer de renovação automática
  void _startAutoRenewal() {
    _renewalTimer?.cancel();
    _renewalTimer = Timer.periodic(Duration(minutes: 10), (_) {
      checkAndRenewQuests();
    });
  }

  void completeQuest(int index) {
    if (!_quests[index].isCompleted && !_quests[index].isCancelled) {
      _quests[index].isCompleted = true;
      _timers[index]?.cancel();
      _timers.remove(index);
      saveQuests();
      notifyListeners();
    }
  }

  void startQuestTimers() {
    _startQuestTimers();
  }

  void _startQuestTimers() {
    _cancelAllTimers();
    for (int i = 0; i < _quests.length; i++) {
      if (!_quests[i].isCompleted && !_quests[i].isCancelled) {
        _timers[i] = Timer.periodic(Duration(seconds: 1), (timer) {
          if (_quests[i].remainingTime > 0) {
            _quests[i].remainingTime--;
            notifyListeners();
          } else {
            _quests[i].isCancelled = true;
            print('Penalidade aplicada: ${_quests[i].penaltyPoints}');
            _characterProvider.applyXpPenalty(
                userId: userId, penalty: _quests[i].penaltyPoints);
            timer.cancel();
            _timers.remove(i);
            saveQuests();
            notifyListeners();
          }
        });
      }
    }
  }

  void _cancelAllTimers() {
    for (var timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
  }

  Future<void> loadQuests(String userId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('quests').doc(userId).get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null && data['quests'] != null) {
          _quests =
              (data['quests'] as List).map((q) => Quest.fromMap(q)).toList();
        }
      }
      _startQuestTimers();
      notifyListeners();
    } catch (e) {
      print("Erro ao carregar quests: $e");
    }
  }

  Future<void> saveQuests() async {
    try {
      await _firestore.collection('quests').doc(userId).set({
        'quests': _quests.map((quest) => quest.toMap()).toList(),
      });
    } catch (e) {
      print("Erro ao salvar quests: $e");
    }
  }

  @override
  void dispose() {
    _cancelAllTimers();
    _renewalTimer?.cancel();
    super.dispose();
  }
}
