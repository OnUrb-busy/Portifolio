import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Map<int, Timer> _timers = {};

  List<Quest> get quests => _quests;

  QuestProvider() {
    _startQuestTimers();
  }

  void _startQuestTimers() {
    for (int i = 0; i < _quests.length; i++) {
      if (!_timers.containsKey(i) &&
          !_quests[i].isCompleted &&
          !_quests[i].isCancelled) {
        _timers[i] = Timer.periodic(Duration(seconds: 1), (timer) {
          if (_quests[i].remainingTime > 0) {
            _quests[i].remainingTime--;
            notifyListeners();
          } else {
            _quests[i].isCancelled = true;
            timer.cancel();
            _timers.remove(i);
            notifyListeners();
          }
        });
      }
    }
  }

  void completeQuest(String userId, int index) {
    if (!_quests[index].isCompleted && !_quests[index].isCancelled) {
      _quests[index].isCompleted = true;
      _timers[index]?.cancel();
      _timers.remove(index);
      saveQuests(userId);
      notifyListeners();
    }
  }

  void generateDailyQuests(String userId) {
    _quests = [
      Quest(
        name: '30 flexões',
        description: 'Faça 30 flexões',
        rewardPoints: 50,
        penaltyPoints: 10,
      ),
      Quest(
        name: '60 agachamentos',
        description: 'Faça 60 agachamentos',
        rewardPoints: 70,
        penaltyPoints: 15,
      ),
      Quest(
        name: '40 abdominais',
        description: 'Faça 40 abdominais',
        rewardPoints: 100,
        penaltyPoints: 20,
      ),
    ];
    _startQuestTimers();
    saveQuests(userId);
    notifyListeners();
  }

  Future<void> loadQuests(String userId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('quests').doc(userId).get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null && data['quests'] != null) {
          List<dynamic> questData = data['quests'];
          _quests = questData.map((quest) => Quest.fromMap(quest)).toList();
        } else {
          generateDailyQuests(userId);
        }
      } else {
        generateDailyQuests(userId);
      }
      _startQuestTimers();
      notifyListeners();
    } catch (e) {
      print("Erro ao carregar quests: $e");
    }
  }

  Future<void> saveQuests(String userId) async {
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
    for (var timer in _timers.values) {
      timer.cancel();
    }
    super.dispose();
  }
}
